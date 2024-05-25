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
