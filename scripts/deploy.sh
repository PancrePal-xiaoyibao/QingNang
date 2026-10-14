#!/usr/bin/env bash
# 青囊 · 部署脚本
#   --mode=source   装依赖 + 拉 MCP + 探测本机（生成 HOST_PROFILE.md）
#   --mode=agent    把三个注入文件装到宿主技能目录
#   --host=<h>      指定宿主（claude|pi|openclaw|codex），不填则自动探测
#   --link          用软链代替复制（源改了宿主副本自动跟随）
#   --dry-run       只验证链路，不写任何文件、不读真实凭据值
#   --uninstall     卸载 agent 模式写入的内容
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
. "$HERE/lib/common.sh"

REPO_ROOT="$(qrepo_root)"
MODE=""; HOST=""; LINK=0; DRY=0; UNINSTALL=0
MARKER="qingnang-inject"

usage() { sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'; exit 0; }

for a in "$@"; do
  case "$a" in
    --mode=*) MODE="${a#*=}" ;;
    --host=*) HOST="${a#*=}" ;;
    --link) LINK=1 ;;
    --dry-run) DRY=1 ;;
    --uninstall) UNINSTALL=1 ;;
    -h|--help) usage ;;
    *) qdie "未知参数：$a（用 --help 看用法）" ;;
  esac
done

qinfo "青囊 · 部署"
qinfo "────────────────────────────────"
[ "$DRY" = "1" ] && qinfo "模式：dry-run（只验证，不写文件）"

# ── 前置：遥测校验（唯一合法值 off）─────────────────────────
qload_env "$REPO_ROOT/.env"
qcheck_telemetry || exit 1

# ── 前置：依赖 ────────────────────────────────────────────────
need_node=1
command -v node >/dev/null 2>&1 || { qerr "缺少 Node.js（MCP 走 npx，必需）"; qinfo "  安装：https://nodejs.org/ 或 apt/brew install node"; need_node=0; }
command -v npx  >/dev/null 2>&1 || { qerr "缺少 npx（随 Node 安装）"; need_node=0; }
[ "$DRY" = "1" ] || [ "$need_node" = "1" ] || exit 1

# ── HOST_PROFILE.md 准备（三个注入文件之一）──────────────────
ensure_host_profile() {
  local out="$REPO_ROOT/skills/qingnang/HOST_PROFILE.md"
  if [ -f "$out" ]; then
    qok "宿主画像已存在：skills/qingnang/HOST_PROFILE.md"
  elif [ "$DRY" = "1" ]; then
    qinfo "[dry-run] 将生成 skills/qingnang/HOST_PROFILE.md"
  else
    qinfo "探测本机（硬件/网络/代理）→ 生成宿主画像"
    bash "$HERE/probe-host.sh" >/dev/null
  fi
}

# ── 宿主推断 ──────────────────────────────────────────────────
detect_host() {
  [ -n "$HOST" ] && { printf '%s' "$HOST"; return; }
  if   [ -d "$HOME/.claude" ]; then printf 'claude'
  elif [ -d "$HOME/.pi" ];     then printf 'pi'
  elif [ -d "$HOME/.codex" ];  then printf 'codex'
  elif [ -d "$HOME/.openclaw" ] || [ -d "$PWD/config/openclaw" ]; then printf 'openclaw'
  else printf 'claude'; fi
}

host_skill_dir() {
  case "$1" in
    claude)   printf '%s' "$HOME/.claude/skills" ;;
    pi)       printf '%s' "$HOME/.claude/skills" ;;   # pi 继承 .claude/skills
    codex)    printf '%s' "" ;;                        # Codex 无 skills 惯例 → 走 AGENTS.md
    openclaw) printf '%s' "$PWD/config/openclaw/workspace/skills" ;;
    *)        printf '%s' "$HOME/.claude/skills" ;;
  esac
}

# ── 三个注入文件 ──────────────────────────────────────────────
INJECT_FILES="INJECT.md SEARCH_RUNTIME.md SKILL.md MERGE_CONTRACT.md HOST_PROFILE.md"

