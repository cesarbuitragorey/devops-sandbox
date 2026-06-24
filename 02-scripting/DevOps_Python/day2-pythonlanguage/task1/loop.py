# Importamos el módulo 'sys' del sistema para manejar flujos de terminación y códigos de salida
import sys


# Definimos una función que recibe un número entero (n) y devuelve su factorial (int)
def calculate_factorial(n: int) -> int:
    """Calcula el factorial de un número n de forma iterativa."""
    # Inicializamos la variable acumuladora en 1 (ya que 0! = 1 y el elemento neutro de la multiplicación es 1)
    factorial = 1

    # Creamos un bucle que va desde 1 hasta n (inclusive). range(1, n+1) genera: 1, 2, ..., n
    for i in range(1, n + 1):
        # Multiplicamos el valor acumulado actual por el número del paso presente (i)
        factorial *= i

    # Devolvemos el resultado final del cálculo
    return factorial


# Definimos la función encargada de la ejecución principal
def main():
    try:
        # Leemos la entrada del usuario, eliminamos espacios laterales con strip() y la convertimos a entero
        n = int(input().strip())

        # Validamos el criterio del problema: n debe ser mayor o igual a 0
        if n < 0:
            # Si es negativo, cerramos el programa con código de estado 1 (Error)
            sys.exit(1)

        # Invocamos la función de cálculo pasándole el número capturado
        result = calculate_factorial(n)

        # Imprimimos el resultado final en la consola
        print(result)

    # Si el valor ingresado no se puede transformar a entero (ej. letras), se captura el error
    except ValueError:
        # Finalizamos el script de inmediato debido a una entrada inválida
        sys.exit(1)


# Validamos si el script está ejecutándose de manera directa desde la consola
if __name__ == "__main__":
    # Ejecutamos la función principal
    main()