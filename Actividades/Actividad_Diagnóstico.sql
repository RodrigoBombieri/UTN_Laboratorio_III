-- ¿Cuál es el apellido del médico (sexo masculino) con más antigüedad de la clínica?
-- 1 --
Select M.Apellido FROM MEDICOS AS M
WHERE M.SEXO LIKE 'M'
ORDER BY FECHAINGRESO ASC

-- 2 --
Declare @duracionProm int
Select @duracionProm = AVG(Duracion) From Turnos

Select count(DISTINCT P.IDPACIENTE) From Pacientes as P
inner join TURNOS as T ON P.IDPACIENTE = T.IDPACIENTE
Where T.DURACION > @duracionProm


--¿Cuánto tuvo que pagar la consulta el paciente con el turno nro 146?
-- Teniendo en cuenta que el paciente debe pagar el costo de la consulta del médico 
-- menos lo que cubre la cobertura de la obra social. La cobertura de la obra social 
-- está expresado en un valor decimal entre 0 y 1. Siendo 0 el 0% de cobertura y 1 el 100% de la cobertura.

--Si la cobertura de la obra social es 0.2, entonces el paciente debe pagar el 80% de la consulta.
-- 3 --
Select T.IDTURNO AS "Turno número", M.COSTO_CONSULTA * 0.8 AS "Costo de la consulta del paciente 146"
FROM TURNOS AS T
INNER JOIN MEDICOS AS M ON T.IDMEDICO = M.IDMEDICO
INNER JOIN PACIENTES AS P ON T.IDPACIENTE = P.IDPACIENTE
Where T.IDTURNO = 146

-- ¿Cuál es la cantidad de pacientes que no se atendieron en el año 2019?
--4--
Select COUNT(DISTINCT P.IDPACIENTE) From PACIENTES AS P
INNER JOIN TURNOS AS T ON P.IDPACIENTE = T.IDPACIENTE
Where YEAR(T.FECHAHORA) NOT IN (2019) 

-- ¿Qué Obras Sociales cubren a pacientes que se hayan atendido en algún turno con algún médico de especialidad 'Odontología'?
-- 5 --
Select OS.Nombre as "Obra Social" From OBRAS_SOCIALES AS OS
INNER JOIN PACIENTES AS P ON OS.IDOBRASOCIAL = P.IDOBRASOCIAL
INNER JOIN TURNOS AS T ON P.IDPACIENTE = T.IDPACIENTE
INNER JOIN MEDICOS AS M ON T.IDMEDICO = M.IDMEDICO
INNER JOIN ESPECIALIDADES AS E ON M.IDESPECIALIDAD = E.IDESPECIALIDAD
WHERE E.NOMBRE LIKE 'Odontología'

-- ¿Cuáles son el/los paciente/s que se atendieron más veces? (indistintamente del sexo del paciente)
-- 6 --
Select P.Apellido AS APELLIDO, P.Nombre as NOMBRE, COUNT(T.IDPACIENTE) AS "Cantidad de veces que se atendió" From PACIENTES AS P
INNER JOIN TURNOS AS T ON P.IDPACIENTE = T.IDPACIENTE
Group By P.APELLIDO, P.NOMBRE
Order By COUNT(T.IDPaciente) desc

-- ¿Cuántos médicos tienen la especialidad "Gastroenterología" ó "Pediatría"?
-- 7 --
Select E.Nombre AS ESPECIALIDAD, COUNT(M.IDMEDICO) AS CANTIDAD
From ESPECIALIDADES AS E
INNER JOIN MEDICOS AS M ON E.IDESPECIALIDAD = M.IDESPECIALIDAD
WHERE E.NOMBRE LIKE 'Gastroenterología' OR E.NOMBRE LIKE 'Pediatría'
Group By E.NOMBRE

-- ¿Cuál es el costo de la consulta promedio de los/as especialistas en "Oftalmología"?
-- 8 --
Select AVG(M.COSTO_CONSULTA) AS Promedio FROM MEDICOS AS M
INNER JOIN ESPECIALIDADES AS E ON M.IDESPECIALIDAD = E.IDESPECIALIDAD
WHERE E.NOMBRE LIKE 'Oftalmología'

-- ¿Cuántos turnos fueron atendidos por la doctora Flavia Rice?
-- 9 --
Select M.APELLIDO, M.NOMBRE, COUNT(T.IDTURNO) AS "CANTIDAD DE TURNOS" FROM MEDICOS AS M
INNER JOIN TURNOS AS T ON M.IDMEDICO = T.IDMEDICO
WHERE M.APELLIDO LIKE 'Rice' AND M.NOMBRE LIKE 'Flavia'
Group By M.APELLIDO, M.NOMBRE


-- ¿Cuántas médicas cobran sus honorarios de consulta un costo mayor a $1000?
-- 10 --
Select COUNT(M.IDMEDICO) FROM MEDICOS AS M
WHERE M.SEXO LIKE 'F' AND M.COSTO_CONSULTA > 1000