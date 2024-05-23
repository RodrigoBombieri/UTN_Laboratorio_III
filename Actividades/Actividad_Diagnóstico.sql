-- �Cu�l es el apellido del m�dico (sexo masculino) con m�s antig�edad de la cl�nica?
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


--�Cu�nto tuvo que pagar la consulta el paciente con el turno nro 146?
-- Teniendo en cuenta que el paciente debe pagar el costo de la consulta del m�dico 
-- menos lo que cubre la cobertura de la obra social. La cobertura de la obra social 
-- est� expresado en un valor decimal entre 0 y 1. Siendo 0 el 0% de cobertura y 1 el 100% de la cobertura.

--Si la cobertura de la obra social es 0.2, entonces el paciente debe pagar el 80% de la consulta.
-- 3 --
Select T.IDTURNO AS "Turno n�mero", M.COSTO_CONSULTA * 0.8 AS "Costo de la consulta del paciente 146"
FROM TURNOS AS T
INNER JOIN MEDICOS AS M ON T.IDMEDICO = M.IDMEDICO
INNER JOIN PACIENTES AS P ON T.IDPACIENTE = P.IDPACIENTE
Where T.IDTURNO = 146

-- �Cu�l es la cantidad de pacientes que no se atendieron en el a�o 2019?
--4--
Select COUNT(DISTINCT P.IDPACIENTE) From PACIENTES AS P
INNER JOIN TURNOS AS T ON P.IDPACIENTE = T.IDPACIENTE
Where YEAR(T.FECHAHORA) NOT IN (2019) 

-- �Qu� Obras Sociales cubren a pacientes que se hayan atendido en alg�n turno con alg�n m�dico de especialidad 'Odontolog�a'?
-- 5 --
Select OS.Nombre as "Obra Social" From OBRAS_SOCIALES AS OS
INNER JOIN PACIENTES AS P ON OS.IDOBRASOCIAL = P.IDOBRASOCIAL
INNER JOIN TURNOS AS T ON P.IDPACIENTE = T.IDPACIENTE
INNER JOIN MEDICOS AS M ON T.IDMEDICO = M.IDMEDICO
INNER JOIN ESPECIALIDADES AS E ON M.IDESPECIALIDAD = E.IDESPECIALIDAD
WHERE E.NOMBRE LIKE 'Odontolog�a'

-- �Cu�les son el/los paciente/s que se atendieron m�s veces? (indistintamente del sexo del paciente)
-- 6 --
Select P.Apellido AS APELLIDO, P.Nombre as NOMBRE, COUNT(T.IDPACIENTE) AS "Cantidad de veces que se atendi�" From PACIENTES AS P
INNER JOIN TURNOS AS T ON P.IDPACIENTE = T.IDPACIENTE
Group By P.APELLIDO, P.NOMBRE
Order By COUNT(T.IDPaciente) desc

-- �Cu�ntos m�dicos tienen la especialidad "Gastroenterolog�a" � "Pediatr�a"?
-- 7 --
Select E.Nombre AS ESPECIALIDAD, COUNT(M.IDMEDICO) AS CANTIDAD
From ESPECIALIDADES AS E
INNER JOIN MEDICOS AS M ON E.IDESPECIALIDAD = M.IDESPECIALIDAD
WHERE E.NOMBRE LIKE 'Gastroenterolog�a' OR E.NOMBRE LIKE 'Pediatr�a'
Group By E.NOMBRE

-- �Cu�l es el costo de la consulta promedio de los/as especialistas en "Oftalmolog�a"?
-- 8 --
Select AVG(M.COSTO_CONSULTA) AS Promedio FROM MEDICOS AS M
INNER JOIN ESPECIALIDADES AS E ON M.IDESPECIALIDAD = E.IDESPECIALIDAD
WHERE E.NOMBRE LIKE 'Oftalmolog�a'

-- �Cu�ntos turnos fueron atendidos por la doctora Flavia Rice?
-- 9 --
Select M.APELLIDO, M.NOMBRE, COUNT(T.IDTURNO) AS "CANTIDAD DE TURNOS" FROM MEDICOS AS M
INNER JOIN TURNOS AS T ON M.IDMEDICO = T.IDMEDICO
WHERE M.APELLIDO LIKE 'Rice' AND M.NOMBRE LIKE 'Flavia'
Group By M.APELLIDO, M.NOMBRE


-- �Cu�ntas m�dicas cobran sus honorarios de consulta un costo mayor a $1000?
-- 10 --
Select COUNT(M.IDMEDICO) FROM MEDICOS AS M
WHERE M.SEXO LIKE 'F' AND M.COSTO_CONSULTA > 1000