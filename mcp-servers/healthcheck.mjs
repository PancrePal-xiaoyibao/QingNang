#!/usr/bin/env node
/**
 * 青囊 · MCP 通道健康检查（跨平台，纯 Node）
 *
 * 用法：
 *   node mcp-servers/healthcheck.mjs           # 详细输出
 *   node mcp-servers/healthcheck.mjs --quiet   # 只出退出码（供 doctor 调用）
 *
 * 契约：
 *   ✓ 可用     —— initialize 握手成功
 *   ⬜ 选填未配 —— credential_gate 通道缺凭据（**不算失败**，不影响 exit code）
 *   ❌ 失败     —— 其他原因（含许可证不在白名单）
 *
 * 退出码：有 ❌ → 1，否则 0
 */
import { spawn } from 'node:child_process'
import { readFileSync, existsSync } from 'node:fs'
import { join, dirname, resolve } from 'node:path'
import { fileURLToPath } from 'node:url'

const HERE = dirname(fileURLToPath(import.meta.url))
const REPO = resolve(HERE, '..')
const QUIET = process.argv.includes('--quiet')
const TTY = process.stdout.isTTY
const C = TTY ? { ok: '\x1b[32m', warn: '\x1b[33m', err: '\x1b[31m', rst: '\x1b[0m' } : { ok: '', warn: '', err: '', rst: '' }
const OK = '✓', OPT = '⬜', FAIL = '❌'

function loadEnvFile() {
  const f = join(REPO, '.env')
  if (!existsSync(f)) return {}
  const out = {}
  for (const line of readFileSync(f, 'utf8').split(/\r?\n/)) {
    if (/^\s*#/.test(line)) continue
    const m = line.match(/^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)\s*$/)
    if (!m) continue
    let v = m[2].trim().replace(/^["']|["']$/g, '')
    if (v) out[m[1]] = v
  }
  return out
}

/** 对一个 MCP 做 initialize 握手 */
function handshake(server, env) {
  return new Promise((resolve) => {
    const cmd = server.command || []
    if (!cmd.length) return resolve({ ok: false, why: 'manifest 未声明 command' })
    const [bin, ...args] = cmd
    // Windows 上 node 可能在 PATH 里是 node.exe；直接 spawn 即可，不需要 shell
    const child = spawn(bin, args, {
      cwd: REPO, env, stdio: ['pipe', 'pipe', 'ignore'], shell: false,
    })
    let out = ''
    let settled = false
    const done = (r) => { if (settled) return; settled = true; try { child.kill('SIGKILL') } catch {} ; resolve(r) }
    const timer = setTimeout(() => done({ ok: false, why: `initialize 超时（${server.health?.timeout_s || 30}s）` }),
      (server.health?.timeout_s || 30) * 1000)

    child.on('error', (e) => { clearTimeout(timer); done({ ok: false, why: `启动失败：${e.message}` }) })
    // 正确判定：逐行按 JSON-RPC 解析，找 id=1 且带 result 的响应。
    // ❌ 曾经的 bug：判定条件里写了 out.includes('initialize')，
    //    但 initialize 响应的 body 里并没有这个字符串（只有 serverInfo/capabilities），
    //    导致条件永不成立、只能等满 30 秒超时。
    child.stdout.on('data', (d) => {
      out += d.toString()
      for (const line of out.split(/\r?\n/)) {
        const t = line.trim()
        if (!t.startsWith('{')) continue
        try {
          const msg = JSON.parse(t)
          if (msg.id === 1 && msg.result) {
            clearTimeout(timer)
            const info = msg.result.serverInfo ? `"serverInfo":${JSON.stringify(msg.result.serverInfo)}` : ''
            done({ ok: true, info })
            return
          }
          if (msg.id === 1 && msg.error) {
            clearTimeout(timer)
            done({ ok: false, why: `服务返回错误：${msg.error.message || JSON.stringify(msg.error)}` })
            return
          }
        } catch { /* 半行 JSON，等下一块数据 */ }
      }
    })
    child.on('exit', (code) => {
      clearTimeout(timer)
      if (!settled) done({ ok: false, why: `进程退出（code=${code}）且未返回 initialize` })
    })

    try {
      child.stdin.write(JSON.stringify({
        jsonrpc: '2.0', id: 1, method: 'initialize',
        params: { protocolVersion: '2024-11-05', capabilities: {}, clientInfo: { name: 'qingnang-healthcheck', version: '0.1.0' } },
      }) + '\n')
    } catch (e) { clearTimeout(timer); done({ ok: false, why: `写入失败：${e.message}` }) }
  })
}

async function main() {
  const mf = join(HERE, 'manifest.json')
  if (!existsSync(mf)) { console.error(`${FAIL} 找不到 ${mf}`); process.exit(1) }
  const m = JSON.parse(readFileSync(mf, 'utf8'))
  const wl = new Set(m.license_whitelist || [])
  const fileEnv = loadEnvFile()

  const usable = [], gated = [], failed = []

  for (const s of m.servers || []) {
    const id = s.id
    // 许可白名单
    if (s.license && !wl.has(s.license)) { failed.push([id, `许可 ${s.license} 不在白名单`]); continue }

    // 凭据门：缺必需凭据 → 选填未配（不算失败）
    const required = (s.env || []).filter((e) => e.required).map((e) => e.key)
    const missing = required.filter((k) => !process.env[k] && !fileEnv[k])
    if (missing.length) {
      if (s.credential_gate) { gated.push([id, `未配凭据 ${missing.join(',')}（降级到 ${s.degrade_to || '无'}）`]); continue }
      failed.push([id, `缺必需凭据 ${missing.join(',')}`]); continue
    }

    // 只把「本通道声明的 env」+「进程环境」传下去，不把整个 .env 灌进去。
    // 理由：避免通道间凭据串门（A 通道不该看到 B 通道的 key）。
    const env = { ...process.env }
    for (const e of s.env || []) {
      const v = process.env[e.key] || fileEnv[e.key] || e.value
      if (v) env[e.key] = String(v)
    }

    const r = await handshake(s, env)
    if (r.ok) usable.push([id, r.info])
    else failed.push([id, r.why])
  }

  if (!QUIET) {
    console.log('青囊 · MCP 通道健康检查')
    console.log('─'.repeat(46))
    for (const [id, info] of usable) console.log(`  ${C.ok}${OK}${C.rst} ${id}${info ? ' ' + info : ''}`)
    for (const [id, why] of gated) console.log(`  ${C.warn}${OPT}${C.rst} ${id} — ${why}`)
    for (const [id, why] of failed) console.log(`  ${C.err}${FAIL}${C.rst} ${id} — ${why}`)
    console.log('─'.repeat(46))
    console.log(`可用 ${usable.length} / 选填未配 ${gated.length} / 共计 ${(m.servers || []).length}`)
    if (gated.length) {
      console.log('')
      console.log('选填未配的通道不影响使用：')
      for (const [id, why] of gated) console.log(`  · ${id}：${why}`)
      console.log('  · 需要时自行申请凭据，填入 .env 后重跑 doctor')
    }
    if (failed.length) {
      console.log('')
      console.log('修复提示：')
      for (const [id, why] of failed) console.log(`  · ${id}：${why}`)
      console.log('  · 环境未构建 → node scripts/qingnang.mjs fetch')
      console.log('  · 网络问题 → 参考 HOST_PROFILE.md 的「网络与代理」一节')
    }
  }

  process.exit(failed.length ? 1 : 0)
}

main().catch((e) => { console.error(e.stack || e.message); process.exit(1) })
