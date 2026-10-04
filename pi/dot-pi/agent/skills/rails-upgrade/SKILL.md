---
name: rails-upgrade
description: >
  Analyzes Rails applications and generates comprehensive upgrade reports with breaking changes, deprecations, and step-by-step migration guides for Rails 2.3 through 8.1.
  Use when upgrading Rails applications, planning multi-hop upgrades, or querying version-specific changes. Based on FastRuby.io methodology and "The Complete Guide to Upgrade Rails" ebook.
tags: [rails, ruby, upgrade, migration]
triggers: [rails upgrade, gemfile rails, breaking changes, app:update]
model_hint: large
---

# Rails Upgrade Assistant Skill

## Skill Identity
- **Name:** Rails Upgrade Assistant
- **Purpose:** Intelligent Rails application upgrades from 2.3 through 8.1
- **Skill Type:** Modular with external workflows and examples
- **Upgrade Strategy:** Sequential only (no version skipping)
- **Methodology:** Based on FastRuby.io upgrade best practices and "The Complete Guide to Upgrade Rails" ebook
- **Attribution:** Content based on "The Complete Guide to Upgrade Rails" by FastRuby.io (OmbuLabs)

---

## Core Methodology (FastRuby.io Approach)

This skill follows the proven FastRuby.io upgrade methodology:

1. **Incremental Upgrades** - Always upgrade one minor/major version at a time
2. **Assessment First** - Understand scope before making changes
3. **Dual-Boot Testing** - Test both versions during transition using `next_rails` gem
4. **Test Coverage** - Ensure adequate test coverage before upgrading (aim for 80%+)
5. **Gem Compatibility** - Check gem compatibility at each step using RailsBump
6. **Deprecation Warnings** - Address deprecations before upgrading
7. **Backwards Compatible Changes** - Deploy small changes to production before version bump

**Key Resources:**
- See `reference/deprecation-warnings.md` for managing deprecations
- See `reference/staying-current.md` for maintaining upgrades over time

---

## Core Workflow (7-Step Process)

### Step 0: Verify Latest Patch Version (MANDATORY PRE-STEP)
- **CRITICAL:** Before any upgrade work begins, verify the app is on the latest patch release of its current Rails series
- Read `Gemfile.lock` to find the exact current Rails version (e.g., `3.2.19`)
- Compare against the latest patch for that series:
  - **EOL series (≤ 6.1):** Use the static table in `reference/multi-hop-strategy.md`
  - **Active series (≥ 7.0):** Query the RubyGems API at runtime (see `reference/multi-hop-strategy.md` for commands)
- If the app is NOT on the latest patch:
  - Inform user: "Your app is on Rails X.Y.Z but the latest patch is X.Y.W — you should upgrade to the latest patch first"
  - Guide user through updating the Gemfile and running `bundle update rails`
  - Run test suite after patch upgrade to verify nothing broke
  - Deploy patch upgrade before proceeding with the minor/major version hop
- If the app IS on the latest patch → Proceed to Step 1

### Step 1: Run Test Suite (MANDATORY FIRST STEP)
- **CRITICAL:** Before any upgrade work begins, run the existing test suite
- Execute `bundle exec rspec` or `bundle exec rails test` to verify baseline
- All tests MUST pass before proceeding with any upgrade
- If tests fail, stop and help user fix failing tests first
- Record test count and coverage as baseline metrics
- See `workflows/test-suite-verification-workflow.md` for details

### Step 2: Set Up Dual-Boot with next_rails (EARLY SETUP)
- Set up `next_rails` gem for dual-boot testing
- Add next_rails gem and run `next_rails --init`
- Install dependencies for both Rails versions
- Configure the Gemfile with `if next?` conditionals

### Step 3: Run Breaking Changes Detection (DIRECT)
- **Run detection checks directly** using Grep, Glob, and Read tools
- No script generation - search the codebase in real-time
- Find issues with file:line references
- Collect all findings immediately
- See `workflows/direct-detection-workflow.md` for patterns to search

### Step 4: Generate Reports Based on Findings
- **Comprehensive Upgrade Report**: Breaking changes analysis with OLD vs NEW code examples, custom code warnings with ⚠️ flags, step-by-step migration plan, testing checklist and rollback plan
- **app:update Preview Report**: Shows exact configuration file changes (OLD vs NEW), lists new files to be created, impact assessment (HIGH/MEDIUM/LOW)

### Step 5: Implement Changes & Upgrade Rails Version
- Fix breaking changes identified in the reports
- Use `NextRails.next?` for code that must work with both versions
- Update Gemfile to target Rails version
- Run test suite against both versions during the transition
- Deploy and verify

### Step 6: Align load_defaults to New Version (FINAL STEP)
- Walk through each config change one at a time, grouped by risk tier
- Tests are re-run between each change
- Consolidates into config/application.rb when done

---

## Trigger Patterns

Activate this skill when user says:

**Upgrade Requests:**
- "Upgrade my Rails app to [version]"
- "Help me upgrade from Rails [x] to [y]"
- "What breaking changes are in Rails [version]?"
- "Plan my upgrade from [x] to [y]"
- "Analyze my Rails app for upgrade"
- "Find breaking changes in my code"
- "Check my app for Rails [version] compatibility"

