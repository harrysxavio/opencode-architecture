# RECENT_SESSION_PACK Template

Use this structure when OpenCode compacts a long session.

## ACTIVE_PHASE

- Current phase:
- Why it matters:

## LAST_VALIDATED_OUTCOME

- Last command/gate/result actually verified:
- Evidence:

## CURRENT_OBJECTIVE

- Immediate objective:
- Scope:
- Out of scope:

## RAW_RECENT_CONTEXT

Preserve the last 3 meaningful turns as accurately as possible.

1. Turn N-2:
2. Turn N-1:
3. Turn N:

## SUMMARY_CONTEXT

Summarize turns 4-10 back from the current point in 1-2 lines each.

- Turn:
- Turn:
- Turn:

## ACCUMULATED_CONTEXT

Compress older turns into stable facts only:

- Completed work:
- Decisions:
- Constraints:
- Risks:
- Files/artifacts:

## OPEN_DECISIONS

- Decision needed:
- Approval needed:

## OPEN_RISKS_AND_BLOCKERS

- Risk:
- Blocker:
- Verification gap:

## NEXT_STEP

- Safest next action:
- Why:

## REGRESSION_GATES

- E6B:
- Suite F:
- Harness:
- Security:

## Rules

- Preserve explicit user decisions textually when they include constraints, approvals, prohibitions, or rollback requirements.
- Do not include secrets, API keys, tokens, private tags, or credential-like values; replace them with `[REDACTED]`.
- Do not mix projects. Keep project context scoped to the current project only.
- If context is insufficient, write `UNKNOWN`; do not invent.
- Keep this concise. It is a continuity artifact, not a transcript.
