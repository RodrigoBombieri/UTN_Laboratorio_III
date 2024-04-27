-- ACTIVIDAD 2.3 --
-- Consultas de Selección - Funciones de resumen --


-- 1) Listado con cantidad de cursos.
Select COUNT(ID) as "Cantidad de Cursos" From Cursos

-- 2) Listado con la cantidad de Usuarios.
Select COUNT(ID) as "Cantidad de Usuarios" From Usuarios

-- 3) Listado con el promedio de costo de certificación de los cursos.
Select AVG(CostoCertificacion) as "Costo de Certificación promedio" From Cursos

-- 4) Listado con el promedio general de calificación de reseñas.
Select AVG(Puntaje) as "Promedio general de calificación de reseñas" From Reseñas

-- 5) Listado con la fecha de estreno de curso más antigua.
Select MIN(Estreno) as "Fecha más antigua" From Cursos

-- 6) Listado con el costo de certificación menos costoso.
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

-- 13) Listado con el nombre del País y la cantidad de usuarios de cada país.
Select P.Nombre as País, COUNT(U.ID) as "Cantidad de Usuarios" 
From Usuarios as U
inner join Datos_Personales as DP ON U.ID = DP.ID
inner join Localidades as L ON DP.IDLocalidad = L.ID
inner join Paises as P ON L.IDPais = P.ID
Group By P.Nombre

-- 14) Listado con el apellido y nombres del usuario y el importe más costoso abonado
-- como pago. Sólo listar aquellos que hayan abonado más de $7500.
Select DP.Apellidos + ', ' + DP.Nombres AS "Apellido y Nombre", MAX(P.Importe) as "Pago más costoso"
From Datos_Personales as DP
inner join  Usuarios as U ON DP.ID = U.ID
inner join Inscripciones as I ON DP.ID = I.IDUsuario
inner join Pagos as P ON I.ID = P.IDInscripcion
Group By DP.Apellidos + ', ' + DP.Nombres
Having Max(P.Importe) > 7500

-- 15) Listado con el apellido y nombres de usuario de cada usuario y el importe más
-- costoso del curso al cual se haya inscripto. Si hay usuarios sin inscripciones deben
-- figurar en el listado de todas maneras.
Select DP.Apellidos + ', ' + DP.Nombres as "Apellido y Nombre", MAX(C.CostoCurso) as "Costo del curso"
From Datos_Personales as DP
left join Inscripciones as I ON DP.ID = I.IDUsuario
left join Cursos as C ON I.IDCurso = C.ID
Group By DP.Apellidos + ', ' + DP.Nombres

-- 16) Listado con el nombre del curso, nombre del nivel, cantidad total de clases y 
-- duración total del curso en minutos.
Select C.Nombre as Curso, N.Nombre as Nivel, COUNT(CL.ID) as "Cantidad total de clases", SUM(CL.Duracion) as "Duración en minutos"
From Cursos as C
left join Niveles as N ON C.IDNivel = N.ID
inner join Clases as CL ON C.ID = CL.IDCurso
Group By C.Nombre, N.Nombre

-- 17) Listado con el nombre del curso y cantidad de contenidos registrados. Sólo listar
-- aquellos cursos que tengan más de 10 contenidos registrados.
Select C.Nombre as Curso, COUNT(CO.ID) as "Contenidos Registrados"
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

-- 20) Listado de categorías de curso y cantidad de cursos asociadas a cada categoría.
-- Sólo mostrar las categorías con más de 5 cursos.
Select CAT.Nombre as Categoria, COUNT(CXC.IDCurso) AS "Cantidad de cursos"
From Cursos as C
inner join Categorias_x_Curso as CXC ON C.ID = CXC.IDCurso
inner join Categorias as CAT ON CXC.IDCategoria = CAT.ID
Group By CAT.Nombre, CAT.ID
Having COUNT(CXC.IDCurso) > 5






