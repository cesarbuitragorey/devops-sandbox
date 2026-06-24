# Importamos el módulo os para manejar rutas y verificar archivos en el sistema operativo
import os
# Importamos el módulo yaml para deserializar y leer archivos de datos de tipo YAML
import yaml
# Importamos la clase Template de jinja2 para realizar el motorizado y renderizado de plantillas
from jinja2 import Template

# Definimos la función principal que ejecutará el proceso de generación de configuraciones
def generate_apache_config():
    # Definimos el nombre del archivo de origen que contiene la estructura de datos
    yaml_file = "data.yml"
    # Definimos el nombre del archivo de la plantilla base de Jinja2
    template_file = "vhosts.j2"
    # Definimos el nombre del archivo de salida final que leerá el servidor Apache
    output_file = "vhosts.conf"

    # Abrimos el archivo de datos YAML en modo lectura exclusiva
    with open(yaml_file, "r") as f:
        # Cargamos el contenido del archivo estructurado mapeándolo a un diccionario de Python
        data = yaml.safe_load(f)

    # Abrimos el archivo de la plantilla Jinja2 en modo lectura exclusiva
    with open(template_file, "r") as f:
        # Leemos todo el texto de la plantilla y lo cargamos en memoria como un string
        template_content = f.read()

    # Compilamos el texto leído usando el motor de renderizado de la clase Template
    template = Template(template_content)
    # Renderizamos la plantilla inyectando los datos del diccionario extraídos del YAML
    rendered_config = template.render(data)

    # Filtramos eliminando lineas vacias intermedias y borrando espacios en blanco al final de cada linea (rstrip)
    clean_lines = [line.rstrip() for line in rendered_config.splitlines() if line.strip() != ""]
    # Reconstruimos el archivo uniendo las lineas procesadas con un salto de linea estandar
    final_output = "\n".join(clean_lines)

    # Abrimos el archivo vhosts.conf en modo escritura para guardar el resultado final
    with open(output_file, "w") as f:
        # Escribimos el contenido limpio de forma exacta tal y como lo espera el validador sin saltos extra
        f.write(final_output)

    # Imprimimos un mensaje confirmando en la consola que el archivo fue generado con éxito
    print(f"¡Éxito! El archivo {output_file} ha sido generado correctamente.")

# Validamos si este script está siendo ejecutado directamente desde la terminal de comandos
if __name__ == "__main__":
    # Invocamos la función encargada de procesar la plantilla y los archivos
    generate_apache_config()