# 青囊 QingNang

> **小胰宝社区 · 医学能力资产包**
>
> 把社区积累的医学能力（医学文献 / 临床试验 / 网页搜索 / 病历处理 / 指标追踪）打包成**一只可以被任何 AI Agent 直接加载的工具箱**。
>
> **项目仓库**：https://github.com/PancrePal-xiaoyibao/QingNang
> **定位**：社区医学资产的打包与分发 ｜ **品牌**：小胰宝社区 ｜ **许可**：Apache-2.0

---

## 🎯 这是什么，为谁而做

**青囊不是「给人用的软件」，是「给 AI Agent 用的能力包」。**

| 谁 | 怎么用青囊 |
|---|---|
| **你的 AI Agent** | 读青囊的注入文档，就知道该怎么查文献、找试验、看指南 |
| **你（病友或家属）** | 你只要对 Agent 说话。它自己会选对工具 |
| **未来的桌面客户端**（DeepSeek Harness Desktop） | 通过预留接口接入，让桌面版自带医学能力 |
| **社区贡献者** | 按合并契约往里加知识卡或新能力 |

**你不需要懂任何技术。** 复制一段部署指令给你的 Agent 就行。

---

## 📐 十条设计原则

| # | 原则 | 对你意味着什么 |
|---|---|---|
| 1 | **为 Agent 而做** | 那些文件是给 Agent 读的，所以你不用配置任何东西 |
| 2 | **薄注入 + 厚参考** | Agent 的「记忆占用」小，响应更快 |
| 3 | **零凭据可跑** | **不用申请任何 Key 就能用** |
| 4 | **全链降级** | 一条路不通自动换下一条，不会卡死 |
| 5 | **合并而非搜集** | 只装医学真正用得上的，不塞一堆没用的 |
| 6 | **耦合而非并列** | 工具之间知道彼此存在，不会各干各的 |
| 7 | **医学红线优先** | **宁可查不到，也不给你诊断或剂量** |
| 8 | **数据不出机** | 你的资料永远只在你电脑上 |
| 9 | **跨平台** | Windows / macOS / Linux 都能装，**不用 WSL** |
| 10 | **失败可观察** | 用不了会明确告诉你，**不会编造** |

> 原则冲突时的裁决顺序：**伦理与隐私 > 可用性 > 其余**。
> 完整版见 `AGENTS.md` §0.4。

---

## ⚠️ 医学伦理与免责声明（请先读完这段）

1. **本工具不构成医疗建议。** 青囊只做信息检索与整理，不做诊断、不给用药剂量、不替代医生。
2. **你的病情数据只留在你自己的电脑上。** 所有个人资料写入本机 `~/.qingnang/private/`，**永不上传、永不进 git**。
3. **社区只负责技术分发。** 本包提供的是技术工具与公开信息检索能力，**不承担诊疗责任、不做医疗背书**。
4. **遇到急症请立即就医**，不要依赖任何 AI 工具。

> 每条涉及诊疗的回答都会自动附带来源与上述免责。未经医学审校的知识卡会明确标注 `pending-review`。

---

## 🚀 一键部署

### 支持平台

| 平台 | 支持 | 前置要求 |
|---|---|---|
| **Linux** | ✅ 原生支持 | bash、Node ≥22.13、Python ≥3.10（可选） |
| **macOS** | ✅ 原生支持 | 同上 |
| **Windows** | ⚠️ **需 Git Bash 或 WSL** | 原生 PowerShell / CMD **不支持**（脚本是 bash） |
| **Windows + WSL2** | ✅ 推荐方式 | 在 WSL 里按 Linux 步骤做 |

> **为什么 Windows 要 WSL？** 青囊的部署脚本、体检脚本、MCP 启动垫片都是 bash。
> 在 Git Bash 里能跑，但路径与权限语义与 Linux 有细微差异；**WSL2 最省事**。
> （未来如需原生 Windows 支持，那是独立的工程，见文末「路线图」。）

---

### 第一步：给 Agent 的部署指令（复制即用）

