---
change_id: CHG-20261014-qingnang-mvp
version: 1.0
status: draft
prd_ref: PRD.md（v1.0 draft，待主人批准 —— 见 PRD §11 P1）
health_ref: null
supersedes: null
approved_by: null
approved_at: null
scope: Phase 1 + Phase 2 可独立验收部分（M1–M6）
---

# SPEC：青囊 QingNang MVP v0.1 —— 可跑骨架 + 双免费通道

> **本文件状态**：`draft` = **可评审，但不可定稿**。
> 按 `ai-spec` 流程约束，PRD（`PRD.md`）未 `APPROVED` 前不得进入工程定稿（DoR §8.1）。
> **更新（2026-10-14）**：`PRD.md` 已产出（v1.0 draft，含用户/场景/目标/成功标准/12 条用户故事/5 条边界故事）。**待主人批准后 SPEC 方可定稿。**
> 评审时请重点看：§2 设计选择、§4 冻结契约与文件清单、§5 里程碑验收命令——这三处定了，后面就是执行。

---

## 0. 收敛原则（全部里程碑遵守）

1. **清单外不建文件**。§4 文件清单是白名单；未列出路径不得创建。需要新增 → 提 SPEC 修订（版本号 +1）。
2. **冻结契约不动**：`MANIFEST.json` / `mcp-servers/manifest.json` / doctor 输出格式一旦冻结，只允许**新增字段**，不允许改名或删字段。
3. **品牌清晰（ADR-001）**：包内品牌统一为 **「小胰宝社区 · 青囊」**。仓库名/包名/环境变量前缀/数据目录用 `qingnang`（工程中性，便于宿主兼容）；**README 首屏必须出现小胰宝署名**。不追求「中立」，也不隐藏来源。
4. **隐私边界不可协商**：任何路径、任何脚本、任何 MCP 调用参数**不得**触碰 `~/.qingnang/private/` 之外的写入；网络请求只允许携带检索关键词。
5. **零凭据可跑**：不填任何 API Key 时，**六条搜索通道中的四条（open-websearch / bing-cn / PubMed+OpenAlex / unified-trial）+ 本地知识库**必须全部可用。**任何把凭据变成硬门槛的实现都是违约**。
6. **不静默失败**：通道不可用时必须明说「当前不可用」，**绝不编造未检索到的内容**；任何降级必须在输出中可观察。
7. **每里程碑一个 commit**，模板见 CHANGE §5；commit / push 是独立授权 Gate。
8. **卡住先核对本 SPEC 与 CHANGE，不自由发挥**。
9. **三个把关点（主人 2026-10-14 定，不可协商）**：① **医学伦理**——不做诊断结论、不给用药剂量、遇急症引导就医、知识卡标注审校状态；② **数据安全**——病情数据 100% 本地、遥测唯一档位 `off`、任何导出不得触碰 `private/`；③ **社区只负责技术分发**——社区提供的是技术工具与公开信息检索能力，**不承担诊疗责任、不做医疗背书**，免责声明三处必须到位。
10. **可执行优先**：README 的「一键部署」段落必须能被逐字复制执行且在干净环境一次跑通；**写不清楚就等于没写**。
11. **搜索先分流（ADR-007）**：Agent **不得凭猜选搜索工具**。主注入只给「涉搜索先读 `SEARCH_RUNTIME.md`」的**薄提示**（不列工具清单）；具体通道选择、参数要点、降级顺序全部在 `SEARCH_RUNTIME.md`。新增/更换搜索工具**只改该文件与 manifest，不改主注入**。

---

## 1. 上下文、目标、非目标、约束、假设、未决问题

### 1.1 上下文

- 仓库 `PancrePal-xiaoyibao/QingNang` 为**空仓库**（0 commit，仅 `docs/` 两份未跟踪文档）。
- 母文档 `docs/QingNang_Community_Asset_Pack_Architecture_and_DevPlan_v1.0_20261014.md` 已定稿：愿景、五条铁律、L4–L-1 分层、137 仓库盘点、许可证债、Phase 0–5 计划。
- 本 SPEC **不重新设计架构**，只把母文档的 Phase 1–2 转成**可执行契约**（含文件白名单、验收命令、回滚点）。
- 参考实现 `Development/Starchart`（deploy.sh 306 行模块化 + tasks 三件套 + check.sh）——本例直接沿用其形态，不另创范式。

### 1.2 目标（本 CHG 的可验证目标）

| # | 目标 | 验证锚点 |
|---|---|---|
| G1 | 仓库具备自包含骨架（清单、脚本、技能层、能力层声明、治理文件） | A1–A3 |
| G2 | `deploy.sh` 幂等，`doctor.sh` 逐通道可判定、可机读 | A4–A6 |
| G3 | 技能层 v0 成型（主注入 + 搜索 runtime + 薄技能 + 厚参考），路由可执行 | A7–A9、A23–A26 |
| G4 | **六条搜索通道**中四条零凭据真实可用（open-websearch / bing-cn / PubMed+OpenAlex / unified-trial） | A10–A12、A23 |
| G5 | 降级链在「有/无凭据」两态下行为可预期 | A13–A15 |
| G6 | 第一道敏感信息闸可用（pre-commit + gitleaks + 中文 PHI/PII 规则） | A16–A17 |
| G7 | 治理约束**可执行**而非口头（遥测唯一档位、private 隔离断言） | A18–A19 |

### 1.3 非目标（Non-Goals，本 CHG 明确不做）

1. 不 vendor KnowS / get-biji / MinerU / HADS / Medical-Record-Organizer（许可债未清 → B2）。**搜索类六通道中，前四条零凭据通道本 CHG 全上；KnowS 与 get-biji 等许可清完再上**。
2. 不做离线数据包装载与本地 RAG 索引（Phase 3，等 B3）。
3. **不做 DSH 适配**（ADR-006）——不写 Cordis 插件包、不写 DSH MCP 配置写入、不列 DSH 为支持宿主。**理由（ADR-012）**：本阶段青囊是**独立的多 agent 适配资产包**；DSH 合并属**阶段二 forge**，阶段三产出**独立的小胰宝社区版 DSH Desktop**（含青囊 + DSH 专属嵌入开发 + 数据库接入）。本包只需留好接缝（S1–S5），不写 DSH 代码。
4. 不做病种扩展（`qingnang-breast` 等，Phase 5）。
5. 不引入服务端 / 云依赖 / 常驻进程（坚持本地轻量）。
6. 不引入重型 NLP 依赖（无 torch / spacy / 向量库；本 CHG 甚至不建索引）。
7. 不做医疗内容判断逻辑（不诊断、不荐药、不给剂量——只做检索路由与出处标注）。
8. **本 CHG 不含任何 commit / push 授权**。

### 1.4 约束

| 类型 | 约束 |
|---|---|
| 环境 | 目标机最低配置：Python ≥3.11、Node ≥20、可执行 `npx`、无 GPU 要求 |
| 依赖许可 | 本 CHG 允许纳入的许可白名单：`{MIT, Apache-2.0, ISC, BSD-3-Clause}`（A12 断言）。**ISC 显式加入**：它是功能上等同 MIT 的宽松许可（OpenAlex MCP 用 ISC）；**BSD-3-Clause 加入**是为未来预留，本 CHG 实际只用到前三个。**本仓库自身许可 = Apache-2.0** |
| 体积 | `INJECT.md` ≤**2048** 字节；`SEARCH_RUNTIME.md` ≤**8192** 字节；`SKILL.md` ≤**14336** 字节 |
| 网络 | 部署需外网（拉 npm 包）；**运行期除检索外无网络请求**；代理环境需可通过环境变量覆盖 |
| 平台 | 首版保证 Linux/macOS；Windows 走 WSL 或原生 Node（不保证）；**DSH 平台不在本 CHG 范围** |
| 数据 | 仓库内**不得**出现真实患者数据；演示数据一律走 `data/synthetic/` 造数脚本 |

### 1.5 假设（若被推翻需修订 SPEC）

| # | 假设 | 推翻代价 |
|---|---|---|
| H1 | 六个搜索 MCP 包（`open-websearch` / `bing-cn-mcp` / `mcp-pubmed-llm-server` / `openalex-mcp-server` / `unified-trial-mcp`，KnowS 待凭据）在**无凭据**下可握手并返回结果 | 中（须换通道或补凭据） |
| H2 | A 类宿主（Claude Code / pi / OpenClaw / Codex）以「`<skills_dir>/<name>/SKILL.md`」读技能；无该惯例的（Codex）扫 `AGENTS.md` | 中（需按宿主定制安装逻辑） |
| H3 | 母文档 §7 环境变量矩阵即为最终契约 | 低（仅改配置） |
| H4 | 主人接受「以母文档 §1/§1.3/§11/§12 抽出 PRD」而非另起问卷（B1 处置方式） | 中（改走 `prd` skill） |
| **H5** | `open-websearch` 的**纯 request 模式**是够用的（不必启 Chromium/Playwright） | **中**（若必须 Chromium，装包体积与失败面大升 → R18） |

### 1.6 未决问题（必须解决或显式豁免后才可定稿）

| # | 问题 | 类型 | 处置 |
|---|---|---|---|
| U1 | ~~PRD 缺失~~ → **PRD 已产出，待批准** | **阻塞定稿** | `PRD.md` v1.0 draft 已就位（§1 用户 / §2 场景 / §3 目标 / §4 成功标准 / §5 用户故事）。**仅差主人批准**（PRD §11 P1） |
| ~~U2~~ | ~~落点品牌：社区 org vs 中立~~ | ✅ **已关闭**（K2） | 落社区 org，**品牌 = 小胰宝**，不再讨论 |
| U3 | ~~仓库许可证选择~~ | ✅ **已定** | **Apache-2.0**（含专利授权，与多数上游一致，也是 `open-websearch` 的选择）；LICENSE 内附医学免责声明（非条款部分） |
| U4 | 仓库名大小写（`QingNang` → `qingnang`）与 git 署名 | 阻塞首个 commit | CHANGE §5.2 D5 |
| U5 | `--mode=agent` 的宿主路径矩阵 | 阻塞 M2 验收 | 本 SPEC §3.4 已限为 **A 类宿主**（有 `skills/` 惯例，DSH 已移出）；M2 中逐宿主实测回填 |
| U6 | 知识卡「审校者」字段在无真人审校时如何填写 | 阻塞 M3 验收 | 建议首版填 `pending-review` 并显式标注「未审校」，不得留空 |
| U7 | ~~DSH Desktop 长期接口稳定性~~ | ✅ **已移出本包**（ADR-006） | DSH 集成属**未来独立项目**；本轮实测事实存档于 §4.8 供复用，本 CHG 不依赖 DSH 任何接口 |
| **U8** | `open-websearch` 上游仓库地址与真实许可证未确定（本机 LICENSE 文件 = Apache-2.0，但 `package.json.license` = `None`，且无 repository 字段） | 阻塞 M4（A12 许可断言） | 可先以上游 LICENSE **文件**为准（Apache-2.0），在 manifest 里注明「package.json 元数据缺失」；**R17 登记，并行核实** |
| **U9** | 三个新增包的**本机版本与 npm 版本不一致**（open-websearch 本机 2.1.11 / npm 2.2.0；openalex 本机 1.0.6 / npm 1.0.5；bing-cn 两边都是 1.0.2） | 阻塞 M4（A10 锁版断言） | **以 npm 已发布版本为准**（可复现、可拉取）；本机版本差异仅作参考。M4 中实测确认 |

