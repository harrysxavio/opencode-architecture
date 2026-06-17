# F6A: Controlled Rollout Plan

**Estado:** ✅ READY FOR APPROVAL

## Orden de rollout

1. Reiniciar OpenCode para cargar `engram.ts` actualizado.
2. Validar smoke test: Manager recibe Memory Selector instructions.
3. Forzar/esperar compaction natural y verificar formato RECENT_SESSION_PACK.
4. Ejecutar harness F5B.
5. Monitorear 3 sesiones canonical.

## Rollback

```powershell
Copy-Item -LiteralPath "$env:USERPROFILE\.config\opencode\plugins\engram.ts.f4b-f4c-backup-20260617" -Destination "$env:USERPROFILE\.config\opencode\plugins\engram.ts" -Force
```

Reiniciar OpenCode.

## Stop criteria

E6B falla; Suite F falla; mem_context mezcla proyectos; compacted summary pierde decisiones críticas; aparece secret leakage; Manager degrada por instrucciones contradictorias.

## Observabilidad

`engram-debug.log`, harness F5 y revisión manual del primer compacted summary.
