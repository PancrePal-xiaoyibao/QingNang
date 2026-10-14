#!/usr/bin/env python3
"""青囊 · 生成 MCP 稳定启动垫片（launch shims）

为什么需要垫片：
  manifest.json 里如果直接写 `npx -y <pkg>@<ver>`，每次启动都要联网拉包；
  如果直接写 `node node_modules/<pkg>/<entry>`，又要写死包管理器的目录布局
  （pnpm 是 .pnpm/<pkg>@<ver>/node_modules/<pkg>/，npm 是扁平 node_modules/<pkg>/）。

  垫片把「布局差异」挡在 mcp-servers/launch/<id> 这一层，
  让 manifest.json 的 command 对两种布局都成立，同时完全离线可启动。

用法: make-launch-shims.py <repo_root>
退出码: 0 全部成功；1 有包缺入口
"""
import json
import os
import stat
import sys

SHIM_TMPL = """#!/usr/bin/env bash
# 青囊 MCP 启动垫片 —— 自动生成，请勿手改（由 scripts/lib/make-launch-shims.py 重建）
# 通道: {sid}    包: {pkg}@{ver}    许可: {lic}
# 预设参数: {args_pretty}
# 作用: 把包管理器的目录布局差异（pnpm 隔离 / npm 扁平）挡在这一层，
#       让 manifest.json 的 command 保持稳定，并支持完全离线启动。
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${{BASH_SOURCE[0]}}")/../.." && pwd)"
ENTRY="$REPO_ROOT/node_modules/{pkg}/{entry_escaped}"
if [ ! -f "$ENTRY" ]; then
  echo "青囊: MCP 入口不存在: $ENTRY" >&2
  echo "  请先运行: bash scripts/fetch-vendor.sh" >&2
  exit 1
fi
# 预设子命令在前（如 unified-trial-mcp 需要 serve 才启动 MCP 服务），用户参数在后
exec node "$ENTRY"{args_exec} "$@"
"""


def find_entry(repo: str, pkg: str) -> str | None:
    """在已安装的 node_modules 里找包的入口（bin → main → 常见回退）"""
    pkg_dir = os.path.join(repo, "node_modules", *pkg.split("/"))
    pj = os.path.join(pkg_dir, "package.json")
    if not os.path.isfile(pj):
        return None
    try:
        with open(pj, encoding="utf-8") as f:
            d = json.load(f)
    except Exception:
        return None

    cands = []
    b = d.get("bin")
    if isinstance(b, str):
        cands.append(b)
    elif isinstance(b, dict):
        cands.extend(b.values())
    if d.get("main"):
        cands.append(d["main"])
    cands += ["build/index.js", "dist/index.js", "src/index.js", "src/cli.js"]

    for c in cands:
        if not c:
            continue
        rel = c[2:] if c.startswith("./") else c
        if os.path.isfile(os.path.join(pkg_dir, rel)):
            return rel
    return None


def main() -> int:
    if len(sys.argv) != 2:
        sys.stderr.write("用法: make-launch-shims.py <repo_root>\n")
        return 2
    repo = os.path.abspath(sys.argv[1])
    mf_path = os.path.join(repo, "mcp-servers", "manifest.json")
    if not os.path.isfile(mf_path):
        sys.stderr.write("找不到 %s\n" % mf_path)
        return 2

    with open(mf_path, encoding="utf-8") as f:
        m = json.load(f)

    launch_dir = os.path.join(repo, "mcp-servers", "launch")
    os.makedirs(launch_dir, exist_ok=True)

    made, errors = [], []
    for s in m.get("servers", []):
        sid = s["id"]
        pkg = s["package"]
        ver = s.get("version", "?")
        lic = s.get("license", "?")
        entry = find_entry(repo, pkg)
        if not entry:
            errors.append("%s (%s@%s): 在 node_modules 中找不到入口（是否未安装？）" % (sid, pkg, ver))
            continue
        # 预设参数：某些 MCP 需要子命令才能进入服务模式（实测 unified-trial-mcp 需 serve）
        args = s.get("args") or []
        args_exec = "".join(' "%s"' % a for a in args)
        args_pretty = " ".join(args) if args else "（无）"
        body = SHIM_TMPL.format(sid=sid, pkg=pkg, ver=ver, lic=lic,
                                entry_escaped=entry,
                                args_exec=args_exec, args_pretty=args_pretty)
        path = os.path.join(launch_dir, sid)
        with open(path, "w", encoding="utf-8") as f:
            f.write(body)
        os.chmod(path, os.stat(path).st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
        made.append("%s -> node_modules/%s/%s" % (sid, pkg, entry))

    for line in made:
        print("  ✓ %s" % line)
    if errors:
        for e in errors:
            sys.stderr.write("  ❌ %s\n" % e)
        return 1
    print("  共生成 %d 个垫片（mcp-servers/launch/）" % len(made))
    return 0


if __name__ == "__main__":
    sys.exit(main())