---

## 2. 现状架构与技术债影响

### 2.1 现状

**无代码、无架构、零技术债**。仓库 = `.git/`（空历史）+ `docs/`（2 份文档）+ `.ipynb_checkpoints/`（空目录，应清理）。因此：

- **本 CHG 无历史债基线可审** → `health_ref: null` 是有意为之，非遗漏。
- 唯一的「债务」是**外部依赖债**（许可证 / 再分发条款），登记于 CHANGE §7 R2–R4、R7。
- 唯一的结构性风险是**过早绑定**（品牌、宿主、注入机制）——由 §0.3「品牌清晰」与 ADR-001/004 对冲；DSH 相关风险已由 ADR-006 移出本包。

### 2.2 本 CHG 自身引入的债与处置

| 债 | 内容 | 处置 |
|---|---|---|
| D-1 | 若把 MCP 以 `npx -y <pkg>` 方式依赖，则**每次启动拉最新**，破坏可复现性 | **锁版本**：manifest 中显式写 `@<version>`，A10 断言与 npm 实际版本一致 |
| D-2 | `--mode=agent` 复制（而非软链）技能层 → 上游更新后宿主副本不刷新 | `deploy.sh` 提供 `--mode=agent --link` 选项；README 明写两种模式差异；`doctor.sh` 增加「副本是否与源一致」检查 |
| D-3 | pre-commit 闸只能防「本机提交」，防不了网页上传 | CI 闸（Phase 4）+ `CONTRIBUTING.md` 红线 + PR 模板勾选项（本 CHG 先落文档面） |
| D-4 | 首版知识卡未走真人医学审校 | `U6`：显式标 `pending-review` + 卡片内声明「未经医学审校」，**不假装已审** |

---

## 3. 选定设计（ADR）

### 3.1 ADR-001 · 落点与品牌（已关闭）

| 项 | 内容 |
|---|---|
| **决策** | 仓库落 `PancrePal-xiaoyibao/QingNang`；**品牌 = 小胰宝社区 · 青囊**；**不迁移、不再讨论中立** |
| **被否方案** | ① 另建中立 org（无必要——本项目就是小胰宝社区资产） ② 「社区 org + 中立包结构」（过度设计：中立结构是为未确定的未来买保险） |
| **理由** | 品牌即定位。本项目是小胰宝社区的资产包。主人原话：「品牌就写小胰宝，不用纠结别的」 |
| **可逆性** | 不适用（已关闭） |
| **后果** | §0.3 「品牌中立」**作废**，替换为「**品牌清晰**」 |
| **不阻塞** | —（已关闭） |

### 3.2 ADR-002 · 技能层目录形态

| 项 | 内容 |
|---|---|
| **决策** | 技能层落在 **`skills/qingnang/`**（内含 `INJECT.md` + `SKILL.md` + `references/`）；`deploy.sh --mode=agent` 将其安装到各宿主的 skills 目录 |
| **被否方案** | ① 平铺在仓库根（`INJECT.md`/`SKILL.md` 在根）——母文档 §3.3 字面读法，但无法与「Repo 治理文件」区分，且宿主安装时需逐文件挑拣 ② 单一 `skill/` 目录——与宿主惯例（复数 `skills/`）不符，易踩坑 |
| **理由** | 宿主普遍按 `skills/<name>/SKILL.md` 定位（H2）；保持**一个目录 = 一个可安装单元**，安装逻辑最简单、最不易漏文件 |
| **可逆性** | 高（移动目录 + 改 deploy 路径） |
| **后果** | `MANIFEST.json` 中 `skill.path = "skills/qingnang"`；`INJECT.md` 的宿主注入路径由 deploy 决定 |

### 3.3 ADR-003 · MCP 依赖方式（`npx` 锁版 vs vendor 源码 vs git subtree）

| 项 | 内容 |
|---|---|
| **决策** | **`npx -y <pkg>@<钉死版本>`** 为主；`mcp-servers/manifest.json` 为**唯一事实源** |
| **被否方案** | ① git subtree——母文档 §6.1 倾向此项，但本 CHG 阶段两个包均已在 npm 发布且有稳定版本；subtree 引入「上游 git 历史 + 更新流程」成本，收益要到「需改上游代码」时才兑现 ② vendor 源码进仓——体积与许可声明成本高，且母文档已对 MinerU 采用「独立进程隔离」思路，此处一致化 |
| **理由** | 母文档 §6.1 对「社区 4 个 MCP」给的是「subtree **或** npm 依赖 + lockfile」，本决策取后者；**锁版本**保证可复现（D-1） |
| **可逆性** | 高（改为 subtree 只需补目录 + 改 manifest 的 `command`） |
| **后果** | 部署需外网 + npm 可达；离线部署能力推迟到有知识包（Phase 3）后。**若主人要求完全离线安装，本决策需修订** |

### 3.4 ADR-004 · 宿主注入路径矩阵（**A 类技能目录宿主**，U5）

> **范围（ADR-006）**：**DSH 已移出本包**，不列入下表。本表只含「有 `skills/` 惯例」的 A 类宿主。

| 宿主 | 技能目录 | 验证方式 | 实测状态 |
|---|---|---|---|
| Claude Code | `~/.claude/skills/` | 新会话问「青囊有哪些能力」 | ⬜ 待测 |
| pi | 继承 `.claude/skills/`（本机已确认该继承关系） | 同上 | ⬜ 待测 |
| OpenClaw | `<workspace>/skills/` | 同上 | ⬜ 待测 |
| Codex | 无 `skills/` 惯例 | 向 `AGENTS.md` 追加 marker 包裹的引用块 | ⬜ 待测 |

> **契约**：M2 完成后本表每行必须有实测结论（✅/❌ + 证据）；**至少 2 个宿主 ✅** 才满足 DoD。
> **降级策略**：无技能目录惯例的宿主（Codex），用「向入口指令文件追加一段 marker 包裹的引用块」实现；**幂等要求**：marker 存在则替换内容，不重复追加。
> **注入要装三个文件**：`INJECT.md`（主注入）+ `SEARCH_RUNTIME.md`（搜索分流）+ `HOST_PROFILE.md`（本机画像）。**只装一个会让 Agent 找不到分流表或不知道本机代理**（ADR-007/008）。

**A 类·技能目录宿主**（有 `skills/` 惯例 → 装整个技能目录）

| 宿主 | 技能目录 | 验证方式 | 实测状态 |
|---|---|---|---|
| Claude Code | `~/.claude/skills/` | 新会话问「青囊有哪些能力」 | ⬜ 待测 |
| pi | 继承 `.claude/skills/`（本机已确认该继承关系） | 同上 | ⬜ 待测 |
| OpenClaw | `<workspace>/skills/` | 同上 | ⬜ 待测 |
| Codex | 无 `skills/` 惯例 | 向 `AGENTS.md` 追加 marker 包裹的引用块 | ⬜ 待测 |

### 3.5 ADR-011 · 合并而非搜集 + skill/MCP 耦合（**本包最核心的工程约定**）

> 主人原话：「这个项目**不是要把所有的开发者项目都拉进去**，而是需要把 **skill + MCP 都囊括进来**，尤其是一些明显对于医学工作重要的 skill 和 MCP，都要合并起来，进行 **mcp 工具与 skill 的耦合**，并把这一系列的调用全部进行**内部的路由调用网络与 mcp 工具调用效率的优化**。这个项目本质上**是面对 agent 的开发，不是面对人的**——一切都是为了最大化地服务 agent，让 agent 可以最大化地具备社区目前积累的各种医学能力。」

| 项 | 内容 |
|---|---|
| **决策** | 本包是 **Agent 的能力工具箱**，不是仓库镜像。① **按能力筛选**（不按仓库数量）；② 进来的东西**必须做耦合**（skill 声明依赖哪个 MCP，MCP 声明哪些 skill 会用）；③ 调用路径要**优化**（串并行、降级、去重、互相引用） |
| **被否方案** | ① 「把 137 个仓库都拉进来」（体积爆炸、许可债不可控、Agent 反而不知该用哪个） ② 「只列一张资源链接表」（Agent 无法直接用，等于没做） |
| **可逆性** | 高（每项可单独增删；新增只需改 `SEARCH_RUNTIME.md` + manifest + 在 `MERGE_CONTRACT.md` 登记） |
| **后果** | 新增冻结契约 `MERGE_CONTRACT.md`（§4.9）；准入判据固定为四条；**skill ↔ MCP 双向引用成为验收项**（A30/A31） |

**四条准入判据**（一条仓库要不要进本包）：

| # | 问题 | 进 | 不进 |
|---|---|---|---|
| 1 | **医学相关吗？** | 病友的信息获取、病历处理、指标追踪、心理支持 | 开发者工具、运维脚本、UI 模板 |
| 2 | **是能力还是应用？** | skill / MCP（能力） | 完整应用、机器人、小程序、官网（只借鉴） |
| 3 | **许可干净吗？** | `MIT` / `Apache-2.0` / `ISC` / `MIT-0` / `BSD-3` | `NONE` → 放 `reserved` 等补；`AGPL` / `NOASSERTION` / 禁商用 → 不进主包 |
| 4 | **能被 Agent 调用吗？** | 有 `SKILL.md` 或 MCP 包 | 一堆散脚本、无调用入口 → 先改造成 skill 才进 |

**三种合并方式**（不允许第四种）：

| 方式 | 适用 | 做法 | 禁止 |
|---|---|---|---|
| **A. 直接引用** | 许可干净 + npm 已发布 + 无需改代码 | manifest 写包名 + 钉死版本；skill 写调用要点 | 拷源码进本仓 |
| **B. 改进后并入** | 上游是 skill、思路对但表达不合规范 | 拷入 `skills/qingnang/references/` 或新建 skill，**改动处标注来源与改了什么** | 静默改上游语义 |
| **C. 隔离调用** | 许可有传染性（AGPL）或体积大 | 独立子进程 / 独立 venv，**不进主依赖树**；发行物列明第三方许可 | 与主包代码链接 |

**耦合契约（双向引用，缺一不可）**

每个 skill 的 `SKILL.md` **必须**声明三件事：① 依赖哪些 MCP（写 `server_name`）② 什么时候调（触发信号）③ 拿到的结果怎么用（输出去向）。
每条 `SEARCH_RUNTIME.md` 通道**必须**写明：哪个 skill 会用它、解决什么问题。

> **反例（禁止）**：MCP 装了但没任何 skill 说要用；skill 写「去搜索」但不说搜哪个通道。
> **验收**：**A30** 每个 MCP ≥ 1 个 skill/route 双向引用；**A31** 每个 skill 依赖声明完整。

### 3.6 ADR-005 · 凭据策略：先 dryrun 打通链路（主人 K3）

