# Importamos el módulo 'os' nativo de Python, que nos permite interactuar con el sistema operativo
import os

# Esta condición verifica si el archivo se está ejecutando directamente desde la terminal como el programa principal
if __name__ == "__main__":
    # Imprime un mensaje en la terminal avisando que se iniciará la creación del entorno de Python 2
    print("Creando entorno virtual para Python 2...")

    # Ejecuta en la consola del sistema el comando de pyenv para crear un entorno virtual basado en Python 2.7.18 llamado 'venv-python2'
    os.system("pyenv virtualenv 2.7.18 venv-python2")

    # Imprime un mensaje en la terminal avisando que se iniciará la creación del entorno de Python 3
    print("Creando entorno virtual para Python 3...")

    # Ejecuta en la consola el comando de pyenv para crear un entorno virtual basado en Python 3.9.6 llamado 'venv-python3'
    os.system("pyenv virtualenv 3.9.6 venv-python3")

    # Imprime un salto de línea (\n) seguido de un encabezado para mostrar los resultados
    print("\nLista de versiones actualizadas:")

    # Ejecuta en la consola el comando 'pyenv versions' para listar todos los entornos y versiones de Python instaladas actualmente
    os.system("pyenv versions")