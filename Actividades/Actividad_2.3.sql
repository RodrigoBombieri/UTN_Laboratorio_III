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
Select C.Nombre as Curso, COUNT(CO.ID) as "Contenidos Registrados"
From Cursos as C
inner join Clases as CL ON C.ID = CL.IDCurso
inner join Contenidos as CO ON CL.ID = CO.IDClase
Group By C.Nombre
Having COUNT(CO.ID) > 10





