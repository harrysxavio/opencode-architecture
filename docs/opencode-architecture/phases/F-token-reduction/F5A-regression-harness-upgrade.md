# F5A: Regression Harness Upgrade

**Estado:** ✅ COMPLETED  
**Fecha:** 2026-06-17

## Qué cambió

El harness se amplió de verificación documental básica a gates F4/F5: artefactos F4/F5/F6/F7, plugin hooks F4B/F4C, boundaries de F4A/QW#2/QW#3, secret patterns, DB invariance por tamaño, README/DOCUMENTATION-INDEX y gentle-ai no modificado en repo.

## Challenge QA

Detecta ausencia de hooks/docs/secrets; no simula compaction real. Es read-only y no toca DB. La compactación real solo puede validarse cuando OpenCode dispare compaction tras reinicio.
