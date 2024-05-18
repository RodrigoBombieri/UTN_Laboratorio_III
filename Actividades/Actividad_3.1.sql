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

