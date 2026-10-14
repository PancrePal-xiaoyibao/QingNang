#!/usr/bin/env bash
# 青囊 · 构建本地能力层环境（JS + Python）
#
# 目标：一次 clone 后，在本项目工作区就地构建好全部运行环境，之后离线可用。
#
# ══ JS 侧（MCP 运行环境）═ 降级链 ══════════════════════════════════════════
#   首选 pnpm   —— 隔离式 node_modules，天然支持一个项目内多版本依赖并存
#                   （5 个 MCP 合并后 @modelcontextprotocol/sdk 有 5 个版本区间、
#                    express 有 4.x/5.x 大版本冲突，扁平化会摊在一起）
#   次选 npm    —— 扁平化，通常可用；有冲突风险但已实测通过
#   兜底 yarn   —— 用户只有 yarn 时
#   再兜底      —— 明示包管理器缺失 + 给出安装命令，不静默失败
#
# ══ Python 侧（Phase 3 承载 PDF 解析 / 本地 RAG）═ 降级链 ═════════════════
#   首选 uv venv          —— 快、有 lock、可重现
#   次选 python -m venv   —— 标准库，一定有
#   兜底 conda create     —— 用户只有 conda 时
#   再兜底                —— 明示 Python 能力不可用；**不影响 JS 侧的六条搜索通道**
#
# 用法： bash scripts/fetch-vendor.sh [--force] [--js-only] [--py-only]
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
. "$HERE/lib/common.sh"

REPO_ROOT="$(qrepo_root)"
cd "$REPO_ROOT"

FORCE=0; JS_ONLY=0; PY_ONLY=0
for a in "$@"; do
  case "$a" in
    --force)   FORCE=1 ;;
    --js-only) JS_ONLY=1 ;;
    --py-only) PY_ONLY=1 ;;
    -h|--help) sed -n '2,25p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
  esac
done

FAILED=0
PY_OK=0

qinfo "青囊 · 构建本地能力层"
qinfo "════════════════════════════════════════"
[ "$FORCE" = "1" ] && qinfo "模式：--force（强制重建）"

