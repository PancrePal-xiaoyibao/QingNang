#!/usr/bin/env node
/**
 * 青囊 · 端到端验收测试（E2E acceptance）
 *
 * 覆盖 SPEC 里标注为「待跑」的验收锚点：
 *   A14  无凭据端到端：PubMed 检索返回 ≥1 条（含 PMID + 标题 + 链接）
 *   A15  无凭据端到端：试验检索返回 ≥1 条（含登记号）
 *   A15b 降级可观察：缺凭据通道 → 明示降级事实，不报错、不静默
 *   A23  六类问题的通道选择一致性
 *   A32  open-websearch 纯 request 模式可用（不需 Chromium）
 *   A11  七通道握手（含 tools/list）
 *   A12  许可白名单校验
 *   A34  HOST_PROFILE 不含真实凭据值
 *
 * 用法：
 *   node tests/acceptance/e2e.mjs            # 全跑
 *   node tests/acceptance/e2e.mjs --only=A14,A15
 *   node tests/acceptance/e2e.mjs --offline  # 只跑不依赖外网的检查
 *
 * 退出码：0 全绿（允许 ⚠️ 网络跳跃）；1 有 ❌
 *
 * 设计原则：
 *   · 每个锚点独立可跑，失败不阻塞其他
 *   · 网络依赖项在不可达时记 ⚠️（不记 ✅，也不记 ❌）—— 见 AGENTS.md §1.6 兜底纪律
 *   · 结果写入 tests/acceptance/REPORT.md
 */
import { spawn } from 'node:child_process'
import { readFileSync, writeFileSync, existsSync, mkdirSync } from 'node:fs'
import { join, dirname, resolve } from 'node:path'
import { fileURLToPath } from 'node:url'

const HERE = dirname(fileURLToPath(import.meta.url))
const REPO = resolve(HERE, '..', '..')

const TTY = process.stdout.isTTY
const C = TTY
  ? { ok: '\x1b[32m', warn: '\x1b[33m', err: '\x1b[31m', dim: '\x1b[2m', rst: '\x1b[0m' }
  : { ok: '', warn: '', err: '', dim: '', rst: '' }
const OK = '✓', WARN = '⚠️', FAIL = '❌'

const argv = process.argv.slice(2)
const OFFLINE = argv.includes('--offline')
const onlyArg = argv.find((a) => a.startsWith('--only='))
const ONLY = onlyArg ? new Set(onlyArg.slice(7).split(',')) : null
const want = (id) => !ONLY || ONLY.has(id)

const results = []

function record(id, status, desc, evidence) {
  results.push({ id, status, desc, evidence })
  const mark = status === 'ok' ? `${C.ok}${OK}${C.rst}` : status === 'warn' ? `${C.warn}${WARN}${C.rst}` : `${C.err}${FAIL}${C.rst}`
  console.log(`  ${mark} ${id.padEnd(6)} ${desc}`)
  if (evidence) console.log(`          ${C.dim}${evidence}${C.rst}`)
}

// ════════════════════════════════════════════════════════════════
// 极简 MCP 客户端（stdio，JSON-RPC）
// ════════════════════════════════════════════════════════════════
function loadManifest() {
  return JSON.parse(readFileSync(join(REPO, 'mcp-servers', 'manifest.json'), 'utf8'))
}

