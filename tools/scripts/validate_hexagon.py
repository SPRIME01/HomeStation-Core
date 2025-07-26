#!/usr/bin/env python3
"""Validate Python imports respect hexagonal boundaries.

This script walks Python files in the repository and ensures modules in
certain directories only import from allowed layers.  Domain code should not
depend on application or infrastructure, application should depend only on
domain, infrastructure may depend on domain, and API may depend on
application and infrastructure.  See `hexagon_plugin/tools/plugins/hexagon/scripts/validate-py-imports.py`
for more details.
"""

import ast
import os
import sys
from typing import List


# Define rules: allowed imports per layer
LAYER_RULES = {
    "domain": [],
    "application": ["domain"],
    "infrastructure": ["domain"],
    "api": ["application", "infrastructure"],
}


def find_layer(path: str) -> str | None:
    """Determine which hexagonal layer a file belongs to based on its path.

    We look for the substrings 'domain', 'application', 'infrastructure', or 'api' in the
    path components separated by os.sep.  This supports project names that combine
    context with layer using hyphens (e.g. 'catalog-domain') or underscores
    (e.g. 'catalog_domain').
    """
    parts = path.split(os.sep)
    for part in parts:
        if "domain" in part:
            return "domain"
        if "application" in part:
            return "application"
        if "infrastructure" in part:
            return "infrastructure"
        if "api" in part:
            return "api"
    return None


def extract_imports(file_path: str) -> List[str]:
    with open(file_path, "r", encoding="utf-8") as f:
        try:
            node = ast.parse(f.read(), filename=file_path)
        except SyntaxError:
            # Skip files with syntax errors (they will be caught by lint)
            return []
    modules: List[str] = []
    for n in ast.walk(node):
        if isinstance(n, ast.ImportFrom) and n.module:
            modules.append(n.module)
    return modules


def validate_file(file_path: str) -> List[str]:
    layer = find_layer(file_path)
    if not layer:
        return []
    violations: List[str] = []
    imports = extract_imports(file_path)
    for imp in imports:
        # Determine target layer by module name substring
        for target_layer in LAYER_RULES.keys():
            if f"_{target_layer}" in imp or f"-{target_layer}" in imp:
                allowed = LAYER_RULES[layer]
                if target_layer not in allowed and target_layer != layer:
                    violations.append(
                        f"{file_path} imports {imp} violating {layer} -> {target_layer}"
                    )
    return violations


def main(root: str) -> int:
    errors: List[str] = []
    for dirpath, _, files in os.walk(root):
        for file in files:
            if file.endswith(".py"):
                full = os.path.join(dirpath, file)
                errors.extend(validate_file(full))
    if errors:
        print("❌ Python import violations:")
        for err in errors:
            print("  " + err)
        return 1
    print("✅ Python imports respect hexagonal boundaries.")
    return 0


if __name__ == "__main__":
    # Default to scanning the libs directory if no argument is provided
    root_arg = sys.argv[1] if len(sys.argv) > 1 else "libs"
    sys.exit(main(root_arg))