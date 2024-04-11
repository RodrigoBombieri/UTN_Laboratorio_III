Create Database Clase02_20241C
go
Use Clase02_20241C
go
Create Table Empleado(
	Legajo bigint not null identity (1000, 1),
	IDArea int not null,
	Apellidos varchar(50) not null,
	Nombre varchar(50) not null,
	Nacimiento date null
	primary key(Legajo)
)
go
Create Table Areas(
	ID int not null,
	Nombre varchar(50) not null,
	Presupuesto money not null,
	Mail varchar(100) not null
)

-- Agregamos una columna TELEFONO a Empleado
Alter Table Empleado
Add Telefono varchar(15) null

-- SI QUIERO AGREGAR RESTRICCIONES LUEGO DE CREAR LAS TABLAS
-- Agregar PK a Areas(ID)
Alter Table Areas
Add Constraint PK_Areas Primary Key (ID)

-- Agregar Foering Key a IDArea en Empleados
Alter Table Empleado
Add Constraint FK_Empleado_Areas Foreign Key (IDArea) References Areas(ID)

-- Agregar unique a Mail en Areas
Alter Table Areas
Add Constraint UQ_Areas_Mail Unique(Mail)

-- Agrega un check a Presupuesto en Areas
Alter Table Areas
Add Constraint CHK_Presupuesto Check (Presupuesto > 0)