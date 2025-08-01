# Spec‑Driven Development Framework

This package contains a **spec‑driven development framework** that you can drop into your projects to create, maintain and enforce high‑quality specifications. It was inspired by reverse‑engineering [Kiro](https://kiro.dev/) and distilled into a set of prompts, templates, scripts and workflows. The framework helps you generate and maintain three core documents—`requirements.md`, `design.md` and `tasks.md`—with stable identifiers and full traceability.

## Overview

Spec‑driven development begins by capturing clear, numbered requirements with atomic, testable acceptance criteria. Those requirements drive a numbered design, which in turn drives a detailed implementation plan. A linter ensures nothing falls through the cracks, and a GitHub Action enforces coverage in CI. Additional steering documents (product, tech and structure) guide agents and developers in day‑to‑day decisions.

The key parts of this package are:

- **Prompts** — system prompts you feed into your AI assistant to generate `requirements.md`, `design.md`, `tasks.md` and steering documents with the proper numbering schemes and formats.
- **Orchestrator prompt** — `prompts/orchestrator_prompt.md` describes how to drive the entire workflow (new projects and features) including checking routing, creating steering docs, generating specs, executing tasks and versioning.
- **Templates** — ready‑to‑fill versions of steering documents (`product.md`, `tech.md`, `structure.md`) that you store in `.github/instructions/` to guide developers and coding agents.
- **Copilot router template** — a `copilot-instructions.md` template that routes GitHub Copilot to your steering documents and prioritises product, security, engineering, structure and spec files.
- **Scripts** — a linter (`spec_lint.py`) and a renderer (`spec_manifest_to_md.py`) that check coverage and produce a Markdown report for pull requests.
- **CI workflow** — a GitHub Actions workflow (`spec-lint.yml`) that runs the linter on pull requests, uploads a manifest and posts a coverage summary as a PR comment.
- **Documentation** — this README and extensive comments in the prompts and templates to help you apply the framework effectively.

## Directory Layout

```
spec_driven_framework/
├─ prompts/             # System prompts for generating docs and steering files
│  ├─ requirements_prompt.md
│  ├─ design_prompt.md
│  ├─ tasks_prompt.md
│  ├─ spec_pack_orchestrator.md
│  ├─ product_prompt.md
│  ├─ tech_prompt.md
│  ├─ structure_prompt.md
│  └─ orchestrator_prompt.md
├─ templates/           # Ready‑to‑fill steering documents
│  ├─ product.md
│  ├─ tech.md
│  ├─ structure.md
│  └─ copilot-instructions.md
├─ scripts/
│  ├─ spec_lint.py      # Lints coverage between requirements, design and tasks
│  └─ spec_manifest_to_md.py  # Renders the lint manifest as Markdown
├─ workflows/
│  └─ spec-lint.yml     # GitHub Action to run the linter and post coverage comments
└─ README.md
```

## How to Use This Framework

1. **Adopt the steering documents:** Copy the files in `templates/` into your repository under `.github/instructions/`. Fill out `product.md`, `tech.md` and `structure.md` with your product context, technology stack and repository layout. Copy `copilot-instructions.md` into `.vscode/` to route GitHub Copilot to these steering docs. These files steer developers and coding agents.

2. **Configure AI assistants:** Use the prompts in the `prompts/` folder as system prompts for your AI assistant when generating new specifications or when orchestrating the workflow. You can:
   - Use `requirements_prompt.md` to generate a numbered `requirements.md` with a traceability index.
   - Use `design_prompt.md` to generate a numbered `design.md` that references the requirements and introduces stable design IDs.
   - Use `tasks_prompt.md` to generate an actionable `tasks.md` with references to requirement and design IDs and a tasks traceability table.
   - Use `spec_pack_orchestrator.md` when you want the AI to generate all three files in a single pass and cross‑link them automatically.
   - Use `orchestrator_prompt.md` when you want the AI to manage the entire workflow (detecting whether it’s a project or feature, creating steering docs, routing Copilot, generating specs and executing tasks).
   - Use `product_prompt.md`, `tech_prompt.md`, `structure_prompt.md` (and any future steering prompts) to generate or refresh your steering documents when they evolve.

3. **Generate your spec pack:** With your AI assistant configured, provide context about your project or feature and instruct it to produce the three core spec files. Review and iterate on the generated `requirements.md`, `design.md` and `tasks.md` until they accurately reflect your project.

4. **Install and run the linter locally:** Copy `scripts/spec_lint.py` and `scripts/spec_manifest_to_md.py` into your repository (for example into a `scripts/` directory). Run:

   ```bash
   python3 scripts/spec_lint.py
   ```

   The linter reads `requirements.md`, `design.md` and `tasks.md` in the repository root, checks for missing references and writes `spec-manifest.json`. A non‑zero exit code signals missing coverage or unknown IDs. Use the manifest to fix gaps.

5. **Integrate CI enforcement:** Copy `workflows/spec-lint.yml` into `.github/workflows/` in your repository. This GitHub Action runs the linter on every pull request that touches spec files and posts a coverage comment. You can enforce the check by setting a branch protection rule requiring **Spec Pack Lint / lint** to pass before merging.

6. **Iterate safely:** When you add a new requirement or design element, append it with a new ID. Never renumber existing items. If you retire an item, keep its ID and mark it **Retired** in notes and indexes. After every change, run the linter (`python3 scripts/spec_lint.py`) to ensure coverage remains intact.

## Principles and Best Practices

The framework is built around a few core principles:

- **Stable IDs:** Requirements, design elements and tasks carry identifiers that never change. This allows precise cross‑referencing throughout your documentation and codebase.
- **Traceability:** Every acceptance criterion from `requirements.md` must map to at least one design element in `design.md`, and every design element should be exercised by at least one task in `tasks.md`.
- **Atomic, testable criteria:** Requirements are expressed in EARS‑style WHEN/IF/WHILE conditions followed by “the system SHALL…” statements. Each is atomic and can be translated directly into a test.
- **Separation of concerns:** Requirements define what must be done, the design defines how it will be done, and tasks describe how to execute the plan. Steering documents define the broader product vision and technical guardrails.
- **Automation:** The linter and GitHub Action ensure that documentation stays in sync as the project evolves. Use these tools early in your workflow to avoid drift.

## Versioning Steering Documents

When you update a steering document (e.g. `product.md`, `tech.md`, `structure.md` or other future docs), do not overwrite the previous version. Instead:

1. Create a `docs/deprecated/` directory at the repository root if it does not already exist.
2. Move the old file into `docs/deprecated/` and prepend the filename with `deprecated-YYYY-MM-DD-` where `YYYY-MM-DD` is the date of deprecation (e.g. `deprecated-2025-07-31-product.md`).
3. Create or update the new steering document in `.github/instructions/`.
4. Update `.vscode/copilot-instructions.md` to include or remove routes for the new and deprecated files.

The orchestrator prompt automatically instructs the agent to follow these steps when updating steering docs.

## Frequently Asked Questions

**Why are IDs important?** Stable IDs (e.g. `1.3`, `C2.API1`) are essential for traceability. They allow you to refer to specific behaviours, design elements or tasks in code, tests, comments, ADRs and even commit messages without ambiguity.

**How do I handle non‑functional requirements?** Treat performance, reliability and security targets as numbered requirements (e.g. Requirement 13). Their acceptance criteria should include measurable thresholds (e.g. “13.1 — p95 latency ≤ 200 ms”). These feed into design SLOs and performance tests in tasks.md.

**What if my project uses different technologies?** Adjust the steering templates (`product.md`, `tech.md`, `structure.md`) to reflect your actual stack. The prompts themselves are technology‑agnostic; they require only that you assign IDs consistently and follow the defined structures.

**Can I generate all three spec files at once?** Yes. Use the `spec_pack_orchestrator.md` prompt when instructing your AI. This orchestrator coordinates the generation of `requirements.md`, `design.md` and `tasks.md` and performs internal consistency checks before returning the result.

**What about ADRs and diagrams?** The design prompt includes sections for architecture decision records (ADRs) and diagrams. Use ADRs to document significant choices and trade‑offs, including the IDs of requirements they address. Use Mermaid diagrams labelled with design IDs to visualise system architecture, ER diagrams and critical sequences.

## Contributing

If you wish to extend this framework—for example by adding additional linters, templates or automation scripts—follow the same principles: explicit numbering, clear cross‑references and measurable criteria. Contributions should maintain backward compatibility with existing IDs whenever possible.

## License

This package is released into the public domain. You are free to use, modify and redistribute it without restriction. No warranty is provided; use at your own risk.