Lab3 Jenkins: bitácora de trabajo

Objetivo del lab: Multibranch pipeline "CICD" + pipeline manual "CD_deploy_manual" para deployar https://github.com/epam-msdp/cicd-pipeline en un repo propio, con ramas main (puerto 3000) y dev (puerto 3001), cada una con su logo.svg.

## 0. Diagnóstico del entorno

Antes de instalar nada reviso qué tengo disponible en esta Mac:

```bash
java -version      # -> no hay JRE instalada
docker --version   # -> Docker version 29.6.1
docker info        # -> Docker Desktop corriendo (desktop-linux), sin problema
brew --version     # -> Homebrew 6.0.11 disponible
```

Decisión: como no tengo Java pero sí Docker Desktop corriendo, levanto Jenkins como contenedor Docker en vez de instalarlo nativo con Homebrew. Así evito instalar/gestionar una JVM en el Mac, y aprovecho que el lab ya pide Docker Pipeline + Docker plugin.

Para que los pipelines puedan hacer `docker build` / `docker run` sobre imágenes de la app, monto el socket de Docker del host dentro del contenedor de Jenkins (patrón "Docker outside of Docker"), en vez de Docker-in-Docker.

## 1. Levantar Jenkins en Docker

Dos supuestos del plan inicial fallaron y los corregí:

1. `/var/run/docker.sock` no existe en el host tal cual — en Docker Desktop for Mac el socket real vive en `~/.docker/run/docker.sock` (confirmado con `docker context inspect --format '{{.Endpoints.docker.Host}}' desktop-linux`). Montar el path equivocado da `stat: No such file or directory`.
2. No puedo montar el binario `docker` de macOS (`/usr/local/bin/docker`) dentro del contenedor — es un Mach-O de macOS, el contenedor es Linux/arm64 y no lo puede ejecutar. Hay que usar un binario Linux del CLI.
3. `--group-add <gid>` fallaba con `unable to find group : no matching entries in group file` porque el gid obtenido en el host (macOS) no existe como grupo dentro del contenedor. Más simple: correr el contenedor como `--user root`.

Extraigo el CLI de Docker para Linux desde la imagen oficial `docker:cli` (evita instalar el paquete completo `docker.io` vía apt):

```bash
docker create --name docker-cli-extract docker:cli
docker cp docker-cli-extract:/usr/local/bin/docker ./docker-cli/docker
docker rm docker-cli-extract
chmod +x ./docker-cli/docker
```

Y levanto Jenkins:

```bash
docker volume create jenkins_home

DOCKER_SOCK="$HOME/.docker/run/docker.sock"
DOCKER_CLI="./docker-cli/docker"

docker run -d --name jenkins \
  --user root \
  -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v "$DOCKER_SOCK":/var/run/docker.sock \
  -v "$DOCKER_CLI":/usr/local/bin/docker \
  --restart unless-stopped \
  jenkins/jenkins:lts
```

Verificación de que el contenedor de Jenkins puede hablarle al Docker del host:
```bash
docker exec jenkins docker version
# -> Client linux/arm64 + Server "Docker Desktop 4.82.0", ambos contra el mismo daemon
```

Notas:
- `--user root` porque el usuario `jenkins` (uid 1000) de la imagen no tiene permisos sobre el socket montado desde macOS (el gid del host no mapea a nada dentro del contenedor). Es una decisión válida para un sandbox de entrenamiento local; en un entorno real se manejaría con un grupo `docker` creado explícitamente o un socket-proxy con permisos acotados.
- `jenkins_home` como volumen nombrado para no perder configuración, plugins ni credenciales si el contenedor se recrea (`--restart unless-stopped` + volumen persistente).

