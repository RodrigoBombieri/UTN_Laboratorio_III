-- ACTIVIDAD SUBE 2

-- A) Realizar un procedimiento almacenado llamado SP_Agregar_Usuario que permita registrar
-- un usuario en el sistema. El procedimiento debe recibir como parámetro DNI, Apellido, Nombre
-- Fecha de Nacimiento y los datos del domicilio del Usuario.

-- Creo una función para calcular la edad con la fecha de nacimiento
CREATE OR ALTER FUNCTION FN_CalcularEdad (@FechaNacimiento date)
RETURNS INT
AS
	BEGIN
	Declare @Edad int

	Select @Edad = 
		CASE
			WHEN MONTH(GETDATE()) > MONTH(@FechaNacimiento) OR
			(MONTH(GETDATE()) = MONTH(@FechaNacimiento) AND DAY(GETDATE()) >= DAY(@FechaNacimiento))
			THEN YEAR(GETDATE()) - YEAR(@FechaNacimiento)
					ELSE
						YEAR(GETDATE()) - YEAR(@FechaNacimiento) - 1
				END
			RETURN @Edad
		END


CREATE OR ALTER PROCEDURE SP_Agregar_Usuario(
	@Apellido varchar(50),
	@Nombre varchar(50),
	@DNI varchar(15),
	@FechaNacimiento date,
	@Domicilio varchar(50)
)
AS BEGIN
	Declare @Edad INT

	SET @Edad = dbo.FN_CalcularEdad(@FechaNacimiento)

	INSERT INTO Usuarios(Apellido, Nombres, DNI, Edad, Domicilio)
	VALUES(@Apellido, @Nombre, @DNI, @Edad, @Domicilio)
END

-- Uso del Store procedure:
SELECT* FROM Usuarios
EXEC SP_Agregar_Usuario 'Bombieri', 'Rodrigo', '36273666', '1990-12-20', 'Calle 13, Ciudad R'


-- B) Realizar un procedimiento almacenado llamado SP_Agregar_Tarjeta que dé de alta una tarjeta.
-- El procedimiento sólo debe recibir el DNI del usuario.
-- Como el sistema sólo permite una tarjeta activa por usuario, el procedimiento debe:
	-- Dar de baja la última tarjeta del usuario (si corresponde).
	-- Dar de alta la nueva tarjeta del usuario.
	-- Traspasar el saldo de la vieja tarjeta a la nueva tarjeta (si corresponde).

Select * from Tarjetas

CREATE OR ALTER PROCEDURE SP_Agregar_Tarjeta(
	@Documento varchar(15)
)
AS BEGIN
	DECLARE @IDUsuario BIGINT
    DECLARE @SaldoAntiguo MONEY
    DECLARE @UltimaTarjeta BIGINT
	
	-- Obtengo el ID del usuario
	SET @IDUsuario = (SELECT U.ID FROM Usuarios AS U
	WHERE U.DNI = @Documento)

	-- Capturo el saldo actual de su tarjeta
	SET @SaldoAntiguo = COALESCE((SELECT TOP 1 Saldo FROM Tarjetas 
	WHERE IDUsuario = @IDUsuario ORDER BY FechaPrimeraSube DESC), 0)
	
	-- Obtengo el ID de la última tarjeta del usuario
    SELECT TOP 1 @UltimaTarjeta = ID 
    FROM Tarjetas 
    WHERE IDUsuario = @IDUsuario 
    ORDER BY FechaPrimeraSube DESC

    -- Dar de baja la última tarjeta del usuario
    IF @UltimaTarjeta IS NOT NULL
    BEGIN
        UPDATE Tarjetas 
        SET BajaLogica = 1 
        WHERE ID = @UltimaTarjeta AND BajaLogica = 0
    END
	
	-- Dar de alta la tarjeta nueva (traspasar el saldo)
	INSERT INTO Tarjetas (FechaPrimeraSube, Saldo, CantidadViajes, BajaLogica, IDUsuario)
    VALUES (GETDATE(), @SaldoAntiguo, 0, 0, @IDUsuario)

END

EXEC SP_Agregar_Tarjeta '98765432'
SELECT*FROM Tarjetas


-- C) Realizar un procedimiento almacenado llamado SP_Agregar_Viaje que registre un
-- viaje a una tarjeta en particular. El procedimiento debe recibir: importe del viaje, 
-- nro de interno y nro de línea. El procedimiento deberá:
	-- Descontar el saldo.
	-- Registrar el viaje.
	-- Registrar el movimiento de débito.
