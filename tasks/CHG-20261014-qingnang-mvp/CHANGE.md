---
change_id: CHG-20261014-qingnang-mvp
title: 青囊 QingNang 社区医学能力包 —— MVP v0.1 立项（Phase 1–2 骨架 + 双免费通道打通）
status: draft
created_at: 2026-10-14
updated_at: 2026-10-14
priority: P0
owner: 主人（产品/命名/落点决策）+ AI Agent（实现）
prd_ref: PRD.md（v1.0 draft 已产出，待批准）
health_ref: null（全新空仓库，无历史债基线可审）
source_docs:
  - docs/QingNang_Community_Asset_Pack_Architecture_and_DevPlan_v1.0_20261014.md
  - docs/ASSET_INVENTORY_20261014.md
reference_project: Development/Starchart（deploy.sh / doctor 模式源头）
standing_authorization: false
---

# Change Brief：青囊 QingNang —— 从「架构定稿」到「可跑骨架」

> **本轮性质**：**立项讨论 + 契约固化**，不是实现。
> **产出**：CHANGE（本文）+ SPEC（工程契约草案）+ TRACEABILITY（追溯草案）。
> **不产出**：任何代码、任何 commit。仓库当前 `no commits yet`，工作区只有 `docs/` 未跟踪。

---

## 0. 结论先行（三句话）

1. **项目本身没有问题**：v1.0 文档把愿景、五条铁律、四层架构、137 仓库盘点、许可证债、六阶段计划都写清楚了，质量很高，**不需要推翻重做**。
2. **真正卡住的是三件事**：① 缺 PRD（谁用、成功长什么样没定）；② 有 4 项**外部依赖没落定**（离线数据包再分发条款、DSH 发行版许可、KnowS 补 LICENSE、DSH 团队接口）；③ 有一座**命名/落点的桥**没搭（文档说 `qingnang` 落社区 org，但 DSH 联合维护与官方展示位可能要求中性品牌）。
3. **建议的下一步**：**先做不依赖外部的那半（Phase 1 + Phase 2）**——仓库骨架 + deploy/doctor + 两条免费通道（PubMed / unified-trial）打通。这一半**零凭据、零外部许可依赖、可独立验收**，且是后面所有阶段的地基。有依赖的那半（KnowS、MinerU、知识包、DSH 发行版）等条款落地再上。

---

## 1. 需求辨析：字面 vs 目的

| 层 | 内容 |
|---|---|
| **字面需求** | 「看下里面的文档，我们把这个项目的架构和实施方案讨论一下，做一个 CHG 立项」 |
| **字面背后的目的** | 仓库刚建、还没 commit，主人要的是**一个可以立刻开工的、经过思考的工程契约**，而不是又一次架构综述。文档已经很全，再综述一遍等于零产出。 |
| **本轮真实要交付的** | ① 找出文档里**没说清/没落定**的东西；② 把可执行部分（目录、脚本契约、验收命令）**固化成契约**；③ 把阻塞项**变成一张清单**让主人做选择题；④ 给出**这一步都不做也能继续的路线**。 |
| **产出价值判断** | 合格产出 = 「结论 + 依据 + 可执行下一步」。不合格产出 = 「文档总结 + 问主人怎么办」。 |

---

## 2. 已核实的环境事实（本轮实测，非文档转述）

### 2.1 仓库与本地环境

| 项 | 实测值 | 证据 |
|---|---|---|
| 仓库 | `PancrePal-xiaoyibao/QingNang`，**PRIVATE**，**isEmpty=true** | `gh repo view` |
| 建仓时间 | 2026-10-14T10:26:58Z | 同上 |
| 本地路径 | `~/Development/QingNang`（仓库根） | — |
| Git 状态 | `No commits yet on main`，`origin/main [gone]`，**0 个 commit** | `git status -sb` |
| 未跟踪文件 | `docs/`（2 份文档）、`.ipynb_checkpoints/`（空目录） | `ls -la` |
| 远程 | `https://github.com/PancrePal-xiaoyibao/QingNang`（HTTPS） | `git remote -v` |
| gh 登录 | 已登录，scopes 含 `repo` + `workflow` | `gh auth status` |

> **注意**：`origin/main [gone]` = 远端还没有 main 分支（空仓库）。首次 push 即可建立。
> **注意**：本机 git 署名**与社区 org 品牌不一致**（具体值见本机 `git config user.name/email`，**不写入仓库文档**）。若以社区名义提交，建议确认是否换用社区署名。

### 2.2 上游依赖实况（核对文档清单，逐条实测）

