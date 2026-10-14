# 青囊 QingNang —— 小x宝社区医学能力包 · 架构与开发计划 v1.0（定稿）

> **文档目的**：社区资产打包 + DeepSeek Harness Desktop 医学发行版的总体架构、MVP 原材料清单、分阶段开发计划。
> **版本**：**v1.0 定稿**（2026-10-14 主人拍板定名「青囊 QingNang」）｜ 两组织全量盘点已完成（137 仓库，底稿见同目录 `ASSET_INVENTORY_20261014.md`）｜ **起草**：小虾 🦞
> **状态**：✅ 架构与命名已定稿。下一步：新建 GitHub 仓库 → Phase 1 骨架；并行清偿许可证债（见 §14.3）。
> **范围澄清（2026-10-14 主人明确）**：本项目的定位是**社区医学资产打包**——把小胰宝社区已验证的医学能力装成一个可移植资产包，品牌为**小胰宝**。**桌面发行版（DSH Desktop 整合）属未来独立项目，可能另建仓库，不在本包范围内**（见 §2.4）。

---

## 0. TL;DR

把小x宝社区两个开源组织（**137 个仓库全量盘点完毕**）里已验证的 **4 个自研医学 MCP + 病历脱敏/指标管理/心理评估等 18 项 P1 资产 + 1 个离线数据包 + 提示词知识资产**，按「超薄注入层 + 薄 skill + 厚 reference」的结构打成一个可移植资产包 **青囊（QingNang）**；包遵循「零凭据可跑、凭据增强、数据全本地」原则，支持**一句话部署到任意 Agent**——任何 Agent 用户拿到仓库地址与一段部署指令，即刻获得全部社区医学能力。胰腺癌先行，病种可插拔扩展，公益开源。

> **本包只管一件事：社区医学资产的打包与分发。** 桌面发行版、DSH 集成属未来独立项目（§2.4）。
>
> **搜索能力是青囊的核心入口**（详见 §2.5）：包内建一套 **search runtime**（搜索运行时分流层），用两层注入（主注入薄引导 → runtime 详细分流）让 Agent 高效选通道：一般搜索用 open-websearch、中文网页用 bing-cn、学术文献用 PubMed + OpenAlex、临床试验用 unified-trial、高级医学证据用 KnowS（需凭据）。

**定稿仓库落点**：`PancrePal-xiaoyibao/qingnang`（**唯一仓库**，社区医学资产包）。落小胰宝社区 org，公益开源，**不设迁移计划**。

---

## 1. 愿景与目标

### 1.1 一句话

> 让任何一个癌症病友，下载一个软件、或对任意 AI 说一句话，就立刻获得整个社区沉淀的医学信息能力——文献、临床试验、诊疗知识、病友经验——而自己的病情数据永远只留在自己电脑里。

### 1.2 三层交付物

| 层 | 交付物 | 形态 | 面向人群 |
|---|---|---|---|
| L1 资产包 | `qingnang` | 一个 monorepo（skills + MCP 声明 + 知识包 + 部署脚本） | 任何 Agent 用户 / 开发者 |
| L2 知识网络 | 病种子包序列 | `qingnang-pancreas` → `qingnang-breast` → `qingnang-gastric` → `qingnang-lung` | 全癌种社区 |

> **不在本包范围（§2.4）**：桌面发行版（DSH Desktop 整合安装包）属未来独立项目，届时可能新建仓库。本包只做资产打包与分发。

### 1.3 设计原则（六条铁律）

1. **隐私本地化**：用户病情数据 100% 留在本地 `~/.qingnang/private/`，永不入 git、永不上传；遥测默认关闭。
2. **零凭据可跑**：不填任何 API Key 时，包内提供完整能力的**无凭据子集**（open-websearch + bing-cn + PubMed + OpenAlex + unified-trial + 本地知识库）；凭据只为增强（KnowS 等），不为门槛。
3. **一句话部署**：复制一段部署咒语给任意 Agent（Claude Code / pi / OpenClaw / Codex），即可完成部署+自检（复用 StarChart 已验证的两步部署模式）。
4. **病种可插拔**：架构病种无关；胰腺癌只是第一个被装载的知识子包。新增病种 = 新增一个 references 子目录 + 数据包 release，不动核心。
5. **宿主可移植**：本包对宿主的唯一要求是「支持 MCP + 能读 SKILL.md」。**不绑定任何宿主**；任何支持 MCP 的 Agent 都能装。**注意**：DSH（DeepSeek Harness）无 SKILL.md 惯例（其插件为 Cordis TS 插件），接入方式不同，详见 §9（属未来项目）。
6. **搜索分流（search runtime）**：Agent 不靠猜选搜索工具。主注入文档只给**薄提示**（指引到 search runtime），具体选哪个 MCP 由 **search runtime 注入文档**决策（见 §2.5 与 §3.3）。

---

## 2. 项目命名（✅ 2026-10-14 主人定稿）

> 华佗狱中传《青囊书》，是中国文化里「医术传承、济世救人」的原型意象。青囊 = 装医书的布袋——恰好就是「把社区医学能力装进一只包」的字面表达。

- **文化纵深**：医者仁心 + 知识传承 + 公益济世，与项目使命完全同构；对病友和媒体有叙事力。
- **工程友好**：二字、拼音 `qingnang` 全球唯一性好，repo/命令行/环境变量前缀都干净（`QINGNANG_*`）。
- **可扩展**：病种子包天然形成「青囊·胰」「青囊·乳」「青囊·胃」系列，与「小胰宝/小粉宝」社区品牌互为表里（社区 IP 叫小x宝，开源资产叫青囊）。
- **定稿落地方案**（默认落社区 org，后续如需可整体迁移）：
  - 资产包 repo：`PancrePal-xiaoyibao/qingnang`（唯一仓库）
  - npm scope：`@qingnang/*`（社区已有 `@xiaoyibao_npm` scope，可并存过渡）
  - 环境变量前缀：`QINGNANG_*`；本地数据目录：`~/.qingnang/`

### 2.2 评估存档（备选方案，已评估未采纳）

| 名字 | 理由 | 顾虑 |
|---|---|---|
| **百宝囊 BaoNang** | 「小x宝社区」的宝们装进一只囊，品牌契合度最高；「囊」呼应青囊 | 拼音 `baonang` 国际传播弱；略口语化 |
| **MedSpore 医学孢子** | 一句话部署 = 孢子落地生根，技术隐喻精准；国际化好记 | 缺医学人文纵深；「孢子」对病友群体意象偏冷 |
| **OpenCare Hub** | 与现有 `opencare-skillhub` 组织一脉相承 | 泛化、易撞名、无中文叙事 |

