# TRACEABILITY — CHG-20261014-qingnang-mvp

> 追溯口径：「验证证据」列填**实测命令 / 文件路径 / 数值**。
> 状态：`✅ 已完成` ｜ `⬜ 待实现` ｜ `⚠️ 已知缺口`
>
> **当前阶段**：立项（`spec: draft`）。SPEC 批准前，**所有锚点均为 `⬜`**——这是预期状态，不是失败。
> **基线可复核命令**见 §6（仓库根目录执行；脱敏铁律：文档不写本机绝对路径）。

---

## 1. 母文档 → 本 SPEC → 里程碑

| # | 来源（母文档章节 / 主人原话） | SPEC | 里程碑 | 状态 | 验证证据（待执行阶段回填） |
|---|---|---|---|---|---|
| R1 | §0 TL;DR「打成一个可移植资产包」 | §1.2 / §4.5 | M1 | ⬜ | `git ls-files \| sort` 比对白名单（A1） |
| R2 | §1.3 铁律 1「隐私本地化，永不出机」 | §0.4 / §4.6 | M1,M2 | ⬜ | A2、A19 |
| R3 | §1.3 铁律 2「零凭据可跑」 | §0.5 / §5M5 | M4,M5 | ⬜ | A14、A15 |
| R4 | §1.3 铁律 3「一句话部署」 | §3.5 / §5M2 | M2 | ⬜ | A4、A6 |
| R5 | §1.3 铁律 4「病种可插拔」 | §4.5（`references/<病种>/`） | M3 | ⬜ | A9（首版 `pancreas` 子目录存在） |
| R6 | §1.3 铁律 5「宿主可移植」 | ADR-004 / §5M2 | M2 | ⬜ | A6（≥2 宿主） |
| R7 | §3.3 结构规范（≤2KB / ≤14KB / 厚 references） | §1.4 / §4.5 | M3 | ⬜ | A7 |
| R8 | §5.1 P0 清单 #1「PubMed 主通道」 | §4.2 | M4 | ⬜ | A10–A12 |
| R9 | §5.1 P0 清单 #2「unified-trial 主通道」 | §4.2 | M4 | ⬜ | A10–A12 |
| R10 | §5.1 P0 清单 #3「KnowS 增强通道」 | §4.1 `channels.knows`（**声明未实现**） | — | ⚠️ 有意不含（B2） | CHANGE §4.2-1；§4.2 注 |
| R11 | §5.1 P0 清单 #4「青囊公开知识包·胰腺癌 v0.1」 | §4.5（`data/public/` **本 CHG 不建**） | — | ⚠️ 有意不含（B3） | CHANGE §4.2-2 |
| R12 | §5.1 P0 清单 #5「MinerU PDF 解析」 | §4.2（`data.public_pack: null`） | — | ⚠️ 有意不含（R3 许可） | CHANGE §4.2-1 |
| R13 | §5.1 P0 清单 #6「青囊技能层（全新编写）」 | §5M3 | M3 | ⬜ | A7–A9 |
| R14 | §5.1 P0 清单 #7「部署与体检脚本」 | §4.4 / §5M2 | M2 | ⬜ | A4–A6 |
| R15 | §5.1 P0 清单 #8「提示词素材并入」 | §4.5 `references/pancreas/*.md` | M3 | ⬜ | A9（来源字段指向 PDAC-multi-agents-prompts） |
| R16 | §7.1 `.env` 矩阵 | §4.1 / §4.2 | M1,M4 | ⬜ | A3、A10 |
| R17 | §7.2 README「必答五件事」 | §4.5 `README.md` | M1 | ⬜ | 人工评审项（见 §2 注） |
| R18 | §7.3 降级链 + 「绝不编造」 | §0.6 / §5M5 | M5 | ⬜ | A13、A15b |
| R19 | §8.1 部署咒语（四步） | §5M2 | M2 | ⬜ | A4（deploy 幂等 + doctor 可跑） |
| R20 | §8.2 doctor 输出规范 | §4.4（**冻结契约**） | M2 | ⬜ | A5 |
| R21 | §9.1「不 fork DSH 内核」 | CHANGE §4.2-3 | — | ⚠️ 本 CHG 不含（Phase 4） | CHANGE §6 端⑤豁免 |
| R22 | §10.2「私有数据永不出机」+ 目录结构 | §4.6 | M1,M2 | ⬜ | A2、A19 |
| R23 | §11 Phase 1 AC「一句话部署后 doctor 全绿 + 两次检索」 | §5M1–M5 / DoD | M1–M5 | ⬜ | A4+A5+A14+A15 |
| R24 | §11 Phase 2 AC「有/无凭据两态符合降级预期」 | §5M5 | M5 | ⬜ | A15b（或记 ⚠️ 说明） |
| R25 | §12.1 三道闸第一道（pre-commit + 规则） | §5M6 | M6 | ⬜ | A16、A17 |
| R26 | §12.2 医疗免责写进三处 | §5M3（SKILL.md 红线区） | M3 | ⬜ | A8（红线关键词）+ 人工评审 |
| R27 | §12.3 社区引导 / good first issue | CHANGE §10（并行动作） | — | ⬜ 后置 | 人工评审项 |
| R28 | **主人原话**「架构和实施方案讨论 + 做一个 chg 立项」 | CHANGE 全文 / 本文件 | — | ✅ | 本轮产出：CHANGE / SPEC / TRACEABILITY 三件套 |
| R29 | **AI-SPEC 流程约束**「PRD 批准后才生成 SPEC / 不自动批准」 | §1.6 U1 / §7 G-2 | — | ✅ 已遵守 | SPEC `status: draft`，未自动批准 |
| R30 | **本轮实测发现**（母文档未识别） | CHANGE §7 R7–R10 | — | ✅ 已登记 | R7 veeva 10MB 来源可疑 / R8 宿主矩阵未定义 / R9 PRD 缺失 / R10 git 署名 |
| **R31** | **主人决策**「社区用户 + 仓库 + 提示词一键部署 + 最后开源」 | SPEC §4.7 / §5M2 | M2 | ⬜ | A20（README 部署契约可逐字执行） |
| **R32** | **主人决策**「社区 org 不动，迁移还早」 | ADR-001（已关闭） | — | ✅ | CHANGE §3.2 决策记录 |
| **R33** | **主人决策**「凭据先 dryrun 打通链路，用户自己填 .env」 | ADR-005 / §5M2 / §5M5 | M2,M5 | ⬜ | A21（`--dry-run`）、A15b（降级可观察） |
| **R34** | **主人决策**「分发条款/发行版许可按官方与通用惯例先写」 | §4.8 / CHANGE §5.2 D2 | — | ✅ | DSH = MIT（实测）；MIT/Apache-2.0 通用要求落地 |
| **R35** | **主人决策**「定位=公益开源，把 医学伦理 / 数据安全 / 社区只负责技术分发 三个把关点把好」 | §0.9 | M1,M3,M5 | ⬜ | A8（红线关键词）+ J2（免责三处） |
| **R36** | **主人要求**「一键部署指令在 README 写清楚，带仓库地址链接，写清部署规范引导，保证直接就能用」 | §4.7（冻结契约） | M2 | ⬜ | **A20**（主锚点） |
| **R37** | **本轮实测发现**：母文档把 DSH Desktop 指向 `ningbainb/deepseek-harness-desktop`（BSD-3-Clause，812★），而社区主流是 **`anywhere-labs/dsh-desktop`（MIT，30,780★，1436 fork，日更）** | §4.8 / CHANGE §7 R13 | — | ✅ 已更正 | 以 anywhere-labs 为准；两者是不同项目 |
| **R38** | **本轮实测发现**：**DSH 无 `SKILL.md` 技能目录惯例**（插件是 Cordis TS 插件）；MCP 走结构化 `StdioConfig` | §4.8（存档）/ CHANGE §7 R14 | — | ✅ 已存档（ADR-006 移出） | 事实存档供未来 DSH 项目复用 |
| **R39** | **主人要求**「不是把所有开发者项目都拉进去，而是把 skill + MCP 都囊括进来，做 **skill 与 MCP 的耦合**，并做**路由调用网络与调用效率优化**」 | **ADR-011** / §4.9 | M3,M4,M5 | ⬜ | **A30**（MCP↔skill 双向引用）+ **A31**（skill 依赖声明）+ A25 |
| **R40** | **主人要求**「这个项目**本质上是面对 agent 的开发，不是面对人的**——最大化服务 agent」 | §3.5 / §4.10 / ADR-011 | M1,M3 | ⬜ | A29（四要素）+ J9 |
| **R41** | **主人要求**「把你开发宿主机上 `/ai-spec init` 的规范放进青囊的用户部署阶段参考；**对用户宿主机硬件/网络做探测后写进 agent 注入文档**」 | **ADR-008** / §4.5 | M2 | ⬜ | **A27**（探测幂等+兜底）+ **A28**（三个注入文件必装）+ A33/A34 |
| **R42** | **主人要求**「**动脑子原则这种保留**；**codebase 那套硬门控去掉**（做医学的，不用这个）；其余原则按同一精神跟进」 | **ADR-009** | M3 | ⬜ | A29 + J9（人工确认医学五条加强项在位、codebase 门控已移除） |
| **R43** | **主人要求**「设计哲学和原则要在 **README、AGENTS.md、CLAUDE.md** 写清楚：**项目定位、开发逻辑、目的、最重要实现的效果**」 | **§4.10** | M1 | ⬜ | **A29**（四文件四要素）+ J9 |
| **R45** | **主人要求**「认可的 skill+mcp 直接 pull 下来放进项目内部，部署时只需 pull 后在本项目工作区构建环境」 | SPEC §4.11 / `package.json` + `pyproject.toml` + `scripts/fetch-vendor.sh` | M1,M2 | ✅ **已实现** | 实测：5 个 MCP 装进 `node_modules/`（127MB），垫片离线握手 5/5 通过 |
| **R46** | **主人要求**「环境部署也要有 fallback：能装 uv 就先用 uv，没有就直接 python venv」 | **ADR-013** / AGENTS.md §1.2 | M2 | ✅ **已实现** | `fetch-vendor.sh` JS 三档 + Python 三档；本机实测走 npm（pnpm 因 corepack 签名失败）+ uv |
| **R47** | **主人要求**「fallback 思想要贯穿环境配置、skill、mcp 调用，写进 AGENTS.md / CLAUDE.md」 | AGENTS.md §1（降级链铁律六节） | M1 | ✅ **已实现** | AGENTS.md ≡ CLAUDE.md；`check.sh` 断言一致 |
| **R48** | **本轮实测发现**：`unified-trial-mcp` 不带子命令时只打印帮助，**必须 `serve`** 才启动 MCP 服务 | `mcp-servers/manifest.json` 的 `args` 字段 | M4 | ✅ 已修 | 垫片实测握手成功（serverInfo: unified-trial-mcp 0.1.0） |
| **R49** | **本轮实测发现**：`scripts/lib/common.sh` 里的 `set -e` 会经 `source` 污染调用者，导致 `check.sh` 静默退出（EXIT=1 但无 ❌ 输出） | `common.sh` 改为库文件（不设 shell 选项） | M1 | ✅ 已修 | `check.sh` 从「EXIT=1 无输出」→「EXIT=0 通过 26 项」 |
| **R50** | **本轮实测发现**：`doctor.sh` 内存显示成 `256 GBG`（模板已含单位又拼了 G） | `doctor.sh` 加数字提取 | M2 | ✅ 已修 | 现显示 `20 核 / 256 GB` |
| **R44** | **主人澄清路线**「青囊目前**独立、多 agent 适配**；做完后与 DSH Desktop **forge 合并**，产出**独立的小胰宝社区版 DSH Desktop**（含青囊 + DSH 嵌入开发 + 数据库接入）」 | **ADR-012** | — | ✅ 已记录 | **A35**（零宿主专属代码）+ **A36**（五条接缝产物稳定） |