| 资产 | 文档声明 | 实测结果 | 判定 |
|---|---|---|---|
| `mcp-pubmed-server-pancrpal` | repo=Apache-2.0 / npm=MIT 不一致 | repo=**Apache-2.0**，★11，最后推送 2026-05-10；npm `mcp-pubmed-llm-server@3.0.0` license=**MIT** | ⚠️ **不一致属实**，需统一口径（不影响可用性，两者皆宽松） |
| `unified-trial-search-mcp-service` | MIT，2026-10-06 发版 | repo=**MIT**，npm `unified-trial-mcp@0.3.1` license=**MIT** | ✅ **唯一许可完全干净的通道**，可优先 vendor |
| `MCP-KnowS-AI` | repo 无 LICENSE（npm 声明 MIT） | repo license=**NONE**，★0 | ❌ **许可瑕疵确认**，Phase 2 前必须补 |
| `PDAC-multi-agents-prompts` | Apache-2.0 | repo=**Apache-2.0** | ✅ 可直接并入 references |
| `get-biji-mcp`（npm） | 两仓库均无 LICENSE | npm `get-biji-mcp@0.1.1` license=**MIT**（repo 仍无文件） | ⚠️ npm 声明可用，repo 需补 |
| xyb-pi-agent 离线数据包 | Release，ChiCTR/CDE 整理 | release `xyb-corpus-2026-10-06`，**4 个资产共约 12MB**：`cde_pancreatic.tar.gz`(1MB) / `chictr_pancreatic.tar.gz`(0MB) / `ictrp_pancreatic_cancer.tar.gz`(1MB) / `veeva_ctv.tar.gz`(10MB) | ✅ **体积远小于文档预期的 500MB 知识包上限**，本地 RAG 完全可行；⚠️ 再分发条款仍未书面确认 |

> **体积修正**：文档 §10.1 写「目标体积 ≤500MB」。实测离线数据包仅 **~12MB**（未压缩原始 tar.gz）。这是好消息——Phase 3 本地 RAG 的成本比预期低一个数量级，**建议把目标体积从 500MB 收紧到 150MB**（含索引 + 知识卡）。

### 2.3 参考实现（Starchart，文档指定为脚本模式源头）

文档 §8 说「复用 StarChart 已验证的两步部署模式」。实测确认其确存在且成形：

| 项 | 实测值 |
|---|---|
| 部署脚本 | `Development/Starchart/scripts/deploy.sh`（306 行，模块化：`step_env`/`step_deps`/`step_data`/`step_health`/`step_index`/`step_skill_layers`/`step_skill_install`…） |
| 任务契约 | `Development/Starchart/tasks/CHG-2026100*/{CHANGE,SPEC,TRACEABILITY}.md` 三件套，结构完整（CHANGE 205 行 / SPEC 313 行 / TRACE 171 行） |
| 验证脚本 | `scripts/check.sh`（ruff + 对齐审计 + pytest）、`tests/acceptance/`（含 `test_deploy.py`） |

**结论**：青囊的 `deploy.sh` / `doctor.sh` / `tasks/` 契约**直接沿用 Starchart 已跑通的形态**，不重新设计。这是文档 §8 的承诺，本轮把它固化为 SPEC 契约。

### 2.4 缺口

| 项 | 状态 |
|---|---|
| `gitleaks`（文档 §12.1 三道闸的第一道） | **未安装** → Phase 4 前需部署 |
| `tasks/` 目录 | 本轮新建（此前不存在） |
| PRD | **不存在** → 阻塞项 B1 |
| 青囊自身 codebase 索引 | 未索引（空仓库，无代码可索引，符合预期） |

---

## 3. 定位与品牌（ADR-001，已由主人拍板关闭）

### 3.1 主人的定位澄清（2026-10-14，最终口径）

> 「品牌这块，这个项目仅仅是**社区资产打包**，所以品牌就写**小胰宝**，不用纠结别的。DSH 是未来下一步的事情，也许会新建新的仓库。这个项目的定位，就是**社区医学资产的打包**，所以叫青囊。」

拆成四条硬约束：

| # | 约束 | 含义 |
|---|---|---|
| **P1** | **本项目 = 社区医学资产打包** | 只做「把已验证的社区能力装成一只可移植的包」，不做宿主适配、不做发行版、不做应用层 |
| **P2** | **品牌 = 小胰宝** | 不讨论中立品牌、不预留迁移姿势（那样反而模糊品牌） |
| **P3** | **DSH 集成 = 未来独立项目** | 可能另建仓库。本包内**不写任何 DSH 专属逻辑**，不列 DSH 为交付端 |
| **P4** | **命名 = 青囊 QingNang** | 包名（资产包叫青囊），与社区品牌（小胰宝）互为表里 |

