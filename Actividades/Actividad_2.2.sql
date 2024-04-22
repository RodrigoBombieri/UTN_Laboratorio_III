-- ACTIVIDAD 2.2 - Consultas de Selecci�n - Cl�usula Join

-- 1) Listado con nombre de usuario de todos los usuarios y sus respectivos nombres y apellidos.
Select U.NombreUsuario AS "Nombre de Usuario", D.Apellidos, D.Nombres
From Usuarios AS U
INNER JOIN Datos_Personales AS D
ON U.ID = D.ID

-- 2) Listado con apellidos, nombres, fecha de nacimiento y nombre del pa�s de nacimiento.
Select D.Apellidos, D.Nombres, D.Nacimiento AS "Fecha De Nacimiento", P.Nombre AS Pa�s
From Datos_Personales AS D
INNER JOIN Localidades AS L
ON D.IDLocalidad = L.ID
INNER JOIN Paises AS P
ON L.IDPais = P.ID

-- 3) Listado con nombre de usuario, apellidos, nombres, email o celular de todos los
-- usuarios que vivan en un domicilio que comience con vocal.
-- NOTA: Si no tiene email, obtener el celular
Select U.NombreUsuario, D.Apellidos, D.Nombres,
	CASE
		WHEN D.Email IS NOT NULL THEN D.Email
			ELSE D.Celular
		END AS Contacto
From Datos_Personales as D
INNER JOIN Usuarios as U  ON D.ID = U.ID
WHERE D.Domicilio LIKE '[aeiou]%'
	
-- 4) Listado con nombre de usuario, apellidos, nombres, email o celular o domicilio
-- como 'informaci�n de contacto'.
-- NOTA: Si no tiene email, obtener el celular y si no posee celular obtener el domicilio.
Select U.NombreUsuario, D.Apellidos, D.Nombres,
	CASE
		WHEN D.Email IS NOT NULL THEN D.Email
		WHEN D.Celular IS NOT NULL THEN D.Celular
		ELSE D.Domicilio
	END AS "Informaci�n de Contacto"
From Datos_Personales as D
INNER JOIN Usuarios as U ON D.ID = U.ID

-- 5) Listado con apellido y nombres, nombre del curso y costo de la inscripci�n de todos
-- los usuarios inscriptos a cursos.
-- NOTA: No deben figurar los usuarios que no se inscribieron a ning�n curso.
Select D.Apellidos, D. Nombres, C.Nombre AS "Curso", I.Costo
From Datos_Personales AS D
INNER JOIN Usuarios AS U ON D.ID = U.ID
INNER JOIN Inscripciones AS I ON U.ID = I.IDUsuario
INNER JOIN Cursos AS C ON I.IDCurso = C.ID


-- 6) Listado con nombre de curso, nombre de usuario y email de todos los inscriptos
-- a cursos que se hayan estrenado en el a�o 2020.
Select C.Nombre AS Curso, U.NombreUsuario AS Usuario, D.Email
From Usuarios AS U
INNER JOIN Datos_Personales AS D ON U.ID = D.ID
INNER JOIN Inscripciones AS I ON U.ID = I.IDUsuario
INNER JOIN Cursos AS C ON C.ID = I.IDCurso
WHERE YEAR(C.Estreno) = 2020

-- 7) Listado con nombre de curso, nombre de usuario, apellidos y nombres, fecha de inscripci�n
-- costo de la inscripci�n, fecha de pago e importe de pago. S�lo listar informaci�n de 
-- aquellos que hayan pagado.
Select C.Nombre AS Curso, U.NombreUsuario AS Usuario, D.Apellidos, D.Nombres, 
I.Fecha AS "Fecha de Inscripci�n", I.Costo AS "Costo Inscripci�n", P.Fecha AS "Fecha de Pago", P.Importe AS "Importe Pagado"
From USUARIOS AS U
INNER JOIN Datos_Personales AS D ON U.ID = D.ID
INNER JOIN Inscripciones AS I ON U.ID = I.IDUsuario
INNER JOIN Cursos AS C ON C.ID = I.IDCurso
INNER JOIN Pagos AS P ON I.ID = P.IDInscripcion

