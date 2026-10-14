#!/usr/bin/env python3
"""青囊 · 中文 PHI/PII 扫描（敏感信息第一道闸）

用途：在 commit 前拦截「真实患者信息」与「凭据」进入仓库。
覆盖：身份证号、手机号、住院号/门诊号、姓名+诊断组合、报告单图片 EXIF、API Key。

设计取舍：
  · 宁可误报不可漏报 —— 医疗场景下漏一个真实患者信息的代价远大于多改一次
  · 每类命中都给出「为什么这算敏感 + 怎么改」的中文说明
  · 行级豁免： # phi-scan: ignore   （必须在 PR 里说明理由）

退出码：0 干净；1 有命中
用法： phi_scan.py [--staged] [路径...]
"""
from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys

# ── 扫描范围 ────────────────────────────────────────────────────
SCAN_EXT = {".md", ".txt", ".json", ".yaml", ".yml", ".csv", ".sh", ".py", ".js", ".ts", ".env", ".example"}
SKIP_DIRS = {".git", "node_modules", ".venv", "venv", "__pycache__", ".pytest_cache", ".ruff_cache"}
# 这些文件天然含示例/占位，跳过（但仍扫凭据类规则）
PLACEHOLDER_FILES = {".env.example"}

IGNORE_RE = re.compile(r"#\s*phi-scan:\s*ignore", re.I)

# ── 规则：(名称, 正则, 说明) ─────────────────────────────────────
RULES: list[tuple[str, re.Pattern, str]] = [
    ("身份证号",
     re.compile(r"(?<!\d)[1-9]\d{5}(?:19|20)\d{2}(?:0[1-9]|1[0-2])(?:0[1-9]|[12]\d|3[01])\d{3}[\dXx](?!\d)"),
     "中国大陆居民身份证号（18 位）。请删除；若为演示数据，用 data/synthetic/ 造数脚本生成。"),

    ("手机号",
     re.compile(r"(?<!\d)1[3-9]\d{9}(?!\d)"),
     "手机号。请删除或改为 138****0000 形式；演示数据走 data/synthetic/。"),

    ("住院号/门诊号/病历号",
     # 要求「编号主体含至少 4 位连续数字」——真实单据号必然含数字；
     # 这样可避免误伤文档里的描述性文字（如「住院号 fixture」「住院号字段」）
     re.compile(r"(住院号|门诊号|病历号|就诊号|病案号)\s*[:：]?\s*[A-Za-z\-]{0,6}\d{4,}[A-Za-z0-9\-]*"),
     "医疗单据编号。真实编号可反查到具体患者与就诊记录，必须删除。"),

    ("姓名+诊断组合",
     re.compile(r"(患者|病人|姓名)\s*[:：]?\s*[\u4e00-\u9fa5]{2,4}\s*[,，、\s]\s*(诊断|分期|病理)"),
     "姓名与诊断同时出现 = 可识别到个人。医疗信息属敏感个人信息（PIPL），必须删除。"),

    ("疑似住院时间+医院组合",
     re.compile(r"(?:\d{4}年\d{1,2}月|\d{4}-\d{2})[^\n]{0,20}(住院|入院|手术)[^\n]{0,30}(医院|医学中心|附属)"),
     "时间 + 就诊行为 + 机构 = 三件套，可反推个人。请改为脱敏描述。"),

    ("API Key / Token / Secret",
     re.compile(r"(api[_-]?key|secret|token|passwd|password)\s*[:=]\s*['\"]?[A-Za-z0-9_\-]{16,}"),
     "疑似凭据。凭据必须放 .env（已在 .gitignore 中），仓库内只允许 .env.example 里的空占位。"),

    ("私钥",
     re.compile(r"-----BEGIN [A-Z ]*PRIVATE KEY-----"),
     "私钥文件内容。绝不可入库，立即删除并轮换该密钥。"),

    ("中国大陆银行卡号",
     re.compile(r"(?<!\d)(62\d{14,17})(?!\d)"),
     "银行卡号。属敏感财务信息，必须删除。"),
]

# ── 图片 EXIF（报告单照片常带拍摄地点/设备信息）────────────────
IMG_EXT = {".jpg", ".jpeg", ".png", ".tif", ".tiff", ".heic", ".webp"}
EXIF_HINT = re.compile(rb"(GPS|Make|Model|Software|DateTime)", re.I)


def iter_files(paths: list[str], staged: bool):
    if staged:
        out = subprocess.run(["git", "diff", "--cached", "--name-only", "--diff-filter=ACMR"],
                             capture_output=True, text=True).stdout
        for p in out.splitlines():
            p = p.strip()
            if p and os.path.isfile(p):
                yield p
        return
    for path in paths:
        if os.path.isfile(path):
            yield path
            continue
        for root, dirs, files in os.walk(path):
            dirs[:] = [d for d in dirs if d not in SKIP_DIRS]
            for fn in files:
                yield os.path.join(root, fn)


def scan_file(path: str) -> list[tuple[int, str, str, str]]:
    """返回 [(行号, 规则名, 命中片段, 说明)]"""
    hits = []
    ext = os.path.splitext(path)[1].lower()

    # 图片：查 EXIF
    if ext in IMG_EXT:
        try:
            with open(path, "rb") as f:
                head = f.read(65536)
            if EXIF_HINT.search(head):
                hits.append((0, "图片 EXIF",
                             os.path.basename(path),
                             "图片含 EXIF 元数据（可能含 GPS/设备/时间）。报告单照片请先剥离元数据再提交。"))
        except Exception:
            pass
        return hits

    if ext not in SCAN_EXT and ext != "":
        return hits

    try:
        with open(path, encoding="utf-8", errors="ignore") as f:
            lines = f.readlines()
    except Exception:
        return hits

    is_placeholder_file = os.path.basename(path) in PLACEHOLDER_FILES
    for i, line in enumerate(lines, 1):
        if IGNORE_RE.search(line):
            continue
        for name, rx, why in RULES:
            # .env.example 里允许出现 KEY 名的空占位（= 后面无值）
            if is_placeholder_file and name == "API Key / Token / Secret":
                continue
            m = rx.search(line)
            if m:
                hits.append((i, name, m.group(0)[:80], why))
    return hits


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--staged", action="store_true", help="只扫暂存区文件（pre-commit 用）")
    ap.add_argument("paths", nargs="*", default=["."])
    a = ap.parse_args()

    total = 0
    files_with_hits = 0
    for path in sorted(set(iter_files(a.paths or ["."], a.staged))):
        hits = scan_file(path)
        if not hits:
            continue
        files_with_hits += 1
        print("\n\033[31m✗ %s\033[0m" % path)
        for ln, name, frag, why in hits:
            total += 1
            loc = ("第 %d 行" % ln) if ln else "文件级"
            print("  %s · %s" % (loc, name))
            print("    命中: %s" % frag)
            print("    为什么: %s" % why)
            print("    怎么改: 删除该内容；若为误报，加 `# phi-scan: ignore` 并在 PR 说明理由")

    print("")
    if total:
        print("\033[31m拦截：发现 %d 处疑似敏感信息（%d 个文件）。\033[0m" % (total, files_with_hits))
        print("医疗信息属敏感个人信息（PIPL）。请按上方提示修改后再提交。")
        return 1
    print("\033[32m✓ 未发现敏感信息。\033[0m")
    return 0


if __name__ == "__main__":
    sys.exit(main())
