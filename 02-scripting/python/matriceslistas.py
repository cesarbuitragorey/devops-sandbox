datos= [5,6,7,8,9]
datos.append(15)
datos.append(20)
print(datos[0])
print(datos[1])
print("Todos los datos ")
for i in range(0,len(datos)):
    print (datos[i])

print("Todos los datos al reves")
for i in range(4,-1,-1):
    print (datos[i])