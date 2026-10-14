# 青囊 · 技术架构

> 本文件是 [`README.md`](../README.md) 的展开版，讲清「青囊是怎么搭起来的」。
> 权威契约在 [`tasks/CHG-20261014-qingnang-mvp/SPEC.md`](../tasks/CHG-20261014-qingnang-mvp/SPEC.md)，本文件是导览。

---

## 一、一句话架构

```
        用户（病友/家属）
              │  自然语言提问
              ▼
   ┌──────────────────────────┐
   │  宿主 Agent                │
   │  （Claude Code / pi /      │
   │    OpenClaw / Codex）      │
   └───┬──────────────────┬───┘
       │ 读注入文档         │ 调 MCP 工具
       ▼                  ▼
  ┌─────────────┐   ┌──────────────────┐
  │  技能层       │   │  MCP 能力层       │
  │ 11 个 skill  │◄──┤ 7 通道 / 28 工具  │
  └─────────────┘   └──────────────────┘
       │                  │
       │  降级链           │  离线 vendor
       ▼                  ▼
  ┌──────────────────────────────┐
  │  隐私沙箱 ~/.qingnang/private │
  │  （0700 · 永不出机）           │
  └──────────────────────────────┘
```

**三条设计主线**：

| 主线 | 目标 | 关键机制 |
|---|---|---|
| **对 Agent 友好** | 不浪费上下文预算 | **三层注入**，按需加载 |
| **对用户友好** | 部署不失败 | **离线 vendor** + **全链降级** |
| **对医学负责** | 不出事 | **五条红线** + **脱敏闸门** + **不许编造** |

---

## 二、三层注入（为什么必须物理分离）

### 2.1 三个文件、三种加载时机

| # | 文件 | 上限 | 何时进上下文 | 内容 |
|---|---|---|---|---|
| ① | `INJECT.md` | 2048 B | **常驻** | 宣告存在 + 三条医学红线 + 「涉搜索去读 SEARCH_RUNTIME」 |
| ② | `SEARCH_RUNTIME.md` | 8192 B | **涉搜索时** | 7 条通道分工、参数、降级顺序 |
| ③ | `HOST_PROFILE.md` | 运行时生成 | **需要本机信息时** | 硬件 / 网络 / 代理（已实测验证） |

另有 `SKILL.md`（14336 B 上限）承载**路由层**——两跳路由表、表达要求、失败与降级。

### 2.2 分离的三条理由

| 理由 | 说明 |
|---|---|
| **常量优化** | `INJECT.md` 常驻 → 它每多 1 KB，Agent 每次思考都多背 1 KB。所以它**只指路，不给内容** |
| **变更隔离** | 换搜索工具只改 `SEARCH_RUNTIME.md`，**不动主注入** → 变更不会污染常驻上下文 |
| **环境解耦** | `HOST_PROFILE.md` 是机器相关的（含代理地址），必须可 gitignore、可重生成 |

### 2.3 有断言守住（不是靠自觉）

`node scripts/qingnang.mjs check` 会验证：

- `INJECT.md` ≤ 2048 B、`SEARCH_RUNTIME.md` ≤ 8192 B、`SKILL.md` ≤ 14336 B
- `INJECT.md` **含**三条红线关键词（不做诊断 / 不给剂量 / 永不上传）
- `INJECT.md` **不含**任何工具包名（`open-websearch` / `bing-cn-mcp` / …）
- `SEARCH_RUNTIME.md` 含 ≥6 条通道

> **第 2 条为什么重要**：主注入一旦写了工具名，Agent 就可能跳过分流表直接调工具。
> 那就退化成了「猜工具」，而分流表存在的意义正好是**禁止猜**。

### 2.4 给宿主开发者的改造建议

如果你的宿主有自己的注入机制，**逐层重渲染这三个文件**，不要合并成一个大文件。

合并的代价：常驻上下文膨胀 → Agent 注意力被稀释 → 首次提问命中率下降（违反 G2）。

---

## 三、技能层结构（1 主 + 11 社区）

### 3.1 为什么社区 skill 是「原样引入」而不是「拍平」
社区 skill 自带 `SKILL.md` + 可执行脚本，**是能力，不是文档**。
把可执行能力抽成 `references/*.md` 是**降级**——脚本跑不了，只剩"读一读"。

所以本包采用 **方式 A：原样引入 + 适配层**：

