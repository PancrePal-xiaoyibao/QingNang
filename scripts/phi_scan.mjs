#!/usr/bin/env node
/**
 * 青囊 · 中文 PHI/PII 扫描（敏感信息第一道闸）
 *
 * 用途：在 commit 前拦截「真实患者信息」与「凭据」进入仓库。
 * 覆盖：身份证号、手机号、住院号/门诊号、姓名+诊断组合、报告单图片 EXIF、API Key。
 *
 * 设计取舍：
 *   · 宁可误报不可漏报 —— 医疗场景下漏一个真实患者信息的代价远大于多改一次
 *   · 每类命中都给出「为什么这算敏感 + 怎么改」的中文说明
 *   · 行级豁免： # phi-scan: ignore   （必须在 PR 里说明理由）
 *
 * 为什么是 Node 而不是 Python：
 *   青囊的整条工具链统一在 Node 上（MCP 本身就跑在 Node 上）。
 *   多一个 Python 依赖 = 多一道安装门槛。贡献者也罢、Agent 也罢，少装一样是一样。
 *
 * 退出码：0 干净；1 有命中
 * 用法： node scripts/phi_scan.mjs [--staged] [路径...]
 */
import { existsSync, readFileSync, readdirSync, statSync } from 'node:fs'
import { join, extname, basename, resolve } from 'node:path'
import { spawnSync } from 'node:child_process'

const TTY = process.stdout.isTTY
const C = TTY
  ? { err: '\x1b[31m', ok: '\x1b[32m', rst: '\x1b[0m' }
  : { err: '', ok: '', rst: '' }

// ── 扫描范围 ────────────────────────────────────────────────────
const SCAN_EXT = new Set([
  '.md', '.txt', '.json', '.yaml', '.yml', '.csv', '.sh', '.py', '.js', '.mjs',
  '.ts', '.tsx', '.env', '.example', '.toml', '.cfg', '.ini',
])
const SKIP_DIRS = new Set([
  '.git', 'node_modules', '.venv', 'venv', '__pycache__', '.pytest_cache',
  '.ruff_cache', 'dist', 'build', '.next', 'cache',
])
// 这些文件天然含示例/占位，跳过凭据类规则（但仍扫 PHI）
const PLACEHOLDER_FILES = new Set(['.env.example'])

const IGNORE_RE = /#\s*phi-scan:\s*ignore/i