### 3.2 ADR-001 · 仓库落点与品牌（已关闭）

| 项 | 内容 |
|---|---|
| **决策** | 仓库落 `PancrePal-xiaoyibao/QingNang`；**品牌 = 小胰宝**；**不迁移、不再讨论迁移** |
| **被否方案** | ① 另建中立 org（无必要——本项目就是小胰宝社区资产，中立化会模糊品牌） ② 「社区 org + 中立包结构」（原 C 方案，过度设计：中立结构是为未确定的未来买保险，而未来已明确是独立项目） |
| **理由** | 品牌即定位。本项目是小胰宝社区的资产包，品牌就该是小胰宝。过度中立化会同时得罪两边：社区觉得你不愿认名，外部宿主觉得你不够中立 |
| **可逆性** | 不适用（决策已关闭） |
| **后果** | SPEC §0.3 的「品牌中立约束」**作废**，替换为「**品牌清晰约束**」：包内以「小胰宝社区 · 青囊」署名，不模糊 |

### 3.3 ADR-006 · DSH 集成边界（已关闭）

| 项 | 内容 |
|---|---|
| **决策** | **DSH 集成不在本包范围**。本包交付物中**不包含** DSH 适配代码、不包含 `--host=dsh` 的实现承诺 |
| **理由** | DSH 插件是 Cordis TS 插件（需写 npm 包），MCP 走结构化 `StdioConfig`，**无 `SKILL.md` 目录惯例**。这是一个独立的工作量，与「资产打包」不是一个关注点 |
| **后果** | ① `deploy.sh` 的宿主列表**移除 DSH**；② 齐头并进核对从五端降为**四端**；③ SPEC §4.8 从「DSH 接入契约」降级为「与 DSH 的边界声明 + 实测事实存档（给未来那个项目用）」 |
| **存档价值** | 本轮实测的 DSH 事实（仓库地址、许可证、插件形态、`StdioConfig` 字段）写入 SPEC §4.8，**专供未来 DSH 项目复用** |

### 3.4 ADR-007 · 搜索工具集与 search runtime（2026-10-14 主人要求纳入）

| 项 | 内容 |
|---|---|
| **决策** | ① 搜索 MCP 从 2 个扩到 **6 个**：新增 `open-websearch`、`bing-cn-mcp`、`openalex-mcp-server`；② 建立 **search runtime 注入层**（`SEARCH_RUNTIME.md`），主注入只给薄提示引导，具体选工具在 runtime 里定 |
| **被否方案** | ① 把所有搜索工具直接写进主注入文档（常驻上下文膨胀，且每加一个工具就要改主注入） ② 主注入不提搜索（Agent 不知道有这套分流体系） |
| **理由** | ① 青囊最常被用到的是搜索，**用错通道比搜不到更危险**；② 主注入要薄（常驻上下文），所以只给「去找 search runtime」这一层引导；③ 具体工具表放独立文件，按需加载 |
| **可逆性** | 高（新增/移除通道只需改 `SEARCH_RUNTIME.md` + manifest，不动主注入） |
| **后果** | 新增冻结契约：`SEARCH_RUNTIME.md`（≤8KB）；主注入新增一条「涉搜索先读 search runtime」；`INJECT.md` 体积上限不变（≤2KB） |

### 3.5 六条搜索通道分工（冻结）

| # | 通道 | MCP 包 | 许可 | 凭据 | 适用问题信号 |
|---|---|---|---|---|---|
| 1 | 通用网页搜索 | `open-websearch` | Apache-2.0（本机已验证 LICENSE 文件） | 免 | 一般资讯、最新动态、名词解释 |
| 2 | 中文网页搜索 | `bing-cn-mcp` | MIT | 免 | 中文内容、国内政策/指南、公众号文章 |
| 3 | 学术文献 | `mcp-pubmed-llm-server` + `openalex-mcp-server` | MIT + ISC | 免（OpenAlex 可选邮箱提速） | 论文、机制、指南出处 |
| 4 | 临床试验 | `unified-trial-mcp` | MIT | 免 | 在招试验、入组标准、中美双登记 |
| 5 | 高级医学证据 | `@xiaoyibao_npm/knows-mcp-server` | ⚠️ repo 待补 | **需凭据** | 循证医学证据、指南结构化摘要 |
| 6 | 病友经验 | `get-biji-mcp` | ⚠️ repo 待补 | 免 | 病友经验、实操细节（Phase 2+） |

> **许可白名单需扩容为 `{MIT, Apache-2.0, ISC, BSD-3-Clause}`**——ISC 与 MIT 实质等同（OpenAlex 用 ISC），需显式加入并注明理由。

