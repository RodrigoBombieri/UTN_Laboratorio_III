-- ACTIVIDAD 2.4 --

-- 1) Listado con apellidos y nombres de los usuarios que se hayan inscripto a cursos
-- durante el a�o 2019.
Select DP.Apellidos + ', ' + DP.Nombres AS "Apellido y Nombre"
From Usuarios as U
INNER JOIN Datos_Personales AS DP ON U.ID = DP.ID
INNER JOIN Inscripciones AS I ON DP.ID = I.IDUsuario
Where YEAR(I.Fecha) = 2019

-- 2) Listado con apellidos y nombres de los usuarios que se hayan inscripto a cursos
-- pero no hayan realizado ning�n pago.
Select DP.Apellidos + ', ' + DP.Nombres AS "Apellido y Nombre"
From Usuarios as U
INNER JOIN Datos_Personales AS DP ON U.ID = DP.ID
INNER JOIN Inscripciones AS I ON DP.ID = I.IDUsuario
LEFT JOIN Pagos AS P ON I.ID = P.IDInscripcion
Where P.Importe IS NULL

-- 3) Listado de pa�ses que no tengan usuarios relacionados.
Select P.Nombre AS Pa�s
From Paises as P Where P.Nombre NOT IN (
	Select P.Nombre From Paises as p
	inner join Localidades as L ON P.ID = L.IDPais
	inner join Datos_Personales as DP ON L.ID = DP.IDLocalidad
)

-- 4) Listado de clases cuya duraci�n sea mayor a la duraci�n promedio.
Declare @DuracionProm Int
Select @DuracionProm = AVG(Duracion) From Clases

Select CL.Nombre as Clase, CL.Duracion as "Duraci�n"
From Clases as CL
Group By CL.Nombre, CL.Duracion
Having CL.Duracion > @DuracionProm

-- 5) Listado de contenidos cuyo tama�o sea mayor al tama�o de todos los contenidos
-- de tipo 'Audio de alta calidad'.
Select DISTINCT TC.Nombre From TiposContenido AS TC
INNER JOIN Contenidos as CO ON TC.ID = CO.IDTipo
Where CO.Tama�o > ALL (
	Select CO2.Tama�o From Contenidos as CO2
	inner join TiposContenido as TC2 ON TC2.ID = CO2.IDTipo
	Where TC2.Nombre like 'Audio de alta calidad'
)

-- 6) Listado de contenidos cuyo tama�o sea menor al tama�o de alg�n contenido
-- de tipo 'Audio de alta calidad'.
Select DISTINCT TC.Nombre as Contenido From TiposContenido as TC
inner join Contenidos AS CO ON TC.ID = CO.IDTipo
Where CO.Tama�o < ANY (
	Select CO2.Tama�o From Contenidos as CO2
	inner join TiposContenido as TC2 ON CO2.IDTipo = TC2.ID
	Where TC2.Nombre LIKE 'Audio de alta calidad'
) --> Lista: Audio de alta calidad, Examen y Texto


-- 7) Listado con nombre de pa�s y la cantidad de usuarios de g�nero masculino
-- y la cantidad de usuarios de g�nero femenino que haya registrado.
Select P.Nombre,
(
	Select COUNT(U.ID) From Usuarios as U
	INNER JOIN Datos_Personales AS DP ON U.ID = DP.ID
	INNER JOIN Localidades AS L ON DP.IDLocalidad = L.ID
	Where DP.Genero LIKE 'M' AND L.IDPais = P.ID
) as "Usuarios masculinos",
(
	Select COUNT(U.ID) From Usuarios as U
	inner join Datos_Personales as DP ON U.ID = DP.ID
	INNER JOIN Localidades AS L ON DP.IDLocalidad = L.ID
	Where DP.Genero LIKE 'F' and L.IDPais = P.ID
) as "Usuarios Femeninos"
From Paises as P

-- 8) Listado con apellidos y nombres de los usuarios y la cantidad de inscripciones
-- realizadas en el a�o 2019 y 2020.
Select DP.Apellidos + ', ' + DP.Nombres AS "Apellido y Nombre",
(
	Select COUNT(I.ID) From Inscripciones as I
	Where YEAR(I.Fecha) = 2019 AND I.IDUsuario = U.ID
) AS "Inscripciones 2019",
(
	Select COUNT(I.ID) From Inscripciones as I
	Where YEAR(I.Fecha) = 2020 AND I.IDUsuario = U.ID
) AS "Inscripciones 2020"
From Datos_Personales as DP
inner join Usuarios as U ON DP.ID = U.ID

