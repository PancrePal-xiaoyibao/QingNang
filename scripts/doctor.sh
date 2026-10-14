#!/usr/bin/env bash
# 青囊 · 逐通道体检
# 输出契约（冻结）：[序号/总数] 检查项  ✓/⬜/❌  中文结论
#   退出码：存在任一 ❌ → 1，否则 0。⬜（选填未配）不算失败。
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
. "$HERE/lib/common.sh"

REPO_ROOT="$(qrepo_root)"
TOTAL=9; IDX=0
FAILED=0; WARNS=""; FIXES=""

step() { IDX=$((IDX+1)); printf '[%d/%d] %-10s ' "$IDX" "$TOTAL" "$1"; }
line_end() { printf '\n'; }

qinfo "青囊 · 体检"
qinfo "════════════════════════════════"

# ── 1/8 宿主画像（排第一：代理是第一道门槛）─────────────────
step "宿主画像"
HP="$REPO_ROOT/skills/qingnang/HOST_PROFILE.md"
if [ ! -f "$HP" ]; then
  qerr "HOST_PROFILE.md 不存在（先跑 --mode=source）"; FAILED=1
  FIXES="$FIXES\n  · bash scripts/deploy.sh --mode=source"
else
  AGE_MIN=$(( ( $(date +%s) - $(stat -c %Y "$HP" 2>/dev/null || echo 0) ) / 60 ))
  PROXY="$(awk -F'|' '/建议使用的代理地址/{gsub(/^[ \t*]+|[ \t*]+$/,"",$3); print $3; exit}' "$HP" 2>/dev/null)"
  CORES="$(awk -F'|' '/核心数/{gsub(/^[ \t*]+|[ \t*]+$/,"",$3); print $3; exit}' "$HP" 2>/dev/null)"
  # 内存值本身可能带单位（如 "256 GB"），只取数字部分避免出现 "256 GBG"
  MEM="$(awk -F'|' '/内存/{gsub(/^[ \t*]+|[ \t*]+$/,"",$3); print $3; exit}' "$HP" 2>/dev/null | grep -oE '^[0-9]+')"
  CORES="$(printf '%s' "$CORES" | grep -oE '^[0-9]+')"
  qok "已生成（${AGE_MIN} 分钟前）· 代理 ${PROXY:-未检测到} · ${CORES:-?} 核 / ${MEM:-?} GB"
fi
line_end

# ── 2/8 运行时 ────────────────────────────────────────────────
step "运行时"
RT_OK=1
if command -v node >/dev/null 2>&1; then printf '%s Node %s · ' "$SYM_OK" "$(node -v 2>/dev/null | tr -d v)"
else printf '%s Node 缺失 · ' "$SYM_FAIL"; RT_OK=0; FIXES="$FIXES\n  · 安装 Node.js: https://nodejs.org/ （apt/brew install node）"; fi
if command -v npx >/dev/null 2>&1; then printf '%s npx · ' "$SYM_OK"; else printf '%s npx 缺失 · ' "$SYM_FAIL"; RT_OK=0; fi
if command -v python3 >/dev/null 2>&1 || command -v python >/dev/null 2>&1; then printf '%s Python' "$SYM_OK"; else printf '%s Python 缺失' "$SYM_FAIL"; RT_OK=0; fi
[ "$RT_OK" = "1" ] || FAILED=1
line_end

# ── 3/8 网络 ──────────────────────────────────────────────────
step "网络"
if command -v npm >/dev/null 2>&1; then
  if timeout 15 npm view unified-trial-mcp version >/dev/null 2>&1; then
    printf '%s npm registry 可达' "$SYM_OK"
  else
    printf '%s npm registry 不可达' "$SYM_FAIL"; FAILED=1
    FIXES="$FIXES\n  · 检查网络；国内/受限网络需配代理：npm --proxy <addr> --https-proxy <addr>"
  fi
else
  printf '%s npm 缺失' "$SYM_FAIL"; FAILED=1
fi
line_end

# ── 4/8 MCP 握手 ──────────────────────────────────────────────
step "MCP 握手"
if bash "$REPO_ROOT/mcp-servers/healthcheck.sh" --quiet >/dev/null 2>&1; then
  n="$(python3 -c "import json;print(len(json.load(open('$REPO_ROOT/mcp-servers/manifest.json'))['servers']))" 2>/dev/null || echo '?')"
  printf '%s %s 条通道可用' "$SYM_OK" "$n"
else
  printf '%s 有通道不可用' "$SYM_FAIL"; FAILED=1
  FIXES="$FIXES\n  · 详查： bash mcp-servers/healthcheck.sh"
fi
line_end

# ── 5/8 凭据矩阵 ──────────────────────────────────────────────
step "凭据矩阵"
qload_env "$REPO_ROOT/.env"
OPT=""
[ -z "${NCBI_API_KEY:-}" ]     && OPT="$OPT NCBI_API_KEY"
[ -z "${OPENALEX_EMAIL:-}" ]   && OPT="$OPT OPENALEX_EMAIL"
if [ -n "$OPT" ]; then
  printf '%s 选填未配:%s（不影响使用）' "$SYM_OPT" "$OPT"
