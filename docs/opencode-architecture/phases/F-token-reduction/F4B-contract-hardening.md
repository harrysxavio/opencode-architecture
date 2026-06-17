# F4B Contract Hardening + Observability Patch

**Estado:** ✅ HARDENING PASS · F4B runtime status remains ⚠️ PARTIAL  
**Fecha:** 2026-06-17  
**Objetivo:** endurecer `RECENT_SESSION_PACK_COMPACTION_CONTEXT` para que la próxima compactación real sea más fácil de validar sin promover F4B a PASS.

## Cambios aplicados

Archivo runtime:

```text
C:\Users\harry\.config\opencode\plugins\engram.ts
```

Se agregaron secciones obligatorias explícitas:

- `RECENT_SESSION_PACK_VERSION`
- `F4B_COMPACTION_CONTRACT_ACTIVE`
- `ACTIVE_PHASE`
- `LAST_VALIDATED_OUTCOME`
- `CURRENT_OBJECTIVE`
- `OPEN_DECISIONS`
- `OPEN_RISKS_AND_BLOCKERS`
- `RECENT_IDS_OR_ARTIFACTS`
- `NEXT_STEP`
- `REGRESSION_GATES`
- `ROLLBACK_NOTE`

Se agregaron marcadores observables dentro del contrato:

```text
RECENT_SESSION_PACK_VERSION: v1
F4B_COMPACTION_CONTRACT_ACTIVE: true
```

## Observabilidad segura

Se agregó un marcador de diagnóstico sanitizado cuando corre `experimental.session.compacting`:

```text
F4B RECENT_SESSION_PACK compaction hook entered
```

Metadata permitida:

- `contractVersion: v1`
- `contractActive: true`
- `hasSessionID: boolean`
- `project`

No se loguea contenido de usuario, summary, contexto, tokens, IDs completos ni secretos. No escribe en DB. Es reversible restaurando el backup del plugin.

## Seguridad y límites

- No DB migration.
- No schema changes.
- No `opencode.json`.
- No skills reales.
- No F4A runtime.
- No QW#2 Tool Schema Loading runtime.
- No Manager Protocol compaction.
- No gentle-ai.
- No `.codex/memories_1.sqlite`.
- No forzado de compactación.
- No secretos ni tokens.

## Backups

Backups disponibles:

```text
C:\Users\harry\.config\opencode\plugins\engram.ts.f4b-f4c-backup-20260617
C:\Users\harry\.config\opencode\plugins\engram.ts.f4b-hardening-backup-20260617
```

Rollback hardening:

```powershell
Copy-Item -LiteralPath "$env:USERPROFILE\.config\opencode\plugins\engram.ts.f4b-hardening-backup-20260617" -Destination "$env:USERPROFILE\.config\opencode\plugins\engram.ts" -Force
```

Rollback completo F4B/F4C:

```powershell
Copy-Item -LiteralPath "$env:USERPROFILE\.config\opencode\plugins\engram.ts.f4b-f4c-backup-20260617" -Destination "$env:USERPROFILE\.config\opencode\plugins\engram.ts" -Force
```

## Validación

Harness actualizado para validar:

- `RECENT_SESSION_PACK_VERSION`
- `F4B_COMPACTION_CONTRACT_ACTIVE`
- `RECENT_IDS_OR_ARTIFACTS`
- `ROLLBACK_NOTE`
- marcador seguro del hook de compactación
- backup hardening

Resultado:

```text
Total: 27 | PASS: 27 | FAIL: 0
```

Parsing TypeScript:

```text
esbuild parse/bundle check: PASS
```

Nota: `node --check` no aplica directamente a `.ts` y falló por extensión desconocida, no por sintaxis del parche.

## Challenge multiperspectiva

| Perspectiva | Veredicto |
|---|---|
| Usuario | Sí: los marcadores `v1` y `active=true` hacen mucho más fácil reconocer un summary real F4B. |
| Técnico | Sí: el contrato queda explícito, estable y verificable por texto. |
| Seguridad | Aceptable: logs solo de evento/metadata sanitizada; sin contenido sensible ni DB writes. |
| Senior engineer | Bien balanceado: mejora observabilidad sin acoplar F4B a una API nueva ni forzar compaction. |
| QA | Mejoró: el harness ahora detecta campos críticos y backup hardening. |
| Gerente/ROI | Vale la pena: bajo costo, alto valor para evitar otra validación ambigua. |
| Mantenibilidad | Extensible: `RECENT_SESSION_PACK_VERSION: v1` permite evolucionar contrato después. |
| gentle-ai | Sirve como evidencia futura sin crear integración runtime ni dependencia. |

## Veredicto

El hardening pasa sus criterios. F4B sigue correctamente **PARTIAL** porque todavía no existe evidencia de compactación real generando un `RECENT_SESSION_PACK`.