-- 8) Listado con nombre y apellidos, g�nero, fecha de nacimiento, mail, nombre del curso y 
-- fecha de certificaci�n de todos aquellos usuarios que se hayan certificado.
Select D.Nombres, D.Apellidos, D.Genero, D.Nacimiento AS "Fecha Nac.", D.Email, C.Nombre As "Curso", CF.Fecha AS "Fecha de Certificaci�n"
From Usuarios AS U
INNER JOIN Datos_Personales AS D ON U.ID = D.ID
INNER JOIN Inscripciones AS I ON U.ID = I.IDUsuario
INNER JOIN Cursos AS C ON I.IDCurso = C.ID
INNER JOIN Certificaciones AS CF ON I.ID = CF.IDInscripcion

-- 9) Listado de cursos con nombre, costo de cursado y certificaci�n, costo total(cursado+certificaci�n)
-- con 10% de todos los cursos de nivel principiante.
Select TOP (10) PERCENT C.Nombre, C.CostoCurso, C.CostoCertificacion, C.CostoCurso + C.CostoCertificacion AS "Costo Total"
From Cursos AS C
INNER JOIN Niveles AS N ON C.IDNivel = N.ID
WHERE N.Nombre = 'Principiante'

-- 10) Listado con nombre y apellido y mail de todos los instructores. Sin repetir.
Select DISTINCT D.Nombres, D.Apellidos, D.Email
From Datos_Personales AS D
INNER JOIN Usuarios AS U ON D.ID = U.ID
INNER JOIN Instructores_x_Curso AS IXC ON U.ID = IXC.IDUsuario

-- 11) Listado con nombre y apellido de todos los usuarios que hayan cursado alg�n curso
-- cuya categor�a sea 'Historia'.
Select D.Nombres, D.Apellidos
From Datos_Personales AS D
INNER JOIN Usuarios AS U ON D.ID = U.ID
INNER JOIN Inscripciones AS I ON U.ID = I.IDUsuario
INNER JOIN Cursos AS C ON I.IDCurso = C.ID
INNER JOIN Categorias_x_Curso AS CXC ON C.ID = CXC.IDCurso
INNER JOIN Categorias AS CAT ON CXC.IDCategoria = CAT.ID
WHERE CAT.Nombre = 'Historia'

-- 12) Listado con nombre de idioma, c�digo de curso y c�digo de tipo de idioma.
-- Listar todos los idiomas indistintamente si no tiene cursos relacionados.
Select I.Nombre, C.ID AS "C�digo de Curso", IXC.IDFormatoIdioma AS "C�digo de tipo de idioma"
From Idiomas AS I
LEFT JOIN Idiomas_x_Curso AS IXC ON I.ID = IXC.IDIdioma
LEFT JOIN Cursos AS C ON IXC.IDCurso = C.ID

-- 13) Listado con nombre de idioma de todos los idiomas que no tienen cursos relacionados
SELECT I.Nombre AS 'Nombre de Idioma'
FROM Idiomas AS I
LEFT JOIN Idiomas_x_Curso AS IXC ON I.ID = IXC.IDIdioma
WHERE IXC.IDCurso IS NULL

-- 14) Listado con nombres de idiomas que figuren como audio de alg�n curso. Sin repeticiones.
Select DISTINCT I.Nombre AS 'Idioma'
From Idiomas AS I
INNER JOIN Idiomas_x_Curso AS IXC ON I.ID = IXC.IDIdioma
INNER JOIN FormatosIdioma AS FI ON IXC.IDFormatoIdioma = FI.ID
WHERE FI.Nombre = 'Audio'

