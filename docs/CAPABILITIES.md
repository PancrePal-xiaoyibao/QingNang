# 青囊 · 完整能力清单

> 本文件是 [`README.md`](../README.md) 的展开版：把「部署后到底获得什么」逐项说清。
> 生成方式：`node scripts/qingnang.mjs doctor` + 实跑 `tools/list` 验证（不是抄文档）。

---

## 一、技能层（11 个 Skill）

### 1.1 主技能（1 个，必需）

| Skill | 路径 | 上限 | 职责 |
|---|---|---|---|
| `qingnang` | `skills/qingnang/` | — | 总路由 + 五条医学红线 + 七步执行流 + 七通道分流 + 降级链 |

**`qingnang` 内部由 5 个文件组成，物理分离：**

| 文件 | 上限 | 加载时机 | 内容 |
|---|---|---|---|
| `INJECT.md` | 2048B | **常驻** | 宣告存在 + 三条红线 + 指路（**不含任何工具名**） |
| `SEARCH_RUNTIME.md` | 8192B | 涉搜索时 | 7 条通道分工、参数、降级顺序、双向引用 |
| `SKILL.md` | 14336B | 需要路由时 | 两跳路由表 + 表达要求 + 失败与降级 + MCP 耦合声明 |
| `MERGE_CONTRACT.md` | — | 贡献新能力时 | 4 条准入 + 3 种合并方式 + 耦合契约 |
| `HOST_PROFILE.md` | — | 需要本机信息时 | **运行时生成**（探测结果，已 gitignore） |

**为什么物理分离**：常驻上下文越短，Agent 注意力预算越省。
有自动断言守住——`check` 会验证 `INJECT.md` **不出现任何工具包名**。

### 1.2 社区医学技能（10 个，原样引入）

引入方式：**上游代码一字未改**（`git clone --depth 1` → 剥离依赖/产物），
青囊在每个目录追加一份 `QINGNANG.md` 适配层。
引入脚本：`node scripts/vendor-skills.mjs`（可复现、可审计）。

| # | Skill | 干什么 | 许可 | 上游 |
|---|---|---|---|---|
| 1 | `clinicaltrials-query-analysis` | 试验检索 + LLM 分析 + 中英对照专题报告（含靶点清单、中国中心专题） | Apache-2.0 | opencare-skillhub |
| 2 | `chictr-trials-collector` | 中国临床试验登记平台（ChiCTR）采集，结构化 JSON 导出 | Apache-2.0 | opencare-skillhub |
| 3 | `clinicaltrials-intel-skill` | 试验情报订阅：抓取 → 双路径处理 → 多渠道推送 | Apache-2.0 | opencare-skillhub |
| 4 | `nccn-guideline-downloader` | NCCN 指南 / 患者手册多语言获取（**含版权硬约束**） | Apache-2.0 | opencare-skillhub |
| 5 | `RAG-content-processor` | 知识包生产线：下载 → 清洗 → LLM 富化标签 → QA 评分 → 入库 | Apache-2.0 | opencare-skillhub |
| 6 | `aura_health_profile` | 慢病健康档案：散乱检验单/医嘱 → 清晰健康档案 + 复诊简报 | MIT-0 | opencare-skillhub |
| 7 | `getnote-openclaw` | 笔记沉淀（病友经验记录与检索） | MIT | opencare-skillhub |
| 8 | `xyb_dicom_download_skills` | DICOM 影像下载与整理 | Apache-2.0 | opencare-skillhub |
| 9 | `medical-desensitization` | 医疗文本与病历脱敏（Go 后端 + Next.js 前端）＊ | Apache-2.0 | PancrePal-xiaoyibao |
| 10 | `maskdesk` | Local-first 病历脱敏工作台（Electron）＊ | Apache-2.0 | PancrePal-xiaoyibao |

1. 来源与许可（上游 URL + SPDX + 引入方式 + 是否改动）
2. **青囊五条红线在本技能上如何生效**（M1 不做诊断 / M2 不给剂量 / M3 隐私不出机 / M4 急症先就医 / M5 出处标注）
3. 病人数据红线（示例数据 / 测试病例 / 报告单的处理约束）
4. 运行依赖（上游自带，青囊不代装）
5. 与主技能的关系（入口 / 分工 / 本机画像 / 搜索通道）

> **为什么原样引入而非拆解**：社区 skill 自带 `SKILL.md` + 可执行脚本，**是能力不是文档**。
> 把可执行能力拍平成参考文档 = **降级**，不是合并。见 `SOURCES.md` §二 的修订说明。

