# NCCN 癌种清单与指南检索

> **来源**：改进后并入自社区 skill `opencare-skillhub/nccn-guideline-downloader`（Apache-2.0）的 `references/cancer_types.md`。
> **改动**：保留癌种清单（检索用的关键词表）；**移除**了自动下载脚本与 Cookie 配置细节（涉及登录态，属运营工具）；补充青囊的**版权硬约束**。
> **许可**：Apache-2.0，见 `references/SOURCES.md`。

---

## ⚠️ 版权硬约束（最重要，先读这条）

| 项 | 允许 | 不允许 |
|---|---|---|
| **NCCN 指南全文** | ❌ 不可再分发 | — |
| **指南要点摘录** | ✅ 可以做 | — |
| **官方链接** | ✅ 必须给 | — |
| **患者版手册链接** | ✅ 可以给（官方免费渠道） | — |

**NCCN 指南受版权保护。工具开源 ≠ 内容可再分发。**

**Agent 的硬约束**：
- 引用 NCCN 时**只做要点摘录 + 给官方链接**
- **绝不**输出指南全文、整章、整表
- 用户要全文 → 给官方获取路径（`nccn.org` 免费注册后可下载）

---

## 癌种清单（检索关键词表）

用途：帮 Agent 把癌种名认全，**检索时用对 key**。

### 快速索引（常用癌种）

| 中文 | 英文关键词 | 癌种 Key |
|---|---|---|
| 乳腺癌 | breast, breast cancer | `breast_cancer` |
| 肺癌 | lung, nsclc, sclc | `non_small_cell_lung_cancer`, `small_cell_lung_cancer` |
| **胰腺癌** | **pancreatic, pancreas** | **`pancreatic_adenocarcinoma`** |
| 结肠癌 | colon | `colon_cancer` |
| 直肠癌 | rectal, rectum | `rectal_cancer` |
| 胃癌 | gastric, stomach | `gastric_cancer` |
| 肝癌 | hcc, liver, hepatocellular | `hepatocellular_carcinoma` |
| 前列腺癌 | prostate | `prostate_cancer` |
| 卵巢癌 | ovarian | `ovarian_cancer` |
| 甲状腺癌 | thyroid | `thyroid_carcinoma` |
| 宫颈癌 | cervical | `cervical_cancer` |
| 肾癌 | kidney, renal | `kidney_cancer` |
| 膀胱癌 | bladder | `bladder_cancer` |
| 黑色素瘤 | melanoma | `melanoma_cutaneous` |
| 多发性骨髓瘤 | myeloma | `multiple_myeloma` |

### 全部癌种（完整清单）