| 项 | 内容 |
|---|---|
| **决策** | 验收阶段**不要求凭据 live 可用**。`deploy.sh --dry-run` 必须能验证「配置装载 → 通道发现 → 路由选择」全链路；实际凭据由用户在 `.env` 填写，`doctor.sh` 负责体检与中文指引 |
| **被否方案** | ① 等拿到 KnowS 凭据再验收（会无限期阻塞） ② 用假凭据跑（会污染错误信号，且可能触发上游风控） |
| **理由** | KnowS 需走公众号/小程序申请，NCBI key 对个人非必需；而**零凭据本身就有两条完整通道**，链路可验证性不依赖凭据 |
| **可逆性** | 高（凭据到手后跑同一套 `doctor.sh`，`⬜` 转 `✓`） |
| **后果** | 锚点 A15b 改为「**有凭据 → 路由命中 KnowS；无凭据 → 自动降 PubMed 且不报错、不静默**」，不可 live 时记 `⚠️` 并写明原因；`--dry-run` 成为 `deploy.sh` 必备选项（A21） |

### 3.7 ADR-008 · 宿主机探测与 `HOST_PROFILE.md`（主人要求）

| 项 | 内容 |
|---|---|
| **决策** | 部署时运行 `scripts/qingnang.mjs probe`（**参照 `dev-host-init` 的 `host-scan.sh`**），探测结果写入 `skills/qingnang/HOST_PROFILE.md`（本机画像），与主注入一起装到宿主 |
| **探测维度** | OS/架构 ｜ CPU 核心+内存（判断并发能力） ｜ **网络代理（env 变量 + 常见本地端口探测，含 1080/7890/7897/8118/8888）** ｜ npm registry 可达性 ｜ 已装运行时（node/python/npx） ｜ 磁盘可用空间 ｜ 宿主类型（探测到 `.claude`/`.pi`/`.codex` 等目录） |
| **被否方案** | ① 不探测、让用户手填（零基础用户填不对代理，直接卡在第一步） ② 把探测结果写进 `INJECT.md`（主注入必须 ≤2KB 且**与机器无关**，否则无法入库复用） |
| **理由** | **代理是青囊的第一道门槛**（`open-websearch` 需代理才能访问部分境外站点）；探测一次写到独立文件，既不污染主注入，又让 Agent 直接知道「本机代理是 127.0.0.1:7890」 |
| **可逆性** | 高（删文件即回退；探测失败时填「未检测到」兜底文案，**绝不留裸占位符**） |
| **后果** | ① `HOST_PROFILE.md` 成为 `deploy.sh --mode=agent` 的**必备安装项**（A28）；② `doctor.sh` 增加「宿主画像存在与新鲜度」检查；③ `open-websearch` 的 `USE_PROXY`/`PROXY_URL` **从本文件自动回填** |
| **来源** | 主人原话：「把你的开发宿主机上的 /ai-spec init 的规范，放入这个青囊项目的用户部署阶段参考，对任何一个用户宿主机的硬件、网络环境等等，做一个探测以后写到 agent 的注入文档里面」 |

### 3.8 ADR-009 · 从 `dev-host-init` 移植与裁剪（主人要求）

| 保留（与医学场景强相关） | 裁掉（医学场景不需要） |
|---|---|
| **动脑子铁律**（先想清 项目/环境/需求/目的/用户体验 五件事 + 三条红线） | ~~codebase 图谱硬门控~~——**主人明确要求去掉**：「因为项目是做医学的，可以不用这个硬性门控」。改为**软建议**（「如宿主已装 codebase 工具则推荐用，**不强制**」） |
| **说人话铁律**（先结论、短句、术语首现即解释、代号表） | ~~多 Agent 并行协作~~（青囊是资产包，不涉并行开发） |
| **测试产物卫生**（T0–T3 四阶段） | ~~服务器硬件环境 / 网络拓扑运维~~（那是那台开发机的，不是用户的） |
| **修改/删除安全**（尤其是 `~/.qingnang/private/` 绝不删） | ~~Conda 环境速查 / 踩坑记录~~（青囊不依赖 conda） |
| **隐私与敏感信息**（PHI/PII 不出机——**医学场景下比代码场景更关键**） | ~~开源脱敏（push 前查 IP/域名）~~❓ **保留但降权**：青囊也会开源，但用户在本地跑不需查；改为「**贡献者PR 时**才触发」 |
| **先判断再行动**（不判根因不动手） | — |
| **交付纪律**（不甩半成品、给结论+依据+下一步） | — |

> **医学场景加强项（`dev-host-init` 没有、青囊必须有）**：
> 1. **不做诊断结论**（不猜病、不下结论）
> 2. **不给用药剂量**（一句也不给）
> 3. **遇急症引导就医**（不自行处理）
> 4. **出处强制标注**（每个结论带来源）
> 5. **知识卡审校状态**（`pending-review` 时必须声明未经医学审校）

### 3.9 ADR-010 · 极致可用性目标（主人本轮的根需求）

> 主人原话：「目的就是保证，**项目开源出去，用户复制了部署指令，他的 agent 瞬间就具备了社区的医学相关能力**，而且是**高度优化整合的 skill 路由平滑 + mcp 调用提示 + 注入文档优化提升性能**的一整套工具箱」

拆成三条**可验收**的硬指标（写入 DoD）：

| # | 指标 | 可执行判定 | 锚点 |
|---|---|---|---|
| **E1** | **复制即用**：用户复制 README 的部署咒语给任意 Agent，**无需额外解释**即可完成 | 干净环境抽指令块执行一次 `exit 0`；且 J6 人工验收通过 | A20 / J6 |
| **E2** | **瞬间就绪**：部署完成后**第一次提问就能命中正确通道**，不需要用户教 Agent 怎么用 | 6 类典型问题各跑一次，通道选择与 §3.5 分流表一致 | A23 |
| **E3** | **路由平滑**：主注入薄、分流表详、Agent 不靠猜；**新增工具不改主注入** | `INJECT.md` 含引导语但不含工具清单；`SEARCH_RUNTIME.md` 含完整分流表 | A24 / A25 |

### 3.10 ADR-012 · 下游 forge 接缝（**本包必须为后续合并留好缝**）

> 主人原话（2026-10-14）：「这个青囊项目，目前设计上是**独立的**，就是**多 agent 适配**。项目做完以后，后续会把这个项目和 **dsh desktop 项目合并 forge**，系统性地**嵌入提升 dsh desktop 的医学能力**，并**直接发布社区版本的 dsh desktop**。到时候那个**小胰宝社区的 dsh desktop 是一个独立的项目**，里面除了这个青囊项目以外，还会有一些**适配 dsh desktop 的嵌入开发、数据库接入**等等事项。」

**三段式路线（记清楚，别混）**：

| 阶段 | 项目 | 做什么 | 交付 |
|---|---|---|---|
| **一（本项目）** | **青囊 QingNang** | **独立**的社区医学能力资产包；**多 agent 适配**（Claude Code / pi / OpenClaw / Codex 等） | 一个可被任意 Agent 加载的资产包（本 CHG 范围） |
| **二（未来）** | **forge（合并）** | 把青囊 × DSH Desktop **合并锻造**，系统性嵌入 DSH 医学能力 | 合并方案 + 实现（**独立立项**） |
| **三（未来）** | **小胰宝社区版 DSH Desktop** | **独立项目**：含青囊 + DSH 专属嵌入开发 + 数据库接入 等 | 可直接发布给社区用户的桌面发行版 |

| 项 | 内容 |
|---|---|
| **决策** | 青囊**本阶段完全独立**（不依赖 DSH，也不为 DSH 写代码）；**但必须留下可被 forge 直接复用的接缝**，使阶段二的合并是「拼装」而非「重写」 |
| **被否方案** | ① 现在就按 DSH 插件形态做（毁掉多 agent 适配——DSH 无 `SKILL.md` 惯例，插件是 Cordis TS 包，见 §4.8） ② 不管未来，随便写（阶段二会推倒重来，等于白做一遍） |
| **可逆性** | 高（接缝是「声明 + 结构」层面的约束，不改功能） |
| **后果** | 新增五条 **forge 接缝约束**（下方）；本包内凡违反接缝的实现，属违约 |

**forge 接缝五条（本包必须遵守）**：

| # | 接缝 | 为什么阶段二需要它 | 违反的后果 |
|---|---|---|---|
| **S1** | **零宿主专属代码**：包内不出现任何 DSH/Cordis/OpenClaw 专属逻辑 | 阶段二在宿主侧做适配层，不与能力层混在一起 | 合并时要先把宿主代码剥出来，等于重写 |
| **S2** | **`mcp-servers/manifest.json` 是唯一事实源**：所有 MCP 声明都从这里读 | 阶段二可直接把它翻译成 DSH 的 `StdioConfig`（字段映射见 §4.8），无需二次采集 | 各宿主各自维护一份配置 → 漂移 |
| **S3** | **三层注入文件物理分离**（`INJECT.md` / `SEARCH_RUNTIME.md` / `HOST_PROFILE.md`）：不合并成一个大文件 | 阶段二可按 DSH 的注入机制**逐层重渲染**，而不用拆解大文件 | 大文件无法按宿主裁剪 |
| **S4** | **`MERGE_CONTRACT.md` 随包交付**：阶段二的项目继承同一套准入判据与耦合契约 | 保证阶段三引入新能力（数据库接入等）时纪律一致 | 每个项目一套规矩 → 生态碎片化 |
| **S5** | **`HOST_PROFILE.md` 与能力层解耦**：机器画像单独成文件，不进 `SKILL.md` | 阶段三的桌面版有自己的探测方式（Electron 主进程），可自行生成同构画像 | 机器信息硬编码进技能层，换环境即失效 |

> **验收**：**A35** 包内 grep 不出现宿主专属标识（`dsh`/`cordis`/`openclaw` 作为**依赖或配置键**出现，而非文档说明）；**A36** 上述五条接缝在 SPEC 文件清单中各有对应产物且路径稳定。
> **与 ADR-006 的关系**：ADR-006 说「DSH 不在**本包实现**范围内」；ADR-012 说「本包必须为**阶段二的合并**留好缝」。**两者不矛盾：不写 DSH 代码 ≠ 不留合并余地。**

### 3.11 ADR-013 · 环境构建与运行全链降级链（**主人要求，贯穿全项目**）

> 主人原话：「就是环境部署，也要有个 fallback。如果用户能安装 uv，那就先安装 uv；实在没有，那就直接 python venv。反正就是把这个 fallback 的项目规范，**无论是环境配置，还是 skill，还是 mcp 调用**，都要有这个 fallback 思想在——**首先是什么，其次是什么，最后是什么兜底**，都要做到。」

| 项 | 内容 |
|---|---|
| **决策** | 项目内**每一处「做选择」的地方都必须写成三档降级链**（首选 → 次选 → 兜底），并写入 `AGENTS.md` §1 作为铁律 |
| **被否方案** | ① 只写一条「快乐路径」（一半用户装不上） ② 在脚本里各写各的降级逻辑（散落、不一致、无法审查） |
| **理由** | 青囊要装到**用户的机器**上。用户环境千差万别：可能只有 conda 没有 uv、npm 装不上 pnpm、没有代理、Node 版本不够。**只写一条路径 = 一半用户装不上。** |
| **可逆性** | 高（降级链是文档 + 脚本条件分支，不改变契约） |
| **后果** | `AGENTS.md` §1 新增六节降级链铁律；`scripts/qingnang.mjs fetch` 实现环境三档；所有降级必须**可观察**（明示走了哪一档） |

**五条降级链（全部已实现）**：

