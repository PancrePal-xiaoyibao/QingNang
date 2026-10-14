#!/usr/bin/env bash
# 青囊共用工具函数 — 日志 / 符号 / 幂等 / 环境变量校验
# 用法： source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
#
# ⚠️ 本文件是**库**，刻意不设置任何 shell 选项：
#    若在此写 set -e，会把 errexit 泄漏给调用者（source 会修改当前 shell）。
#    而 check.sh / doctor.sh 等刻意使用 set -uo pipefail（要收集全部错误再汇总），
#    一旦被注入 errexit，第一个返回非零的语句就会让整个脚本静默退出。
#    → 各脚本自行声明所需的 set 选项。

# ── 颜色（非 TTY 时自动关闭）──────────────────────────────────
if [ -t 1 ]; then
  C_OK=$'\033[32m'; C_WARN=$'\033[33m'; C_ERR=$'\033[31m'; C_DIM=$'\033[2m'; C_RST=$'\033[0m'
else
  C_OK=''; C_WARN=''; C_ERR=''; C_DIM=''; C_RST=''
fi

SYM_OK='✓'; SYM_OPT='⬜'; SYM_FAIL='❌'

# ── 日志 ──────────────────────────────────────────────────────
qlog()  { printf '%s\n' "$*"; }
qinfo() { printf '%s\n' "$*"; }
qok()   { printf '%s %s\n' "${C_OK}${SYM_OK}${C_RST}" "$*"; }
qwarn() { printf '%s %s\n' "${C_WARN}${SYM_OPT}${C_RST}" "$*"; }
qerr()  { printf '%s %s\n' "${C_ERR}${SYM_FAIL}${C_RST}" "$*" >&2; }
qdie()  { qerr "$*"; exit 1; }

# ── 幂等：把内容写到文件，内容相同则不动（避免无谓 mtime 变化）──
qwrite_if_changed() {
  local target="$1" content="$2"
  mkdir -p "$(dirname "$target")"
  if [ -f "$target" ] && printf '%s' "$content" | cmp -s - "$target"; then
    return 0
  fi
  printf '%s' "$content" > "$target"
}

# ── 幂等：在文件中插入/替换 marker 包裹块（不重复追加）────────
# qupsert_block <file> <marker> <content>
qupsert_block() {
  local file="$1" marker="$2" content="$3"
  local begin="<!-- QINGNANG:BEGIN ${marker} -->"
  local end="<!-- QINGNANG:END ${marker} -->"
  mkdir -p "$(dirname "$file")"
  [ -f "$file" ] || : > "$file"

  if grep -qF "$begin" "$file" 2>/dev/null; then
    # 用 awk 替换 begin..end 之间的内容
    awk -v b="$begin" -v e="$end" -v new="$content" '
      $0==b { print; print new; inblock=1; next }
      $0==e { inblock=0 }
      !inblock { print }
    ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
  else
    {
      [ -s "$file" ] && printf '\n'
      printf '%s\n' "$begin"
      printf '%s\n' "$content"
      printf '%s\n' "$end"
    } >> "$file"
  fi
}

# ── 从 marker 块中移除（卸载用）──────────────────────────────
qremove_block() {
  local file="$1" marker="$2"
  [ -f "$file" ] || return 0
  local begin="<!-- QINGNANG:BEGIN ${marker} -->"
  local end="<!-- QINGNANG:END ${marker} -->"
  awk -v b="$begin" -v e="$end" '
    $0==b { inblock=1; next }
    $0==e { inblock=0; next }
    !inblock { print }
  ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
}

# ── 路径 ──────────────────────────────────────────────────────
qrepo_root() { cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd; }
qhome_root() { printf '%s' "${QINGNANG_HOME:-$HOME/.qingnang}"; }

# ── .env 装载（只读变量名，不打印值）─────────────────────────
qload_env() {
  local envfile="${1:-$(qrepo_root)/.env}"
  [ -f "$envfile" ] || return 0
  set -a
  # shellcheck disable=SC1090
  . "$envfile"
  set +a
}

# ── 遥测校验（唯一合法值 off）────────────────────────────────
qcheck_telemetry() {
  local v="${QINGNANG_TELEMETRY:-off}"
  if [ "$v" != "off" ]; then
    qerr "QINGNANG_TELEMETRY 的值 '$v' 非法。"
    qinfo "  本包遥测唯一合法值是 off（默认即 off，无需设置）。"
    qinfo "  请编辑 .env 或删除该变量后重试。"
    return 1
  fi
  return 0
}

# ── 依赖检查 ──────────────────────────────────────────────────
qneed_cmd() {
  command -v "$1" >/dev/null 2>&1 || qdie "缺少命令：$1  （$2）"
}

# ── 版本比较： qver_ge <实际> <要求> ─────────────────────────
qver_ge() {
  [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -1)" = "$2" ]
}
