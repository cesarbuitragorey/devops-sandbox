def main():
    """Encuentra elementos comunes entre dos listas sin duplicados y ordenados."""
    try:
        # Lee los números de la primera línea y los vuelve un conjunto de enteros
        list1 = set(map(int, input().strip().split()))
        # Lee los números de la segunda línea de igual forma
        list2 = set(map(int, input().strip().split()))

        # La operación '&' calcula la intersección exacta de ambos conjuntos (sets)
        common_items = list1 & list2

        # Convertimos a lista para poder usar la función sorted() antes de imprimir
        result = sorted(list(common_items))
        print(result)
    except ValueError:
        pass


if __name__ == "__main__":
    main()