| 层 | 首选 | 次选 | 兜底 | 实现位置 |
|---|---|---|---|---|
| **JS 包管理** | **pnpm**（隔离式 `node_modules`，支持一个项目内多版本依赖并存） | **npm**（扁平化，有冲突风险但可用） | **yarn**；再不行 → 明示缺失 + 给安装命令 | `fetch-vendor.sh` |
| **Python 环境** | **uv venv**（快、有 lock） | **`python -m venv`**（标准库，一定有） | **`conda create -p .venv`**；再不行 → **明示 Python 能力不可用**（**不影响 JS 侧六条通道**） | `fetch-vendor.sh` |
| **代理** | 探测到的本机端口（自动写入 `HOST_PROFILE.md`） | 用户 `.env` 手填 | 直连；再失败 → 明示「需配代理」+ 给命令 | `host-probe.sh` / `SEARCH_RUNTIME.md` |
| **MCP 调用** | 通道首选模式（如 `request` 纯 HTTP） | 通道次选模式（如 `playwright`） | **降级到另一条通道**；仍失败 → **明示不可用**（**绝不编造**） | `SEARCH_RUNTIME.md` 各通道 |
| **宿主注入** | 宿主原生 skills 目录 | 向入口指令文件追加 marker 块（Codex） | 输出三个注入文件绝对路径，让用户手动贴 | `deploy.sh` |

**JS 侧首选 pnpm 的理由（不是偏好，是正确性）**：实测五个 MCP 合并后共用 16 个依赖，其中 `@modelcontextprotocol/sdk` 有 **5 个不同版本区间**、`express` 有 **4.x/5.x 大版本冲突**。pnpm 的隔离布局能让它们各自装各自的；npm 的扁平化会把它们摊在同一层。

**三条纪律**（写入 `AGENTS.md` §1.6）：

1. **必须可观察** —— 降档时要在输出里说明「走了哪一档、为什么」。用户不知道降级 = 降级没发生。
2. **兜底允许放弃** —— 某能力实在不可用时，**明说不可用**是正确的兜底。不择手段地给一个假答案才是违规。
3. **兜底不许污染** —— 任何降级都不得触碰 `~/.qingnang/private/`。

> **验收**：**A37** `AGENTS.md` 含降级链铁律六节且 `CLAUDE.md` 逐字一致；**A38** `fetch-vendor.sh` 的 JS/Python 两条链各有三档条件分支且**兜底档会明示**；**A39** 实测至少走过一次非首选档（本机：pnpm→npm、uv 命中首选）。

### 3.11b ADR-014 · 全链路只允许 Node（**删掉 bash/WSL 依赖**）

| 项 | 内容 |
|---|---|
| **决策** | 本包所有可执行逻辑**只用 Node（.mjs）**。删除全部 `.sh`，`mcp-servers/healthcheck.mjs`、`scripts/qingnang.mjs`、`scripts/vendor-*.mjs` 均为 Node。**不再需要 WSL / Git Bash / Cygwin。** |
| **被否方案** | ① 保留 bash + 要求 Windows 用户装 WSL（真实用户是病友，装 WSL 就是断头路） ② 写 PowerShell + bash 双份（双倍维护，且 PowerShell 执行策略是另一个坑） |
| **理由** | **MCP 的必备运行时就是 Node**——宿主只要装得下 MCP，就必然有 Node。把整条工具链收拢到 Node，**零新增依赖**，却把 Windows 门槛从「装 WSL」降到「装 Node」。 |
| **可逆性** | 高（脚本逻辑不变，只换宿主语言） |
| **后果** | 删除 10 个 `.sh`；`manifest` 的 `command` 从 `sh scripts/xxx.sh` 改为 `node scripts/qingnang.mjs serve <id>`；`mcp-config` 六种格式**全部输出纯 JSON**（机器优先，符合 P1） |

**实测（本机）**：`node --check` 全部通过；`node_modules` 完全移走后 5 条零凭据通道仍能完成 `initialize` 握手。

### 3.11c ADR-015 · MCP 离线 vendor（**一次 clone → 立刻可用**）

| 项 | 内容 |
|---|---|
| **决策** | 7 个 MCP 及其**完整依赖闭包**（265 包）vendor 进仓库 `vendor/node_modules/`（46MB，已裁瘦）。`git clone` 后**不跑 npm install、不联网**即可启动。 |
| **被否方案** | ① 只存 `package-lock.json`（仍需 npm registry，代理不稳时部署就挂） ② git submodule（仍需网络逐子仓拉） ③ 只 vendor 5 个包不含依赖（运行时报 `ERR_MODULE_NOT_FOUND`） |
| **理由** | G1「一键部署真的能一键」，用户是病友不是工程师。**把不确定性从用户机器上挪走**，是唯一能保证的方法。 |
| **可逆性** | 高（删除 `vendor/` 即回退到 npm install 路径） |
| **后果** | `.gitignore` 需 `!vendor/node_modules/**` 例外；`fetch` 改为**优先校验 vendor**（零网络），vendor 不完整才回退 pnpm/npm/yarn；`check` 增加 vendor 完整性断言 |

**目录名必须叫 `node_modules`（踩坑记录）**：
Node 解析 `import 'dotenv'` 时，从文件所在目录逐级向上，在**每个祖先目录 D** 里查 `D/node_modules/dotenv`。
包放在 `vendor/node_modules/<pkg>/` 时，祖先 `vendor` 正好提供 `vendor/node_modules/✓`。
若放 `vendor/mcp/<pkg>/`，祖先里**没有任何目录叫 node_modules**，解析立刻失败（实测 `ERR_MODULE_NOT_FOUND: dotenv`）。

**裁剪策略（跨平台约束优先）**：

| 裁什么 | 省了 |
|---|---|
| sourcemap（`*.map`） | 32 MB |
| TS 类型声明（`*.d.ts` / `*.ts`） | 约 3 MB |
| 测试 / 文档 / CI 配置 | 少量 |
| 非目标平台原生二进制 | 约 12 MB |
| `pdf-parse` 多余 3 个 pdf.js 版本 | 约 21 MB |

**保留的平台（不裁）**：`linux_x64` `linux_arm64` `darwin_x64` `darwin_arm64` `win32_x64` `win32_arm64`。
理由：产物要装到**别人的机器**上，跨平台优先于体积。

**验收**：**A40** `node scripts/vendor-mcp.mjs --verify` 退出码 0；**A41** `node_modules` 移走后 `serve pubmed` / `serve openalex` / `serve bing_cn` / `serve web_search` / `serve unified_trial` 五个通道都完成 `initialize` 握手；**A42** `check` 报出 vendor 包数与保留平台。

### 3.12 数据流（本 CHG 覆盖范围，Phase 3 部分以虚线标出）

```
用户提问
  │
  ├─(宿主启动注入 INJECT.md：宣告青囊存在 + 三条红线)
  │
  └─ SKILL.md 路由表 ──┬─ 文献类 → MCP: pubmed ────────────────┐
                       ├─ 试验类 → MCP: unified-trial ────────┤
                       ├─ 证据类 → MCP: knows(未配→降级 pubmed)┤→ 出处强制标注
                       └─ 知识类 → 本地 RAG（Phase 3，本 CHG 不含）  + 免责声明
                                                                  │
用户报告单/病历 ─(Phase 3，本 CHG 不含)→ MinerU 子进程 → ~/.qingnang/private/
```

---

## 4. 冻结契约与文件清单

### 4.1 `MANIFEST.json`（冻结，只允许新增字段）

```jsonc
{
  "schema_version": 1,
  "pack": "qingnang",
  "pack_version": "0.1.0",
  "brand": "小胰宝社区 · 青囊",
  "generated_at": "<ISO8601>",
  "skill":   { "path": "skills/qingnang",
               "inject_bytes_max": 2048,
               "search_runtime_bytes_max": 8192,
               "skill_bytes_max": 14336 },
  "mcp":     { "manifest": "mcp-servers/manifest.json" },
  "channels": {
    "web_search":    { "credential_required": false, "proxy_capable": true },
    "bing_cn":       { "credential_required": false },
    "pubmed":        { "credential_required": false },
    "openalex":      { "credential_required": false },
    "unified_trial": { "credential_required": false },
    "knows":         { "credential_required": true, "degrade_to": "pubmed" },
    "get_biji":      { "credential_required": false, "status": "reserved_license_pending" }
  },
  "host_profile": { "path": "skills/qingnang/HOST_PROFILE.md", "generated_by": "scripts/qingnang.mjs probe" },
  "data": { "public_pack": null, "private_root": "~/.qingnang/private" },
  "privacy": { "telemetry_allowed_values": ["off"], "private_paths_exportable": false }
}
```

> `data.public_pack: null` 是**有意的**——Phase 3 才装载知识包；`null` 表示「当前无公开数据包」，而非遗漏。

### 4.2 `mcp-servers/manifest.json`（冻结，只允许新增字段；**唯一事实源**）

```jsonc
{
  "schema_version": 2,
  "license_whitelist": ["MIT", "Apache-2.0", "ISC", "BSD-3-Clause"],
  "servers": [
    {
      "id": "web_search",
      "display_name": "青囊·通用网页搜索",
      "server_name": "qingnang_web",
      "package": "open-websearch",
      "version": "2.2.0",
      "license": "Apache-2.0",
      "license_note": "上游仓库 LICENSE 文件为 Apache-2.0；package.json 的 license 字段缺失（None），以上游 LICENSE 文件为准",
      "upstream": "https://github.com/Aas-ee/open-webSearch",
      "transport": "stdio",
      "command": ["npx", "-y", "open-websearch@2.2.0"],
      "env": [
        { "key": "MODE", "value": "stdio", "required": false, "effect_when_missing": "默认 both，会额外监听 HTTP 3000 端口" },
        { "key": "SEARCH_MODE", "value": "request", "required": false, "effect_when_missing": "auto：可能启用 Playwright（需 Chromium）；强制 request 可完全避开浏览器依赖" },
        { "key": "USE_PROXY", "value_from": "host_profile", "required": false },
        { "key": "PROXY_URL", "value_from": "host_profile", "required": false }
      ],
      "proxy": {
        "supported": true,
        "env_keys": ["USE_PROXY", "PROXY_URL"],
        "upstream_default": "http://127.0.0.1:7890",
        "auto_fill_from": "skills/qingnang/HOST_PROFILE.md 的 网络/代理 小节",
        "two_stage_note": "上游 README 明确：安装期代理（npm --proxy，拉包用）与运行期代理（USE_PROXY/PROXY_URL，搜索用）是两件独立的事，必须分两步配"
      },
      "degrade_to": "bing_cn",
      "health": { "kind": "mcp_initialize", "timeout_s": 30 }
    },
    {
      "id": "bing_cn",
      "display_name": "青囊·中文网页搜索",
      "server_name": "qingnang_bing",
      "package": "bing-cn-mcp",
      "version": "1.0.2",
      "license": "MIT",
      "upstream": "https://github.com/yan5236/bing-cn-mcp-server",
      "transport": "stdio",
      "command": ["npx", "-y", "bing-cn-mcp@1.0.2"],
      "env": [],
      "proxy": { "supported": false },
      "degrade_to": null,
      "health": { "kind": "mcp_initialize", "timeout_s": 30 }
    },
    {
      "id": "pubmed",
      "display_name": "青囊·文献检索",
      "server_name": "qingnang_pubmed",
      "package": "mcp-pubmed-llm-server",
      "version": "3.0.0",
      "license": "MIT",
      "license_note": "上游 repo 标 Apache-2.0，npm 元数据写 MIT（不一致）；两者皆宽松，按 npm 实际分发为准",
      "upstream": "https://github.com/PancrePal-xiaoyibao/mcp-pubmed-server-pancrpal",
      "transport": "stdio",
      "command": ["npx", "-y", "mcp-pubmed-llm-server@3.0.0"],
      "env": [{ "key": "NCBI_API_KEY", "required": false, "effect_when_missing": "限速 3 req/s（个人够用）" }],
      "proxy": { "supported": false },
      "degrade_to": null,
      "health": { "kind": "mcp_initialize", "timeout_s": 30 }
    },
    {
      "id": "openalex",
      "display_name": "青囊·学术文献（开放获取）",
      "server_name": "qingnang_openalex",
      "package": "openalex-mcp-server",
      "version": "1.0.5",
      "license": "ISC",
      "upstream": "https://github.com/SecretRichGarden/openAlex-mcp",
      "transport": "stdio",
      "command": ["npx", "-y", "openalex-mcp-server@1.0.5"],
      "env": [{ "key": "OPENALEX_EMAIL", "required": false, "effect_when_missing": "共享池限速；填邮箱可获更快配额" }],
      "proxy": { "supported": false },
      "degrade_to": null,
      "health": { "kind": "mcp_initialize", "timeout_s": 30 }
    },
    {
      "id": "unified_trial",
      "display_name": "青囊·临床试验检索",
      "server_name": "qingnang_trial",
      "package": "unified-trial-mcp",
      "version": "0.3.1",
      "license": "MIT",
      "upstream": "https://github.com/opencare-skillhub/unified-trial-search-mcp-service",
      "transport": "stdio",
      "command": ["npx", "-y", "unified-trial-mcp@0.3.1"],
      "env": [],
      "proxy": { "supported": false },
      "degrade_to": null,
      "health": { "kind": "mcp_initialize", "timeout_s": 30 }
    }
  ],
  "reserved": [
    { "id": "knows", "package": "@xiaoyibao_npm/knows-mcp-server", "reason": "需凭据；repo 待补 LICENSE", "degrade_to": "openalex" },
    { "id": "get_biji", "package": "get-biji-mcp", "reason": "双仓库均无 LICENSE 文件（npm 声明 MIT）", "degrade_to": null }
  ]
}
```

