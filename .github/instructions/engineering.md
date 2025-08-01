# Engineering Guardrails

## Code Quality Standards
- All code must pass linting and formatting checks before being committed.
- Type checking is mandatory for both TypeScript and Python code.
- Unit test coverage must be at least 90% for new code.
- Integration tests must be written for all API endpoints and critical workflows.

## Development Practices
- Prefer standardized generators (Nx/Just/cookiecutter) over hand-rolled scaffolding.
- Use generators/scaffolding for creating new apps and libraries.
- Do not introduce technologies or dependencies that circumvent the CI lint/spec gates.
- Follow established naming conventions and directory structure patterns.

## Architecture Principles
- Separate business logic from API handlers and UI components.
- Keep models/schemas in dedicated directories.
- Place platform-specific code in platform folders.
- Co-locate test files with the code they test using `*.spec.*` or `*.test.*` naming.
- Avoid duplicating utilities across applications; place them in shared libraries.

## Dependency Management
- Use pnpm for Node.js dependencies and uv for Python dependencies.
- Commit lockfiles to version control.
- External packages should be added only when necessary and properly vetted.
- Minimize inter-library dependencies in shared libraries.

## Documentation Requirements
- Update environment variables documentation when adding new variables.
- Maintain README files for all apps and libraries.
- Document public APIs and configuration options.
- Keep specification documents in sync with implementation changes.

## Review Process
- All code changes must be reviewed by at least one other team member.
- Specification changes must be reviewed by both technical and product stakeholders.
- Security-sensitive changes require additional review by security team members.
