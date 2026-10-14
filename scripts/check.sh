#!/usr/bin/env bash
# 青囊 · 聚合自检
#   --only=a,b,c  只跑指定检查项（默认全部）
# 检查类别：whitelist(清单) manifest(MCP清单) skill(技能层) isolation(隐私) guard(敏感闸) scripts(脚本语法)
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
. "$HERE/lib/common.sh"

REPO_ROOT="$(qrepo_root)"
cd "$REPO_ROOT"

ONLY=""
for a in "$@"; do case "$a" in --only=*) ONLY="${a#*=}" ;; esac; done
want() { [ -z "$ONLY" ] && return 0; case ",$ONLY," in *",$1,"*) return 0 ;; esac; return 1; }

FAILED=0
pass() { qok "$1"; }
fail() { qerr "$1"; FAILED=1; }

qinfo "青囊 · 自检"
qinfo "════════════════════════════════"

# ── 1. 修复脚本语法 ───────────────────────────────────────────
if want scripts; then
  qinfo "── 脚本语法 ──"
  bad=0
  for f in scripts/*.sh scripts/lib/*.sh mcp-servers/*.sh; do
    [ -f "$f" ] || continue
    if ! bash -n "$f" 2>/dev/null; then qerr "语法错误：$f"; bad=1; fi
  done
  [ "$bad" = "0" ] && pass "全部 shell 脚本语法通过" || FAILED=1
fi

# ── 2. MCP 清单合法性 ────────────────────────────────────────
if want manifest; then
  qinfo "── MCP 清单 ──"
  python3 - <<'PY' || FAILED=1
import json, sys
mf = "mcp-servers/manifest.json"
d = json.load(open(mf, encoding="utf-8"))
errs = []
wl = set(d.get("license_whitelist", []))
names = set()
for s in d.get("servers", []):
    sid = s.get("id", "?")
    for k in ("id","server_name","package","version","license","command"):
        if not s.get(k): errs.append(f"{sid}: 缺字段 {k}")
    if s.get("license") and s["license"] not in wl:
        errs.append(f"{sid}: 许可 {s['license']} 不在白名单 {sorted(wl)}")
    sn = s.get("server_name", "")
    if sn:
        import re
        if not re.fullmatch(r"[A-Za-z0-9_-]{1,32}", sn):
            errs.append(f"{sid}: server_name '{sn}' 不匹配 [A-Za-z0-9_-]{{1,32}}")
        if sn in names: errs.append(f"{sid}: server_name '{sn}' 重复")
        names.add(sn)
    # 两种合法形态：(a) 指向本地垫片 mcp-servers/launch/<id>（离线可启动，版本由 package.json 钉死）
    #               (b) 直接 npx <pkg>@<version>（必须显式钉版本）
    cmd = s.get("command", [])
    is_shim = any("mcp-servers/launch/" in str(a) for a in cmd)
    has_ver = any("@" in str(a) for a in cmd)
    if not (is_shim or has_ver):
        errs.append(f"{sid}: command 既未指向本地垫片，也未钉死版本")
    if is_shim and "version" not in s:
        errs.append(f"{sid}: 指向垫片但未声明 version（垫片依赖它记录来源）")
if errs:
    print("❌ MCP 清单问题：")
    for e in errs: print("   ·", e)
    sys.exit(1)
print(f"✓ {len(d.get('servers',[]))} 条通道声明合法；{len(d.get('reserved',[]))} 条 reserved")
PY
fi

# ── 3. 技能层体积 + 内容 ─────────────────────────────────────
if want skill; then
  qinfo "── 技能层 ──"
  D="skills/qingnang"
  chk() {
    local f="$1" max="$2"
    if [ ! -f "$f" ]; then fail "缺失：$f"; return; fi
    local sz; sz="$(wc -c < "$f")"
    if [ "$sz" -le "$max" ]; then pass "$(basename "$f") ${sz}B / ${max}B"
    else fail "$(basename "$f") 超限：${sz}B > ${max}B"; fi
  }
  chk "$D/INJECT.md" 2048
  chk "$D/SEARCH_RUNTIME.md" 8192
  chk "$D/SKILL.md" 14336

  # A8: 三条医学红线关键词
  if [ -f "$D/INJECT.md" ]; then
    miss=""
    grep -q '不做诊断' "$D/INJECT.md" || miss="$miss 不做诊断"
    grep -qE '不给(用药)?剂量' "$D/INJECT.md" || miss="$miss 不给剂量"
    grep -qE '隐私|不出机|永不上传' "$D/INJECT.md" || miss="$miss 隐私"
    [ -z "$miss" ] && pass "INJECT.md 含三条医学红线" || fail "INJECT.md 缺红线关键词：$miss"
  fi

  # A24: 主注入含搜索引导但**不含具体工具包名**（薄提示）
  if [ -f "$D/INJECT.md" ]; then
    if ! grep -q 'SEARCH_RUNTIME' "$D/INJECT.md"; then fail "INJECT.md 缺「涉搜索先读 SEARCH_RUNTIME」引导"
    else
      leak=""
      for p in open-websearch bing-cn-mcp mcp-pubmed-llm-server openalex-mcp-server unified-trial-mcp; do
        grep -q "$p" "$D/INJECT.md" && leak="$leak $p"
      done
      [ -z "$leak" ] && pass "INJECT.md 保持薄提示（未泄漏工具包名）" || fail "INJECT.md 泄漏工具包名（应移入 SEARCH_RUNTIME.md）：$leak"
    fi
  fi

  # A25: SEARCH_RUNTIME 六通道齐备
  if [ -f "$D/SEARCH_RUNTIME.md" ]; then
    n=$(grep -cE '^### 通道 [1-6] ' "$D/SEARCH_RUNTIME.md" || echo 0)
    [ "$n" -ge 6 ] && pass "SEARCH_RUNTIME.md 含 $n 条通道" || fail "SEARCH_RUNTIME.md 通道数不足（$n/6）"
    # 双向引用：每条通道都要写「由哪个 skill 使用」
    m=$(grep -c '由哪个 skill 使用' "$D/SEARCH_RUNTIME.md" || echo 0)
    [ "$m" -ge 5 ] && pass "通道含 skill 引用说明（$m 处）" || fail "通道缺 skill 双向引用说明（$m 处，应 ≥5）"
  fi

  # A29: 四文件四要素（每要素给多个可接受表述，避免形式主义卡词）
  check4() {
    local f="$1"
    [ -f "$f" ] || { fail "缺失：$f"; return; }
    local miss=""
    # ① 定位：这是什么
    grep -qE '定位|是什么|做什么|What it is|本包是' "$f" || miss="$miss 定位"
    # ② 开发逻辑：怎么干活
    grep -qE '开发逻辑|怎么干活|先动脑子|工作逻辑|How we work|纪律' "$f" || miss="$miss 开发逻辑"
    # ③ 目的：为什么存在
    grep -qE '目的|为什么|为何|使命|Purpose|Why' "$f" || miss="$miss 目的"
    # ④ 效果：实现什么
    grep -qE '效果|实现|结果|交付|能做什么|Outcome' "$f" || miss="$miss 效果"
    [ -z "$miss" ] && pass "$f 含四要素" || fail "$f 四要素不全（缺:$miss）"
  }
  for f in README.md AGENTS.md CLAUDE.md "$D/MERGE_CONTRACT.md"; do check4 "$f"; done

  # A31: SKILL.md 耦合三件事
  if [ -f "$D/SKILL.md" ]; then
    grep -q '依赖的 MCP\|依赖哪些 MCP' "$D/SKILL.md" && grep -q '什么时候调' "$D/SKILL.md" && grep -q '怎么用' "$D/SKILL.md" \
      && pass "SKILL.md 声明耦合三件事" || fail "SKILL.md 缺耦合三件事（依赖哪个 MCP / 何时调 / 结果怎么用）"
  fi
fi

# ── 4. 隐私隔离 ──────────────────────────────────────────────
if want isolation; then
  qinfo "── 隐私隔离 ──"
  grep -q '^skills/qingnang/HOST_PROFILE.md' .gitignore 2>/dev/null \
    && pass "HOST_PROFILE.md 已在 .gitignore" || fail "HOST_PROFILE.md 未加入 .gitignore"
  grep -q '^\.env$' .gitignore 2>/dev/null \
    && pass ".env 已在 .gitignore" || fail ".env 未加入 .gitignore"
  grep -q 'private/' .gitignore 2>/dev/null \
    && pass "private/ 已在 .gitignore" || fail "private/ 未加入 .gitignore"
  # HOST_PROFILE 不得含真实凭据值（A34）
  if [ -f skills/qingnang/HOST_PROFILE.md ]; then
    if grep -nE '(API_KEY|TOKEN|SECRET)[[:space:]]*[:=][[:space:]]*[A-Za-z0-9_-]{8,}' skills/qingnang/HOST_PROFILE.md >/dev/null 2>&1; then
      fail "HOST_PROFILE.md 疑似含真实凭据值"
    else
      pass "HOST_PROFILE.md 无凭据值"
    fi
  fi
fi

# ── 5. 敏感信息闸配置 ────────────────────────────────────────
if want guard; then
  qinfo "── 敏感闸 ──"
  for f in .pre-commit-config.yaml .gitleaks.toml scripts/phi_scan.py .github/PULL_REQUEST_TEMPLATE.md; do
    [ -f "$f" ] && pass "存在：$f" || fail "缺失：$f"
  done
fi

# ── 6. 治理文档一致性 ────────────────────────────────────────
if want whitelist; then
  qinfo "── 治理一致性 ──"
  if cmp -s AGENTS.md CLAUDE.md; then pass "AGENTS.md ≡ CLAUDE.md"; else fail "AGENTS.md 与 CLAUDE.md 不一致（必须逐字相同）"; fi
  # forge 接缝 S1：零「DSH/Cordis 专属实现」（注意——宿主【类型探测】是允许的，那只是决定装到哪个目录）
  # 禁止的是：写 DSH 插件、读 DSH 的 StdioConfig、依赖 DSH 内部 service
  s1bad=0; s1hit=""
  for pat in 'dsh-plugin' 'StdioConfig' 'ctx.inject' '@deepseek-ai' 'desktopPnpm' 'desktopProfiles' 'dsh-community-fabric'; do
    n=$(grep -rn "$pat" --include='*.json' --include='*.sh' --include='*.py' . 2>/dev/null \
        | grep -v node_modules | grep -v '\.git/' | grep -v 'scripts/check.sh' | wc -l | tr -d ' ')
    [ "$n" != "0" ] && { s1bad=1; s1hit="$s1hit $pat($n)"; }
  done
  [ "$s1bad" = "0" ] && pass "forge 接缝 S1：无 DSH/Cordis 专属实现（0 命中）" \
    || fail "forge 接缝 S1 违约：发现 DSH 专属实现 →$s1hit"

  # 顺带：确认宿主探测存在（说明 --host 分派是真的实现了，不是空壳）
  if grep -q 'openclaw)' scripts/deploy.sh 2>/dev/null && grep -q 'claude)' scripts/deploy.sh 2>/dev/null; then
    pass "宿主分派已实现（claude / pi / openclaw / codex）"
  else
    fail "宿主分派疑似缺失"
  fi
fi

qinfo "════════════════════════════════"
if [ "$FAILED" = "1" ]; then qerr "自检未通过"; exit 1; fi
qok "自检全部通过"
exit 0