Password inicial:
```bash
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

### Incidente: Jenkins no arrancaba después de reiniciar Docker Desktop

Al volver a una sesión con Docker Desktop apagado y prenderlo de nuevo (`open -a Docker`), el contenedor `jenkins` quedó en `Exited (127)`. Causa: había montado el binario `docker` desde un path del scratchpad de la sesión anterior (`/private/tmp/claude-503/.../scratchpad/docker-cli/docker`), que es efímero y se limpia entre sesiones. Al reiniciar, ese archivo ya no existía como archivo (quedó como carpeta vacía), y el bind-mount fallaba:

```
error mounting ".../scratchpad/docker-cli/docker" to rootfs at "/usr/local/bin/docker": ...
not a directory: Are you trying to mount a directory onto a file (or vice-versa)?
```

Lección: nunca depender de un bind-mount de host apuntando a un path temporal/efímero para algo que el contenedor necesita en cada arranque.

Fix: recreé el contenedor (`docker rm -f jenkins` + `docker run` de nuevo) reusando el volumen nombrado `jenkins_home` (por eso no se perdió nada — plugins, admin user, jobs viven ahí, no en el contenedor), pero esta vez **sin** montar el binario de Docker desde el host. En su lugar lo instalé como paquete real dentro del filesystem propio del contenedor, que si persiste entre reinicios del contenedor (solo se perdería si se borra el contenedor, no el daemon):

```bash
docker rm -f jenkins

docker run -d --name jenkins \
  --user root \
  -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v "$HOME/.docker/run/docker.sock":/var/run/docker.sock \
  --restart unless-stopped \
  jenkins/jenkins:lts

