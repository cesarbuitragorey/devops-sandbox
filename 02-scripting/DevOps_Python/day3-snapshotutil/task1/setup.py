# Importamos setup y find_packages desde setuptools para estructurar el empaquetado del software
from setuptools import setup, find_packages

# Ejecutamos la función de configuración del paquete distributivo de Python
setup(
    # Especificamos el nombre oficial del ejecutable de la herramienta según el requerimiento
    name="snapshot",
    # Indicamos la versión actual de lanzamiento de este paquete de software
    version="1.0.0",
    # Buscamos y mapeamos de manera automática todos los directorios internos que contengan un __init__.py
    packages=find_packages(),
    # Listamos los paquetes externos de PyPI obligatorios que deben descargarse para que funcione
    install_requires=[
        # Declaramos que se requiere psutil en versiones iguales o superiores a la 5.9.0
        "psutil>=5.9.0",
    ],
    # Configuramos el mapeo de consolas para crear comandos globales del sistema operativo
    entry_points={
        # Declaramos que la palabra clave 'snapshot' en terminal llamará a la función main del monitor
        'console_scripts': [
            'snapshot=snapshot.monitor:main',
        ],
    },
)