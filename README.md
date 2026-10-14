# 青囊 QingNang

> **小胰宝社区 · 医学能力资产包**
>
> 把社区积累的医学能力（文献检索 / 临床试验 / 指南 / 病历 / 影像 / 健康档案）打包成**一只任何 AI Agent 都能一键加载的工具箱**。
>
> **仓库**：https://github.com/PancrePal-xiaoyibao/QingNang ｜ **许可**：Apache-2.0

---

## 🎯 这是什么，为谁而做

**青囊不是给人用的软件，是给 AI Agent 用的能力包。**

| 谁 | 怎么用 |
|---|---|
| **你的 AI Agent** | 读青囊的技能文件，就知道该怎么查文献、找试验、看指南 |
| **你（病友或家属）** | 只要对 Agent 说话。它自己会选对工具 |
| **DeepSeek Harness Desktop**（未来） | 通过 `--format=dsh` 的 MCP 配置接入，让桌面版自带医学能力 |
| **社区贡献者** | 按合并契约往里加知识卡或新能力 |

**你不需要懂技术。** 复制一段指令给你的 Agent 就行。

---

## ⚠️ 医学伦理与免责

1. **本工具不构成医疗建议。** 只做信息检索与整理，**不诊断、不给用药剂量、不替代医生**。
2. **你的病情数据只留在自己电脑上。** 写入 `~/.qingnang/private/`（权限 0700），**永不上传、永不进 git**。
3. **社区只负责技术分发。** 提供技术工具与公开信息检索能力，**不承担诊疗责任、不做医疗背书**。
4. **遇到急症请立即就医**（剧烈腹痛 / 黄疸加重 / 呕血 / 意识改变），不要依赖任何 AI 工具。

> 每条涉及诊疗的回答都会自动附来源与免责。未经医学审校的知识卡标注 `pending-review`。

---

## 🚀 一键部署

### 平台支持

**三个平台命令完全相同。只需要 Node（≥22.13.0）。不需要 WSL、不需要 Git Bash、不需要 Python、不需要 npm install。**

| 平台 | 支持 | 说明 |
|---|---|---|
| **Linux** | ✅ 原生 | x64 / arm64 |
| **macOS** | ✅ 原生 | Intel / Apple Silicon |
| **Windows** | ✅ **原生** | PowerShell / CMD / Git Bash 都能跑（命令是 `node ...`，与 shell 无关） |

> **为什么不需要 WSL**：整条工具链是 **Node 脚本 + Node 跑的 MCP**。
> `node scripts/qingnang.mjs ...` 在 PowerShell、CMD、bash、zsh 里行为一致。
>
> **为什么不需要 npm install**：7 个 MCP 及其 265 个依赖包**已随仓库分发**（`vendor/node_modules/`，46MB）。
> clone 下来就能跑。Windows / macOS / Linux 的原生二进制都保留了。

### 把这段复制给你的 Agent

```
请把青囊（QingNang）医学能力包装到当前环境。

项目仓库：https://github.com/PancrePal-xiaoyibao/QingNang

按顺序执行，不要跳步：
1. git clone https://github.com/PancrePal-xiaoyibao/QingNang.git && cd QingNang
2. node scripts/qingnang.mjs fetch                  # 校验离线依赖（无需联网、无需 npm install）
3. node scripts/qingnang.mjs deploy --mode=source   # 探测本机 + 建私有目录
4. node scripts/qingnang.mjs deploy --mode=agent    # 装技能层到你自己的技能目录
5. node scripts/qingnang.mjs doctor                 # 逐通道体检，把结果贴回来

不用填任何 API Key：五条通道零凭据可用。
遇到报错按脚本给的中文提示处理，不要跳过任何一步。
```

### 手动部署（三步）

```console
# 1. 拿代码
git clone https://github.com/PancrePal-xiaoyibao/QingNang.git
cd QingNang

# 2. 校验离线依赖（有 vendor，秒级完成）
node scripts/qingnang.mjs fetch

# 3. 探测本机 + 部署
node scripts/qingnang.mjs deploy --mode=source    # 探测硬件/网络/代理 → 生成本机画像
node scripts/qingnang.mjs deploy --mode=agent     # 装技能层到你的 Agent
node scripts/qingnang.mjs doctor                  # 体检
```

**可选参数**：

| 参数 | 作用 |
|---|---|
| `--host=claude\|pi\|openclaw\|codex` | 指定宿主（不填则自动探测） |
| `--link` | 用软链代替复制（源改了宿主副本自动跟随） |
| `--dry-run` | 只验证链路，不写任何文件 |

### 凭据配置（全部选填）