docker exec -u root jenkins bash -c "apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq docker.io"
```

(Los warnings de `sysctl: permission denied` durante el `apt-get install` son ruido del post-install script de `docker.io` intentando tunear parámetros de kernel dentro de un contenedor sin privilegios para eso — no afectan, el CLI queda instalado igual.)

Verifiqué que la config previa seguía intacta después de recrear el contenedor: `docker exec jenkins ls /var/jenkins_home/plugins/` seguía mostrando `docker-plugin`, `docker-workflow`, `nodejs` ya instalados.

## 2. Desbloqueo e instalación de plugins

Desbloqueo manual en http://localhost:8080 con el password inicial + "Install suggested plugins" (hecho por mí en el navegador, no automatizable desde acá). Eso instala git, github, pipeline/workflow, pero **no** Docker Pipeline, Docker plugin ni NodeJs plugin — hay que sumarlos aparte.

Los instalé sin pasar por la UI, usando el CLI que trae la propia imagen de Jenkins (evita depender de login/API token):

```bash
docker exec -u root jenkins jenkins-plugin-cli --plugins docker-plugin docker-workflow nodejs
docker restart jenkins
```

Verificación (deben aparecer en el filesystem del contenedor):
```bash
docker exec jenkins ls /var/jenkins_home/plugins/ | grep -iE "docker|nodejs"
```

Nota: `groovy` no aparece como plugin aparte — el motor Groovy ya viene embebido en `workflow-cps`/pipeline, que se instala con el set "suggested". No hace falta instalarlo por separado.

## 3. Clonar epam-msdp/cicd-pipeline y crear repo propio

Importante: el repo nuevo NO va dentro de `devops-sandbox` (que ya es un repo git con remote propio) ni dentro de `lab3-jenkins/`. Anidar un repo git dentro de otro repo git rompe el tracking del repo padre. Lo cloné como carpeta **hermana**, fuera de `devops-sandbox`:

`/Users/cesar.buitrago/sm/training/github-sandbox/cicd-pipeline`

(`github-sandbox` en sí no es un repo git, así que no hay riesgo de anidamiento)

Creé el repo remoto con `gh` (instalé `gh` vía Homebrew porque no estaba, y logueé con `gh auth login` en modo SSH):

```bash
brew install gh
gh auth login   # interactivo: GitHub.com -> SSH -> login with browser
gh repo create cicd-pipeline --private --description "Lab3 Jenkins: CI/CD pipeline app (import from epam-msdp/cicd-pipeline)"
```

Clono el repo base, elimino su historial y lo re-inicializo como historial propio apuntando a mi remote:

```bash
git clone https://github.com/epam-msdp/cicd-pipeline.git
cd cicd-pipeline
rm -rf .git
git init -q
git checkout -b main
git remote add origin git@github.com-cesarbuitragorey:cesarbuitragorey/cicd-pipeline.git
git config user.name cesarbuitragorey
git config user.email cesar.buitrago.rey@gmail.com
git add .
git commit -m "Initial import from epam-msdp/cicd-pipeline"
git push -u origin main
```

Uso el alias SSH `github.com-cesarbuitragorey` que ya tengo configurado para esta cuenta (ver [lab1 steps.md](../lab1-github-actions/steps.md)).

Verifiqué después que `devops-sandbox` seguía intacto (`git status` sin cambios nuevos) — el clone/push de `cicd-pipeline` no lo tocó para nada.

## 4. Jenkinsfile compartido + rama dev + diferenciación logo/puerto

Primero agregué un único `Jenkinsfile` en `main` (funciona para ambas ramas vía Multibranch, condicionando por `env.BRANCH_NAME`):

```groovy
environment {
    APP_PORT = "${env.BRANCH_NAME == 'main' ? '3000' : '3001'}"
    IMAGE_NAME = "${env.BRANCH_NAME == 'main' ? 'nodemain' : 'nodedev'}"
    CONTAINER_NAME = "${env.BRANCH_NAME == 'main' ? 'cicd-main' : 'cicd-dev'}"
}
```

Stages: Checkout -> Build (`scripts/build.sh`) -> Test (`CI=true scripts/test.sh`, el `CI=true` es necesario porque `react-scripts test` sin eso queda en modo watch y el pipeline nunca termina) -> Build Docker Image (`docker build -t $IMAGE_NAME:v1.0 .`) -> Deploy.

En el stage de Deploy implementé directamente la versión de la tarea "Advanced tasks" del README: en vez de borrar todos los contenedores (`docker rm -f $(docker ps -aq)`), solo se elimina el contenedor del env que se está desplegando (`docker rm -f $CONTAINER_NAME`), dejando el del otro branch intacto. No tenía sentido implementar primero la versión "ingenua" y luego arreglarla.

```bash
cd cicd-pipeline
git add Jenkinsfile
git commit -m "Add Jenkinsfile with branch-based port/image/container logic"
git push origin main
```

Luego creo la rama `dev` y reemplazo `src/logo.svg` (el logo default de CRA en azul) por un logo distinto (hexágono naranja con texto "DEV"):

```bash
git checkout -b dev
# edito src/logo.svg
git add src/logo.svg
git commit -m "dev: logo distinto (hexagono naranja DEV) para diferenciar env"
git push -u origin dev
```

Confirmé con `git diff main dev --stat` que el único archivo que difiere entre ramas es `src/logo.svg` — el Jenkinsfile es el mismo en ambas y resuelve puerto/imagen/contenedor dinámicamente según `BRANCH_NAME`.

## 5. Credencial SSH + Global Tool Configuration

Decidí mantener `cicd-pipeline` **privado** (en vez de hacerlo público para simplificar), así que el Multibranch pipeline necesita autenticarse. Agregué la credencial manualmente en la UI (no lo hago por script porque implicaría pegar la llave privada en un comando/log, algo que evito):

Manage Jenkins -> Credentials -> (global) -> Add Credentials:
- Kind: SSH Username with private key
- ID: `github-cesarbuitragorey`
- Username: `git`
- Private Key: contenido de `~/.ssh/id_ed25519_cesarbuitragorey` (la misma llave/alias que uso en [lab1 steps.md](../lab1-github-actions/steps.md))

Y el Global Tool para NodeJS (también manual, Manage Jenkins -> Tools):
- NodeJS installations -> Add NodeJS
- Name: `NodeJS-7.8.0` (tiene que calzar exacto con `tools { nodejs 'NodeJS-7.8.0' }` del Jenkinsfile)
- Version: `7.8.0` sí aparece en el dropdown (el plugin lista todo el histórico de nodejs.org/dist)

### Incidente: "Host key verification failed" al escanear el Multibranch

Al crear el Multibranch pipeline "CICD" con la fuente Git por SSH, el primer scan falló:
```
No ED25519 host key is known for github.com and you have requested strict checking.
Host key verification failed.
```

Causa: el contenedor de Jenkins es nuevo (imagen recién creada), nunca se conectó antes a github.com, así que no tiene su host key en `known_hosts`. La estrategia de verificación por default de Jenkins es estricta.

Fix, sin bajar la seguridad a "no verificar" ni tocar la config global de Jenkins — simplemente pre-cargo la host key real de GitHub (`ssh-keyscan`, la misma huella pública y documentada de GitHub) en el `known_hosts` del usuario que corre los jobs (`root`, porque el contenedor corre con `--user root`):

```bash
docker exec -u root jenkins bash -c "mkdir -p /root/.ssh && chmod 700 /root/.ssh && \
  ssh-keyscan -t ed25519 github.com >> /root/.ssh/known_hosts && chmod 600 /root/.ssh/known_hosts"
