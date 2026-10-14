# 端到端验收报告（E2E REPORT）

> **生成时间**：2026-10-14T15:59:48Z
> **运行模式**：在线
> **汇总**：通过 8 · 待观察 1 · 失败 0

> ⚠️ = 网络/外部依赖不可达，按 SPEC §5 规定**不记 ✅ 也不记 ❌**（见 AGENTS.md §1.6 兜底纪律）

| 锚点 | 状态 | 断言 | 实测证据 |
|---|---|---|---|
| **A12** | ✅ | 全部 7 条许可在白名单内 | 白名单: MIT, Apache-2.0, ISC, BSD-3-Clause |
| **A34** | ✅ | HOST_PROFILE 无凭据值 | 1419 字符已扫 |
| **A43** | ✅ | vendor 265 包 / 46.4M / 入口 7 个 | 平台: linux_x64 linux_arm64 darwin_x64 darwin_arm64 win32_x64 win32_arm64 |
| **A11** | ✅ | 握手通过 5 条（2 条待凭据） | web_search(6工具) bing_cn(2工具) pubmed(5工具) openalex(8工具) unified_trial(7工具) |
| **A15b** | ✅ | 2 条凭据门通道的降级语义均已显式声明 | knows→pubmed · get_biji(唯一能力，明示未启用) · 运行时: initialize 超时（15000ms） |
| **A23** | ✅ | 六类问题均有对应通道 + 分流表完整 | 通道 6 条 · 双向引用 8 处 · manifest 覆盖 7/6 |
| **A14** | ✅ | PubMed 返回结果（PMID=30575490） | 字段: PMID=true 标题=true 链接=true · 1497 字符 |
| **A15** | ⚠️ | 试验检索未返回登记号（需本地语料配置，见 get_source_status） | 前 150 字: {   "schemaVersion": "1.0",   "query": {     "keyword": "胰腺癌",     "limit": 5,     "offset": 0   },   "statuses": [     {       "sourceId": "chinadrug |
| **A32** | ✅ | request 模式可用（无需 Chromium） | 294 字符 |

---

## 复现命令

```bash
node tests/acceptance/e2e.mjs            # 全跑（含外网）
node tests/acceptance/e2e.mjs --offline  # 只跑不依赖外网的
node tests/acceptance/e2e.mjs --only=A14,A15
```