```console
cp .env.example .env
# 编辑 .env（大多数情况不用填）
node scripts/qingnang.mjs doctor     # 逐项显示 ✓ 已配 / ⬜ 选填未配 / ❌ 出错
```

| 变量 | 用途 | 不填的后果 |
|---|---|---|
| `KNOWS_API_KEY` + `KNOWS_API_HOST` | 高级医学证据通道 | 自动降级到 PubMed + OpenAlex，**并在回答中明示** |
| `GET_NOTE_API_KEY` | 病友经验通道 | 该通道不启用（**该能力唯一，不用别的凑**） |
| `NCBI_API_KEY` | PubMed 提速 | 限速 3 次/秒（个人足够） |
| `OPENALEX_EMAIL` | OpenAlex 提速 | 共享池，较慢 |

---

## 🎁 部署后，你的 Agent 获得什么

### 一、11 个 Skill

青囊 = **1 个主技能（总路由与伦理）+ 10 个社区医学技能（原样引入）**。
上游 skill 的 `SKILL.md` **一字未改**；青囊在每个目录里追加一份 `QINGNANG.md` 适配层，写明许可 + 青囊五条红线在这个技能上如何生效。
其中 2 个上游不是 skill 形态（无 `SKILL.md`），青囊补了一份并在文件头**明确标注「青囊编写，非上游」**。

#### 主技能

| Skill | 干什么 |
|---|---|
| **`qingnang`** | **总路由 + 五条医学红线 + 七步执行流 + 七通道分流表 + 降级链** |

#### 社区医学技能（11 个，按场景）

| Skill | 干什么 | 许可 |
|---|---|---|
| `clinicaltrials-query-analysis` | 临床试验搜索 + 专题报告（含靶点清单、中国中心专题） | Apache-2.0 |
| `chictr-trials-collector` | 中国临床试验登记平台（ChiCTR）采集 | Apache-2.0 |
| `clinicaltrials-intel-skill` | 试验情报订阅与多渠道推送 | Apache-2.0 |
| `nccn-guideline-downloader` | NCCN 指南与患者手册（**含版权硬约束**） | Apache-2.0 |
| `RAG-content-processor` | 知识包生产线（下载→清洗→打标→入库） | Apache-2.0 |
| `aura_health_profile` | 健康档案与复诊简报 | MIT-0 |
| `getnote-openclaw` | 笔记沉淀（病友经验记录） | MIT |
| `xyb_dicom_download_skills` | DICOM 影像下载与整理 | Apache-2.0 |
| `maskdesk` | Local-first 病历脱敏工作台 | Apache-2.0 | ＊
| `medical-desensitization` | 医疗文本脱敏 | Apache-2.0 | ＊ |

> ＊ = 上游不是 skill 形态（`maskdesk` 是 Electron 应用、`medical-desensitization` 是 Next.js 应用），
> 青囊补了适配 `SKILL.md` 并在文件头标注「青囊编写」。

> 装完可以问 Agent：「**你现在有哪些青囊能力？**」——它会列出上面这些。
> 完整清单与逐项说明：见 [`docs/CAPABILITIES.md`](docs/CAPABILITIES.md)

### 二、28 个 MCP 工具（5 条零凭据通道）

| 通道 | 工具数 | 代表工具 |
|---|---|---|
| **通用网页搜索** | 6 | `search`、`fetchWebContent`、`fetchGithubReadme` |
| **中文网页搜索** | 2 | `bing_search`、`crawl_webpage` |
| **PubMed 医学文献** | 5 | `pubmed_search`、`pubmed_get_details`、`pubmed_find_related` |
| **OpenAlex 学术文献** | 8 | `openalex_search`、`openalex_download_fulltext`、`openalex_get_fulltext_sections` |
| **临床试验** | 7 | `search_trials`、`get_trial_detail`、`get_record_evidence` |

**+ 2 条凭据门通道**（留空即可，不影响上面 28 个）：
- **通道 5 · 高级医学证据**（KnowS）→ 缺凭据自动降 PubMed + OpenAlex
- **通道 6 · 病友经验**（get-biji）→ 缺凭据明示未启用

> **完整工具清单与参数**：见 [`docs/CAPABILITIES.md`](docs/CAPABILITIES.md)

### 三、注入层（Agent 怎么知道有青囊）

青囊用**三层注入**，按需加载。这是 Agent 高效调用的关键：

