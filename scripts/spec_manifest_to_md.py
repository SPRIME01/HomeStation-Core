#!/usr/bin/env python3
"""
spec_manifest_to_md.py — Render a spec‑manifest JSON file into a human‑readable
Markdown summary. This script is designed for use in CI to post coverage
reports to pull requests. It reads `spec-manifest.json`, computes coverage
percentages and lists missing or unknown IDs.

Usage:
  python3 spec_manifest_to_md.py > spec-coverage.md

It expects to run in a repository that contains a `spec-manifest.json` file
produced by the linter.
"""
import json
import pathlib
import sys

MANIFEST_PATH = pathlib.Path("spec-manifest.json")

if not MANIFEST_PATH.exists():
    print("> No spec-manifest.json found. Did the linter run?")
    sys.exit(0)

data = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))

reqs = [r["id"] for r in data.get("requirements", [])]
covered_in_design = set(data.get("coverage", {}).get("requirements_in_design", []))
covered_in_tasks = set(data.get("coverage", {}).get("requirements_in_tasks", []))

orph = data.get("orphans", {})
missing_in_design = orph.get("requirements_missing_in_design", [])
missing_in_tasks = orph.get("requirements_missing_in_tasks", [])
design_unused = orph.get("design_unused_by_tasks", [])
unknown_in_tasks = orph.get("design_unknown_in_tasks", [])

total = len(reqs)
pct_design = (len(covered_in_design) / total * 100.0) if total else 100.0
pct_tasks = (len(covered_in_tasks) / total * 100.0) if total else 100.0


def badge(label: str, pct: float) -> str:
    """Return a Markdown badge string based on percentage."""
    if pct == 100:
        color = "brightgreen"
    elif pct >= 80:
        color = "yellow"
    else:
        color = "orange"
    return f"![{label} {pct:.0f}%](https://img.shields.io/badge/{label}-{pct:.0f}%25-{color}.svg)"


print("| Metric | Status |")
print("|---:|:---|")
print(f"| Requirements → Design coverage | {badge('design', pct_design)} |")
print(f"| Requirements → Tasks coverage  | {badge('tasks', pct_tasks)}  |")
print()
if missing_in_design:
    print("**❌ Missing in design.md**")
    print("`" + "`, `".join(missing_in_design[:50]) + "`" + (" …" if len(missing_in_design) > 50 else ""))
    print()
if missing_in_tasks:
    print("**❌ Missing in tasks.md**")
    print("`" + "`, `".join(missing_in_tasks[:50]) + "`" + (" …" if len(missing_in_tasks) > 50 else ""))
    print()
if unknown_in_tasks:
    print("**❌ Unknown design IDs referenced in tasks.md**")
    print("`" + "`, `".join(unknown_in_tasks[:50]) + "`" + (" …" if len(unknown_in_tasks) > 50 else ""))
    print()
if design_unused:
    print("**⚠️ Design IDs not referenced by tasks.md**")
    print("`" + "`, `".join(design_unused[:50]) + "`" + (" …" if len(design_unused) > 50 else ""))
    print()
if not (missing_in_design or missing_in_tasks or unknown_in_tasks):
    print("✅ All requirement criteria are mapped in `design.md` and referenced in `tasks.md`.")