把下面整段复制给你的 AI Agent：

```
请把青囊（QingNang）医学能力包装到当前环境。

项目仓库：https://github.com/PancrePal-xiaoyibao/QingNang

按顺序执行，不要跳步：
1. git clone https://github.com/PancrePal-xiaoyibao/QingNang.git && cd QingNang
2. node scripts/qingnang.mjs fetch            # 在本项目内构建全部依赖环境（含 7 个 MCP）
3. node scripts/qingnang.mjs deploy --mode=source    # 探测本机（硬件/网络/代理）+ 建私有目录
4. node scripts/qingnang.mjs deploy --mode=agent     # 把技能层装到你自己（--host= 可指定宿主）
5. node scripts/qingnang.mjs doctor                  # 逐通道体检，把结果贴回来

说明：
- 不需要填任何 API Key。五条通道零凭据可用。
- 遇到报错按脚本给的中文提示处理。脚本会告诉你缺什么、怎么装。
- doctor.sh 输出里的 ⬜ 是「选填未配」，不是错误。
```

**Agent 会自己完成安装。** 你只需要在它报错时按提示操作。

---

### 第二步：手动部署（想自己点的人）

#### Linux / macOS / WSL

```bash
# 前置：确认 Node 版本（必须 ≥ 22.13.0）
node -v          # 低于 22.13 → 去 https://nodejs.org/ 或 nvm install 22

# 1. 拿代码
git clone https://github.com/PancrePal-xiaoyibao/QingNang.git
cd QingNang

# 2. 构建依赖环境（首次约 5–10 分钟）
node scripts/qingnang.mjs fetch

# 3. 探测本机 + 建私有目录
node scripts/qingnang.mjs deploy --mode=source

# 4. 装技能层到你的 Agent
node scripts/qingnang.mjs deploy --mode=agent

# 5. 体检
node scripts/qingnang.mjs doctor
```

#### Windows + WSL2（推荐）

```bash
# 在 WSL 终端里，完全按上面的 Linux 步骤做
# WSL 里可以用 linux 版 Node；文件放在 WSL 文件系统（不要放在 /mnt/c）性能更好
```

#### Windows + Git Bash（可用但不推荐）

```bash
# 前置：Git for Windows（自带 Git Bash）+ Node ≥22.13
# 在 Git Bash 里执行与 Linux 相同的命令
# 注意：路径用 /c/Users/... 而非 C:\Users\...
```

---

### 第三步：配置（skill + MCP）

部署完成后，**Agent 会自动读到技能层**。如果你想手动确认配置，看这一节。

#### 技能层装在哪（按宿主分派）

| 宿主 | 安装位置 | 怎么触发 |
|---|---|---|
| **Claude Code** | `~/.claude/skills/qingnang/` | 新会话问「有哪些青囊能力」 |
| **pi** | 继承 `~/.claude/skills/` | 同上 |
| **OpenClaw** | `<项目>/config/openclaw/workspace/skills/qingnang/` | 同上 |
| **Codex** | 追加到 `~/.codex/AGENTS.md` 的 marker 块 | 新会话自动生效 |

**指定宿主**（不指定则自动探测）：

```bash
node scripts/qingnang.mjs deploy --mode=agent --host=claude     # 或 pi / openclaw / codex
node scripts/qingnang.mjs deploy --mode=agent --link            # 用软链（源改了宿主副本自动跟随）
```

#### MCP 通道配置

**MCP 的配置是自动的**——你在第 2 步跑 `fetch-vendor.sh` 时，脚本会：

1. 把 7 个 MCP 装进 `node_modules/`
2. 为每个生成启动垫片 `mcp-servers/launch/<id>`
3. manifest 的 `command` 指向垫片（**离线启动，不联网**）

**唯一的事实源**是 `mcp-servers/manifest.json`。想看配了什么，看这个文件：

