Use Clima
-- Ejemplo de inserción de datos en una tabla
-- Se recomienda indicar explícitamente las columnas que tendrán inserciones, en este caso (IDPais, Nombre).
-- Si el ID es autonumérico no se permite tener inserciones.
Insert into Paises (IDPais, Nombre) 
Values 
(1000, 'Islandia'),
(2000, 'China'),
(3000, 'Portugal')

-- Ejemplo de modificación de un registro
-- Siempre se escribe el Where, para modificar el registro específico que quiero (Sino va a cambiar TODOS los registros)
Update Paises Set Nombre = 'Francia' Where IDPais = 3000

-- Ejemplo de modificación de varios registros
Update Paises Set Nombre = 'Uruguay' Where IDPais >= 1000

-- Ejemplo de eliminación de un registro
-- Siempre se escribe el Where, para eliminar el registro específico que quiero(Sino va a eliminar TODOS los registros)
Delete From Paises Where IDPais = 3000

-- Borra todo
-- Truncate Table Paises