```
① INJECT.md（2026B / 上限 2048B）          ← 常驻 Agent 上下文
     只说：有青囊 / 三条红线 / 涉搜索去读 SEARCH_RUNTIME.md
     ↓ 用户问搜索类问题时
② SEARCH_RUNTIME.md（7828B / 上限 8192B）  ← 按需加载
     七条通道的分工、参数、降级顺序、双向引用
     ↓ 需要知道本机情况时
③ HOST_PROFILE.md（运行时生成）            ← 按需加载
     本机硬件、代理（已实测验证）、构建器
```

**为什么这么分**：常驻上下文越短，Agent 的「注意力预算」越省。
所以主注入**只负责指路**，具体工具放独立文件。

**收益**：新增搜索工具**只改 `SEARCH_RUNTIME.md`，不动主注入**。
这条有自动断言守住——`check` 会检查主注入里**不许出现任何工具包名**。

> **给宿主开发者的改造建议**：如果你的宿主有自己的注入机制，**逐层重渲染**这三个文件即可，不要合并成一个大文件。
> 详见 [`AGENTS.md`](AGENTS.md) §5。

### 四、降级链（每处选择都有三档）

**任何一环失败都不会卡死**，而且降档**必须可观察**。

| 层 | 首选 | 次选 | 兜底 |
|---|---|---|---|
| **MCP 依赖** | **vendor 随包分发**（零网络） | npm install | pnpm install |
| **JS 包管理器** | pnpm（隔离布局） | npm | yarn |
| **Python 环境** | uv venv | python -m venv | conda |
| **代理** | 自动探测并**真实验证** | 用户 `.env` 手填 | 直连 |
| **MCP 调用** | 通道首选模式 | 通道次选模式 | 降级到另一条通道 |
| **宿主注入** | 原生 skills 目录 | 追加 marker 块 | 输出路径让用户手动贴 |

**三条纪律**：

1. **必须可观察** —— 降档时说清「走了哪档、为什么」。用户不知道降级 = 降级没发生。
2. **兜底允许放弃** —— 能力不可用时**明说不可用**是正确的兜底。
3. **兜底不许污染** —— 任何降级都不得触碰 `~/.qingnang/private/`。

> **给宿主开发者的改造建议**：你的宿主选择能力时也要有降级链。
> **绝不静默编造**——这是本项目最硬的一条。详见 [`AGENTS.md`](AGENTS.md) §1。

### 五、本机适配（自动完成）

| 能力 | 说明 |
|---|---|
| **本机画像** | 探测硬件 / 网络 / 代理 / 构建器 → 写入 `HOST_PROFILE.md` |
| **代理验证** | **真的发请求验证代理能用**（不是只看端口在不在监听） |
| **宿主分派** | 自动识别 Claude Code / pi / OpenClaw / Codex 并装到对应位置 |

---

## 🔑 凭据申请

**不填任何 Key，青囊已完整可用**（28 个工具 + 11 个 skill）。

