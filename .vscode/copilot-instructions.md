## Steering Router (high priority)

When proposing, editing or generating code or specifications, **first consult**:

- **Product context:** `.github/instructions/product.md`
- **Engineering guardrails:** `.github/instructions/engineering.md` (if present)
- **Security & data handling:** `.github/instructions/security.md`, `.github/instructions/data.md` (if present)
- **Technical stack:** `.github/instructions/tech.md`
- **Repository structure:** `.github/instructions/structure.md`
- **Additional steering docs:** (e.g. `.github/instructions/api-standards.md`, `.github/instructions/testing-standards.md`) as they are created.

**Obey these priorities:**
1. Product constraints (scope, non‑goals, success metrics)
2. Security and data constraints
3. Engineering guardrails and technology stack guidelines
4. Repository structure and naming conventions
5. Local specification documents (`requirements.md` → `design.md` → `tasks.md`)

If conflicts arise, prefer Product → Security → Engineering → Structure → Local convenience. Avoid decisions that violate **Non‑Goals** in `product.md`. When new steering documents are added or updated, ensure this router is updated accordingly to maintain coverage.