### 3.6 附带小项

- 仓库名实际为 `QingNang`，文档全篇写 `qingnang`。建议在 GitHub 设置里改为小写 `qingnang`（与 `QINGNANG_*` 环境变量、`~/.qingnang/` 目录、npm scope 口径统一，GitHub 访问不区分大小写）。
- 首次 commit 前确认 git 署名（本机全局配置 vs 社区身份；**署名值不在本仓库文档内记录**）。

---

## 4. 范围（Scope）

### 4.1 本 CHG 覆盖：Phase 1 + Phase 2 的**可独立验收部分**

| # | 模块 | 交付物 | 验收锚点 |
|---|---|---|---|
| **M1** | 仓库骨架 | 目录结构、`MANIFEST.json`、`.env.example`、`.gitignore`（含 `private/` 加固）、`LICENSE`、`README.md`、`CONTRIBUTING.md`、PR 模板 | A1–A3 |
| **M2** | 部署与体检 | `scripts/deploy.sh`（`--mode=source` / `--mode=agent`，幂等）、`scripts/doctor.sh`（逐通道 ✅/⬜/❌） | A4–A6 |
| **M3** | 技能层 v0 | `INJECT.md`（≤2KB）+ `SKILL.md`（≤14KB）+ `references/pancreas/` 首批知识卡（由 Apache-2.0 的 PDAC 提示词资产清洗而来） | A7–A9 |
| **M4** | 双免费通道 | vendor/依赖 `unified-trial-mcp`（MIT，最干净）+ `mcp-pubmed-llm-server`（Apache-2.0）+ 统一 MCP 健康检查 | A10–A12 |
| **M5** | 降级链与铁律 | SKILL.md 路由表写死降级链（KnowS 未配 → PubMed 兜底）、无凭据档端到端问答可跑 | A13–A15 |
| **M6** | PR 敏感信息闸（第一道） | `pre-commit` + gitleaks 配置 + PHI/PII 中文正则规则集 | A16–A17 |

### 4.2 明确不含（本 CHG Non-Goals）

1. ❌ **不 vendor KnowS／get-biji／MinerU／HADS**——许可债未清（B2）或形态未定（MinerU 隔离方案）之前不动。
2. ❌ **不做离线数据包装载与本地 RAG**（Phase 3）——等再分发条款书面确认（B3）。
3. ❌ **不做 DSH Desktop 发行版流水线**（Phase 4）——等发行版许可确认 + DSH 团队接口确认（B4/B5）。
4. ❌ **不写代码先于 PRD 批准**（B1）。
5. ❌ **不建 `qingnang-desktop` 仓库**（等 B4/B5）。
6. ❌ **不引入服务端/云依赖**——坚持「本地轻量、零凭据可跑」，与文档 §1.3 铁律 2 一致。
7. ❌ **不做病种扩展**（`qingnang-breast` 等，Phase 5）。
8. ❌ **本 CHG 不含任何 commit / push 授权**——commit 与 push 是独立 Gate。

---

## 5. 待主人决策的问题清单

### 5.1 阻塞项（不解决就无法推进对应阶段）

| # | 问题 | 阻塞什么 | 谁决定 | 建议 |
|---|---|---|---|---|
| ~~**B1**~~ | ~~PRD 缺失~~ | ✅ **已解决** | — | **`PRD.md` v1.0 draft 已产出**（含用户 U1–U3 / 场景 A–F / 目标 G1–G7 / 硬指标 M1–M8 / 12 条用户故事 / 5 条边界故事）。**仅差主人批准**。 |
| **B2** | **许可证债**：KnowS（NONE）、get-biji 双仓（NONE）、HADS（NONE）、Medical-Record-Organizer（NONE） | Phase 2 的 KnowS 通道、Phase 3 的经验库 | 社区（Sam） | 建议**先只上 MIT 的 unified-trial + Apache-2.0 的 pubmed**，把许可债清完再逐步纳入。**不因等待而停工**。 |
| **B3** | **离线数据包再分发条款**未书面确认（`xyb-corpus-2026-10-06`，~12MB，包含 veeva_ctv 10MB 来自第三方？） | Phase 3 知识包 | 主人引荐 ↔ Sam/数据小组 | `veeva_ctv.tar.gz`（10MB）**来源需单独确认**——Veeva 是商业临床数据平台，这一项的再分发权最可疑。建议**先只装 ChiCTR/CDE/ICTRP 三个官方登记来源（共 ~2MB）**，veeva 部分挂起。 |

### 5.2 非阻塞项（可并行、可后置）

