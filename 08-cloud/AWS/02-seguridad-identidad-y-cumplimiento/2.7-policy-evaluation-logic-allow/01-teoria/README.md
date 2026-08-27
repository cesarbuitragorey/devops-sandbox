# Teoría — Policy Evaluation Logic (Allow)

## El caso opuesto al lab 2.6

En [2.6 (Deny)](../2.6-policy-evaluation-logic-deny/01-teoria/README.md) el foco era: un `Deny` explícito gana sobre un `Allow` explícito, sin importar de qué política venga. Este lab (2.7) ilustra la otra mitad de la lógica de evaluación: **la ausencia de un `Allow` es, por sí sola, suficiente para denegar** — no hace falta ningún `Deny` explícito para bloquear acceso a un recurso.

```
¿Hay algún Deny explícito aplicable?         → si SÍ: Deny (fin de la evaluación)
¿Hay al menos un Allow explícito aplicable?  → si SÍ: Allow
En cualquier otro caso                        → Deny implícito (por defecto)
```

## Aislamiento entre recursos por alcance de `Resource`

Cuando una resource-based policy (bucket policy) especifica el `Resource` como el ARN de un bucket concreto (y sus objetos), esa política **no otorga nada** sobre ningún otro bucket — ni falta hacerlo explícito con un `Deny` para el segundo bucket. Simplemente, al no existir ningún statement `Allow` que mencione ese otro bucket (ni en la identity-based policy del rol, ni en ninguna resource-based policy), la regla de "deny implícito por defecto" se encarga de bloquear el acceso.

Esto es relevante en el diseño de políticas: **es más seguro por defecto** dejar que la ausencia de Allow haga el trabajo, en vez de tener que acordarse de agregar un Deny explícito por cada recurso al que no se debe acceder — hay que enumerar los Deny, pero solo hay que ser preciso con el alcance (`Resource`) de los Allow que sí se otorgan.

## Separación de responsabilidades: qué va en la identity-based policy vs. la resource-based policy

Este lab combina intencionalmente dos mecanismos distintos para dos necesidades distintas:

- **Identity-based policy (inline, en el rol)**: `s3:ListAllMyBuckets` — una acción de alcance *global* (cuenta completa), que no tiene sentido limitar por bucket porque no opera sobre un bucket específico.
- **Resource-based policy (en el bucket)**: `s3:GetObject`, `s3:PutObject`, `s3:ListBucket` — acciones de alcance *por bucket*, donde SÍ importa limitar el `Resource` (y aquí también el `Principal`, para no abrir el bucket a "cualquiera") a un bucket puntual.

Poner `ListAllMyBuckets` en la política del bucket no tendría sentido (esa acción no pertenece a ningún bucket en particular), y poner `GetObject`/`PutObject`/`ListBucket` sin acotar el bucket en la política del rol sería exactamente el error que este lab busca evitar — permitiría acceso a *todos* los buckets, no solo al indicado.
