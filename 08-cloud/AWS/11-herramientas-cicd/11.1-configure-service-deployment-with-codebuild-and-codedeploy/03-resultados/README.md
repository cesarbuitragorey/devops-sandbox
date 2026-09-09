# Resultados — Configure Service Deployment with CodeBuild and CodeDeploy

**Estado:** ✅ Tarea completada y verificada por la plataforma (7/7 checks aprobados)

## Resumen de los recursos configurados

| Recurso | Configuración |
|---|---|
| ECR | `cmtr-iacp1ebx`, imagen `alpine-httpd` publicada |
| CodeBuild | `cmtr-iacp1ebx-project`, build `SUCCEEDED`, rol `cmtr-iacp1ebx-cb` (AdministratorAccess) |
| S3 | `cmtr-iacp1ebx-bucket-13120` (`build-source.zip`, `deploy-source.zip`) |
| EC2 | `cmtr-iacp1ebx-instance`, tag `app=alpine-httpd`, rol con SSM + S3 read + ECR read |
| CodeDeploy | App `cd-alpine-httpd`, deployment group `cd-alpine-httpd` (in-place, filtro por tag), `Deployment: Succeeded` |
| App corriendo | `curl localhost:80` → `cmtr-iacp1ebx` |

## Verificación automática de la plataforma

1. **Proyecto CodeBuild existe** ✅
2. **Repo ECR existe** ✅
3. **Build corrido y con status `SUCCEEDED`** ✅
4. **Imagen `alpine-httpd` existe en ECR** ✅
5. **Aplicación CodeDeploy existe** ✅
6. **Deployment con status `Succeeded`** ✅
7. **httpd corriendo en la instancia con tag correcto, sirve `cmtr-iacp1ebx`** ✅

## Incidentes clave (no cubiertos explícitamente por el enunciado)

1. El agente de CodeDeploy no viene preinstalado — hubo que instalarlo manualmente vía SSM antes de poder desplegar.
2. El rol de la instancia EC2 necesitó permisos adicionales de `s3:GetObject` (para que el agente descargue el bundle) y `ecr:GetAuthorizationToken`/pull (para que `install_dependencies.sh` pueda autenticarse y descargar la imagen) — permisos que van más allá de solo SSM.
3. Cambios de IAM no se reflejan en credenciales ya cacheadas por el agente — hubo que reiniciar `codedeploy-agent` tras cada cambio de política para que tomara efecto de inmediato.

## Recursos

Al finalizar se usó el botón **"Destroy Resources"** de la plataforma.
