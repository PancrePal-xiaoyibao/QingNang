#!/usr/bin/env node
/**
 * 把社区医学 skill 原样 clone 进 skills/ 下，并给每个加一份 QINGNANG.md 适配说明。
 *
 * 为什么这么做（ADR-011）：社区 skill 本身有 SKILL.md + 可执行脚本，是**能力**。
 * 拍平成 references/ 会丢掉可执行性。所以原样引入 + 加适配层。
 *
 * 用法：node scripts/vendor-skills.mjs [--src=/tmp/qn-repos] [--dry-run]
 */
import { cp, mkdir, readdir, rm, stat, writeFile, readFile, access } from 'node:fs/promises';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { existsSync } from 'node:fs';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const args = Object.fromEntries(process.argv.slice(2).map(a => {
  const m = a.match(/^--([^=]+)(?:=(.*))?$/); return m ? [m[1], m[2] ?? true] : [a, true];
}));
const SRC = args.src || '/tmp/qn-repos';
const DRY = !!args['dry-run'];

/** 许可证干净、允许 vendor 的清单。许可缺失的一律不进（许可债）。 */
const VENDORED = [
  { repo: 'clinicaltrials-query-analysis', org: 'opencare-skillhub', license: 'Apache-2.0', cat: '临床试验' },
  { repo: 'chictr-trials-collector',       org: 'opencare-skillhub', license: 'Apache-2.0', cat: '临床试验' },
  { repo: 'clinicaltrials-intel-skill',    org: 'opencare-skillhub', license: 'Apache-2.0', cat: '临床试验' },
  { repo: 'nccn-guideline-downloader',     org: 'opencare-skillhub', license: 'Apache-2.0', cat: '临床指南' },
  { repo: 'RAG-content-processor',         org: 'opencare-skillhub', license: 'Apache-2.0', cat: '知识生产' },
  { repo: 'aura_health_profile',           org: 'opencare-skillhub', license: 'MIT-0',      cat: '健康管理' },
  { repo: 'getnote-openclaw',              org: 'opencare-skillhub', license: 'MIT',        cat: '笔记' },
  { repo: 'xyb_dicom_download_skills',     org: 'opencare-skillhub', license: 'Apache-2.0', cat: '影像' },
  { repo: 'medical-desensitization',       org: 'PancrePal-xiaoyibao', license: 'Apache-2.0', cat: '病历隐私' },
  { repo: 'maskdesk',                      org: 'PancrePal-xiaoyibao', license: 'Apache-2.0', cat: '病历隐私' },
  { repo: 'PDAC-multi-agents-prompts',     org: 'PancrePal-xiaoyibao', license: 'Apache-2.0', cat: '提示词资产' },
];

/** 不带进包的东西：版本控制、依赖、产物、凭据、缓存 */
const EXCLUDE = [
  '.git', 'node_modules', '.venv', 'venv', '__pycache__', '.pytest_cache',
  'dist', 'build', '.next', 'target', 'outputs', 'cache', '.cache',
  '.DS_Store', 'dev.log', '*.pyc',
];

async function copyTree(from, to) {
  await cp(from, to, {
    recursive: true, force: true,
    filter: (src) => {
      const base = src.split('/').pop();
      if (EXCLUDE.includes(base)) return false;
      if (base.startsWith('.env')) return false;          // 凭据/模板一律不进（模板单独处理）
      if (/\.(pyc|log|tmp|bak|orig)$/.test(base)) return false;
      return true;
    },
  });
}

async function dirSize(p) {
  let n = 0;
  for (const e of await readdir(p, { withFileTypes: true })) {
    const f = join(p, e.name);
    if (e.isDirectory()) n += await dirSize(f);
    else n += (await stat(f)).size;
  }
  return n;
}

const HUMAN = (b) => b < 1024 ? `${b}B` : b < 1048576 ? `${(b / 1024).toFixed(0)}K` : `${(b / 1048576).toFixed(1)}M`;

