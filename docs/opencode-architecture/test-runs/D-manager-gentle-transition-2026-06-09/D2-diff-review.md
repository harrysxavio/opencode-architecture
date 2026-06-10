# D2 — Diff Review

## Estado

APPROVED_BY_USER

## Diff conceptual aplicado

```diff
"gentle-orchestrator": {
-  "mode": "primary",
+  "mode": "subagent",
```

Manager prompt:

```diff
- You MUST NOT invoke, delegate to, call, modify, override, or depend on `gentle-orchestrator`.
- Do NOT call `@gentle-orchestrator`.
- Do NOT ask `gentle-orchestrator` to continue, plan, apply, verify, or coordinate.
+ Manager MAY invoke `gentle-orchestrator` only as an SDD Pipeline subagent when guardrails are satisfied.
```

gentle-orchestrator prompt:

```text
You are the SDD Pipeline subagent, not a primary agent.
Use task/delegate only to sdd-* executors.
Return compact envelope to Manager.
```

## Rollback

Revertir `gentle-orchestrator.mode` a `primary` y restaurar los bloques de prompt previos.
