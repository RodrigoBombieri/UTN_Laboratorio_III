Use Univ
-- Consultas de Selecci�n - Clausula WHERE

-- 1) Listado de todos los idiomas.
Select * From Idiomas

-- 2) Listado de todos los cursos.
Select * From Cursos

-- 3) Listado con Nombre, costo de inscripci�n(costo de curso), costo de
-- certificaci�n y fecha de estreno de todos los cursos.
Select Nombre, CostoCurso, CostoCertificacion, FechaEstreno from Cursos

-- 4) Listado con ID, nombre, costo de inscripci�n y ID de nivel de todos
-- los cursos cuyo costo de certificaci�n sea menor a $5000.
Select ID, Nombre, CostoCurso, IDNivel From Cursos Where CostoCertificacion < 5000

-- 5) Listado con ID, nombre, costo de inscripci�n y ID de nivel de todos
-- los cursos cuyo costo de certificaci�n sea mayor a $1200.
Select ID, Nombre, CostoCurso, IDNivel From Cursos Where CostoCertificacion > 1200

-- 6) Listado con nombre, n�mero y duraci�n de todas las clases del curso con ID
-- n�mero 6.
Select Nombre, Numero, Duracion From Clases Where IDCurso = 6

-- 7) Listado con nombre, n�mero y duraci�n de todas las clases del curso con ID
-- n�mero 10.
Select Nombre, Numero, Duracion From Clases Where IDCurso = 10

-- 8) Listado con nombre y duraci�n de todas las clases del curso coon ID n�mero 4
-- ordenado por duraci�n de mayor a menor.
Select Nombre, Duracion From Clases Where IDCurso = 4 ORDER BY Duracion desc

-- 9) Listado de cursos con nombre, fecha de estreno, costo del curso, costo de 
-- certificaci�n, ordenados por fecha de estreno de manera creciente.
Select Nombre, FechaEstreno, CostoCurso, CostoCertificacion From Cursos ORDER BY FechaEstreno asc

-- 10) Listado con nombre, fecha de estreno y costo del curso de todos aquellos
-- cuyo ID de nivel sea 1,5,9 o 10.
Select Nombre, FechaEstreno, CostoCurso
From Cursos
WHERE ID IN(1,5,9,10)

-- 11) Listado con nombre, fecha de estreno y costo del curso de los tres cursos
-- mas caros de certificar.
Select TOP(3) Nombre, FechaEstreno, CostoCurso
From Cursos
ORDER BY CostoCertificacion desc

-- 12) Listado con nombre, duraci�n y n�mero de todas las clases de los cursos con
-- ID 2, 5 y 7. Ordenados por ID de Curso ascendente y luego por n�mero de clase
-- ascendente
Select Nombre, Duracion, Numero
From Clases
Where IDCurso IN(2,5,7)
ORDER BY IDCurso asc, Numero asc

-- 13) Listado con nombre y fecha de estreno de todos los cursos cuya fecha de
-- estreno haya sido en el primer semestre del a�o 2019.
Select Nombre, FechaEstreno
From Cursos
WHERE Year(FechaEstreno) = 2019 AND Month(FechaEstreno) BETWEEN 1 AND 6

-- 14) Listado de cursos cuya fecha de estreno haya sido en el a�o 2020.
Select *
From Cursos
Where Year(FechaEstreno) = 2020

-- 15) Listado de cursos cuyo mes de estreno haya sido entre el 1 y el 4.
Select *
From Cursos
Where Month(FechaEstreno) BETWEEN 1 AND 4

-- 16) Listado de clases cuya duraci�n se encuentre entre 15 y 90 minutos.
Select *
From Clases
Where Duracion BETWEEN 15 AND 90

-- 17) Listado de contenidos cuyo tama�o supere los 5000MB y sean de tipo 4
-- o sean menores a 400MB y sean del tipo 1
Select *
From Contenidos
WHERE Tama�o >= 5000 AND IDTipoContenido = 4 
OR Tama�o < 400 AND IDTipoContenido = 1

-- 18) Listado de cursos que no posean ID de Nivel
Select *
From Cursos
Where IDNivel IS NULL

-- 19) Listado de cursos cuyo costo de certificaci�n corresponda al 20%
-- o m�s del costo del curso.
Select *
From Cursos
--Where CostoCurso <> 0 AND CostoCertificacion * 100 / CostoCurso >= 20
Where CostoCertificacion >= CostoCurso*0.2

-- 20) Listado de costos de cursado de todos los cursos sin repetir y
-- ordenados de mayor a menor.
Select DISTINCT CostoCurso 
From Cursos
ORDER BY CostoCurso desc