| # | 问题 | 建议 |
|---|---|---|
| ~~**D1**~~ | ~~落点：社区 org vs 中立品牌~~ | ✅ **已决策**（§3.2）：落社区 org，不再迁移 |
| **D2** | DSH Desktop 仓库许可 | ✅ **已核实**：社区主流桌面端是 `anywhere-labs/dsh-desktop`，**MIT**（30,780★，日更）。母文档写的 `ningbainb/deepseek-harness-desktop` 是**另一个项目**（BSD-3-Clause，812★）。按官方惯例直接写即可，**无需许可谈判** |
| **D3** | DSH 集成接口 | ⚠️ **已核实关键事实**：DSH 的插件是 **Cordis TS 插件**（`export function apply(ctx)`），**没有 `SKILL.md` 技能目录惯例**；MCP 走结构化 `StdioConfig`。详见 SPEC §3.4 / §4.8。仍建议向 anywhere-labs 确认长期兼容性 |
| **D4** | KnowS 凭据申请门槛（公众号/小程序试用额度） | Phase 2 的 README「凭据申请」章节，实测申请流程后写 |
| **D5** | 仓库改名 `QingNang` → `qingnang`；git 署名 | 首次 commit 前顺手做 |
| **D6** | 知识包体积目标 500MB → 建议收紧至 150MB（实测数据仅 12MB） | SPEC 里改掉 |
| **D7** | MinerU 隔离方案（AGPL 子进程 + 许可页） | Phase 3 前定；不影响 Phase 1–2 |

### 5.3 主人已决策（2026-10-14，本轮）

| # | 决策 | 落地影响 |
|---|---|---|
| **K1** | **目标用户 = 社区用户**；交付形态 = **有仓库 + 提示词一键部署**；最终**开源** | PRD 定位确立；README 的「一键部署」段落升为**首要交付物**（SPEC §4.7 冻结契约） |
| **K2** | **定位 = 社区医学资产打包**；品牌 = **小胰宝**；不纠结中立 | §3.1 P1/P2；ADR-001 关闭；母文档 §2.1/§3.1 表述已修正 |
| **K3** | **凭据策略：先 dryrun 打通链路**，实际部署时用户自己填 `.env` | 验收锚点从「凭据 live 可用」改为「无凭据链路可跑 + 有凭据时路由正确」；`--dry-run` 成为 `deploy.sh` 必备能力（SPEC §5M2/M5） |
| **K4** | **外部依赖分发条款 / 发行版许可：按官方与通用惯例先写** | 分发条款按 MIT/Apache-2.0/ISC 通用要求写（保留版权声明 + NOTICE）；**不因等待许可谈判而停工** |
| **K5** | **定位 = 公益开源；三个把关点：① 医学伦理 ② 数据安全 ③ 社区只负责技术分发** | 写入 SPEC §0 收敛原则；免责边界据此表述；**社区不承担诊疗责任、不做医疗背书** |
| **K6** | **一键部署指令写进 README**，带开源地址链接，写清部署规范引导，**保证直接能用** | SPEC §4.7 给逐字模板；A20 断言可执行；README 结构以「部署段落在前 1/3」为硬约束 |
| **K7** | **DSH 是未来下一步的事，也许新建仓库** | ADR-006：DSH 移出本包；五端降为四端；`--host=dsh` 不做；实测事实存档备未来用 |
| **K8** | **命名不变（青囊），但品牌写小胰宝** | 署名统一为「小胰宝社区 · 青囊」；README 首屏含小胰宝署名 |
| **K9** | **纳入 open-websearch + bing-cn + OpenAlex；建立 search runtime 注入文档；主注入做薄引导** | ADR-007 新增；搜索通道 2→6；新增冻结契约 `SEARCH_RUNTIME.md`（≤8KB）；主注入写「涉搜索先读 search runtime」；SPEC §5M3/M4 与锚点 A23–A26 |
| **K10** | **本包是「为 Agent 而做」**：不是搜集开发者项目，而是把 **skill + MCP 都囊括进来并做耦合**，优化**路由调用网络与调用效率** | **ADR-011** 新增；四条准入判据 + 三种合并方式 + 双向引用耦合契约；新增冻结契约 `MERGE_CONTRACT.md`；锚点 A30/A31 |
| **K11** | **移植 `/ai-spec init` 规范到用户部署阶段**：探测用户宿主机（硬件/网络/代理）→ 写入 Agent 注入文档；**保留动脑子原则**；**去掉 codebase 硬门控**（医学场景不需要） | **ADR-008**（`HOST_PROFILE.md` + `probe-host.sh`）+ **ADR-009**（移植与裁剪表 + 医学五条加强项）；锚点 A27/A28/A33/A34 |
| **K12** | **设计哲学与原则要写进 README、AGENTS.md、CLAUDE.md**：项目定位 / 开发逻辑 / 目的 / 最重要实现的效果 | **SPEC §4.10**「治理文档必写内容」四文件必写四要素；锚点 A29 |
| **K14** | **能力层直接 pull 进项目内部**：认可的 skill + MCP 放进本仓，部署时在本项目工作区构建环境；**不要太轻量化**（大小没事，共享环境性价比高） | SPEC §4.11 环境构建契约（E1–E8）；`package.json` / `pyproject.toml` / `scripts/fetch-vendor.sh` / `mcp-servers/launch/`；实测 **127MB / 5 通道握手 5/5** |
| **K15** | **全链降级链**：环境部署也要 fallback（能 uv 就先 uv，没有就 python venv）；**fallback 思想要贯穿环境配置、skill、mcp 调用**，写进 AGENTS.md / CLAUDE.md | **ADR-013** + `AGENTS.md` §1（降级链铁律六节，已与 CLAUDE.md 逐字一致）；`fetch-vendor.sh` JS 三档（pnpm→npm→yarn）+ Python 三档（uv→venv→conda）；锚点 A37–A39 |
| **K13** | **路线三段式**：青囊（本项目，**独立 + 多 agent 适配**）→ **forge 合并** DSH Desktop → **小胰宝社区版 DSH Desktop**（**独立项目**，含青囊 + DSH 嵌入开发 + 数据库接入） | **ADR-012** 新增；五条 **forge 接缝**（S1–S5）；锚点 A35/A36 |

