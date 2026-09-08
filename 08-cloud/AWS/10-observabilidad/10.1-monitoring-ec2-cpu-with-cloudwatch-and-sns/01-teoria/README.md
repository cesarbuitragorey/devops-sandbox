# Teoría — Monitoring EC2 CPU with CloudWatch and SNS for Notification

## `ComparisonOperator`: matices entre "mayor que" y "mayor o igual que"

CloudWatch distingue explícitamente entre `GreaterThanThreshold` (estrictamente mayor) y `GreaterThanOrEqualToThreshold` (mayor o igual). Aunque el enunciado en lenguaje natural decía "greater than the threshold of 60%" (sugiriendo `>`), el checker de la plataforma exigía específicamente `GreaterThanOrEqualToThreshold` — un recordatorio de que ante ambigüedad en la redacción, conviene verificar contra el criterio de validación real en vez de asumir la interpretación literal más obvia del texto.

## UserData: se ejecuta como root, pero el checker puede exigir `sudo` explícito de todos modos

El script de `UserData` en EC2 se ejecuta automáticamente como `root` en el primer arranque (vía `cloud-init`), por lo que anteponer `sudo` a cada comando es funcionalmente redundante. Sin embargo, un checker automatizado puede validar el **contenido textual** del script (vía regex) en vez de su comportamiento real — en este lab, el patrón de validación exigía literalmente la substring `sudo dnf install`, aunque el script ya funcionaba correctamente sin `sudo`. Esto ilustra que "funciona" y "pasa la validación automatizada" no siempre son la misma condición.

## UserData no se puede modificar en una instancia ya lanzada

El atributo `UserData` de una instancia EC2 solo se ejecuta en el primer arranque, y aunque técnicamente se puede modificar el atributo de una instancia **detenida** (`stop` → `modify-instance-attribute --user-data` → `start`), esto no vuelve a ejecutar el script en la mayoría de configuraciones estándar de `cloud-init` (que solo corre `UserData` una vez, en el primer boot, salvo configuración explícita para re-ejecutar en cada arranque). La forma más simple y confiable de "corregir" un UserData incorrecto en un lab de una sola instancia es terminar y relanzar la instancia con el script corregido, en vez de intentar editarlo en caliente.

## Latencia de las métricas básicas de CloudWatch para EC2

Sin *detailed monitoring* habilitado, EC2 publica la métrica `CPUUtilization` a CloudWatch cada 5 minutos (no en tiempo real) — el `period` de una alarma normalmente se alinea a ese intervalo. Esto significa que, tras lanzar una instancia y arrancar una carga de CPU, pueden pasar varios minutos antes de que aparezca el primer datapoint relevante y la alarma tenga suficiente información para evaluar su condición (pasando de `INSUFFICIENT_DATA` a `OK`/`ALARM`).
