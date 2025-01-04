-- MODELO DE EXAMEN INTEGRADOR 2024 --

/* Aclaraciones:
- Ningún campo acepta valores nulos.
- Todas las columnas ID son primary key y autonuméricas.
- El ranking de un usuario consite en el promedio de puntajes de todas las fotografías
de su autoría. Si no tiene promedio, el ranking del usuario debe ser 0.
- Una fotografía tiene un participante que es el creador. Una votación tiene un votante,
también participante, que es quien vota.
- Un concurso cuyo RankingMinimo es 0.0 significa que acepta cualquier participante.
*/

-- 1) Hacer un procedimiento almacenado llamado SP_Descalificar que reciba un ID de 
-- fotografía y realice la descalificación de la misma. También debe eliminar todas las 
-- votaciones registradas a la fotografía en cuestión. Sólo se puede descalificar una fotografía
-- si pertenece a un concurso no finalizado.
CREATE OR ALTER PROCEDURE SP_Descalificar(
	@IDFotografía BIGINT
)
AS BEGIN
	DECLARE @InicioConcurso DATE
	DECLARE @FinConcurso DATE
	DECLARE @Descalificada BIT
	DECLARE @FechaPublicacion DATE
	
	Select @InicioConcurso = C.Inicio, @FinConcurso = C.Fin, @Descalificada = F.Descalificada, @FechaPublicacion = F.Publicacion
	FROM Concursos AS C
	INNER JOIN Fotografias as F ON C.ID = F.IDConcurso
	WHERE F.ID = @IDFotografía

	IF @FechaPublicacion NOT BETWEEN @InicioConcurso AND @FinConcurso BEGIN
		RAISERROR('El concurso ya finalizó', 16, 1)
		RETURN
	END

	UPDATE Fotografias SET @Descalificada = 1 WHERE ID = @IDFotografía

	DELETE Votaciones WHERE IDFotografia = @IDFotografía
END

-- 2) Al insertar una fotografía verificar que el usuario creador de la fotografía
-- tenga el ranking suficiente para participar del concurso. También se debe verificar
-- que el concurso haya iniciado y no finalizado. Si ocurriese un error, mostrarlo con
-- un mensaje aclaratorio. De lo contrario, insertar el registro teniendo en cuenta que
-- la fecha de publicación es la fecha y la hora del sistema.
CREATE OR ALTER TRIGGER TR_Punto_2 ON Fotografias
INSTEAD OF INSERT
AS BEGIN
BEGIN TRY
	DECLARE @IDFotografia BIGINT
	DECLARE @PuntajeCreador DECIMAL(5,2)
	DECLARE @RankingMinimo DECIMAL(5,2)
	DECLARE @FechaInicio DATE
	DECLARE @FechaFin DATE

	SELECT @IDFotografia = ID
	FROM inserted

	SELECT @PuntajeCreador = AVG(V.Puntaje) FROM Votaciones as V
	INNER JOIN Fotografias AS F ON V.IDFotografia = F.ID
	WHERE F.ID = @IDFotografia

	SELECT @RankingMinimo = C.RankingMinimo, @FechaInicio = C.Inicio, @FechaFin = C.Fin FROM Concursos AS C
	INNER JOIN Fotografias AS F ON C.ID = F.IDConcurso
	WHERE F.ID = @IDFotografia
	
	IF @PuntajeCreador <= @RankingMinimo BEGIN
		RAISERROR('El puntaje no es suficiente para participar del concurso',16,1)
		RETURN
	END

	IF GETDATE() > @FechaInicio AND GETDATE() > @FechaFin BEGIN
		RAISERROR('El concurso ya ha finalizado.', 16, 1)
		RETURN
	END

	BEGIN TRANSACTION
	INSERT INTO Fotografias(IDParticipante, IDConcurso, Titulo, Descalificada, Publicacion)
	SELECT IDParticipante, IDConcurso, Titulo, Descalificada, Publicacion FROM inserted

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	PRINT ERROR_MESSAGE()
END CATCH
END

-- 3) Al insertar una votación, verificar que el usuario que vota no lo haga más de una
-- vez para el mismo concurso ni se pueda votar a si mismo. Tampoco puede votar una fotografía
-- descalificada. Si ninguna validación lo impide insertar el registro, de lo contrario, 
-- informar un mensaje de error.
CREATE OR ALTER TRIGGER TR_Punto_3 ON Votaciones
AFTER INSERT
AS BEGIN
BEGIN TRY

	DECLARE @IDVotacion BIGINT
	DECLARE @IDVotante BIGINT
	DECLARE @IDFotografia BIGINT
	
	DECLARE @CantidadConcursos INT

	SELECT @IDVotacion = ID,
			@IDFotografia = IDFotografia
	FROM inserted

	SELECT @CantidadConcursos = COUNT(C.ID) FROM Concursos AS C
	INNER JOIN Fotografias AS F ON C.ID = F.IDConcurso
	INNER JOIN Votaciones AS V ON F.ID = V.IDFotografia
	WHERE V.ID = @IDVotacion

	IF @CantidadConcursos > 1
	
	BEGIN TRANSACTION

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	PRINT ERROR_MESSAGE()
END CATCH
END


-- 4) Hacer un listado en el que se obtenga: ID de participante, apellidos y nombres de 
-- los participantes que hayan registrado al menos dos fotografías descalificadas.
SELECT P.ID AS Participante, P.Apellidos, P.Nombres, COUNT(F.Descalificada) AS "Fotografías descalificadas"
FROM Participantes AS P
INNER JOIN Fotografias AS F ON P.ID = F.IDParticipante
WHERE F.Descalificada = 1
GROUP BY P.ID, P.Apellidos, P.Nombres
HAVING COUNT(F.Descalificada) > 2


-- 5) Agregar las tablas y restricciones que sean necesarias para poder registrar las
-- denuncias que un usuario hace a una fotografía. Debe poder registrar cuando realiza
-- la denuncia incluyendo fecha y hora. Se debe asegurar que se conozcan los datos del
-- usuario que denuncia la fotografía, como el usuario que la publicó y la fotografía denunciada.
-- También debe registrarse obligatoriamente un comentario a la denuncia y una categoría de denuncia.
-- Las categorías de denuncia habitualmente son: Suplantación de identidad, Contenido inapropiado,
-- Infringimiento de derechos de autor, etc. Un usuario solamente puede denunciar una fotografía a la vez.
CREATE TABLE CategoriasDenuncia(
	ID SMALLINT NOT NULL PRIMARY KEY IDENTITY(1,1),
	Descripcion VARCHAR(50) NOT NULL
);
GO
CREATE TABLE Usuarios(
	ID BIGINT NOT NULL PRIMARY KEY IDENTITY(1,1),
	Nombres VARCHAR(50) NOT NULL,
	Apellidos VARCHAR(50) NOT NULL
);
GO
CREATE TABLE Denuncias(
	ID BIGINT NOT NULL PRIMARY KEY IDENTITY(1,1),
	IDCategoriaDenuncia SMALLINT NOT NULL FOREIGN KEY REFERENCES CategoriasDenuncia(ID),
	Fecha DATETIME NOT NULL,
	IDUsuario BIGINT NOT NULL FOREIGN KEY REFERENCES Usuarios(ID),
	IDFotografia BIGINT NOT NULL FOREIGN KEY REFERENCES Fotografias(ID),
	Comentario VARCHAR(400) NOT NULL
);
GO
INSERT INTO CategoriasDenuncia (Descripcion) VALUES
('Suplantación de identidad'),
('Contenido inapropiado'),
('Infringimiento de derechos de autor');
