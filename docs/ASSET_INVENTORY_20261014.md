# 青囊 Phase 0 · 社区资产盘点底稿（全量 137 仓库）

> 盘点时间：2026-10-14 ｜ 方式：GitHub API 全量枚举（orgs/PancrePal-xiaoyibao=95 + orgs/opencare-skillhub=42）
> 图例：**P0** MVP必选 ｜ **P1** 二期 ｜ P2 后置 ｜ OBS 观察名单 ｜ ⛔ 不入包（合规/运营类）
> ⚠️ = 许可证缺失或不明确，vendor 前必须补齐/确认

## A. 医学检索 MCP（青囊能力层核心）

| 仓库 | org | 许可证 | 活跃度 | 定向 | 备注 |
|---|---|---|---|---|---|
| mcp-pubmed-server-pancrpal | PancrePal | repo=Apache-2.0（npm元数据写MIT⚠️不一致） | ★11 · 2026-05 | **P0** | 文献检索主通道 |
| unified-trial-search-mcp-service | opencare | MIT | 2026-10-06发版 | **P0** | 统一试验检索：ICTRP+CT.gov+ChiCTR+中国登记平台 |
| MCP-KnowS-AI | PancrePal | ⚠️ repo无LICENSE（npm声明MIT） | ★0 · 2026-04 | **P0** | KnowS医学证据；需凭据 |
| chictr-mcp-server | PancrePal | Apache-2.0 | ★5 · 2026-10-04 | P2 | ChiCTR单通道MCP（unified-trial已覆盖，作上游参考/降级备份） |
| xiaoyibao-clinical-trials-mcp-server | PancrePal | MIT | ★6 · 2026-01 | P2 | 早期单通道CT.gov（npm: xiaoyibao-clinical-trials） |
| dayi-search-mcp | PancrePal | ⚠️ none | ★1 · 2026-04 | P2 | 大医dayi.org.cn检索（中药/西药说明书向） |
| metasota-API-MCP | PancrePal | Apache-2.0 FORK | 2026-03 | OBS | 秘塔搜索（需秘塔API凭据） |
| openAlex-mcp | PancrePal | FORK | 2026-02 | OBS | 学术检索补充 |
| dicom_download_mcp | PancrePal | ⚠️ NOASSERTION（禁商用禁收费） | ★4 | P2 | DICOM CT报告下载；条款自定义 |
| dxy_med_crawl | PancrePal | ⚠️ none | ★8 | ⛔/P2 | 丁香园药物说明书爬取，合规风险，仅内部评估 |

## B. 临床试验类（skill + 数据管线）

| 仓库 | org | 许可证 | 定向 | 备注 |
|---|---|---|---|---|
| clinicaltrials-query-analysis | opencare | Apache-2.0 | **P1** | 检索+LLM分析 skill，比裸检索强 |
| chictr-trials-collector | opencare | Apache-2.0 | **P1** | ChiCTR提取+患者匹配 skill |
| chinadurgtrials | opencare | ⚠️ none | P1 | chinadrugtrials.com提取 skill（补license） |
| chinadrugtrials-collector | PancrePal | ⚠️ none | P1 | chinadrugtrials docx/json→RAG 数据管线 |
| ctg-rag-genie | PancrePal | ⚠️ NOASSERTION | P1 | CT.gov+ChiCTR自动中文化RAG |
| clinical_trial_api_search | PancrePal | ⚠️ none | P2 | CT官方API查询脚本（早期） |
| search_china_trials | PancrePal | ⚠️ none | P2 | 中国肿瘤试验查询脚本（早期） |
| clinical-trial-matching | opencare | FORK ⚠️ | OBS | CancerDAO试验匹配，借鉴其匹配逻辑 |

## C. 医学文档/知识处理（数据管线与本地RAG）

| 仓库 | org | 许可证 | 定向 | 备注 |
|---|---|---|---|---|
| MinerU-xyb | PancrePal | AGPL-3.0 | P1 | 社区MinerU分支 ★16 |
| mineru-tianshu | PancrePal | Apache-2.0 FORK | P1 | 天枢PDF→Markdown+MCP平台；底层含MinerU组件，Phase 0核许可继承 |
| nccn-guideline-downloader | opencare | Apache-2.0 | **P1** | NCCN指南+患者手册多语言下载；⚠️产出仅做要点摘录，全文受版权保护不得再分发 |
| NCCN_guideline_download | PancrePal | ⚠️ none | P2 | 同类早期版 |
| RAG-content-processor | opencare | Apache-2.0 | **P1** | 文章下载→格式化→上传 知识包生产线 |
| embedding-chunk-pre-processing | PancrePal | ⚠️ none | P1 | chunk标记优化，直接可用的小工具 |
| fastgpt-rag-kb-automation | PancrePal | ⚠️ none | P2 | FastGPT知识库自动化（青囊走本地索引，作参考） |
| fastgpt-kb-automation / kb-frontend / kb_upload_genie | PancrePal | 混合 | OBS | FastGPT生态周边 |
| rag-benchmarking | PancrePal | ⚠️ none | ★6 OBS | RAG评测体系，Phase 3质检可借鉴 |
| MedicRAG | PancrePal | Apache-2.0 | OBS | 医学研究→患者提示词转化 |
| pdf-translate | opencare | FORK | OBS | PDF翻译（pdf2zh） |