---

## 6. 齐头并进核对（**四端**：青囊是社区资产包，不是发行版）

> **范围修正（K7 / ADR-006）**：原「五端」中的「发行版编排端」属于未来独立项目，已从本包移除。本包是**四端**。

| 端 | 位置 | 本 CHG 是否覆盖 | 备注 |
|---|---|---|---|
| ① **仓库/脚本端** | `qingnang` repo 根：`scripts/`、`MANIFEST.json`、CI | ✅ M1/M2/M6 | 地基 |
| ② **能力层（MCP）端** | `mcp-servers/`（npm 依赖锁版 + 健康检查） | ✅ M4（**6 个搜索通道，其中 4 个零凭据**） | KnowS/get-biji 待许可债 |
| ③ **内置技能端** | `skills/qingnang/`：`INJECT.md` + `SKILL.md` + `SEARCH_RUNTIME.md` + `references/**` | ✅ M3 | 随包分发 |
| ④ **宿主注入端** | `deploy.sh --mode=agent`：写入宿主的技能目录 | ✅ M2（需列宿主路径矩阵） | **A 类宿主**：Claude Code / pi / OpenClaw / Codex。**DSH 不在内**（ADR-006） |
| ~~⑤ 发行版编排端~~ | ~~`qingnang-desktop` 流水线~~ | ❌ **已移出本包** | 未来独立项目（K7） |

> **④ 是本轮容易漏的端**：`--mode=agent` 要往**多个不同宿主**的技能目录写文件。各宿主约定不同（Claude Code 读 `.claude/skills/`、pi 继承 `.claude` skills、OpenClaw 有自己的 workspace/skills、Codex 无 `skills/` 惯例 → 走 `AGENTS.md` 追加）。SPEC 要求**列全路径矩阵 + 每宿主一条验证命令**。
> **注入层要装三个文件**：`INJECT.md`（主注入）+ `SEARCH_RUNTIME.md`（搜索分流）+ `HOST_PROFILE.md`（本机画像）。**缺一不可**：少前者 Agent 不知道有青囊，少中者不知道用哪条通道，少后者不知道本机代理（ADR-007 / ADR-008）。
> **DSH 是特例**：它无 `SKILL.md` 惯例（插件是 Cordis TS 插件），**不是「配置路径不同」而是「机制不同」**——所以干脆不做，留给未来项目（ADR-006）。

### 6.1 未来接缝（ADR-012：本项目不做，但必须留）

| 阶段 | 项目 | 做什么 | 与本包的关系 |
|---|---|---|---|
| **一** | **青囊 QingNang**（本项目） | 独立的社区医学能力资产包，**多 agent 适配** | 本 CHG 范围 |
| **二** | **forge（合并）** | 青囊 × DSH Desktop 合并锻造，系统性嵌入 DSH 医学能力 | 读本包留的**五条接缝**（S1–S5） |
| **三** | **小胰宝社区版 DSH Desktop** | **独立项目**：青囊 + DSH 专属嵌入开发 + 数据库接入 | 继承本包的 `MERGE_CONTRACT.md` 纪律 |

