def reverse_words_in_sentence(sentence: str) -> str:
    """Invierte cada palabra manteniendo su posición en la oración original."""
    # Si la cadena está vacía, regresamos una cadena vacía directamente
    if not sentence:
        return ""
    # Dividimos la oración por espacios en una lista de palabras
    words = sentence.split(" ")
    # Invertimos los caracteres de cada palabra usando comprensión de listas
    reversed_words = [word[::-1] for word in words]
    # Unimos nuevamente las palabras usando un único espacio como conector
    return " ".join(reversed_words)


def main():
    """Función principal exigida por el validador del test."""
    sentence = input().strip()
    result = reverse_words_in_sentence(sentence)
    print(result)


if __name__ == "__main__":
    main()