/** 生成适配说明：证青囊的医学红线在借用来的 skill 上同样生效 */
function adapter({ repo, org, license, cat }) {
  return `# 青囊适配层 · ${repo}

> 本目录是**社区原版 skill**，由青囊原样 vendor 引入（见 \`scripts/vendor-skills.mjs\`）。
> 本文件是青囊加的**适配层**：说明许可、改动、以及青囊的医学红线在本技能上如何生效。
> **上游的 \`SKILL.md\` 未改动**——Agent 以它为准，本文件是叠加约束。

## 一、来源与许可

| 项 | 值 |
|---|---|
| 上游仓库 | \`https://github.com/${org}/${repo}\` |
| 许可证 | **${license}**（上游 \`LICENSE\` 文件随本目录一并保留） |
| 分类 | ${cat} |
| 引入方式 | git clone（深度 1）→ 剥离依赖与产物 |
| 是否改动上游代码 | **否**（仅新增本文件） |

**许可义务**：保留上游 \`LICENSE\` 与版权声明（已保留）。若二次分发，需同样保留。

## 二、青囊医学五条红线（**在本技能上同样生效**）

借用来的社区 skill 不因为是"别人的"就豁免青囊红线。**冲突时以红线为准。**

| # | 红线 | 落到本技能 |
|---|---|---|
| **M1** | 不做诊断 | 输出只能"整理公开信息"，不得给出"你得的是 X / 你该按 Y 治" |
| **M2** | 不给用药建议 | 不给剂量、不给"换成某药"、不给停药建议 |
| **M3** | 隐私不出机 | 涉及病历时，一律指向 \`~/.qingnang/private/\`（0700），不得写入仓库 |
| **M4** | 急症先就医 | 命中红旗症状（剧痛 / 黄疸加重 / 呕血 / 意识改变）先转介就医 |
| **M5** | 出处标注 | 每条事实性输出带来源与时间；无来源时显式说"未核实" |

## 三、病人数据红线（本技能特别相关）

- 上游若含**示例数据、测试病例、真实报告单**，一律**不得**在青囊语境下当"演示数据"使用
- 需要演示时，走 \`data/synthetic/\`（合成数据）
- 上游 \`outputs/\`、\`cache/\`、\`*.log\` 已在 vendor 时剔除，不得回填

## 四、运行依赖

上游脚本依赖自带于本目录（\`requirements.txt\` / \`package.json\`）。
**青囊不代装**——需要时由 Agent 在**本项目目录内**按上游说明安装，且安装前须提示用户。

**代理提示**：若安装需走代理，见 \`skills/qingnang/HOST_PROFILE.md\` 的「网络与代理」一节（已实测验证）。

## 五、与主技能的关系

- **入口**：用户的医学问题先进 \`skills/qingnang/SKILL.md\`（总路由）
- **分工**：主技能负责伦理、通道分流、降级链；本技能负责具体业务能力
- **本机画像**：\`skills/qingnang/HOST_PROFILE.md\`
- **搜索通道**：\`skills/qingnang/SEARCH_RUNTIME.md\`
`;
}

const rows = [];
for (const v of VENDORED) {
  const from = join(SRC, v.repo);
  const to = join(ROOT, 'skills', v.repo);
  if (!existsSync(from)) { rows.push({ ...v, status: 'SKIP 源不存在' }); continue; }
  if (DRY) { rows.push({ ...v, status: 'DRY' }); continue; }
  await rm(to, { recursive: true, force: true });
  await mkdir(to, { recursive: true });
  await copyTree(from, to);
  await writeFile(join(to, 'QINGNANG.md'), adapter(v), 'utf8');
  const size = await dirSize(to);
  rows.push({ ...v, status: 'OK', size, files: (await readdir(to)).length });
}

// 迁移：老的 references/trials 已并入上游 skill，清掉避免重复
for (const stale of ['skills/qingnang-trials', 'skills/qingnang-guidelines',
                     'skills/qingnang-records', 'skills/qingnang-health',
                     'skills/qingnang-knowledge']) {
  const p = join(ROOT, stale);
  if (existsSync(p)) { if (!DRY) await rm(p, { recursive: true, force: true }); rows.push({ repo: stale, status: 'REMOVED 已由上游 skill 取代' }); }
}

if (!DRY) {
  console.log('\n  repo'.padEnd(42) + 'license'.padEnd(13) + 'size'.padEnd(8) + 'status');
  for (const r of rows) {
    console.log('  ' + String(r.repo).padEnd(40) + String(r.license || '-').padEnd(13) +
                String(r.size ? HUMAN(r.size) : '-').padEnd(8) + r.status);
  }
  console.log(`\n  合计 ${rows.filter(r => r.status === 'OK').length} 个 skill 已 vendor 到 skills/`);
}