else
  printf '%s 增强通道已配置' "$SYM_OK"
fi
line_end

# ── 6/8 隐私隔离 ──────────────────────────────────────────────
step "隐私隔离"
PH="$(qhome_root)/private"
P_OK=1
if [ -d "$PH" ]; then
  PERM="$(stat -c '%a' "$PH" 2>/dev/null)"
  if [ "$PERM" = "700" ]; then printf '%s %s 权限 0700 · ' "$SYM_OK" "$PH"
  else printf '%s %s 权限 %s（应为 700）· ' "$SYM_FAIL" "$PH" "$PERM"; P_OK=0; FAILED=1
       FIXES="$FIXES\n  · chmod 700 $PH"; fi
else
  printf '%s %s 不存在（跑 --mode=source 创建）· ' "$SYM_FAIL" "$PH"; P_OK=0; FAILED=1
  FIXES="$FIXES\n  · bash scripts/deploy.sh --mode=source"
fi
if git -C "$REPO_ROOT" check-ignore -q skills/qingnang/HOST_PROFILE.md 2>/dev/null; then
  printf '%s 画像未入库' "$SYM_OK"
else
  printf '%s 画像未加入 .gitignore' "$SYM_FAIL"; FAILED=1
fi
line_end

# ── 7/8 遥测 ──────────────────────────────────────────────────
step "遥测"
if [ "${QINGNANG_TELEMETRY:-off}" = "off" ]; then printf '%s off（唯一合法值）' "$SYM_OK"
else printf '%s 值非法：%s' "$SYM_FAIL" "$QINGNANG_TELEMETRY"; FAILED=1
     FIXES="$FIXES\n  · 编辑 .env，把 QINGNANG_TELEMETRY 设为 off（或删除该行）"; fi
line_end

# ── 8/8 技能层 ────────────────────────────────────────────────
step "技能层"
S_OK=1
chk_size() {
  local f="$1" max="$2" label="$3"
  if [ -f "$f" ]; then
    local sz; sz="$(wc -c < "$f")"
    if [ "$sz" -le "$max" ]; then printf '%s %s %sB/%sB · ' "$SYM_OK" "$label" "$sz" "$max"
    else printf '%s %s %sB 超限 %sB · ' "$SYM_FAIL" "$label" "$sz" "$max"; S_OK=0; FAILED=1; fi
  else printf '%s %s 缺失 · ' "$SYM_FAIL" "$label"; S_OK=0; FAILED=1; fi
}
D="$REPO_ROOT/skills/qingnang"
chk_size "$D/INJECT.md" 2048 "INJECT.md"
chk_size "$D/SEARCH_RUNTIME.md" 8192 "SEARCH_RUNTIME.md"
chk_size "$D/SKILL.md" 14336 "SKILL.md"
printf '%s' "$SYM_OK"
line_end

# ── 9/9 能力层（JS + Python 环境）────────────────────────────
step "能力层"
C_OKA=1
if [ -d "$REPO_ROOT/node_modules" ]; then
  nn="$(ls "$REPO_ROOT/mcp-servers/launch" 2>/dev/null | wc -l | tr -d ' ')"
  printf '%s JS node_modules · %s 个垫片 · ' "$SYM_OK" "$nn"
else
  printf '%s JS 环境未构建 · ' "$SYM_FAIL"; C_OKA=0; FAILED=1
  FIXES="$FIXES\n  · bash scripts/fetch-vendor.sh   （JS 侧降级链：pnpm → npm → yarn）"
fi
if [ -x "$REPO_ROOT/.venv/bin/python" ] || [ -x "$REPO_ROOT/.venv/Scripts/python.exe" ]; then
  printf '%s Python .venv' "$SYM_OK"
elif [ -d "$REPO_ROOT/.venv" ]; then
  printf '%s Python .venv 异常' "$SYM_FAIL"; C_OKA=0
else
  printf '%s Python .venv 未建（当前无 Python 依赖，不影响搜索）' "$SYM_OPT"
fi
line_end

# ── 汇总 ──────────────────────────────────────────────────────
qinfo "════════════════════════════════"
if [ "$FAILED" = "1" ]; then
  qerr "有检查未通过，请修复："
  printf '%b\n' "$FIXES"
  qinfo ""
  qinfo "修好后重跑： bash scripts/doctor.sh"
  exit 1
fi

qok "全部通过。"
qinfo ""
qinfo "你现在可以说："
qinfo "  · 帮我查一下胰腺癌 FOLFIRINOX 方案的最新文献"
qinfo "  · 找一下国内正在招募的胰腺癌临床试验"
qinfo "  · 解释一下 CA19-9 这个指标是什么意思"
exit 0