```

Nota: esto vive en el filesystem propio del contenedor (no en el volumen `jenkins_home`), igual que el CLI de Docker instalado antes — persiste mientras no se borre el contenedor, pero si se recrea hay que repetirlo. Si esto se vuelve rutina, se podría hornear en un `Dockerfile` custom en vez de repetirlo a mano.

## 6. Pipeline Multibranch "CICD"

New Item -> nombre `CICD` -> tipo Multibranch Pipeline.

- Branch Sources -> Add source -> **Git** (no "GitHub", para no pedir de más scopes de API — con Git simple por SSH alcanza)
  - Project Repository: `git@github.com:cesarbuitragorey/cicd-pipeline.git`
  - Credentials: `github-cesarbuitragorey`
- Build Configuration: Mode `by Jenkinsfile`, Script Path `Jenkinsfile` (default)
- Scan Multibranch Pipeline Triggers: **Periodically if not otherwise run**, cada 1 minuto (no hay forma de recibir webhook de GitHub hacia un Jenkins que corre en `localhost`, así que el scan periódico es cómo detecta ramas/cambios)

Primer scan encontró las 2 ramas y corrió ambos jobs automáticamente: `CICD/main` y `CICD/dev`, ambos `SUCCESS` en el primer intento (después de resolver el incidente de host key de abajo).

Resultado del build de `CICD/main` (log completo revisado vía `docker exec jenkins tail ... /var/jenkins_home/jobs/CICD/branches/main/builds/1/log`):
- Descarga NodeJS 7.8.0 vía el Global Tool (`Unpacking https://nodejs.org/dist/v7.8.0/node-v7.8.0-linux-arm64.tar.gz`)
- `npm install` completo (el árbol enorme de dependencias en el log es ruido normal de un `package.json` de 2017 con `react-scripts@1.0.14`)
- `docker build -t nodemain:v1.0 .` — nota: sale un warning `requested image's platform (linux/amd64) does not match ... arm64` porque `node:7.8.0` (la base del Dockerfile) es tan vieja que solo tiene manifest amd64; Docker Desktop la corre emulada. Funciona, solo un poco más lento.
- Deploy: `docker rm -f cicd-main || true` (no existía, primera vez) + `docker run -d --name cicd-main -p 3000:3000 -e PORT=3000 nodemain:v1.0`

`CICD/dev` corrió igual pero con `nodedev:v1.0` / `cicd-dev` / puerto 3001.

## 7. Pipeline manual "CD_deploy_manual"

Para que este job pueda elegir a qué rama redeployar sin depender de `env.BRANCH_NAME` (que solo existe en Multibranch), le agregué un parámetro al Jenkinsfile con fallback:

```groovy
parameters {
    choice(name: 'TARGET_BRANCH', choices: ['', 'main', 'dev'], description: 'Rama a desplegar (solo aplica a CD_deploy_manual)')
}
environment {
    RESOLVED_BRANCH = "${params.TARGET_BRANCH ?: env.BRANCH_NAME}"
    APP_PORT = "${RESOLVED_BRANCH == 'main' ? '3000' : '3001'}"
    ...
}
```

Este cambio lo hice en `main` y lo mergeé a `dev` (`git merge main` desde `dev`) para no romper la invariante de que ambas ramas comparten el mismo Jenkinsfile y solo difieren en `src/logo.svg`.

Config del job (New Item -> `CD_deploy_manual` -> tipo **Pipeline**, no Multibranch):
- Sin ningún trigger marcado (ni "Build periodically" ni "Poll SCM" ni webhook) -> 100% manual
- Pipeline -> Definition: **Pipeline script from SCM**
  - SCM: Git, Repository URL: `git@github.com:cesarbuitragorey/cicd-pipeline.git`, Credentials: `github-cesarbuitragorey`
  - Branch Specifier: `*/main` (fijo, da igual desde qué rama se lee ya que el Jenkinsfile es idéntico)
  - Script Path: `Jenkinsfile`

