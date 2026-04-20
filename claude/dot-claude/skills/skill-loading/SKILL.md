---
name: skill-loading
description: Mandatory skill and philosophy loading protocol. Read this before any implementation work.
tags: [philosophy, skills, protocol, mandatory]
triggers: [starting implementation, beginning a coding task, modifying code]
model_hint: small
---

# Skill & Philosophy Loading Protocol

Before ANY implementation, you MUST:

1. **Select the relevant philosophy** based on your task:
   - **Frontend work** (UI, styling, components) → load `frontend-philosophy`
   - **Infrastructure-as-Code** (Terraform, Ansible, Nix, etc.) → load `iac-philosophy`
   - **Astro projects** → load `astro` + `frontend-philosophy`
   - **All other code** → load `code-philosophy`
   - **Multiple domains?** → load all relevant philosophies

2. **Review available skills** for any matching the project's technology stack, patterns, or domain

3. **Load all relevant skills** BEFORE writing or modifying code

4. **Verify your implementation** against the philosophy checklist and skill best practices BEFORE completing

5. **Refactor if needed** — if code violates any principle, fix it before proceeding

This is NOT optional. These philosophies and skills define how code must be written.