```bash
# 列出所有通道（含许可、版本、凭据要求、降级目标）
python3 -c "
import json
d = json.load(open('mcp-servers/manifest.json'))
for s in d['servers']:
    gate = '需凭据' if s.get('credential_gate') else '零凭据'
    print(f\"  通道{s['channel']} {s['id']:14s} {s['package']:36s} {gate}\")
"
```

**如果你用 DSH 或别的宿主**：把 `manifest.json` 的每个 server 翻译成该宿主的 MCP 配置格式即可。
本包**故意不写宿主专属代码**（见「技术特点」第 6 条），所以不会被某个宿主的配置格式绑死。

#### 凭据配置（全部选填）

```bash
cp .env.example .env
# 编辑 .env，取消对应行注释并填值（大多数情况不用填）
node scripts/qingnang.mjs doctor     # 体检，逐项显示 ✓ 已配 / ⬜ 选填未配 / ❌ 出错
```

| 变量 | 用途 | 不填的后果 |
|---|---|---|
| `KNOWS_API_KEY` + `KNOWS_API_HOST` | 高级医学证据通道 | 自动降级到 PubMed + OpenAlex，**并在回答中明示** |
| `GET_NOTE_API_KEY` | 病友经验通道 | 该通道不启动，经验类问题明示未启用 |
| `NCBI_API_KEY` | PubMed 提速 | 限速 3 次/秒（个人足够） |
| `OPENALEX_EMAIL` | OpenAlex 提速 | 用共享池，较慢 |

**申请入口**见下方「🔑 凭据申请」一节。

---

## ✅ 部署完你能做什么

装好之后，直接对 Agent 说话就行：

```
帮我查一下胰腺癌 FOLFIRINOX 方案的最新文献
找一下国内正在招募的胰腺癌临床试验
解释一下 CA19-9 这个指标是什么意思
帮我整理一下胰腺癌 KRAS 靶点的试验现状
CLDN18.2 现在中国有哪些中心在做
```

Agent 会自动判断该走哪条通道，**不需要你教它**。

---

## 🔧 技术特点（这个包和"把几个工具拼在一起"有什么不同）

### 1. 三层注入分离——常驻上下文只占 2KB

```
INJECT.md（2026B / 上限 2048B）        ← 常驻 Agent 上下文，只说「去找分流表」
   ↓ 用户提问涉及搜索时
SEARCH_RUNTIME.md（7828B / 上限 8192B） ← 按需加载，详列七条通道怎么选
   ↓ 需要知道本机情况时
HOST_PROFILE.md（运行时生成，不入库）    ← 按需加载，本机代理/硬件
```

**为什么这么分**：常驻上下文越短，Agent 的"注意力预算"越省。
所以主注入**只负责指路**，具体工具放独立文件。

**收益**：新增搜索工具**只改 `SEARCH_RUNTIME.md`，不动主注入**。
这条被自动断言守住——`check.sh` 会检查主注入里**不许出现任何工具包名**。

### 2. 合并而非搜集——只挑医学能力，并且做耦合

本包**不是**把社区 137 个仓库全拉进来。它按四条判据筛选：

| 问题 | 进 | 不进 |
|---|---|---|
| 医学相关吗？ | 病友的信息获取、病历处理、指标追踪、心理支持 | 开发者工具、运维脚本、UI 模板 |
| 是能力还是应用？ | skill / MCP | 完整应用、机器人、小程序、官网 |
| 许可干净吗？ | MIT / Apache-2.0 / ISC / BSD-3 | 无 LICENSE 或 AGPL（需隔离） |
| 能被 Agent 调用吗？ | 有 `SKILL.md` 或 MCP 包 | 一堆散脚本无入口 |

**进来了还得做耦合**（见下条）。

### 3. 双向引用耦合——skill 知道调哪个 MCP，MCP 知道被谁用

**skill 侧必须声明三件事**（在 `SKILL.md`）：

| 依赖哪个 MCP | 什么时候调 | 结果怎么用 |
|---|---|---|
| `qingnang_pubmed` | 文献类、机制 | 拼成文献段，带 PMID |
| `qingnang_trial` | 试验类、入组标准 | 列登记号 + 分期 + 状态 |

