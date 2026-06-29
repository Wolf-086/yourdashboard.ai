# SaaS Development Ruleset

version: 1.0
author: Scott
compatible_rulesets:
 - software-development-ruleset-v1
 - writing-ruleset-v1

## Use Case
Codifies the SaaS Development Delegation Planner workflow. Use when building, modifying, or auditing SaaS products (multi-tenant, cloud-hosted, subscription-based). Does NOT apply to core Hermes features (use software-development-ruleset-v1).

## Agent / Role Ownership
- senior-coder: owns SaaS feature implementation, API routes, database schema, integrations
- qa-manager: owns SaaS test suites, security regression, data isolation tests
- safety-manager: owns SaaS safety/security/privacy/compliance review ONLY
- design-manager: owns SaaS UX/UI design artifacts, user flows, dashboard design
- research-director: owns market research, competitive analysis for SaaS
- writing-specialist: owns SaaS copy, onboarding flows, help docs, release notes
- ceo: routing, tracking, blocker investigation, retry logic, GitHub coordination (only with Scott approval)

## Trigger Conditions
- Task touches SaaS product (yourdashboard.ai or other SaaS)
- Task involves user onboarding, billing, multi-tenancy, analytics
- Task touches dashboard, rules engine, API, or cloud infra
- Task requires privacy/security/compliance review
- Task involves external integrations (Stripe, Auth, email, etc.)

## Workflow Steps

1. Intake
   - CEO validates task against SaaS Development Delegation Planner
   - Confirms SaaS tier: frontend / backend / infra / safety / research / copy
   - Assigns to senior-coder (default), safety-manager (safety only), or writing-specialist (copy only)

2. Planning
   - senior-coder reads design docs (yourdashboard.md) + research (yourdashboard-deep-research-v2.md)
   - Maps to SaaS rules engine core (do not treat as generic UI project)
   - Proposes minimal viable change (MVC)
   - design-manager reviews UX alignment

3. Implementation
   - senior-coder implements via patch / write_file
   - No subagent delegation from coding profiles
   - All changes scoped to SaaS product only

4. Safety Review (if applicable)
   - safety-manager runs saas-safety-review for:
     - Data handling / PII
     - Auth / session management
     - Billing integrations
     - External API calls
   - Blocks merge on FAIL; does not auto-fix

5. QA
   - qa-manager validates:
     - Unit + integration tests pass
     - Data isolation between tenants (if multi-tenant)
     - No regression in existing SaaS features
     - Performance / load baseline

6. Deployment Prep
   - CEO confirms no push/commit without Scott approval
   - Change log / release notes drafted by writing-specialist
   - Onboarding docs updated if user-facing change

## Approval Criteria
- SaaS safety review PASS (when safety-review triggered)
- QA PASS on affected test suite
- Rules engine behavior unchanged unless explicitly scoped
- No user data leaked in logs / error messages
- Backward compatibility maintained for API contracts
- All new env vars reviewed by safety-manager

## Validation Checklist
- [ ] Task intake checked against SaaS Development Delegation Planner
- [ ] senior-coder implementation verified
- [ ] safety-manager review PASS (if triggered)
- [ ] qa-manager PASS on scripts/run_tests.sh
- [ ] No regression in yourdashboard.ai rules engine
- [ ] No secrets committed (env vars in .env only)
- [ ] No cross-tenant data access paths
- [ ] API contract changes documented
- [ ] Writing-specialist copy review (if user-facing)
- [ ] No commit/push unless Scott explicitly approves