| # | 中文 | Key |
|---|---|---|
| 1 | 急性淋巴细胞白血病 (ALL) | `acute_lymphoblastic_leukemia` |
| 2 | 急性髓系白血病 (AML) | `acute_myeloid_leukemia` |
| 3 | 壶腹腺癌 | `ampullary_adenocarcinoma` |
| 4 | 肛门癌 | `anal_carcinoma` |
| 5 | 阑尾肿瘤 | `appendiceal_neoplasms` |
| 6 | 基底细胞皮肤癌 | `basal_cell_skin_cancer` |
| 7 | B细胞淋巴瘤 | `b_cell_lymphomas` |
| 8 | 胆道癌 | `biliary_tract_cancers` |
| 9 | 膀胱癌 | `bladder_cancer` |
| 10 | 骨癌 | `bone_cancer` |
| 11 | 乳腺癌 | `breast_cancer` |
| 12 | 卡斯尔曼病 | `castleman_disease` |
| 13 | 中枢神经系统肿瘤 | `central_nervous_system_cancers` |
| 14 | 宫颈癌 | `cervical_cancer` |
| 15 | 慢性淋巴细胞白血病 (CLL/SLL) | `chronic_lymphocytic_leukemia` |
| 16 | 慢性髓系白血病 (CML) | `chronic_myeloid_leukemia` |
| 17 | 结肠癌 | `colon_cancer` |
| 18 | 皮肤淋巴瘤 | `cutaneous_lymphomas` |
| 19 | 隆突性皮肤纤维肉瘤 | `dermatofibrosarcoma_protuberans` |
| 20 | 食管癌/食管胃结合部癌 | `esophageal_cancers` |
| 21 | 胃癌 | `gastric_cancer` |
| 22 | 胃肠道间质瘤 (GIST) | `gastrointestinal_stromal_tumors` |
| 23 | 妊娠滋养细胞肿瘤 | `gestational_trophoblastic_neoplasia` |
| 24 | 毛细胞白血病 | `hairy_cell_leukemia` |
| 25 | 头颈癌 | `head_and_neck_cancers` |
| 26 | 肝胆癌 | `hepatobiliary_cancers` |
| 27 | 肝细胞癌 (HCC) | `hepatocellular_carcinoma` |
| 28 | 组织细胞肿瘤 | `histiocytic_neoplasms` |
| 29 | 霍奇金淋巴瘤 | `hodgkin_lymphoma` |
| 30 | 卡波西肉瘤 | `kaposi_sarcoma` |
| 31 | 肾癌 | `kidney_cancer` |
| 32 | 皮肤黑色素瘤 | `melanoma_cutaneous` |
| 33 | 葡萄膜黑色素瘤 | `melanoma_uveal` |
| 34 | 默克尔细胞癌 | `merkel_cell_carcinoma` |
| 35 | 腹膜间皮瘤 | `mesothelioma_peritoneal` |
| 36 | 胸膜间皮瘤 | `mesothelioma_pleural` |
| 37 | 多发性骨髓瘤 | `multiple_myeloma` |
| 38 | 骨髓增生异常综合征 (MDS) | `myelodysplastic_syndromes` |
| 39 | 骨髓增殖性肿瘤 (MPN) | `myeloproliferative_neoplasms` |
| 40 | 神经母细胞瘤 | `neuroblastoma` |
| 41 | 神经内分泌和肾上腺肿瘤 | `neuroendocrine_adrenal_tumors` |
| 42 | 非小细胞肺癌 (NSCLC) | `non_small_cell_lung_cancer` |
| 43 | 隐匿性原发癌 | `occult_primary` |
| 44 | 卵巢癌/输卵管癌/腹膜癌 | `ovarian_cancer` |
| 45 | **胰腺腺癌** | **`pancreatic_adenocarcinoma`** |
| 46 | 儿童急性淋巴细胞白血病 | `pediatric_all` |
| 47 | 儿童侵袭性成熟B细胞淋巴瘤 | `pediatric_b_cell_lymphoma` |
| 48 | 儿童中枢神经系统肿瘤 | `pediatric_cns` |
| 49 | 儿童霍奇金淋巴瘤 | `pediatric_hodgkin` |
| 50 | 儿童软组织肉瘤 | `pediatric_soft_tissue_sarcoma` |
| 51 | 阴茎癌 | `penile_cancer` |
| 52 | 前列腺癌 | `prostate_cancer` |
| 53 | 直肠癌 | `rectal_cancer` |
| 54 | 小肠腺癌 | `small_bowel_adenocarcinoma` |
| 55 | 小细胞肺癌 (SCLC) | `small_cell_lung_cancer` |
| 56 | 软组织肉瘤 | `soft_tissue_sarcoma` |
| 57 | 鳞状细胞皮肤癌 | `squamous_cell_skin_cancer` |
| 58 | 系统性轻链淀粉样变性 | `systemic_light_chain_amyloidosis` |
| 59 | 系统性肥大细胞增多症 | `systemic_mastocytosis` |
| 60 | T细胞淋巴瘤 | `t_cell_lymphomas` |
| 61 | 睾丸癌 | `testicular_cancer` |
| 62 | 胸腺瘤和胸腺癌 | `thymomas_thymic` |
| 63 | 甲状腺癌 | `thyroid_carcinoma` |
| 64 | 子宫肿瘤/子宫内膜癌 | `uterine_neoplasms` |
| 65 | 阴道癌 | `vaginal_cancer` |
| 66 | 外阴癌 | `vulvar_cancer` |
| 67 | 华氏巨球蛋白血症 | `waldenstrom_macroglobulinemia` |
| 68 | 肾母细胞瘤 (Wilms) | `wilms_tumor` |

---

## 怎么拿到 NCCN 指南

**官方路径（唯一合规路径）**：

1. 注册 `nccn.org` 账号（免费）
2. 登录后下载对应癌种指南（PDF）
3. **患者版手册**（NCCN Guidelines for Patients）官网免费，中文版部分癌种有

**Agent 应该做什么**：

| 用户问 | Agent 答 |
|---|---|
| 「NCCN 胰腺癌指南怎么说的」 | 给出**要点摘录**（来自公开综述或社区知识卡）+ 官方链接 |
| 「帮我下载 NCCN 指南全文」 | 给官方注册路径，**不代为下载、不代为分发** |
| 「有没有患者版」 | 给 NCCN 官网患者手册链接 |

---

## 参考

| 项 | 位置 |
|---|---|
| 检索通道 | `SEARCH_RUNTIME.md` 通道 3（文献） |
| 报告提纲 | `references/trials/report-outline.md` |
| 来源与许可 | `references/SOURCES.md` |
MD