| 变量 | 申请入口 | 不填的后果 |
|---|---|---|
| `KNOWS_API_KEY`<br>`KNOWS_API_HOST` | 走社区公众号/小程序试用额度 → [社区组织页](https://github.com/PancrePal-xiaoyibao) | 自动降级到 PubMed + OpenAlex，**并明示** |
| `GET_NOTE_API_KEY` | [得到笔记](https://getnote.cn/) 账号 API 凭据 | 该通道不启用 |
| `NCBI_API_KEY` | https://www.ncbi.nlm.nih.gov/account/ | 限速 3 次/秒 |
| `OPENALEX_EMAIL` | https://openalex.org/ | 共享池，较慢 |

---

## 🛡️ 数据安全

| 项 | 说明 |
|---|---|
| **私有数据位置** | `~/.qingnang/private/`（权限 `0700`） |
| **包含什么** | 报告单原件、解析文本、病情档案、检索历史、DICOM 影像 |
| **遥测** | **默认关闭，唯一合法值是 `off`**；其他值脚本会拒绝 |
| **网络请求** | 只携带**检索关键词**，**永不携带身份或病情细节** |
| **导出/分享** | 任何导出路径都不得触碰 `private/` |
| **本机画像** | `HOST_PROFILE.md` 含你的代理与硬件，**已 gitignore** |
| **脱敏闸门** | 病历类内容出机前必须过 `medical-desensitization`；不通过则**拒绝**后续处理 |

---

## ❓ 故障排查

| 现象 | 原因 | 怎么办 |
|---|---|---|
| `node: command not found` | 没装 Node | 去 https://nodejs.org/ 装 LTS |
| Node 版本过低 | 需 ≥22.13.0 | `nvm install 22` 或升级 |
| 搜不到结果 / 超时 | 本机需要代理 | 看 `skills/qingnang/HOST_PROFILE.md` 的「网络与代理」一节 |
| `MCP 入口不存在` | vendor 不完整 | `node scripts/qingnang.mjs fetch --force` |
| 某通道显示 `❌` | 通道不可用 | `node scripts/qingnang.mjs doctor` 会给中文修复指引 |
| `⬜` 是什么意思 | 选填项未配 | **不是错误，不影响使用** |
| Agent 不知道有青囊 | 注入没装到位 | 重跑 `node scripts/qingnang.mjs deploy --mode=agent` |

**自检命令**：

```console
node scripts/qingnang.mjs check    # 聚合自检（清单/体积/vendor/隐私/治理）
node scripts/qingnang.mjs doctor   # 九项体检
node tests/acceptance/e2e.mjs      # 端到端验收
cmp AGENTS.md CLAUDE.md            # 治理文档一致性（Windows 用 fc）
```

---

## 🤝 参与贡献

**最需要的不只是代码**——病种知识卡、术语中英对照、FAQ 整理，价值不低于代码。

**红线**：❌ 禁止提交任何真实患者数据（姓名 / 证件号 / 手机号 / 住院号 / 报告单原件）。
演示数据走 `data/synthetic/`。仓库有自动闸门（pre-commit + CI + AI 复审）。

**准入纪律**：一条新能力能不能进，看四条——医学相关吗？是能力还是应用？许可干净吗？能被 Agent 调用吗？
详见 [`skills/qingnang/MERGE_CONTRACT.md`](skills/qingnang/MERGE_CONTRACT.md)。

**流程**：见 [`CONTRIBUTING.md`](CONTRIBUTING.md)。

---

## 📚 文档

| 想了解 | 看这个 |
|---|---|
| **完整能力清单**（12 skill + 28 工具逐个说明） | [`docs/CAPABILITIES.md`](docs/CAPABILITIES.md) |
| **技术架构**（三层注入 / 离线 vendor / forge 接缝） | [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) |
| **产品需求**（用户 / 场景 / 目标 / 成功标准） | [`tasks/CHG-20261014-qingnang-mvp/PRD.md`](tasks/CHG-20261014-qingnang-mvp/PRD.md) |
| **立项与架构决策**（ADR-001 ~ ADR-015） | [`tasks/CHG-20261014-qingnang-mvp/CHANGE.md`](tasks/CHG-20261014-qingnang-mvp/CHANGE.md) |
| **工程契约**（42 个验收锚点 / 里程碑） | [`tasks/CHG-20261014-qingnang-mvp/SPEC.md`](tasks/CHG-20261014-qingnang-mvp/SPEC.md) |
| **验收证据** | [`TRACEABILITY.md`](tasks/CHG-20261014-qingnang-mvp/TRACEABILITY.md) ｜ [`tests/acceptance/REPORT.md`](tests/acceptance/REPORT.md) |
| **给 Agent 的工作规则**（降级链铁律 / 医学五条 / 数据安全） | [`AGENTS.md`](AGENTS.md) |
| **合并纪律**（什么能进、怎么进、怎么耦合） | [`skills/qingnang/MERGE_CONTRACT.md`](skills/qingnang/MERGE_CONTRACT.md) |
| **许可台账**（每个资产的来源 / 许可 / 改动 / 待办） | [`skills/qingnang/references/SOURCES.md`](skills/qingnang/references/SOURCES.md) |
| **社区资产全量盘点**（137 仓库） | [`docs/ASSET_INVENTORY_20261014.md`](docs/ASSET_INVENTORY_20261014.md) |
| **架构与开发计划**（母文档） | [`docs/QingNang_Community_Asset_Pack_Architecture_and_DevPlan_v1.0_20261014.md`](docs/QingNang_Community_Asset_Pack_Architecture_and_DevPlan_v1.0_20261014.md) |

---

## 🗺️ 路线图

| 阶段 | 项目 | 内容 |
|---|---|---|
| **一（当前）** | **青囊**（本仓库） | 独立的社区医学能力资产包，多 agent 适配 |
| **二** | **forge 合并** | 青囊 × DSH Desktop 合并，深度嵌入医学能力 |
| **三** | **小胰宝社区版 DSH Desktop** | 独立项目：青囊 + DSH 嵌入开发 + 数据库接入 |

**本包为阶段二/三预留了五条 forge 接缝**（零宿主专属代码 / manifest 唯一事实源 / 三层注入物理分离 / 合并契约随包交付 / 本机画像解耦）。
详见 [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)。

---

<p align="center">
  <strong>青囊</strong> · 华佗狱中传《青囊书》，是中国文化里「医术传承、济世救人」的原型意象。<br>
  把社区医学能力装进一只包，让任何 Agent 都能用。
</p>
