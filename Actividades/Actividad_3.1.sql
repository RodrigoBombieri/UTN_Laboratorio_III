-- ACTIVIDAD 3.1 --
-- Objetos de bases de datos
-- Realizar consultas en lenguaje T-SQL que permitan crear funciones, vistas y procedimientos almacenados:

-- Agregar una columna a la tabla Cursos llamada DebeSerMayorDeEdad bit que permita determinar
-- si para realizar el curso el usuario debe ser mayor de edad (edad>=18). El valor por defecto
-- de la columna debe ser un 0. Luego, modificar algunos cursos para que el valor de la nueva columna sea 1.
ALTER TABLE Cursos
ADD DebeSerMayorDeEdad bit not null default 0

UPDATE Cursos
SET DebeSerMayorDeEdad = 1
WHERE ID IN (1,3,5,7,9,11)

-- 1) Hacer una función llamada FN_PagosxUsuario que a partir de un IDUsuario
-- devuelva el total abonado en concepto de pagos. Si no hay pagos debe retornar 0.
GO
CREATE OR ALTER FUNCTION FN_PagosxUsuario (@IDUsuario INT)
RETURNS money
	AS
	BEGIN
		Declare @TotalPagos money

		Select @TotalPagos = Coalesce(SUM(P.Importe), 0) From Pagos AS P
		INNER JOIN Inscripciones AS I ON P.IDInscripcion = I.ID
		INNER JOIN Usuarios AS U ON I.IDUsuario = U.ID
		WHERE U.ID = @IDUsuario;
		
		RETURN @TotalPagos
	END

-- Uso de la Función:
Select U.NombreUsuario, dbo.FN_PagosxUsuario(U.ID) AS "Importe total abonado"
From Usuarios as U
Go

-- 2) Hacer una función llamada FN_DeudaxUsuario que a partir de un IDUsuario
-- devuelva el total adeudado. Si no hay deuda debe retornar 0.
CREATE OR ALTER FUNCTION FN_DeudaxUsuario (@IDUsuario INT)
RETURNS money
	AS
		BEGIN
			Declare @Deuda money

			Select @Deuda = COALESCE(SUM(I.Costo) - SUM(P.Importe), 0) From Inscripciones as I
			inner join Pagos AS P ON I.ID = P.IDInscripcion
			INNER JOIN Usuarios AS U ON I.IDUsuario = U.ID
			WHERE U.ID = @IDUsuario

			RETURN @Deuda
		END

-- Uso de la Función:
Select DISTINCT U.ID, U.NombreUsuario, SUM(I.Costo), SUM(P.Importe) AS "Pagado", dbo.FN_DeudaxUsuario(U.ID) as "Importe total adeudado"
From Usuarios as U
INNER join Inscripciones as I ON U.ID = I.IDUsuario
INNER JOIN Pagos AS P ON I.ID = P.IDInscripcion
--WHERE U.ID = 1
GROUP BY U.ID, U.NombreUsuario
Go

-- 3) Hacer una función llamada FN_CalcularEdad que a partir de un IDUsuario devuelva
-- la edad del mismo. La edad es un valor entero.
CREATE OR ALTER FUNCTION FN_CalcularEdad (@IDUsuario INT)
RETURNS INT
	AS
		BEGIN
			Declare @Edad int

			Select @Edad = 
				CASE
					WHEN MONTH(GETDATE()) > MONTH(DP.Nacimiento) OR
					(MONTH(GETDATE()) = MONTH(DP.Nacimiento) AND DAY(GETDATE()) >= DAY(DP.Nacimiento))
						THEN YEAR(GETDATE()) - YEAR(DP.Nacimiento)
					ELSE
						YEAR(GETDATE()) - YEAR(DP.Nacimiento) -1
				END
			From Datos_Personales AS DP
			inner join Usuarios as U ON DP.ID = U.ID
			WHERE U.ID = @IDUsuario

			RETURN @Edad
		END
-- Uso de la Función:
Select U.ID, U.NombreUsuario, dbo.FN_CalcularEdad(U.ID) From Usuarios as U
WHERE U.ID = 7

-- 4) Hacer una función llamada FN_PuntajeCurso que a partir de un IDCurso devuelva
-- el promedio de puntaje en concepto de reseñas.
CREATE OR ALTER FUNCTION FN_PuntajeCurso(@IDCurso INT)
RETURNS DECIMAL
	BEGIN
		DECLARE @PromedioPuntaje DECIMAL

		Select @PromedioPuntaje = AVG(R.Puntaje) From Reseñas as R
		INNER JOIN Inscripciones as I ON R.IDInscripcion = I.ID
		INNER JOIN Cursos as C ON I.IDCurso = C.ID
		WHERE C.ID = @IDCurso

		RETURN @PromedioPuntaje
	END

-- Uso de la Función:
Select C.Nombre AS CURSO, dbo.FN_PuntajeCurso(C.ID)
From Cursos as C
WHERE C.ID = 1

-- 5) Hacer una vista que muestre por cada usuario el apellido y nombre, una columna
-- llamada Contacto que muestre el celular, si no tiene celular el teléfono, si no tiene
-- teléfono el email, si no tiene email el domicilio. También debe mostrar la edad del 
-- usuario, el total pagado y el total adeudado.

CREATE OR ALTER VIEW VW_DatosUsuario
AS
SELECT
	DP.ID, --→ Se agregó para la consigna 6
	DP.Apellidos,
	DP.Nombres,
	--Contacto
	CASE
		WHEN DP.Celular IS NOT NULL THEN DP.Celular
		WHEN DP.Telefono IS NOT NULL THEN DP.Telefono
		WHEN DP.Email IS NOT NULL THEN DP.Email
		ELSE DP.Domicilio
	END AS Contacto,
	----
	dbo.FN_CalcularEdad(U.ID) AS Edad,
	dbo.FN_PagosxUsuario(U.ID) AS Pagos,
	dbo.FN_DeudaxUsuario(U.ID) AS Deudas

From Datos_Personales AS DP
INNER JOIN Usuarios AS U ON DP.ID = U.ID

-- Uso de la vista:
SELECT * FROM VW_DatosUsuario

-- 6) Hacer uso de la vista creada anteriormente para obtener la cantidad de usuarios
-- que adeuden más de lo que pagaron.
SELECT COUNT(*) AS "Usuarios que adeudan más de lo que pagaron" FROM VW_DatosUsuario
WHERE dbo.FN_DeudaxUsuario(ID) > dbo.FN_PagosxUsuario(ID)

