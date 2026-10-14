# 胰腺癌相关靶点速查

> **来源**：整理自社区资产（`clinicaltrials-query-analysis` 的已生成专题报告靶点清单，Apache-2.0）+ 公开文献常用写法。
> **定位**：**检索用的关键词表**，不是治疗指导。本卡只帮 Agent 把靶点名字认全，避免漏检试验。

---

## 为什么需要这张卡

临床试验检索最常见的失败模式是**漏检**：患者/家属只知道「靶点 A」，而这个靶点在登记平台上有 3 种写法。少写一种就漏一批试验。

**用法**：检索时把所有别名**并行发出**，而不是只发一个。

---

## 胰腺癌核心靶点

| 靶点 | 别名 / 常见写法 | 说明（仅名词解释） |
|---|---|---|
| **KRAS** | KRAS G12C / G12D / G12V / G12R / pan-KRAS / RAS(ON) / RASi | 胰腺癌最高频突变基因；不同突变位点的药物不通用 |
| **CLDN18.2** | Claudin 18.2 / CLDN18.2 / Zolbetuximab 类 | 紧密连接蛋白，部分胰腺癌与胃癌表达 |
| **B7-H3** | CD276 / B7H3 | 免疫检查点家族成员 |
| **HER2** | ERBB2 / HER-2 / HER2-low | 乳腺癌/胃癌常规靶点，胰腺癌中占比较低 |
| **NTRK** | NTRK1 / NTRK2 / NTRK3 / TRK fusion / 神经营养受体酪氨酸激酶 | 泛癌种罕见融合，有跨癌种药物 |
| **BRCA** | BRCA1 / BRCA2 / HRD / 同源重组修复缺陷 | 与 PARP 抑制剂相关 |
| **MSI-H / dMMR** | microsatellite instability-high / mismatch repair deficient | 泛癌种免疫治疗标志 |
| **TMB-H** | tumor mutational burden-high | 肿瘤突变负荷 |
| **FGFR** | FGFR2 / FGFR2b / FGFR fusion | 部分消化道肿瘤 |
| **DLL3** | DLL3 | 神经内分泌方向 |
| **MUC1** | MUC-1 / 黏蛋白1 | 胰腺癌高表达 |
| **Mesothelin** | MSLN | 胰腺癌 CAR-T 方向常见靶点 |
| **Trop-2** | TROP2 / TACSTD2 | ADC 方向 |
| **CEACAM5** | CEA / CD66e | 消化道肿瘤 |

---

## 治疗类型关键词

| 类型 | 英文关键词 |
|---|---|
| 化疗 | chemotherapy, FOLFIRINOX, Gemcitabine, nab-Paclitaxel |
| 靶向 | targeted therapy, TKI, monoclonal antibody |
| 免疫 | immunotherapy, PD-1, PD-L1, CTLA-4, checkpoint inhibitor |
| ADC | antibody-drug conjugate |
| CAR-T | CAR-T, chimeric antigen receptor |
| 细胞治疗 | cell therapy, TCR-T, TIL |
| 双抗 | bispecific antibody, bispecific |
| 疫苗 | vaccine, neoantigen vaccine |
| 溶瘤病毒 | oncolytic virus |
| 放射性核素 | radioligand, RLT, PRRT |

---

## 阶段关键词

| 平台写法 | 含义 |
|---|---|
| Early Phase 1 / Phase 1 | 早期安全性 |
| Phase 1/2 | 安全性 + 初步疗效 |
| Phase 2 | 疗效探索 |
| Phase 2/3 | — |
| Phase 3 | 确证性 |
| Phase 4 | 上市后 |
| Not Applicable | 不适用（如部分器械/观察性研究） |

---

## 状态关键词（**必须带采集时间**）

| 平台写法 | 中文 | 对患者的含义 |
|---|---|---|
| Recruiting | 招募中 | 可咨询 |
| Not yet recruiting | 尚未开始 | 关注 |
| Active, not recruiting | 进行中但不招募 | 不可入组 |
| Enrolling by invitation | 邀请制入组 | 通常不可自主报名 |
| Completed | 已完成 | 不可入组 |
| Terminated | 已终止 | — |
| Withdrawn | 已撤回 | — |
| Suspended | 暂停 | — |
| Unknown status | 状态不明 | 需核实 |

> ⚠️ **状态变化快**。「正在招募」这个结论**只在采集时刻有效**。引用时必须带 `截至 YYYY-MM-DD`。

---

## 给 Agent 的使用提示

1. **别名要发全**：用户说「KRAS」，你要发 `KRAS G12C, KRAS G12D, KRAS G12V, pan-KRAS, RAS(ON)`。
2. **靶点不等于治疗**：本卡只做名词对照。用户问「KRAS G12D 有没有药」→ 检索后如实汇报进展，**不做「你能不能用」的判断**（触发红线 M1）。
3. **不要自行扩展靶点**：只在用户提到或文献明确相关的范围内检索。不要「顺便」查一堆无关靶点。