## D. 隐私与病历管理（青囊隐私层的天然盟友）

| 仓库 | org | 许可证 | 定向 | 备注 |
|---|---|---|---|---|
| maskdesk | PancrePal | Apache-2.0 FORK | **P1** | 🔒Local-first病历脱敏工作台「数据永不出机」——与青囊隐私铁律同频，2026-09-30活跃 |
| medical-desensitization | PancrePal | Apache-2.0 | **P1** | 医疗脱敏TS库 |
| Medical-Record-Organizer | opencare | ⚠️ none | **P1** | llm/mineru/paddle整理多中心病历 skill（补license） |
| case-organizer | PancrePal | ⚠️ none | P2 | 患者跨院治疗材料整理 |
| ca199_toolbox_donated_by_lihb | PancrePal | AGPL-3.0 | **P1** | CA19-9+治疗管理工具箱★7（胰腺癌核心指标；独立工具形态，不与核心代码混合） |
| ca199_toolbox_flutter | PancrePal | ⚠️ none | OBS | 上者的Flutter版 |
| xyb_dicom_download_skills | opencare | Apache-2.0 | P2 | DICOM下载skill |
| aura_health_profile | opencare | MIT-0 | **P1** | 慢病患者健康档案skill |
| family_health | PancrePal | Apache-2.0 FORK | OBS | 内网家庭健康管理 |

## E. 心理支持与康复

| 仓库 | org | 许可证 | 定向 | 备注 |
|---|---|---|---|---|
| skill-HADS-accessment | opencare | ⚠️ none | **P1** | HADS医院焦虑抑郁量表skill（补license；量表本身版权需核） |
| Agent-Scale-MCP / Agent-Scale | PancrePal | ⚠️ none | P2 | 心理测评量表MCP |
| inkstone-studio | opencare | Apache-2.0 | OBS | 自我改进心理文章写作 |
| pancrepal-breath-assistant | PancrePal | ⚠️ NOASSERTION | OBS | 胰腺术后呼吸评估（江苏省人民医院护理团队共建） |
| devil-chat | PancrePal | ⚠️ none | OBS | 帮患者/家属避错的游戏 |

## F. 病种垂直应用（青囊病种扩展的先行者/语料来源）

| 仓库 | org | 定向 | 备注 |
|---|---|---|---|
| PancrePal-xiaoyibao | PancrePal | **P0素材** | 智能RAG平台★27fork Apache-2.0——胰腺癌语料与RAG经验上游 |
| xyb-pi-agent | PancrePal(orig)+opencare(fork) | **P0** | PI桌面LGPL-3.0；Releases离线数据包（ChiCTR/CDE）=青囊公开知识包v0.1来源 |
| RAG-xiaofeibao-Lungcancer | PancrePal | OBS | 小肺宝·肺癌SCLC RAG Apache-2.0——病种扩展模板参照 |
| xiaofubao | PancrePal | OBS | 小腹宝·妇科肿瘤RAG |
| Lymphoma_AI_assistant_xiaoyibao | PancrePal | OBS | 小铃铛·淋巴瘤助手 |
| xiaoxuebao_AI_Project | PancrePal | OBS | 小雪宝·儿童 |
| xiaoxinbao_UI / xiaoxinbao-full / Xiaoxinbao_TTS / Heartie-fastGPT-analyzer / CareBot | PancrePal | OBS | 小馨宝系列（微信端服务） |
| xyb-Octop | opencare | OBS | PDAC定制Octop MIT |
| openpancan | PancrePal | P2 | 基于openrare的胰腺癌基因洞察 MIT |
| little_green_card | PancrePal | P2 | 基因报告患者友好解读 FORK |
| VitaForge | PancrePal | OBS | 通用医学AI4S干实验引擎 NOASSERTION |
| osintel-pancrepal / pancreapal-osintel / pancreatic-cancer-dailynews-skill / pancrepal-wechat-news-board | mixed | P2 | 胰腺癌情报/新闻追踪（药讯板块素材管线） |

## G. Agent 技能与大脑（skill 结构同源，注入层直接可参考）