**MCP 侧必须被引用**（在 `SEARCH_RUNTIME.md`）：每条通道都要写「由哪个 skill 使用」。

**禁止**：MCP 装了但没任何 skill 说要用；skill 写「去搜索」但不说哪条通道。
**自动断言**：`check.sh` 检查每个 MCP ≥1 个双向引用，每个 skill 依赖声明完整。

### 4. 全链降级链——每处"做选择"的地方都有三档

| 层 | 首选 | 次选 | 兜底 |
|---|---|---|---|
| **JS 包管理** | pnpm（隔离布局） | npm | yarn |
| **Python 环境** | uv venv | python -m venv | conda |
| **代理** | 自动探测本机端口 | 用户 `.env` 手填 | 直连 |
| **MCP 调用** | 通道首选模式 | 通道次选模式 | 降级到另一条通道 |
| **宿主注入** | 原生 skills 目录 | 追加 marker 块 | 输出路径让用户手动贴 |

**三条纪律**：
1. **必须可观察** —— 降档时要说清「走了哪档、为什么」。用户不知道降级 = 降级没发生。
2. **兜底允许放弃** —— 某能力不可用时，**明说不可用**是正确的兜底。
3. **兜底不许污染** —— 任何降级都不得触碰 `~/.qingnang/private/`。

### 5. 项目内自足环境——pull 一次，离线可跑

所有依赖环境**落在项目活动区内**，不散落到 `~/.npm` 或全局：

```
QingNang/
├── package.json + package-lock.json    ← 7 个 MCP，版本钉死
├── pyproject.toml                      ← Python 侧（Phase 3 用）
├── node_modules/                       ← JS 环境（实测 127MB）
├── .venv/                              ← Python 环境
└── mcp-servers/
    ├── manifest.json                   ← 唯一事实源
    └── launch/                         ← 启动垫片（每通道一个）
```

**共享一个环境，不是每个 MCP 独立**：

| | 共享（本方案） | 每 MCP 独立 |
|---|---|---|
| 磁盘 | 16 个依赖去重，**127MB** | 5 倍冗余 |
| 多版本冲突 | pnpm 隔离布局解决 | 天然无冲突但无法复用 |
| 升级 | 改一处 + 重跑脚本 | 改 5 处 |

**实测**：五个 MCP 的 tarball 合计约 2.1MB，装完 127MB。共享环境的账算得过来。

### 6. 启动垫片——挡住包管理器差异 + 离线启动

```
manifest.json 的 command
   → mcp-servers/launch/<id>（垫片）
     → node_modules/<pkg>/<entry>（真实入口）
```

**垫片解决两个问题**：

1. **布局解耦** —— pnpm 是 `.pnpm/<pkg>@<ver>/node_modules/`，npm 是扁平 `node_modules/`。
   垫片把差异挡在中间，manifest 不需要知道用的是哪个包管理器。
2. **离线启动** —— 不再 `npx` 联网拉包。**装完后断网也能跑。**

**顺带解决**：某些 MCP 需要子命令才启动（如 `unified-trial-mcp` 必须 `serve`）。
manifest 的 `args` 字段声明，垫片自动带上。

### 7. 凭据门——缺凭据记「选填未配」，不算失败

有的通道需要凭据（KnowS / get-biji）。**本包的设计是：缺凭据不是错误。**

```bash
$ node mcp-servers/healthcheck.mjs
  ✓ web_search
  ✓ bing_cn
  ✓ pubmed
  ✓ openalex
  ✓ unified_trial
  ⬜ knows — 未配凭据 KNOWS_API_KEY,KNOWS_API_HOST（降级到 pubmed）
  ⬜ get_biji — 未配凭据 GET_NOTE_API_KEY（降级到 无）
──────────────────────────────────────────────
可用 5 / 选填未配 2 / 共计 7
```

**`⬜` 不导致非零退出。** 这样用户接到的信号是「5 条能用，2 条可选」，而不是「有 2 个错误」。