---

## 二、MCP 能力层（7 条通道 / 28 个工具）

实测命令：`node scripts/qingnang.mjs doctor`，或逐个 `serve <id>` 发 `tools/list`。

### 通道 1 · 通用网页搜索（Apache-2.0 · 零凭据）

包：`open-websearch@2.2.0`（6 工具）

| 工具 | 用途 |
|---|---|
| `search` | 多引擎聚合搜索 |
| `fetchWebContent` | 抓取网页正文 |
| `fetchGithubReadme` | 抓 GitHub README |
| `fetchCsdnArticle` | 抓 CSDN 文章 |
| `fetchJuejinArticle` | 抓掘金文章 |
| `fetchLinuxDoArticle` | 抓 LinuxDo 帖子 |

**特殊说明**：上游默认 `SEARCH_MODE=auto` 可能启用 Playwright（需 Chromium）。
青囊在 manifest 里**强制 `SEARCH_MODE=request`**，完全避开浏览器依赖。
代理支持：`USE_PROXY` / `PROXY_URL`（从 `HOST_PROFILE.md` 自动回填）。

### 通道 2 · 中文网页搜索（MIT · 零凭据）

包：`bing-cn-mcp@1.0.2`（2 工具）

| 工具 | 用途 |
|---|---|
| `bing_search` | 必应中文搜索 |
| `crawl_webpage` | 按搜索结果 UUID 抓正文（内置黑名单过滤知乎/小红书等） |

### 通道 3a · PubMed 医学文献（MIT · 零凭据）

包：`mcp-pubmed-llm-server@3.0.0`（5 工具）

| 工具 | 用途 |
|---|---|
| `pubmed_search` | 检索（支持 MeSH 与布尔逻辑） |
| `pubmed_get_details` | 取单篇详情（含摘要） |
| `pubmed_extract_info` | 抽取关键信息 |
| `pubmed_find_related` | 找相关文献 |
| `pubmed_manage_cache` | 缓存管理 |

提速：`NCBI_API_KEY`（选填，不填限速 3 次/秒，个人足够）。

### 通道 3b · OpenAlex 学术文献（ISC · 零凭据）

包：`openalex-mcp-server@1.0.5`（8 工具）

| 工具 | 用途 |
|---|---|
| `openalex_search` | 检索 |
| `openalex_get_work` | 取单篇详情（含摘要） |
| `openalex_batch_get_works` | 批量取（≤50 篇，省调用） |
| `openalex_detect_fulltext` | 检测开放获取状态 |
| `openalex_download_fulltext` | 下载开放获取全文 PDF |
| `openalex_get_fulltext_sections` | 抽取全文分节（摘要/方法/结果/讨论） |
| `openalex_cache_stats` | 缓存统计 |
| `openalex_system_check` | 系统与连通性自查 |

提速：`OPENALEX_EMAIL`（选填）。

### 通道 4 · 临床试验（MIT · 零凭据）

包：`unified-trial-mcp@0.3.1`（7 工具）

| 工具 | 用途 |
|---|---|
| `search_trials` | 统一检索（ICTRP + CT.gov + ChiCTR + 中国登记平台） |
| `get_trial_detail` | 取试验详情（入组标准、中心） |
| `get_record_evidence` | 取登记记录的原始证据片段 |
| `get_source_status` | **各数据源的真实查询状态** |
| `refresh_ictrp` | 刷新 ICTRP 索引 |
| `sync_ctv_index` | 同步 CT.gov 索引 |
| `sync_chinadrugtrials` | 同步中国药物临床试验登记平台 |

**`get_source_status` 是本通道的关键**：
只有 `SUCCESS` / `NO_RESULTS` 才算「真查过」。其他状态**不得**被解读为「没有试验」。
这条写进了主技能 `SKILL.md` 的降级表。

### 通道 5 · 高级医学证据（MIT · **需凭据**）

包：`@xiaoyibao_npm/knows-mcp-server@0.2.2`

| 项 | 说明 |
|---|---|
| 凭据 | `KNOWS_API_KEY` + `KNOWS_API_HOST`（走社区公众号/小程序申请） |
| 缺凭据时 | **自动降级到通道 3（PubMed + OpenAlex）**，并在回答中明示 |
| 许可状况 | npm 声明 MIT；**上游 repo 待补 LICENSE 文件**（见 SOURCES.md §五 许可债） |
| 工具清单 | 需凭据后实测，不在本文档猜测 |

