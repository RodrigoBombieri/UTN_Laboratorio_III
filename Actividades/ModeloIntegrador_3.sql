-- RECUPERATORIO DE EXAMEN INTEGRADOR 2023 --
/* Aclaraciones:
OK-Un anuncio es realizado por un cliente y tiene un tipo de anuncio.
OK-Un cliente puede o no ser VIP.
OK-Un cliente puede tener un impuesto. El valor del impuesto debe ser mayor o igual a 0. (Ej. 0; 10.5; 21, etc.).
OK-El Alto y Ancho de los tipos de anuncios están expresados en centímetros, no pueden ser nulos y siempre son positivos.
OK-El precio base de un tipo de anuncio es requerido.
OK-Un costo adicional se aplica si un anuncio de un tipo determinado tiene un costo extra en un día particular
de la semana. Puede ocurrir que no se aplique un costo adicional a un anuncio,
OK-Un anuncio puede o no estar pagado. La seña y el importe final de un anuncio son valores monetarios.
OK-El día de la semana de CostosAdicionales es exactamente el mismo valor que devuelve la funcion DATEPART
para obtener el día de la semana.
OK-Adicional en CostosAdicionales es un valor monetario. No puede ser 0 ni negativo.
*/

-- 1) Realizar el código SQL que genere la base de datos con sus tablas y columnas. Agregar las restricciones necesarias.
CREATE DATABASE RecuIntegrador_2023
GO
USE RecuIntegrador_2023
GO
CREATE TABLE TiposAnuncios (
	IDTipoAnuncio INT NOT NULL PRIMARY KEY,
	Descripcion VARCHAR(100) NOT NULL,
	PrecioBase MONEY NOT NULL,
	Alto DECIMAL(5,1) NOT NULL CHECK (Alto > 0),
	Ancho DECIMAL(5,1) NOT NULL CHECK (Ancho > 0),
)
GO
CREATE TABLE CostosAdicionales(
	IDTipoAnuncio INT NOT NULL FOREIGN KEY REFERENCES TiposAnuncios(IDTipoAnuncio),
	DiaSemana TINYINT NULL CHECK (DiaSemana BETWEEN 1 AND 7),
	Adicional MONEY NULL CHECK (Adicional > 0)
)
GO
CREATE TABLE Clientes(
	IDCliente INT NOT NULL PRIMARY KEY,
	Nombres VARCHAR(50) NOT NULL,
	Apellidos VARCHAR (50) NOT NULL,
	Vip BIT DEFAULT 0 NOT NULL,
	Impuesto DECIMAL(4,1) NULL CHECK (Impuesto >= 0)
)
GO
CREATE TABLE Anuncios(
	IDAnuncio INT NOT NULL PRIMARY KEY,
	IDCliente INT NOT NULL FOREIGN KEY REFERENCES Clientes(IDCliente),
	IDTipoAnuncio INT NOT NULL FOREIGN KEY REFERENCES TiposAnuncios(IDTipoAnuncio),
	Fecha DATE NOT NULL,
	ImporteFinal MONEY NOT NULL CHECK (ImporteFinal > 0),
	Seña MONEY NULL CHECK(Seña > 0),
	Pagado BIT NULL
)


-- 2) Hacer un trigger que a partir de un nuevo anuncio determine el importe final y
-- la seña del mismo. El importe final se calcula en base al precio base del anuncio
-- y del costo adicional (si corresponde). Además, se debe aplicar el impuesto al cliente
-- sobre el precio base + costo adicional. La seña se calcula solamente para los clientes 
-- que no son VIP. Corresponde a un 20% del importe final. Si el cliente es VIP la seña es 0.