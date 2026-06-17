# F4E: Manager Protocol Compaction Decision

**Estado:** ✅ PROPOSAL ONLY — no `opencode.json` change

## Decisión

No aplicar compactación del Manager Protocol en runtime activo. Se deja propuesta v2 lista para revisión.

## Razón

El ahorro conservador (~1,200-2,300 tokens) no justifica tocar `opencode.json` sin una ventana explícita de aprobación. F4B/F4C entregan mejor ROI/riesgo.

## Reglas no compactables

Manager owns orchestration; no `gentle-orchestrator` como orchestrator top-level; approval gates; safety restrictions; completion contract; debugging/review gates.

## Challenge

No arriesgar comportamiento del Manager por ahorro menor. Compactación posible, pero requiere tests fuertes. Seguridad bloquearía cualquier pérdida de guardrails críticos.