### 2.3 命名规范（即日起全项目生效）
```
qingnang                    # 社区医学资产包主仓库（本档主角，唯一仓库）
qingnang-pancreas           # 病种子包：胰腺癌（对应小胰宝）
qingnang-breast             # 病种子包：乳腺癌（对应小粉宝，未来）
@qingnang/<pkg>             # npm scope
QINGNANG_*                  # 环境变量前缀
~/.qingnang/                # 用户本地数据根目录（隐私沙箱）
```

### 2.4 本包范围边界（2026-10-14 主人明确）

**本项目 = 社区医学资产打包。** 只做一件事：把小胰宝社区已验证的医学能力装成一只可移植的包。

| 属于本包 | 不属于本包 |
|---|---|
| MCP 能力声明与健康检查 | 宿主专属适配代码 |
| 技能层（注入 + SKILL.md + references） | 桌面发行版（DSH 桌面安装包） |
| 一键部署与体检脚本 | DSH Cordis 插件包 |
| 公开知识包（可再分发部分） | 云端服务 / 账号体系 |
| 敏感信息守门与合规声明 | 病种应用的 UI |

> **DSH 集成属未来独立项目**（可能另建仓库）：DSH 插件是 Cordis TS 插件，**无 `SKILL.md` 目录惯例**，MCP 走结构化 `StdioConfig`。这是一个独立工作量，与「资产打包」不是一个关注点。事实存档见 §9.2。

### 2.5 搜索能力与 search runtime（本包核心入口，2026-10-14 主人要求纳入）

青囊最常被用到的能力是**搜索**。Agent 面对「帮我查…」时，最危险的不是搜不到，而是**用错通道**（用通用搜索查临床指南、用文献库查中文新闻）。所以青囊把搜索做成一个**显式的分流层**。

| 层 | 文件 | 职责 | 体积 |
|---|---|---|---|
| **主注入** | `INJECT.md` | **薄提示**：告诉 Agent「有青囊，涉搜索先读 search runtime 分流」，不列具体工具 | ≤2KB |
| **搜索运行时** | `skills/qingnang/SEARCH_RUNTIME.md` | **详细分流表**：问题信号 → 用哪个 MCP → 参数要点 → 降级顺序 | ≤8KB |
| **技能决策** | `SKILL.md` | 总体路由（搜索类直接转 SEARCH_RUNTIME） | ≤14KB |
| **厚参考** | `references/**` | 病种知识、指标卡、术语表 | 不限 |

**搜索通道分工（五条）**：

| # | 通道 | MCP | 凭据 | 适用问题信号 | 不该用它查 |
|---|---|---|---|---|---|
| 1 | **通用网页搜索** | `open-websearch` | 免 | 一般资讯、最新动态、某个名词是什么 | 学术文献、临床试验登记 |
| 2 | **中文网页搜索** | `bing-cn-mcp` | 免 | 中文内容、国内政策/指南/公众号/网报 | 英文文献、结构化检索 |
| 3 | **学术文献** | `mcp-pubmed-llm-server` + `openalex-mcp-server` | 免（OpenAlex 可选邮箱提速） | 论文、机制、指南出处、影响因子 | 网页新闻、试验招募 |
| 4 | **临床试验** | `unified-trial-mcp` | 免 | 在招试验、入组标准、中美双登记 | 文献综述 |
| 5 | **高级医学证据** | `@xiaoyibao_npm/knows-mcp-server` | **需凭据** | 循证医学证据、指南结构化摘要 | 一般网页检索（浪费额度） |

**分流铁律（写进 SEARCH_RUNTIME.md）**：

1. **先分类再检索**：Agent 必须先判定问题属于表中哪一类，再选通道；跨类则**并行调多个**（如「查胰腺癌最新治疗」= 通道 3 + 4 + 5）。
2. **零凭据不降级为不可用**：通道 5 缺凭据时，**自动降到通道 3（PubMed + OpenAlex）**，并在回答中**明示「本次未使用 KnowS（需凭据）」**。
3. **绝不静默编造**：任何通道失败必须明说「当前不可用」，绝不编造未检索到的内容。
4. **中文优先通道 2**：涉及中国患者、国内政策、中文指南时，通道 2 优先于通道 1。
5. **能并行不串行**：多通道检索应并行发出，不逐个等待。

> **设计理由**：主注入要薄（常驻上下文，越短越好），所以只给「去找 search runtime」这一层引导；具体工具表放 SEARCH_RUNTIME.md（按需加载，不占常驻上下文）。这是§3.3 三层结构的直接应用。

---

## 3. 总体架构

### 3.1 分层架构

```
┌─────────────────────────────────────────────────────────────────┐
│  L4 宿主层    OpenClaw / Claude Code / pi / Codex / 任意 MCP 宿主       │
│              （DSH 另有接入方式，见 §9）                             │
├─────────────────────────────────────────────────────────────────┤
│  L3 注入层    两层注入（Agent 启动注入）                        │
│              INJECT.md（≤2KB）→ 宣青囊 + 指路 SKILL.md + 搜索薄提示│
│              SEARCH_RUNTIME.md（≤8KB）→ 搜索工具详细分流表        │
├───────────────────────────────────────────────────────────────┤
│  L2 技能层    薄 SKILL.md（≤14KB 决策层：路由表 + 铁律 + 红线）     │
│              厚 references/（按需加载：病种知识/指标卡/话术/FAQ）    │
├───────────────────────────────────────────────────────────────┤
│  L1 能力层    MCP servers（统一健康检查，锁版本）                   │
│              搜索：open-websearch · bing-cn · openalex · pubmed  │
│                    unified-trial · knows(需凭据)                  │
│              其他：get-biji · mineru · 本地 RAG（sqlite 级）        │
├─────────────────────────────────────────────────────────────────┤
│  L0 数据层    公开知识包（随发行版分发，可再分发许可）               │
│              用户私有数据（~/.qingnang/private/，永不出机）         │
├─────────────────────────────────────────────────────────────────┤
│  L-1 治理层    PR 敏感信息自动审查（gitleaks + PHI/PII 规则 + AI 审查）│
│              许可证合规矩阵 · 医疗免责 · 贡献者引导                  │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 数据流与隐私边界

```
病友提问 ──→ 注入层路由 ──→ ┌─ 文献类问题 → pubmed / knows(有凭据)
                            ├─ 试验类问题 → unified-trial (ICTRP/CT.gov/ChiCTR/中国登记平台)
                            ├─ 知识类问题 → 本地 RAG（公开知识包 + 用户私有数据合并检索）
                            └─ 经验类问题 → get-biji 病友笔记知识库
         ──→ 回答强制附带：出处 + 「不构成医疗建议，请与主治医生确认」
         ──→ 用户报告单/病历 ──→ MinerU 本地解析 ──→ 只写入 ~/.qingnang/private/
