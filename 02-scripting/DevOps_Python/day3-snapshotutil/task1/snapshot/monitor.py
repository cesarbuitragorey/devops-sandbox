# Importamos el módulo argparse para procesar y validar argumentos por consola de comandos
import argparse
# Importamos json para convertir diccionarios de Python a cadenas de texto en formato JSON
import json
# Importamos os para interactuar con comandos del sistema operativo como limpiar pantalla
import os
# Importamos time para pausar la ejecución del programa según el intervalo definido
import time
# Importamos la clase de métricas desde nuestro submódulo interno de utilidades
from snapshot.handlers.utils import MetricsHandler

# Definimos la clase principal que controlará la ejecución del monitoreo del servidor
class SystemMonitor:
    
    # Definimos el constructor que recibe los parámetros de configuración del script
    def __init__(self, interval, filename, count):
        # Asignamos el intervalo en segundos a una propiedad de la instancia
        self.interval = interval
        # Asignamos el nombre del archivo de salida a una propiedad de la instancia
        self.filename = filename
        # Convertimos la cantidad de snapshots a entero y la guardamos en la instancia
        self.count = int(count)
        # Abrimos el archivo objetivo en modo escritura para limpiar cualquier dato previo
        with open(self.filename, "w") as file:
            # Forzamos la reducción del tamaño del archivo a cero bytes eliminando su contenido anterior
            file.truncate(0)

    # Definimos el método encargado de arrancar el bucle de captura de snapshots
    def start(self):
        # Ejecutamos un ciclo for que se repetirá exactamente el número de veces configurado en count
        for _ in range(self.count):
            # Llamamos al manejador estático para obtener el diccionario de métricas actuales
            snapshot = MetricsHandler.get_current_snapshot()
            # Convertimos el diccionario de métricas en una única línea de texto estructurada en JSON
            snapshot_json = json.dumps(snapshot)
            
            # Abrimos el archivo en modo "append" para adjuntar texto al final sin sobreescribir
            with open(self.filename, "a") as file:
                # Escribimos el JSON de la métrica seguido de un salto de línea en el archivo
                file.write(snapshot_json + "\n")
            
            # Ejecutamos un comando del sistema operativo para limpiar la consola de texto antiguo
            os.system('clear')
            # Imprimimos el JSON en la terminal usando retorno de carro para sobreescribir la misma línea
            print(snapshot_json, end="\r")
            
            # Suspendemos la ejecución del script durante los segundos definidos en el intervalo
            time.sleep(self.interval)

# Definimos la función de entrada principal que procesa la terminal y arranca el monitor
def main():
    # Inicializamos el objeto ArgumentParser definiendo una descripción básica del programa
    parser = argparse.ArgumentParser(description="System Monitor Snapshot Utility")
    # Agregamos el argumento opcional -i para definir el intervalo de tiempo entre capturas
    parser.add_argument("-i", help="Interval between snapshots in seconds", type=int, default=30)
    # Agregamos el argumento opcional -f para cambiar el nombre predeterminado del archivo JSON
    parser.add_argument("-f", help="Output file name", default="snapshot.json")
    # Agregamos el argumento opcional -n para indicar cuántos snapshots tomar en total antes de salir
    parser.add_argument("-n", help="Quantity of snapshot to output", default=20)
    # Analizamos y extraemos los argumentos pasados por la terminal mapeándolos a variables accesibles
    args = parser.parse_args()

    # Instanciamos la clase de monitoreo pasándole los parámetros limpios que ingresó el usuario
    monitor = SystemMonitor(interval=args.i, filename=args.f, count=args.n)
    # Iniciamos el bucle de captura de datos del monitor
    monitor.start()

# Validamos si este script está siendo ejecutado directamente por la terminal de comandos
if __name__ == "__main__":
    # Invocamos la función main para arrancar todo el flujo lógico del software
    main()