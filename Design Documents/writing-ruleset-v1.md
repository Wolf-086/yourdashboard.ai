# Writing Ruleset

version: 1.0
author: Scott
compatible_rulesets:
  - software-development-ruleset-v1
  - saas-development-ruleset-v1

## Use Case
Covers planning, drafting, revising, editing, publishing workflows. Use for documentation, blog posts, marketing copy, release notes, help docs, technical writing, or any authored content. Does NOT apply to code or UI implementation.

## Agent / Role Ownership
- writing-specialist: owns draft creation, revision, editing, style adaptation
- research-director: owns source material, fact-checking, competitive landscape
- design-manager: owns visuals, formatting, layout, brand consistency
- qa-manager: owns final proofread checklist, factual accuracy spot-check
- ceo: routing, tracking, deadline management, publication approval

## Trigger Conditions
- Task requires new written content
- Task requires revision or editing of existing content
- Task requires formatting for publication
- Task needs research-backed sourcing
- Publication / release / publish action requested

## Workflow Steps

1. Intake
   - CEO validates task against Writing Delegation Planner (or Writing Ruleset)
   - Confirms format: blog / doc / release note / help / marketing / technical
   - Confirms tone, audience, length target
   - Assigns to writing-specialist (default)

2. Research (if needed)
   - research-director gathers:
     - Primary sources (docs, interviews, specs)
     - Competitive / reference material
     - Factual claims requiring verification
   - Returns structured brief + source list

3. Drafting
   - writing-specialist produces first draft
   - Follows project style guide (if exists in vault)
   - Includes section headers, scannable structure
   - Length within target; no filler

4. Revision
   - writing-specialist revises draft against:
     - Clarity / specificity
     - Tone consistency
     - Factual accuracy (from research-director brief)
     - SEO / goal alignment (if applicable)

5. Editing
   - writing-specialist produces self-contained final draft
   - design-manager adds formatting, visuals, callouts
   - qa-manager runs proofread checklist

6. Approval
   - CEO reviews against approval criteria
   - Scott approves for publish (if Scott is destination)
   - publication action only after explicit approval

7. Publish
   - Deliverable finalized in vault or target platform
   - Versioned (v1, v2) if iterative
   - Source + published copies saved

## Approval Criteria
- All factual claims sourced from research-director brief or primary source
- Tone matches audience + project brand
- No jargon dumps; plain language preferred unless technical audience
- Passes qa-manager proofread checklist
- Formatting complete (headers, links, images where needed)
- Publication target confirmed

## Validation Checklist
- [ ] Task intake checked against Writing Delegation Planner
- [ ] Research completed (if required) and sourced
- [ ] Draft within length target
- [ ] Revision addresses clarity + accuracy
- [ ] Edit pass complete (spelling, grammar, flow)
- [ ] design-manager formatting applied
- [ ] qa-manager proofread PASS
- [ ] Publication target confirmed
- [ ] Deliverable saved to vault or target location
- [ ] No publish action without explicit Scott approval