# ════════════════════════════════════════════════════════════════════════
# A. JS 侧 —— MCP 运行环境
# ════════════════════════════════════════════════════════════════════════
build_js() {
  qinfo ""
  qinfo "【A】JS 侧 · MCP 运行环境"
  qinfo "────────────────────────────────────────"

  # ── 前置：Node ──────────────────────────────────────────────
  if ! command -v node >/dev/null 2>&1; then
    qerr "缺少 Node.js（MCP 运行必需）"
    qinfo "  安装： https://nodejs.org/   或  apt install nodejs npm  /  brew install node"
    return 1
  fi
  local major; major="$(node -p 'process.versions.node.split(".")[0]' 2>/dev/null || echo 0)"
  if [ "$major" -lt 22 ]; then
    qerr "Node 版本过低：$(node -v)（需要 >= 22.13.0）"
    qinfo "  原因：unified-trial-mcp 要求 node >=22.13.0，是五个 MCP 里最严的下限。"
    qinfo "  安装新版： https://nodejs.org/   或  nvm install 22  /  fnm install 22"
    return 1
  fi
  qok "Node $(node -v)"

  # ── 选包管理器（降级链）─────────────────────────────────────
  # 注意：包管理器 --version 可能因 corepack 版本切换而挂起，必须加超时
  have_pm() { command -v "$1" >/dev/null 2>&1 && timeout 10 "$1" --version >/dev/null 2>&1; }

  local PM="" PM_WHY=""
  if have_pm pnpm; then
    PM=pnpm; PM_WHY="首选（隔离式依赖布局）"
  elif have_pm corepack; then
    qinfo "  未检测到可用 pnpm，尝试用 corepack 启用…"
    timeout 60 corepack enable >/dev/null 2>&1 || true
    timeout 90 corepack prepare pnpm@10.15.0 --activate >/dev/null 2>&1 || true
    if have_pm pnpm; then PM=pnpm; PM_WHY="corepack 启用"
    else qwarn "  corepack 启用 pnpm 失败"; fi
  fi
  if [ -z "$PM" ] && have_pm npm;  then PM=npm;  PM_WHY="次选（扁平化，多版本依赖有冲突风险）"; fi
  if [ -z "$PM" ] && have_pm yarn; then PM=yarn; PM_WHY="兜底"; fi

  if [ -z "$PM" ]; then
    qerr "未找到任何 JS 包管理器（pnpm / npm / yarn 均不可用）"
    qinfo "  请先安装： npm i -g pnpm   （推荐）  或安装 Node.js（自带 npm）"
    qinfo "  下载： https://nodejs.org/"
    return 1
  fi
  qok "包管理器：$PM（$(timeout 10 "$PM" --version 2>/dev/null | head -1)）— $PM_WHY"
  [ "$PM" = "npm" ] && qwarn "  ⚠️ npm 扁平化：本项目已知 @modelcontextprotocol/sdk / express 存在多版本共存，"
  [ "$PM" = "npm" ] && qwarn "     若 healthcheck 出现模块解析错误，请改装 pnpm： npm i -g pnpm"

  # ── 安装（带重试与超时说明）─────────────────────────────────
  qinfo "  安装 5 个 MCP（版本已在 package.json 钉死）…"
  local rc=0
  case "$PM" in
    pnpm)
      if [ "$FORCE" = "1" ]; then timeout 900 pnpm install --force
      else timeout 900 pnpm install; fi
      rc=$? ;;
    yarn)
      if [ "$FORCE" = "1" ]; then timeout 900 yarn install --force
      else timeout 900 yarn install; fi
      rc=$? ;;
    npm)
      timeout 900 npm install --no-audit --no-fund --fetch-retries=5 --fetch-retry-maxtimeout=120000
      rc=$? ;;
  esac

  if [ "$rc" != "0" ]; then
    qerr "安装失败（$PM 退出码 $rc）"
    qinfo "  常见原因与对策："
    qinfo "    · 网络慢 → 耐心重跑一次（npm 可达但慢，实测约 7 分钟）"
    qinfo "    · 需要代理 → 安装期代理与运行期代理是两件事，安装期用命令行："
    qinfo "        npm --proxy <代理> --https-proxy <代理> install"
    qinfo "        pnpm config set proxy <代理> && pnpm config set https-proxy <代理>"
    qinfo "    · registry 不通 → npm config get registry 检查，必要时换镜像"
    return 1
  fi
  qok "依赖安装完成"

  # ── 生成稳定启动层（shim）────────────────────────────────────
  qinfo "  生成稳定启动层 mcp-servers/launch/ …"
  if python3 "$HERE/lib/make-launch-shims.py" "$REPO_ROOT" ; then
    qok "启动层就绪"
  else
    qerr "启动层生成失败"
    return 1
  fi
  return 0
}