### Incidente: no aparecía "Build with Parameters", solo "Build Now"

Con "Pipeline script from SCM", Jenkins no puede mostrar los parámetros definidos dentro del Jenkinsfile hasta que el job corre **al menos una vez** (necesita bajar y parsear el script primero). Fix: ninguno realmente, solo correr "Build Now" una vez — ese primer build corre con `TARGET_BRANCH` vacío (cae al fallback, termina desplegando `dev` por default del ternario). Confirmé después en `config.xml` del job que quedó persistido el `ParametersDefinitionProperty`, y ya apareció "Build with Parameters" para los siguientes builds.

Build #1 de `CD_deploy_manual`: `SUCCESS`, redeployó `cicd-dev` (contenedor recreado, timestamp más reciente) sin tocar `cicd-main` — confirma que el aislamiento por env funciona también disparado desde este pipeline manual.

## 8. Validación final

```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000   # -> 200 (main, logo azul CRA)
curl -s -o /dev/null -w "%{http_code}" http://localhost:3001   # -> 200 (dev, logo naranja hexágono "DEV")
```

Confirmé que cada puerto sirve un `logo.<hash>.svg` distinto (`logo.5d5d9eef.svg` en main vs `logo.a917de48.svg` en dev) y que el contenido de cada uno corresponde al logo esperado de esa rama.

## 9. Advanced task: Docker Hub + Deploy_to_main / Deploy_to_dev

Segunda advanced task del README: push de las imágenes a Docker Hub, y 2 pipelines nuevos que hacen `docker pull` + `docker run` desde el registry, disparados automáticamente por el Multibranch según la rama.

Para no hardcodear el usuario de Docker Hub en el código, uso `withCredentials` con una credencial tipo "Username with password" (username = usuario Docker Hub, password = access token, no la contraseña real) — así `$DOCKER_USER`/`$DOCKER_PASS` se resuelven en runtime y el Jenkinsfile no depende de qué cuenta específica se use:

Credencial en Jenkins (manual, vía UI, no por script — evito pegar el token en un comando):
- Manage Jenkins -> Credentials -> (global) -> Add Credentials
- Kind: Username with password, ID: `dockerhub-cesarbuitragorey`

Cambios al Jenkinsfile compartido (commit en `main`, merge a `dev`, se mantiene la invariante de que solo `src/logo.svg` difiere entre ramas):

```groovy
stage('Push Docker Image') {
    when { expression { env.BRANCH_NAME != null } }   // solo corre en el Multibranch, no en CD_deploy_manual
    steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-cesarbuitragorey', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
            sh """
                echo "\$DOCKER_PASS" | docker login -u "\$DOCKER_USER" --password-stdin
                docker tag ${IMAGE_NAME}:v1.0 \$DOCKER_USER/${IMAGE_NAME}:v1.0
                docker push \$DOCKER_USER/${IMAGE_NAME}:v1.0
                docker logout
            """
        }
    }
}
stage('Trigger Deploy Job') {
    when { expression { env.BRANCH_NAME != null } }
    steps {
        build job: "${DOWNSTREAM_JOB}", wait: false, propagate: false
    }
}
stage('Deploy (manual pipeline)') {
    when { expression { env.BRANCH_NAME == null } }   // CD_deploy_manual sigue desplegando directo de la imagen local
    steps { /* ... igual que antes ... */ }
}
```

`Deploy_to_main` y `Deploy_to_dev` los creé como jobs Pipeline standalone (Pipeline script inline, no "from SCM" — son chicos e independientes del repo de la app), cada uno hace `docker login` + `docker pull $DOCKER_USER/node{main,dev}:v1.0` + `docker rm -f cicd-{main,dev} || true` + `docker run -d ...`.

Importante: estos 2 jobs deben existir **antes** de que el Multibranch intente el `build job: "Deploy_to_main"` — si no, ese step falla porque el job no existe todavía.

### Incidente 1: `Deploy_to_main`/`Deploy_to_dev` fallaban con "not found" al hacer pull