```
skills/
├── qingnang/                        ← 主技能（本包自写）
│   ├── INJECT.md                    ← 常驻
│   ├── SEARCH_RUNTIME.md            ← 按需
│   ├── HOST_PROFILE.md              ← 运行时生成（不入库）
│   ├── SKILL.md                     ← 路由
│   ├── MERGE_CONTRACT.md            ← 准入纪律
│   └── references/                  ← 本包自写的伦理 / 术语表 / 许可台账
│
└── <10 个社区 skill>/                ← 上游代码一字未改
    ├── SKILL.md                     ← 上游文件
    ├── <上游脚本等>                  ← 上游文件
    └── QINGNANG.md                  ← 【青囊追加】适配层
```

### 3.2 适配层（`QINGNANG.md`）的五段

| 段 | 内容 |
|---|---|
| 一 | 来源与许可（上游 URL + SPDX + 引入方式 + **是否改动上游代码**） |
| 二 | **青囊五条红线在本技能上如何生效**（M1–M5） |
| 三 | 病人数据红线（示例数据 / 测试病例 / 报告单的处理约束） |
| 四 | 运行依赖（上游自带，青囊不代装） |
| 五 | 与主技能的关系（入口 / 分工 / 本机画像 / 搜索通道） |

**关键原则**：借用来的 skill **不因为是"别人的"就豁免青囊红线**。冲突时以红线为准。

### 3.3 引入脚本（可复现、可审计）

```console
node scripts/vendor-skills.mjs --src=<clone 源目录>
```

脚本里有一份 `VENDORED` 清单（repo / org / license / category）。
**只有许可干净的在清单里**；无 LICENSE 的一律不进（列入许可债，见 `SOURCES.md` §五）。

---

## 四、离线 vendor（一次 clone → 立刻可用）

### 4.1 为什么不用 lockfile / submodule

| 方案 | 为什么不选 |
|---|---|
| 只存 `package-lock.json` | 仍需 npm registry。用户代理不稳 → 部署挂 |
| git submodule | 仍需网络逐个子仓拉 |
| 只 vendor 5 个包不含依赖 | 运行时报 `ERR_MODULE_NOT_FOUND` |

**青囊选**：把**已跑通一次的完整依赖树**整体拷进仓库。

### 4.2 目录名的坑（必须记）

```
✅ vendor/node_modules/<pkg>/        ← 正确
❌ vendor/mcp/<pkg>/                 ← 错误，会导致 ERR_MODULE_NOT_FOUND
```

**原因**：Node 解析 `import 'dotenv'` 时，从文件所在目录**逐级向上**，
在每个祖先目录 `D` 里查 `D/node_modules/dotenv`。

- 放 `vendor/node_modules/` → 祖先 `vendor` 提供 `vendor/node_modules/` ✓
- 放 `vendor/mcp/` → 祖先里**没有任何目录叫 node_modules** ✗

### 4.3 裁剪策略（跨平台优先）

| 裁什么 | 省了 |
|---|---|
| sourcemap（`*.map`） | 32 MB |
| TS 类型声明（`*.d.ts` / `*.ts`） | 约 3 MB |
| 测试 / 文档 / CI 配置 | 少量 |
| 非目标平台原生二进制 | 约 12 MB |
| `pdf-parse` 多余 3 个 pdf.js 版本 | 约 21 MB |

**131 MB → 46.4 MB**

**不裁的**：6 个目标平台的 koffi 原生二进制
（`linux_x64` `linux_arm64` `darwin_x64` `darwin_arm64` `win32_x64` `win32_arm64`）。
理由：产物要装到**别人的机器**上，**跨平台优先于体积**。

### 4.4 解析顺序

```js
function pkgRoots() {
  const roots = [ join(REPO, 'vendor', 'node_modules') ]   // ① 离线优先
  if (existsSync(join(REPO, 'node_modules'))) roots.push(...)  // ② 开发态回退
  return roots
}
```

### 4.5 自检

```console
node scripts/vendor-mcp.mjs --verify      # 依赖闭包完整性
node scripts/qingnang.mjs check           # 含 vendor 断言
```

---

## 五、启动机制（跨平台的关键）

### 5.1 manifest 是唯一事实源

`mcp-servers/manifest.json` 里每条通道的启动命令是：

```json
"command": ["node", "scripts/qingnang.mjs", "serve", "<id>"]
```