do_source() {
  qinfo "① 建立本机画像（硬件 / 网络 / 代理 / 构建器）"
  ensure_host_profile

  qinfo "② 校验 MCP 清单"
  local mf="$REPO_ROOT/mcp-servers/manifest.json"
  [ -f "$mf" ] || qdie "找不到 $mf"
  local n
  n="$(python3 -c "import json;print(len(json.load(open('$mf'))['servers']))" 2>/dev/null || echo '?')"
  qok "清单就绪：$n 条零凭据通道"

  qinfo "③ 构建本地能力层环境（JS + Python）"
  if [ "$DRY" = "1" ]; then
    qinfo "[dry-run] 将执行 scripts/fetch-vendor.sh"
    qinfo "           JS 侧降级链：pnpm → npm → yarn"
    qinfo "           Python 侧降级链：uv venv → python -m venv → conda"
  else
    if [ -d "$REPO_ROOT/node_modules" ] && [ -d "$REPO_ROOT/mcp-servers/launch" ]; then
      qok "能力层已存在（重跑 --force 可重建）：node_modules/ + mcp-servers/launch/"
    else
      qinfo "  首次构建，可能需要几分钟（下载 5 个 MCP 及其依赖）…"
      if ! bash "$HERE/fetch-vendor.sh"; then
        qerr "能力层构建失败"
        qinfo "  排查： bash scripts/fetch-vendor.sh   （单独跑看详细输出）"
        exit 1
      fi
    fi
  fi

  qinfo "④ 创建私有数据目录"
  local ph; ph="$(qhome_root)/private"
  if [ "$DRY" = "1" ]; then
    qinfo "[dry-run] 将创建 $ph（权限 0700）"
  else
    mkdir -p "$ph"
    chmod 700 "$ph" 2>/dev/null || true
    qok "私有目录就绪：$ph（0700）"
  fi

  qinfo "⑤ 提示"
  qinfo "  下一步： bash scripts/deploy.sh --mode=agent"
  qinfo "  然后：   bash scripts/doctor.sh"
}

do_agent() {
  local h; h="$(detect_host)"
  local sdir; sdir="$(host_skill_dir "$h")"
  qinfo "宿主：$h"

  # 必备三件套检查（A28）
  local missing=""
  for f in INJECT.md SEARCH_RUNTIME.md HOST_PROFILE.md; do
    [ -f "$REPO_ROOT/skills/qingnang/$f" ] || missing="$missing $f"
  done
  if [ -n "$missing" ]; then
    qerr "缺少注入文件：$missing"
    qinfo "  先跑： bash scripts/deploy.sh --mode=source"
    exit 1
  fi

  if [ "$h" = "codex" ]; then
    # Codex 无 skills 惯例 → 向 AGENTS.md 追加 marker 块
    local target="$HOME/.codex/AGENTS.md"
    local content
    content="$(cat <<EOF
青囊（QingNang）医学能力包已就绪。
- 主注入：$REPO_ROOT/skills/qingnang/INJECT.md
- 搜索分流：$REPO_ROOT/skills/qingnang/SEARCH_RUNTIME.md
- 本机画像：$REPO_ROOT/skills/qingnang/HOST_PROFILE.md
涉及医学检索时，先读搜索分流表再动手。
EOF
)"
    if [ "$DRY" = "1" ]; then
      qinfo "[dry-run] 将在 $target 写入 marker 块 $MARKER（幂等 upsert）"
    else
      qupsert_block "$target" "$MARKER" "$content"
      qok "已注入 $target（marker: $MARKER）"
    fi
  else
    [ -n "$sdir" ] || qdie "无法确定 $h 的技能目录"
    local dest="$sdir/qingnang"
    if [ "$DRY" = "1" ]; then
      qinfo "[dry-run] 将安装到 $dest（link=$LINK）"
    else
      mkdir -p "$dest"
      for f in $INJECT_FILES; do
        local src="$REPO_ROOT/skills/qingnang/$f"
        [ -f "$src" ] || continue
        if [ "$LINK" = "1" ]; then
          ln -sfn "$src" "$dest/$f"
        else
          cp -f "$src" "$dest/$f"
        fi
      done
      [ -d "$REPO_ROOT/skills/qingnang/references" ] && {
        if [ "$LINK" = "1" ]; then ln -sfn "$REPO_ROOT/skills/qingnang/references" "$dest/references"
        else rm -rf "$dest/references"; cp -r "$REPO_ROOT/skills/qingnang/references" "$dest/references"; fi
      }
      qok "已安装到 $dest（$(printf '%s ' $INJECT_FILES | wc -w) 个注入文件 + references/）"
    fi
  fi

  qinfo "  下一步： bash scripts/doctor.sh"
}

do_uninstall() {
  local h; h="$(detect_host)"
  local sdir; sdir="$(host_skill_dir "$h")"
  if [ "$h" = "codex" ]; then
    qremove_block "$HOME/.codex/AGENTS.md" "$MARKER"
    qok "已移除 $HOME/.codex/AGENTS.md 中的青囊块"
  else
    rm -rf "$sdir/qingnang"
    qok "已移除 $sdir/qingnang"
  fi
}

# ── 主流程 ────────────────────────────────────────────────────
if [ "$UNINSTALL" = "1" ]; then
  do_uninstall
elif [ "$MODE" = "source" ]; then
  do_source
elif [ "$MODE" = "agent" ]; then
  do_agent
else
  qerr "必须指定 --mode=source 或 --mode=agent"
  qinfo ""
  usage
fi

qinfo "────────────────────────────────"
qok "完成"
