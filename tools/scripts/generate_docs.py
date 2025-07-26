#!/usr/bin/env python3
"""Generate simple project documentation.

This script demonstrates how you might automate documentation generation for
your project.  It currently prints a basic README based on the available
contexts and layers.  You can extend it to produce Markdown, OpenAPI
specifications, Sphinx documentation or any other artefacts required by
your workflow.
"""
from pathlib import Path
import json


def list_contexts(libs_path: Path) -> list[str]:
    contexts: list[str] = []
    for child in libs_path.iterdir():
        if child.is_dir() and "-" in child.name:
            context, _layer = child.name.split("-", 1)
            if context not in contexts:
                contexts.append(context)
    return contexts


def main() -> None:
    root = Path(__file__).resolve().parents[2]
    libs_path = root / "libs"
    contexts = list_contexts(libs_path)
    docs = {
        "project": root.name,
        "contexts": contexts,
        "description": (
            "This project was generated from the cookiecutter‑nx‑hexagon template.\n"
            "Each context is split into domain, application and infrastructure layers."
        ),
    }
    output = root / "PROJECT_DOCS.json"
    output.write_text(json.dumps(docs, indent=2))
    print(f"Generated documentation at {output}")


if __name__ == "__main__":
    main()