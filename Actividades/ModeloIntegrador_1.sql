-- MODELO DE EXAMEN INTEGRADOR 2024 --

/* Aclaraciones:
	-Una pieza no defectuosa es aquella que haya sido producida dentro del rango de
	las medidas m�nimo y m�ximo (ambos inclusive).
	-Una pieza defectuosa es aquella que haya sido producida fuera del rango de las medidas
	m�nima y m�xima.
	-El primer a�o de trabajo de un operario es el a�o en que fue dado de alta.
	-Una producci�n se considera "estropeada" si la pieza producida es defectuosa. El costo
	monetario de la producci�n estropeada es el producto de la cantidad de piezas producidas
	por el costo unitario de producci�n de la pieza.
*/

/* 1) La f�brica quiere evitar que empleados sin experiencia mayor a 5 a�os puedan generar
producciones de piezas cuyo costo unitario de producci�n supere los $15.
Hacer un TRIGGER que asegure �sta comprobaci�n para registros de producci�n cuya fecha sea
mayor a la actual. En caso de poder registrar la informaci�n, calcular el costo total de producci�n.
*/
CREATE OR ALTER TRIGGER TR_EmpleadosSinExperiencia ON Produccion
INSTEAD OF INSERT
AS BEGIN
	BEGIN TRY
	BEGIN TRANSACTION
	
	DECLARE @IDProduccion BIGINT,--
			@IDOperario BIGINT,--
			@IDPieza BIGINT,--
			@Fecha DATE,--
			@Medida DECIMAL(5,3),
			@Cantidad INT,--
			@CostoTotal MONEY,--
			@AnioAlta smallint,--
			@CostoUnitarioProd MONEY,--
			@CostoFinal MONEY --
	--Obtengo valores de la fila insertada:
	SELECT  @IDProduccion = IDProduccion,--
			@IDOperario = I.IDOperario,--
			@IDPieza = I.IDPieza,--
			@Fecha = Fecha,--
			@Medida = Medida,
			@Cantidad = Cantidad,--
			@CostoTotal = CostoTotal,--
			@AnioAlta = O.AnioAlta,--
			@CostoUnitarioProd = P.CostoUnitarioProduccion--
	FROM inserted AS I
	INNER JOIN Operarios AS O ON I.IDOperario = O.IDOperario
	INNER JOIN Piezas AS P ON I.IDPieza = P.IDPieza
	WHERE P.IDPieza = @IDPieza

	-- Si la fecha de la produccion ingresada es anterior a la actual,
	-- o la experiencia menor a 5 a�os se cancela el trigger.
	IF @Fecha < GETDATE() OR YEAR(GETDATE()) - YEAR(@AnioAlta) + 1 < 5  BEGIN
		RAISERROR('Fecha incorrecta.', 16,1)
		RETURN
	END
	-- Si el costo unitario es mayor a $15 finaliza el trigger.
	IF @CostoUnitarioProd > 15 BEGIN
		RAISERROR('Costo unitario mayor a $15.', 16,1)
		RETURN
	END
	-- Actualizo el costo total de la Producci�n.
	SET @CostoFinal = @Cantidad * @CostoUnitarioProd
	
	--Inserto el nuevo registro de Producci�n
	INSERT INTO Produccion(IDOperario, IDPieza, Fecha, Medida, Cantidad, CostoTotal)
	VALUES(@IDOperario, @IDPieza, @Fecha, @Medida, @Cantidad, @CostoFinal)

	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		PRINT ERROR_MESSAGE()
	END CATCH
END

-- 2) Hacer un listado que permita visualizar el nombre del material, el nombre de la pieza y
-- la cantidad de operarios que nunca produjeron esa pieza.
DECLARE @CantOperarios Integer
Select @CantOperarios = COUNT(*) From Operarios
SELECT M.Nombre AS Material, P.Nombre AS Pieza, 
@CantOperarios - (SELECT COUNT(distinct IDOperario) fROM Produccion WHERE IDPieza = P.IDPieza) AS "Cantidad de operarios que no produjeron esa pieza"
FROM Materiales AS M
INNER JOIN Piezas AS P ON M.IDMaterial = P.IDMaterial