**为什么这么设计**：

| 收益 | 说明 |
|---|---|
| **跨平台** | `node ...` 在 PowerShell / CMD / bash / zsh 里行为一致。**不需要 WSL、不需要 Git Bash** |
| **零新增依赖** | Node 是 MCP 的**必备运行时**——装得下 MCP 就必然有 Node |
| **集中兜底** | 凭据门、env 合并、代理回填、入口解析全在 `serve` 里做一次，不散落 |
| **宿主无关** | 任何宿主只要会起 stdio MCP 就能用 |

### 5.2 `serve` 做的四件事

```
① 凭据门检查      缺必需凭据 → 明确提示 + exit 2（不算崩溃）
② env 合并        manifest 覆盖值 + .env + 现有环境
③ 入口解析        vendor 优先 → node_modules 回退
④ 转发 stdio      起真实 MCP 进程，接管 stdin/stdout
```

### 5.3 六种宿主配置格式

```console
node scripts/qingnang.mjs mcp-config --format={claude|pi|openclaw|codex|dsh|generic}
```

**全部输出纯 JSON**（机器优先，符合 P1「为 Agent 而做」）。
人读的说明在 `deploy --mode=agent` 的对话输出里，不在 JSON 里。

`dsh` 格式对齐 DeepSeek Harness Desktop 的 `StdioConfig` 形状
（`transport` / `serverName` / `command` / `args` / `env` / `cwd` / `toolCallTimeoutMs` / `failOnStartupError`）。

---

## 六、降级链（全链三档，必须可观察）

| 层 | 首选 | 次选 | 兜底 |
|---|---|---|---|
| **MCP 依赖** | vendor 随包分发（零网络） | npm install | pnpm install |
| **JS 包管理器** | pnpm（隔离布局） | npm | yarn |
| **Python 环境** | uv venv | python -m venv | conda |
| **代理** | 自动探测并**真实验证** | 用户 `.env` 手填 | 直连 |
| **MCP 调用** | 通道首选模式 | 通道次选模式 | 降级到另一条通道 |
| **宿主注入** | 原生 skills 目录 | 追加 marker 块 | 输出路径让用户手动贴 |

### 三条纪律

| # | 纪律 | 反例 |
|---|---|---|
| **① 必须可观察** | 降档时说清「走了哪档、为什么」 | 静默降级 = 降级没发生，用户不知道自己在用什么 |
| **② 兜底允许放弃** | 能力不可用时**明说不可用** | 硬凑一个不相关通道 = 编造 |
| **③ 兜底不许污染** | 任何降级都不得触碰 `~/.qingnang/private/` | — |

### 两个特殊案例

**`degrade_to: null` 是设计，不是遗漏**

`get_biji`（病友经验通道）的能力是**独有**的——没有替代品。
硬指一个"降级目标"等于虚构能力。所以它显式写 `null` + `degrade_note`。

**代理验证不是「看端口在不在」**

端口在监听 ≠ 代理真的能转发。青囊发**真实 CONNECT 请求**验证，结果分三档：

| 档 | 含义 |
|---|---|
| **已验证可用** | 真发请求成功 |
| **端口在听但不转发** | 能连上但代理不通 —— **这是最坑的一档**，看端口会误判 |
| **无法判定** | socks5 等无法用 HTTP 探测 |

---

## 七、隐私架构

```
~/.qingnang/private/          权限 0700
├── 报告单原件
├── 解析文本
├── 病情档案
├── 检索历史
└── DICOM 影像
```

| 约束 | 实现 |
|---|---|
| **永不出机** | `private/` 与 `private/` 均在 `.gitignore`；`phi_scan.mjs` 扫描 |
| **遥测唯一值 `off`** | 其他值脚本直接拒绝（不警告，是拒绝） |
| **网络请求只带关键词** | 不携带身份 / 病情细节 |
| **导出不碰 private** | 任何导出路径都不允许指向 `private/` |
| **脱敏闸门** | 病历类内容出机前必须过 `medical-desensitization`；不通过则**拒绝**后续处理 |
| **本机画像** | `HOST_PROFILE.md` 含代理与硬件 → 已 gitignore |

---

## 八、为下游预留的五条 forge 接缝

**背景**：阶段二是「青囊 × DSH Desktop 合并」，阶段三是「社区版 DSH Desktop」。
本包**不写任何 DSH 代码**（ADR-006），但必须留好缝。

