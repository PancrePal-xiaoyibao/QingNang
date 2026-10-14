#!/usr/bin/env bash
# 青囊宿主机探测 → 渲染 HOST_PROFILE.md
# 幂等：可重复跑；探测失败填兜底文案，绝不留裸占位符
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
. "$HERE/lib/common.sh"

REPO_ROOT="$(qrepo_root)"
TMPL="$REPO_ROOT/skills/qingnang/HOST_PROFILE.md.template"
OUT="$REPO_ROOT/skills/qingnang/HOST_PROFILE.md"
PROBE_JSON="$(mktemp)"
trap 'rm -f "$PROBE_JSON"' EXIT

[ -f "$TMPL" ] || qdie "找不到模板：$TMPL"

qinfo "青囊 · 宿主机探测"
qinfo "────────────────────────────────"

bash "$HERE/lib/host-probe.sh" > "$PROBE_JSON" 2>/dev/null || printf '{}' > "$PROBE_JSON"

chmod 600 "$OUT" 2>/dev/null || true
python3 "$HERE/lib/render-host-profile.py" "$TMPL" "$PROBE_JSON" "$OUT"

qok "已生成 skills/qingnang/HOST_PROFILE.md"
qinfo "  含本机代理与硬件信息 → 已加入 .gitignore，不会入库"
qinfo "  提示：搜索失败时，Agent 应先读此文件的「网络与代理」一节"
