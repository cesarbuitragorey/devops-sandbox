# Teoría — EKS Cluster Setup (WordPress + MySQL + phpMyAdmin en EKS)

Este fue el lab más extenso del bootcamp: un stack completo de Kubernetes en EKS con IRSA, External Secrets, almacenamiento persistente, Ingress ALB, y automatización de snapshots vía CronJob.

## IRSA (IAM Roles for Service Accounts) vs. Pod Identity

Dos mecanismos distintos para dar permisos de AWS a pods, ambos usados en este lab:
- **IRSA** (AWS Load Balancer Controller, External Secrets Operator): requiere un **OIDC identity provider** asociado al cluster (`eksctl utils associate-iam-oidc-provider`). El rol IAM tiene una trust policy con una condición sobre el claim `sub` del JWT del service account (`system:serviceaccount:<namespace>:<nombre-exacto>`) — el rol queda atado a un **service account específico en un namespace específico**. Por eso reutilizar el mismo rol IAM entre namespaces distintos falla con `AccessDenied: Not authorized to perform sts:AssumeRoleWithWebIdentity` (el `sub` del JWT no coincide con la condición del trust policy).
- **Pod Identity** (EBS CSI Driver): mecanismo más nuevo y simple, vía el addon `eks-pod-identity-agent` — no requiere OIDC ni trust policies con condiciones de `sub`; usa asociaciones directas (`eks create-pod-identity-association`) entre un rol y un `namespace/service-account`.

## Un rol IRSA por namespace, no uno compartido

Cuando el mismo tipo de componente (aquí, un service account para ESO) debe operar en dos namespaces distintos (`external-secrets` para el propio operador, `wordpress` para el `SecretStore`), cada namespace necesita **su propio rol IAM** con una trust policy que apunte exactamente a `system:serviceaccount:<su-namespace>:<su-service-account>` — no basta con anotar el mismo rol ARN en un service account de otro namespace, aunque el nombre del rol "suene" reutilizable.

## Auto-discovery de subnets del AWS Load Balancer Controller

Por defecto, el controller intenta descubrir automáticamente qué subnets usar para el ALB inspeccionando tags (`kubernetes.io/role/elb`, `kubernetes.io/role/internal-elb`) y rutas (`ec2:DescribeRouteTables`). En una VPC **pre-existente** (no creada por eksctl) sin esos tags, y con una policy IAM oficial que no incluye `ec2:DescribeRouteTables`, el auto-discovery falla silenciosamente (el Ingress se queda sin `ADDRESS`). La solución robusta es especificar las subnets explícitamente vía la anotación `alb.ingress.kubernetes.io/subnets`, evitando por completo la necesidad de auto-discovery (y del permiso IAM que le falta a la policy oficial descargada).

## Health checks de ALB y redirecciones de aplicación

WordPress responde `302` en su primera carga (redirección al instalador) — el health check por defecto del target group de un ALB solo acepta `200`, lo que marcaría el target como unhealthy pese a que la aplicación funciona correctamente. La anotación `alb.ingress.kubernetes.io/success-codes: "200-399"` amplía el rango aceptado para incluir redirects legítimos.

## Aprovisionamiento estático de EBS (PV/PVC) vs. dinámico

En vez de dejar que el `StorageClass` aprovisione un volumen nuevo automáticamente (`volumeClaimTemplates` en un StatefulSet), este lab pide crear el volumen EBS manualmente y enlazarlo vía un `PersistentVolume` con `nodeAffinity` explícito a la AZ del volumen — necesario porque un volumen EBS vive en una única AZ, y el pod que lo monta debe programarse en un nodo de esa misma AZ. Sin el `nodeAffinity`, el scheduler podría intentar colocar el pod en el nodo equivocado y el montaje fallaría.

## Por qué el CronJob necesita RBAC propio

Un `CronJob` que ejecuta `kubectl scale` y crea `VolumeSnapshot` corre con la identidad de su propio `ServiceAccount` (no la del usuario que lo creó) — sin un `Role`/`RoleBinding` que otorgue permisos sobre `deployments/scale`, `statefulsets/scale` y `volumesnapshots`, el Job fallaría con `Forbidden` al ejecutar esas acciones dentro del cluster, sin importar qué permisos IAM tenga a nivel de AWS (son capas de autorización completamente separadas: RBAC de Kubernetes vs. IAM de AWS).

## Probar el CronJob sin esperar a medianoche

`kubectl create job --from=cronjob/<nombre>` crea un `Job` puntual con exactamente la misma `jobTemplate` del CronJob, permitiendo validar la lógica completa (escalar a 0, esperar, snapshot, reescalar) sin depender del schedule real — el snapshot resultante (verificado por AWS como un `EBS Snapshot` real, no solo el objeto `VolumeSnapshot` de Kubernetes) confirma que toda la cadena CSI funciona de punta a punta.