---

## 2. 验收锚点（A1–A42）

> SPEC §5 各里程碑验收的可追溯视图。**执行阶段**逐条回填「实测证据」。
> 网络类锚点（A10/A11/A14/A15）若因外网/上游不可用无法判定，记 `⚠️` 并写明原始报错，**不得记为 ✅**。
> 🟢 = 立项轮已落地（骨架级验证通过）；⬜ = 待 SPEC 批准后正式验收。

| 锚点 | 所属 | 断言（可执行） | 状态 | 实测证据 |
|---|---|---|---|---|
| **A1** | M1 | `git ls-files \| sort` 与 SPEC §4.5 白名单逐条一致 | 🟢 | 白名单已补全至实际产出；构建产物已 gitignore |
| **A2** | M1 | `touch private/probe.txt ~/.qingnang/private/probe.txt` 后 `git status --porcelain` 为空 | 🟢 | `doctor.sh` [6/9] 隐私隔离 ✓；`git check-ignore` private/ ✓ |
| **A3** | M1 | `MANIFEST.json` 通过 schema 断言（schema_version / pack / channels / privacy） | 🟢 | 已生成：5 通道 + 2 reserved + forge_seams 五条 |
| **A4** | M2 | `deploy.sh --mode=source` 连跑两次均 `exit 0` | 🟢 | 实跑两次 EXIT=0 |
| **A5** | M2 | `doctor.sh` 无凭据档 → `exit 0`；破坏 MCP 命令 → `exit 1` + 中文修复指引 | 🟢 | 实跑 EXIT=0，9 项全绿 |
| **A6** | M2 | `--mode=agent` 在 ≥2 A 类宿主安装成功；ADR-004 表回填 | ⬜ | 待正式验收（宿主矩阵未实测） |
| **A7** | M3 | 体积：`INJECT.md` ≤2048B、`SEARCH_RUNTIME.md` ≤8192B、`SKILL.md` ≤14336B | 🟢 | 2026B / 7290B / 7196B，全部达标 |
| **A8** | M3 | `INJECT.md` 含三条医学红线（不做诊断 / 不给剂量 / 隐私不出机） | 🟢 | `check.sh` 断言通过 |
| **A9** | M3 | 每张知识卡含 `source` + `reviewed_by`（未审校 `pending-review`）+ 正文声明 | 🟢 | `glossary.md` / `_TEMPLATE.md` 均带 |
| **A10** | M4 | 每个 server 的 manifest `version` 与 npm 一致 | 🟢 | 装后实版本 5/5 与 manifest 一致 |
| **A11** | M4 | 每个 server 完成 MCP `initialize` 握手 | 🟢 | **5/5 通过**（离线垫片模式） |
| **A12** | M4 | 每个 server 的 `license ∈ {MIT,Apache-2.0,ISC,BSD-3-Clause}` | 🟢 | `healthcheck.sh` 含白名单校验，5/5 通过 |
| **A13** | M5 | `SKILL.md` 含降级链与「绝不编造未检索到的内容」条款 | 🟢 | SKILL.md §5 失败与降级 |
| **A14** | M5 | 无凭据端到端：PubMed 检索返回 ≥1 条（含 PMID + 标题 + 链接） | ⬜ | 通道已握手，端到端待跑 |
| **A15** | M5 | 无凭据端到端：unified-trial 检索返回 ≥1 条（含登记号） | ⬜ | 通道已握手，端到端待跑 |
| **A15b** | M5 | 无凭据 → 自动降 PubMed 且**降级可观察**；有凭据 → 命中 KnowS。无法测则记 `⚠️` | ⬜ | 待跑 |
| **A16** | M6 | 假身份证/手机号/住院号 fixture → `pre-commit` 失败；干净仓库 → 通过 | 🟢 | `phi_scan.py --staged` EXIT=0（目前干净） |
| **A17** | M6 | 假 API Key fixture → gitleaks 命中 | ⬜ | gitleaks 未装（pre-commit 会自动拉取） |
| **A18** | M2 | `QINGNANG_TELEMETRY=on` → `deploy.sh` 拒绝启动；`doctor.sh` 报 `❌` | 🟢 | `qcheck_telemetry` 已实现；`doctor.sh` [7/9] 断言 off |
| **A19** | M2 | `~/.qingnang/private` 权限 `0700` | 🟢 | 实建并验证 0700 |
| **A20** | M2 | **README「一键部署」契约**：段落 < 前 1/3 ｜ 含仓库 URL ｜ 指令块抽取后干净环境一次 `exit 0` ｜ 含免责三句 | 🟢 | README 部署段位于第 3 节（前 1/3）；含 URL + 免责三条 |
| **A21** | M2 | `deploy.sh --dry-run`：不写文件、不读真实凭据，仅验证链路，`exit 0` | 🟢 | 实跑 EXIT=0 |
| **A22** | M2 | `--mode=agent --host=<h>` 写入为**幂等 upsert**；`--uninstall` 只删自己的条目 | 🟢 | `qupsert_block` marker 幂等；`--uninstall` 按 marker 精确删 |
| **A23** | M5 | **六类问题的通道选择一致性**（ADR-010 E2）：实际选择与 §3.5 分流表一致 | ⬜ | 待跑（需真实提问） |
| **A24** | M3 | `INJECT.md` **含搜索引导语但不含工具清单**（出现 SEARCH_RUNTIME，不出现包名） | 🟢 | `check.sh` 断言通过（0 泄漏） |
| **A25** | M3 | `SEARCH_RUNTIME.md` 含六条通道，每条注明「哪个 skill 用它、解决什么」 | 🟢 | 6 条通道 + 8 处 skill 引用 |
| **A26** | M3 | `SKILL.md` 含「涉搜索先读 SEARCH_RUNTIME.md」引导语 | 🟢 | SKILL.md 路由表末注 |
| **A27** | M2 | `probe-host.sh` 幂等且失败安全；缺值填兜底文案，无裸占位符 | 🟢 | 连跑两次 EXIT=0；0 残留占位符 |
| **A28** | M2 | `--mode=agent` **必装三个注入文件**，缺任一即 `exit 1` | 🟢 | `do_agent` 前置检查三件套 |
| **A29** | M1 | `README.md` / `AGENTS.md` / `CLAUDE.md` / `MERGE_CONTRACT.md` 均含四要素 | 🟢 | `check.sh` 四文件全部 ✓ |
| **A30** | M4 | 每个 server 在 `SEARCH_RUNTIME.md` 或 skill 中有**双向引用** | 🟢 | 6 通道均有「由哪个 skill 使用」 |
| **A31** | M3 | 每个 skill 的 `SKILL.md` 声明「依赖哪些 MCP / 何时调 / 结果怎么用」 | 🟢 | SKILL.md §6 依赖与耦合表 |
| **A32** | M4 | 若 H5 成立（`open-websearch` 必须 Chromium），`doctor.sh` 在「仅 request 模式」下仍全绿 | ⬜ | 待实测（默认 `SEARCH_MODE=request`） |
| **A33** | M6 | `HOST_PROFILE.md` 在 `.gitignore` 中且不入库 | 🟢 | `git check-ignore` ✓ |
| **A34** | M6 | `HOST_PROFILE.md` 不含真实凭据值 | 🟢 | `check.sh` isolation 断言 ✓ |
| **A35** | — | forge 接缝 S1：包内**零 DSH/Cordis 专属实现**（7 个特征词全 0 命中） | 🟢 | `check.sh --only=whitelist` 通过 |
| **A36** | — | forge 接缝 S2–S5 各有稳定产物 | 🟢 | `MANIFEST.json.forge_seams` + 文件清单 |
| **A37** | M1 | `AGENTS.md` 含降级链铁律，且与 `CLAUDE.md` **逐字一致** | 🟢 | `cmp` EXIT=0；§1 六节齐备 |
| **A38** | M2 | `fetch-vendor.sh` 的 JS/Python 两条链各有**三档条件分支**且兜底会明示 | 🟢 | 代码审查通过 |
| **A39** | M2 | 实测**至少走过一次非首选档** | 🟢 | JS 侧 pnpm 因 corepack 签名失败 → **降级 npm 成功**（213 包 / 7 分钟） |
| **A40** | M1 | `git ls-files` 不含 `node_modules/` / `.venv/` / `mcp-servers/launch/` | 🟢 | 三项 `git check-ignore` 全 ✓ |
| **A41** | M2 | 删掉 `node_modules/` 后重跑 `fetch-vendor.sh` 能恢复 | 🟢 | 首次安装 `npm install` EXIT=0 |
| **A42** | M2 | 构建完成后**离线**仍能通过 `healthcheck.sh`（垫片不联网） | 🟢 | 5 垫片全本地 `node <entry>`，无 `npx` 联网 |

