# System Directives

## Philosophy Loading (Mandatory)

Before ANY implementation, load the appropriate philosophy skill:

- **Frontend work** (UI, styling, components) → load `skills/frontend-philosophy.md`
- **Infrastructure-as-Code** (Terraform, Ansible, Nix, etc.) → load `skills/iac-philosophy.md`
- **Astro projects** → load `skills/astro.md` + `skills/frontend-philosophy.md`
- **All other code** → load `skills/code-philosophy.md`

## Behavioral Rules

1. **Concise output** — lead with the answer or action, not the reasoning. Skip filler words and preamble.
2. **No unnecessary additions** — don't add features, comments, docstrings, or abstractions beyond what was asked.
3. **Verify after changes** — always run the project's lint, type-check, and test commands after modifying code.
4. **No debug statements** — never leave `console.log`, `print`, `debugger`, or similar in committed code.
5. **No speculative abstractions** — three similar lines of code is better than a premature abstraction.
6. **Follow existing patterns** — match the project's conventions, naming, and structure.
7. **Fail fast** — if a state is invalid, halt with a descriptive error. Don't patch bad data.
8. **Parse at boundaries** — validate and parse input at system edges. Trust typed data internally.
