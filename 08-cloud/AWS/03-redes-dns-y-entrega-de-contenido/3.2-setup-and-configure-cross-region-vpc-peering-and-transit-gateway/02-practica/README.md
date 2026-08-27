# Práctica — Setup and Configure Cross-Region VPC Peering and Transit Gateway

## Enunciado de la tarea

> Interconnect three VPCs in different AWS regions: A and B connect directly via VPC Peering; C connects to A and B via Transit Gateway peering.

**Recursos pre-provisionados por CloudFormation** (uno por región):

| | Region A (`us-east-1`) | Region B (`eu-west-1`) | Region C (`ap-south-1`) |
|---|---|---|---|
| VPC | `cmtr-iacp1ebx-vpc-a` (`10.0.0.0/16`) | `cmtr-iacp1ebx-vpc-b` (`10.1.0.0/16`) | `cmtr-iacp1ebx-vpc-c` (`10.2.0.0/16`) |
| Subnet | `cmtr-iacp1ebx-public-subnet-vpc-a` | `cmtr-iacp1ebx-public-subnet-vpc-b` | `cmtr-iacp1ebx-public-subnet-vpc-c` |
| Route Table | `cmtr-iacp1ebx-public-rt-a` | `cmtr-iacp1ebx-public-rt-b` | `cmtr-iacp1ebx-public-rt-c` |
| EC2 | `i-0b8ea1c1d7181c811` | `i-049958979608aa47c` | `i-0c761ec9576945f7c` |

**Entorno real usado:** sandbox AWS, cuenta `438465166519`. Todo por **CLI**, en una sola sesión de CloudShell (todos los pasos dependen de IDs generados sobre la marcha).

---

## Fase 0 — Descubrir IDs de recursos

```bash
export AWS_PAGER=""

VPC_A_ID=$(aws ec2 describe-vpcs --region us-east-1 --filters Name=tag:Name,Values=cmtr-iacp1ebx-vpc-a --query 'Vpcs[0].VpcId' --output text)
SUBNET_A_ID=$(aws ec2 describe-subnets --region us-east-1 --filters Name=tag:Name,Values=cmtr-iacp1ebx-public-subnet-vpc-a --query 'Subnets[0].SubnetId' --output text)
RT_A_ID=$(aws ec2 describe-route-tables --region us-east-1 --filters Name=tag:Name,Values=cmtr-iacp1ebx-public-rt-a --query 'RouteTables[0].RouteTableId' --output text)
IP_A=$(aws ec2 describe-instances --region us-east-1 --instance-ids i-0b8ea1c1d7181c811 --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
# (mismo patrón para VPC_B/SUBNET_B/RT_B/IP_B en eu-west-1, y VPC_C/SUBNET_C/RT_C/IP_C en ap-south-1)
```
Resultado: `VPC_A=vpc-07a86452234202ef8`, `IP_A=10.0.5.196` / `VPC_B=vpc-0eae6326597e54920`, `IP_B=10.1.5.213` / `VPC_C=vpc-00048906f0793b8df`, `IP_C=10.2.5.194`.

## Fase 1 — VPC Peering A (requester) ↔ B (accepter)

```bash
PCX_ID=$(aws ec2 create-vpc-peering-connection \
  --vpc-id $VPC_A_ID --peer-vpc-id $VPC_B_ID --peer-region eu-west-1 --region us-east-1 \
  --tag-specifications 'ResourceType=vpc-peering-connection,Tags=[{Key=Name,Value=cmtr-iacp1ebx-pcx-a-b}]' \
  --query 'VpcPeeringConnection.VpcPeeringConnectionId' --output text)

aws ec2 accept-vpc-peering-connection --vpc-peering-connection-id $PCX_ID --region eu-west-1

aws ec2 create-route --route-table-id $RT_A_ID --destination-cidr-block 10.1.0.0/16 --vpc-peering-connection-id $PCX_ID --region us-east-1
aws ec2 create-route --route-table-id $RT_B_ID --destination-cidr-block 10.0.0.0/16 --vpc-peering-connection-id $PCX_ID --region eu-west-1
```

## Fase 2 — Crear un Transit Gateway por región

```bash
TGW_A_ID=$(aws ec2 create-transit-gateway --description cmtr-iacp1ebx-tgw-a --region us-east-1 \
  --tag-specifications 'ResourceType=transit-gateway,Tags=[{Key=Name,Value=cmtr-iacp1ebx-tgw-a}]' \
  --query 'TransitGateway.TransitGatewayId' --output text)
# ídem TGW_B (eu-west-1) y TGW_C (ap-south-1)

sleep 180   # los TGW tardan varios minutos en pasar de 'pending' a 'available'
```

## Fase 3 — Adjuntar cada TGW a su VPC

```bash
ATTACH_A_ID=$(aws ec2 create-transit-gateway-vpc-attachment \
  --transit-gateway-id $TGW_A_ID --vpc-id $VPC_A_ID --subnet-ids $SUBNET_A_ID --region us-east-1 \
  --tag-specifications 'ResourceType=transit-gateway-attachment,Tags=[{Key=Name,Value=cmtr-iacp1ebx-tgw-attach-a}]' \
  --query 'TransitGatewayVpcAttachment.TransitGatewayAttachmentId' --output text)
# ídem ATTACH_B y ATTACH_C

sleep 120   # esperar 'available' en las 3 regiones (A y B tardaron más que C en este caso)
```

