# Importamos el módulo 'sys' del sistema para poder cerrar el script con códigos de salida específicos
import sys

# Importamos la función 'colored' de la librería 'termcolor' para aplicar estilos y colores al texto en la terminal
from termcolor import colored


# Definimos una función que recibe la edad (un número entero) y nos devuelve una cadena de texto (str)
def get_age_category(age: int) -> str:
    """Regresa la categoría de edad basada en los criterios del task."""
    # Si la edad es estrictamente menor a 2 años, retorna la cadena de texto para el bebé
    if age < 2:
        return "You are a baby."
    # Si la edad está en el rango inclusivo de 2 a 12 años, retorna la cadena para el niño
    elif 2 <= age <= 12:
        return "You are a child."
    # Si la edad está en el rango inclusivo de 13 a 19 años, retorna la cadena para el adolescente
    elif 13 <= age <= 19:
        return "You are a teenager."
    # Si no se cumplió ninguna de las condiciones anteriores (20 años o más), retorna la cadena para el adulto
    else:
        return "You are an adult."


# Definimos la función principal que controlará la ejecución y el flujo de la aplicación
def main():
    # Creamos el título formateado: texto en color Cyan, en Negrita (bold) y Subrayado (underline)
    title = colored("Age category detector", "cyan", attrs=["bold", "underline"])

    # Imprimimos en la pantalla el título que acabamos de estilizar
    print(title)

    # Imprimimos una línea de guiones decorativa que tiene exactamente el mismo largo que el título
    print("-" * len("Age category detector"))

    # Iniciamos un bloque 'try' para capturar posibles errores si el usuario no escribe un número válido
    try:
        # Solicitamos la edad al usuario a través de la terminal y guardamos su respuesta como texto
        user_input = input("Please enter your age: ")

        # Intentamos convertir el texto ingresado por el usuario en un número entero
        age = int(user_input)

        # Validamos si el número ingresado es negativo (lo cual no es una edad válida)
        if age < 0:
            # Imprimimos un mensaje advirtiendo que la edad no puede ser un número negativo
            print("Age cannot be negative.")
            # Terminamos el programa inmediatamente enviando un código de error de salida (1)
            sys.exit(1)

        # Llamamos a nuestra función pasándole la edad para obtener el texto de la categoría correspondiente
        category = get_age_category(age)

        # Imprimimos en la consola el resultado final devuelto por la función
        print(category)

    # Si el usuario ingresó letras o caracteres que no se pueden convertir a entero, se ejecuta este bloque
    except ValueError:
        # Imprimimos un mensaje notificando que el valor ingresado es inválido
        print("Invalid input. Please enter a valid integer number.")
        # Terminamos el programa enviando un código de error de salida (1) al sistema operativo
        sys.exit(1)


# Esta condición verifica si el archivo se está ejecutando directamente desde la terminal
if __name__ == "__main__":
    # Si se ejecuta directamente, manda a llamar a la función principal 'main' para iniciar el programa
    main()