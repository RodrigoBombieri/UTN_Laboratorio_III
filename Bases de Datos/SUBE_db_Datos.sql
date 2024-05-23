-- Insertar datos en la tabla EmpresasColectivos
INSERT INTO EmpresasColectivos (Nombre, DomicilioLegal) VALUES 
('Empresa A', 'Calle 123, Ciudad A'),
('Empresa B', 'Avenida Principal, Ciudad B'),
('Empresa C', 'Calle Central, Ciudad C');

-- Insertar datos en la tabla Colectivos
INSERT INTO Colectivos (Numero, LineaColectivo, IDEmpresa) VALUES 
(101, 'Linea 1', 1),
(202, 'Linea 2', 2),
(303, 'Linea 3', 3),
(404, 'Linea 4', 1),
(505, 'Linea 5', 2);

-- Insertar datos en la tabla Usuarios
INSERT INTO Usuarios (Apellido, Nombres, DNI, Domicilio, Edad, BajaLogica) VALUES 
('Gomez', 'Juan', '12345678', 'Calle 456, Ciudad X', 30, 0),
('Perez', 'Maria', '98765432', 'Avenida 789, Ciudad Y', 25, 0),
('Lopez', 'Pedro', '54321678', 'Calle 012, Ciudad Z', 40, 0);

-- Insertar datos en la tabla Tarjetas
INSERT INTO Tarjetas (FechaPrimeraSube, Saldo, CantidadViajes, BajaLogica, IDUsuario) VALUES 
('2024-01-01', 100.00, 10, 0, 1),
('2024-02-01', 50.00, 5, 0, 2),
('2024-03-01', 75.00, 7, 0, 3);

-- Insertar datos en la tabla Viajes
INSERT INTO Viajes (Fecha, IDColectivos, IDTarjeta, ImporteTicket) VALUES 
('2024-01-02', 1, 1, 10.00),
('2024-02-05', 2, 2, 5.00),
('2024-03-10', 3, 3, 7.50),
('2024-04-15', 4, 1, 10.00),
('2024-05-20', 5, 2, 5.00);

-- Insertar datos en la tabla Movimientos
INSERT INTO Movimientos (Fecha, Importe, TipoMovimiento) VALUES 
('2024-01-02', 10.00, 'Recarga'),
('2024-02-05', 5.00, 'Recarga'),
('2024-03-10', 7.50, 'Recarga'),
('2024-04-15', 10.00, 'Recarga'),
('2024-05-20', 5.00, 'Recarga');

-- Insertar datos en la tabla Movimientos_X_Tarjeta
INSERT INTO Movimientos_X_Tarjeta (IDMovimiento, IDTarjeta) VALUES 
(1, 1),
(2, 2),
(3, 3),
(4, 1),
(5, 2);
