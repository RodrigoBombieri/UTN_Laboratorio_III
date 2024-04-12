Use Clima
-- Ejemplo de inserci�n de datos en una tabla
-- Se recomienda indicar expl�citamente las columnas que tendr�n inserciones, en este caso (IDPais, Nombre).
-- Si el ID es autonum�rico no se permite tener inserciones.
Insert into Paises (IDPais, Nombre) 
Values 
(1000, 'Islandia'),
(2000, 'China'),
(3000, 'Portugal')

-- Ejemplo de modificaci�n de un registro
-- Siempre se escribe el Where, para modificar el registro espec�fico que quiero (Sino va a cambiar TODOS los registros)
Update Paises Set Nombre = 'Francia' Where IDPais = 3000

-- Ejemplo de modificaci�n de varios registros
Update Paises Set Nombre = 'Uruguay' Where IDPais >= 1000

-- Ejemplo de eliminaci�n de un registro
-- Siempre se escribe el Where, para eliminar el registro espec�fico que quiero(Sino va a eliminar TODOS los registros)
Delete From Paises Where IDPais = 3000

-- Borra todo
-- Truncate Table Paises