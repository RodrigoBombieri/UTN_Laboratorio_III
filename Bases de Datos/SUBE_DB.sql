CREATE DATABASE SUBE
GO
USE SUBE
GO
Create Table EmpresasColectivos(
	ID bigint not null primary key identity(1,1),
	Nombre varchar(50) not null,
	DomicilioLegal varchar(100) not null
)
GO
Create Table Colectivos(
	ID bigint not null primary key identity(1,1),
	Numero smallint not null,
	LineaColectivo varchar(50) not null,
	IDEmpresa bigint not null foreign key references EmpresasColectivos(ID)
)
GO
Create Table Usuarios(
	ID bigint not null primary key identity(1,1),
	Apellido varchar(50) not null,
	Nombres varchar(50) not null,
	DNI varchar(15) not null unique,
	Domicilio varchar(50) not null,
	Edad tinyint not null,
	BajaLogica bit not null default 0
)
GO
Create Table Tarjetas(
	ID bigint not null primary key identity(1,1),
	FechaPrimeraSube datetime not null,
	Saldo money not null,
	CantidadViajes int not null,
	BajaLogica bit not null default 0,
	IDUsuario bigint not null foreign key references Usuarios(ID)
)
GO
Create Table Viajes(
	ID bigint not null primary key identity(1,1),
	Fecha datetime not null,
	IDColectivos bigint not null foreign key references Colectivos(ID),
	IDTarjeta bigint not null foreign key references Tarjetas(ID),
	ImporteTicket money not null check (ImporteTicket > 0)
)
GO
Create Table Movimientos(
	ID bigint not null primary key identity(1,1),
	Fecha datetime not null,
	Importe money not null,
	TipoMovimiento char not null
)
GO
Create Table Movimientos_X_Tarjeta(
	IDMovimiento bigint not null foreign key references Movimientos(ID),
	IDTarjeta bigint not null foreign key references Tarjetas(ID),
	Primary key (IDMovimiento, IDTarjeta)
)
GO
