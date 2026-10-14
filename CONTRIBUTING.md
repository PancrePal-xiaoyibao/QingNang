# 贡献指南（CONTRIBUTING）

> **提交前请先读完本文。** 青囊服务的是癌症病友，**一条真实患者信息进仓库就是事故**。

---

## 0. 三类贡献，都能进

| 类型 | 例子 | 门槛 |
|---|---|---|
| **知识卡** | 病种知识、指标解读、术语对照、医患沟通话术 | 低（**最需要**） |
| **能力** | 新的 MCP 通道、skill | 中（须过合并契约） |
| **稿件** | 文档、README 改进、故障排查补充 | 低 |

**不写代码也能贡献。** 病种知识卡、术语翻译、FAQ 整理，价值不低于代码。

---

## 1. 绝对红线（违反不予合并）

| ❌ 禁止提交 | 包括 |
|---|---|
| **真实患者数据** | 姓名、身份证号、手机号、住院号/门诊号、病历号、影像编号 |
| **报告单原件** | PDF、照片、截图、扫描件 |
| **可反推身份的** | 罕见病 + 具体日期 + 具体医院的组合 |
| **真实对话记录** | 病友群聊天截图、私信内容 |
| **他人隐私** | 未经同意的家属 / 医生姓名与联系方式 |
| **凭据** | API Key、Token、私钥（放 `.env`，已在 `.gitignore`） |

**演示数据一律走 `data/synthetic/`** —— 由造数脚本生成，全虚构。

---

## 2. 三道自动闸门

| 闸 | 时机 | 检查 |
|---|---|---|
| **1. pre-commit** | 你本地提交前 | `gitleaks`（凭据）+ `scripts/phi_scan.mjs`（中文 PHI/PII）+ 清单/体积/隐私自检 |
| **2. CI** | PR 推送后 | 同套规则跑全量 diff；命中即红 |
| **3. AI 复审** | PR 触发 | 专查「看似脱敏实可反推」的组合；结论挂 label，人工复核 |

**启用本地闸门**（强烈建议）：

```bash
pip install pre-commit
pre-commit install
pre-commit run --all-files    # 手动全量跑一次
```

**命中闸门怎么办**：

- 确实是真实数据 → **删除该文件/该行**，不得提交
- 是误报 → 加 `# phi-scan: ignore` 行内豁免，**并在 PR 说明理由**
- 不确定 → **按敏感处理**，先删再说

---

## 3. 新增能力（MCP / skill）的流程

**必须先读 [`skills/qingnang/MERGE_CONTRACT.md`](skills/qingnang/MERGE_CONTRACT.md)。** 简版：

### 3.1 准入四条（全过才进）

1. **医学相关吗？** 与病友的信息获取、病历处理、指标追踪、心理支持相关 → 考虑
2. **是能力还是应用？** skill / MCP 是能力（进）；完整应用 / 机器人 / 小程序 → 不进，只借鉴
3. **许可干净吗？** `MIT` / `Apache-2.0` / `ISC` / `MIT-0` / `BSD-3` 可进；`NONE` → 放 `reserved` 等补；`AGPL` / 禁商用 → 不进主包
4. **能被 Agent 调用吗？** 有 `SKILL.md` 或 MCP 包 → 进；散脚本无入口 → 先改造

### 3.2 耦合三件事（缺一不可）

- 每个 skill 的 `SKILL.md` **必须**声明：① 依赖哪些 MCP（写 `server_name`）② 什么时候调 ③ 结果怎么用
- 每条 `SEARCH_RUNTIME.md` 通道**必须**写明：哪个 skill 会用、解决什么问题

> **反例**：MCP 装了但没任何 skill 说要用；skill 写「去搜索」但不说搜哪个通道。

### 3.3 新增 MCP 通道的三步

1. `mcp-servers/manifest.json` 的 `servers` 加条目（**钉死版本** + 许可在白名单 + 凭据可降级）
2. `skills/qingnang/SEARCH_RUNTIME.md` 加一节
3. `skills/qingnang/SKILL.md` 加对应分支并指回通道编号

**许可未清的放 `reserved` 段**，不要混进 `servers`。

---

## 4. 新增知识卡

每张卡**必须**带 frontmatter：

```yaml
---
title: <标题>
source: <来源 URL / 文献标识>
reviewed_by: <审校人 或 pending-review>
updated_at: YYYY-MM-DD
---
```

**硬约束**：

1. **未审校必须显式写 `pending-review`**，正文也要声明「本卡未经医学审校」。**不假装已审**。
2. **只做要点摘录 + 官方链接**，**不做原创医学结论**。
3. **指南全文有版权** → 只摘要点 + 给官方链接，**绝不整篇转载**。
4. **不做诊断判断、不给剂量**（见 `AGENTS.md` §2 医学五条）。

---

## 5. 提交规范

### 5.1 提交前自检

```bash
node scripts/qingnang.mjs check          # 26 项自检（清单 / 体积 / 隐私 / 治理一致性）
node scripts/qingnang.mjs doctor         # 逐通道体检，应无 ❌
cmp AGENTS.md CLAUDE.md        # 若改过治理文档，两个必须逐字一致
```

### 5.2 Git 纪律

- ❌ **禁止 `git add .` / `git add -A`** —— 必须**显式列每个文件**
- 一个逻辑单元一个 commit，message 说清干了什么
- **不要**提交构建产物：`node_modules/`、`.venv/`、`mcp-servers/launch/`、`skills/qingnang/HOST_PROFILE.md`、`cache/`（都已在 `.gitignore`）

### 5.3 commit message 风格

```
<类型>(<范围>): <做了什么>

类型： feat / fix / docs / chore
范围： skill / mcp / docs / scripts

例：
  feat(mcp): 新增 XXX 通道 + SEARCH_RUNTIME 分流说明
  docs(skill): 补充 CA19-9 指标解读卡（pending-review）
  fix(scripts): 修正 doctor 内存显示单位重复
```

---

## 6. PR 检查清单

PR 模板会自动带上，逐项勾选：

- [ ] 不含任何真实患者信息
- [ ] 知识卡有 `source` + `reviewed_by`
- [ ] 未整篇转载受版权保护的指南
- [ ] 新增 MCP 许可在白名单内且钉死版本
- [ ] 通过合并契约的准入四条
- [ ] 耦合三件事齐备 + `SEARCH_RUNTIME.md` 双向引用已更新
- [ ] `node scripts/qingnang.mjs check` 通过

---

## 7. 遇到问题

| 情况 | 去哪 |
|---|---|
| 不确定某条内容算不算敏感 | **按敏感处理**，先删；在 PR 里问 |
| 不确定某能力能否进包 | 读 `MERGE_CONTRACT.md` 准入四条；仍不确定就在 issue 里问 |
| 部署/运行报错 | README「故障排查」一节；`doctor.sh` 会给中文修复指引 |
| 医学内容准确性 | **找社区医学志愿者审校**，不要自行判断 |

---

**青囊的定位**：小胰宝社区 · 医学能力资产包。社区**只负责技术分发**，提供工具与公开信息检索能力，**不承担诊疗责任、不做医疗背书**。