-- 9) Listado con nombres de los cursos y la cantidad de idiomas de cada tipo. 
-- Es decir, la cantidad de idiomas de audio, cantidad de subtitulos y cantidad de texto de video.
Select C.Nombre as Curso,
(
	Select COUNT(I.ID) From Idiomas as I
	INNER JOIN Idiomas_x_Curso AS IXC ON I.ID = IXC.IDIdioma
	INNER JOIN FormatosIdioma AS FI ON IXC.IDFormatoIdioma = FI.ID
	Where FI.Nombre LIKE 'Audio' AND IXC.IDCurso = C.ID
) AS "Cantidad de idiomas en audio",
(
	Select COUNT(I.ID) From Idiomas as I
	INNER JOIN Idiomas_x_Curso AS IXC ON I.ID = IXC.IDIdioma
	INNER JOIN FormatosIdioma AS FI ON IXC.IDFormatoIdioma = FI.ID
	Where FI.Nombre LIKE 'Subtitulo' AND IXC.IDCurso = C.ID
) AS "Cantidad de idiomas en subtitulos",
(
	Select COUNT(I.ID) From Idiomas as I
	INNER JOIN Idiomas_x_Curso AS IXC ON I.ID = IXC.IDIdioma
	INNER JOIN FormatosIdioma AS FI ON IXC.IDFormatoIdioma = FI.ID
	Where FI.Nombre LIKE 'Texto del video' AND IXC.IDCurso = C.ID
) AS "Cantidad de idiomas en texto de video"
From Cursos as C

-- 10) Listado con apellidos y nombres de los usuarios, nombre del usuario y cantidad
-- de cursos nivel 'Principiante' que realiz� y cantidad de cursos 'Avanzado' que realiz�.
Select DP.Apellidos + ', ' + DP.Nombres as "Apellido y Nombre", U.NombreUsuario,
(
	Select COUNT(N.ID) From Niveles as N
	INNER JOIN Cursos AS C ON N.ID = C.IDNivel
	INNER JOIN Inscripciones AS I ON C.ID = I.IDCurso
	Where N.Nombre LIKE 'Principiante' AND I.IDUsuario = DP.ID
) AS "Cantidad de cursos nivel Principiante",
(
	Select COUNT(N.ID) From Niveles as N
	INNER JOIN Cursos AS C ON N.ID = C.IDNivel
	INNER JOIN Inscripciones AS I ON C.ID = I.IDCurso
	Where N.Nombre LIKE 'Avanzado' AND I.IDUsuario = DP.ID

) AS "Cantidad de cursos nivel Avanzado"
From Usuarios as U
INNER JOIN Datos_Personales AS DP ON U.ID = DP.ID

-- 11) Listado con nombre de los cursos y la recaudaci�n de inscripciones de usuarios
-- de g�nero femenino que se inscribieron y de g�nero m�sculino.
Select C.Nombre as Curso,
(
	Select SUM(I.Costo) From Inscripciones as I
	inner join Usuarios as U ON I.IDUsuario = U.ID
	inner join Datos_Personales as DP ON U.ID = DP.ID
	Where DP.Genero LIKE 'F' AND I.IDCurso = C.ID
) AS "Recaudaci�n de Femeninas inscriptas",
(
	Select SUM(I.Costo) From Inscripciones as I
	inner join Usuarios as U ON I.IDUsuario = U.ID
	inner join Datos_Personales as DP ON U.ID = DP.ID
	Where DP.Genero LIKE 'M' AND I.IDCurso = C.ID
) AS "Recaudaci�n de Masculinos inscriptos"
From Cursos as C

-- 12) Listado con nombre de pa�s de aquellos que hayan registrado m�s usuarios de 
-- g�nero masculino que de g�nero femenino.
SELECT P.Nombre AS Pa�s
FROM Paises AS P
INNER JOIN Localidades AS L ON P.ID = L.IDPais
INNER JOIN Datos_Personales AS DP ON L.ID = DP.IDLocalidad
GROUP BY P.Nombre
HAVING SUM(CASE WHEN DP.Genero = 'M' THEN 1 ELSE 0 END) > SUM(CASE WHEN DP.Genero = 'F' THEN 1 ELSE 0 END)

-- 13) Listado con nombre de pa�s de aquellos que hayan registrados m�s usuarios de
-- g�nero masculino que de g�nero femenino pero que haya registado al menos un usuario 
-- de g�nero femenino
SELECT P.Nombre AS Pa�s
FROM Paises AS P
INNER JOIN Localidades AS L ON P.ID = L.IDPais
INNER JOIN Datos_Personales AS DP ON L.ID = DP.IDLocalidad
GROUP BY P.Nombre
HAVING SUM(CASE WHEN DP.Genero = 'M' THEN 1 ELSE 0 END) > SUM(CASE WHEN DP.Genero = 'F' THEN 1 ELSE 0 END)
AND SUM(CASE WHEN DP.Genero = 'F' THEN 1 ELSE 0 END) > 0