```

**隐私边界三条**：
1. 所有网络请求只携带**检索关键词**（病名、药名、试验编号），永不携带用户身份/病情细节。
2. 用户上传的报告单原件、解析文本、检索历史全部落在 `~/.qingnang/private/`；该目录被 `.gitignore` + 安装包权限双重保护。
3. 发行版内嵌数据仅限**可再分发公开数据**（政府公开登记信息、指南要点社区摘录、CC 授权内容），逐项登记来源与许可。

### 3.3 技能结构规范（社区已验证模式的产品化）

青囊把主人工作区已跑通的三层结构（美学大脑 / 数学大脑 / StarChart）泛化为社区标准：

| 结构 | 体积约束 | 内容 | 加载时机 |
|---|---|---|---|
| **超薄注入层** `INJECT.md` | ≤2KB | 一段系统提示片段：宣告青囊存在 + 指路 SKILL.md + 三条红线（不诊断/不荐药/隐私不出机） | Agent 启动常驻 |
| **薄技能层** `SKILL.md` | ≤14KB | 意图路由表（问题信号→通道）、七步执行流、铁律、环境变量自检 | 首次触发全文读 |
| **厚参考层** `references/**` | 不限 | 病种知识卡、指标解读、术语中英对照、临床试验名词表、心理支持话术、FAQ | 按需单文件读 |
| **能力层** `mcp-servers/` | — | vendor 的 MCP 源码或 npm 依赖声明 + 统一启动/健康检查脚本 | deploy.sh 安装 |
| **清单** `MANIFEST.json` | — | 版本、组件 hash、索引指纹、凭据矩阵——版本一致性三锁（参照 StarChart P2） | 校验 |

---

## 4. 社区资产盘点（已确认部分）

### 4.1 两个开源组织（2026-10-14 全量盘点完成）

| 组织 | 定位 | 仓库数 | 链接 |
|---|---|---|---|
| **PancrePal-xiaoyibao** | 小胰宝开源社区主组织（病友 SamQin 创立，小胰宝开源社区 CMC × 天工开物基金会管理，110+ 生态成员） | **95** | https://github.com/PancrePal-xiaoyibao |
| **opencare-skillhub** | 社区的技能/MCP 工作坊（skill 为主，含 unified-trial） | **42** | https://github.com/opencare-skillhub |

> 全量 137 仓库的分类盘点底稿（P0/P1/P2/OBS/⛔ 定向 + 许可证债清单）见 **`ASSET_INVENTORY_20261014.md`**。下表只列进入 MVP 视野的核心资产。

### 4.2 核心资产矩阵（MVP 视野，全量见盘点底稿）

| 资产 | 仓库 | npm 包 | 许可证 | 用途 |
|---|---|---|---|---|
| 智能RAG平台（旗舰） | [PancrePal-xiaoyibao/PancrePal-xiaoyibao](https://github.com/PancrePal-xiaoyibao/PancrePal-xiaoyibao) | — | Apache-2.0（210★） | 知识内容与 RAG 经验上游；本包不整体 vendor（太重），取其语料与思路 |
| PI 桌面版 + 离线数据包 | [PancrePal-xiaoyibao/xyb-pi-agent](https://github.com/PancrePal-xiaoyibao/xyb-pi-agent) | — | LGPL-3.0 | **Releases 提供「小胰宝离线数据包」**（ChiCTR/CDE 公开登记整理，community_owned）→ 青囊公开知识包 v0.1 的直接来源 |
| PubMed 文献 MCP | [PancrePal-xiaoyibao/mcp-pubmed-server-pancrpal](https://github.com/PancrePal-xiaoyibao/mcp-pubmed-server-pancrpal) | `mcp-pubmed-llm-server`（163 月下载） | repo=Apache-2.0（npm 写 MIT ⚠️ 不一致，Phase 0 统一） | P0 必选 |
| KnowS 医学证据 MCP | [PancrePal-xiaoyibao/MCP-KnowS-AI](https://github.com/PancrePal-xiaoyibao/MCP-KnowS-AI) | `@xiaoyibao_npm/knows-mcp-server` | ⚠️ repo 无 LICENSE（npm 声明 MIT，待补文件） | P0 必选（需凭据，见 §7） |
| 统一临床试验检索 MCP | [opencare-skillhub/unified-trial-search-mcp-service](https://github.com/opencare-skillhub/unified-trial-search-mcp-service) | `unified-trial-mcp`（208 月下载，2026-10-06 发版） | MIT | P0 必选：一个入口覆盖 ICTRP + ClinicalTrials.gov + ChiCTR + 中国药物临床试验登记平台（含研究者信息） |
| PDAC 提示词资产 | [PancrePal-xiaoyibao/PDAC-multi-agents-prompts](https://github.com/PancrePal-xiaoyibao/PDAC-multi-agents-prompts) | — | Apache-2.0 | P0 素材：多场景多智能体提示词集，零成本并入知识层 references |
| 病历脱敏工作台 | [PancrePal-xiaoyibao/maskdesk](https://github.com/PancrePal-xiaoyibao/maskdesk) | — | Apache-2.0 | P1：Local-first 病历脱敏「数据永不出机」，与青囊隐私铁律同频 |
| CA19-9 管理工具箱 | [PancrePal-xiaoyibao/ca199_toolbox_donated_by_lihb](https://github.com/PancrePal-xiaoyibao/ca199_toolbox_donated_by_lihb) | — | AGPL-3.0（独立工具形态隔离） | P1：胰腺癌核心指标追踪 ★7 病友刚需 |
| NCCN 指南下载 skill | [opencare-skillhub/nccn-guideline-downloader](https://github.com/opencare-skillhub/nccn-guideline-downloader) | — | Apache-2.0 | P1：知识包生产管线（⚠️ 指南全文有版权，仅做要点摘录+官方链接） |
| 试验检索+LLM分析 skill | [opencare-skillhub/clinicaltrials-query-analysis](https://github.com/opencare-skillhub/clinicaltrials-query-analysis) | — | Apache-2.0 | P1：检索质量增强 |
| 病历整理 skill | [opencare-skillhub/Medical-Record-Organizer](https://github.com/opencare-skillhub/Medical-Record-Organizer) | — | ⚠️ none（待补） | P1：llm/mineru/paddle 整理多中心病历 |
| 心理评估 skill | [opencare-skillhub/skill-HADS-accessment](https://github.com/opencare-skillhub/skill-HADS-accessment) | — | ⚠️ none（待补） | P1：HADS 量表评估（量表版权需核） |
| 健康档案 skill | [opencare-skillhub/aura_health_profile](https://github.com/opencare-skillhub/aura_health_profile) | — | MIT-0 | P1：慢病健康档案 |
| 知识包生产线 | [opencare-skillhub/RAG-content-processor](https://github.com/opencare-skillhub/RAG-content-processor) | — | Apache-2.0 | P1：文章下载→格式化→上传流水线（内部工具） |
| Get笔记 MCP | [PancrePal-xiaoyibao/get-biji-dev-by-gemini3pro](https://github.com/PancrePal-xiaoyibao/get-biji-dev-by-gemini3pro) / [get_biji_mcp](https://github.com/PancrePal-xiaoyibao/get_biji_mcp) | `get-biji-mcp` | ⚠️ 两仓库均无 LICENSE | P1：病友经验知识库（先补 LICENSE） |
| MinerU 社区分支 | [PancrePal-xiaoyibao/MinerU-xyb](https://github.com/PancrePal-xiaoyibao/MinerU-xyb) / [mineru-tianshu](https://github.com/PancrePal-xiaoyibao/mineru-tianshu) | — | AGPL-3.0 / Apache-2.0 FORK | P1 评估：tianshu 支持 MCP 且 Apache-2.0（底层仍含 MinerU 组件，许可继承 Phase 0 核） |
| ChiCTR 单通道 MCP | [PancrePal-xiaoyibao/chictr-mcp-server](https://github.com/PancrePal-xiaoyibao/chictr-mcp-server) | — | Apache-2.0（★5，2026-10-04 活跃） | P2：unified-trial 的上游参考/降级备份 |
| 早期试验 MCP（单通道） | [PancrePal-xiaoyibao/xiaoyibao-clinical-trials-mcp-server](https://github.com/PancrePal-xiaoyibao/xiaoyibao-clinical-trials-mcp-server) | `xiaoyibao-clinical-trials` | MIT | P2：被 unified-trial 取代 |
| 病种垂直应用先行者 | RAG-xiaofeibao(肺癌) / xiaofubao(妇科) / Lymphoma_AI_assistant(淋巴瘤) / xiaoxuebao(儿童) | — | 混合 | OBS：病种扩展模板参照与语料来源 |
| Get笔记 OpenClaw Skill | [opencare-skillhub/getnote-openclaw](https://github.com/opencare-skillhub/getnote-openclaw) | — | MIT（fork） | P1：skill 形态参考 |

### 4.3 盘点结论与许可证债

**结构发现**：社区资产呈「MCP 检索层 + skill 工作坊 + 数据管线 + 隐私脱敏 + 病种垂直应用」五线并行，与青囊 L0-L3 分层天然对齐；「小x宝」病种系列（胰/肺/腹/铃铛/雪宝/馨宝）已验证病种可插拔模式。另发现社区已 fork 数学大脑/美学大脑（种子库模式外溢），青囊 skill 结构规范与社区习惯同构，落地无摩擦。

**许可证债清单（vendor 前必须清偿，详见盘点底稿）**：
1. `MCP-KnowS-AI` repo 无 LICENSE（npm 声明 MIT）→ 请 Sam 补文件
2. `mcp-pubmed-server-pancrpal` repo（Apache-2.0）与 npm（MIT）不一致 → 统一口径
3. `get-biji` 双仓库、`Medical-Record-Organizer`、`skill-HADS-accessment`、`dayi-search-mcp` 等无 LICENSE → P1 前补
4. `dicom_download_mcp`（禁商用条款）、`VitaForge` 等自定义条款 → 逐条人工核
5. xyb-pi-agent 离线数据包再分发条款 → 与 Sam 书面确认
6. NCCN 指南全文有版权 → 只做要点摘录 + 官方链接，绝不全文分发

---

## 5. MVP（v0.1）原材料清单

### 5.1 P0 —— MVP 必选（首发就要有）

| # | 组件 | 来源 | 凭据 | MVP 角色 |
|---|---|---|---|---|
| 1 | `mcp-pubmed-llm-server` | 社区自研（repo Apache-2.0，npm 元数据 MIT ⚠️ Phase 0 统一） | 免凭据可用（NCBI 无 key 限速 3 req/s，个人够用；选填 `NCBI_API_KEY` 提速） | 文献检索主通道 |
| 2 | `unified-trial-mcp` | 社区自研（MIT） | 免凭据 | 临床试验检索主通道（中美双登记，病友最刚需） |
| 3 | `@xiaoyibao_npm/knows-mcp-server` | 社区自研（npm MIT；repo 待补 LICENSE） | **需凭据**：`KNOWS_API_KEY` + `KNOWS_API_BASE_URL`（环境变量注入，申请教程进 README） | 循证医学证据增强通道（不填则自动降级到 PubMed） |
| 4 | 青囊公开知识包·胰腺癌 v0.1 | 基于 xyb-pi-agent 离线数据包（ChiCTR/CDE 登记整理）+ 社区指南要点摘录 | 免凭据，全本地 | 本地 RAG 语料；发行版随包分发 |
| 5 | MinerU（PDF 解析） | opendatalab 上游 或社区分支 mineru-tianshu（Apache-2.0，底层含 MinerU 组件待核） | 免凭据（本地推理；可选官方 API） | 报告单/指南 PDF → Markdown，喂给私有知识库。**以独立子进程调用，不进主进程依赖树** |
| 6 | 青囊技能层（全新编写） | 复用美学大脑/数学大脑/StarChart 结构规范（社区已 fork 此模式，习惯同构） | — | `INJECT.md` + `SKILL.md` + `references/pancreas/**`：意图路由、指标解读卡、试验名词表、医患沟通话术、免责红线 |
| 7 | 部署与体检脚本 | 参照 StarChart `deploy.sh --mode=source/--mode=agent` + `doctor.sh` | — | 一句话部署的执行体（幂等、可重复跑） |
| 8 | 提示词素材并入 | `PDAC-multi-agents-prompts`（Apache-2.0）+ `Genie-X-PAL-prompts-center`（⚠️补 license） | — | 零开发成本：清洗后并入 `references/` 知识层 |

### 5.2 P1 —— 二期增强

- **病历与指标管理线**：`maskdesk`（病历脱敏工作台，Apache-2.0）、`Medical-Record-Organizer`（病历整理 skill，⚠️补 license）、`ca199_toolbox`（CA19-9 追踪，AGPL-3.0 以独立工具隔离）、`aura_health_profile`（健康档案，MIT-0）。
- **知识包生产管线**：`nccn-guideline-downloader`（⚠️ 产出仅要点摘录）+ `RAG-content-processor` + `embedding-chunk-pre-processing` + `chinadrugtrials-collector` + `ctg-rag-genie`（中文化试验语料）。
- **试验检索增强**：`clinicaltrials-query-analysis`（检索+LLM分析）、`chictr-trials-collector`。
- **心理支持线**：`skill-HADS-accessment`（⚠️补 license + 量表版权核）。
- **经验库**：`get-biji-mcp` + `getnote-openclaw` skill（先补双仓库 LICENSE）。
- **知识包 v0.2**：NCCN/CSCO 指南要点结构化、化疗方案词汇表、副作用管理卡（社区医学志愿者流水线）。

### 5.3 P2 —— 后置

- `chictr-mcp-server`（unified-trial 的单通道前辈，作降级备份/上游参考）、`xiaoyibao-clinical-trials`（归档）。
- `dayi-search-mcp`（大医检索，⚠️补 license）、`dicom_download_mcp`（禁商用条款评估）、`little_green_card`（基因报告解读）、`openpancan`（基因洞察）、`xyb_dicom_download_skills`。
- 胰腺癌情报线：`pancreatic-cancer-dailynews-skill` + `osintel-pancrepal` 系（药讯板块素材管线）。
- PancrePal 主 RAG 平台的重量级能力（多轮对话记忆、在线服务端）——Desktop 版坚持本地轻量路线，不引入服务端依赖。
- 病种扩展：`qingnang-breast`（小粉宝）、`qingnang-gastric`、`qingnang-lung`（参照 RAG-xiaofeibao / xiaofubao / Lymphoma 先例）。

---

## 6. 外部依赖与 vendor 策略

### 6.1 vendor 方式决策表

| 依赖 | 方式 | 理由 |
|---|---|---|
| 社区 4 个 MCP（MIT，小仓库） | **git subtree**（或直接以 npm 依赖 + lockfile 锁版本） | 单仓自包含，终端用户 clone 一次拿全部；subtree 保留上游 pull 能力 |
| MinerU | **外部进程 + pip 独立 venv**，不 vendor 源码 | ①许可证隔离（见 6.2）②模型权重大（GB 级）不适合进 git ③部署脚本按需拉取 |
| deepseek-harness / DSH Desktop | **本包不涉及**。青囊只把自己做成 MCP 能力 + 技能层；宿主怎么装是宿主的事。未来若做 DSH 集成，另建仓库 | 避免把两个项目的进度绑在一起 |
| 公开知识包数据 | **GitHub Releases 分发**（大文件不进 git） | xyb-pi-agent 已用此模式（离线数据包 release），直接沿用；sha256 校验进 MANIFEST |

### 6.2 许可证合规矩阵（Phase 0 法务复核）

| 组件 | 许可证 | 发行版影响 | 处置 |
|---|---|---|---|
| 社区自研 MCP（unified-trial=MIT 确认） | MIT | 无 | 保留版权声明即可 |
| mcp-pubmed-server-pancrpal | repo=Apache-2.0 / npm=MIT ⚠️不一致 | 无（两者皆宽松） | Phase 0 统一口径后按 repo 为准 |
| MCP-KnowS-AI | repo 无 LICENSE（npm 声明 MIT）⚠️ | 存在法律瑕疵 | **vendor 前请 Sam 补 LICENSE 文件** |
| PancrePal 主仓库 | Apache-2.0 | 无（仅借鉴思路/语料，语料本身另看来源许可） | 登记来源 |
| xyb-pi-agent 离线数据包 | 仓库 LGPL-3.0（代码）；**数据部分许可需确认** | 数据再分发条款 Phase 0 与 Sam 确认 | Release 附数据来源清单（basis: community_owned 已是好基础） |
| maskdesk / clinicaltrials-query-analysis / nccn-guideline-downloader / RAG-content-processor | Apache-2.0 | 无 | 常规 |
| ca199_toolbox | AGPL-3.0 | 传染风险 | 以独立工具形态分发（不与青囊核心代码链接），或仅做接口对接 |
| deepseek-harness | MIT | 无 | — |
| DSH Desktop（未来项目） | MIT（已核实：`anywhere-labs/dsh-desktop`） | 本包不涉及 | 青囊不打包发行版；未来独立项目自行处理 |
| MinerU | **≤3.0.9 为 AGPL-3.0；≥3.1.0 为 MinerU 开源许可（Apache-2.0 + 附加条款，声明可商用）**；社区分支 mineru-tianshu 标 Apache-2.0 但底层含 MinerU 组件 | AGPL 传染风险 → 用「独立子进程 + 管道通信」隔离，并向用户明示该组件许可 | 锁定 4.x / tianshu 二选一 + 隔离调用 + 发行版第三方许可页列明 |
| NCCN 指南内容 | 工具 Apache-2.0，**指南全文有版权** | 全文再分发侵权风险 | 只做要点摘录 + 官方链接 + 患者版手册链接 |

---

## 7. 凭据与环境变量体系

### 7.1 `.env` 矩阵（随包分发 `.env.example`）

| 变量 | 所属组件 | 必填？ | 申请入口 | 缺失时行为 |
|---|---|---|---|---|
| `KNOWS_API_KEY` | knows-mcp | 选填 | KnowS 公众号/小程序 → 开发者 API 试用申请（教程+截图进 README） | KnowS 通道自动禁用，路由降级 PubMed |
| `KNOWS_API_BASE_URL` | knows-mcp | 与 KEY 成对 | 申请时随邮件下发 | 同上 |
| `NCBI_API_KEY` | pubmed-mcp | 选填 | https://www.ncbi.nlm.nih.gov/account/ | 限速 3 req/s（个人使用足够） |
| `MINERU_MODE` | mineru 管线 | 免填 | — | 默认 `local`；可选 `api` |
| `QINGNANG_HOME` | 数据目录 | 免填 | — | 默认 `~/.qingnang/` |
| `QINGNANG_TELEMETRY` | 遥测 | 免填 | — | 默认 `off`（唯一档位还有 `off` 😄） |

### 7.2 README 必答五件事（主人定的验收项）

部署文档必须让零基础用户一眼看到：

1. **环境变量文件在哪**：`qingnang/.env`（从 `.env.example` 复制），deploy.sh 第一次运行会自动生成并打开提示。
2. **哪些 MCP 填了才能用**：仅 KnowS（1 个）。
3. **哪些 MCP 不填也能用**：PubMed、unified-trial、本地知识库、get-biji（P1 起）——零凭据完整可用。
4. **怎么申请**：README「凭据申请」章节逐项给出申请入口、截图、预计等待时间（KnowS 走公众号/小程序试用额度）。
5. **填完怎么生效**：`node scripts/qingnang.mjs doctor` 一键体检，逐通道打 ✓/⬜/❌ 并给出修复提示。

### 7.3 降级链（路由层写死在 SKILL.md 铁律里）

```
医学证据类问题：KnowS（有凭据）→ PubMed（兜底）→ 本地知识包（离线兜底）
试验检索类问题：unified-trial（按病灶地区自动选 CT.gov / ChiCTR / 中国登记平台）
任何通道失败：明确告知用户「当前不可用」，绝不静默编造（never lie about what you did not find，
             沿用 unified-trial 的诚实哲学）
```

---

## 8. 一句话部署协议

### 8.1 部署咒语（用户复制给任意 Agent）

```text
请把青囊（QingNang）医学能力包部署到当前环境：
1) git clone https://github.com/PancrePal-xiaoyibao/qingnang.git && cd qingnang
2) node scripts/qingnang.mjs fetch                 # 在本项目内构建依赖环境（含 7 个 MCP）
3) node scripts/qingnang.mjs deploy --mode=source  # 探测本机 + 建私有目录
4) node scripts/qingnang.mjs deploy --mode=agent   # 把注入层+技能层装到你自己（宿主）
5) node scripts/qingnang.mjs doctor                # 逐通道体检，把结果贴回来
环境变量只影响增强通道：先跑 doctor，缺什么它会用中文告诉你去 README 哪一节申请。
遇到报错按提示处理，不要跳过任何一步。
```

> 该协议直接复用 StarChart 已验证的两步部署 + 幂等脚本 + 版本锁模式（实测低配 NAS 可跑），青囊是它的医学版翻版。

### 8.2 部署后自检（doctor.sh 输出规范）

- 逐项：Python/Node 版本 → 4 个 MCP 握手 → 本地索引存在性 → 凭据矩阵（✅已配/⬜选填未配/❌错误）→ 数据包 hash 校验。
- 最后一屏输出「你现在可以对 Agent 说的话」示例 3 条（查文献 / 找试验 / 解读报告单），让用户立刻见效。

---

## 9. 与 DeepSeek Harness 的关系（未来独立项目，本包不涉及）

> **定位澄清（2026-10-14）**：DSH 相关的一切都在**另一个项目**里。本包（青囊）只做社区医学资产打包与分发。DSH 集成若要做，届时另建仓库、另写文档。

### 9.1 本包对 DSH 的立场

青囊只是一个 MCP + 技能层资产包。**任何支持 MCP 的宿主都能装青囊**，DSH 是其中一个候选，不是依赖。

包内**不写**任何宿主专属逻辑；宿主适配属宿主侧的事。

### 9.2 如果未来做 DSH 集成，需要知道的事实（实测于 2026-10-14）

| 项 | 事实 |
|---|---|
| 社区主流桌面端 | **`anywhere-labs/dsh-desktop`**（MIT，30,780★，1436 fork，日更） |
| DSH 插件形态 | **Cordis TS 插件**（`export const name` / `export const inject` / `export function apply(ctx)`），**没有 `SKILL.md` 技能目录惯例** |
| DSH 的 MCP 配置 | 结构化 `StdioConfig`（字段：`transport`/`serverName`/`command`/`args`/`env`/`cwd`/`toolCallTimeoutMs`/`failOnStartupError`/`reconnect?`）；`serverName` 须匹配 `[A-Za-z0-9_-]{1,32}` |
| `dsh-community-fabric` | 其 manifest/capability/统一事件模型仍是 **RFC Draft**，官方明写「尚不能作为依赖或发布目标」 |

**结论**：DSH 集成不是「拷个 SKILL.md 目录」那么简单。它需要写一个真正的 Cordis 插件包，或至少按 `StdioConfig` 写 MCP 配置 + 另作指令注入。这是一个**独立工作量**，所以单独立项。

---

## 10. 数据嵌入策略

### 10.1 公开知识包（随发行版分发）

| 内容 | 来源 | 许可处置 |
|---|---|---|
| 胰腺癌临床试验登记数据 v0.1 | xyb-pi-agent Release「离线数据包 2026-10-06」（ChiCTR/CDE 公开登记，community_owned） | Phase 0 与数据小组确认再分发条款；Release 附来源清单 |
| 诊疗知识卡（分期/术式/化疗方案/指标） | 社区医学志愿者编写 + 指南要点摘录（CC BY-SA 4.0 统一授权） | 每张卡带来源与审校者字段 |
| 术语表（中英对照） | 社区沉淀 | CC BY-SA 4.0 |

**形态**：结构化 Markdown + 预建本地索引（sqlite FTS5 起步，向量层可选），GitHub Releases 分发 + sha256 入 MANIFEST。目标体积 ≤500MB（含索引），低配电脑可跑。

### 10.2 用户私有数据（永不出机）

```
~/.qingnang/private/
  ├── reports/        # 报告单原件（PDF/图片）
  ├── extracted/      # MinerU 解析后的 Markdown
  ├── profile/        # 病情档案（用户或 Agent 对话生成，本地明文，后续可选加密）
  └── history.db      # 检索与对话历史
```

- 本地 RAG 检索 = 公开知识包索引 ∪ 私有索引，回答时**区分标注**「来自公开知识 / 来自你的资料」。
- 铁律进注入层：任何导出/分享/遥测路径不得触碰 `private/`；用户主动要求"分享给医生"时才生成脱敏摘要文件。

### 10.3 MinerU 解析管线

报告单/出院小结 PDF → MinerU（独立子进程）→ Markdown → 私有索引。指标数值另走正则抽取（血常规/肿瘤标志物/肝肾功能）→ 结构化存 `profile/`，供「指标解读卡」比对参考区间。**抽取结果只做趋势呈现，不做诊断结论。**

---

## 11. 分阶段开发计划

> 原则：每阶段有可运行产出 + 验收标准（AC）；后端 Agent 可按 §14 命令自行推进。

### Phase 0 · 资产盘点冻结（1-3 天，盘点已完成 80%）
- ✅ 两组织全量盘点完成（137 仓库 → `ASSET_INVENTORY_20261014.md`，P0/P1/P2/OBS/⛔ 已定向）。
- 剩余：向 Sam/数据小组确认离线数据包再分发条款、推动补 LICENSE（KnowS-AI/get-biji/HADS 等）、knows 凭据申请流程文档化。
- **AC**：许可证债清单清零或挂书面结论，盘点冻结表定稿。

### Phase 1 · 青囊包骨架（第 1 周）
- 建 `qingnang` 仓库：目录骨架、MANIFEST、`.env.example`、deploy.sh（source/agent 两模式，幂等）、doctor.sh。
- 写 INJECT.md + SKILL.md v0（路由表先通 pubmed + unified-trial 两条免费通道）。
- **AC**：新容器一句话部署后，doctor 全绿（无凭据档），能完成一次 PubMed 检索 + 一次试验检索。

### Phase 2 · MCP 全接入 + 降级链（第 2 周）
- subtree/npm 引入 4 个 MCP；统一健康检查；KnowS 凭据增强 + 自动降级链；路由铁律写入 SKILL.md。
- **AC**：有/无凭据两种状态下 doctor 与端到端问答均符合 §7.3 降级预期。

### Phase 3 · 胰腺癌知识包 v0.1 + 本地 RAG（第 3 周）
- 离线数据包 v0.1 引入 + 预建索引；MinerU 子进程管线 + 指标抽取；私有目录隔离与 .gitignore 加固。
- **AC**：断网状态下，病种知识问答可用；上传一份报告单 PDF → 解析入库 → 指标被抽出；`private/` 外无任何数据残留。

### Phase 4 · 公开发布守门（第 4 周）
- PR 敏感信息闸三道（pre-commit / CI / AI 复审）；README 面向**社区用户**（零技术语言 + §7.2 五件事 + §8.1 一键部署咒语）。
- **AC**：干净环境按 README 部署咒语一次跑通，doctor 全绿。

> **DSH 桌面发行版不在本计划内**——那是未来独立项目（§2.4 / §9）。本包的终点是「社区用户能一句话装上并用起来」。

### Phase 5 · 公开发布 + 病种扩展模板（第 6 周起）
- 发布 v0.1（GitHub + 社区渠道）；沉淀《病种子包制作手册》，启动 `qingnang-breast`（小粉宝）试点。

---

## 12. 社区治理与合规

### 12.1 PR 敏感信息自动审查（主人点名的刚需）

**三道闸**：
1. **pre-commit**（贡献者本地）：gitleaks（密钥/凭据）+ 自定义 PHI/PII 正则（身份证、手机号、住院号、患者姓名+诊断组合、报告单图片 EXIF）。
2. **CI 必过**（GitHub Actions）：同套规则跑全量 diff；命中即红，给出「为什么这算敏感 + 怎么改」的中文说明。
3. **AI 复审**（规则漏网兜底）：PR 触发轻量 LLM 审查——专查「看似脱敏实可反推」的组合（ rare 病+日期+医院三件套）；结论只挂 label 不阻塞，人工复核。

**配套**：`CONTRIBUTING.md` 红线章节（禁止提交真实患者数据/影像/报告单原件；演示数据一律走 `data/synthetic/` 造数脚本）；PR 模板内置「本 PR 不含任何真实患者信息」勾选项。

### 12.2 医疗免责（写进三处）

发行版首次启动强制展示一次；SKILL.md 红线区；每条涉及诊疗的回答末尾自动附「以上为信息整理，不构成医疗建议，请以主治医生意见为准」。注入层明令：不做诊断结论、不做用药剂量建议、遇急症表述立即引导就医。

### 12.3 社区引导

- 「你的经验值得进青囊」：病友经验 → get-biji 知识库的贡献流水线（PR 模板 + 脱敏自查清单 + AI 审查兜底）。
- good first issue 打标：知识卡编写、术语翻译、FAQ 整理等非编码贡献入口（110+ 生态成员的主要参与面）。

---

## 13. 风险与待决问题

| # | 风险 | 等级 | 对策 |
|---|---|---|---|
| 1 | MinerU 许可证历史复杂（AGPL→自定义） | 中 | 独立子进程隔离 + 锁 4.x + 发行版第三方许可页；Phase 0 法务复核 |
| 2 | 离线数据包再分发条款未书面确认 | 中 | Phase 0 与 Sam/数据小组书面确认后装载 |
| 3 | 本包需覆盖多种宿主（Claude Code / OpenClaw / Codex 等），各宿主 skills 约定不同 | 中 | 架构已宿主无关；一句话部署脚本按宿主分派（`--host=<h>`） |
| 4 | knows 凭据申请门槛影响体验 | 低 | 降级链保证零凭据可用；申请教程进 README |
| 5 | get-biji 双仓库、MCP-KnowS-AI、HADS 等多个仓库无 LICENSE | 低 | P1 前由社区补齐（已列许可证债清单），否则不 vendor |
| 6 | NCCN 指南全文版权（工具开源≠内容可再分发） | 中 | 只做要点摘录+官方链接；患者版手册用官方渠道链接 |
| 7 | 医疗信息质量责任 | 高(常态) | 出处强制标注 + 免责三处 + 知识卡审校人制度 + 不做诊断铁律 |
| 8 | 病友数据隐私（PIPL） | 高(常态) | §3.2 三条隐私边界 + §12.1 三道闸 + 遥测默认关 |

---

## 14. 附录

### 14.1 链接总表（后端 Agent 直接用）

```text
# 社区组织
https://github.com/PancrePal-xiaoyibao
https://github.com/opencare-skillhub

# 社区仓库（P0/P1 核心，全量见 ASSET_INVENTORY_20261014.md）
https://github.com/PancrePal-xiaoyibao/PancrePal-xiaoyibao          # RAG平台 Apache-2.0
https://github.com/PancrePal-xiaoyibao/xyb-pi-agent                 # PI桌面 LGPL-3.0 + 离线数据包Releases
https://github.com/PancrePal-xiaoyibao/mcp-pubmed-server-pancrpal   # PubMed MCP (npm: mcp-pubmed-llm-server) repo=Apache-2.0
https://github.com/PancrePal-xiaoyibao/MCP-KnowS-AI                 # KnowS MCP (npm: @xiaoyibao_npm/knows-mcp-server) ⚠️repo待补LICENSE
https://github.com/opencare-skillhub/unified-trial-search-mcp-service # 统一试验检索 (npm: unified-trial-mcp) MIT
https://github.com/PancrePal-xiaoyibao/PDAC-multi-agents-prompts    # PDAC提示词集 Apache-2.0
https://github.com/PancrePal-xiaoyibao/maskdesk                     # 病历脱敏工作台 Apache-2.0
https://github.com/PancrePal-xiaoyibao/ca199_toolbox_donated_by_lihb # CA19-9工具箱 AGPL-3.0
https://github.com/opencare-skillhub/nccn-guideline-downloader      # NCCN指南下载 Apache-2.0（内容版权注意）
https://github.com/opencare-skillhub/clinicaltrials-query-analysis  # 试验检索+LLM分析 Apache-2.0
https://github.com/opencare-skillhub/Medical-Record-Organizer       # 病历整理skill ⚠️待补LICENSE
https://github.com/opencare-skillhub/skill-HADS-accessment          # HADS心理评估 ⚠️待补LICENSE
https://github.com/opencare-skillhub/aura_health_profile            # 健康档案skill MIT-0
https://github.com/opencare-skillhub/RAG-content-processor          # 知识包生产线 Apache-2.0
https://github.com/PancrePal-xiaoyibao/chictr-mcp-server            # ChiCTR MCP Apache-2.0
https://github.com/PancrePal-xiaoyibao/get-biji-dev-by-gemini3pro   # Get笔记MCP ⚠️待补LICENSE
https://github.com/PancrePal-xiaoyibao/get_biji_mcp                 # Get笔记MCP·TS版 ⚠️待补LICENSE
https://github.com/opencare-skillhub/getnote-openclaw               # Get笔记Skill MIT
https://github.com/PancrePal-xiaoyibao/MinerU-xyb                   # 社区MinerU分支 AGPL-3.0
https://github.com/PancrePal-xiaoyibao/mineru-tianshu               # 天枢PDF→MD+MCP Apache-2.0(FORK,底层许可待核)
https://github.com/PancrePal-xiaoyibao/xiaoyibao-clinical-trials-mcp-server # 早期CT.gov MCP MIT
https://github.com/opencare-skillhub/chictr-trials-collector        # ChiCTR提取匹配skill Apache-2.0
https://github.com/opencare-skillhub/clinicaltrials-intel-skill     # 试验情报skill Apache-2.0
https://github.com/PancrePal-xiaoyibao/RAG-xiaofeibao-Lungcancer    # 小肺宝·肺癌RAG（病种扩展参照）Apache-2.0
https://github.com/PancrePal-xiaoyibao/xiaofubao                    # 小腹宝·妇科肿瘤RAG（参照）
https://github.com/PancrePal-xiaoyibao/Lymphoma_AI_assistant_xiaoyibao # 小铃铛·淋巴瘤（参照）
https://github.com/PancrePal-xiaoyibao/xiaoxuebao_AI_Project        # 小雪宝·儿童（参照）

# 外部依赖
https://github.com/deepseek-ai/deepseek-harness                     # DSH官方内核 MIT（未来项目参考）
https://github.com/anywhere-labs/dsh-desktop                        # DSH Desktop 社区主流桌面端 MIT（未来项目参考）
https://github.com/ahamoment-101/Open-DeepSeek-Harness-Desktop      # 第三方macOS版（P2评估）
https://github.com/opendatalab/MinerU                               # PDF解析 ⚠️许可注意（§6.2）
https://github.com/opendatalab/MinerU-Document-Explorer             # 文档知识引擎MCP（P1评估）
# 备选参照（不 vendor，仅借鉴）
https://github.com/cyanheads/clinicaltrialsgov-mcp-server           # 患者-试验匹配功能可借鉴
https://github.com/JackKuo666/PubMed-MCP-Server
```

### 14.2 Phase 0 盘点命令（✅ 已于 2026-10-14 执行完成，137 仓库入库）

```bash
gh api "orgs/PancrePal-xiaoyibao/repos?per_page=100" --jq '.[] | [.name,.description,.license.spdx_id,.stargazers_count,.pushed_at,.html_url] | @tsv'
gh api "orgs/opencare-skillhub/repos?per_page=100" --jq '.[] | [.name,.description,.license.spdx_id,.stargazers_count,.pushed_at,.html_url] | @tsv'
# 数据包核对
gh release view xyb-corpus-2026-10-06 -R PancrePal-xiaoyibao/xyb-pi-agent
```

### 14.3 定稿决议与 Phase 0 待办（2026-10-14）

**已决议**：
1. ✅ **名字**：青囊 QingNang（主人拍板，§2 生效）。
2. ✅ **仓库落点**：`PancrePal-xiaoyibao/qingnang`（唯一仓库）。落小胰宝社区 org，公益开源，不设迁移计划。
3. ✅ **架构/MVP 清单/阶段计划**：按本 v1.0 定稿执行。

**Phase 0 剩余待办（可并行推进）**：
1. ⏳ 主人在 GitHub 新建 `qingnang` 仓库 → 把地址发小虾，即刻开搭 Phase 1 骨架（目录/MANIFEST/deploy.sh/doctor.sh/SKILL.md v0）。
2. ⏳ 主人引荐小虾 ↔ Sam：离线数据包再分发条款、补 LICENSE（KnowS-AI / get-biji / HADS 等）、knows 凭据申请流程文档化。
3. ⏳ 主人引荐小虾 ↔ Sam：离线数据包再分发条款、补 LICENSE（KnowS-AI / get-biji / HADS 等）、knows 凭据申请流程文档化。

> **DSH 集成相关的一切**已从本档移出（见 §2.4 / §9）：那是未来独立项目，不在青囊范围。

---

*青囊 · 2026-10-14 定稿 ✅ 命名已定、盘点已清、架构已立——仓库地址一到，Phase 1 立刻开工 🦞*