-- 3) Hacer un procedimiento almacenado llamado Punto_3 que reciba el nombre de un material y un 
-- valor porcentual (admite 2 decimales) y modifique el precio unitario de producci�n a partir de ese
-- valor porcentual a todas las piezas que sean de este material.
	-- Por ejemplo:
	-- Si el procedimiento recibe 'Acero' y 50, debe aumentar el precio unitario de producci�n
	-- de todas las piezas de acero en un 50%.
	-- Si el procedimiento recibe 'Vidrio' y -25 debe disminuir el precio unitario de producci�n
	-- de todas las piezas de vidrio en un 25%.
-- NOTA: No se debe permitir hacer un descuento del 100% ni un aumento mayor a 1000%.
CREATE OR ALTER PROCEDURE SP_Punto_3 (
	@Material VARCHAR(50),
	@AumentoDescuento DECIMAL(6,2) -- hasta 999.99
)
AS BEGIN
	BEGIN TRY
		BEGIN TRANSACTION

		-- Validamos los porcentajes de descuento o aumento
		IF @AumentoDescuento < -100 OR @AumentoDescuento > 1000
		BEGIN
			RAISERROR('Valor de Aumento/Descuento inv�lido',16,1)
			RETURN
		END

		 -- Actualizar el costo total de todas las producciones relacionadas con el material
        UPDATE Produccion
        SET CostoTotal = CASE WHEN @AumentoDescuento < 0 THEN CostoTotal - (ABS(@AumentoDescuento) * CostoTotal /100)
                              ELSE CostoTotal + (@AumentoDescuento * CostoTotal / 100.0)
                         END
        WHERE IDPieza IN (
		SELECT IDPieza FROM Piezas 
		WHERE IDMaterial = (SELECT IDMaterial FROM Materiales WHERE Nombre LIKE @Material)
		)

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		PRINT ERROR_MESSAGE()
	END CATCH
END

exec SP_Punto_3 'Acero', -10
select * from Produccion

-- 4) Hacer un procedimiento almacenado llamado SP_Punto_4 que reciba dos fechas y que
-- calcule e informe el costo total de todas las producciones que se registraron entre
-- esas fechas.
CREATE OR ALTER PROCEDURE SP_Punto_4(
	@PrimerFecha DATE,
	@SegundaFecha DATE
)
AS BEGIN
	BEGIN TRY
	BEGIN TRANSACTION
	-- Determinar cu�l es la fecha menor y cu�l la mayor
	DECLARE @FechaMenor DATE
	DECLARE @FechaMayor DATE

	IF @PrimerFecha > @SegundaFecha
	BEGIN
		SET @FechaMayor = @PrimerFecha
		SET @FechaMenor = @SegundaFecha
	END
	ELSE IF @PrimerFecha = @SegundaFecha
	BEGIN
		SET @FechaMenor = @PrimerFecha
		SET @FechaMayor = @SegundaFecha
	END
	ELSE
	BEGIN
		SET @FechaMayor = @SegundaFecha
		SET @FechaMenor = @PrimerFecha
	END

	SELECT @FechaMenor AS FechaMenor, @FechaMayor AS FechaMayor, SUM(PR.CostoTotal) AS "Costo total" FROM Produccion AS PR
	WHERE PR.Fecha BETWEEN @FechaMenor AND @FechaMayor


	COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
	ROLLBACK TRANSACTION
	PRINT ERROR_MESSAGE()
	END CATCH
END

EXEC SP_Punto_4 '2023-02-20', '2023-04-05'
select * from Produccion

-- 5) Hacer un listado que permita visualizar el nombre de cada material y el costo
-- total de las producciones estropeadas de ese material. S�lo listar aquellos registros
-- que totalicen un costo total mayor a $100.
CREATE OR ALTER VIEW VW_Punto_5
AS
SELECT M.Nombre AS Material, SUM(PR.CostoTotal) AS "Costo total de producciones estropeadas"
FROM Materiales as M
INNER JOIN Piezas as P ON M.IDMaterial = P.IDMaterial
INNER JOIN Produccion AS PR ON P.IDPieza = PR.IDPieza
WHERE PR.Medida < P.MedidaMinima OR PR.Medida > P.MedidaMaxima
GROUP BY M.Nombre
HAVING SUM(PR.CostoTotal) > 100