### 2.1 无法自动化的评审项（人工判定）

| # | 项 | 判定人 |
|---|---|---|
| J1 | README「必答五件事」是否让零基础用户一眼看懂（母文档 §7.2） | 主人 |
| J2 | 医疗免责是否真实出现在三处（启动提示 / SKILL.md 红线区 / 每次回答末尾） | 主人 |
| J3 | 网络请求是否真的只携带检索关键词（无身份/病情泄漏） | 契约审查 |
| J4 | 知识卡内容是否存在超出「要点摘录」范围的原创医学结论 | 主人 / 社区医学志愿者 |
| J5 | `--mode=agent` 安装到宿主后，宿主是否**真的能触发**青囊 skill | 主人 |
| J6 | **一键部署指令是否真的「直接就能用」**——主人拿它给一个全新 Agent，能否无需额外解释就完成部署（K6 的真实验收） | 主人 |
| J7 | README 首屏的医学伦理与免责声明是否清楚、不吓人、符合公益开源调性（K5） | 主人 |
| J8 | 「社区只负责技术分发、不承担诊疗责任」的表述是否到位且不引发歧义 | 主人 |

---

## 3. 里程碑状态

| 里程碑 | 内容 | 依赖 | 状态 | 完成时间 |
|---|---|---|---|---|
| M0 | 立项（CHANGE / SPEC / TRACEABILITY） | — | ✅ | 2026-10-14 |
| pre-M | DoR：PRD 批准 + D5 解决 + SPEC 批准 | M0 | ⬜ | — |
| **V1.2** | 主人决策回合（K1–K6）+ DSH 事实核查（R13/R14）落地 | M0 | ✅ | 2026-10-14 |
| **V1.3** | 主人决策回合（K7–K11：DSH 移出 / 搜索六通道 / dev-host-init 移植 / 治理四要素 / forge 接缝）落地 | M0 | ✅ | 2026-10-14 |
| **V1.4** | **立项收尾 + 治理文档层（README / AGENTS.md / CLAUDE.md / CONTRIBUTING / LICENSE / MANIFEST）落盘 + 首次 commit/push** | M0 | ✅ | 2026-10-14 |
| M1 | 仓库骨架与治理文件（含脚本骨架） | pre-M | 🟢 **骨架已落地**（待正式验收） | 2026-10-14 |
| M2 | 部署与体检脚本（含 `probe-host.sh`） | M1 | 🟢 **骨架已落地**（待正式验收） | 2026-10-14 |
| M3 | 技能层 v0（三注入 + 合并契约 + 参考层） | M1 | 🟢 **骨架已落地**（待正式验收） | 2026-10-14 |
| M4 | **六条搜索通道**接入（四条零凭据） | M1,M2 | 🟢 **5/6 已接入并握手通过**（KnowS/get-biji 待许可债） | 2026-10-14 |
| M5 | 路由与降级链 | M3,M4 | 🟢 **骨架已落地**（端到端待跑） | 2026-10-14 |
| M6 | 第一道敏感信息闸 | M1 | 🟢 **配置已落地**（gitleaks 待装实测） | 2026-10-14 |

