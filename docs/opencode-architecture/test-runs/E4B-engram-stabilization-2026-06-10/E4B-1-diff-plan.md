# E4B-1 — Diff Plan

> Plan de cambios aprobado antes de implementar.

## Archivos modificados

| Archivo | Cambio |
|---|---|
| `C:\Users\harry\.config\opencode\opencode.json` | Pin binario v1.16.1 + `--project=opencode-architecture` |
| `C:\Users\harry\.config\opencode\opencode.jsonc` | Pin binario v1.16.1 + `--project=opencode-architecture` |
| `C:\Users\harry\.codex\config.toml` | **No tocar** |

## Diff — opencode.json

```diff
     "engram": {
       "command": [
-        "engram",
-        "mcp",
-        "--tools=agent"
+        "C:\\Users\\harry\\AppData\\Local\\engram\\bin\\engram.exe",
+        "mcp",
+        "--tools=agent",
+        "--project=opencode-architecture"
       ],
       "type": "local"
     },
```

## Diff — opencode.jsonc

```diff
     "engram": {
       "command": [
-        "C:\\Users\\harry\\bin\\engram.exe",
-        "mcp",
-        "--tools=agent"
+        "C:\\Users\\harry\\AppData\\Local\\engram\\bin\\engram.exe",
+        "mcp",
+        "--tools=agent",
+        "--project=opencode-architecture"
       ],
```

## Riesgos identificados pre-cambio

| Riesgo | Mitigación |
|---|---|
| v1.16.1 tool schema diferente | Backup previo; rollback inmediato |
| opencode.jsonc merge duplica instancia | Ambos apuntan al mismo binario/project → no conflictivo |
| Codex mantiene v1.15.13 | Documentado; store compartido, binario diferente |
| JSON inválido post-edit | Validación con `node -e "JSON.parse(...)"` antes de reiniciar |

## Rollback

```bash
copy C:\Users\harry\.config\opencode\opencode.json.bak C:\Users\harry\.config\opencode\opencode.json
copy C:\Users\harry\.config\opencode\opencode.jsonc.bak C:\Users\harry\.config\opencode\opencode.jsonc
```
