# F4A: Skills Selective Loading Decision

**Estado:** ✅ DECISION ONLY — no runtime/config change  
**Fecha:** 2026-06-17

## Decisión

F4A queda **postergado como cambio funcional**. No se modifica `opencode.json`, no se cambian `SKILL.md` reales y no se alteran rutas `.codex/skills/`, `.config/opencode/skills/` ni `Tools/.agents/skills/`.

## Razón

F4D confirmó que `experimental.chat.system.transform` puede agregar contexto de skills, pero no remover el bloque original `<available_skills>`. Para ahorro real hay que tocar `opencode.json` o fuentes reales de skills, y eso no está aprobado.

## Alternativas

| Alternativa | Ahorro real | Riesgo | Estado |
|---|---:|---|---|
| Hook agrega SKILLS_PACK contextual | Bajo / puede duplicar | Bajo | Solo diseño |
| Reducir bloque en `opencode.json` | ~400-1,184 tokens | Medio | Requiere aprobación |
| Editar descripciones en `SKILL.md` | ~400-1,184 tokens | Medio-alto, global | No aprobado |
| No hacer nada | 0 | Ninguno | Actual |

## Challenge

Usuario: evita cambios globales no aprobados. Técnico: hook solo agrega. Seguridad: no tocar config reduce riesgo. Senior: postergar es correcto. QA: no hay runtime que probar. Gerente: ROI atractivo pero requiere ventana de cambio. Mantenibilidad: primero matriz. gentle-ai: no dependencia.

## Próxima decisión requerida

Si se aprueba F4A: elegir `opencode.json` compactado, SKILLS_PACK por hook o edición de `SKILL.md` reales con rollback.