| 仓库 | org | 许可证 | 定向 | 备注 |
|---|---|---|---|---|
| OpenClaw-Medical-Skills | opencare | FORK ⚠️ | P1参考 | 「最大开源医学AI技能库」fork，选编可用skill |
| openclaw_skills_pool | opencare | ⚠️ none | P1参考 | 龙虾workspace/skills可复用池 |
| Claude_skill_pool | opencare | Apache-2.0 FORK | OBS | cc skill动态更新 |
| agent-math-seed-system | opencare/PancrePal | Apache-2.0 | OBS | 数学大脑社区版（种子库模式已在社区传播，青囊skill结构与之一脉相承） |
| agent-taste-seed-system | opencare/PancrePal | FORK ⚠️ | OBS | 美学大脑社区版 |
| openclaw-backup-restore-ops | opencare | AGPL-3.0 | OBS | 帮病友运维OpenClaw（DSH语境下弱化） |
| getnote-openclaw | opencare | MIT FORK | P1 | Get笔记skill（配get-biji MCP） |
| get-biji-dev-by-gemini3pro / get_biji_mcp | PancrePal | ⚠️ 均无LICENSE | **P1** | Get笔记MCP×2（npm: get-biji-mcp；先补license再vendor） |
| skill-HADS 等 UI/运营skills | opencare | 见各表 | — | 含 renjianshi(MIT)、xyb-humanizer、xyb-whitepaper-writer、inkstone、generic-image-gen-skills(⚠️) 等 |
| codex-tokens-compress | opencare | MIT FORK | OBS | AGENTS.md压缩实验（注入层瘦身可借鉴） |

## H. 提示词与知识资产（直接喂 references/）

| 仓库 | org | 许可证 | 定向 | 备注 |
|---|---|---|---|---|
| PDAC-multi-agents-prompts | PancrePal | Apache-2.0 | **P0素材** | PDAC多场景多智能体提示词集——零成本并入知识层 |
| Genie-X-PAL-prompts-center | PancrePal | ⚠️ none | **P1素材** | CA患者/家属提示词中心 |
| web-xyb-writer-pal / xyb-wechat-article-* / awesome_research_writter | mixed | 混合 | OBS | 写作/公众号运营类 |

## I. 社区运营与基建（⛔ 默认不入包）

微信机器人系（dify-on-wechat、dow_gewe_*、chatgpt-on-wechat-win、fastgpt_xiaoyibao_xxxbot、xxxbot-GetWeather、dow-qr-helper）、文章爬取系（crawl_wx_articles、batch_download_wx_articles、xyb_wx_articles、wechat-article-downloader⚠️AGPL）、小程序/官网/图床（miniapp-*、web、Positivus、my-images、xiaoxbao_community_edgeone_publish、community_volunteer_miniapp、MemoPal）、监控/基建（xiao-x-bao-monitor、xiao-x-bao-tech-infra、code-server-samedition、claudecode_quick_switch、nb、picoclaw、VibeWheel、CodeForge、Secondev-easy-datasets、MedGemma3_test_xyb、gemini2.0-xiaoyibao）、校园/黑客松（DKU-*、hackathon2026、Hackathon-internal）、3xpad(MIT★21公益工具)、aiyouth-personal-ip-website、sol-advisor、SenseNova-Skills、lark/feishu skills、renjianshi、skills_report_genie、feishu-lark-cli-message-process-skills、llm-wiki-pancrepal(graphify)、graphify-xiaoyibao(AGPL)、PubMed-Agent、.github×2

> 注：llm-wiki-pancrepal-graphify（MIT，患者私有知识库LLM组织）值得P1深读，暂列观察因其定位与青囊本地RAG重叠。

## 汇总统计

| 定向 | 数量 | 说明 |
|---|---|---|
| **P0** | 7 项能力/素材 + 2 项素材来源 | §5.1 主文档 |
| **P1** | ~18 项 | 主攻：知识包生产管线 + 病历/指标管理 + 心理评估 |
| P2 | ~15 项 | 备选与降级 |
| OBS | ~25 项 | 深读后升降级 |
| ⛔ 不入包 | ~70 项 | 运营/基建/爬虫 |

## ⚠️ 许可证债清单（vendor 前必须清偿）

1. `MCP-KnowS-AI` repo 无 LICENSE（npm 声明 MIT）→ 请 Sam 在 repo 补 LICENSE 文件
2. `mcp-pubmed-server-pancrpal` repo=Apache-2.0 vs npm=MIT 不一致 → 统一口径
3. `get-biji-dev-by-gemini3pro` + `get_biji_mcp` 双仓库均无 LICENSE
4. `skill-HADS-accessment`、`Medical-Record-Organizer`、`dayi-search-mcp`、`chinadurgtrials`、`chinadrugtrials-collector` 等 none → P1 前补
5. `dicom_download_mcp`（禁商用）、`VitaForge`、`ctg-rag-genie`（NOASSERTION）→ 逐条人工核条款
6. xyb-pi-agent 离线数据包（数据再分发条款）→ 书面确认
7. NCCN 指南：工具 Apache-2.0 可用，**指南全文有版权** → 只做要点摘录+官方链接，不得全文分发
