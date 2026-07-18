Checklist para mis commits manuales (multi-cuenta)

Antes de cualquier `git push`, valido estos 3 puntos en la carpeta del repo:

1. ¿Qué remote tengo en este repo?

```bash
git remote -v
```
Me debe mostrar `git@github.com-cesarbuitragorey:cesarbuitragorey/devops-sandbox.git`. Si un día veo `https://github.com/...` u otro alias, algo lo cambió — lo corrijo antes de seguir.

2. ¿Qué identidad de autor va a quedar en el commit?

```bash
git config user.name
git config user.email
```
Para este repo debe ser `cesarbuitragorey` / `cesar.buitrago.rey@gmail.com` (ya lo dejé seteado localmente, solo para este repo).

3. ¿Con qué llave SSH voy a autenticar el push?

```bash
ssh -T git@github.com-cesarbuitragorey
```
Me debe responder `Hi cesarbuitragorey! You've successfully authenticated...`. Si me responde con otro usuario, tengo mal el alias o la llave.

Flujo normal de commit:

```bash
git status                     # reviso qué se va a incluir
git add <archivos específicos> # nunca hago "git add ." a ciegas
git commit -m "mensaje claro"
git push origin main
```

Si en el futuro agrego otra cuenta de GitHub, repito el mismo patrón:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_<alias> -C "correo@ejemplo.com"
# agrego entrada en ~/.ssh/config con Host github.com-<alias>
# agrego la .pub en github.com/settings/ssh/new de esa cuenta
# remote: git@github.com-<alias>:<usuario>/<repo>.git
```

Para mi expo: como el pipeline corre en runners efímeros de GitHub (no queda nada visible fuera de la UI), voy a mostrar: el diagrama del README → el workflow YAML → un push en vivo → la pestaña Actions con los steps expandidos mostrando `minikube service list` y la URL expuesta.

## Probar el pipeline con un cambio de ejemplo

Cambio `replicas: 1` a `replicas: 2` en `k8s-node-app.yaml`, luego:

```bash
git status
git add k8s-node-app.yaml
git commit -m "Demo: cambio de replicas para disparar el pipeline"
git push origin main
```

Reviso el run en `https://github.com/cesarbuitragorey/devops-sandbox/actions`.

## Verificar el resultado

Estado del último run (`conclusion` debe decir `"success"`):
```bash
curl -s "https://api.github.com/repos/cesarbuitragorey/devops-sandbox/actions/runs?branch=main&per_page=1" | jq '.workflow_runs[0] | {sha: .head_sha, status, conclusion}'
```

Detalle de cada step del último run:
```bash
curl -s "https://api.github.com/repos/cesarbuitragorey/devops-sandbox/actions/runs/$(curl -s 'https://api.github.com/repos/cesarbuitragorey/devops-sandbox/actions/runs?branch=main&per_page=1' | jq '.workflow_runs[0].id')/jobs" | jq '.jobs[0].steps[] | {name, conclusion}'
```

## 4. Se me divergió el repo local del remoto (edité desde GitHub mobile con un commit local pendiente)

Me pasó porque el remoto tenía un commit que yo no tenía en mi local, y yo tenía uno local que el remoto no tenía. Así lo resolví:

```bash
git fetch origin                 # traigo lo nuevo del remoto sin mezclarlo todavía
git status                       # confirmo que dice "diverged"
git log --oneline -5             # reviso qué tengo yo en local
git log --oneline -5 origin/main # reviso qué hay en el remoto, para ver si son los mismos archivos
git pull --rebase origin main    # como no chocan archivos, reordeno mi commit encima del remoto
git push origin main             # ya con el historial derecho, subo normal
```