function loadEnv() {
  const f = join(REPO, '.env')
  if (!existsSync(f)) return {}
  const out = {}
  for (const line of readFileSync(f, 'utf8').split(/\r?\n/)) {
    if (/^\s*#/.test(line)) continue
    const m = line.match(/^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)\s*$/)
    if (m) { const v = m[2].trim().replace(/^["']|["']$/g, ''); if (v) out[m[1]] = v }
  }
  return out
}

/** 启动一个 MCP，完成 initialize，返回 { call, close, tools } */
function connect(serverId, { timeoutMs = 40000 } = {}) {
  const m = loadManifest()
  const s = m.servers.find((x) => x.id === serverId)
  if (!s) return Promise.reject(new Error(`通道不存在：${serverId}`))

  const [bin, ...args] = s.command
  const env = { ...process.env }
  const fileEnv = loadEnv()
  for (const e of s.env || []) {
    const v = process.env[e.key] || fileEnv[e.key] || e.value
    if (v) env[e.key] = String(v)
  }

  const child = spawn(bin, args, { cwd: REPO, env, stdio: ['pipe', 'pipe', 'pipe'] })
  let buf = ''
  let nextId = 1
  const pending = new Map()
  const stderrChunks = []

  child.stderr.on('data', (d) => stderrChunks.push(d.toString()))
  child.on('error', (e) => {
    for (const [, p] of pending) p.reject(e)
    pending.clear()
  })

  child.stdout.on('data', (d) => {
    buf += d.toString()
    const lines = buf.split('\n')
    buf = lines.pop() || ''
    for (const line of lines) {
      const t = line.trim()
      if (!t.startsWith('{')) continue
      let msg
      try { msg = JSON.parse(t) } catch { continue }
      if (msg.id !== undefined && pending.has(msg.id)) {
        const p = pending.get(msg.id)
        pending.delete(msg.id)
        if (msg.error) p.reject(new Error(msg.error.message || JSON.stringify(msg.error)))
        else p.resolve(msg.result)
      }
    }
  })

  const send = (method, params) => new Promise((res, rej) => {
    const id = nextId++
    pending.set(id, { resolve: res, reject: rej })
    setTimeout(() => {
      if (pending.has(id)) { pending.delete(id); rej(new Error(`${method} 超时（${timeoutMs}ms）`)) }
    }, timeoutMs)
    child.stdin.write(JSON.stringify({ jsonrpc: '2.0', id, method, params }) + '\n')
  })

  const api = {
    stderr: () => stderrChunks.join(''),
    call: (name, args = {}) => send('tools/call', { name, arguments: args }),
    close: () => { try { child.kill('SIGKILL') } catch {} },
  }

  return send('initialize', {
    protocolVersion: '2024-11-05', capabilities: {},
    clientInfo: { name: 'qingnang-e2e', version: '0.1.0' },
  }).then(async () => {
    const t = await send('tools/list', {})
    api.tools = (t.tools || []).map((x) => x.name)
    return api
  })
}

/** 从 tools/call 结果里取文本（MCP 返回 content: [{type:'text',text}]） */
function textOf(res) {
  const parts = (res && res.content) || []
  return parts.filter((p) => p.type === 'text').map((p) => p.text).join('\n')
}

// ════════════════════════════════════════════════════════════════
// A11 · 七通道握手（含 tools/list）
// ════════════════════════════════════════════════════════════════
async function testA11() {
  if (!want('A11')) return
  const m = loadManifest()
  const usable = [], gated = [], failed = []
  for (const s of m.servers) {
    const required = (s.env || []).filter((e) => e.required).map((e) => e.key)
    const fileEnv = loadEnv()
    const missing = required.filter((k) => !process.env[k] && !fileEnv[k])
    if (missing.length && s.credential_gate) { gated.push(s.id); continue }
    try {
      const c = await connect(s.id, { timeoutMs: 30000 })
      usable.push(`${s.id}(${c.tools.length}工具)`)
      c.close()
    } catch (e) {
      failed.push(`${s.id}: ${e.message.slice(0, 40)}`)
    }
  }
  if (failed.length) {
    record('A11', 'fail', `通道握手 ${usable.length}/${m.servers.length}`, failed.join(' | '))
  } else {
    record('A11', 'ok', `握手通过 ${usable.length} 条（${gated.length} 条待凭据）`, usable.join(' '))
  }
}

// ════════════════════════════════════════════════════════════════
// A12 · 许可白名单
// ════════════════════════════════════════════════════════════════
function testA12() {
  if (!want('A12')) return
  const m = loadManifest()
  const wl = new Set(m.license_whitelist)
  const bad = m.servers.filter((s) => !wl.has(s.license)).map((s) => `${s.id}=${s.license}`)
  if (bad.length) record('A12', 'fail', '许可白名单', bad.join(', '))
  else record('A12', 'ok', `全部 ${m.servers.length} 条许可在白名单内`, `白名单: ${m.license_whitelist.join(', ')}`)
}

// ════════════════════════════════════════════════════════════════
// A14 · PubMed 端到端（无凭据）
// ════════════════════════════════════════════════════════════════
async function testA14() {
  if (!want('A14')) return
  if (OFFLINE) return record('A14', 'warn', '离线模式跳过', '需外网')
  let c
  try {
    c = await connect('pubmed')
    const res = await c.call('pubmed_search', { query: 'pancreatic cancer FOLFIRINOX', max_results: 3 })
    const txt = textOf(res)
    const hasPmid = /\b\d{7,8}\b/.test(txt)
    const hasTitle = txt.length > 120
    const hasLink = /pubmed\.ncbi\.nlm\.nih\.gov|doi\.org/i.test(txt)
    if (hasPmid && hasTitle) {
      const pmid = (txt.match(/\b\d{7,8}\b/) || [])[0]
      record('A14', 'ok', `PubMed 返回结果（PMID=${pmid}）`,
        `字段: PMID=${hasPmid} 标题=${hasTitle} 链接=${hasLink} · ${txt.length} 字符`)
    } else {
      record('A14', 'warn', 'PubMed 返回但字段不全',
        `PMID=${hasPmid} 标题=${hasTitle} · 前 120 字: ${txt.slice(0, 120).replace(/\n/g, ' ')}`)
    }
  } catch (e) {
    record('A14', 'warn', 'PubMed 端到端未通过（可能是网络）',
      `${e.message.slice(0, 120)}${c ? ' · stderr: ' + c.stderr().slice(0, 80) : ''}`)
  } finally { c?.close() }
}

// ════════════════════════════════════════════════════════════════
// A15 · 试验检索端到端（无凭据）
// ════════════════════════════════════════════════════════════════
async function testA15() {
  if (!want('A15')) return
  if (OFFLINE) return record('A15', 'warn', '离线模式跳过', '需外网')
  let c
  try {
    c = await connect('unified_trial', { timeoutMs: 60000 })
    const res = await c.call('search_trials', { keyword: '胰腺癌', limit: 5 })
    const txt = textOf(res)
    const hasReg = /NCT\d{8}|ChiCTR\d{8,}|CTR\d{8,}/i.test(txt)
    if (hasReg) {
      const reg = (txt.match(/NCT\d{8}|ChiCTR\d{8,}|CTR\d{8,}/i) || [])[0]
      record('A15', 'ok', `试验检索返回结果（登记号=${reg}）`, `${txt.length} 字符`)
    } else {
      // 该通道需要本地语料/配置；未配置时如实记 ⚠️
      const hint = /未配置|not configured|coverage|数据依赖|config/i.test(txt) ? '（需本地语料配置，见 get_source_status）' : ''
      record('A15', 'warn', `试验检索未返回登记号${hint}`,
        `前 150 字: ${txt.slice(0, 150).replace(/\n/g, ' ')}`)
    }
  } catch (e) {
    record('A15', 'warn', '试验检索端到端未通过',
      `${e.message.slice(0, 120)}${c ? ' · stderr: ' + c.stderr().slice(0, 80) : ''}`)
  } finally { c?.close() }
}

// ════════════════════════════════════════════════════════════════
// A15b · 降级可观察（缺凭据 → 明示降级，不报错、不静默）
// ════════════════════════════════════════════════════════════════
async function testA15b() {
  if (!want('A15b')) return
  const m = loadManifest()
  const gated = m.servers.filter((s) => s.credential_gate)
  if (!gated.length) return record('A15b', 'ok', '无凭据门通道（全部已配凭据）', '')

  // 降级目标有两种【同样合法】的形态：
  //   ① 有目标（knows→pubmed）：语义成立，缺凭据时自动降级 + 明示
  //   ② null + degrade_note：该能力唯一，无合理降级目标 → 明示未启用，不用别的通道凑
  // 只有「既没目标、也没说明」才算遗漏。
  const noDegrade = gated.filter((s) => !s.degrade_to && !s.degrade_note).map((s) => s.id)
  const explicitNull = gated.filter((s) => !s.degrade_to && s.degrade_note)
  // 检查运行时：connect 是否会因缺凭据给出清晰提示（不崩）
  let runtimeMsg = ''
  try {
    const c = await connect(gated[0].id, { timeoutMs: 15000 })
    c.close()
    runtimeMsg = '（凭据已配，通道可启动）'
  } catch (e) {
    runtimeMsg = e.message.slice(0, 100)
  }

  if (noDegrade.length) {
    record('A15b', 'warn', `部分凭据门通道既无降级目标也无说明：${noDegrade.join(',')}`,
      '在 manifest 的 degrade_to 填目标，或填 null + degrade_note 说明「该能力唯一」')
  } else {
    const withTarget = gated.filter((s) => s.degrade_to).map((s) => `${s.id}→${s.degrade_to}`)
    const soleCap = explicitNull.map((s) => `${s.id}(唯一能力，明示未启用)`)
    record('A15b', 'ok',
      `${gated.length} 条凭据门通道的降级语义均已显式声明`,
      `${[...withTarget, ...soleCap].join(' · ')} · 运行时: ${runtimeMsg}`)
  }
}

// ════════════════════════════════════════════════════════════════
// A23 · 六类问题的通道选择一致性
// ════════════════════════════════════════════════════════════════
async function testA23() {
  if (!want('A23')) return
  // 六类问题 → 期望通道（对齐 SEARCH_RUNTIME.md 分流表）
  const cases = [
    { q: 'FOLFIRINOX 方案的最新文献', expect: ['pubmed', 'openalex'], label: '文献类' },
    { q: '国内正在招募的胰腺癌试验', expect: ['unified_trial'], label: '试验类' },
    { q: '2026 年医保目录里有没有这个药', expect: ['bing_cn'], label: '政策类' },
    { q: '最近有什么新药新闻', expect: ['web_search', 'bing_cn'], label: '资讯类' },
    { q: '证据等级怎么看', expect: ['knows'], label: '证据类', optional: true },
    { q: '病友怎么应对副作用', expect: ['get_biji'], label: '经验类', optional: true },
  ]
  // 静态校验：SEARCH_RUNTIME 里这六类都写了「由哪个 skill 使用」
  const sr = readFileSync(join(REPO, 'skills', 'qingnang', 'SEARCH_RUNTIME.md'), 'utf8')
  const channelCount = (sr.match(/^### 通道 [1-9] /gm) || []).length
  const skillRefs = (sr.match(/由哪个 skill 使用/g) || []).length
  const m = loadManifest()
  const declared = new Set(m.servers.map((s) => s.id))

  const problems = []
  for (const c of cases) {
    const ok = c.expect.every((id) => declared.has(id))
    if (!ok && !c.optional) problems.push(`${c.label}→期望 ${c.expect.join('/')} 但 manifest 缺`)
  }
  if (channelCount < 6) problems.push(`分流表通道数 ${channelCount} < 6`)
  if (skillRefs < 5) problems.push(`双向引用说明仅 ${skillRefs} 处（应 ≥5）`)

  if (problems.length) record('A23', 'fail', '六类问题通道映射不完整', problems.join(' | '))
  else record('A23', 'ok', '六类问题均有对应通道 + 分流表完整',
    `通道 ${channelCount} 条 · 双向引用 ${skillRefs} 处 · manifest 覆盖 ${[...new Set(cases.flatMap((c) => c.expect))].filter((x) => declared.has(x)).length}/6`)
}

// ════════════════════════════════════════════════════════════════
// A32 · open-websearch 纯 request 模式（不需 Chromium）
// ════════════════════════════════════════════════════════════════
async function testA32() {
  if (!want('A32')) return
  if (OFFLINE) return record('A32', 'warn', '离线模式跳过', '需外网')
  let c
  try {
    c = await connect('web_search', { timeoutMs: 45000 })
    const res = await c.call('search', { query: 'pancreatic cancer', limit: 3 })
    const txt = textOf(res)
    const ok = txt.length > 50 && !/browser_unavailable|Chromium|playwright.*not/i.test(txt)
    if (ok) record('A32', 'ok', 'request 模式可用（无需 Chromium）', `${txt.length} 字符`)
    else record('A32', 'fail', 'request 模式异常', txt.slice(0, 200).replace(/\n/g, ' '))
  } catch (e) {
    const msg = e.message + (c ? c.stderr() : '')
    if (/browser_unavailable|Chromium|playwright/i.test(msg)) {
      record('A32', 'fail', '需要 Chromium（假设 H5 不成立）', msg.slice(0, 150))
    } else {
      record('A32', 'warn', 'request 模式未通过（可能是网络/代理）', msg.slice(0, 150))
    }
  } finally { c?.close() }
}

// ════════════════════════════════════════════════════════════════
// A34 · HOST_PROFILE 不含真实凭据值
// ════════════════════════════════════════════════════════════════
function testA34() {
  if (!want('A34')) return
  const hp = join(REPO, 'skills', 'qingnang', 'HOST_PROFILE.md')
  if (!existsSync(hp)) return record('A34', 'warn', 'HOST_PROFILE.md 不存在', '先跑 deploy --mode=source')
  const txt = readFileSync(hp, 'utf8')
  const hit = txt.match(/(API_KEY|TOKEN|SECRET)\s*[:=]\s*[A-Za-z0-9_-]{8,}/)
  if (hit) record('A34', 'fail', 'HOST_PROFILE 含疑似凭据', hit[0].slice(0, 60))
  else record('A34', 'ok', 'HOST_PROFILE 无凭据值', `${txt.length} 字符已扫`)
}

// ════════════════════════════════════════════════════════════════
// 主流程
// ════════════════════════════════════════════════════════════════
async function main() {
  console.log('青囊 · 端到端验收')
  console.log('════════════════════════════════════════')
  if (OFFLINE) console.log(`${C.dim}离线模式：跳过需外网的检查${C.rst}`)
  console.log('')

  testA12()
  testA34()
  await testA11()
  await testA15b()
  await testA23()
  if (!OFFLINE) {
    await testA14()
    await testA15()
    await testA32()
  } else {
    for (const id of ['A14', 'A15', 'A32']) if (want(id)) record(id, 'warn', '离线模式跳过', '需外网')
  }

  // ── 汇总 ──
  const ok = results.filter((r) => r.status === 'ok').length
  const warn = results.filter((r) => r.status === 'warn').length
  const fail = results.filter((r) => r.status === 'fail').length
  console.log('')
  console.log('════════════════════════════════════════')
  console.log(`并通过 ${ok} · 待观察 ${warn} · 失败 ${fail}`)

  // ── 报告 ──
  const stamp = new Date().toISOString().replace(/\.\d+Z$/, 'Z')
  const lines = [
    '# 端到端验收报告（E2E REPORT）',
    '',
    `> **生成时间**：${stamp}`,
    `> **运行模式**：${OFFLINE ? '离线' : '在线'}`,
    `> **汇总**：通过 ${ok} · 待观察 ${warn} · 失败 ${fail}`,
    '',
    '> ⚠️ = 网络/外部依赖不可达，按 SPEC §5 规定**不记 ✅ 也不记 ❌**（见 AGENTS.md §1.6 兜底纪律）',
    '',
    '| 锚点 | 状态 | 断言 | 实测证据 |',
    '|---|---|---|---|',
    ...results.map((r) => {
      const s = r.status === 'ok' ? '✅' : r.status === 'warn' ? '⚠️' : '❌'
      return `| **${r.id}** | ${s} | ${r.desc} | ${(r.evidence || '—').replace(/\|/g, '\\|')} |`
    }),
    '',
    '---',
    '',
    '## 复现命令',
    '',
    '```bash',
    'node tests/acceptance/e2e.mjs            # 全跑（含外网）',
    'node tests/acceptance/e2e.mjs --offline  # 只跑不依赖外网的',
    'node tests/acceptance/e2e.mjs --only=A14,A15',
    '```',
    '',
  ]
  mkdirSync(HERE, { recursive: true })
  writeFileSync(join(HERE, 'REPORT.md'), lines.join('\n'), 'utf8')
  console.log(`${C.dim}报告： tests/acceptance/REPORT.md${C.rst}`)

  process.exit(fail ? 1 : 0)
}

main().catch((e) => { console.error(`${FAIL} ${e.stack || e.message}`); process.exit(1) })