> **废弃（2026-10-14）**：`server_name` 字段原为「DSH 兼容要求」，**DSH 已移出本包（ADR-006）**。该字段**保留**（它是有用的机器标识：可用于生成宿主侧 MCP 工具名前缀，格式约束 `[A-Za-z0-9_-]{1,32}` 是通用防注入实践），但**不再作为 DSH 合规依据**。

> **准入三重门（全部满足）**：`license ∈ license_whitelist` **且** `npm view <pkg> version` 可达 **且** 无凭据或凭据可自动降级。
> **凭据/许可未清的包一律放 `reserved` 段**，不混进 `servers`——这样「设计上预留、实现上未纳入」一眼可辨，不会让人误以为遗漏。

> **KnowS 条目不在本 CHG 的 `servers` 中**（许可债 B2 + 需凭据）。但它在 `MANIFEST.json.channels.knows` 中**声明了降级关系**——即「设计上预留、实现上未纳入」，避免读者误以为遗漏。
> 新增 server 的准入条件（三重门，全部满足）：`license ∈ license_whitelist` **且** `npm view <pkg> version` 可达 **且** 无凭据或凭据可自动降级。

### 4.3 `.env.example`（冻结）

```bash
# ── 增强通道（全部选填；不填 = 零凭据模式，两条主通道照常可用）──────────
# KnowS 医学证据（Phase 2 后启用；申请入口见 README「凭据申请」）
#KNOWS_API_KEY=
#KNOWS_API_BASE_URL=
# NCBI（填了提速；不填限速 3 req/s，个人够用）
#NCBI_API_KEY=

# ── 路径与运行时（免填）──────────────────────────────────────────────
#QINGNANG_HOME=~/.qingnang
# 遥测唯一合法值：off（其他值会被脚本拒绝）
QINGNANG_TELEMETRY=off
```

**凭据装载契约**（K3：实际部署时用户自己填）：
1. `deploy.sh` 首次运行若发现 `.env` 不存在，则从 `.env.example` 复制，并**打印中文指引**告知「在仓库根目录 `.env` 填写」。
2. `.env` 必须在 `.gitignore` 中（A2 覆盖）。
3. `doctor.sh` 读取 `.env` 后逐项输出 `✓`/`⬜`/`❌`；`⬜` 不视为失败（A5）。
4. `deploy.sh --dry-run` **不读取真实凭据值**，只校验变量名与配对关系（A21）。

### 4.4 `doctor.sh` 输出契约（冻结）

逐行 `[序号/总数] 检查项  <符号> <人类可读结论>`，符号集固定为 `✓`（通过）/ `⬜`（选填未配，不算失败）/ `❌`（失败，必须修）。

```
[1/8] 宿主画像      ✓ HOST_PROFILE.md 已生成（2 分钟前）· 代理 127.0.0.1:7890 · 8 核 /32G
[2/8] 运行时        ✓ Python 3.11.14 · ✓ Node 20.x · ✓ npx
[3/8] 网络          ✓ npm registry 可达 · ✓ 目标站点可达（经代理）
[4/8] MCP 握手      ✓ web_search · ✓ bing_cn · ✓ pubmed · ✓ openalex · ✓ unified_trial
[5/8] 凭据矩阵      ⬜ NCBI_API_KEY（选填）· ⬜ OPENALEX_EMAIL（选填）
[6/8] 隐私隔离      ✓ ~/.qingnang/private 权限 0700 · ✓ HOST_PROFILE.md 未入库
[7/8] 遥测          ✓ off（唯一合法值）
[8/8] 技能层        ✓ INJECT.md 1.8KB/2KB · ✓ SEARCH_RUNTIME.md 6.2KB/8KB · ✓ SKILL.md 13KB/14KB

就绪。你现在可以说：
  · 帮我查一下胰腺癌 FOLFIRINOX 方案的最新文献
  · 找一下国内正在招募的胰腺癌临床试验
  · 解释一下 CA19-9 这个指标是什么意思
```

- **退出码契约**：存在任一 `❌` → `exit 1`，否则 `exit 0`。`⬜` **不**导致非零退出（A5 断言）。
- 失败时必须输出**中文修复指引**（指向 README 具体章节）。

> **第 1 项（宿主画像）为何排第一**：代理与运行时是青囊的**第一道门槛**，用户部署卡住九成卡在这里。先说清「本机什么情况」，用户才有信心往下走（ADR-008）。

### 4.5 文件清单（白名单——清单外不得创建）

> **标记说明**：🔨 = **构建产物**（`fetch-vendor.sh` 生成，**已入 `.gitignore`，不入库**）｜🗄️ = **机器相关**（运行时生成，不入库）

```
# ── 治理与元数据（四文件必写四要素，§4.10）──────────────────
AGENTS.md                                  # **面向 Agent**：定位 + 开发逻辑 + 降级链铁律 + 医学五条 + private/ 铁律
CLAUDE.md                                  # 与 AGENTS.md **逐字一致**（cmp 验证）
README.md                                  # **面向人**：免责首屏 + 一键部署 + 能做啥 + 凭据 + 数据安全
CONTRIBUTING.md                            # 贡献指南：红线 + 三道闸 + 准入四条 + 自检命令
LICENSE                                    # Apache-2.0 + 医学免责附加声明
MANIFEST.json                              # §4.1（脚本生成：版本/体积/哈希/通道矩阵/forge 接缝）
.env.example                               # §4.3
.gitignore                                 # private/ + HOST_PROFILE.md + .env + 构建产物
.pre-commit-config.yaml                    # M6
.gitleaks.toml                             # M6
.github/PULL_REQUEST_TEMPLATE.md           # M1（含「本 PR 不含真实患者信息」勾选项）

# ── 依赖声明（环境构建的唯一事实源）──────────────────────────
package.json                               # JS 侧：5 个 MCP **钉死版本** + engines.node>=22.13.0
package-lock.json                          # 锁定完整依赖树（可复现）
pyproject.toml                             # Python 侧：Phase 3 承载 PDF 解析 / 本地 RAG（当前依赖为空）

# ── 脚本 ─────────────────────────────────────────────────────
（已合并进 scripts/qingnang.mjs）                      # 共用：日志/符号/幂等/upsert（**库文件，不设 set，避免污染调用者**）
（已合并进 scripts/qingnang.mjs）                  # 宿主机探测（移植自 dev-host-init，含硬件/代理/构建器/宿主）
（已合并进 scripts/qingnang.mjs）         # HOST_PROFILE.md 渲染（探测值→模板；缺值填兜底文案）
（已废弃，见 ADR-014）           # 生成 MCP 启动垫片（挡住所包管理器目录布局差异）
scripts/qingnang.mjs fetch                    # **环境构建**：JS 首选 pnpm→npm→yarn；Python 首选 uv→venv→conda
scripts/qingnang.mjs probe                      # 调 host-probe.sh → 渲染 HOST_PROFILE.md（**幂等**）
scripts/qingnang.mjs                      # **唯一入口**（跨平台）：serve / fetch / deploy / probe / doctor / check / mcp-config
scripts/phi_scan.mjs                        # 中文 PHI/PII 正则扫描

# ── 技能层（可安装单元，**三个注入文件必须都装**）────────────
skills/qingnang/INJECT.md                  # ≤2KB：宣告存在 + 指路 + 医学三条红线 + 搜索薄提示
skills/qingnang/SEARCH_RUNTIME.md          # ≤8KB：六通道分流表 + 参数要点 + 降级顺序 + 代理说明
skills/qingnang/SKILL.md                   # ≤14KB：总体路由 + 七步执行流 + 铁律 + 自检 + 耦合声明
skills/qingnang/MERGE_CONTRACT.md          # 合并契约：准入四条 + 合并三种 + 耦合契约 + forge 接缝
skills/qingnang/HOST_PROFILE.md.template   # 宿主画像模板（**入库**；探测失败填兜底文案）
skills/qingnang/HOST_PROFILE.md            # 🗄️ **运行时生成 → 入 .gitignore**（机器相关，不共享）
skills/qingnang/references/ethics/README.md            # 本目录说明（规则类，无审校问题）
skills/qingnang/references/ethics/disclaimer.md        # 三条红线 + 免责三处 + 转介话术
skills/qingnang/references/ethics/data-safety.md       # 数据边界 + 给 Agent 的硬约束
skills/qingnang/references/ethics/contribution-ethics.md # 贡献者伦理红线
skills/qingnang/references/pancreas/README.md          # 病种子包说明 + 知识卡规范
skills/qingnang/references/pancreas/_TEMPLATE.md       # 知识卡模板（含必填 frontmatter）
skills/qingnang/references/pancreas/glossary.md         # 术语中英对照（pending-review）

# ── 能力层 ───────────────────────────────────────────────────
mcp-servers/manifest.json                  # §4.2（**MCP 唯一事实源**）
mcp-servers/healthcheck.mjs                 # 遍历 manifest 做 mcp_initialize 握手（含许可白名单校验）
mcp-servers/launch/                        # 🔨 启动垫片（make-launch-shims.py 生成，不入库）

# ── 数据与任务 ───────────────────────────────────────────────
data/synthetic/README.md                   # 说明：仓库内禁真实数据，演示数据在此造
tasks/CHG-20261014-qingnang-mvp/CHANGE.md        # 立项：需求辨析 + 环境实测 + ADR + 风险

tasks/CHG-20261014-qingnang-mvp/SPEC.md           # 本文件
tasks/CHG-20261014-qingnang-mvp/TRACEABILITY.md   # 追溯与证据
```

