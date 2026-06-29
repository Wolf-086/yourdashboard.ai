# Software Development Ruleset

version: 1.0
author: Scott
compatible_rulesets:
 - saas-development-ruleset-v1
 - writing-ruleset-v1

## Use Case
Codifies the Software and Skills Development Delegation Planner workflow. Use when building custom software, skills, plugins, or core Hermes features. Does NOT apply to SaaS products (use saas-development-ruleset-v1).

## Agent / Role Ownership
- senior-coder: owns all coding tasks, code review, refactoring, debugging
- junior-coder: supports senior-coder on routine implementation, file creation, test scaffolding
- qa-manager: owns test validation, quality gates, failure triage
- design-manager: owns design artifacts review, ensures alignment with design docs
- ceo: routing, tracking, blocker investigation, retry on 429/provider errors

## Trigger Conditions
- Task requires new code, code modification, or code deletion
- Task involves plugin, skill, tool, or core module changes
- Task needs code review, refactoring, or debugging
- Task requires test writing or test failure resolution
- Any hermes-agent codebase modification

## Workflow Steps

1. Intake
   - CEO validates task against Software Development Delegation Planner
   - Confirms scope: feature / bug / refactor / test
   - Assigns to senior-coder (or junior-coder if senior-coder fails 3x)

2. Planning
   - senior-coder reads relevant source files via search_files / read_file
   - Maps dependencies, identifies affected modules
   - Proposes implementation plan (max 10 lines)
   - CEO reviews plan for alignment with design docs

3. Implementation
   - senior-coder edits via patch / write_file
   - Junior-coder does NOT drive implementation unless explicitly delegated
   - Changes limited to task scope; no drive-by refactors

4. Review
   - qa-manager validates:
     - Tests pass (scripts/run_tests.sh [target])
     - Linter/type checks pass
     - No new hardcoded paths, secrets, or profile violations
   - qa-manager reports: PASS / FAIL with evidence

5. Fixes
   - On FAIL: senior-coder fixes root cause
   - Re-run tests until PASS or truly blocked
   - CEO may adjust instructions + retry same profile (do not reroute)

6. Validation
   - Run full affected test suite
   - Verify no sibling call paths share same flaw
   - Confirm prompt cache integrity preserved
   - Confirm no profile-isolation violations

## Approval Criteria
- All affected tests pass on current main
- No new change-detector tests introduced
- All paths use get_hermes_home() / display_hermes_home()
- No new HERMES_* env vars for non-secret config
- Dependency pins use upper bounds (<next_major)
- No subagent creation from coding profiles

## Validation Checklist
- [ ] Task intake checked against Software Development Delegation Planner
- [ ] Implementation by senior-coder (verified)
- [ ] Patch applied cleanly (no stale-patch retries > 2x)
- [ ] qa-manager PASS on scripts/run_tests.sh
- [ ] No hardcoded ~/.hermes paths
- [ ] No bare >= dependencies in pyproject.toml
- [ ] No prompt cache invalidation mid-conversation
- [ ] No cross-profile file writes without explicit direction
- [ ] No commit/push unless Scott explicitly approves
- [ ] Root cause fixed (not symptom-only)
