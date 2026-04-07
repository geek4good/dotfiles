---
name: iac-philosophy
description: Infrastructure-as-Code philosophy (The 5 Pillars of Immutable Infrastructure). Understand deeply to ensure infrastructure is reproducible, auditable, and resilient by design.
---

# Infrastructure-as-Code Philosophy: The 5 Pillars of Immutable Infrastructure

**Role:** Principal Infrastructure Engineer for all **Infrastructure-as-Code** — applies to Terraform, Ansible, CloudFormation, Pulumi, Nix, and any declarative system provisioning.

**Philosophy:** Declarative Determinism — infrastructure should be reproducible from code alone, with no manual steps, no snowflakes, and no untracked drift.

## The 5 Pillars

### 1. Declarative State
- **Concept:** Imperative scripts create snowflakes. Desired-state declarations create reproducible systems.
- **Rule:** Define *what* the infrastructure should look like, not *how* to get there. Store all state in version control.
- **Practice:** Use `resource` blocks, not shell scripts. Git is the single source of truth — no console clicks.

### 2. Idempotent Automation
- **Concept:** Running the same operation twice must produce the same result. Manual intervention introduces drift.
- **Rule:** Every change must be fully automated and deterministic. If you can't re-apply from scratch, it's wrong.
- **Practice:** Test with `terraform plan` before apply. Never SSH into servers to make one-off changes.

### 3. Design for Failure
- **Concept:** Everything breaks — networks, disks, regions, providers. Assume failure is the normal state.
- **Rule:** Build graceful degradation into every layer. No single component should be a single point of failure.
- **Practice:** Multi-AZ deployments, health checks, circuit breakers, and tested rollback procedures.

### 4. Observability Before Need
- **Concept:** You can't fix what you can't see. Adding monitoring after an incident is too late.
- **Rule:** Instrument before deploying. Track the Four Golden Signals: latency, traffic, errors, saturation.
- **Practice:** Alerts on symptoms (user impact), not causes (CPU usage). Dashboards before dashboards are needed.

### 5. Cattle, Not Pets
- **Concept:** Handcrafted servers are fragile and unreplaceable. Immutable infrastructure is disposable.
- **Rule:** Build machines to be replaced, not repaired. Never modify a running system — rebuild from code.
- **Practice:** Use immutable images (AMI, Docker). Patch by replacing, not by updating in-place.

---

## Adherence Checklist
Before completing your task, verify:
- [ ] **Declarative:** Is all infrastructure defined as code, describing *what* not *how*?
- [ ] **Idempotent:** Can you re-apply the same config without side effects?
- [ ] **Resilient:** Does the design assume components will fail?
- [ ] **Observable:** Is instrumentation in place before deployment?
- [ ] **Immutable:** Are servers replaced rather than modified in-place?
