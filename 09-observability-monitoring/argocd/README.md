Argo CD en WSL (Debian + Minikube)
Visualización gráfica del árbol de Kubernetes desde Windows
Este documento describe cómo instalar Argo CD en un clúster Kubernetes local (Minikube sobre WSL/Debian) y usarlo únicamente como interfaz gráfica para visualizar los recursos (Deployment, Service, Pod, Ingress, etc.), sin usar GitOps por el momento.

📋 Requisitos previos

Windows 10/11
WSL2 con Debian
Docker funcionando en WSL
Minikube instalado y corriendo
kubectl configurado y apuntando al clúster

Verificar clúster activo:
Shellkubectl get nodesMostrar más líneas
Debe mostrar el nodo Ready.

🚀 Instalación de Argo CD (en el clúster)
1. Crear el namespace argocd
Shellkubectl create namespace argocdMostrar más líneas

2. Instalar Argo CD (manifiestos oficiales)
Shellkubectl apply -n argocd --server-side --force-conflicts \  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yamlMostrar más líneas
Esto instala:

Argo CD API Server (UI)
Application Controller
Repo Server
Redis
CRDs (Application, AppProject, etc.)


3. Esperar a que los pods estén listos
Shellkubectl get pods -n argocd``Mostrar más líneas
Todos deben quedar en estado Running.

🧠 Uso previsto (sin GitOps)
En este laboratorio:

❌ No se usa auto‑sync
❌ No se despliega desde Git
✅ Argo CD se usa solo como visor gráfico
✅ Se usa para ver:

árbol de recursos
relaciones entre objetos
estado (Healthy / Degraded)
YAML y eventos




🌐 Acceso desde Windows (método recomendado)

⚠️ NodePort NO es fiable en WSL2
El acceso estable se hace con port‑forward.

4. Port‑forward dedicado al servicio de Argo CD
Desde WSL (Debian), ejecutar:
Shellkubectl port-forward svc/argocd-server -n argocd 8080:443Mostrar más líneas
Salida esperada:
Forwarding from 127.0.0.1:8080 -> 443
Forwarding from [::1]:8080 -> 443

⚠️ No cerrar esta terminal mientras se usa Argo CD.

5. Abrir la UI desde Windows
En el navegador de Windows:
https://localhost:8080


El aviso de certificado es normal (self‑signed).
Aceptar y continuar.


6. Credenciales iniciales
Usuario
admin

Contraseña
(obtenerla desde WSL):
Shellkubectl -n argocd get secret argocd-initial-admin-secret \  -o jsonpath="{.data.password}" | base64 -d; echo Mostrar más líneas

🌳 Qué se puede ver en la UI
Desde la interfaz gráfica de Argo CD es posible:

Ver el árbol visual completo de Kubernetes
Inspeccionar:

Deployments
ReplicaSets
Pods
Services
Ingress


Ver estado de salud
Ver YAML y eventos
Navegar relaciones entre recursos

Todo sin modificar el clúster.

⚠️ Notas importantes sobre persistencia

✅ Reiniciar Windows → NO borra Argo CD
✅ Reiniciar WSL → NO borra Argo CD
✅ minikube stop/start → NO borra Argo CD
❌ minikube delete → BORRA TODO (incluyendo Argo CD)

Argo CD vive dentro del clúster.

❌ Accesos no recomendados en WSL
Evitar en este entorno:

NodePort (no funciona bien desde Windows)
LoadBalancer
reglas netsh portproxy

El port‑forward es el método correcto y estable para labs.

✅ Resumen

Argo CD instalado dentro del clúster
Usado solo como visor gráfico
Acceso desde Windows vía kubectl port-forward
Configuración simple, segura y estable para WSL + Minikube
-----

Argo CD SIGUE gestionando el namespace demo-k8s a través de la Application demo-view.
Por eso, todo lo que borras vuelve a levantarse.
Esto es comportamiento esperado, no un bug.

🧠 Qué está pasando exactamente
La Application demo-view le dice a Argo CD:

“Asegúrate de que lo que está en Git exista siempre en Kubernetes”

Entonces:

Tú borras recursos (o el namespace demo-k8s)
Argo CD detecta que el estado real ≠ estado deseado
Argo CD recrea automáticamente todo
El namespace “resucita”

Esto se llama reconciliation loop y es el corazón de Argo CD.

✅ SOLUCIÓN CORRECTA (haz ESTO)
Como tú quieres parar definitivamente que se levanten recursos:
👉 BORRA la Application demo-view
Shellkubectl delete application demo-view -n argocdMostrar más líneas
✅ Esto:

Detiene la reconciliación
NO borra Argo CD
NO toca tu repositorio Git
Libera completamente el namespace


✅ Verificación (muy importante)
Comprueba que ya no existe ninguna Application:
Shellkubectl get applications -AMostrar más líneas
Resultado esperado:
No resources found

kubectl port-forward svc/argocd-server -n argocd 8080:443
user: admin
pass: ZI-ZGo1HXtfXCAG9
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 --decode ; echo