> **注意**：`data/public/`（公开知识包）**本 CHG 不建**——Phase 3 才需要，届时提 SPEC 修订。
> **注意**：`CONTRIBUTING.md` / `LICENSE` / `MANIFEST.json` 由 M1 交付（本 CHG 内），**不是遗漏**。
> **注意**：`node_modules/` / `.venv/` / `cache/` 是构建与运行产物，已入 `.gitignore`，**不在白名单内是因为它们本就不该入库**。

### 4.6 隐私隔离契约（冻结）

| 规则 | 可执行断言 |
|---|---|
| `~/.qingnang/private/` 权限 `0700` | `stat -c %a` == `700`（A19） |
| 仓库内不得出现 `private/` 实体内容 | `git status --porcelain` 在 `private/probe.txt` 存在时仍为空（A2） |
| `QINGNANG_TELEMETRY` 唯一合法值 `off` | 设为其他值 → `doctor.sh` 报 `❌` 且 `deploy.sh` 拒绝启动（A18） |
| 网络请求仅携带检索关键词 | 契约审查（无自动化断言；由 SPEC §5 评审项覆盖） |
| 导出/分享不得触碰 `private/` | `MANIFEST.json.privacy.private_paths_exportable = false` + `check.sh` 断言 |
| `HOST_PROFILE.md`（含本机代理/硬件）不得入库 | `git status --porcelain` 在其存在时仍为空；`check.sh` 断言其在 `.gitignore` 中（A33） |
| `HOST_PROFILE.md` 不得含真实凭据值 | `phi_scan.mjs` 扫到 `*_API_KEY=` 后跟非空值即失败（A34） |

### 4.7 `README.md` 「一键部署」段落（**冻结契约**，主人 K6 首要交付物）

**这是本项目的第一交付物**——用户拿到后应能**直接复制执行**。写作硬约束：

| 约束 | 可执行判定 |
|---|---|
| 部署段必须位于 README **前 1/3**（不是藏在末尾） | 段落起始行号 < 全文行数 × 0.33（A20 断言） |
| 必须含**开源地址链接**（`https://github.com/PancrePal-xiaoyibao/QingNang`） | 文本包含该 URL（A20） |
| 指令块必须是**可逐字复制执行**的（不含占位符说明文字，除可选凭据行） | 把指令块抽取到临时文件后 `bash` 执行，干净环境一次 `exit 0`（A20） |
| 必须写清「**部署规范引导**」：先做什么、后做什么、卡住看哪里 | 段落含编号步骤 + 一步一个编号（对齐 `AGENTS.md` 说人话规则 R2） |
| 必须写清**凭据非必需**（K3） | 含「不填任何 Key 也能用」的明确表述 + 指向 `node scripts/qingnang.mjs doctor` |
| 必须含**医学伦理与免责**首屏声明（K5） | 含三句：不构成医疗建议 / 数据只留本机 / 社区只做技术分发不担诊疗责任 |

**README 骨架（顺序即优先级，冻结）**：

```
1. 标题 + 一句话（青囊是什么，为谁而做）
2. ⚠️ 医学伦理与免责声明（首屏，不可折叠到后面）
3. 🚀 一键部署（把下面四行复制给任意 Agent）
      └─ 部署咒语代码块（含仓库 URL + deploy + doctor）
      └─ 手动部署（三步，给想自己点的人）
4. ✅ 部署完成后你能做什么（三条示例提问）
5. 🔑 凭据申请（选填，逐项给入口；说明不填也完整可用）
6. 🛡️ 数据安全说明（private/ 目录、遥测 off、网络只发检索词）
7. 📦 包含的能力（MCP 通道表 + 许可证）
8. ❓ 常见问题 / 故障排查
9. 🤝 参与贡献（社区只负责技术分发；如何提交知识卡）
10. ⚖️ 许可证 + 第三方组件声明
```

**部署咒语代码块（逐字模板，随版本更新）**：

````markdown
请把青囊（QingNang）医学能力包装到当前环境：

1. `git clone https://github.com/PancrePal-xiaoyibao/QingNang.git && cd QingNang`
2. `node scripts/qingnang.mjs deploy --mode=source`   # 装依赖 + 拉取 MCP + 建本地索引（幂等，可重复跑）
3. `node scripts/qingnang.mjs deploy --mode=agent`    # 把能力装到你自己（宿主）
4. `node scripts/qingnang.mjs doctor`                 # 逐通道体检，把结果贴回来

不用填任何 API Key 也能用：文献检索与临床试验检索是免费通道。
遇到报错按脚本给的中文提示处理，不要跳过任何一步。
````

> **注意**：第 4 步的 `doctor.sh` 是**用户向 Agent 反馈状态的标准入口**——它输出的 `✓/⬜/❌` 三符号集是冻结契约（§4.4），Agent 据此判断下一步。
> **注意**：`--dry-run`（K3）不写进用户咒语（用户要真部署），但写进 README「开发者/故障排查」章节。

### 4.8 DSH 边界声明 + 实测事实存档（**DSH 不在本包范围**，ADR-006）

> **依据**（实测，非推测）：DSH Desktop 官方仓库 `anywhere-labs/dsh-desktop`（MIT，30,780★）文档 `docs/plugin-development.md` + DSH 上游内核源码 `packages/mcp/mcp-client/src/index.ts`。

**事实 1 — DSH 插件是 Cordis TS 插件，不是 `SKILL.md` 技能文件**

```ts
export const name = 'example-plugin'
export const inject = ['webServer', 'loader']        // 声明式依赖
export function apply(ctx: Context, config: {...}): void { /* ... */ }
```

→ 青囊若要在 DSH 内以**原生插件**形态存在，需写一个 `dsh-plugin-*` npm 包。**本 CHG 不做**（Phase 4，见 U7）。

**事实 2 — MCP server 在 DSH 中是结构化配置，不是自由文本**

DSH 内核的 `StdioConfig` 接口（`packages/mcp/mcp-client/src/index.ts:50-73`）：

| 字段 | 类型 | 约束 / 说明 |
|---|---|---|
| `transport` | `'stdio'` | 选择子进程 stdio 传输 |
| `serverName` | `string` | **必须匹配 `[A-Za-z0-9_-]{1,32}`**，且在活动实例中唯一；DSH 用它生成模型侧工具名 |
| `command` | `string` | 可执行文件 |
| `args` | `string[]` | 直接传参，**不做 shell 插值**（无注入风险） |
| `env` | `Record<string,string>` | 叠加在**已清洗的环境变量**之上 |
| `cwd` | `string` | 子进程工作目录 |
| `toolCallTimeoutMs` | `number` | 每次工具调用超时 |
| `failOnStartupError` | `boolean` | 首连/同步失败时是否让插件激活失败 |
| `reconnect?` | `ReconnectConfig` | 断线重连策略，省略用默认 |

**DSH 生成的工具名形如 `mcp__<serverName>__<rawName>`**。

**事实 3 — `dsh-community-fabric` 的 manifest / capability / 统一事件模型仍是 RFC Draft**，官方文档明确写「**尚不能作为依赖或发布目标**」。

→ **本 CHG 的纪律**：只依赖**已冻结**的 `StdioConfig` 形状，**不碰 Draft 接口**。

**契约（废止）**：原 `deploy.sh --mode=agent --host=dsh` 的职责**已移出本 CHG**（ADR-006）。下列内容**仅作未来 DSH 项目参考**，不得在本包实现：

1. 读 `mcp-servers/manifest.json`，把每个 server 翻译成 `StdioConfig` 形状（映射：`command[0]`→`command`，`command[1:]`→`args`，`server_name`→`serverName`，`env`→`env`）。
2. 写入 DSH 的 MCP 配置位置（**具体路径/写入方式由 M2 实测确定并回填本表**——已知形状、未知位置，不得猜测后静默写错）。
3. 幂等：以 `serverName` 为键做 upsert；不重复追加。
4. `--uninstall` 按 `serverName` 精确删除，不动用户的其它 MCP 条目。
5. 技能层以**指令片段注入**（marker 包裹），不假定 DSH 扫描 `SKILL.md`。

| 待实测项 | 状态 |
|---|---|
| DSH MCP 配置文件路径与格式 | ⬜ M2 实测回填 |
| DSH 指令注入的落点 | ⬜ M2 实测回填 |
| `env` 是否能透传 `.env` 内容（而非仅系统环境） | ⬜ M2 实测回填 |
| DSH Desktop 与 DSH CLI 的配置是否同一份 | ⬜ 未来项目实测 |

---

### 4.9 合并契约 `MERGE_CONTRACT.md`（冻结——本包的核心工程约定）

> **定位澄清（2026-10-14 主人明确）**：「这个项目不是要把所有的开发者项目都拉进去，而是需要把 **skill + MCP 都囊括进来**，尤其是一些明显对于医学工作重要的 skill 和 MCP，都要合并起来，**进行 mcp 工具与 skill 的耦合**，并把这一系列的调用全部进行**内部的路由调用网络与 mcp 工具调用效率的优化**。这个项目本质上是**面对 agent 的开发，不是面对人的**——一切都是为了最大化地服务 agent，让 agent 可以最大化地具备社区目前积累的各种医学能力。」

**三句话概括本包的本质**：

| 维度 | 不是 | 是 |
|---|---|---|
| **什么该进来** | 不是「所有社区仓库都要拉进来」 | **只挑对医学工作重要的 skill 与 MCP**，按能力筛选，不按仓库数量 |
| **进来之后做什么** | 不是「把文件拷进来放着」 | **做耦合**：skill 知道该调哪个 MCP、MCP 的返回怎么喂给 skill；**做路由网络**：多通道串并行、降级、去重、互相引用 |
| **为谁做** | 不是「给人看的文档站」 | **为 Agent 做**：一切以「Agent 能否高效调用」为唯一验收尺度 |

**准入判据（一条仓库要不要进本包，问四个问题）**：

1. **医学相关吗？** 与癌症病友的信息获取、病历处理、指标追踪、心理支持直接相关的 → 考虑纳入。开发者工具、运维脚本、UI 模板 → **不进**。
2. **是能力还是应用？** skill / MCP 是**能力**（进）；完整应用、机器人、小程序、官网是**应用**（不进，只借鉴）。
3. **许可干净吗？** `MIT` / `Apache-2.0` / `ISC` / `MIT-0` / `BSD-3` 可进；`NONE`（无 LICENSE 文件）→ 进 `reserved` 等补；`AGPL` / `NOASSERTION` / 自定义禁商用 → **不进主包**（可能以独立隔离工具形态）。
4. **能不能被 Agent 调用？** 有 `SKILL.md`（可直接装）或 MCP 包（可配）→ 进；只是一堆散脚本、没有调用入口 → 需先改造成 skill 才进。

**合并方式（三种，不允许第四种）**：