-- 15) Listado con nombres y apellidos de todos los usuarios y el nombre del pa�s en
-- el que nacieron. Listar todos los paises indistintamente si no tienen usuarios relacionados.
Select D.Nombres, D.Apellidos, P.Nombre AS Pais
FROM Usuarios AS U
INNER JOIN Datos_Personales AS D ON U.ID = D.ID
INNER JOIN Localidades AS L ON D.IDLocalidad = L.ID
RIGHT JOIN Paises AS P ON L.IDPais = P.ID

-- 16) Listado con nombre de curso, fecha de estreno y nombres de usuario de todos los inscriptos.
-- Listar todos los nombres de usuario indistintamente si no se inscribieron a ning�n curso.
Select C.Nombre as Curso, C.Estreno as "Fecha de estreno", U.NombreUsuario as "Nombre de usuario"
From Cursos as C
inner join Inscripciones as I ON C.ID = I.IDCurso
right join Usuarios AS U ON I.IDUsuario = U.ID

-- 17) Listado con nombre de usuario, apellido, nombres, genero, fecha de nacimiento y mail
-- de todos los usuarios que no cursaron ning�n curso.
Select U.NombreUsuario as "Nombre de Usuario", D.Apellidos, D.Nombres, D.Genero, D.Nacimiento, D.Email
From Datos_Personales as D
inner join Usuarios as U on D.ID = u.ID
left join Inscripciones as I on U.ID = I.IDUsuario
Where I.ID IS NULL

-- 18) Listado con nombre y apellido, nombre del curso, puntaje otorgado, y texto de la rese�a.
-- S�lo de aquellos usuarios que hayan realizado una rese�a inapropiada.
Select D.Nombres, D.Apellidos, C.Nombre as Curso, R.Puntaje, R.Observaciones
From Datos_Personales as D
inner join Usuarios as U ON D.ID = U.ID
inner join Inscripciones as I ON U.ID = I.IDUsuario
right join Rese�as as R ON I.ID = R.IDInscripcion
inner join Cursos as C ON I.IDCurso = C.ID
Where R.Inapropiada = 1

-- 19) Listado con nombre del curso, costo de cursado, costo de certificaci�n, nombre del idioma,
-- y nombre del tipo de idioma de todos los cursos cuya fecha de estreno haya sido antes del a�o actual.
-- Ordenado por nombre del curso y luego por nombre de tipo de idioma. Ambos ascendentemente.
Select C.Nombre as Curso, C.CostoCurso as "Costo del curso", C.CostoCertificacion as "Costo de Certificaci�n",
I.Nombre as Idioma, FI.Nombre as "Formato de idioma"
From Cursos as C
inner join Idiomas_x_Curso AS IXC ON C.ID = IXC.IDCurso
inner join Idiomas AS I ON IXC.IDIdioma = I.ID
inner join FormatosIdioma AS FI ON IXC.IDFormatoIdioma = FI.ID
Where YEAR(C.Estreno) < YEAR(GETDATE())
Order By Curso ASC,
"Formato de idioma" ASC

-- 20) Listado con nombre del curso y todos los importes de los pagos relacionados.
Select C.Nombre as Cursos, P.Importe AS "Importe de Pago"
From Cursos as C
inner join Inscripciones as I ON C.ID = I.IDCurso
inner join Pagos as P ON I.ID = P.IDInscripcion


-- 21) Listado con nombre del curso, costo de cursado y una leyenda que indique "Costoso"
-- si el costo de cursado es mayor a $ 15000, "Accesible" si el costo de cursado est� entre $2500 y $15000,
-- "Barato" si el costo est� entre $1 y $2499 y "Gratis" si el costo es $0.
Select C.Nombre AS Curso, C.CostoCurso AS "Costo de Cursado",
CASE
	WHEN C.CostoCurso > 15000 THEN 'Costoso'
	WHEN C.CostoCurso <= 15000 and C.CostoCurso >= 2500 THEN 'Accesible'
	WHEN C.CostoCurso < 2500 and C.CostoCurso >= 1 THEN 'Barato'
	WHEN C.CostoCurso = 0 THEN 'Gratis'
END AS 'Leyenda'
From Cursos as C
