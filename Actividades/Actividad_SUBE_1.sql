-- ACTIVIDAD SUBE 1

-- 1) Realizar una vista que permita conocer los datos de los usuarios y sus respectivas tarjetas.
-- La misma debe contener: Apellido y nombre del usuario, número de la tarjeta SUBE, estado de la tarjeta y saldo.

CREATE OR ALTER VIEW VW_DatosUsuarioTarjeta
AS
SELECT U.Apellido, U.Nombres, T.NumeroTarjeta as "Número de Tarjeta", T.BajaLogica AS Estado, T.Saldo
FROM Usuarios as U
INNER JOIN Tarjetas AS T ON U.ID = T.IDUsuario

SELECT * FROM VW_DatosUsuarioTarjeta

-- 2) Realizar una vista que permita conocer los datos de los usuarios y sus respectivos viajes. La misma
-- debe contener: Apellido y Nombre del usuario, número de tarjeta SUBE, fecha del viaje, importe del viaje,
-- número de interno y nombre de la línea.
CREATE OR ALTER VIEW VW_ViajesDeUsuarios
AS
SELECT U.Apellido, U.Nombres, T.NumeroTarjeta, V.Fecha, V.ImporteTicket AS Importe, C.Numero AS "Nº de Colectivo",
C.LineaColectivo AS "Linea"
FROM Usuarios AS U
INNER JOIN Tarjetas AS T ON U.ID = T.IDUsuario
INNER JOIN Viajes AS V ON T.ID = V.IDTarjeta
INNER JOIN Colectivos AS C ON V.IDColectivos = C.ID

-- 3) Realizar una vista que permita conocer los datos estadísticos de cada tarjeta. La misma debe
-- contener: Apellido y nombre del usuario, número de la tarjeta SUBE, cantidad de viajes realizados,
-- total de dinero acreditado (históricamente), cantidad de recargas, importe de recarga promedio (en pesos),
-- estado de la tarjeta.
CREATE OR ALTER VIEW VW_DatosEstadísticosTarjeta
AS
SELECT U.Apellido, U.Nombres, T.NumeroTarjeta, T.CantidadViajes, M.Importe, COUNT(M.ID) AS "Cantidad de Recargas", 
AVG(M.Importe) AS "Importe de recarga promedio", T.BajaLogica
FROM Usuarios AS U
INNER JOIN Tarjetas AS T ON U.ID = T.IDUsuario
INNER JOIN Viajes as V ON T.ID = V.IDTarjeta
INNER JOIN Movimientos_X_Tarjeta AS MXT ON T.ID = MXT.IDTarjeta
INNER JOIN Movimientos AS M ON MXT.IDMovimiento = M.ID
WHERE M.TipoMovimiento LIKE 'C'
GROUP BY U.Apellido, U.Nombres, T.NumeroTarjeta, T.CantidadViajes, M.Importe, T.BajaLogica
