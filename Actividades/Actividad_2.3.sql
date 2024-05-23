-- ACTIVIDAD 2.3 --
-- Consultas de Selecci�n - Funciones de resumen --

-- 1) Listado con cantidad de cursos.
Select COUNT(ID) as "Cantidad de Cursos" From Cursos

-- 2) Listado con la cantidad de Usuarios.
Select COUNT(ID) as "Cantidad de Usuarios" From Usuarios

-- 3) Listado con el promedio de costo de certificaci�n de los cursos.
Select AVG(CostoCertificacion) as "Costo de Certificaci�n promedio" From Cursos

-- 4) Listado con el promedio general de calificaci�n de rese�as.
Select AVG(Puntaje) as "Promedio general de calificaci�n de rese�as" From Rese�as

-- 5) Listado con la fecha de estreno de curso m�s antigua.
Select MIN(Estreno) as "Fecha m�s antigua" From Cursos

-- 6) Listado con el costo de certificaci�n menos costoso.
Select MIN(CostoCertificacion) as "Menor Costo" From Cursos

-- 7) Listado con el costo total de todos los cursos.
Select SUM(CostoCurso) as "Costo total de todos los cursos" From Cursos

-- 8) Listado con la suma total de todos los pagos.
Select SUM(Importe) as "Total Pagos" From Pagos

-- 9) Listado con la cantidad de curso de nivel principiante.
Select COUNT(IDNivel) as "Cantidad de Cursos Nivel Principiante" From Cursos
Where IDNivel = 5

-- 10) Listado con la suma total de todos los pagos realizados en 2020.
Select SUM(Importe) as "Pagos en 2020" From Pagos
Where YEAR(Fecha) = 2020

-- 11) Listado con la cantidad de usuarios que son instructores.
Select COUNT(IDUsuario) as "Cantidad de instructores" From Instructores_x_Curso

-- 12) Listado con la cantidad de usuarios distintos que se hayan certificado.
Select COUNT(distinct U.ID) as "Cantidad de usuarios certificados" 
From Usuarios as U
inner join Inscripciones as I ON U.ID = I.IDUsuario
inner join Certificaciones as C ON I.ID = C.IDInscripcion

-- 13) Listado con el nombre del Pa�s y la cantidad de usuarios de cada pa�s.
Select P.Nombre as Pa�s, COUNT(U.ID) as "Cantidad de Usuarios" 
From Usuarios as U
inner join Datos_Personales as DP ON U.ID = DP.ID
inner join Localidades as L ON DP.IDLocalidad = L.ID
inner join Paises as P ON L.IDPais = P.ID
Group By P.Nombre

-- 14) Listado con el apellido y nombres del usuario y el importe m�s costoso abonado
-- como pago. S�lo listar aquellos que hayan abonado m�s de $7500.
Select DP.Apellidos + ', ' + DP.Nombres AS "Apellido y Nombre", MAX(P.Importe) as "Pago m�s costoso"
From Datos_Personales as DP
inner join  Usuarios as U ON DP.ID = U.ID
inner join Inscripciones as I ON DP.ID = I.IDUsuario
inner join Pagos as P ON I.ID = P.IDInscripcion
Group By DP.Apellidos + ', ' + DP.Nombres
Having Max(P.Importe) > 7500

-- 15) Listado con el apellido y nombres de usuario de cada usuario y el importe m�s
-- costoso del curso al cual se haya inscripto. Si hay usuarios sin inscripciones deben
-- figurar en el listado de todas maneras.
Select DP.Apellidos + ', ' + DP.Nombres as "Apellido y Nombre", MAX(C.CostoCurso) as "Costo del curso"
From Datos_Personales as DP
left join Inscripciones as I ON DP.ID = I.IDUsuario
left join Cursos as C ON I.IDCurso = C.ID
Group By DP.Apellidos + ', ' + DP.Nombres