| 缝 | 内容 | 当前产物 |
|---|---|---|
| **S1** | **零宿主专属代码** | `check` 扫 7 个特征词（`dsh-plugin` / `StdioConfig` / `ctx.inject` / …）全 0 命中 |
| **S2** | **manifest 唯一事实源** | `mcp-servers/manifest.json` |
| **S3** | **三层注入物理分离** | `INJECT.md` / `SEARCH_RUNTIME.md` / `HOST_PROFILE.md` 三个独立文件 |
| **S4** | **合并契约随包交付** | `skills/qingnang/MERGE_CONTRACT.md` |
| **S5** | **本机画像解耦** | `HOST_PROFILE.md` 可随时重新生成，与能力层无关 |

**DSH 事实（已实测，非猜测）**：

| 项 | 值 |
|---|---|
| 主体 | `anywhere-labs/dsh-desktop`（MIT） |
| 插件机制 | **Cordis TS 插件**（`export const name` / `export const inject` / `export function apply(ctx)`） |
| **无 `SKILL.md` 目录约定** | 所以青囊的技能层在 DSH 里要靠 Cordis 插件承载，不能靠目录约定 |
| MCP 配置形状 | `StdioConfig`：`transport` / `serverName`（`[A-Za-z0-9_-]{1,32}`）/ `command` / `args` / `env` / `cwd` / `toolCallTimeoutMs` / `failOnStartupError` / `reconnect?` |
| 工具名形式 | `mcp__<serverName>__<rawName>` |
| `dsh-community-fabric` | manifest / capability / 统一事件模型仍是 **RFC Draft**，官方明写「尚不能作为依赖」→ 本包不碰 |

**给 DSH 后端的三条嵌入提示**：

1. **用绝对路径指向 node 可执行文件**（打包后 PATH 不可靠）
2. **凭据门通道设 `failOnStartupError: false`**（否则缺凭据会打断整体启动）
3. 配置里可用 `_qingnang` 元数据字段承载 UI 提示

---

## 九、落盘布局

```
QingNang/
├── README.md                     ← 唯一给人看的文件
├── AGENTS.md ≡ CLAUDE.md         ← Agent 工作规则（逐字一致，有断言）
├── CONTRIBUTING.md
├── LICENSE                       ← Apache-2.0 + 医学免责
├── MANIFEST.json                 ← 机器可读包清单
├── package.json                  ← 仅用于构建 MCP 依赖
│
├── mcp-servers/
│   ├── manifest.json             ← ★ 唯一事实源（7 通道）
│   └── healthcheck.mjs
│
├── skills/                       ← 11 个 skill（1 主 + 10 社区）
├── vendor/                       ← ★ 离线依赖（265 包 / 46MB）
│   ├── VENDOR.json
│   └── node_modules/
│
├── scripts/
│   ├── qingnang.mjs              ← 统一入口
│   ├── vendor-mcp.mjs            ← MCP 离线打包
│   ├── vendor-skills.mjs         ← 社区 skill 引入
│   └── phi_scan.mjs              ← 隐私扫描
│
├── docs/                         ← 人类参考文档
├── tasks/CHG-20261014-qingnang-mvp/  ← 立项三件套 + PRD
└── tests/acceptance/             ← 端到端验收
```

---

## 十、核心命令速查

| 命令 | 作用 |
|---|---|
| `node scripts/qingnang.mjs fetch` | 校验 / 构建本地能力层（vendor 优先，零网络） |
| `node scripts/qingnang.mjs deploy --mode=source` | 探测本机 + 建私有目录 |
| `node scripts/qingnang.mjs deploy --mode=agent` | 装 11 个 skill 到宿主 |
| `node scripts/qingnang.mjs doctor` | 九项体检 |
| `node scripts/qingnang.mjs check` | 聚合自检 |
| `node scripts/qingnang.mjs probe` | 本机探测 |
| `node scripts/qingnang.mjs serve <id>` | 起单条 MCP（宿主用） |
| `node scripts/qingnang.mjs mcp-config --format=dsh` | 输出宿主配置 |
| `node scripts/vendor-mcp.mjs --verify` | vendor 完整性 |
| `node tests/acceptance/e2e.mjs` | 端到端验收 |
| `node scripts/phi_scan.mjs .` | 隐私扫描 |