> **接缝五条（S1–S5）**：零宿主专属代码 / manifest 唯一事实源 / 三层注入物理分离 / 合并契约随包交付 / 宿主画像与能力层解耦。**详见 SPEC §3.10**。

---

## 7. 风险登记（含本轮新识别）

| # | 风险 | 等级 | 文档是否已识别 | 对策 |
|---|---|---|---|---|
| R1 | 医疗信息质量责任 | 高 | ✅ §13-7 | 出处强制标注 + 免责三处 + 不做诊断铁律 |
| R2 | 病友数据隐私（PIPL） | 高 | ✅ §13-8 | 三条隐私边界 + 三道闸 + 遥测默认关 |
| R3 | MinerU 许可历史复杂（AGPL→自定义） | 中 | ✅ §13-1 | 独立子进程隔离 + 锁 4.x + 第三方许可页 |
| R4 | 离线数据包再分发条款未确认 | 中 | ✅ §13-2 | Phase 3 前书面确认 |
| R5 | DSH Desktop 很新、Windows-only | 中 | ✅ §13-3 | 宿主无关架构；macOS 版有第三方项目可评估 |
| R6 | NCCN 指南全文版权 | 中 | ✅ §13-6 | 只做要点摘录 + 官方链接 |
| **R7（新）** | **`veeva_ctv.tar.gz`（10MB，占数据包 83%）来源是商业临床数据平台，再分发权最可疑** | **中高** | ❌ **文档未单列** | **建议先不装 veeva 部分**；只用 ChiCTR/CDE/ICTRP 三个官方登记来源 |
| **R8（新）** | **`--mode=agent` 跨四宿主路径矩阵未定义**，只测一个宿主会「本地绿、别人红」 | 中 | ❌ **文档未展开** | SPEC 要求列全宿主路径矩阵 + 每宿主验证命令 |
| ~~R9~~ | ~~PRD 缺失导致 SPEC 无法「不发明需求」~~ | 低 | ❌ 曾存 | ✅ **已解决**：`PRD.md` v1.0 draft 已就位；待批准后 SPEC 可定稿 |
| **R10（新）** | **本机 git 署名非社区身份**，首次 commit 会写进历史 | 低 | ❌ | 首次 commit 前确认（署名值不在仓库内记录） |
| R11 | 无凭据档体验（KnowS 需申请） | 低 | ✅ §13-4 | 降级链 + README 申请教程 |
| R12 | 许可债未清就 vendor | 低 | ✅ §13-5 | 本 CHG 只 vendor MIT/Apache-2.0 两个 |
| ~~R13~~ | ~~母文档把 DSH Desktop 指向 `ningbainb/deepseek-harness-desktop`（BSD-3-Clause，812★），而社区主流是 `anywhere-labs/dsh-desktop`（MIT，30,780★）~~ | 低 | ❌ 曾误 | ✅ **已降级**：DSH 已移出本包（ADR-006）；事实已存档于 SPEC §4.8 供未来项目复用 |
| ~~R14~~ | ~~DSH 无 `SKILL.md` 技能目录惯例（插件是 Cordis TS 插件）~~ | 低 | ❌ 曾误 | ✅ **已降级**：同上；本包只面向 A 类技能目录宿主 |
| R15 | 凭据 live 验证不可能在本机完成（KnowS 需申请、NCBI key 可选） | 低 | ❌ | 主人已决策（K3）：**先 dryrun 打通链路**，实际部署由用户填 `.env`；锚点据此改写（SPEC §5M5 A15b） |
| **R16（新）** | **母文档把「资产包」与「桌面发行版」混为一个项目**，导致范围膨胀（五端、依赖 DSH 排期） | 中 | ❌ **文档结构问题** | 主人已澄清（K2/K7/K13）：本包只管资产打包；四端；DSH 合并另立项目（ADR-006/ADR-012） |
| **R17（新）** | **新增搜索 MCP 的许可与元数据不一致**：`open-websearch` 上游 LICENSE = Apache-2.0 但 `package.json.license` = `None`；`openalex-mcp-server` = **ISC**（不在原白名单）；`bing-cn-mcp` = MIT ✅ | 低 | ❌ **未识别** | ① 白名单显式加入 **ISC**（与 MIT 实质等同）；② `open-websearch` 以**上游 LICENSE 文件**为准并在 manifest 注明；③ 锁版以 **npm 已发布版本**为准（本机版本与 npm 不一致，见 SPEC §1.6 U9） |
| **R19（新）** | **依赖布局风险**：5 个 MCP 合并后共享 16 个依赖，其中 `@modelcontextprotocol/sdk` 有 **5 个不同版本区间**、`express` 有 **4.x/5.x 大版本冲突**；npm 扁平化可能解析错版本 | **中** | ❌ **未识别** | ① JS 侧**首选 pnpm**（隔离式布局，天然支持多版本并存），已在降级链首选位；② 兜底 npm 时脚本**显式警告**该风险；③ 用垫片隔离布局差异（SPEC §4.11 E3） |
| **R20（新）** | **`scripts/lib/common.sh` 的 `set -e` 经 `source` 污染调用者**，导致 `check.sh` 静默退出（EXIT=1 但无 ❌ 输出） | 低 | ❌ **未识别** | 已修：`common.sh` 改为**纯库文件**（不设任何 shell 选项），各脚本自行声明 `set`；已在注释里写明原因防复发（TRACE R49） |
| **R18（新）** | **`open-websearch` 依赖 Chromium/Playwright 能力**（README 出现 CDP、Playwright fallback），可能显著增大安装体积与失败面 | 中 | ❌ **未识别** | ① 默认 `SEARCH_MODE=request` **强制避开浏览器**；② `doctor.sh` 显式提示；③ 若必须 Chromium，则给「仅 request 模式」降级路径（SPEC §5M2 风险行 + A32） |

