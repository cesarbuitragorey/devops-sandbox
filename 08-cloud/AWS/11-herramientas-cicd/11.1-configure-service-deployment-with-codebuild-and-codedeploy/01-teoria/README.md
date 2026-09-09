# Teoría — Configure Service Deployment with CodeBuild and CodeDeploy

## Dos pipelines de artefactos separados: CodeBuild → ECR, y CodeDeploy → EC2

Este lab combina dos flujos de despliegue distintos que comparten el mismo destino final (la instancia EC2), pero por caminos diferentes:
- **CodeBuild** empaqueta código fuente (`Dockerfile` + `buildspec.yml`) desde S3, construye una imagen Docker, y la publica en **ECR** — el artefacto resultante es la imagen del contenedor.
- **CodeDeploy** empaqueta scripts de despliegue (`appspec.yml` + scripts `.sh`) desde S3, y orquesta su ejecución **dentro** de la instancia EC2 (vía el agente de CodeDeploy) — el artefacto resultante es la aplicación corriendo.
Ninguno de los dos construye ni despliega directamente al otro: CodeDeploy no sabe nada de Docker por sí mismo, simplemente ejecuta los scripts que el propio `appspec.yml` le indica (y esos scripts son los que hacen `docker pull`/`docker run`).

## El agente de CodeDeploy no viene preinstalado en una AMI genérica

A diferencia de EC2 Systems Manager (SSM), cuyo agente ya viene preinstalado en las AMIs oficiales de Amazon Linux, **CodeDeploy requiere su propio agente** (`codedeploy-agent`), que debe instalarse explícitamente en la instancia (`wget` del instalador regional + `./install auto`) antes de que cualquier deployment pueda dirigirse a ella. Sin el agente corriendo, CodeDeploy simplemente no encuentra "instancias saludables" para desplegar, y falla con `HEALTH_CONSTRAINTS` — un error genérico que no indica la causa raíz real.

## El agente de CodeDeploy usa las credenciales de la instancia (rol IAM), no un rol separado de CodeDeploy

Aunque existe un rol IAM dedicado para el **servicio** CodeDeploy (usado para orquestar el deployment y llamar a la API de EC2/Auto Scaling), las acciones que ocurren **dentro** de la instancia — descargar el bundle de S3, autenticar contra ECR — las realiza el agente de CodeDeploy usando el **rol de instancia EC2** (vía credenciales del Instance Metadata Service), no el rol de CodeDeploy. Por eso el rol de la instancia necesitó permisos adicionales de `s3:GetObject` y `ecr:GetAuthorizationToken`/`ecr:BatchGetImage` que no tenían relación directa con SSM — son permisos que el *propio código que corre en la instancia* necesita, independientemente de qué servicio orquestó su ejecución.

## Cambios de política IAM no se reflejan instantáneamente en un rol ya asumido

Cuando un rol IAM se modifica (se le adjunta una nueva policy) mientras una instancia ya tiene credenciales activas obtenidas de ese rol, el proceso que las cacheó (aquí, el `codedeploy-agent`) puede seguir usando las credenciales viejas hasta su próxima renovación automática. Reiniciar el proceso/servicio que mantiene esas credenciales en memoria (`systemctl restart codedeploy-agent`) fuerza una nueva obtención de credenciales, reflejando los permisos actualizados de inmediato — evita tener que esperar el ciclo de rotación automático (~15 minutos antes de expirar).

## Encoding de la consola de Windows y logs con caracteres Unicode

Ciertos comandos de AWS CLI (ej. `systemctl status`, o logs que contienen flechas `→`) devuelven texto con caracteres Unicode que la consola de Windows (codepage por defecto `cp1252`) no puede imprimir, causando `'charmap' codec can't encode character`. Ni `PYTHONIOENCODING=utf-8` ni `chcp 65001` resolvieron el problema de forma confiable en este entorno (AWS CLI v2 empaqueta su propio runtime Python vía PyInstaller, con detección de encoding que no siempre respeta esas configuraciones). La solución robusta fue filtrar el output en el origen (`tr -cd '\11\12\15\40-\176'` dentro del propio comando remoto vía SSM), garantizando que solo lleguen bytes ASCII puros al CLI local antes de intentar imprimirlos.
