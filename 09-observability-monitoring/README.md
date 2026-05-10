# 🚀 Local Observability Sandbox

Este proyecto despliega un entorno completo de monitoreo y observabilidad utilizando **Docker Compose**. Incluye una aplicación de microservicios ligera para simular tráfico real y un stack de monitoreo profesional.

## 🛠️ Componentes del Stack


| Herramienta | Rol | Acceso Local |
| :--- | :--- | :--- |
| **Podinfo** | Aplicación de tienda (Frontend/API) | [http://localhost:8081](http://localhost:8081) |
| **Prometheus** | Base de datos de series temporales | [http://localhost:9090](http://localhost:9090) |
| **Grafana** | Visualización y Dashboards | [http://localhost:3000](http://localhost:3000) |
| **Generador** | Simulador de tráfico (Wget loop) | *Background* |

## 📋 Requisitos Previos

*   Docker Desktop con **WSL2** activado.
*   Docker Compose instalado.
*   (Opcional) Edición del archivo `hosts` para nombres personalizados:
    ```text
    127.0.0.1 tiendahost grafanahost prometheushost
    ```

## 🚀 Despliegue Rápido

1.  **Clonar/Preparar carpeta:**
    ```bash
    mkdir demo-monitoreo && cd demo-monitoreo
    ```

2.  **Levantar el stack:**
    ```bash
    docker-compose up -d
    ```

3.  **Verificar estado:**
    ```bash
    docker-compose ps
    ```

## 📊 Configuración de Monitoreo

### 1. Vincular Prometheus en Grafana
*   Acceder a Grafana (`admin`/`admin`).
*   Ir a **Connections > Data Sources > Add data source**.
*   Seleccionar **Prometheus**.
*   URL: `http://prometheus:9090`
*   Click en **Save & Test**.

### 2. Queries Principales (PromQL)

*   **Peticiones por Segundo (RPS):**
    `rate(http_requests_total{job="tienda-ligera"}[1m])`
*   **Latencia Promedio:**
    `rate(http_request_duration_seconds_sum[1m]) / rate(http_request_duration_seconds_count[1m])`
*   **Uso de RAM:**
    `go_memstats_alloc_bytes{job="tienda-ligera"}`

## 🧪 Pruebas de Carga
El servicio `generador` realiza peticiones automáticas. Para generar picos de tráfico manuales, refresca repetidamente [http://localhost:8081](http://localhost:8081) o ejecuta:
```bash
docker exec -it generador_trafico sh -c "while true; do wget -qO- http://tienda-demo:9898; done"
```

## 🧹 Limpieza
Para detener y borrar todos los recursos:
```bash
docker-compose down
```