-- 16) Listado con el nombre del curso, nombre del nivel, cantidad total de clases y 
-- duraci�n total del curso en minutos.
Select C.Nombre as Curso, N.Nombre as Nivel, COUNT(CL.ID) as "Cantidad total de clases", SUM(CL.Duracion) as "Duraci�n en minutos"
From Cursos as C
left join Niveles as N ON C.IDNivel = N.ID
inner join Clases as CL ON C.ID = CL.IDCurso
Group By C.Nombre, N.Nombre

-- 17) Listado con el nombre del curso y cantidad de contenidos registrados. S�lo listar
-- aquellos cursos que tengan m�s de 10 contenidos registrados.
Select C.Nombre as Curso, COUNT(distinct CO.ID) as "Contenidos Registrados"
From Cursos as C
inner join Clases as CL ON C.ID = CL.IDCurso
inner join Contenidos as CO ON CL.ID = CO.IDClase
Group By C.Nombre
Having COUNT(CO.ID) > 10

-- 18) Listado con nombre del curso, nombre del idioma y cantidad de tipos de idiomas.
Select C.Nombre as Curso, I.Nombre as Idioma, COUNT(FI.ID) as "Cantidad de tipos de idiomas"
From Cursos as C
inner join Idiomas_x_Curso as IXC ON C.ID = IXC.IDCurso
inner join Idiomas as I ON IXC.IDIdioma = I.ID
inner join FormatosIdioma as FI ON IXC.IDFormatoIdioma = FI.ID
Group By C.Nombre, I.Nombre

-- 19) Listado con el nombre del curso y cantidad de idiomas distintos disponibles.
Select C.Nombre as Curso, COUNT(distinct IXC.IDIdioma) as "Idiomas distintos disponibles"
From Cursos as C
inner join Idiomas_x_Curso as IXC ON C.ID = IXC.IDCurso
Group By C.Nombre, C.ID

-- 20) Listado de categor�as de curso y cantidad de cursos asociadas a cada categor�a.
-- S�lo mostrar las categor�as con m�s de 5 cursos.
Select CAT.Nombre as Categoria, COUNT(CXC.IDCurso) AS "Cantidad de cursos"
From Cursos as C
inner join Categorias_x_Curso as CXC ON C.ID = CXC.IDCurso
inner join Categorias as CAT ON CXC.IDCategoria = CAT.ID
Group By CAT.Nombre, CAT.ID
Having COUNT(CXC.IDCurso) > 5

-- 21) Listado con tipos de contenido y la cantidad de contenidos asociados a cada tipo.
-- Mostrar tambi�n aquellos tipos que no hayan registrado contenidos con cantidad 0.
Select TC.Nombre as "Tipo de Contenido", COUNT(CO.ID) AS "Cantidad de Contenidos"
From Contenidos as CO
right join TiposContenido as TC ON CO.IDTipo = TC.ID
Group By TC.Nombre

-- 22) Listado con nombre del curso, nivel, a�o de estreno y total recaudado en concepto de
-- inscripciones. Listar tambi�n aquellos cursos sin inscripciones con total igual a $0.
Select C.Nombre as Curso, N.Nombre as Nivel, C.Estreno, SUM(I.Costo) as "Total Inscripciones"
From Cursos as C
left join Inscripciones as I ON C.ID = I.IDCurso
inner join Niveles as N ON C.IDNivel = N.ID
Group By C.Nombre, N.Nombre, C.Estreno

-- 23) Listado con Nombre del curso, costo de cursado y certificaci�n y cantidad de usuarios
-- distintos inscriptos cuyo costo de cursado sea menor a $10000 y cuya cantidad de usuarios 
-- inscriptos sea menor a 5. Listar tambi�n aquellos cursos sin inscripciones con cantidad 0.
Select C.Nombre as Curso, C.CostoCurso, C.CostoCertificacion, COUNT(distinct I.IDUsuario) as "Usuarios Inscriptos"
From Cursos as C
left join Inscripciones as I ON C.ID = I.IDCurso
--left join Usuarios as U ON I.IDUsuario = U.ID
Where C.CostoCurso < 10000 
Group By C.ID, C.Nombre, C.CostoCurso, C.CostoCertificacion
Having COUNT(I.IDUsuario) < 5 --> NO MUESTRA EL CURSO 16 QUE TIENE 0 Inscripciones

