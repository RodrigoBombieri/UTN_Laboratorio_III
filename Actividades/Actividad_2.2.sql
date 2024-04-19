-- ACTIVIDAD 2.2 - Consultas de Selecci�n - Cl�usula Join

-- 1) Listado con nombre de usuario de todos los usuarios y sus respectivos nombres y apellidos.
Select U.NombreUsuario, D.Apellidos, D.Nombres
From Usuarios AS U
INNER JOIN Datos_Personales AS D
ON U.ID = D.ID

-- 2) Listado con apellidos, nombres, fecha de nacimiento y nombre del pa�s de nacimiento.
Select D.Apellidos, D.Nombres, D.Nacimiento, P.Nombre
From Datos_Personales AS D
INNER JOIN Localidades AS L
ON D.IDLocalidad = L.ID
INNER JOIN Paises AS P
ON L.IDPais = P.ID