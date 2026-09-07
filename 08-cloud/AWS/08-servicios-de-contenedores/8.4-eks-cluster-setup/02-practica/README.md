# Práctica — EKS Cluster Setup (WordPress + MySQL + phpMyAdmin en EKS)

## Enunciado de la tarea

> Deploy WordPress on EKS with ALB ingress, MySQL and phpMyAdmin, using External Secrets Operator for credentials, EBS for persistence, and a nightly CronJob to snapshot the MySQL volume.

**Región:** `eu-west-1` — Cuenta `396608813306`

**Infraestructura pre-creada:** stack CloudFormation `cmtr-iacp1ebx-stack` con VPC `vpc-0c5d9ac83167c7e22` (subnets privadas `subnet-0b2f339b4b753c57a`/eu-west-1a y `subnet-02c275ef942e5df2d`/eu-west-1b; públicas `subnet-07920178e2fc7be83`/eu-west-1a y `subnet-0a4aae1433a3862e3`/eu-west-1b) y secret de Secrets Manager `cmtr-iacp1ebx-secret` (keys: `root_password`, `database`, `user`, `password`).

**Entorno real usado:** CLI local (Git Bash), con `eksctl` y `helm` instalados manualmente (no venían preinstalados).

---

## Movimiento 0 — Instalar herramientas faltantes

```bash
curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Windows_amd64.zip" -o /tmp/eksctl.zip
unzip -o /tmp/eksctl.zip -d ~/bin

curl -sL "https://get.helm.sh/helm-v3.16.4-windows-amd64.zip" -o /tmp/helm.zip
unzip -o /tmp/helm.zip -d /tmp/helm-extract
cp /tmp/helm-extract/windows-amd64/helm.exe ~/bin/
```

## Movimiento 1 — Cluster EKS con 2 nodos en subnets privadas + addons

```yaml
# eks-cluster.yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
metadata:
  name: cmtr-iacp1ebx-eks-cluster
  region: eu-west-1
  version: "1.31"
vpc:
  id: vpc-0c5d9ac83167c7e22
  subnets:
    private:
      eu-west-1a: { id: subnet-0b2f339b4b753c57a }
      eu-west-1b: { id: subnet-02c275ef942e5df2d }
    public:
      eu-west-1a: { id: subnet-07920178e2fc7be83 }
      eu-west-1b: { id: subnet-0a4aae1433a3862e3 }
iam:
  withOIDC: true
managedNodeGroups:
  - name: ng-private
    instanceType: t3.medium
    desiredCapacity: 2
    minSize: 2
    maxSize: 2
    privateNetworking: true
    subnets: [subnet-0b2f339b4b753c57a, subnet-02c275ef942e5df2d]
addons:
  - name: eks-pod-identity-agent
  - name: aws-ebs-csi-driver
  - name: snapshot-controller
```
```bash
eksctl create cluster -f eks-cluster.yaml   # ~18 minutos
```
El OIDC provider quedó asociado automáticamente (`withOIDC: true`); se confirmó con `eksctl utils associate-iam-oidc-provider --approve` (idempotente, reportó "already associated").

## Movimiento 2 — AWS Load Balancer Controller (IRSA + Helm)

```bash
curl -o iam-policy-lbc.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.10.0/docs/install/iam_policy.json
aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy-iacp1ebx --policy-document file://iam-policy-lbc.json

eksctl create iamserviceaccount \
  --cluster cmtr-iacp1ebx-eks-cluster --namespace kube-system --name aws-load-balancer-controller \
  --attach-policy-arn arn:aws:iam::396608813306:policy/AWSLoadBalancerControllerIAMPolicy-iacp1ebx \
  --approve --region eu-west-1

helm repo add eks https://aws.github.io/eks-charts && helm repo update
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=cmtr-iacp1ebx-eks-cluster --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller --set region=eu-west-1 --set vpcId=vpc-0c5d9ac83167c7e22
```

## Movimiento 3 — External Secrets Operator (IRSA + Helm)

```bash
kubectl create namespace external-secrets

cat > eso-iam-policy.json << 'EOF'
{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":["secretsmanager:GetSecretValue","secretsmanager:DescribeSecret"],"Resource":"arn:aws:secretsmanager:eu-west-1:396608813306:secret:cmtr-iacp1ebx-secret-LwBOP9"}]}
EOF
aws iam create-policy --policy-name ExternalSecretsIAMPolicy-iacp1ebx --policy-document file://eso-iam-policy.json

eksctl create iamserviceaccount \
  --cluster cmtr-iacp1ebx-eks-cluster --namespace external-secrets --name external-secrets \
  --attach-policy-arn arn:aws:iam::396608813306:policy/ExternalSecretsIAMPolicy-iacp1ebx \
  --approve --region eu-west-1

helm repo add external-secrets https://charts.external-secrets.io && helm repo update
helm install external-secrets external-secrets/external-secrets \
  -n external-secrets --set serviceAccount.create=false --set serviceAccount.name=external-secrets --set installCRDs=true
```

## Incidente: trust policy de IRSA atada a un solo namespace/service-account

