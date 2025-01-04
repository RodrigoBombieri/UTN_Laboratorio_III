-- EXAMEN INTEGRADOR 2024 - 1C--
-- Rodrigo Sebastián Bombieri

-- A --
CREATE OR ALTER TRIGGER TR_RegistrarAdelanto 
ON Adelantos
INSTEAD OF INSERT
AS BEGIN
	BEGIN TRY
		DECLARE @MontoAdelanto MONEY
		DECLARE @IDEmpleado BIGINT
		DECLARE @SueldoEmpleado MONEY
		DECLARE @AnioIngreso INT
		DECLARE @Antiguedad SMALLINT
		DECLARE @FechaAdelanto DATE
		DECLARE @Contador INT

		SELECT @MontoAdelanto = Monto,
				@IDEmpleado = IDEmpleado,
				@FechaAdelanto = Fecha
		FROM inserted

		SET @SueldoEmpleado = (SELECT Sueldo FROM Empleados
		WHERE IDEmpleado = @IDEmpleado)

		SET @AnioIngreso = (SELECT AnioIngreso FROM Empleados
		WHERE IDEmpleado = @IDEmpleado)

		SET @Antiguedad = (YEAR(GETDATE()) - @AnioIngreso)

		SELECT @Contador = COUNT(*) FROM Adelantos
		WHERE IDEmpleado = @IDEmpleado AND YEAR(Fecha) = YEAR(@FechaAdelanto)

		IF @MontoAdelanto <= 0 OR @MontoAdelanto > (@SueldoEmpleado * 0.6) BEGIN
			RAISERROR('El monto de adelanto es inválido', 16, 1)
			RETURN
		END

		IF @Antiguedad <= 5 BEGIN
			RAISERROR('Debe tener más de 5 años de antigüedad para solicitar un adelanto', 16, 1)
			RETURN
		END

		IF @Contador > 0 BEGIN
			RAISERROR('No puede solicitar un nuevo adelanto en éste año calendario', 16, 1)
			RETURN
		END

		BEGIN TRANSACTION

		INSERT INTO Adelantos(IDEmpleado, Fecha, Monto)
		VALUES(@IDEmpleado, GETDATE(), @MontoAdelanto)
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		PRINT ERROR_MESSAGE()
	END CATCH
END



-- B --
CREATE OR ALTER PROCEDURE SP_PuntoB(
	@FechaInicio DATE,
	@FechaFin DATE
)
AS BEGIN
	SELECT C.Nombre AS Categoria, COUNT(DISTINCT E.IDEmpleado) AS "Cantidad de Empleados" FROM Categorias AS C
	INNER JOIN Empleados AS E ON C.IDCategoria = E.IDCategoria
	INNER JOIN Adelantos AS A ON E.IDEmpleado = A.IDEmpleado
	WHERE A.Fecha BETWEEN @FechaInicio AND @FechaFin
	GROUP BY C.Nombre
END



--C --
-- En éste punto decidí no utilizar coalesce en la función SUM ya que utilizando HAVING va a filtrar si o si los que tengan
-- monto mayor a 500, además el monto está especificado como not null en la tabla de Adelantos.
SELECT E.Nombre, E.Apellido, SUM(A.Monto) AS "Monto Total en Adelantos en el año actual" FROM Empleados AS E
INNER JOIN Adelantos AS A ON E.IDEmpleado = A.IDEmpleado
WHERE YEAR(A.Fecha) = YEAR(GETDATE())
GROUP BY E.Nombre, E.Apellido
HAVING SUM(A.Monto) > 500



-- D --
CREATE TABLE Dictamenes(
	IDDictamen BIGINT NOT NULL PRIMARY KEY IDENTITY(1,1),
	IDEmpleado BIGINT NOT NULL FOREIGN KEY REFERENCES Empleados(IDEmpleado),
	IDAdelanto BIGINT NOT NULL FOREIGN KEY REFERENCES Adelantos(IDAdelanto),
	Conclusion BIT NOT NULL DEFAULT 1,
	Fecha DATETIME NOT NULL,
	Descripcion VARCHAR(300) NOT NULL
	CONSTRAINT UQ_DictamenAdelanto UNIQUE(IDAdelanto)
)






