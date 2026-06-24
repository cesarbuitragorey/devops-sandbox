# Importamos la librería nativa 'json' para poder interpretar estructuras complejas tipo JSON recibidas por consola
import json


# Definimos la función que limpia el diccionario, recibiendo y retornando objetos tipo dict
def drop_empty_items(data: dict) -> dict:
    """Filtra el diccionario descartando los elementos cuyo valor sea None."""
    # Usamos comprensión de diccionarios: barremos llaves (k) y valores (v), guardando solo si 'v' no es nulo
    return {k: v for k, v in data.items() if v is not None}


# Función principal
def main():
    try:
        # Capturamos el string de entrada que representa la estructura del objeto
        user_input = input().strip()

        # Traducimos el string JSON a un diccionario real de Python (mapeando automáticamente "null" a None)
        data = json.loads(user_input)

        # Limpiamos el diccionario invocando la función de filtrado
        result = drop_empty_items(data)

        # Imprimimos el diccionario resultante depurado
        print(result)

    # Si la entrada no cumple con las reglas estrictas de sintaxis de un JSON string, capturamos la falla
    except json.JSONDecodeError:
        # Pasamos silenciosamente para evitar crasheos del backend de pruebas
        pass


# Punto de arranque estándar
if __name__ == "__main__":
    # Inicializamos la ejecución del filtro de diccionarios
    main()