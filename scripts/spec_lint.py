#!/usr/bin/env python3
"""
spec_lint.py — Lint and coverage checker for spec‑driven development.

This script verifies that:
  * Every acceptance criterion ID in requirements.md appears in design.md and tasks.md.
  * Every design ID referenced in tasks.md exists in design.md.
  * No design ID remains unused by any task (warns if there are orphans).
  * Generates a machine‑readable manifest summarising coverage and orphans.

It writes a JSON file `spec-manifest.json` with coverage information and prints a human‑readable summary.

Usage:
  python3 spec_lint.py

Exit codes:
  0 — Lint passed (full coverage)
  1 — Lint completed with warnings or errors
  2 — Missing files or other fatal error
"""

import re
import json
import sys
import pathlib

# Paths to the spec files (relative to the current working directory)
REQ_PATH = pathlib.Path("requirements.md")
DES_PATH = pathlib.Path("design.md")
TASK_PATH = pathlib.Path("tasks.md")
OUT_PATH = pathlib.Path("spec-manifest.json")

# Regular expressions to extract IDs
ID_REQ_CRIT = re.compile(r"(?m)^\s*-\s*(\d+\.\d+)\b")      # Lines like "- 1.1 …"
ID_REQ_ANY = re.compile(r"\b(\d+\.\d+)\b")                 # Any dotted ID
ID_DES_ANY = re.compile(r"\b(?:C\d+(?:\.(?:I|API|CFG|ERR)\d+)?)|DM\d+(?:\.F\d+)?|G\d+|ADR\d+\b")
ID_TASK_REQ = re.compile(r"\b(\d+\.\d+)\b")
ID_TASK_DES = ID_DES_ANY


def read(path: pathlib.Path) -> str:
    """Read a file, returning its contents as a string. Abort on failure."""
    try:
        return path.read_text(encoding="utf-8")
    except Exception as exc:
        print(f"[ERROR] Missing or unreadable file: {path}: {exc}")
        sys.exit(2)


def extract_requirement_criteria(req_text: str) -> list[str]:
    """Extract requirement criterion IDs from requirements.md."""
    ids = set(ID_REQ_CRIT.findall(req_text))
    if not ids:
        ids = set(ID_REQ_ANY.findall(req_text))
    return sorted(ids, key=lambda s: tuple(map(int, s.split("."))))


def extract_design_ids(des_text: str) -> list[str]:
    """Extract all design IDs from design.md."""
    return sorted(set(ID_DES_ANY.findall(des_text)))


def extract_tasks_refs(task_text: str) -> tuple[list[str], list[str]]:
    """Extract requirement and design references from tasks.md."""
    req_refs = sorted(set(ID_TASK_REQ.findall(task_text)), key=lambda s: tuple(map(int, s.split("."))))
    des_refs = sorted(set(ID_TASK_DES.findall(task_text)))
    return req_refs, des_refs


def main() -> int:
    req_text = read(REQ_PATH)
    des_text = read(DES_PATH)
    task_text = read(TASK_PATH)

    req_ids = extract_requirement_criteria(req_text)
    des_ids = extract_design_ids(des_text)
    task_req_ids, task_des_ids = extract_tasks_refs(task_text)

    # Determine coverage
    missing_in_design = [r for r in req_ids if r not in des_text]
    missing_in_tasks = [r for r in req_ids if r not in task_req_ids]
    unknown_design_in_tasks = [d for d in task_des_ids if d not in des_ids]
    orphan_design = [d for d in des_ids if d not in task_des_ids]

    manifest = {
        "requirements": [{"id": r} for r in req_ids],
        "coverage": {
            "requirements_in_design": sorted([r for r in req_ids if r not in missing_in_design]),
            "requirements_in_tasks": sorted([r for r in req_ids if r not in missing_in_tasks]),
        },
        "orphans": {
            "requirements_missing_in_design": missing_in_design,
            "requirements_missing_in_tasks": missing_in_tasks,
            "design_unused_by_tasks": orphan_design,
            "design_unknown_in_tasks": unknown_design_in_tasks,
        },
    }
    OUT_PATH.write_text(json.dumps(manifest, indent=2), encoding="utf-8")

    # Human‑readable summary
    print("=== Spec Lint Summary ===")
    print(f"Requirement criteria found: {len(req_ids)} → {req_ids[:8]}{' …' if len(req_ids) > 8 else ''}")
    print(f"Design IDs found:         : {len(des_ids)}")
    print(f"Task refs — req IDs      : {len(task_req_ids)}")
    print(f"Task refs — design IDs   : {len(task_des_ids)}")
    print()
    if missing_in_design:
        print("[FAIL] Criteria missing in design.md:", ", ".join(missing_in_design))
    if missing_in_tasks:
        print("[FAIL] Criteria missing in tasks.md:", ", ".join(missing_in_tasks))
    if unknown_design_in_tasks:
        print("[FAIL] Unknown design IDs referenced in tasks.md:", ", ".join(unknown_design_in_tasks))
    if orphan_design:
        print("[WARN] Design IDs not referenced by tasks.md:", ", ".join(orphan_design[:20]), "…" if len(orphan_design) > 20 else "")

    if not (missing_in_design or missing_in_tasks or unknown_design_in_tasks):
        print("[OK] Coverage looks good. See spec-manifest.json for details.")
        return 0
    else:
        print("\n[NOTE] See spec-manifest.json for a machine‑readable report.")
        return 1


if __name__ == "__main__":
    sys.exit(main())