### 8. 体检契约——三符号输出，可机读

`doctor.sh` 输出固定格式：`[序号/总数] 检查项  ✓/⬜/❌ 中文结论`

| 符号 | 含义 | 退出码影响 |
|---|---|---|
| `✓` | 通过 | — |
| `⬜` | 选填未配 | **不影响** |
| `❌` | 失败，必须修 | 任一 `❌` → `exit 1` |

**为什么这很重要**：用户可以把 doctor 结果**原样贴给 Agent**，Agent 一看符号就知道下一步。

### 9. 敏感信息闸——中文 PHI/PII 扫描

医疗场景下，**一条真实患者信息进仓库就是事故**。本包有三道闸：

| 闸 | 时机 | 查什么 |
|---|---|---|
| **pre-commit** | 本地提交前 | gitleaks（凭据）+ `phi_scan.mjs`（中文 PHI/PII） |
| **CI** | PR 推送后 | 同套规则跑全量 diff |
| **AI 复审** | PR 触发 | 查「看似脱敏实可反推」的组合 |

`phi_scan.mjs` 覆盖：身份证号、手机号、住院号/门诊号、**姓名+诊断组合**、
**时间+就诊+机构三件套**、报告单图片 EXIF、API Key、私钥、银行卡号。

**做正负向测试**：真实形态命中，描述性文字不误报。

### 10. 为未来合并留缝——五条 forge 接缝

青囊本阶段是**独立的多 agent 适配资产包**。后续会与 DSH Desktop 合并，产出社区版桌面客户端。

**包内零宿主专属代码**，但留了五条接缝：

| # | 接缝 | 作用 |
|---|---|---|
| S1 | 零 DSH / Cordis / OpenClaw 专属实现 | 宿主适配属宿主侧的事 |
| S2 | `manifest.json` 是唯一事实源 | 未来可直接翻译成目标宿主格式 |
| S3 | 三层注入物理分离 | 可按新宿主机制逐层重渲染 |
| S4 | `MERGE_CONTRACT.md` 随包交付 | 纪律一致，不各搞一套 |
| S5 | `HOST_PROFILE.md` 与能力层解耦 | 新宿主可自行生成同构画像 |

**自动断言**：`check.sh` 检查包内**零命中** DSH 专属特征（`dsh-plugin` / `StdioConfig` / `ctx.inject` 等）。

---

## 🔑 凭据申请（全部选填）

**不填任何 Key，青囊已经完整可用。** 凭据只用于增强通道。

