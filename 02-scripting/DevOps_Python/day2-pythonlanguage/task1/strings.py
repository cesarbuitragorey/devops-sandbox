# Definimos la función que verifica si la palabra es un palíndromo, devolviendo 'yes' o 'no'
def is_palindrome(text: str) -> str:
    """Compara el texto original con su versión invertida."""
    # Usamos rebanado de cadenas [::-1] para invertir el texto. Si el original es igual al invertido, es palíndromo.
    if text == text[::-1]:
        # Si se lee igual en ambas direcciones, retorna "yes"
        return "yes"

    # Si difieren en algún carácter, retorna "no"
    return "no"


# Función principal
def main():
    # Capturamos la cadena de texto de la entrada estándar quitando espacios al inicio o final
    text = input().strip()

    # Procesamos la palabra con la función de validación
    result = is_palindrome(text)

    # Imprimimos la respuesta en la consola
    print(result)


# Punto de entrada estándar de Python
if __name__ == "__main__":
    # Iniciamos la ejecución del programa
    main()