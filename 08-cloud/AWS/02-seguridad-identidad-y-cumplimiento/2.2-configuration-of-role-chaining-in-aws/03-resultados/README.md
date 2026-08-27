# Resultados — Configuration of Role Chaining in AWS

**Estado:** ✅ Tarea completada y verificada por la plataforma (8/8 checks aprobados)

## Resumen de los recursos configurados

| Campo | Valor |
|---|---|
| Assume Role | `cmtr-iacp1ebx-iam-ar-iam_role-assume` |
| Política del assume role | Inline `allow-assume-readonly-role` → `sts:AssumeRole` acotado al ARN de `readonly_role` |
| Read-Only Role | `cmtr-iacp1ebx-iam-ar-iam_role-readonly` |
| Política del readonly role | `ReadOnlyAccess` (AWS managed) |
| Trust policy de readonly role | Principal único: ARN de `assume_role` |

## Verificación automática de la plataforma

1. **Sin acceso cross-account en `assume_role`** ✅ — `"No cross-account access detected for role: cmtr-iacp1ebx-iam-ar-iam_role-assume"`
2. **Sin acceso cross-account en `readonly_role`** ✅ — `"No cross-account access detected for role: cmtr-iacp1ebx-iam-ar-iam_role-readonly"`
3. **`assume_role` no tiene `AdministratorAccess`** ✅
4. **El test asume `assume_role` correctamente** ✅ — `arn:aws:sts::396913711198:assumed-role/cmtr-iacp1ebx-iam-ar-iam_role-assume/cloud-mentor-validation-assume-role`
5. **El test asume `readonly_role` correctamente (role chaining)** ✅ — `arn:aws:sts::396913711198:assumed-role/cmtr-iacp1ebx-iam-ar-iam_role-readonly/cloud-mentor-validation-assume-role-readonly`
6. **`readonly_role` no tiene `AdministratorAccess`** ✅
7. **`readonly_role` puede describirse a sí mismo** (acción de lectura, `iam:GetRole`) ✅
8. **Bono por uso de CLI** ✅ — coeficiente 1.0 (máximo)

## Recursos destruidos

Al finalizar se usó el botón **"Destroy Resources"** de la plataforma — los roles, políticas y trust policies configurados ya no existen fuera de este registro.