| 变量 | 所属通道 | 申请入口 | 不填的后果 |
|---|---|---|---|
| `KNOWS_API_KEY`<br>`KNOWS_API_HOST` | 高级医学证据 | 走社区公众号/小程序试用额度 → 见 [社区组织页](https://github.com/PancrePal-xiaoyibao) | 自动降级到 PubMed + OpenAlex，**并在回答中明示** |
| `GET_NOTE_API_KEY` | 病友经验 | [得到笔记](https://getnote.cn/) 账号 API 凭据 | 该通道不启动 |
| `NCBI_API_KEY` | PubMed 提速 | https://www.ncbi.nlm.nih.gov/account/ | 限速 3 次/秒 |
| `OPENALEX_EMAIL` | OpenAlex 提速 | https://openalex.org/ | 共享池，较慢 |

**怎么填**：

```bash
cp .env.example .env
# 编辑 .env
node scripts/qingnang.mjs doctor
```

---

## 🛡️ 数据安全说明

| 项 | 说明 |
|---|---|
| **私有数据位置** | `~/.qingnang/private/`（权限 `0700`，仅你自己可读） |
| **包含什么** | `reports/`（报告单原件）、`extracted/`（解析后文本）、`profile/`（病情档案）、`history.db`（检索历史） |
| **遥测** | **默认关闭，且唯一合法值是 `off`**。脚本会拒绝其他任何值。 |
| **网络请求** | 只携带**检索关键词**（病名、药名、试验编号），**永不携带身份或病情细节** |
| **导出/分享** | 任何导出路径都不得触碰 `private/`；只有你主动要求「分享给医生」时才生成脱敏摘要 |
| **本机画像** | `HOST_PROFILE.md` 记录你的硬件与代理，**已加入 `.gitignore`，不会进仓库** |

---

## 📦 包内包含的能力

### 七条 MCP 通道（五条零凭据）

| # | 通道 | 包 | 许可 | 凭据 | 什么时候用 |
|---|---|---|---|---|---|
| 1 | 通用网页搜索 | `open-websearch` | Apache-2.0 | 免 | 一般资讯、最新动态、英文内容 |
| 2 | 中文网页搜索 | `bing-cn-mcp` | MIT | 免 | 中文内容、国内政策/指南 |
| 3 | 医学文献 | `mcp-pubmed-llm-server` | MIT | 免 | 论文、机制、指南出处 |
| 4 | 学术文献 | `openalex-mcp-server` | ISC | 免 | 开放获取全文、引用网络 |
| 5 | 临床试验 | `unified-trial-mcp` | MIT | 免 | 在招试验、入组标准、中美双登记 |
| 6 | 高级医学证据 | `@xiaoyibao_npm/knows-mcp-server` | MIT | **需** | 循证证据、结构化指南摘要 |
| 7 | 病友经验 | `get-biji-mcp` | MIT | **需** | 病友经验、就医流程、副作用应对 |

> 通道 3、4 常**并联使用**：PubMed 找临床证据，OpenAlex 追引用与全文。
> 需要凭据的两条**留空即可**——缺凭据会自动降级，并在回答中明示。

### 技能层（三层注入 + 决策 + 契约）

| 文件 | 体积 | 作用 |
|---|---|---|
| `INJECT.md` | 2026B | 常驻：宣告存在 + 指路 + 三条医学红线 |
| `SEARCH_RUNTIME.md` | 7828B | 按需：七条通道分流表 + 降级顺序 |
| `SKILL.md` | 8514B | 决策：七步执行流 + 五条铁律 + 路由表 + 耦合声明 |
| `MERGE_CONTRACT.md` | 8769B | 契约：准入四条 + 合并三种 + 耦合契约 + forge 接缝 |

### 参考层（厚，按需单文件读）

| 目录 | 内容 | 来源 |
|---|---|---|
| `references/ethics/` | 三条红线 / 免责三处 / 数据安全 / 贡献者伦理 / 转介话术 | 本包原创 |
| `references/pancreas/` | 胰腺癌术语中英对照 | 社区知识 + 待审校 |
| `references/trials/` | **试验报告提纲** / **靶点速查** / **ChiCTR 指南** / **情报流水线** | 合并自社区 4 个 skill（Apache-2.0） |
| `references/guidelines/` | **NCCN 68 癌种清单** + 版权硬约束 | 合并自社区 skill（Apache-2.0） |
| `references/SOURCES.md` | **许可台账**：全部资产来源、许可、改动、待办 | 本包原创 |

### 从社区合并进来的 skill 资产（方式 B：改进后并入）

| 来源 skill | 许可 | 并入到 |
|---|---|---|
| `clinicaltrials-query-analysis` | Apache-2.0 | `references/trials/report-outline.md` + `targets.md` |
| `chictr-trials-collector` | Apache-2.0 | `references/trials/chictr-guide.md` |
| `clinicaltrials-intel-skill` | Apache-2.0 | `references/trials/intel-pipeline.md` |
| `nccn-guideline-downloader` | Apache-2.0 | `references/guidelines/nccn-cancer-types.md` |

> 每个并入文件都标注了**来源 + 改了什么 + 许可**，并补充了青囊的医学约束。
> 完整台账见 `references/SOURCES.md`。

### 只登记、未并入（许可隔离）

| 资产 | 许可 | 为什么 |
|---|---|---|
| `ca199_toolbox` | AGPL-3.0 | 有传染性。只登记（CA19-9 趋势管理工具，本地处理无上传），不并入代码 |
| `MinerU` 系列 | AGPL-3.0 / Apache-2.0(FORK) | 同上 + 体积大（GB 级模型）。Phase 3 再评估 |
| `maskdesk` / `little_green_card` / `devil-chat` | Apache-2.0 / 无 | 是完整应用，不是能力。只借鉴思路 |

### 规划中

| 组件 | 状态 |
|---|---|
| 胰腺癌知识卡（分期术式 / 化疗方案 / 指标解读 / 副作用应对 / 医患沟通） | 🔜 需医学志愿者审校 |
| 离线知识包 + 本地 RAG | 🔜 Phase 3 |
| MinerU PDF 解析 | 🔜 Phase 3 |

---

## 🧭 这个包是怎么组织的

```
QingNang/
├── README.md / AGENTS.md / CLAUDE.md / CONTRIBUTING.md / LICENSE
├── MANIFEST.json              ← 版本 / 体积 / 哈希 / 通道矩阵 / forge 接缝
├── package.json               ← JS 依赖声明（7 个 MCP，版本钉死）
├── pyproject.toml             ← Python 依赖声明
│
├── skills/qingnang/           ← 技能层（可安装单元）
│   ├── INJECT.md / SEARCH_RUNTIME.md / SKILL.md / MERGE_CONTRACT.md
│   ├── HOST_PROFILE.md.template   （运行时生成 .md → 不入库）
│   └── references/            ← ethics / pancreas / trials / guidelines / SOURCES
│
├── mcp-servers/
│   ├── manifest.json          ← **MCP 唯一事实源**
│   ├── healthcheck.mjs        ← 逐通道握手 + 许可白名单校验
│   └── launch/                ← 启动垫片（生成，不入库）
│
├── scripts/
│   ├── fetch-vendor.sh        ← **环境构建**（全链降级）
│   ├── deploy.sh              ← 部署（source / agent 两模式）
│   ├── doctor.sh              ← 九项体检
│   ├── probe-host.sh          ← 宿主机探测
│   ├── check.sh               ← 聚合自检（26 项）
│   ├── phi_scan.mjs           ← 中文 PHI/PII 扫描
│   └── lib/                   ← common / host-probe / render / make-shims
│
├── data/synthetic/            ← 演示数据（仓库内禁真实数据）
└── tasks/CHG-20261014-qingnang-mvp/
    ├── CHANGE.md / SPEC.md / TRACEABILITY.md
    └── PRD.md                 ← 产品需求文档
```

**为什么分三层注入**：主注入常驻上下文，越短越好。所以它只说「去找分流表」。
**为什么 `HOST_PROFILE.md` 单独一个文件**：它记你的代理和硬件，**机器相关、不入库**。
**为什么 `manifest.json` 是唯一事实源**：避免多个地方各写一份 MCP 配置，导致漂移。

---

## ❓ 故障排查

| 现象 | 原因 | 怎么办 |
|---|---|---|
| `node: command not found` | 没装 Node | 去 https://nodejs.org/ 装 LTS |
| Node 版本过低 | 需 ≥22.13.0 | `nvm install 22` 或升级 |
| 搜不到结果 / 超时 | 本机需要代理 | 看 `HOST_PROFILE.md` 的「网络与代理」一节 |
| npm 拉包失败 | 安装期需代理 | `npm --proxy <地址> --https-proxy <地址> install` |
| 装了很久没动静 | registry 慢 | 实测正常约 5–10 分钟；可重跑一次 |
| 某个通道 `❌` | 通道不可用 | `doctor.sh` 会给中文修复指引 |
| `⬜` 是什么意思 | 选填项未配 | **不是错误，不影响使用** |
| 报 bash 语法错 | Windows 用了 PowerShell/CMD | 改用 **Git Bash 或 WSL** |
| Agent 不知道有青囊 | 注入没装到位 | 重跑 `node scripts/qingnang.mjs deploy --mode=agent` |
| Windows 路径报错 | Git Bash 路径语义 | 用 `/c/Users/...` 而非 `C:\Users\...`，或改用 WSL |

**开发者自检**：

```bash
node scripts/qingnang.mjs check            # 26 项聚合自检
node scripts/qingnang.mjs deploy --mode=source --dry-run   # 只验证链路，不写文件
node scripts/qingnang.mjs doctor           # 九项体检
bash -n scripts/*.sh             # 脚本语法
cmp AGENTS.md CLAUDE.md          # 治理文档一致性
```

---

## 🤝 参与贡献

**我们最需要的不只是代码**——病种知识卡、术语中英对照、FAQ 整理，都是极有价值的贡献。

**提交前必读红线**：

- ❌ **禁止提交任何真实患者数据**：姓名、身份证号、手机号、住院号、报告单原件、影像。
- ✅ 演示数据一律放 `data/synthetic/`，用造数脚本生成。
- ✅ PR 模板里有「本 PR 不含任何真实患者信息」的勾选项，**必须勾**。
- ✅ 仓库有自动闸门（pre-commit + CI + AI 复审）会拦截敏感信息。

**准入纪律**：一条新能力要不要进青囊，看四条——医学相关吗？是能力还是应用？许可干净吗？能被 Agent 调用吗？
详见 `skills/qingnang/MERGE_CONTRACT.md`。

**并入社区 skill 的流程**：见 `CONTRIBUTING.md` 第 3 节。

---

## ⚖️ 许可证与第三方组件

| 项 | 许可 |
|---|---|
| **青囊本体** | **Apache-2.0**（见 `LICENSE`，附医学免责声明） |
| 第三方 MCP 组件（7 个） | 各自保留原许可，见 `mcp-servers/manifest.json` 与 `references/SOURCES.md` |
| 并入的社区 skill 资产（4 项） | Apache-2.0，保留来源与改动说明 |
| **NCCN 指南内容** | **受版权保护，不得再分发全文**，只做要点摘录 + 官方链接 |

**为什么选 Apache-2.0**：含专利授权（对医疗信息化场景更稳妥），且与多数上游一致。

---

## 📚 延伸阅读

| 文档 | 内容 |
|---|---|
| `tasks/CHG-20261014-qingnang-mvp/PRD.md` | **产品需求**：用户、场景、目标、成功标准 |
| `tasks/CHG-20261014-qingnang-mvp/CHANGE.md` | 立项说明：需求辨析、架构决策、风险登记 |
| `tasks/CHG-20261014-qingnang-mvp/SPEC.md` | 工程契约：冻结接口、里程碑、42 个验收锚点 |
| `tasks/CHG-20261014-qingnang-mvp/TRACEABILITY.md` | 追溯与证据 |
| `AGENTS.md` | 面向 AI Agent 的工作规则（含降级链铁律、医学加强项） |
| `CONTRIBUTING.md` | 贡献指南：伦理红线 + 三道闸 + 准入四条 |
| `skills/qingnang/MERGE_CONTRACT.md` | 合并契约：什么样的能力能进、怎么进 |
| `skills/qingnang/references/SOURCES.md` | 全部资产的许可台账 |
| `docs/` | 架构与开发计划、社区资产全量盘点 |

---

## 🗺️ 路线图

| 阶段 | 项目 | 内容 |
|---|---|---|
| **一（当前）** | **青囊**（本仓库） | 独立的社区医学能力资产包，多 agent 适配 |
| **二** | **forge 合并** | 青囊 × DSH Desktop 合并，系统性嵌入医学能力 |
| **三** | **小胰宝社区版 DSH Desktop** | **独立项目**：青囊 + DSH 嵌入开发 + 数据库接入 |

**「Windows 原生支持」也在这条线上**——需要写 PowerShell 版脚本或打包成桌面应用，
属于阶段三的工作，不在本包。

---

<p align="center">
  <strong>青囊</strong> · 华佗狱中传《青囊书》，是中国文化里「医术传承、济世救人」的原型意象。<br>
  把社区医学能力装进一只包，让任何 Agent 都能用。
</p>
