## 这个 PR 做了什么

<!-- 一句话说清 -->

## 类型

- [ ] 新增能力（MCP 通道 / skill）
- [ ] 新增知识卡（病种 / 术语 / 话术）
- [ ] 修复
- [ ] 文档
- [ ] 其他

---

## ⚠️ 伦理与合规（必须逐项确认）

- [ ] **本 PR 不含任何真实患者信息**
      （姓名 / 身份证号 / 手机号 / 住院号 / 报告单原件 / 可反推身份的组合）
- [ ] 若含知识卡：每张卡都有 `source` 与 `reviewed_by` frontmatter
      （未审校的显式写了 `pending-review` + 正文声明）
- [ ] 若含知识卡：**只做要点摘录 + 官方链接**，**未整篇转载受版权保护的指南**
- [ ] 若新增 MCP：许可在 `manifest.json` 的白名单内，且**钉死了版本**
- [ ] 若新增能力：通过了合并契约的**准入四条**（见 `skills/qingnang/MERGE_CONTRACT.md`）
- [ ] 若新增能力：**耦合三件事齐备**（依赖哪个 MCP / 何时调 / 结果怎么用），
      且 `SEARCH_RUNTIME.md` 的双向引用已更新

---

## 自检

- [ ] `bash scripts/check.sh` 通过
- [ ] `bash scripts/doctor.sh` 无 `❌`
- [ ] `cmp AGENTS.md CLAUDE.md` 通过（若改过治理文档）

## 备注

<!-- 有需要 review 者特别注意的地方吗？ -->
