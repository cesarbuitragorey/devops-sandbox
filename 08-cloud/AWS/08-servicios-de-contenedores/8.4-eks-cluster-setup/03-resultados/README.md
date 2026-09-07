# Resultados — EKS Cluster Setup (WordPress + MySQL + phpMyAdmin en EKS)

**Estado:** ✅ Tarea completada y verificada por la plataforma (14/14 checks aprobados) — el lab más extenso del bootcamp hasta la fecha.

## Resumen de los recursos configurados

| Recurso | Configuración |
|---|---|
| Cluster EKS | `cmtr-iacp1ebx-eks-cluster`, `ACTIVE`, 1.31, 2 nodos en subnets privadas |
| Addons | `aws-ebs-csi-driver`, `snapshot-controller`, `eks-pod-identity-agent` (todos `ACTIVE`) |
| OIDC | Asociado al cluster (IRSA habilitado) |
| AWS Load Balancer Controller | `kube-system`, 2 réplicas, IRSA propio |
| External Secrets Operator | `external-secrets`, 1 réplica, IRSA propio |
| Secret `mysql` | Namespace `wordpress`, `SecretSynced`, 4 keys correctas |
| MySQL | StatefulSet `mysql` (imagen `mysql:9`), 1 réplica, EBS gp3 10Gi estático |
| WordPress | Deployment 2 réplicas |
| phpMyAdmin | Deployment 1 réplica + nginx-proxy |
| Ingress | ALB internet-facing, target-type `ip`, rutas `/pma/` y `/` |
| VolumeSnapshotClass | `ebs-snapclass`, driver `ebs.csi.aws.com`, `Delete` |
| CronJob | `cmtr-iacp1ebx-cj`, `0 0 * * *`, probado exitosamente con Job manual |

## Verificación automática de la plataforma (14 checks)

1. Cluster EKS `ACTIVE` ✅
2. 2 nodos worker presentes ✅
3. Addons requeridos activos ✅
4. AWS Load Balancer Controller corriendo en `kube-system` ✅
5. External Secrets Operator corriendo en `external-secrets` ✅
6. External secret `mysql` sincronizado ✅
7. StatefulSet MySQL 9.x corriendo ✅
8. Deployment WordPress con 2 réplicas ✅
9. Deployment phpMyAdmin corriendo ✅
10. Ingress ALB internet-facing existe ✅
11. Página de WordPress accesible vía el ALB ✅
12. Página de phpMyAdmin accesible vía `/pma` ✅
13. CronJob programado a medianoche existe ✅
14. VolumeSnapshot creado exitosamente al ejecutar el CronJob (confirmado como snapshot EBS real en AWS) ✅

## Incidentes clave resueltos

- **eksctl/helm no preinstalados** → instalados manualmente en `~/bin`.
- **IRSA atado a un service account específico** → no se puede reutilizar el mismo rol IAM entre namespaces distintos; se creó un rol dedicado por namespace.
- **Auto-discovery de subnets del ALB Controller falla** (policy oficial sin `ec2:DescribeRouteTables` + subnets sin tags) → subnets especificadas explícitamente vía anotación.
- **Health check de ALB rechaza el `302` de WordPress** → `success-codes: 200-399`.

## Recursos

Al finalizar se usó el botón **"Destroy Resources"** de la plataforma.