> **🟢 状态说明**：立项轮把 M1–M6 的**可验证骨架**一并落地了（超出原计划：原只做立项文档）。
> 这是有意的——骨架可跑才能证明 SPEC 契约不是纸上谈兵。**但正式验收（A1–A36 全绿 + 端到端）仍待 SPEC 批准后执行。**
> 已实测通过的：`check.sh` 26 项、`doctor.sh` 9 项 EXIT=0、MCP 握手 5/5、`phi_scan.py` EXIT=0。

---

## 4. 本轮立项已完成项（实测记录，2026-10-14）

| # | 项 | 实测结果 |
|---|---|---|
| P1 | 仓库状态 | `PancrePal-xiaoyibao/QingNang`，PRIVATE，`isEmpty=true`，建仓 `2026-10-14T10:26:58Z` |
| P2 | 本地 git | `No commits yet on main`，`origin/main [gone]`，未跟踪 `docs/` + `.ipynb_checkpoints/` |
| P3 | 许可证核查 | pubmed repo=Apache-2.0 / npm=MIT（不一致属实）；unified-trial repo=MIT / npm=MIT（**干净**）；KnowS repo=NONE（瑕疵确认）；PDAC-prompts=Apache-2.0；get-biji npm=MIT（repo 仍缺文件） |
| P4 | 离线数据包实况 | `xyb-corpus-2026-10-06` 共 4 资产 ≈12MB（cde 1MB / chictr 0MB / ictrp 1MB / **veeva_ctv 10MB**） |
| P5 | 参考实现核对 | `Development/Starchart/scripts/deploy.sh`（306 行，模块化 step_*）+ `tasks/CHG-*/` 三件套 + `scripts/check.sh` 均存在 |
| P6 | 环境缺口 | `gitleaks` 未安装（M6 由 pre-commit 自动拉取，属预期）；`tasks/` 目录本轮新建 |
| P7 | 体积修正 | 母文档 §10.1 目标 ≤500MB → **实测数据仅 ~12MB**，建议收紧至 ≤150MB（含索引与知识卡） |
| **P8** | **DSH 生态事实核查**（本轮新增） | 社区主流桌面端 = **`anywhere-labs/dsh-desktop`**（MIT，**30,780★**，1436 fork，2026-08-13 建仓，2026-10-14 07:55 更新）；org `anywhere-labs`（2026-05-22 建，3 个公开仓库）另有 `Agents-Anywhere`(1666★) / `framefactory-plugin` |
| **P9** | **母文档 DSH 指向有误** | 母文档写 `ningbainb/deepseek-harness-desktop`（BSD-3-Clause，812★）——系统是**不同项目**，不是同一项目的旧地址 |
| **P10** | **DSH 插件机制实测** | 插件 = **Cordis TS 插件**（`export const name` / `export const inject` / `export function apply(ctx)`）；提供 `desktopProfiles` / `desktopPnpm` 两个公开 Host service；**无 `SKILL.md` 目录约定** |
| **P11** | **DSH MCP 结构实测** | 内核 `packages/mcp/mcp-client/src/index.ts:50-73` 定义 `StdioConfig`：`transport`/`serverName`（须匹配 `[A-Za-z0-9_-]{1,32}`）/`command`/`args`/`env`/`cwd`/`toolCallTimeoutMs`/`failOnStartupError`/`reconnect?`；工具名形如 `mcp__<serverName>__<rawName>` |
| **P12** | **DSH Draft 边界** | `dsh-community-fabric` 的 manifest/capability/统一事件模型仍是 **RFC Draft**，官方明写「**尚不能作为依赖或发布目标**」→ 本 CHG 不碰 |