**Specific Report Requests:**
- "Show me the app:update changes"
- "Preview configuration changes for Rails [version]"
- "Generate the upgrade report"

---

## CRITICAL: Sequential Upgrade Strategy

### ⚠️ Version Skipping is NOT Allowed

Rails upgrades MUST follow a sequential path. Examples:

```
5.0.x → 5.1.x → 5.2.x → 6.0.x → 6.1.x → 7.0.x → 7.1.x → 7.2.x → 8.0.x → 8.1.x
```

**You CANNOT skip versions.** Examples:
- ❌ 5.2 → 6.1 (skips 6.0)
- ❌ 6.0 → 7.0 (skips 6.1)
- ✅ 5.2 → 6.0 (correct)
- ✅ 7.2 → 8.0 (correct)

---

## Supported Upgrade Paths

| From | To | Difficulty | Key Changes | Ruby Required |
|------|-----|-----------|-------------|---------------|
| 3.2.x | 4.0.x | Hard | Strong Parameters, scopes require lambda | 1.9.3+ |
| 4.2.x | 5.0.x | Hard | ActionCable, API mode, ApplicationRecord | 2.2.2+ |
| 5.0.x | 5.1.x | Easy | Encrypted secrets, yarn default | 2.2.2+ |
| 5.1.x | 5.2.x | Medium | Active Storage, credentials | 2.2.2+ |
| 5.2.x | 6.0.x | Hard | Zeitwerk, Action Mailbox/Text | 2.5.0+ |
| 6.0.x | 6.1.x | Medium | Horizontal sharding, strict loading | 2.5.0+ |
| 6.1.x | 7.0.x | Hard | Hotwire/Turbo, Import Maps | 2.7.0+ |
| 7.0.x | 7.1.x | Medium | Composite keys, async queries | 2.7.0+ |
| 7.1.x | 7.2.x | Medium | Transaction-aware jobs, DevContainers | 3.1.0+ |
| 7.2.x | 8.0.x | Very Hard | Propshaft, Solid gems, Kamal | 3.2.0+ |
| 8.0.x | 8.1.x | Easy | Bundler-audit, max_connections | 3.2.0+ |

---

## Available Resources

### Version-Specific Guides (Load as needed)
- `version-guides/upgrade-3.2-to-4.0.md`
- `version-guides/upgrade-4.2-to-5.0.md`
- `version-guides/upgrade-5.0-to-5.1.md`
- `version-guides/upgrade-5.1-to-5.2.md`
- `version-guides/upgrade-5.2-to-6.0.md`
- `version-guides/upgrade-6.0-to-6.1.md`
- `version-guides/upgrade-6.1-to-7.0.md`
- `version-guides/upgrade-7.0-to-7.1.md`
- `version-guides/upgrade-7.1-to-7.2.md`
- `version-guides/upgrade-7.2-to-8.0.md`
- `version-guides/upgrade-8.0-to-8.1.md`

### Workflow Guides (Load when generating deliverables)
- `workflows/test-suite-verification-workflow.md`
- `workflows/direct-detection-workflow.md`
- `workflows/upgrade-report-workflow.md`
- `workflows/app-update-preview-workflow.md`

### Examples (Load when user needs clarification)
- `examples/simple-upgrade.md`
- `examples/multi-hop-upgrade.md`

### Reference Materials
- `reference/deprecation-warnings.md`
- `reference/staying-current.md`
- `reference/breaking-changes-by-version.md`
- `reference/multi-hop-strategy.md`
- `reference/testing-checklist.md`
- `reference/gem-compatibility.md`

### Detection Pattern Resources
- `detection-scripts/patterns/rails-40-patterns.yml`
- `detection-scripts/patterns/rails-50-patterns.yml`
- `detection-scripts/patterns/rails-60-patterns.yml`
- `detection-scripts/patterns/rails-70-patterns.yml`
- `detection-scripts/patterns/rails-71-patterns.yml`
- `detection-scripts/patterns/rails-72-patterns.yml`
- `detection-scripts/patterns/rails-80-patterns.yml`
- `detection-scripts/patterns/rails-81-patterns.yml`

### Report Templates
- `templates/upgrade-report-template.md`
- `templates/app-update-preview-template.md`

---

## Key Principles

1. **ALWAYS Verify Latest Patch First** (MANDATORY)
2. **ALWAYS Run Test Suite** (MANDATORY - no exceptions)
3. **Block on Failing Tests** (if tests fail, STOP)
4. **Set Up Dual-Boot Early** (right after tests pass)
5. **Run Detection Directly** (use Grep/Glob/Read tools)
6. **Always Use Actual Findings** (no generic examples in reports)
7. **Always Flag Custom Code** (with ⚠️ warnings)
8. **Always Use Templates** (for consistency)
9. **Sequential Process is Critical** (patch → tests → dual-boot → detection → reports → implement → load_defaults)
10. **Follow FastRuby.io Methodology** (incremental upgrades, assessment first)
11. **Always Use `NextRails.next?` for Dual-Boot Code** (NEVER use `respond_to?` for version branching)
12. **Align load_defaults Last** (after the Rails version upgrade is complete)