-- 24) Listado con Nombre del curso, fecha de estreno y nombre del nivel del curso que
-- m�s recaud� en concepto de certificaciones.
Select TOP 1 C.Nombre as Curso, C.Estreno, N.Nombre as Nivel, MAX(CE.Costo) as "Recaudaci�n por certificaciones"
From Cursos as C
inner join Niveles as N ON C.IDNivel = N.ID
inner join Inscripciones as I ON C.ID = I.IDCurso
inner join Certificaciones as CE ON I.ID = CE.IDInscripcion
Group By C.Nombre, C.Estreno, N.Nombre
Order By MAX(CE.Costo) desc

-- 25) Listado con Nombre del idioma, del idioma m�s utilizado como subt�tulo.
Select TOP 1 I.Nombre as Idioma, COUNT(FI.ID) AS "Idioma m�s utilizado como subt�tulo"
From Idiomas as I
inner join Idiomas_x_Curso as IXC ON I.ID = IXC.IDIdioma
inner join FormatosIdioma as FI ON IXC.IDFormatoIdioma = FI.ID
Where FI.ID = 1
Group By I.Nombre
Order By [Idioma m�s utilizado como subt�tulo] DESC

-- 26) Listado con Nombre del curso y promedio de puntaje de rese�as apropiadas.
Select C.Nombre as Curso, AVG(R.Puntaje) as "Promedio de puntaje de rese�as apropiadas"
From Cursos as C
inner join Inscripciones as I ON C.ID = I.IDCurso
inner join Rese�as as R ON I.ID = R.IDInscripcion
Where R.Inapropiada = 0
Group By C.Nombre

-- 27) Listado con Nombre de usuario y la cantidad de rese�as inapropiadas que registr�.
Select U.NombreUsuario, COUNT(R.Inapropiada) as "Rese�as inapropiadas"
From Usuarios as U
inner join Inscripciones as I ON U.ID = I.IDUsuario
inner join Rese�as as R ON I.ID = R.IDInscripcion
Group By U.NombreUsuario

-- 28) Listado con Nombre del curso, nombre y apellidos de usuarios y la cantidad 
-- de veces que dicho usuario realiz� dicho curso. 
-- No mostrar cursos y usuarios que contabilicen cero.
Select C.Nombre as Curso, DP.Apellidos, DP.Nombres, COUNT(U.ID) as "Cantidad de usuarios"
From Cursos as C
inner join Inscripciones as I ON C.ID = I.IDCurso
inner join Usuarios as U ON I.IDUsuario = U.ID
inner join Datos_Personales as DP ON U.ID = DP.ID
Group By C.Nombre, DP.Apellidos, Dp.Nombres

-- 29) Listado con Apellidos y nombres, mail y duraci�n total en concepto de clases de cursos
-- a los que se haya inscripto. S�lo listar informaci�n de aquellos registros cuya 
-- duraci�n total supere los 400 minutos.
Select DP.Apellidos + ', ' + DP.Nombres as "Apellido y Nombre", DP.Email, SUM(CL.Duracion) as "Duraci�n en minutos"
From Datos_Personales as DP
inner join Inscripciones as I ON DP.ID = I.IDUsuario
inner join Cursos as C ON I.IDCurso = C.ID
inner join Clases as CL ON C.ID = CL.IDCurso
Group By DP.Apellidos + ', ' + DP.Nombres, DP.Email
Having SUM(CL.Duracion) > 400

-- 30) Listado con nombre del curso y recaudaci�n total. La recaudaci�n total consiste 
-- en la sumatoria de costos de inscripci�n y de certificaci�n. 
-- Listarlos ordenados de mayor a menor por recaudaci�n.
Select C.Nombre as Curso, SUM(I.Costo + CE.Costo) as "Recaudaci�n Total"
From Cursos as C
inner join Inscripciones as I ON C.ID = I.IDCurso
inner join Certificaciones as CE ON I.ID = CE.IDInscripcion
Group By C.Nombre
Order By [Recaudaci�n Total] desc