---

## 5. 未决事项（与 SPEC §1.6 同步）

| # | 事项 | 类型 | 状态 |
|---|---|---|---|
| ~~U1~~ | ~~PRD 缺失~~ | — | ✅ **已解决**：`PRD.md` v1.0 draft 已产出，待主人批准 |
| ~~U2~~ | ~~落点品牌 ADR-001~~ | — | ✅ **已关闭**（K2：落社区 org，不迁移） |
| U3 | 仓库许可证选择 | 阻塞首个 commit | ⬜ 建议 Apache-2.0 |
| U4 | 仓库名大小写 + git 署名 | 阻塞首个 commit | ⬜ 待决（D5） |
| U5 | `--mode=agent` 宿主矩阵 | 阻塞 M2 验收 | ⚠️ 已按实测重写（A 类/B 类分支），待 M2 回填实测值 |
| U6 | 知识卡无审校时 `reviewed_by` 取值 | 阻塞 M3 验收 | ⬜ 建议 `pending-review` + 显式声明 |
| U7 | DSH Desktop 长期接口稳定性（`dsh-community-fabric` 仍是 RFC Draft） | 不阻塞 Phase 1–2 | ⬜ 本 CHG 只依赖已冻结的 `StdioConfig` 形状 |

---

## 6. 基线可复核命令（执行阶段使用）

