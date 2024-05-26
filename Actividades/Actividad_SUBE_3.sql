-- ACTIVIDAD SUBE 3

/*Rehacer los procedimientos almacenados B, C y D para que se ejecuten dentro de una transacci�n.*/

-- B) Realizar un procedimiento almacenado llamado SP_Agregar_Tarjeta que d� de alta una tarjeta.
-- El procedimiento s�lo debe recibir el DNI del usuario.
-- Como el sistema s�lo permite una tarjeta activa por usuario, el procedimiento debe:
	-- Dar de baja la �ltima tarjeta del usuario (si corresponde).
	-- Dar de alta la nueva tarjeta del usuario.
	-- Traspasar el saldo de la vieja tarjeta a la nueva tarjeta (si corresponde).
CREATE OR ALTER PROCEDURE SP_Agregar_Tarjeta(
	@DNI varchar(50)
)
AS BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			DECLARE @IDUsuario BIGINT
			DECLARE @SaldoAnterior MONEY
			DECLARE @UltimaTarjeta BIGINT

			-- Obtengo el ID del usuario
			SET @IDUsuario = (SELECT U.ID FROM Usuarios AS U
			WHERE U.DNI = @DNI)

			-- Capturo el saldo actual de su tarjeta
			SET @SaldoAnterior = COALESCE((SELECT TOP 1 Saldo FROM Tarjetas 
			WHERE IDUsuario = @IDUsuario ORDER BY FechaPrimeraSube DESC), 0)

			-- Obtengo el ID de la �ltima tarjeta del usuario
			SELECT TOP 1 @UltimaTarjeta = ID 
			FROM Tarjetas 
			WHERE IDUsuario = @IDUsuario 
			ORDER BY FechaPrimeraSube DESC

			-- Dar de baja la �ltima tarjeta del usuario
			IF @UltimaTarjeta IS NOT NULL
			BEGIN
				UPDATE Tarjetas 
				SET BajaLogica = 1 
				WHERE ID = @UltimaTarjeta AND BajaLogica = 0
			END

			-- Dar de alta la tarjeta nueva (traspasar el saldo)
			INSERT INTO Tarjetas(FechaPrimeraSube, Saldo, CantidadViajes, BajaLogica, IDUsuario)
			VALUES(GETDATE(), @SaldoAnterior, 0, 0, @IDUsuario) 

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		PRINT ERROR_MESSAGE()
		ROLLBACK TRANSACTION
	END CATCH
END

-- C) Realizar un procedimiento almacenado llamado SP_Agregar_Viaje que registre un
-- viaje a una tarjeta en particular. El procedimiento debe recibir: importe del viaje, 
-- nro de interno y nro de l�nea. El procedimiento deber�:
	-- Descontar el saldo.
	-- Registrar el viaje.
	-- Registrar el movimiento de d�bito.
-- NOTA una tarjeta no puede tener una deuda que supere los $2000.
CREATE OR ALTER PROCEDURE SP_Agregar_Viaje(
	@Importe MONEY,
	@NroInterno SMALLINT, 
	@NroLinea VARCHAR(50)
)
AS BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			DECLARE @SaldoAnterior MONEY
			DECLARE @IDTarjeta BIGINT
			DECLARE @SaldoActual MONEY 
			DECLARE @IDColectivo BIGINT

			SET @IDColectivo = (SELECT C.ID FROM Colectivos AS C
			WHERE C.Numero = @NroInterno AND C.LineaColectivo = @NroLinea)

			SET @IDTarjeta = (SELECT T.ID FROM Tarjetas AS T
			INNER JOIN Viajes AS V ON T.ID = V.IDTarjeta
			INNER JOIN Colectivos AS C ON V.IDColectivos = C.ID
			WHERE C.Numero = @NroInterno AND C.LineaColectivo = @NroLinea)

			SET @SaldoAnterior = (SELECT T.Saldo FROM Tarjetas AS T
			INNER JOIN Viajes AS V ON T.ID = V.IDTarjeta
			INNER JOIN Colectivos AS C ON V.IDColectivos = C.ID
			WHERE C.Numero = @NroInterno AND C.LineaColectivo = @NroLinea)

			SET @SaldoActual = @SaldoAnterior - @Importe

			-- Verificar Deuda menor a -$2000
			IF @SaldoActual < -2000
			BEGIN
				RAISERROR('La deuda no puede superar los -$2000', 16, 1)
				RETURN
			END
			ELSE
			BEGIN
				UPDATE Tarjetas
				SET Saldo = @SaldoActual, CantidadViajes = CantidadViajes + 1
				WHERE ID = @IDTarjeta
			END

			-- Registro del viaje
			INSERT INTO Viajes(Fecha, IDColectivos, IDTarjeta, ImporteTicket)
			VALUES(GETDATE(), @IDColectivo, @IDTarjeta, @Importe)

			-- Registro del movimiento
			INSERT INTO Movimientos(Fecha, Importe, TipoMovimiento)
			VALUES(GETDATE(), @Importe, 'D')

		COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		PRINT ERROR_MESSAGE()
		ROLLBACK TRANSACTION
	END CATCH
END


-- D) Realizar un procedimiento almacenado llamado SP_Agregar_Saldo que registre un movimiento
-- de cr�dito a una tarjeta en particular. El procedimiento debe recibir: n�mero de tarjeta y el
-- importe a recargar. Modificar el Saldo de la tarjeta.
CREATE OR ALTER PROCEDURE SP_Agregar_Saldo(
	@NumeroTarjeta BIGINT,
	@ImporteACargar MONEY
)
AS BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			DECLARE @SaldoAnterior MONEY
			DECLARE @MovimientoID BIGINT
			
			SET @SaldoAnterior = (SELECT T.Saldo FROM Tarjetas AS T
			WHERE T.NumeroTarjeta = @NumeroTarjeta)
			-- Registrar CR�DITO a una tarjeta

			INSERT INTO Movimientos(Fecha, Importe, TipoMovimiento)
			VALUES (GETDATE(), @ImporteACargar, 'C')

			SET @MovimientoID = SCOPE_IDENTITY(); -- Obtiene el ID del nuevo movimiento

			INSERT INTO Movimientos_X_Tarjeta (IDMovimiento, IDTarjeta)
			VALUES (@MovimientoID, (SELECT ID FROM Tarjetas WHERE NumeroTarjeta = @NumeroTarjeta));

			-- Actualizar Saldo de tarjeta
			UPDATE Tarjetas
			SET Saldo = @SaldoAnterior + @ImporteACargar
			WHERE NumeroTarjeta = @NumeroTarjeta

		COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		PRINT ERROR_MESSAGE()
		ROLLBACK TRANSACTION
	END CATCH
END

EXEC SP_Agregar_Saldo 1019, 13