-- NOTA una tarjeta no puede tener una deuda que supere los $2000.
CREATE OR ALTER PROCEDURE SP_Agregar_Viaje(
	@Importe MONEY,
	@NroInterno INT,
	@NroLinea VARCHAR(50)
)
AS BEGIN
	DECLARE @SaldoActual money
	DECLARE @SaldoFinal money
	DECLARE @IDColectivo BIGINT
	DECLARE @IDTarjeta BIGINT

	SET @IDTarjeta = (SELECT TOP 1 T.ID FROM TARJETAS AS T
	INNER JOIN VIAJES AS V ON T.ID = V.IDTarjeta
	INNER JOIN Colectivos AS C ON V.IDColectivos = C.ID
	WHERE C.Numero = @NroInterno AND C.LineaColectivo = @NroLinea)
	
	-- Capturar el Saldo actual de la Tarjeta
	SET @SaldoActual = (SELECT TOP 1 T.Saldo FROM Tarjetas as T
	INNER JOIN VIAJES AS V ON T.ID = V.IDTarjeta
	INNER JOIN Colectivos AS C ON V.IDColectivos = C.ID
	WHERE C.Numero = @NroInterno AND C.LineaColectivo = @NroLinea)

	SET @SaldoFinal = @SaldoActual - @Importe

	-- Verificar Deuda
	IF @SaldoFinal < -2000
	BEGIN
		RAISERROR('La deuda no puede superar los $2000', 16, 1)
		RETURN
	END
	-- Si la deuda no es menor a -2000, actualizamos el saldo de la tarjeta
	ELSE
	BEGIN 
		UPDATE Tarjetas 
			SET Saldo = @SaldoFinal, CantidadViajes = CantidadViajes + 1
			WHERE ID = @IDTarjeta;
	END

	SET @IDColectivo = (SELECT C.ID FROM Colectivos AS C
	WHERE C.Numero = @NroInterno AND C.LineaColectivo = @NroLinea)

	-- Registro del viaje
	INSERT INTO Viajes(Fecha, IDColectivos, IDTarjeta, ImporteTicket)
	VALUES(GETDATE(), @IDColectivo, @IDTarjeta, @Importe)

	-- Registro del movimiento
	INSERT INTO Movimientos(Fecha, Importe, TipoMovimiento)
	VALUES(GETDATE(), @Importe, 'D')
END

-- Uso del store procedure
EXEC SP_Agregar_Viaje 17, 101, 'Linea 1'

-- D) Realizar un procedimiento almacenado llamado SP_Agregar_Saldo que registre un movimiento
-- de crédito a una tarjeta en particular. El procedimiento debe recibir: número de tarjeta y el
-- importe a recargar. Modificar el Saldo de la tarjeta.
CREATE OR ALTER PROCEDURE SP_Agregar_Saldo(
	@NumTarjeta BIGINT,
	@Importe MONEY
)
AS BEGIN
	DECLARE @Credito CHAR
	DECLARE @SaldoAnterior MONEY
	DECLARE @MovimientoID BIGINT

	-- Capturamos el saldo anterior
	SET @SaldoAnterior = (SELECT T.Saldo FROM Tarjetas AS T
	WHERE T.NumeroTarjeta = @NumTarjeta)
	
	INSERT INTO Movimientos(Fecha, Importe, TipoMovimiento)
	VALUES(GETDATE(), @Importe, 'C')

	SET @MovimientoID = SCOPE_IDENTITY(); -- Obtiene el ID del nuevo movimiento

	INSERT INTO Movimientos_X_Tarjeta (IDMovimiento, IDTarjeta)
	VALUES (@MovimientoID, (SELECT ID FROM Tarjetas WHERE NumeroTarjeta = @NumTarjeta));

	UPDATE Tarjetas
	SET Saldo = @SaldoAnterior + @Importe
	WHERE Tarjetas.NumeroTarjeta = @NumTarjeta
END

-- Uso del Store Procedure
EXEC SP_Agregar_Saldo 1011, 12

-- E) Realizar un procedimiento almacenado llamado SP_Baja_Fisica_Usuario que elimine un
-- usuario del sistema. La eliminación deberá ser "en cascada". Ésto quiere decir que para
-- cada usuario primero deberán eliminarse todos los viajes y recargas de sus respectivas tarjetas. 
-- Luego, todas sus tarjetas y por último su registro de usuario.
CREATE OR ALTER PROCEDURE SP_Baja_Fisica_Usuario(
	@IDUsuario BIGINT
)
AS BEGIN
	BEGIN TRY
	-- Eliminar viajes del usuario
	DELETE V FROM Viajes AS V
	INNER JOIN Tarjetas AS T ON V.IDTarjeta = T.ID
	INNER JOIN Usuarios AS U ON T.IDUsuario = U.ID
	WHERE U.ID = @IDUsuario

	-- Eliminar recargas de las tarjetas.
	DELETE MXT FROM Movimientos_X_Tarjeta AS MXT
	INNER JOIN Tarjetas AS T ON MXT.IDTarjeta = T.ID
	INNER JOIN Usuarios AS U ON T.IDUsuario = U.ID
	WHERE U.ID = @IDUsuario

	-- Eliminar movimientos de la tarjeta del usuario
	DELETE M FROM Movimientos AS M
	INNER JOIN Movimientos_X_Tarjeta AS MXT ON M.ID = MXT.IDMovimiento
	INNER JOIN Tarjetas AS T ON MXT.IDTarjeta = T.ID
	INNER JOIN Usuarios AS U ON T.IDUsuario = U.ID
	WHERE U.ID = @IDUsuario

	-- Eliminar tarjetas del usuario
	DELETE T FROM TARJETAS AS T
	INNER JOIN Usuarios AS U ON T.IDUsuario = U.ID
	WHERE U.ID = @IDUsuario

	-- Eliminar el usuario
	DELETE FROM Usuarios
	WHERE Usuarios.ID = @IDUsuario
	END TRY
	
	BEGIN CATCH
		RAISERROR('Ocurrio un error', 16, 1)
	END CATCH

END

-- Uso del Store procedure
exec SP_Baja_Fisica_Usuario 2