### 通道 6 · 病友经验（MIT · **需凭据**）

包：`get-biji-mcp@0.1.1`

| 项 | 说明 |
|---|---|
| 凭据 | `GET_NOTE_API_KEY` |
| 缺凭据时 | **该通道不启用**（**该能力唯一，不用别的凑**） |
| 降级目标 | `null` —— 这是**有意为之**，不是遗漏 |
| 许可状况 | 上游双仓库均无 LICENSE 文件（npm 声明 MIT） |
| 工具清单 | 需凭据后实测，不在本文档猜测 |

> **`degrade_to: null` 是设计**：当一条通道的能力是独有的时候，
> 硬指一个「替代通道」等于**编造能力**。明确说「不可用」才是正确的兜底。

---

## 三、离线能力（vendor）

**7 个 MCP + 265 个依赖包已随仓库分发**，路径 `vendor/node_modules/`。

| 项 | 值 |
|---|---|
| 包数 | 265 |
| 体积 | 46.4 MB |
| 保留平台 | `linux_x64` `linux_arm64` `darwin_x64` `darwin_arm64` `win32_x64` `win32_arm64` |
| 裁掉了什么 | sourcemap（32MB）/ TS 类型声明（2.8MB）/ 测试 / 文档 / 非目标平台二进制 / pdf-parse 的 3 个多余 pdf.js 版本 |
| 清单 | `vendor/VENDOR.json` |
| 校验 | `node scripts/vendor-mcp.mjs --verify` |

**效果**：`git clone` 后**不跑 npm install、不联网**即可启动全部 5 条零凭据通道。

**为什么放 `vendor/node_modules/` 而不是 `vendor/mcp/`**：
Node 解析 `import 'dotenv'` 时，从文件所在目录逐级向上，在每个祖先目录 D 里查 `D/node_modules/dotenv`。
包放在 `vendor/node_modules/<pkg>/` 时，祖先 `vendor` 正好提供 `vendor/node_modules/✓`。
这个坑已踩过一次，见 `ADR-015`。

---

## 四、本机适配能力

| 能力 | 命令 | 产物 |
|---|---|---|
| 本机探测 | `deploy --mode=source` / `probe` | `skills/qingnang/HOST_PROFILE.md` |
| **代理真实验证** | 同上 | 区分「已验证可用 / 端口在听但不转发 / 无法判定(socks5)」 |
| 宿主分派 | `deploy --mode=agent` | 自动识别 Claude Code / pi / OpenClaw / Codex |
| 私有目录 | `deploy --mode=source` | `~/.qingnang/private/`（0700） |

**代理验证为什么不是「看端口在不在」**：端口在监听 ≠ 代理真的能转发。
青囊发**真实 CONNECT 请求**验证，并把结果分三档写进画像。
这条也踩过一次（曾误报「已验证可用」）。

---

## 五、输出格式（给宿主集成用）

| 格式 | 命令 | 说明 |
|---|---|---|
`claude` | `mcp-config --format=claude` | Claude Code / pi（`~/.claude.json` 的 `mcpServers`） |
`pi` | `mcp-config --format=pi` | 同上 |
`openclaw` | `mcp-config --format=openclaw` | OpenClaw 工作区配置 |
`codex` | `mcp-config --format=codex` | Codex |
`dsh` | `mcp-config --format=dsh` | **DeepSeek Harness Desktop**（对齐其 StdioConfig） |
`generic` | `mcp-config --format=generic` | 通用 stdio 形式 |

**6 种格式全部输出纯 JSON**（机器优先）。
理由：青囊是**给 Agent 用的**，人读的说明在 `deploy --mode=agent` 的对话输出里。

---

## 六、自检与验收命令

| 命令 | 检查什么 |
|---|---|
| `node scripts/qingnang.mjs check` | 聚合自检：MCP 清单 / 技能层体积 / vendor 完整性 / 隐私隔离 / 治理一致性 / forge 接缝 |
| `node scripts/qingnang.mjs doctor` | 9 项体检（含逐通道真实握手） |
| `node mcp-servers/healthcheck.mjs` | 通道健康（可用 / 选填未配 / 出错） |
| `node tests/acceptance/e2e.mjs` | 端到端验收 |
| `node scripts/vendor-mcp.mjs --verify` | vendor 依赖闭包完整性 |
| `node scripts/phi_scan.mjs .` | 隐私信息（PHI）扫描 |
| `cmp AGENTS.md CLAUDE.md` | 治理文档一致性 |
