# 来源与许可台账（SOURCES）

> **本文件是青囊的许可事实底账。** 每个进入本包的 MCP / skill / 知识资产都必须在册。
> 新增能力时**必须**在此登记（见 `MERGE_CONTRACT.md` §4）。未登记的资产视为**未授权纳入**。

**登记时间**：2026-10-14 ｜ **许可白名单**：`MIT` / `Apache-2.0` / `ISC` / `BSD-3-Clause`

---

## 一、MCP 通道（7 条，全部已接入）

| # | 通道 | 包 | 版本 | 上游 | 许可 | 判定依据 | 待办 |
|---|---|---|---|---|---|---|---|
| 1 | 通用网页搜索 | `open-websearch` | 2.2.0 | [Aas-ee/open-webSearch](https://github.com/Aas-ee/open-webSearch) | **Apache-2.0** | 上游 LICENSE 文件 | `package.json.license` 缺失（为 `None`），以上游文件为准 |
| 2 | 中文网页搜索 | `bing-cn-mcp` | 1.0.2 | [yan5236/bing-cn-mcp-server](https://github.com/yan5236/bing-cn-mcp-server) | **MIT** | repo + npm 一致 | — |
| 3a | 医学文献 | `mcp-pubmed-llm-server` | 3.0.0 | [PancrePal-xiaoyibao/mcp-pubmed-server-pancrpal](https://github.com/PancrePal-xiaoyibao/mcp-pubmed-server-pancrpal) | **MIT** | npm 元数据（实际分发物） | repo 标 Apache-2.0，与 npm 不一致 → 建议上游统一口径 |
| 3b | 学术文献 | `openalex-mcp-server` | 1.0.5 | [SecretRichGarden/openAlex-mcp](https://github.com/SecretRichGarden/openAlex-mcp) | **ISC** | npm 元数据 | ⚠️ 上游 repo 无 LICENSE 文件；ISC 与 MIT 实质等同，**已显式加入白名单** |
| 4 | 临床试验 | `unified-trial-mcp` | 0.3.1 | [opencare-skillhub/unified-trial-search-mcp-service](https://github.com/opencare-skillhub/unified-trial-search-mcp-service) | **MIT** | repo + npm 一致 | — |
| 5 | 高级医学证据 | `@xiaoyibao_npm/knows-mcp-server` | 0.2.2 | [PancrePal-xiaoyibao/MCP-KnowS-AI](https://github.com/PancrePal-xiaoyibao/MCP-KnowS-AI) | **MIT**（按惯例） | npm 元数据声明 | ⚠️ 上游 repo 无 LICENSE 文件 → **建议上游补 LICENSE**（见下「许可债」） |
| 6 | 病友经验 | `get-biji-mcp` | 0.1.1 | [PancrePal-xiaoyibao/get_biji_mcp](https://github.com/PancrePal-xiaoyibao/get_biji_mcp) | **MIT**（按惯例） | npm 元数据声明 | ⚠️ 上游双仓库均无 LICENSE 文件 → **建议上游补 LICENSE** |

### 许可判定惯例（本包采用）

```
1. 优先上游 LICENSE 文件
2. 文件缺失 → 以 npm 元数据声明为准（npm 是实际分发渠道）
3. 两者不一致 → 记 license_note 说明差异，并在此表登记待办
4. 一律登记在册，不因"待办未完成"而阻止接入
     └─ 理由：社区内部资产（KnowS / get-biji 均属 PancrePal 组织内）补 LICENSE 是
        内部协作事项，不应阻塞整个包的可用性
```

---

## 二、合并进来的 skill 资产（方式 B：改进后并入）

| 来源 skill | 许可 | 并入到 | 改了什么 |
|---|---|---|---|
| [clinicaltrials-query-analysis](https://github.com/opencare-skillhub/clinicaltrials-query-analysis) | **Apache-2.0** | `references/trials/report-outline.md`<br>`references/trials/targets.md` | 抽取「标准化报告提纲」与靶点清单；**新增青囊四条医学约束**（不给治疗建议 / 不承诺医保 / 状态带采集时间 / 只用公开联系方式）；移除公众号排版细节 |
| [chictr-trials-collector](https://github.com/opencare-skillhub/chictr-trials-collector) | **Apache-2.0** | `references/trials/chictr-guide.md` | 保留参数约束与数据质量规则；**补充「诚实边界」四条纪律**；移除采集器源码细节 |
| [clinicaltrials-intel-skill](https://github.com/opencare-skillhub/clinicaltrials-intel-skill) | **Apache-2.0** | `references/trials/intel-pipeline.md` | 抽取「两阶段分离」核心契约 + 三条关键契约；**补充三条面向病友的约束**；移除 TG/GeWe/飞书/FastGPT 具体接入 |
| [nccn-guideline-downloader](https://github.com/opencare-skillhub/nccn-guideline-downloader) | **Apache-2.0** | `references/guidelines/nccn-cancer-types.md` | 保留 68 项癌种清单；**新增版权硬约束章节**（只做要点摘录 + 官方链接）；移除自动下载脚本与 Cookie 配置 |

> **方式 B 的硬要求**：每个并入文件的开头都必须注明「来源 + 改动 + 许可」。已全部标注。

---

## 三、只登记、未并入代码（方式 C：许可隔离）

| 资产 | 许可 | 为什么只登记 | 处置 |
|---|---|---|---|
| [ca199_toolbox_donated_by_lihb](https://github.com/PancrePal-xiaoyibao/ca199_toolbox_donated_by_lihb) | **AGPL-3.0** | AGPL 有传染性——链接即传染 | **不并入代码**。只在本表登记其存在与用途（CA19-9 指标趋势管理工具，本地处理无上传）。未来若纳入，须以**独立子进程 / 独立目录**形态隔离，并在发行物列明第三方许可 |
| [MinerU-xyb](https://github.com/PancrePal-xiaoyibao/MinerU-xyb) / [mineru-tianshu](https://github.com/PancrePal-xiaoyibao/mineru-tianshu) | AGPL-3.0 / Apache-2.0(FORK) | 同上 + 体积大（GB 级模型权重） | Phase 3 再评估；原则：**独立子进程 + 独立 venv，不进主依赖树** |
| [maskdesk](https://github.com/PancrePal-xiaoyibao/maskdesk) | Apache-2.0 | 是完整应用（Electron 桌面），不是能力（skill/MCP） | **只借鉴思路**（local-first 脱敏），不纳入 |
| [little_green_card](https://github.com/PancrePal-xiaoyibao/little_green_card) | NONE | 是完整 React 应用 + 无许可 | 不纳入 |
| [devil-chat](https://github.com/PancrePal-xiaoyibao/devil-chat) | NONE | 是游戏原型 + 无许可 | 不纳入 |

---

## 四、经准入判定「拒绝入包」的资产（登记理由，避免重复评估）

| 资产 | 拒绝理由（按准入四条） |
|---|---|
| `xyb-wechat-article-generator` / `xyb-wechat-article-transcription` | **非能力**——是公众号运营工具（准入第 2 条：应用不入，只借鉴） |
| `xyb-whitepaper-writer` / `xyb-humanizer` | 同上 |
| `generic-image-gen-skills` | 同上 + 无 LICENSE |
| 微信机器人系（`dify-on-wechat` / `dow_gewe_*` / `chatgpt-on-wechat-win` 等） | **非医学能力** + 运营基建（准入第 1、2 条） |
| 社区官网 / 小程序 / 图床系（`miniapp-*` / `web` / `my-images` 等） | 同上 |
| `xyb_dicom_download_skills` | **边界敏感**——DICOM 影像下载涉及患者影像数据流转。虽为 Apache-2.0，但与本包「数据不出机」铁律冲突，**暂不纳入**，留给未来的桌面端项目评估 |
| `RAG-content-processor` | 是**内部生产工具**（文章下载→格式化→上传），不是面向病友的能力。Phase 3 做知识包生产时再考虑 |
| `Medical-Record-Organizer` / `skill-HADS-accessment` | ⚠️ 无 LICENSE 文件 → 待上游补。**补后可重新评估**（两者都是医学相关能力，价值不低） |
| `chinadrugtrials-collector` / `pancreatic-cancer-dailynews-skill` | ⚠️ 无 LICENSE 文件 → 待上游补 |
| `ca199_toolbox_flutter` / `ca199_toolbox_mp` | ⚠️ 无 LICENSE + 与 `ca199_toolbox` 同源 → 以那个为准 |

---

## 五、许可债清单（**给社区的行动项**）

| # | 仓库 | 缺什么 | 影响 | 优先级 |
|---|---|---|---|---|
| 1 | `PancrePal-xiaoyibao/MCP-KnowS-AI` | LICENSE 文件（npm 已声明 MIT） | 通道 5 的许可依据只有 npm 元数据 | **中**（已可用，但依据偏弱） |
| 2 | `PancrePal-xiaoyibao/get_biji_mcp` 与 `get-biji-dev-by-gemini3pro` | LICENSE 文件（npm 已声明 MIT） | 通道 6 同上 | **中** |
| 3 | `SecretRichGarden/openAlex-mcp` | LICENSE 文件（npm 声明 ISC） | 通道 3b 同上。注意：这是**外部**仓库，非社区内部 | **中** |
| 4 | `opencare-skillhub/Medical-Record-Organizer` | LICENSE 文件 | 无法纳入（病历整理是刚需能力） | **高** |
| 5 | `opencare-skillhub/skill-HADS-accessment` | LICENSE 文件（另需核量表版权） | 无法纳入（心理评估是刚需） | **高** |
| 6 | `opencare-skillhub/chinadrugtrials-collector` | LICENSE 文件 | 无法纳入 | 中 |
| 7 | `opencare-skillhub/pancreatic-cancer-dailynews-skill` | LICENSE 文件 | 无法纳入（药讯追踪有价值） | 中 |
| 8 | `opencare-skillhub/clinical-trial-matching` | LICENSE 文件（且为 fork） | 无法纳入 | 低 |
| 9 | `mcp-pubmed-server-pancrpal` | repo(Apache-2.0) 与 npm(MIT) **不一致** | 需统一口径 | 低（两者皆宽松） |

---

## 六、本仓库自身许可

**Apache-2.0**（见 `LICENSE`），附医学免责声明（非许可条款部分）。

**为什么选 Apache-2.0 而非 MIT**：
- 含**专利授权**（对医疗信息化场景更稳妥）
- 与多数上游一致（`open-websearch` 也是 Apache-2.0）
- 要求保留 NOTICE——对本项目「标注来源与改动」的纪律天然一致

---

## 七、第三方组件声明（面向发行物）

若青囊被打包进发行版（未来 DSH 项目），**必须**在第三方许可页列明：

| 组件 | 许可 | 要求 |
|---|---|---|
| `open-websearch` | Apache-2.0 | 保留版权声明 + NOTICE |
| `bing-cn-mcp` | MIT | 保留版权声明 |
| `mcp-pubmed-llm-server` | MIT | 同上 |
| `openalex-mcp-server` | ISC | 同上 |
| `unified-trial-mcp` | MIT | 同上 |
| `@xiaoyibao_npm/knows-mcp-server` | MIT（待补文件） | 同上 |
| `get-biji-mcp` | MIT（待补文件） | 同上 |
| 并入的 skill 资产（4 项） | Apache-2.0 | 保留来源与改动说明 |
| **NCCN 指南内容** | **受版权保护** | **不得再分发全文**，只做要点摘录 + 官方链接 |
