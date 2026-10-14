#!/usr/bin/env bash
# 青囊宿主机探测 — 输出单行 JSON 到 stdout
# 移植自 dev-host-init/scripts/host-scan.sh，裁剪掉 SSH/FRP/nginx 等运维项（青囊用户不需要）
# 原则：每个探测项静默降级为 null/false/[]，绝不报错退出

set -uo pipefail

json_str()     { printf '"%s"' "${1:-}"; }
json_opt_str() { if [ -n "${1:-}" ]; then printf '"%s"' "$1"; else printf 'null'; fi; }

OS_NAME="$(uname -s 2>/dev/null || echo Unknown)"
IS_MAC=0; [ "$OS_NAME" = "Darwin" ] && IS_MAC=1

echo '{'

# ── OS & shell ────────────────────────────────────────────────
echo '  "os": {'
printf '    "name": ';    json_str "$OS_NAME"; echo ','
printf '    "version": '; json_str "$(uname -r 2>/dev/null || echo Unknown)"; echo ','
printf '    "arch": ';    json_str "$(uname -m 2>/dev/null || echo Unknown)"
echo '  },'
printf '  "shell": '; json_opt_str "${SHELL:-}"; echo ','

# ── 硬件 ──────────────────────────────────────────────────────
echo '  "hardware": {'
if [ "$IS_MAC" = "1" ]; then
  CPU_MODEL="$(sysctl -n machdep.cpu.brand_string 2>/dev/null || true)"
  [ -z "$CPU_MODEL" ] && CPU_MODEL="$(sysctl -n hw.model 2>/dev/null || true)"
  CPU_CORES="$(sysctl -n hw.ncpu 2>/dev/null || echo 0)"
  MEM_GB=$(( $(sysctl -n hw.memsize 2>/dev/null || echo 0) / 1073741824 ))
else
  CPU_MODEL="$(lscpu 2>/dev/null | awk -F': +' '/^Model name|^型号名称/{print $2; exit}')"
  [ -z "$CPU_MODEL" ] && CPU_MODEL="$(awk -F': ' '/^model name/{print $2; exit}' /proc/cpuinfo 2>/dev/null || true)"
  CPU_CORES="$(nproc 2>/dev/null || getconf _NPROCESSORS_ONLN 2>/dev/null || echo 0)"
  MEM_GB=$(( $(awk '/^MemTotal/{print $2}' /proc/meminfo 2>/dev/null || echo 0) / 1048576 ))
fi
printf '    "cpu_model": '; json_opt_str "$CPU_MODEL"; echo ','
printf '    "cpu_cores": %s,\n' "${CPU_CORES:-0}"
printf '    "memory_gb": %s,\n' "${MEM_GB:-0}"
# GPU（青囊不强制 GPU；仅记录，供未来 Phase 3 本地解析参考）
printf '    "gpu": '
if command -v nvidia-smi >/dev/null 2>&1; then
  json_opt_str "$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -1)"
elif command -v rocm-smi >/dev/null 2>&1; then
  printf '"amd"'
elif [ "$IS_MAC" = "1" ] && printf '%s' "$CPU_MODEL" | grep -q '^Apple'; then
  printf '"apple"'
else
  printf 'null'
fi
echo ','
# 磁盘（取 / 或 $HOME 所在挂载点，最多 3 个）
printf '    "disks": ['
DF_OUT="$(df -l -k 2>/dev/null | awk 'NR>1 && $1 !~ /^(tmpfs|devfs|devtmpfs|map|overlay|squashfs|proc|sysfs|cgroup|udev)/ && $6 !~ /^\/(dev|proc|sys|run)(\/|$)/ {print $6" "$2" "$4}' | head -3 || true)"
FIRST=1
while read -r mnt total avail; do
  [ -z "${mnt:-}" ] && continue
  [ $FIRST -eq 1 ] || printf ','
  FIRST=0
  printf '{"mount":'; json_str "$mnt"; printf ',"total_gb":%s,"free_gb":%s}' "$((total/1048576))" "$((avail/1048576))"
done <<< "$DF_OUT"
echo ']'
echo '  },'

# ── 运行时 ────────────────────────────────────────────────────
echo '  "runtimes": {'
printf '    "node": ';   command -v node   >/dev/null 2>&1 && json_str "$(node --version 2>/dev/null | tr -d v)" || printf 'null'; echo ','
printf '    "npx": ';    command -v npx    >/dev/null 2>&1 && printf 'true' || printf 'false'; echo ','
if command -v python3 >/dev/null 2>&1; then
  printf '    "python": '; json_str "$(python3 --version 2>/dev/null | awk '{print $2}')"
