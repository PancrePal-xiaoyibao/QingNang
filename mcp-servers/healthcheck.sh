#!/usr/bin/env bash
# 青囊 · MCP 通道健康检查
# 对 manifest.json 中每个 server 做 MCP initialize 握手，打印 server info
#   --quiet  只输出汇总（供 doctor.sh 调用）
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../scripts/lib/common.sh
. "$HERE/../scripts/lib/common.sh"

MANIFEST="$HERE/manifest.json"
QUIET=0
[ "${1:-}" = "--quiet" ] && QUIET=1

[ -f "$MANIFEST" ] || qdie "找不到 $MANIFEST"

# 用 python 做完整握手（读 manifest → 起子进程 → MCP initialize → 校验响应）
python3 - "$MANIFEST" "$QUIET" <<'PY'
import json, subprocess, sys, os

manifest_path, quiet = sys.argv[1], sys.argv[2] == "1"
with open(manifest_path, encoding="utf-8") as f:
    m = json.load(f)

servers = m.get("servers", [])
wl = set(m.get("license_whitelist", []))
ok, fail = [], []

INIT = json.dumps({
    "jsonrpc": "2.0", "id": 1, "method": "initialize",
    "params": {"protocolVersion": "2024-11-05",
               "capabilities": {},
               "clientInfo": {"name": "qingnang-doctor", "version": "0.1.0"}}
}) + "\n"

for s in servers:
    sid = s.get("id", "?")
    lic = s.get("license", "")
    # 许可白名单校验（A12）
    if lic not in wl:
        fail.append((sid, "许可 %s 不在白名单 %s" % (lic, sorted(wl))))
        continue
    cmd = s.get("command") or []
    if not cmd:
        fail.append((sid, "manifest 未声明 command"))
        continue
    env = dict(os.environ)
    for e in s.get("env", []):
        k = e.get("key")
        if k and e.get("value"):
            env[k] = str(e["value"])
    try:
        p = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                             stderr=subprocess.DEVNULL, env=env, text=True)
        try:
            out, _ = p.communicate(INIT, timeout=int(s.get("health", {}).get("timeout_s", 30)))
        except subprocess.TimeoutExpired:
            p.kill(); p.communicate()
            fail.append((sid, "initialize 超时（%ss）" % s.get("health", {}).get("timeout_s", 30)))
            continue
        if out and '"result"' in out:
            ok.append(sid)
        else:
            fail.append((sid, "未返回 initialize result"))
    except FileNotFoundError:
        fail.append((sid, "命令不存在：%s" % cmd[0]))
    except Exception as ex:
        fail.append((sid, "异常：%s" % ex))

if not quiet:
    print("青囊 · MCP 通道健康检查")
    print("─" * 40)
    for sid in ok:
        print("  ✓ %s" % sid)
    for sid, why in fail:
        print("  ❌ %s — %s" % (sid, why))
    print("─" * 40)
    print("通过 %d / 共计 %d" % (len(ok), len(servers)))
    if fail:
        print("")
        print("修复提示：")
        for sid, why in fail:
            print("  · %s：%s" % (sid, why))
        print("  · 网络问题 → 参考 HOST_PROFILE.md 的「网络与代理」一节")

sys.exit(0 if not fail else 1)
PY
