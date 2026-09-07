# Teoría — Setup a Simple ECS Anywhere Cluster

## ¿Qué es ECS Anywhere?

ECS Anywhere extiende el plano de control de Amazon ECS para gestionar contenedores corriendo en infraestructura **fuera de AWS** — servidores on-premises, VMs locales, u otros proveedores cloud. AWS gestiona la orquestación (scheduling, definiciones de tarea, API), pero el cómputo real vive fuera de la nube de AWS. Es distinto de ECS con EC2 launch type (donde el cómputo también es de AWS) o Fargate (serverless) — aquí el usuario aporta y administra el hardware/VM.

## Prerrequisitos de una "external instance"

Para que una máquina externa pueda unirse a un cluster ECS como "container instance externa", primero debe registrarse como **instancia administrada de AWS Systems Manager (SSM)** — SSM es el mecanismo de conectividad/control subyacente (no se necesita SSH entrante ni IP pública fija del lado de AWS hacia la VM). Sobre esa base, se instalan el agente de contenedores de ECS y Docker. El script oficial de instalación (`ecs-anywhere-install-latest.sh`) automatiza los 3 pasos: agente SSM, Docker, agente ECS.

## Rol IAM `ecsExternalInstanceRole`

Es el rol que SSM asume en nombre de la instancia externa (`Principal: ssm.amazonaws.com` en la trust policy) para poder registrarla como managed instance y luego permitir que el agente ECS se comunique con la API de ECS. Requiere dos políticas administradas:
- `AmazonEC2ContainerServiceforEC2Role` — permisos para que el agente ECS interactúe con el servicio (registrar la instancia, reportar estado de tareas, etc.)
- `AmazonSSMManagedInstanceCore` — permisos base de SSM (heartbeat, ejecución de comandos, inventario)

## SSM Activation con `registration-limit`

`aws ssm create-activation --iam-role <rol> --registration-limit N` genera un par `ActivationId`/`ActivationCode` de un solo uso limitado (aquí, `N=1`) que actúa como credencial temporal de "onboarding" — la máquina externa lo usa una única vez para registrarse como managed instance (obteniendo su propio `mi-xxxxxxxx` ID permanente), tras lo cual la activación ya no es reutilizable. Es análogo a un código de invitación de un solo uso.

## Por qué WSL2 (con `systemd` habilitado) cuenta como "VM local"

El enunciado de la tarea pide explícitamente una VM local, servidor on-premises, u otra nube — no una instancia EC2 (eso sería ECS "normal", no "Anywhere"). WSL2 corre técnicamente sobre una VM ligera de Hyper-V, cumple con un SO Linux soportado (Ubuntu 22.04) y tiene salida a internet vía NAT — suficiente para que el agente SSM/ECS se comunique de forma saliente con los endpoints de AWS (ECS Anywhere no requiere conectividad entrante hacia la VM). El único requisito técnico adicional es tener `systemd` activo (el instalador gestiona los agentes como servicios `systemd`), que en versiones recientes de WSL2 puede habilitarse en `/etc/wsl.conf` con `[boot]\nsystemd=true`.