Los corrí manualmente (Build Now) para probarlos, pero fallaban con `nodemain:v1.0: not found` en Docker Hub. Causa: todavía no había corrido el Multibranch con el nuevo stage de push, así que la imagen nunca se había subido. Orden correcto: primero que el Multibranch pushee, después los jobs de deploy hacen pull.

### Incidente 2: build automático de `CICD` falló por credencial faltante

El scan periódico detectó el push del Jenkinsfile y disparó un build automático (`CICD/main` build #3) **antes** de que yo terminara de crear la credencial `dockerhub-cesarbuitragorey` en Jenkins. Log: `Could not find credentials entry with ID 'dockerhub-cesarbuitragorey'`. Fix: no hay nada que arreglar en el código, solo había que re-disparar el build (`Build Now` dentro del job de cada rama, no en la página del folder `CICD` — ahí no hay botón de build, solo "Scan Multibranch Pipeline Now") una vez que la credencial ya existía.

### Incidente 3 (el interesante): dos builds concurrentes de `main` mezclaron el env — main pusheó la imagen de dev

Al re-disparar main manualmente, en algún momento quedaron 2 builds de `CICD/main` corriendo al mismo tiempo (se solapan en `<timestamp>`/`<duration>` de sus `build.xml`, confirmado). El build #5 de `main` terminó haciendo `docker build -t nodedev:v1.0`, `docker push cesarbuitrago/nodedev:v1.0` y `Scheduling project: Deploy_to_dev` — es decir, el job de la rama `main` se comportó como si fuera `dev`. El build #4 (que no se solapaba con nada) sí había resuelto todo correctamente como `main`.

Causa: Jenkins permite builds concurrentes del mismo job por default, y bajo esa concurrencia el bloque `environment` (que depende de `env.BRANCH_NAME` vía ternario) resolvió mal la rama en una de las dos ejecuciones paralelas.

No hubo daño real (el contenedor final `cicd-main` seguía corriendo `nodemain` gracias al build #4 que sí fue correcto), pero el historial de builds de `main` quedaba confuso para las capturas de evidencia, y es un bug real que puede repetirse.

Fix — agregar `disableConcurrentBuilds()` al Jenkinsfile:
```groovy
options {
    disableConcurrentBuilds()
}
```
Pusheado a `main` y mergeado a `dev`. Con esto, un segundo trigger mientras hay un build corriendo queda encolado en vez de correr en paralelo.

### Validación final del flujo completo con Docker Hub

Después del fix, un build limpio (sin solape) de cada rama:
- `CICD/main` build #6: `docker build -t nodemain:v1.0` -> push `cesarbuitrago/nodemain:v1.0` -> `Scheduling project: Deploy_to_main` -> `SUCCESS`
- `CICD/dev` build #5: `docker build -t nodedev:v1.0` -> push `cesarbuitrago/nodedev:v1.0` -> `Scheduling project: Deploy_to_dev` -> `SUCCESS`
- `Deploy_to_main` build #3 y `Deploy_to_dev` build #4: ambos `SUCCESS`, recrearon los contenedores a partir de las imágenes bajadas de Docker Hub (`docker ps` muestra `cesarbuitrago/nodemain:v1.0` y `cesarbuitrago/nodedev:v1.0` como imagen de origen, no las locales `nodemain:v1.0`/`nodedev:v1.0`)
- `curl` a :3000 y :3001 siguen devolviendo 200 después del redeploy vía registry

## 9b. Apéndice del README: revisión

Revisé los 2 items del Apéndice para ver si aplicaban:
- **GitHub API token scopes**: no aplica — esa guía es para cuando se usa un GitHub Personal Access Token / el plugin OAuth de GitHub. Nosotros autenticamos por SSH (llave privada), decisión deliberada para no pedir de más scopes de API.
- **How to add Trivy to Jenkins pipeline**: no estaba hecho, no es obligatorio (no aparece en el checklist de entregables), pero decidimos agregarlo como refuerzo de seguridad.

Agregué un stage `Security Scan` justo después de `Build Docker Image`, usando el contenedor oficial `aquasec/trivy` contra el daemon del host (mismo patrón "docker outside of docker" que el resto del pipeline, sin instalar nada extra en el filesystem de Jenkins):

```groovy
stage('Security Scan') {
    steps {
        // exit-code 0: reporta vulnerabilidades sin fallar el build. La imagen base
        // (node:7.8.0, de 2017) tiene CVEs HIGH/CRITICAL conocidos fuera del alcance
        // de este lab arreglar; el scan es informativo, no gate.
        sh "docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image --exit-code 0 --severity HIGH,CRITICAL --format table ${IMAGE_NAME}:v1.0"
    }
}
```

Pre-descargué `aquasec/trivy` en el host (`docker pull aquasec/trivy`) para que el primer build no se demore bajándola. Sin `when`, corre igual en Multibranch y en `CD_deploy_manual`.

Resultado en ambas ramas (`CICD/main` build #7, `CICD/dev` build #6, ambos `SUCCESS`):
```
Total: 1581 (HIGH: 1273, CRITICAL: 308)   # vulnerabilidades del OS base (node:7.8.0, Debian de 2017)
Total: 98 (HIGH: 89, CRITICAL: 9)          # vulnerabilidades de las dependencias npm (react-scripts@1.0.14, etc.)
```
Como se esperaba de una imagen base de 2017: muchísimos CVEs conocidos. `exit-code 0` evita que esto rompa el pipeline — arreglarlos requeriría actualizar Node/dependencias, que está fuera del alcance de este lab (la app está fijada a Node 7.8.0 a propósito).

## 9c. Skip de build/scan/push/deploy en commits de solo documentación

El usuario agregó `README.md` (con el texto del lab) e imágenes de referencia directamente al repo `cicd-pipeline` (antes solo vivían en `devops-sandbox/07-ci-cd/lab3-jenkins/`, que Jenkins ni siquiera vigila). Como `cicd-pipeline` sí es el repo que escanea el Multibranch, cualquier commit ahí —aunque sea solo un cambio de texto en el README— disparaba el pipeline completo (build, test, docker build, Trivy, push a Docker Hub, deploy). Va a pasar seguido porque también se va a sumar un `steps.md` a este repo.

Fix: nuevo stage `Detect Docs-Only Change` justo después de Checkout, que inspecciona `currentBuild.changeSets` y marca `env.DOCS_ONLY = 'true'` solo si **todos** los archivos del commit matchean el patrón de documentación (`README.md`, `steps.md`, `*.png`, `*.jpg/jpeg`). Los demás stages (Build, Test, Build Docker Image, Security Scan, Push Docker Image, Trigger Deploy Job, Deploy manual) llevan `when { expression { env.DOCS_ONLY != 'true' } }` (combinado con `allOf` donde ya había otra condición).

```groovy
stage('Detect Docs-Only Change') {
    steps {
        script {
            def changedFiles = []
            currentBuild.changeSets.each { cs ->
                cs.each { entry -> entry.affectedFiles.each { f -> changedFiles << f.path } }
            }
            def docsPattern = ~/^(README\.md|steps\.md|[^\/]+\.(png|jpe?g))$/
            env.DOCS_ONLY = (changedFiles && changedFiles.every { it ==~ docsPattern }) ? 'true' : 'false'
        }
    }
}
```

Importante: `src/logo.svg` queda **fuera** del patrón a propósito — es contenido real de la app (define el env), no documentación, así que un cambio de logo debe seguir disparando todo el pipeline normalmente.

Validado con 2 commits reales:
- Commit mixto (Jenkinsfile + README + imágenes) -> `DOCS_ONLY=false` -> corrió completo, `SUCCESS`
- Commit solo `README.md` -> `DOCS_ONLY=true` -> los 7 stages pesados salieron "skipped due to when conditional", build rápido en `SUCCESS`, contenedores `cicd-main`/`cicd-dev` sin tocar (mismo `CREATED` de antes del commit)

## 10. Entregables para el PDF

Pendiente del lado del usuario (no es código): capturas de Jenkins UI (Multibranch CICD con las 2 ramas + los 2 pipelines Deploy_to_main/dev), los Jenkinsfile (el compartido de main/dev, y los 2 scripts inline de Deploy_to_main/dev), capturas del browser en :3000 y :3001, y el código de la advanced task (ya documentado arriba). Armar el PDF y nombrarlo `Cloud_DevOps_CICD_[nombre]_[apellido].pdf`.
