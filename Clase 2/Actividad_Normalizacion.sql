SELECT 
    E.IDEmpleado,
    E.Nombre AS NombreEmpleado,
    E.Apellido,
    I.Idioma,
    N.Descripcion AS Nivel
FROM 
    Empleados E
JOIN 
    Idiomas I ON E.IDEmpleado = I.IDEmpleado
JOIN 
    Niveles_Idioma N ON I.IDIdioma = N.IDIdioma;