# Importamos 'sys' para controlar cierres inesperados ante datos erróneos
import sys


# Definimos la función que toma un número entero y retorna la suma de sus dígitos
def sum_of_digits(n: int) -> int:
    """Suma los dígitos individuales convirtiendo el número a texto."""
    # Inicializamos el contador de la suma total en cero
    total_sum = 0

    # Convertimos el entero a string con str(n) para poder iterar carácter por carácter (dígito por dígito)
    for digit in str(n):
        # Convertimos el carácter de vuelta a entero y lo acumulamos en la suma total
        total_sum += int(digit)

    # Devolvemos la sumatoria obtenida
    return total_sum


# Función principal
def main():
    try:
        # Capturamos la entrada de la consola removiendo espacios vacíos invisibles
        user_input = input().strip()

        # Transformamos el texto ingresado a un tipo numérico entero
        n = int(user_input)

        # Verificamos la restricción del problema: n debe ser positivo o cero
        if n < 0:
            # Salimos del programa en caso de recibir un número negativo
            sys.exit(1)

        # Llamamos a nuestra función de procesamiento
        result = sum_of_digits(n)

        # Imprimimos la suma de los dígitos en la terminal
        print(result)

    # Capturamos el error en caso de que la entrada no contenga un formato numérico entero válido
    except ValueError:
        # Forzamos la salida del script indicando falla
        sys.exit(1)


# Comprobación de ejecución como script principal
if __name__ == "__main__":
    # Ejecutamos la lógica del programa
    main()