#!/usr/bin/env python3
"""Generate domain code stubs from YAML specifications.

This script parses domain.yaml files located in your domain libraries and
emits Python files for aggregates, ports and use cases.  See the top-level
README for details on the expected YAML format.
"""
import os
import sys
import yaml
from pathlib import Path

def generate_from_yaml(yaml_path: Path) -> None:
    with open(yaml_path, "r", encoding="utf-8") as f:
        spec = yaml.safe_load(f)
    root = yaml_path.parent
    aggregates = spec.get("aggregates", {}) or {}
    agg_dir = root / "src" / "aggregates"
    agg_dir.mkdir(parents=True, exist_ok=True)
    for name, definition in aggregates.items():
        class_name = "".join(part.capitalize() for part in name.split("_"))
        fields = definition.get("fields", {}) or {}
        lines = ["from dataclasses import dataclass", "", "@dataclass", f"class {class_name}:"]  # header
        if fields:
            for fname, ftype in fields.items():
                lines.append(f"    {fname}: {ftype}")
        else:
            lines.append("    pass")
        (agg_dir / f"{name}.py").write_text("\n".join(lines) + "\n", encoding="utf-8")
    ports = spec.get("ports", {}) or {}
    ports_dir = root / "src" / "ports"
    ports_dir.mkdir(parents=True, exist_ok=True)
    for name, definition in ports.items():
        class_name = "".join(part.capitalize() for part in name.split("_"))
        methods = definition.get("methods", {}) or {}
        lines = [f"class {class_name}:"]  # header
        if methods:
            for m in methods:
                lines.append(f"    def {m}(self) -> None:\n        raise NotImplementedError()")
        else:
            lines.append("    pass")
        (ports_dir / f"{name}.py").write_text("\n".join(lines) + "\n", encoding="utf-8")
    # generate simple use-case stubs in application package if present
    app_path = root.parent.parent / f"{root.name.replace('-domain', '')}-application" / "src" / "use_cases"
    if app_path.is_dir() or not app_path.exists():
        app_path.mkdir(parents=True, exist_ok=True)
        for agg_name in aggregates.keys():
            use_case_file = app_path / f"{agg_name}_use_case.py"
            if not use_case_file.exists():
                use_case_file.write_text(
                    f'"""Use case for {agg_name}."""\n\n'
                    f'def execute() -> None:\n'
                    f'    # TODO: implement use case for {agg_name}\n'
                    f'    pass\n',
                    encoding='utf-8'
                )

def main() -> None:
    if len(sys.argv) > 1:
        for arg in sys.argv[1:]:
            p = Path(arg)
            if p.exists():
                generate_from_yaml(p)
    else:
        # Find all domain.yaml files in libs/*-domain directories
        for yaml_file in Path.cwd().glob("libs/*-domain/domain.yaml"):
            generate_from_yaml(yaml_file)

if __name__ == "__main__":
    main()