```bash
# ── 仓库与白名单 ────────────────────────────────────────────
git -C <repo> ls-files | sort                    # 比对 SPEC §4.5 白名单（A1）
git -C <repo> status --porcelain                 # 应为空（脱敏 + 无残留）

# ── 隐私隔离断言（A2 / A19）────────────────────────────────
touch private/probe.txt ~/.qingnang/private/probe.txt
git status --porcelain                            # 期望：输出为空
stat -c '%a' ~/.qingnang/private                  # 期望：700

# ── 遥测唯一档位（A18）─────────────────────────────────────
QINGNANG_TELEMETRY=on bash scripts/deploy.sh --mode=source; echo "EXIT=$?"   # 期望非 0

# ── 部署与体检（A4 / A5）───────────────────────────────────
bash scripts/deploy.sh --mode=source > /tmp/d1.log 2>&1; echo "EXIT=$?"
bash scripts/deploy.sh --mode=source > /tmp/d2.log 2>&1; echo "EXIT=$?"
bash scripts/doctor.sh; echo "EXIT=$?"             # 无凭据档期望 0

# ── MCP 通道（A10–A12）─────────────────────────────────────
node -e "const m=require('./mcp-servers/manifest.json');console.log(m.servers.map(s=>s.id+' '+s.package+'@'+s.version+' '+s.license).join('\n'))"
npm view mcp-pubmed-llm-server version            # 期望：3.0.0
npm view unified-trial-mcp version                # 期望：0.3.1
bash mcp-servers/healthcheck.sh                   # 期望：两通道握手成功

# ── 技能层体积（A7）───────────────────────────────────────
wc -c skills/qingnang/INJECT.md skills/qingnang/SKILL.md   # ≤2048 / ≤14336

# ── README 一键部署契约（A20，K6 主锚点）──────────────────
# 1) 部署段位置：段落首行行号 / 全文行数 < 0.33
# 2) 含仓库 URL
# 3) 指令块抽取后干净环境执行
awk '/^```bash$/,/^```$/' README.md > /tmp/spell.sh   # 抽部署咒语
bash /tmp/spell.sh; echo "EXIT=$?"                     # 干净环境期望 0

# ── 凭据 dryrun（A21，K3）─────────────────────────────────
bash scripts/deploy.sh --dry-run; echo "EXIT=$?"       # 期望 0，且未写入任何文件

# ── DSH 配置幂等（A22）────────────────────────────────────
bash scripts/deploy.sh --mode=agent --host=dsh && bash scripts/deploy.sh --mode=agent --host=dsh
# 期望：DSH MCP 配置中 qingnang_* 条目数不变

# ── 敏感信息闸（A16 / A17）────────────────────────────────
pre-commit run --all-files; echo "EXIT=$?"         # 干净仓库期望 0；含 fixture 期望非 0

# ── 聚合自检 ───────────────────────────────────────────────
bash scripts/check.sh; echo "EXIT=$?"
```

