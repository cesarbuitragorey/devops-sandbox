# Resultados — Setup and Configure Cross-Region VPC Peering and Transit Gateway

**Estado:** ✅ Tarea completada y verificada por la plataforma (31/31 checks aprobados)

## Resumen de los recursos creados

| Recurso | Region A | Region B | Region C |
|---|---|---|---|
| Transit Gateway | `tgw-02a257739002bbe43` | `tgw-02dc46f9e62c145c3` | `tgw-0fe6d13345ba62a74` |
| TGW VPC Attachment | `tgw-attach-09aa4337b2a68097c` | `tgw-attach-022fe536be5cd218e` | `tgw-attach-08d87d68ff065322e` |

| Peering | Recurso |
|---|---|
| VPC Peering A↔B | `pcx-0ecc3c2004245047f` |
| TGW Peering C↔A | `tgw-attach-04f0af7d23cc05ab2` |
| TGW Peering C↔B | `tgw-attach-0e70fe12236457303` |

## Verificación automática de la plataforma (31 checks)

Cobertura completa de la arquitectura:
- **Checks 1-3**: CIDR/región de VPC-A y VPC-B, y estado `active` de la conexión de peering.
- **Checks 4-7**: asociación de las subredes A/B a sus route tables, y las rutas del peering en ambas direcciones.
- **Checks 8-10**: exactamente **un** Transit Gateway por región (cumpliendo la advertencia del enunciado).
- **Checks 11-13**: estado `available` de los 3 Transit Gateways.
- **Checks 14, 16, 18**: los 3 VPC attachments `available` y asociados a su route table.
- **Checks 15, 17, 19-20**: los 2 TGW peering attachments (C-A y C-B) `available` y asociados correctamente, vistos desde ambos lados.
- **Checks 21-24**: las 4 rutas estáticas en las route tables de los TGW, apuntando al peering attachment correcto.
- **Checks 25-28**: las 4 rutas en las VPC route tables (A, B, C) apuntando al Transit Gateway correcto.
- **Checks 29-31**: conectividad real por `ping` entre los 3 pares de instancias (A↔B, B↔C, C↔A), `0% packet loss` en los 3 casos.

## Recursos destruidos

Al finalizar se usó el botón **"Destroy Resources"** de la plataforma para los recursos del CloudFormation (VPCs, subredes, EC2, route tables). Los recursos creados manualmente por fuera del stack (VPC Peering Connection, los 3 Transit Gateways, sus VPC attachments y los 2 TGW peering attachments) deben verificarse/eliminarse aparte si la plataforma no los limpia automáticamente, dado que no formaban parte de los "Task Resources" originales.