| 方式 | 适用 | 做法 | 禁止 |
|---|---|---|---|
| **A. 直接引用** | 许可干净 + npm 已发布 + 无需改代码 | manifest 里写包名 + 钉死版本；skill 里写调用要点 | 禁止把源码拷进本仓（除非 B） |
| **B. 改进后并入** | 上游是 skill、思路对但表达不合本包规范 | 拷入 `skills/qingnang/references/` 或新建独立 skill，**改动处标注来源与改了什么** | 禁止静默改上游语义 |
| **C. 隔离调用** | 许可有传染性（AGPL）或体积大 | 独立子进程/独立 venv，**不进主依赖树**；发行物列明第三方许可 | 禁止与主包代码链接 |

**耦合契约（skill ↔ MCP 必须绑起来，不能各自为政）**：

每个进入本包的 skill **必须**在 `SKILL.md` 中声明三件事：

1. **依赖哪些 MCP**（写 `server_name`，如 `qingnang_pubmed`）
2. **什么时候调它**（触发信号，如「用户问论文」）
3. **拿到的结果怎么用**（输出去向，如「拼成答案的文献段，带 PMID 链接」）

同理，`SEARCH_RUNTIME.md` 的每条通道**必须**写明「哪个 skill 会用它、用它解决什么问题」。

> **反例（禁止）**：MCP 装了但没有任何 skill 说要用它；skill 里写「去搜索」但不说搜哪个通道。
> **验收**：A30 检查每个 MCP ↔ 至少一个 skill/route 有双向引用；A31 检查每个 skill 的依赖声明完整。

---

### 4.10 治理文档的必写内容（冻结——主人要求）

> 主人原话：「这些设计哲学和原则，你要在**README、以及项目根目录的 AGENTS.md 和 CLAUDE.md** 里面，写清楚：**项目定位、开发逻辑、目的、最重要实现的效果**等等。」

**四个文件均写，但角度不同**（不允许互拷全文，否则读者分不清该看哪个）：

| 文件 | 读者 | 必写内容 | 语言风格 |
|---|---|---|---|
| **`README.md`** | **人**（用户 + 贡献者） | ① 一句话定位 ② 医学伦理免责（首屏） ③ 一键部署（§4.7） ④ 能做什么（示例提问） ⑤ 凭据申请 ⑥ 数据安全 ⑦ 包含的能力清单 ⑧ 参与贡献 | 零术语、零黑话；假设读者不懂技术 |
| **`AGENTS.md`** | **Agent**（工作规则） | ① 项目定位（为 Agent 服务，不是为人） ② **开发逻辑**（先动脑子 → 再动手） ③ **医学场景加强项五条**（不诊断/不给剂量/急症引导/出处标注/审校声明） ④ 数据安全铁律（`private/` 不可碰） ⑤ 本包的文件结构与改哪里 ⑥ 修改后的自检命令 | 写给 Agent 的指令定式（第二人称、命令式） |
| **`CLAUDE.md`** | Agent（Claude 系镜像） | **与 `AGENTS.md` 逐字一致**（`cmp` 验证）；不另写内容 | 同上 |
| **`skills/qingnang/MERGE_CONTRACT.md`** | 贡献者 + Agent | **本包的核心工程约定**：四条准入判据 + 三种合并方式 + 耦合契约（§4.9 全文） | 半技术、有例子 |

**必写四要素（每个文件自己表述，不许省）**：

| 要素 | 要求 |
|---|---|
| **① 项目定位** | 一句话说清「这是什么」：小胰宝社区的**医学能力资产包**，为 Agent 而做 |
| **② 开发逻辑** | 怎么干活：先动脑子（项目/环境/需求/目的/用户体验）→ 再动手；能力先合并、再耦合、再优化路由 |
| **③ 目的** | 为什么存在：把社区积累的医学能力，**打包成 Agent 能直接用的工具箱**，不让知识烂在 137 个仓库里 |
| **④ 实现效果** | 用户复制一段指令 → Agent 瞬间具备社区全部医学能力；**路由平滑、调用正确、本机适配** |

> **验收**：**A29** 四个文件均含上述四要素（关键词断言 + 人工评审 J9）。
> **禁止**：把 README 全文拷进 AGENTS.md（读者不同、粒度不同，拷贝会导致两头都不合用）。

---

### 4.11 环境构建契约（冻结——**项目工作区内自足，pull 即可构建**）

> 主人要求：「把青囊认可的 skill + MCP **直接 pull 下来放在这个项目内部**，部署时只需 pull 后**在本项目工作区构建** mcp 和 skill 的环境。」
> 主人补充：「**不要太轻量化**；大小其实没事，**所有 MCP 共享一个环境的时候，性价比很高**。」

**核心设计**：所有能力层的运行环境**落在项目活动区内**，不散落到 `~/.npm` 或全局。

```
<repo>/
├── package.json          ← JS 侧依赖声明（5 个 MCP，**版本钉死**）
├── package-lock.json     ← 锁定完整依赖树（可复现）
├── pyproject.toml        ← Python 侧依赖声明（Phase 3 承载 PDF 解析 / 本地 RAG）
├── node_modules/         ← 🔨 JS 环境（共享，实测 127MB）→ .gitignore
├── .venv/                ← 🔨 Python 环境（项目活动区）→ .gitignore
└── mcp-servers/
    ├── manifest.json     ← **唯一事实源**：5 通道 + 2 reserved，含许可/版本/凭据/降级/代理
    ├── healthcheck.mjs   ← 遍历 manifest 做 mcp_initialize 握手（含许可白名单校验）
    └── launch/           ← 🔨 启动垫片（每通道一个）→ .gitignore
```

**契约条款**：

| # | 条款 | 理由 |
|---|---|---|
| **E1** | 依赖**只声明在** `package.json` / `pyproject.toml`，**版本钉死**（不许 `^` / `~`） | MCP 行为变化直接影响医疗信息检索结果，不可接受漂移 |
| **E2** | 环境构建**只通过** `scripts/qingnang.mjs fetch`（幂等，`--force` 重建） | 单一入口，降级链只有一处实现，可审查 |
| **E3** | `manifest.json` 的 `command` **指向本地垫片**（`mcp-servers/launch/<id>`），**不直接 `npx`** | ① **完全离线启动**（不再联网拉包）② 与 pnpm/npm 目录布局解耦 ③ 垫片知道该加什么预设参数（如 `serve`） |
| **E4** | 垫片由 `make-launch-shims.py` **生成**，不入库 | 它依赖实际安装位置，是构建产物 |
| **E5** | `engines.node >= 22.13.0`，在**前置检查**中拦截 | `unified-trial-mcp` 的硬要求；不满足时给中文升级指引，而非让用户在半途失败 |
| **E6** | MCP 需要子命令时，在 manifest 的 `args` 字段声明（如 `unified_trial: ["serve"]`） | 实测 `unified-trial-mcp` 不带子命令只打印帮助 |
| **E7** | Python 环境构建**失败不算致命** | 六条搜索通道全在 JS 侧；Python 侧当前零依赖（Phase 3 才用）。**不允许让 Python 问题阻断核心能力** |
| **E8** | 构建后**离线可用** | 部署与运行都不再需要拉包（除非 `--force` 重建） |

**为什么共享一个环境，而不是每个 MCP 独立**：

| 维度 | 共享环境（本方案） | 每 MCP 独立环境 |
|---|---|---|
| 磁盘 | 16 个依赖去重，实测 127MB | 每个 MCP 各带一份 `@modelcontextprotocol/sdk` 等，**5 倍冗余** |
| 多版本冲突 | 由 pnpm 隔离布局解决，npm 有风险（已在降级链说明） | 天然无冲突，但完全无法复用 |
| 升级 | 改 `package.json` 一处 + 重跑 `fetch-vendor.sh` | 改 5 处 |
| 一致性 | 所有通道共用同一套运行时，行为可预期 | 各通道运行时可能漂移 |

**实测数据（2026-10-14）**：

| 项 | 值 |
|---|---|
| 五个 MCP 的 npm tarball 合计 | 约 2.1MB（open-websearch 1.1M / unified-trial 524K / pubmed 352K / openalex 124K / bing-cn 52K） |
| 合并依赖 | 16 个（去重后）；其中 6 个被 2+ MCP 共用 |
| 实际安装后 | **127MB**（含完整依赖树） |
| 握手结果 | **5/5 通过**（离线垫片模式） |

> **验收**：**A40** `git ls-files` 不含 `node_modules/` / `.venv/` / `mcp-servers/launch/`；**A41** 删掉 `node_modules/` 后重跑 `qingnang.mjs fetch` 能恢复；**A42** 构建完成后**断网**仍能通过 `healthcheck.mjs`（离线可启动）。

---

## 5. 里程碑

### M1 — 仓库骨架与治理文件

| 项 | 内容 |
|---|---|
| 依赖 | 无 |
| 产出 | §4.5 中「治理与元数据」全部文件 |
| 验收 | **A1** `git ls-files \| sort` 与 §4.5 白名单逐条比对一致（无清单外文件）<br>**A2** 隔离断言：`touch private/probe.txt` 与 `~/.qingnang/private/probe.txt` 后 `git status --porcelain` 输出为空<br>**A3** `MANIFEST.json` 可被 6 个断言校验（schema_version / pack / 三个 channels / privacy） |
| 检查命令 | `node scripts/qingnang.mjs check --only=manifest,whitelist,isolation` |
| 风险 | 白名单过严会拖慢开发 → 允许提 SPEC 修订，**不允许静默越界** |
| 回滚 | 全部为新增文件，`git revert` 或删除即回到空仓库态 |

### M2 — 部署与体检脚本

| 项 | 内容 |
|---|---|
| 依赖 | M1 |
| 产出 | `scripts/qingnang.mjs`、`scripts/qingnang.mjs`（`serve`/`fetch`/`deploy`/`probe`/`doctor`/`check`/`mcp-config`）、`scripts/phi_scan.mjs`、`mcp-servers/healthcheck.mjs` |
| 验收 | **A4** 幂等：`deploy.sh --mode=source` 连跑两次均 `exit 0`，第二次不改变已装产物（对安装目录取 hash 比对）<br>**A5** `doctor.sh` 退出码契约：无凭据档 `exit 0`；人为破坏一个 MCP `command` 后 `exit 1` 且输出中文修复指引<br>**A6** `deploy.sh --mode=agent --host=<h>` 在 **至少 2 个 A 类宿主**安装成功；ADR-004 表回填实测结论<br>**A18** `QINGNANG_TELEMETRY=on` 时 `deploy.sh` 拒绝启动且 `doctor.sh` 报 `❌`<br>**A19** `~/.qingnang/private` 权限为 `0700`<br>**A20** README「一键部署」契约（§4.7）：段落位置 < 前 1/3、含仓库 URL、指令块抽取后干净环境一次 `exit 0`、含免责三句<br>**A21** `deploy.sh --dry-run`：**不写任何文件、不读真实凭据值**，仅校验「配置装载 → 通道发现 → 路由选择」，`exit 0`（K3）<br>**A22** `--mode=agent --host=<h>` 写入为**幂等 upsert**（连跑两次不产生重复条目），`--uninstall` 只删自己的条目<br>**A27** `probe-host.sh` **幂等且失败安全**：连跑两次 `exit 0`；字段缺失时 `HOST_PROFILE.md` 填「未检测到」兜底文案，**不留裸 `{{}}`**<br>**A28** `deploy.sh --mode=agent` **必装三个注入文件**（`INJECT.md` / `SEARCH_RUNTIME.md` / `HOST_PROFILE.md`），缺任一即 `exit 1`
| 检查命令 | `node scripts/qingnang.mjs check --only=deploy,doctor` + `bash -n` 全脚本 + `tests/acceptance/test_deploy.py` |
| 风险 | R8（跨宿主路径矩阵未定义）→ 由 ADR-004 限为 **A 类宿主**（有 `skills/` 惯例）+ marker 幂等策略兜<br>R18（`open-websearch` 可能需 Chromium）→ `doctor.sh` 显式提示 + 提供「仅 request 模式」降级路径 |
| 回滚 | `deploy.sh` 需支持 `--uninstall`（幂等副作用的最小回退）；脚本本身删除即回滚 |