// ── 规则：(名称, 正则, 说明) ─────────────────────────────────────
const RULES = [
  ['身份证号',
    /(?<!\d)[1-9]\d{5}(?:19|20)\d{2}(?:0[1-9]|1[0-2])(?:0[1-9]|[12]\d|3[01])\d{3}[\dXx](?!\d)/g,
    '中国大陆居民身份证号（18 位）。请删除；若为演示数据，用 data/synthetic/ 的造数脚本生成。'],

  ['手机号',
    /(?<!\d)1[3-9]\d{9}(?!\d)/g,
    '手机号。请删除或改为 138****0000 形式；演示数据走 data/synthetic/。'],

  ['住院号/门诊号/病历号',
    // 要求「编号主体含至少 4 位连续数字」——真实单据号必然含数字；
    // 这样可避免误伤文档里的描述性文字（如「住院号 fixture」「住院号字段」）
    /(住院号|门诊号|病历号|就诊号|病案号)\s*[:：]?\s*[A-Za-z-]{0,6}\d{4,}[A-Za-z0-9-]*/g,
    '医疗单据编号。真实编号可反查到具体患者与就诊记录，必须删除。'],

  ['姓名+诊断组合',
    /(患者|病人|姓名)\s*[:：]?\s*[\u4e00-\u9fa5]{2,4}\s*[,，、\s]\s*(诊断|分期|病理)/g,
    '姓名与诊断同时出现 = 可识别到个人。医疗信息属敏感个人信息（PIPL），必须删除。'],

  ['疑似住院时间+医院组合',
    /(?:\d{4}年\d{1,2}月|\d{4}-\d{2})[^\n]{0,20}(住院|入院|手术)[^\n]{0,30}(医院|医学中心|附属)/g,
    '时间 + 就诊行为 + 机构 = 三件套，可反推个人。请改为脱敏描述。'],

  ['API Key / Token / Secret',
    /(api[_-]?key|secret|token|passwd|password)\s*[:=]\s*['"]?[A-Za-z0-9_-]{16,}/g,
    '疑似凭据。凭据必须放 .env（已在 .gitignore 中），仓库内只允许 .env.example 里的空占位。'],

  ['私钥',
    /-----BEGIN [A-Z ]*PRIVATE KEY-----/g,
    '私钥文件内容。绝不可入库，立即删除并轮换该密钥。'],

  ['中国大陆银行卡号',
    /(?<!\d)(62\d{14,17})(?!\d)/g,
    '银行卡号。属敏感财务信息，必须删除。'],
]

// ── 图片 EXIF（报告单照片常带拍摄地点/设备信息）─────────────────
const IMG_EXT = new Set(['.jpg', '.jpeg', '.png', '.tif', '.tiff', '.heic', '.webp'])
const EXIF_HINT = /(GPS|Make|Model|Software|DateTime)/i

// ── 文件遍历 ────────────────────────────────────────────────────
function* iterFiles(paths, staged) {
  if (staged) {
    const r = spawnSync('git', ['diff', '--cached', '--name-only', '--diff-filter=ACMR'],
      { encoding: 'utf8' })
    for (const p of (r.stdout || '').split(/\r?\n/)) {
      const t = p.trim()
      if (t && existsSync(t) && statSync(t).isFile()) yield t
    }
    return
  }
  for (const path of paths) {
    if (existsSync(path) && statSync(path).isFile()) { yield path; continue }
    const stack = [path]
    while (stack.length) {
      const dir = stack.pop()
      if (!existsSync(dir)) continue
      for (const e of readdirSync(dir, { withFileTypes: true })) {
        if (e.isDirectory()) {
          if (!SKIP_DIRS.has(e.name)) stack.push(join(dir, e.name))
        } else {
          yield join(dir, e.name)
        }
      }
    }
  }
}

// ── 单文件扫描 ──────────────────────────────────────────────────
function scanFile(path) {
  const hits = []
  const ext = extname(path).toLowerCase()

  // 图片：查 EXIF 特征字节
  if (IMG_EXT.has(ext)) {
    try {
      const buf = readFileSync(path).subarray(0, 65536).toString('latin1')
      if (EXIF_HINT.test(buf)) {
        hits.push([0, '图片 EXIF', basename(path),
          '图片含 EXIF 元数据（可能含 GPS/设备/时间）。报告单照片请先剥离元数据再提交。'])
      }
    } catch { /* 读不了就跳过 */ }
    return hits
  }

  // 只扫白名单扩展名；无扩展名也扫（可能是 .env 之类）
  if (ext && !SCAN_EXT.has(ext)) return hits

  let lines
  try {
    lines = readFileSync(path, 'utf8').split(/\r?\n/)
  } catch {
    return hits
  }

  const isPlaceholderFile = PLACEHOLDER_FILES.has(basename(path))

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i]
    if (IGNORE_RE.test(line)) continue
    for (const [name, rx, why] of RULES) {
      // .env.example 允许出现 KEY 名的空占位（= 后面无值）
      if (isPlaceholderFile && name === 'API Key / Token / Secret') continue
      rx.lastIndex = 0
      const m = rx.exec(line)
      if (m) hits.push([i + 1, name, m[0].slice(0, 80), why])
    }
  }
  return hits
}

// ── 主流程 ──────────────────────────────────────────────────────
function main() {
  const argv = process.argv.slice(2)
  const staged = argv.includes('--staged')
  const paths = argv.filter((a) => !a.startsWith('--'))
  const targets = paths.length ? paths : ['.']

  let total = 0
  let filesWithHits = 0

  for (const path of [...new Set(iterFiles(targets, staged))].sort()) {
    const hits = scanFile(path)
    if (!hits.length) continue
    filesWithHits++
    console.log(`\n${C.err}✗ ${path}${C.rst}`)
    for (const [ln, name, frag, why] of hits) {
      total++
      console.log(`  ${ln ? `第 ${ln} 行` : '文件级'} · ${name}`)
      console.log(`    命中: ${frag}`)
      console.log(`    为什么: ${why}`)
      console.log('    怎么改: 删除该内容；若为误报，加 `# phi-scan: ignore` 并在 PR 说明理由')
    }
  }

  console.log('')
  if (total) {
    console.log(`${C.err}拦截：发现 ${total} 处疑似敏感信息（${filesWithHits} 个文件）。${C.rst}`)
    console.log('医疗信息属敏感个人信息（PIPL）。请按上方提示修改后再提交。')
    return 1
  }
  console.log(`${C.ok}✓ 未发现敏感信息。${C.rst}`)
  return 0
}

process.exit(main())
