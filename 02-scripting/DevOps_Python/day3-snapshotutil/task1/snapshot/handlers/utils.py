# Importamos el módulo time para trabajar con marcas de tiempo (timestamps)
import time
# Importamos psutil para acceder a las métricas de hardware del sistema servidor
import psutil

# Definimos la clase encargada de recolectar y dar formato a las métricas del sistema
class MetricsHandler:
    
    # Definimos un método estático ya que no requiere instanciar atributos de la clase
    @staticmethod
    def get_current_snapshot():
        # Inicializamos el contador para el total de procesos del sistema
        total_tasks = 0
        # Inicializamos el contador para los procesos en estado de ejecución (running)
        running = 0
        # Inicializamos el contador para los procesos en estado de espera/sueño (sleeping)
        sleeping = 0
        # Inicializamos el contador para los procesos que están detenidos (stopped)
        stopped = 0
        # Inicializamos el contador para los procesos en estado huérfano o zombi (zombie)
        zombie = 0

        # Iteramos sobre todos los procesos activos del sistema solicitando solo su estado
        for proc in psutil.process_iter(['status']):
            # Abrimos un bloque try para manejar posibles excepciones si un proceso se cierra en medio del ciclo
            try:
                # Extraemos el string del estado del proceso actual
                status = proc.info['status']
                # Incrementamos en 1 el contador total de tareas encontradas
                total_tasks += 1
                # Verificamos si el estado del proceso equivale a la constante RUNNING de psutil
                if status == psutil.STATUS_RUNNING:
                    # Incrementamos el contador de procesos en ejecución
                    running += 1
                # Verificamos si el estado del proceso equivale a la constante SLEEPING de psutil
                elif status == psutil.STATUS_SLEEPING:
                    # Incrementamos el contador de procesos en espera
                    sleeping += 1
                # Verificamos si el estado del proceso equivale a la constante STOPPED de psutil
                elif status == psutil.STATUS_STOPPED:
                    # Incrementamos el contador de procesos detenidos
                    stopped += 1
                # Verificamos si el estado del proceso equivale a la constante ZOMBIE de psutil
                elif status == psutil.STATUS_ZOMBIE:
                    # Incrementamos el contador de procesos zombi
                    zombie += 1
            # Capturamos la excepción en caso de que el proceso ya no exista o no tengamos permisos de lectura
            except (psutil.NoSuchProcess, psutil.AccessDenied):
                # Continuamos con el siguiente proceso de la lista sin romper el bucle
                continue

        # Obtenemos los porcentajes de uso de CPU divididos por categorías del sistema
        cpu_times = psutil.cpu_times_percent(interval=None)
        
        # Obtenemos el estado de uso de la memoria RAM del sistema
        mem = psutil.virtual_memory()
        # Obtenemos el estado de uso de la memoria de intercambio Swap del sistema
        swap = psutil.swap_memory()

        # Retornamos el diccionario formateado con la estructura exacta JSON solicitada
        return {
            # Sub-diccionario con el conteo clasificado de tareas
            "Tasks": {
                # Guardamos el total de procesos contados
                "total": total_tasks,
                # Guardamos la cantidad de procesos en ejecución
                "running": running,
                # Guardamos la cantidad de procesos en espera
                "sleeping": sleeping,
                # Guardamos la cantidad de procesos detenidos
                "stopped": stopped,
                # Guardamos la cantidad de procesos zombi
                "zombie": zombie
            },
            # Sub-diccionario con los porcentajes de uso de CPU
            "%CPU": {
                # Guardamos el porcentaje de CPU usado por tareas de usuario
                "user": cpu_times.user,
                # Guardamos el porcentaje de CPU usado por tareas del sistema kernel
                "system": cpu_times.system,
                # Guardamos el porcentaje de CPU que se encuentra inactivo
                "idle": cpu_times.idle
            },
            # Sub-diccionario con la memoria RAM medida en KiB (Bytes divididos por 1024)
            "KiB Mem": {
                # Convertimos a entero y guardamos la memoria RAM total en KiB
                "total": int(mem.total / 1024),
                # Convertimos a entero y guardamos la memoria RAM disponible como libre en KiB
                "free": int(mem.available / 1024),
                # Convertimos a entero y guardamos la memoria RAM actualmente en uso en KiB
                "used": int(mem.used / 1024)
            },
            # Sub-diccionario con la memoria Swap medida en KiB
            "KiB Swap": {
                # Convertimos a entero y guardamos el total de espacio Swap en KiB
                "total": int(swap.total / 1024),
                # Convertimos a entero y guardamos el espacio Swap libre en KiB
                "free": int(swap.free / 1024),
                # Convertimos a entero y guardamos el espacio Swap usado en KiB
                "used": int(swap.used / 1024)
            },
            # Guardamos la marca de tiempo actual del sistema redondeada a entero sin decimales
            "Timestamp": int(time.time())
        }