### M3 — 技能层 v0

| 项 | 内容 |
|---|---|
| 依赖 | M1 |
| 产出 | `skills/qingnang/INJECT.md`、`SEARCH_RUNTIME.md`、`SKILL.md`、`MERGE_CONTRACT.md`、`HOST_PROFILE.md.template`、`references/ethics/*.md`、`references/pancreas/*.md` |
| 验收 | **A7** 体积：`INJECT.md` ≤2048B、`SEARCH_RUNTIME.md` ≤8192B、`SKILL.md` ≤14336B（字节数断言）<br>**A8** `INJECT.md` 含三条医学红线关键词（不做诊断 / 不给用药建议 / 隐私不出机）<br>**A9** 每张知识卡 frontmatter 含 `source` + `reviewed_by`（无审校时显式 `pending-review`）+ 正文声明「未经医学审校」<br>**A24** `INJECT.md` **含搜索引导语但不含具体工具清单**（断言：出现 `SEARCH_RUNTIME` 字样，且**不出现** `open-websearch` / `bing-cn-mcp` 等包名）<br>**A25** `SEARCH_RUNTIME.md` 含六条通道（§3.5 分流表）且每条注明「哪个 skill 用它、解决什么」<br>**A26** `SKILL.md` 含「涉搜索先读 `SEARCH_RUNTIME.md`」引导语<br>**A29** `README.md` / `AGENTS.md` / `CLAUDE.md` / `MERGE_CONTRACT.md` **均含四要素**（项目定位 / 开发逻辑 / 目的 / 实现效果）<br>**A31** 每个 skill 的 `SKILL.md` 声明了「依赖哪些 MCP / 何时调 / 结果怎么用」三件事 |
| 检查命令 | `node scripts/qingnang.mjs check --only=skill`（含体积 + frontmatter schema 校验） |
| 风险 | 知识卡内容质量（医疗责）→ 只做「要点摘录 + 来源链接」，**不做原创医学结论**；严格遵循母文档 §6.2 的 NCCN 处置 |
| 回滚 | 新增文件，删除即回滚 |

### M4 — **六条搜索通道**接入（其中四条零凭据）

| 项 | 内容 |
|---|---|
| 依赖 | M1、M2 |
| 产出 | `mcp-servers/manifest.json`（§4.2）、`mcp-servers/healthcheck.mjs` |
| 验收 | **A10** manifest 中每个 server 的 `version` 与 `npm view <pkg> version` 一致<br>**A11** `healthcheck.mjs` 对每个 server 完成 MCP `initialize` 握手并打印 server info（超时视为失败）<br>**A12** 每个 server 的 `license ∈ license_whitelist`（`MIT` / `Apache-2.0` / `ISC` / `BSD-3-Clause`）<br>**A30** 每个 server 在 `SEARCH_RUNTIME.md` 或至少一个 skill 中有**双向引用**<br>**A32** 若 H5 成立（`open-websearch` 必须 Chromium），则 `qingnang.mjs doctor` 在「仅 request 模式」下仍全绿 |
| 检查命令 | `node scripts/qingnang.mjs check --only=mcp && node mcp-servers/healthcheck.mjs` |
| 风险 | H1（无凭据能否握手/返回）→ 某条通道不可用时**逐一登记**并写明降级到哪条，**不得静默放宽**<br>H5（`open-websearch` 是否必须 Chromium）→ 若必须，登记 R18 并在 `doctor.sh` 给「仅 request 模式」降级提示 |
| 回滚 | 从 manifest `servers` 移除条目 |

### M5 — 路由与降级链

| 项 | 内容 |
|---|---|
| 依赖 | M3、M4 |
| 产出 | `SKILL.md` 路由表 + 降级链章节（本文档 §3.5 的可执行化） |
| 验收 | **A13** `SKILL.md` 含降级链与「绝不编造未检索到的内容」条款（关键词断言）<br>**A23** **六类问题的通道选择一致性**（ADR-010 的 E2）：对「一般搜索 / 中文搜索 / 文献 / 试验 / 高级证据 / 病友经验」各跑一次，**实际选择的通道与 §3.5 分流表一致**；偏差即失败<br>**A14** 无凭据端到端：一次 PubMed 检索返回 ≥1 条结果且含 PMID、标题、链接<br>**A15** 无凭据端到端：一次试验检索（unified-trial）返回 ≥1 条结果且含登记号<br>**A15b** 路由 dryrun（K3）：**无凭据** → 证据类问题自动降 PubMed，且**可观察到降级事实**（输出中明示走了哪条通道），不报错、不静默；**若提供真实 `KNOWS_API_KEY`** 则追加断言「路由命中 KnowS」。凭据不可得时本项记 `⚠️` 并写明原因（**不得记为 ✅**） |
| 检查命令 | `node scripts/qingnang.mjs check --only=route`（A13）；A14/A15/A15b 走 `tests/acceptance/` 端到端脚本 |
| 风险 | 端到端测试依赖外网与上游服务可用性 → 断言允许「网络不可达」时记 `⚠️` 而非失败，但**必须在证据文件写明** |
| 回滚 | 路由表回退为「仅 PubMed」单通道 |

### M6 — 第一道敏感信息闸

| 项 | 内容 |
|---|---|
| 依赖 | M1 |
| 产出 | `.pre-commit-config.yaml`、`.gitleaks.toml`、`scripts/phi_scan.mjs`、`.github/PULL_REQUEST_TEMPLATE.md` |
| 验收 | **A16** 正向：放入含假身份证号/手机号/住院号的 fixture → `pre-commit run --all-files` **必须失败**；负向：干净仓库 → 通过<br>**A17** 放入假 API Key fixture → gitleaks 命中（`pre-commit` 自动拉取 gitleaks 二进制，本机当前未安装，属预期）<br>**A33** `HOST_PROFILE.md` 在 `.gitignore` 中且不入库（与 §4.6 对应）<br>**A34** `HOST_PROFILE.md` **不含真实凭据值**（`phi_scan.mjs` 扫到 `*_API_KEY=` 后跟非空值即失败） |
| 检查命令 | `node scripts/qingnang.mjs check --only=guard` |
| 风险 | 规则误报影响贡献意愿 → 规则集需附「为什么这算敏感 + 怎么改」的中文提示；允许 `# phi-scan: ignore` 行级豁免（须在 PR 说明理由） |
| 回滚 | 移除 `.pre-commit-config.yaml`（CI 闸与 AI 复审属 Phase 4，不在本 CHG） |

---

## 6. Definition of Ready / Definition of Done

**DoR**（见 CHANGE §8）：B1（PRD）解决 + D5（仓库名/署名）解决 + D1 有方向 + **本 SPEC 明确批准**。未满足不得开工。

**DoD**（见 CHANGE §9）：

1. M1–M6 全部产出物落盘，SPEC 契约逐条实现，**清单外无越界文件**。
2. 验收锚点 **A1–A36** 全绿（网络类例外按 §5 规定记 `⚠️` 并写明原因）。
3. **端到端**：干净环境按 README 部署咒语一次跑通 → `doctor.sh` 全绿（无凭据档）→ 完成一次文献检索 + 一次试验检索。
4. **降级链两态**：有/无凭据两种状态下行为符合 §3.5 分流表预期。
5. **双宿主安装证据**：A 类宿主 ≥ 2 个安装成功，各一条验证命令证据。
6. **三个注入文件都装齐**（`INJECT.md` / `SEARCH_RUNTIME.md` / `HOST_PROFILE.md`，A28）。
7. **隐私隔离可执行断言**通过（A2 / A19 / A33 / A34）。
8. **四端核对**（仓库脚本 / 能力层 / 内置技能 / 宿主注入）均有产出。
9. **forge 接缝完整**（A35 / A36）：零宿主专属代码，五条接缝各有稳定产物。
10. **品牌署名正确**：README 首屏与 `MANIFEST.json` 以「小胰宝社区 · 青囊」署名。
11. **commit / push 待授权**（独立 Gate）。

---

## 7. 评审与交付 Gate

| Gate | 内容 | 谁能过 |
|---|---|---|
| G-1 **SPEC 评审** | 本文件 + CHANGE + TRACEABILITY 提交评审 | 主人 |
| G-2 **SPEC 批准** | 显式批准 → `status: approved`，记录 `approved_by` / `approved_at` / `version` | 主人（**禁止自动批准**） |
| G-3 **里程碑 commit** | 每里程碑完成后提交（模板见 CHANGE §5） | 主人授权后 |
| G-4 **push** | 全部里程碑完成后 | 主人授权后（**独立于 G-3**） |
| G-5 **公开发布** | 需 U2（品牌落点）+ U3（许可证）已决 | 主人 |
| G-6 **Phase 3+ 准入** | 需 B2（许可债）+ B3（再分发条款）书面结论 | 主人 + 社区 |

**复盘触发**：任一里程碑出现「需改冻结契约」或「验收锚点无法达成」时，**停止执行，提 SPEC 修订**（版本 +1），不就地改契约。

---

## 8. 追溯与证据计划

- 追溯矩阵落 `tasks/CHG-20261014-qingnang-mvp/TRACEABILITY.md`：**需求/母文档章节 → 本 SPEC 章节 → 里程碑 → 验收锚点 → 实测证据（命令 + 输出）**。
- 证据文件：`EVIDENCE.md`（由执行阶段产出，逐锚点贴命令与原始输出；网络类断点记 `⚠️` 并写原因）。
- 基线可复核命令集中在 TRACEABILITY §6（参照 Starchart 同类章节），一律**仓库根目录执行 + 不写本机绝对路径**（脱敏铁律）。
- 每里程碑完成即在 TRACEABILITY 更新状态：`✅ 已完成` / `⬜ 待实现` / `⚠️ 已知缺口`。

---

## 9. 回滚总览（§5 各里程碑回滚的汇总视图）

| 里程碑 | 产物性质 | 回滚动作 | 残留风险 |
|---|---|---|---|
| M1 | 新增文件 | 删除/`revert` | 无 |
| M2 | 新增文件 + 写入宿主目录 / DSH 配置 | `deploy.sh --uninstall` + 删脚本 | 宿主目录副本 + DSH MCP 配置条目（`--uninstall` 必须按 `serverName` 精确删净，A22 覆盖，**不得误删用户其它 MCP**） |
| M3 | 新增文件 | 删除 | 无 |
| M4 | 配置 + npm 拉取 | 移除 manifest 条目 | npm 缓存残留（无害） |
| M5 | 修改 `SKILL.md` | 路由表回退单通道 | 无 |
| M6 | 新增 hook 配置 | 移除 `.pre-commit-config.yaml` | 已安装的 hook 需 `pre-commit uninstall` |
