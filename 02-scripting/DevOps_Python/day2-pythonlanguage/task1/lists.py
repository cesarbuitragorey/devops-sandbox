import sys


def main():
    """Función principal que procesa comandos dinámicos sobre una lista."""
    my_list = []
    try:
        # Lee la cantidad total de comandos que vendrán a continuación
        num_commands = int(input().strip())

        for _ in range(num_commands):
            # Divide el comando por espacios (ej: ['insert', '0', '5'])
            parts = input().strip().split()
            command = parts[0]

            if command == "insert":
                i = int(parts[1])
                e = int(parts[2])
                my_list.insert(i, e)
            elif command == "print":
                # Se imprime el objeto lista directamente
                print(my_list)
            elif command == "remove":
                e = int(parts[1])
                my_list.remove(e)
            elif command == "append":
                e = int(parts[1])
                my_list.append(e)
            elif command == "sort":
                my_list.sort()
            elif command == "pop":
                my_list.pop()
            elif command == "reverse":
                my_list.reverse()
    except (ValueError, IndexError):
        pass


if __name__ == "__main__":
    main()