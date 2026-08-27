# Resultados — Using AWS Managed Policies for IAM Resources

**Estado:** ✅ Tarea completada y verificada por la plataforma (3/3 checks aprobados)

## Resumen de los recursos configurados

| Rol | Política adjunta |
|---|---|
| `cmtr-iacp1ebx-iam-mp-iam_role-readonly` | `ReadOnlyAccess` (AWS managed) |
| `cmtr-iacp1ebx-iam-mp-iam_role-administrator` | `AdministratorAccess` (AWS managed) |

## Verificación automática de la plataforma

1. **Rol readonly tiene la política readonly** ✅
   ```json
   {"AttachedPolicies": [{"PolicyArn": "arn:aws:iam::aws:policy/ReadOnlyAccess", "PolicyName": "ReadOnlyAccess"}]}
   ```
2. **Rol administrator tiene la política administrator** ✅
   ```json
   {"AttachedPolicies": [{"PolicyArn": "arn:aws:iam::aws:policy/AdministratorAccess", "PolicyName": "AdministratorAccess"}]}
   ```
3. **Bono por uso de CLI** ✅ — coeficiente 1.0 (máximo)

## Recursos destruidos

Al finalizar se usó el botón **"Destroy Resources"** de la plataforma — los roles y políticas configurados ya no existen fuera de este registro.