# ════════════════════════════════════════════════════════════════════════
# B. Python 侧 —— 项目活动区独立环境（.venv）
# ════════════════════════════════════════════════════════════════════════
build_py() {
  qinfo ""
  qinfo "【B】Python 侧 · 项目活动区环境（.venv）"
  qinfo "────────────────────────────────────────"

  # ── 找 Python（降级链：python3 → python）────────────────────
  local PY=""
  if command -v python3 >/dev/null 2>&1; then PY=python3
  elif command -v python  >/dev/null 2>&1; then PY=python
  else
    qwarn "未检测到 Python —— 跳过 Python 环境构建"
    qinfo "  【不受影响】六条搜索通道全部是 Node 侧，Python 侧当前无依赖（Phase 3 才用）"
    qinfo "  若日后要用 PDF 解析： https://www.python.org/downloads/"
    return 0   # 不算失败：JS 侧能力完整
  fi
  local PYV; PYV="$("$PY" --version 2>&1 | awk '{print $2}')"
  qok "Python $PYV（$PY）"

  # ── 环境已存在？──────────────────────────────────────────────
  local VENV="$REPO_ROOT/.venv"
  if [ -d "$VENV" ] && [ "$FORCE" != "1" ]; then
    if [ -x "$VENV/bin/python" ] || [ -x "$VENV/Scripts/python.exe" ]; then
      qok "环境已存在：.venv（重跑 --force 可重建）"
      PY_OK=1
      return 0
    fi
  fi

  # ── 选构建器（降级链：uv → venv → conda）───────────────────
  local BUILDER="" B_WHY=""

  if command -v uv >/dev/null 2>&1; then
    BUILDER=uv; B_WHY="首选（快、有 lock）"
  elif "$PY" -c 'import venv' >/dev/null 2>&1; then
    BUILDER=venv; B_WHY="次选（标准库，一定有）"
  elif command -v conda >/dev/null 2>&1; then
    BUILDER=conda; B_WHY="兜底（用户只有 conda）"
  fi

  if [ -z "$BUILDER" ]; then
    qwarn "无可用 Python 环境构建器（uv / venv / conda 均不可用）"
    qinfo "  【不受影响】搜索通道是 Node 侧，Python 侧当前无依赖"
    qinfo "  建议装 uv（体积小、速度最快）："
    qinfo "    curl -LsSf https://astral.sh/uv/install.sh | sh"
    return 0   # 不算失败
  fi
  qok "构建器：$BUILDER — $B_WHY"

  [ "$FORCE" = "1" ] && [ -d "$VENV" ] && { qinfo "  移除旧环境…"; /bin/rm -rf "$VENV"; }

  local rc=0
  case "$BUILDER" in
    uv)
      ( cd "$REPO_ROOT" && timeout 600 uv venv "$VENV" ) || rc=$?
      if [ "$rc" = "0" ] && [ -f "$REPO_ROOT/pyproject.toml" ]; then
        # 版本钉死由 pyproject.toml 承载；--no-install-project 因为本包本身不是要装的库
        ( cd "$REPO_ROOT" && VIRTUAL_ENV="$VENV" timeout 600 uv pip install -e . --no-deps 2>/dev/null ) || true
      fi
      ;;
    venv)
      timeout 300 "$PY" -m venv "$VENV" || rc=$?
      ;;
    conda)
      # conda 环境也放在项目活动区（而非 ~/miniconda3/envs），保持「一切在项目内」
      timeout 600 conda create -y -p "$VENV" "python=$PYV" >/dev/null || rc=$?
      ;;
  esac

  if [ "$rc" != "0" ] || { [ ! -x "$VENV/bin/python" ] && [ ! -x "$VENV/Scripts/python.exe" ]; }; then
    qwarn "环境构建失败（$BUILDER 退出码 $rc）"
    qinfo "  【不受影响】搜索通道是 Node 侧，可继续使用"
    if [ "$BUILDER" != "venv" ] && "$PY" -c 'import venv' >/dev/null 2>&1; then
      qinfo "  自动降级到 python -m venv 重试…"
      timeout 300 "$PY" -m venv "$VENV" && PY_OK=1 && qok "降级成功：.venv 已就绪（python -m venv）"
    fi
    [ "$PY_OK" = "0" ] && return 0
  fi

  PY_OK=1
  qok "Python 环境就绪：.venv"
  qinfo "  使用方式： source .venv/bin/activate  （Windows: .venv\\Scripts\\activate）"
  return 0
}

# ════════════════════════════════════════════════════════════════════════
# 主流程
# ════════════════════════════════════════════════════════════════════════
JS_OK=0
[ "$PY_ONLY" = "1" ] || { build_js && JS_OK=1 || FAILED=1; }
[ "$JS_ONLY" = "1" ] || { build_py || FAILED=1; }
[ "$JS_ONLY" = "1" ] && PY_OK=1

qinfo ""
qinfo "════════════════════════════════════════"
if [ "$JS_OK" = "1" ]; then qok "JS 侧（MCP 运行环境）：就绪"
else qerr "JS 侧（MCP 运行环境）：未就绪"; fi
if [ "$PY_OK" = "1" ]; then qok "Python 侧（Phase 3 承载）：就绪"
else qwarn "Python 侧：未就绪（不影响搜索通道）"; fi

if [ "$JS_OK" != "1" ]; then
  qinfo ""
  qerr "JS 侧是青囊的核心，必须修好再继续。"
  exit 1
fi

qinfo ""
qinfo "下一步："
qinfo "  bash scripts/deploy.sh --mode=source       # 探测本机 + 建立私有数据目录"
qinfo "  bash mcp-servers/healthcheck.sh            # 逐通道握手"
qinfo "  bash scripts/doctor.sh                     # 全面体检"
exit 0