## Fase 4 — TGW Peering: C↔A y C↔B

```bash
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

PEER_CA_ID=$(aws ec2 create-transit-gateway-peering-attachment \
  --transit-gateway-id $TGW_C_ID --peer-transit-gateway-id $TGW_A_ID \
  --peer-account-id $ACCOUNT_ID --peer-region us-east-1 --region ap-south-1 \
  --tag-specifications 'ResourceType=transit-gateway-attachment,Tags=[{Key=Name,Value=cmtr-iacp1ebx-tgw-peer-c-a}]' \
  --query 'TransitGatewayPeeringAttachment.TransitGatewayAttachmentId' --output text)
# ídem PEER_CB hacia TGW_B (eu-west-1)

sleep 90
aws ec2 accept-transit-gateway-peering-attachment --transit-gateway-attachment-id $PEER_CA_ID --region us-east-1
aws ec2 accept-transit-gateway-peering-attachment --transit-gateway-attachment-id $PEER_CB_ID --region eu-west-1
sleep 60   # confirmar 'available' antes de seguir
```

### Incidente 1: `--peer-account-id` es obligatorio, incluso en la misma cuenta

```
aws: [ERROR]: An error occurred (ParamValidation): the following arguments are required: --peer-account-id
```
Esta versión del CLI exige el parámetro explícitamente aunque el TGW peer pertenezca a la misma cuenta que el requester — se resolvió agregando `--peer-account-id $ACCOUNT_ID` (obtenido con `sts get-caller-identity`).

### Incidente 2: `accept-transit-gateway-peering-attachment` falla si se corre demasiado pronto

```
InvalidTransitGatewayAttachmentID.NotFound: ... was deleted or does not exist.
IncorrectState: ... is in invalid state
```
A diferencia del VPC Peering (que propaga casi instantáneamente entre regiones), un TGW Peering Attachment tarda más en aparecer como `pendingAcceptance` en la región del accepter. La solución fue simplemente esperar más tiempo (~90s) antes de reintentar el `accept`.

## Fase 5 — Rutas estáticas en las route tables de los Transit Gateways

```bash
TGW_RT_A_ID=$(aws ec2 describe-transit-gateways --transit-gateway-ids $TGW_A_ID --region us-east-1 --query 'TransitGateways[0].Options.AssociationDefaultRouteTableId' --output text)
# ídem TGW_RT_B y TGW_RT_C

aws ec2 create-transit-gateway-route --transit-gateway-route-table-id $TGW_RT_A_ID --destination-cidr-block 10.2.0.0/16 --transit-gateway-attachment-id $PEER_CA_ID --region us-east-1
aws ec2 create-transit-gateway-route --transit-gateway-route-table-id $TGW_RT_B_ID --destination-cidr-block 10.2.0.0/16 --transit-gateway-attachment-id $PEER_CB_ID --region eu-west-1
aws ec2 create-transit-gateway-route --transit-gateway-route-table-id $TGW_RT_C_ID --destination-cidr-block 10.0.0.0/16 --transit-gateway-attachment-id $PEER_CA_ID --region ap-south-1
aws ec2 create-transit-gateway-route --transit-gateway-route-table-id $TGW_RT_C_ID --destination-cidr-block 10.1.0.0/16 --transit-gateway-attachment-id $PEER_CB_ID --region ap-south-1
```

## Fase 6 — Rutas en las VPC route tables hacia el Transit Gateway local

```bash
aws ec2 create-route --route-table-id $RT_A_ID --destination-cidr-block 10.2.0.0/16 --transit-gateway-id $TGW_A_ID --region us-east-1
aws ec2 create-route --route-table-id $RT_B_ID --destination-cidr-block 10.2.0.0/16 --transit-gateway-id $TGW_B_ID --region eu-west-1
aws ec2 create-route --route-table-id $RT_C_ID --destination-cidr-block 10.0.0.0/16 --transit-gateway-id $TGW_C_ID --region ap-south-1
aws ec2 create-route --route-table-id $RT_C_ID --destination-cidr-block 10.1.0.0/16 --transit-gateway-id $TGW_C_ID --region ap-south-1
```

## Fase 7 — Security Groups: nada que hacer

Al revisar los Security Groups de las 3 instancias, ya venían preconfigurados por el CloudFormation del lab con reglas `-1` (todos los protocolos) permitiendo tráfico desde las subredes `/24` de las otras dos regiones — no fue necesario tocar nada aquí.

## Fase 8 — Verificación de conectividad (Session Manager + ping)

```bash
aws ssm start-session --target i-0b8ea1c1d7181c811 --region us-east-1
# dentro:
ping -c 4 10.1.5.213   # -> B, vía VPC Peering, 0% packet loss, ~68ms
ping -c 4 10.2.5.194   # -> C, vía TGW Peering, 0% packet loss, ~190ms

# repetido desde B (i-049958979608aa47c, eu-west-1):
ping -c 4 10.2.5.194   # -> C, vía TGW Peering, 0% packet loss, ~122ms
```

Las 3 rutas de conectividad (A↔B, A↔C, B↔C) confirmadas con `0% packet loss`.
