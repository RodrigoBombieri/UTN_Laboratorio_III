-- ACTIVIDAD 2.2 - Consultas de Selección - Cláusula Join

-- 1) Listado con nombre de usuario de todos los usuarios y sus respectivos nombres y apellidos.
Select U.NombreUsuario AS "Nombre de Usuario", D.Apellidos, D.Nombres
From Usuarios AS U
INNER JOIN Datos_Personales AS D
ON U.ID = D.ID

-- 2) Listado con apellidos, nombres, fecha de nacimiento y nombre del país de nacimiento.
Select D.Apellidos, D.Nombres, D.Nacimiento AS "Fecha De Nacimiento", P.Nombre AS País
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
-- como 'información de contacto'.
-- NOTA: Si no tiene email, obtener el celular y si no posee celular obtener el domicilio.
Select U.NombreUsuario, D.Apellidos, D.Nombres,
	CASE
		WHEN D.Email IS NOT NULL THEN D.Email
		WHEN D.Celular IS NOT NULL THEN D.Celular
		ELSE D.Domicilio
	END AS "Información de Contacto"
From Datos_Personales as D
INNER JOIN Usuarios as U ON D.ID = U.ID

-- 5) Listado con apellido y nombres, nombre del curso y costo de la inscripción de todos
-- los usuarios inscriptos a cursos.
-- NOTA: No deben figurar los usuarios que no se inscribieron a ningún curso.
Select D.Apellidos, D. Nombres, C.Nombre AS "Curso", I.Costo
From Datos_Personales AS D
INNER JOIN Usuarios AS U ON D.ID = U.ID
INNER JOIN Inscripciones AS I ON U.ID = I.IDUsuario
INNER JOIN Cursos AS C ON I.IDCurso = C.ID


-- 6) Listado con nombre de curso, nombre de usuario y email de todos los inscriptos
-- a cursos que se hayan estrenado en el año 2020.
Select C.Nombre AS Curso, U.NombreUsuario AS Usuario, D.Email
From Usuarios AS U
INNER JOIN Datos_Personales AS D ON U.ID = D.ID
INNER JOIN Inscripciones AS I ON U.ID = I.IDUsuario
INNER JOIN Cursos AS C ON C.ID = I.IDCurso
WHERE YEAR(C.Estreno) = 2020

-- 7) Listado con nombre de curso, nombre de usuario, apellidos y nombres, fecha de inscripción
-- costo de la inscripción, fecha de pago e importe de pago. Sólo listar información de 
-- aquellos que hayan pagado.
Select C.Nombre AS Curso, U.NombreUsuario AS Usuario, D.Apellidos, D.Nombres, 
I.Fecha AS "Fecha de Inscripción", I.Costo AS "Costo Inscripción", P.Fecha AS "Fecha de Pago", P.Importe AS "Importe Pagado"
From USUARIOS AS U
INNER JOIN Datos_Personales AS D ON U.ID = D.ID
INNER JOIN Inscripciones AS I ON U.ID = I.IDUsuario
INNER JOIN Cursos AS C ON C.ID = I.IDCurso
INNER JOIN Pagos AS P ON I.ID = P.IDInscripcion

-- 8) Listado con nombre y apellidos, género, fecha de nacimiento, mail, nombre del curso y 
-- fecha de certificación de todos aquellos usuarios que se hayan certificado.
Select D.Nombres, D.Apellidos, D.Genero, D.Nacimiento AS "Fecha Nac.", D.Email, C.Nombre As "Curso", CF.Fecha AS "Fecha de Certificación"
From Usuarios AS U
INNER JOIN Datos_Personales AS D ON U.ID = D.ID
INNER JOIN Inscripciones AS I ON U.ID = I.IDUsuario
INNER JOIN Cursos AS C ON I.IDCurso = C.ID
INNER JOIN Certificaciones AS CF ON I.ID = CF.IDInscripcion

-- 9) Listado de cursos con nombre, costo de cursado y certificación, costo total(cursado+certificación)
-- con 10% de todos los cursos de nivel principiante.
Select TOP (10) PERCENT  C.Nombre, C.CostoCurso, C.CostoCertificacion, C.CostoCurso + C.CostoCertificacion AS "Costo Total"
From Cursos AS C
INNER JOIN Niveles AS N ON C.IDNivel = N.ID
WHERE N.Nombre = 'Principiante'

-- 10) Listado con nombre y apellido y mail de todos los instructores. Sin repetir.
Select DISTINCT D.Nombres, D.Apellidos, D.Email
From Datos_Personales AS D
INNER JOIN Usuarios AS U ON D.ID = U.ID
INNER JOIN Instructores_x_Curso AS IXC ON U.ID = IXC.IDUsuario

-- 11) Listado con nombre y apellido de todos los usuarios que hayan cursado algún curso
-- cuya categoría sea 'Historia'.
Select D.Nombres, D.Apellidos
From Datos_Personales AS D
INNER JOIN Usuarios AS U ON D.ID = U.ID
INNER JOIN Inscripciones AS I ON U.ID = I.IDUsuario
INNER JOIN Cursos AS C ON I.IDCurso = C.ID
INNER JOIN Categorias_x_Curso AS CXC ON C.ID = CXC.IDCurso
INNER JOIN Categorias AS CAT ON CXC.IDCategoria = CAT.ID
WHERE CAT.Nombre = 'Historia'

-- 12) Listado con nombre de idioma, código de curso y código de tipo de idioma.
-- Listar todos los idiomas indistintamente si no tiene cursos relacionados.
Select I.Nombre, C.ID AS "Código de Curso", IXC.IDFormatoIdioma AS "Código de tipo de idioma"
From Idiomas AS I
CROSS JOIN Cursos AS C
LEFT JOIN Idiomas_x_Curso AS IXC ON C.ID = IXC.IDCurso AND I.ID = IXC.IDIdioma

-- 13) Listado con nombre de idioma de todos los idiomas que no tienen cursos relacionados
