#!/usr/bin/env python3
"""青囊 · HOST_PROFILE.md 渲染器
用法: render-host-profile.py <template> <probe.json> <output>
原则: 探测不到的字段填「未检测到」兜底文案，绝不留裸 {{占位符}}
"""
import sys, json, io, re

def main():
    if len(sys.argv) != 4:
        sys.stderr.write("用法: render-host-profile.py <template> <probe.json> <output>\n")
        return 2
    tmpl_path, json_path, out_path = sys.argv[1], sys.argv[2], sys.argv[3]
    try:
        with io.open(json_path, encoding="utf-8") as f:
            d = json.load(f)
    except Exception:
        d = {}

    NA = "未检测到"
    def g(*path, default=NA):
        cur = d
        for k in path:
            if not isinstance(cur, dict): return default
            cur = cur.get(k)
            if cur is None: return default
        return cur

    hw = d.get("hardware") or {}
    rt = d.get("runtimes") or {}
    px = d.get("proxy") or {}
    hs = d.get("hosts") or {}

    def disks_str():
        ds = hw.get("disks") or []
        if not ds: return NA
        return " ｜ ".join("%s %sG 可用 / %sG" % (x.get("mount"), x.get("free_gb"), x.get("total_gb")) for x in ds)

    npx_val = rt.get("npx")
    if npx_val is True:  npx_s = "是"
    elif npx_val is False: npx_s = "否 ⚠️ 必装"
    else: npx_s = NA

    reach = px.get("npm_registry_reachable")
    if reach is True:  reach_s = "是"
    elif reach is False: reach_s = "否 ⚠️ 检查网络/代理"
    else: reach_s = NA

    repl = {
        "{{PROBED_AT}}":       d.get("probed_at") or NA,
        "{{CPU_MODEL}}":       hw.get("cpu_model") or NA,
        "{{CPU_CORES}}":       str(hw.get("cpu_cores") or NA),
        "{{MEMORY_GB}}":       str(hw.get("memory_gb") or NA),
        "{{GPU}}":             hw.get("gpu") or NA,
        "{{DISKS}}":           disks_str(),
        "{{NODE}}":            rt.get("node") or NA,
        "{{NPX}}":             npx_s,
        "{{PYTHON}}":          rt.get("python") or NA,
        "{{NPM}}":             rt.get("npm") or NA,
        "{{GIT}}":             rt.get("git") or NA,
        "{{ENV_HTTP_PROXY}}":  px.get("env_http") or "（未设置）",
        "{{ENV_HTTPS_PROXY}}": px.get("env_https") or "（未设置）",
        "{{ENV_ALL_PROXY}}":   px.get("env_all") or "（未设置）",
        "{{OPEN_PORTS}}":      (", ".join(px.get("open_local_ports") or []) or "（未检测到）"),
        "{{SUGGESTED_PROXY}}": px.get("suggested_url") or "（未检测到，若需代理请手填）",
        "{{NPM_REACHABLE}}":   reach_s,
        "{{HOST_CLAUDE}}":     "是" if hs.get("claude_code") else "否",
        "{{HOST_PI}}":         "是" if hs.get("pi") else "否",
        "{{HOST_CODEX}}":      "是" if hs.get("codex") else "否",
        "{{HOST_OPENCLAW}}":   "是" if hs.get("openclaw") else "否",
    }

    with io.open(tmpl_path, encoding="utf-8") as f:
        t = f.read()
    for k, v in repl.items():
        t = t.replace(k, str(v))

    left = re.findall(r"\{\{[A-Z_]+\}\}", t)
    with io.open(out_path, "w", encoding="utf-8") as f:
        f.write(t)

    if left:
        sys.stderr.write("警告：仍残留未替换占位符 %s\n" % ", ".join(sorted(set(left))))
        return 1
    with io.open(out_path, encoding="utf-8") as f:
        body = f.read()
    if "├─" in body:
        pass
    return 0

if __name__ == "__main__":
    sys.exit(main())