---

## 8. Definition of Ready（本 CHG 开工前必须满足）

1. **定位与品牌已定**（§3.1 P1–P4 / ADR-001）：本项目 = 社区医学资产打包；品牌 = 小胰宝；不讨论中立。✅ **已满足**
2. **DSH 边界已定**（ADR-006 / ADR-012）：本包不写 DSH 代码，只留接缝。✅ **已满足**
3. **B1 解决**：`PRD.md` 存在且状态为 `APPROVED`（或主人明确以 v1.0 文档替代 PRD）。⬜（**当前唯一硬阻塞**）
4. **D5 解决**：仓库名（`QingNang` → `qingnang`）与 git 署名确认。⬜
5. **本 SPEC 被明确批准**（`status: approved`）——**未批准不得开工**。⬜

## 9. Definition of Done（本 CHG 交付判定）

1. M1–M6 全部产出物落盘，SPEC 契约逐条实现，**清单外无越界文件**。
2. 验收锚点 A1–A17 全绿，证据落 `tasks/CHG-20261014-qingnang-mvp/EVIDENCE.md`。
3. **「新容器一句话部署 → doctor 全绿（无凭据档）→ 完成一次 PubMed 检索 + 一次试验检索」端到端跑通**（对应文档 Phase 1 AC）。
4. **「有/无凭据两种状态下，降级链行为符合预期」跑通**（对应文档 Phase 2 AC）。
5. `--mode=agent` 在**至少 2 个宿主**（Claude Code + 另一个）安装成功并各有一条验证命令证据。
6. `private/` 隔离有**可执行验证**（脚本断言「除 `~/.qingnang/private/` 外无任何用户数据残留」）。
7. 五端核对表中 ①–④ 端均有产出；⑤ 端有明确的豁免理由（已记录于 §4.2）。
8. **README「一键部署」段落可被逐字复制执行**，且在干净环境一次跑通（对应 SPEC §4.7 冻结契约 + A20）。
9. **凭据 dryrun 走通**：`deploy.sh --dry-run` 与路由 dryrun 均通过（A21 + A15b）。
10. commit / push **待授权**（独立 Gate，不在本 CHG 自动完成）。

---

## 10. 下一步路由

```
B1 解决（PRD 批准）
  → 本 SPEC 提交主人批准（SPEC_READY → SPEC_APPROVED）
    → goal-driven-development 执行 M1 → M6
      → 每里程碑 commit（授权 Gate）→ 全部完成后 push（授权 Gate）
```

**并行动作（不阻塞，不等 SPEC）**：
- D3：把 DSH 团队沟通稿整理成一封可转发邮件（§9.2 四件事）。
- B3：主人引荐 Sam 后，把「离线数据包再分发条款 + 补 LICENSE 清单」一次性谈掉。
- B2：列出需要补 LICENSE 的仓库清单（KnowS-AI / get-biji×2 / HADS / Medical-Record-Organizer），一次性发社区。

**明确不做**：
- ❌ 在 PRD 未批准时定稿 SPEC 并开工（违反 ai-spec 流程约束）。
- ❌ 自动批准 SPEC / commit / push。
- ❌ 直接进入 Ralph（`ai-spec` 规定：批准后默认交 `goal-driven-development`，Ralph 仅作 legacy 显式选项）。
