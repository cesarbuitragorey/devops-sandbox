# Resultados — Creating and Configuring Amazon RDS MySQL

**Estado:** ✅ Tarea completada y verificada por la plataforma (3/3 checks aprobados)

## Resumen de los recursos configurados

| Recurso | Configuración |
|---|---|
| Security Group EC2 | `cmtr-iacp1ebx-ec2_sg` (`sg-098676da7f07b6b30`) |
| Security Group RDS | `cmtr-iacp1ebx-rds_sg`, ingreso 3306 desde el SG de EC2 |
| Instancia RDS | `cmtr-iacp1ebx-rds`, engine `mysql`, subnet group `...-privatedbsubnetgroup-0nsu9wk5wkbl`, `PubliclyAccessible: false`, sin cifrado |
| Instancia EC2 | `cmtr-iacp1ebx-ec2` (`i-09654c32b8d36ccc1`), `t3.micro`, perfil `cmtr-iacp1ebx-ssm_instance_profile`, VPC `vpc-0deb2ae2a63420b59` |
| Endpoint RDS | `cmtr-iacp1ebx-rds.chg0igkqeaan.eu-west-1.rds.amazonaws.com` |

## Verificación automática de la plataforma

1. **EC2 Instance correct** ✅ — nombre, tipo, instance profile y VPC correctos
2. **RDS Instance correct** ✅ — engine `mysql`, subnet group correcto, `PubliclyAccessible: false`
3. **Conexión a la base de datos establecida** ✅ — `mysql -u admin_iacp1ebx` desde la instancia EC2 lista las bases del servidor (`admin_iacp1ebx`, `rds_superuser_role`, `mysql.infoschema`, `mysql.session`, `mysql.sys`, `rdsadmin`)

## Recursos

Al finalizar se usó el botón **"Destroy Resources"** de la plataforma.