Reutilizar el rol IAM de `external-secrets` (namespace `external-secrets`) anotándolo en un service account del namespace `wordpress` falló:
```
AccessDenied: Not authorized to perform sts:AssumeRoleWithWebIdentity
```
**Causa**: la trust policy generada por `eksctl create iamserviceaccount` incluye una condición sobre el claim `sub` del JWT (`system:serviceaccount:external-secrets:external-secrets`) — no coincide con `system:serviceaccount:wordpress:external-secrets-sa`. **Fix**: crear un rol IRSA dedicado para el namespace `wordpress`:
```bash
eksctl create iamserviceaccount \
  --cluster cmtr-iacp1ebx-eks-cluster --namespace wordpress --name external-secrets-sa \
  --attach-policy-arn arn:aws:iam::396608813306:policy/ExternalSecretsIAMPolicy-iacp1ebx \
  --override-existing-serviceaccounts --approve --region eu-west-1
```
Tras esto, la `SecretStore` pasó a `Valid` (con un breve delay por caché de credenciales fallidas).

## Movimiento 4 — SecretStore + ExternalSecret

```bash
kubectl create namespace wordpress
kubectl apply -f eso-wordpress.yaml   # ServiceAccount + SecretStore + ExternalSecret "mysql"
```
Mapeo de propiedades del secret de Secrets Manager a las keys esperadas por MySQL/WordPress: `root_password→MYSQL_ROOT_PASSWORD`, `database→MYSQL_DATABASE`, `user→MYSQL_USER`, `password→MYSQL_PASSWORD`.

## Movimiento 5 — MySQL 9 StatefulSet con EBS estático

```bash
aws ec2 create-volume --volume-type gp3 --size 10 --availability-zone eu-west-1a --region eu-west-1
# vol-07bf43efd986a0c0e

kubectl apply -f mysql.yaml   # StorageClass gp3 + PV (nodeAffinity eu-west-1a) + PVC + Service headless + StatefulSet (mysql:9)
```

## Movimiento 6 — phpMyAdmin + nginx reverse-proxy

```bash
kubectl apply -f phpmyadmin.yaml   # Deployment phpmyadmin + Service + ConfigMap nginx + Deployment nginx-proxy + Service
```
El ConfigMap de nginx reescribe `/pma/` → `/` y hace proxy hacia `http://phpmyadmin.wordpress.svc.cluster.local:80`, propagando `Host`/`X-Forwarded-*`.

## Movimiento 7 — WordPress Deployment (2 réplicas)

```bash
kubectl apply -f wordpress.yaml
```
Variables `WORDPRESS_DB_USER`/`_PASSWORD`/`_NAME` mapeadas individualmente desde el secret `mysql` (los nombres de key no coinciden 1:1 con las variables que espera la imagen oficial de WordPress, así que no basta un `envFrom` genérico).

## Movimiento 8 — Ingress ALB

```bash
kubectl apply -f ingress.yaml   # scheme internet-facing, target-type ip, /pma/→nginx-proxy, /→wordpress
```

### Incidente: Ingress sin `ADDRESS` — auto-discovery de subnets falla

```
couldn't auto-discover subnets: ... AccessDenied: ... ec2:DescribeRouteTables
```
La policy oficial descargada de GitHub no incluye `ec2:DescribeRouteTables`, y las subnets pre-existentes no tienen los tags `kubernetes.io/role/elb`. **Fix**: especificar las subnets públicas explícitamente:
```yaml
alb.ingress.kubernetes.io/subnets: subnet-07920178e2fc7be83,subnet-0a4aae1433a3862e3
```
Tras esto, el ALB se creó normalmente.

## Movimiento 9 — Ajustes finales: health check y PMA_ABSOLUTE_URI

```bash
ALB_DNS="k8s-wordpres-wordpres-3e2e4be287-1087064196.eu-west-1.elb.amazonaws.com"
kubectl patch ingress wordpress-ingress -n wordpress --type merge \
  -p "{\"metadata\":{\"annotations\":{\"alb.ingress.kubernetes.io/success-codes\":\"200-399\"}}}"
kubectl set env deployment/phpmyadmin -n wordpress PMA_ABSOLUTE_URI="http://$ALB_DNS/pma/"
```
`200-399` acomoda el `302` inicial de WordPress (redirección al instalador).

## Movimiento 10 — VolumeSnapshotClass, RBAC y CronJob

```bash
kubectl apply -f snapshotclass.yaml   # VolumeSnapshotClass ebs-snapclass (cluster-scoped, sin namespace)
kubectl apply -f rbac.yaml            # ServiceAccount + Role + RoleBinding (scale + volumesnapshots)
kubectl apply -f cronjob.yaml         # CronJob cmtr-iacp1ebx-cj, 0 0 * * *
```
El script del CronJob: escala wordpress/phpmyadmin/mysql a 0 → espera con `kubectl wait --for=delete pod -l app=mysql` → crea un `VolumeSnapshot` con nombre timestamped → reescala mysql a 1, wordpress a 2, phpmyadmin a 1.

## Verificación

```bash
kubectl create job --from=cronjob/cmtr-iacp1ebx-cj --namespace=wordpress test-job-$(date +%s)
```
El Job de prueba completó exitosamente (`Complete 1/1`), el `VolumeSnapshot` pasó a `READYTOUSE: true`, y los 3 componentes volvieron a su conteo de réplicas original. `curl` contra el DNS del ALB confirmó `302` en `/` (WordPress) y `200` en `/pma/` (phpMyAdmin vía nginx-proxy).