elif command -v python >/dev/null 2>&1; then
  printf '    "python": '; json_str "$(python --version 2>/dev/null | awk '{print $2}')"
else
  printf '    "python": null'
fi
echo ','
printf '    "npm": ';    command -v npm   >/dev/null 2>&1 && json_str "$(npm --version 2>/dev/null)" || printf 'null'; echo ','
printf '    "git": ';    command -v git   >/dev/null 2>&1 && json_str "$(git --version 2>/dev/null | awk '{print $3}')" || printf 'null'
echo '  },'

# ── 网络与代理（青囊第一道门槛）──────────────────────────────
echo '  "proxy": {'
printf '    "env_http": ';  json_opt_str "${http_proxy:-${HTTP_PROXY:-}}";  echo ','
printf '    "env_https": '; json_opt_str "${https_proxy:-${HTTPS_PROXY:-}}"; echo ','
printf '    "env_all": ';   json_opt_str "${all_proxy:-${ALL_PROXY:-}}";   echo ','
printf '    "open_local_ports": ['
FIRST=1
for port in 1080 7890 7897 8118 10808 8888; do
  if timeout 1 bash -c "echo > /dev/tcp/127.0.0.1/$port" 2>/dev/null; then
    [ $FIRST -eq 1 ] || printf ','
    FIRST=0; printf '"%s"' "$port"
  fi
done
echo '],'
# 从探测到的端口推断一个最可能的代理地址
SUGGEST=""
for port in 7890 7897 1080 8888 8118; do
  case ",$(printf '%s' "$(for p in 1080 7890 7897 8118 10808 8888; do timeout 1 bash -c "echo > /dev/tcp/127.0.0.1/$p" 2>/dev/null && printf '%s,' "$p"; done)")," in
    *",$port,"*) SUGGEST="http://127.0.0.1:$port"; break ;;
  esac
done
[ -n "$SUGGEST" ] || SUGGEST="$(printf '%s' "${http_proxy:-${HTTP_PROXY:-}}")"
printf '    "suggested_url": '; json_opt_str "$SUGGEST"
echo '  },'

# ── 环境构建器探测（降级链需要）──────────────────────────────
echo '  "builders": {'
# 注意：包管理器 --version 可能因 corepack 版本切换而挂起，必须加超时
_v() { timeout 10 "$1" --version 2>/dev/null | tr -d '\r' | head -1; }
printf '    "pnpm": '; { command -v pnpm >/dev/null 2>&1 && [ -n "$(_v pnpm)" ]; } && json_str "$(_v pnpm)" || printf 'null'; echo ','
printf '    "yarn": '; { command -v yarn >/dev/null 2>&1 && [ -n "$(_v yarn)" ]; } && json_str "$(_v yarn)" || printf 'null'; echo ','
printf '    "uv": ';   command -v uv   >/dev/null 2>&1 && json_str "$(uv --version 2>/dev/null | awk '{print $2}')" || printf 'null'; echo ','
printf '    "venv": '; { command -v python3 >/dev/null 2>&1 || command -v python >/dev/null 2>&1; } && printf 'true' || printf 'false'; echo ','
printf '    "conda": '; command -v conda >/dev/null 2>&1 && json_str "$(conda --version 2>/dev/null | awk '{print $2}')" || printf 'null'
echo '  },'

# ── 宿主探测（决定注入落点）──────────────────────────────────
echo '  "hosts": {'
printf '    "claude_code": '; [ -d "$HOME/.claude" ] && printf 'true' || printf 'false'; echo ','
printf '    "pi": ';          [ -d "$HOME/.pi" ]     && printf 'true' || printf 'false'; echo ','
printf '    "codex": ';       [ -d "$HOME/.codex" ]  && printf 'true' || printf 'false'; echo ','
printf '    "openclaw": ';    { [ -d "$HOME/.openclaw" ] || [ -d "$PWD/config/openclaw" ]; } && printf 'true' || printf 'false'
echo '  },'

# ── npm registry 可达性 ───────────────────────────────────────
printf '  "npm_registry_reachable": '
if command -v npm >/dev/null 2>&1; then
  if timeout 15 npm view unified-trial-mcp version >/dev/null 2>&1; then printf 'true'; else printf 'false'; fi
else
  printf 'null'
fi
echo ','

printf '  "probed_at": '; json_str "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo '}'