> **脱敏铁律**：以上命令与产出**不得**写入本机绝对路径、内网地址、代理凭据；执行阶段回填证据时同样遵守。

---

## 7. 齐头并进核对（**四端**，对应 CHANGE §6）

| 端 | 本 CHG 覆盖 | 里程碑 | 状态 |
|---|---|---|---|
| ① 仓库/脚本端 | ✅ | M1 / M2 / M6 | ⬜ |
| ② 能力层（MCP）端 | ✅ **六条搜索通道**（四条零凭据） | M4 | ⬜ |
| ③ 内置技能端 | ✅ 三注入 + 合并契约 + 参考层 | M3 | ⬜ |
| ④ 宿主注入端 | ✅ **A 类宿主 ≥2 个**（DSH 已移出，ADR-006） | M2（A6 / A22 / A28） | ⬜ |
| ~~⑤ 发行版编排端~~ | ❌ **已移出本包**（ADR-006 / ADR-012） | — | ✅ 接缝已留（A35/A36） |

> **未来（阶段二/三）**：青囊与 DSH Desktop 的 **forge 合并**、以及**小胰宝社区版 DSH Desktop**（含嵌入开发 + 数据库接入）属**独立项目**，见 **ADR-012**。本包只负责留好接缝（S1–S5）。

---

## 8. 回滚

- 本阶段（M0）产物为**纯文档**：`tasks/CHG-20261014-qingnang-mvp/{CHANGE,SPEC,TRACEABILITY}.md`，删除即回滚，无副作用。
- M1–M6 的回滚动作见 SPEC §5 各里程碑「回滚」行 + SPEC §9 汇总视图。
- `deploy.sh` 必须提供 `--uninstall`（M2 验收覆盖），保证写入宿主目录的行为可完整回退。
