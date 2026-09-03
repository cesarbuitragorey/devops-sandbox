# Teoría — EC2 con SSH Key Pair y servidor web

## Key Pairs de EC2

Un **key pair** de EC2 es un par de claves asimétricas (pública/privada) usado para autenticación SSH, alternativo/complementario a Session Manager:

- La **clave pública** queda registrada en AWS y se instala automáticamente en `~/.ssh/authorized_keys` del usuario por defecto de la AMI (ej. `ec2-user` en Amazon Linux) cuando se lanza una instancia con ese key pair asociado.
- La **clave privada** (`.pem`) se descarga **una sola vez** al crear el par (`create-key-pair`) — AWS no la guarda, así que si se pierde no hay forma de recuperarla, solo de crear un par nuevo.
- A diferencia de Session Manager (que no requiere abrir ningún puerto de entrada), SSH requiere que el Security Group permita explícitamente el puerto 22 desde el origen deseado.

## Security Group con acceso diferenciado por puerto

Este lab combina dos reglas de alcance muy distinto en el mismo Security Group:

- **Puerto 80 (HTTP) desde `0.0.0.0/0`**: el servidor web debe ser accesible públicamente, sin restricción de origen — es su propósito.
- **Puerto 22 (SSH) solo desde el IP del operador**: acceso administrativo, que debe restringirse al mínimo necesario (la propia IP pública de quien administra la instancia, no todo internet) — buena práctica de seguridad estándar para evitar exponer el puerto de gestión a cualquier atacante que escanee IPs.

## Instance Profile con `CloudWatchAgentServerPolicy`

A diferencia del rol de SSM de labs anteriores (`AmazonSSMManagedInstanceCore`, para poder *conectarse* a la instancia), este rol usa la política administrada **`CloudWatchAgentServerPolicy`**, que da permisos para que el **CloudWatch Agent** corriendo dentro de la instancia pueda publicar métricas y logs personalizados hacia CloudWatch — un propósito de observabilidad, no de conectividad.

## Apache HTTP Server vía `dnf` en Amazon Linux 2023

Amazon Linux 2023 usa `dnf` (sucesor de `yum`) como gestor de paquetes. El paquete del servidor Apache se llama `httpd` (no `apache2`, como en distribuciones basadas en Debian/Ubuntu). El flujo típico de instalación y arranque:
```bash
sudo dnf install -y httpd
sudo systemctl enable httpd
sudo systemctl start httpd
```

## Verificación con `curl -I`

El flag `-I` de `curl` pide solo los **headers** de la respuesta HTTP (sin descargar el cuerpo), útil para confirmar rápidamente el código de estado (`200 OK`) y headers como `Content-Type: text/html` sin necesidad de renderizar la página completa — la forma más directa de comprobar mediante línea de comandos que un servidor web está sirviendo contenido correctamente.
