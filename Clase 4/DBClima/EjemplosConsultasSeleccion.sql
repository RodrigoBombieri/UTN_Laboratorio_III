Use Clima
Go
-- Seleccionar informaci�n de UNA tabla
--CON EL SELECT los cambios se dan �nicamente en memoria (no modifican la DB)

-- TODOS los registros con TODAS las columnas de medici�n (se usa el * para seleccionar todas las columnas)
Select * From Mediciones

-- TODOS los registros con ALGUNAS de las columnas de medici�n (Se indican las columnas que quiero mostrar antes del From)
Select IDCiudad, FechaHora, Temperatura, Lluvia From Mediciones

-- Cambiarle el nombre al encabezado de una columna (EN MEMORIA SOLAMENTE)
Select IDCiudad As CodigoCiudad, FechaHora, Temperatura, Lluvia From Mediciones

-- TODOS los registros con ALGUNAS columnas de medici�n (Se agrega la condici�n para filtrar)
Select * From Mediciones 
Where IDCiudad = 1

-- TODOS los registros con Las ciudades con id = 1 y temperatura menor a cero
Select * From Mediciones 
Where IDCiudad = 1 And Temperatura < 0

-- Todos los registros de la ciudad 1 y la temperatura debajo de cero
-- ordenado por Temperatura de la m�s fr�a a la m�s c�lida
Select * From Mediciones 
Where IDCiudad = 1 And Temperatura < 0
-- Sentencia Order by se usa para ordenar y el asc (ascendente)
Order by Temperatura asc

-- Doble Sentencia Order by primero ordena por lluvia en forma descendente, 
-- y luego ante la igualdad de valores, ordena por Temperatura en forma ascendente
Select * From Mediciones 
Where IDCiudad = 1 And Temperatura < 0
Order by Lluvia desc, Temperatura asc

-- TODOS los registros de Temperatura de los a�os 2022 y 2024
-- Como FechaHora contiene a�o, mes, dia, hora, minuto, segundo, 
-- se debe especificar previo que valor queremos seleccionar
Select * From Mediciones
Where Year(FechaHora) = 2022 or Year(FechaHora) = 2024

-- Si quiero por ejemplo ver varios a�os diferentes 
-- y no estar usando el or muchas veces se usa el In (Si alguno de los valores da Verdadero ya funciona):
Select * From Mediciones
Where Year(FechaHora) In (2022, 2024, 2026, 2027)

-- Agrega una columna con los valores que le especificamos (En este caso el a�o) SIN NOMBRE DE COLUMNA
Select *, Year(FechaHora) From Mediciones

-- Agrega una columna con los valores que le especificamos (En este caso el a�o) CON NOMBRE DE COLUMNA "A�O"
Select *, Year(FechaHora) As A�o From Mediciones

-- Agrega una columna en este caso con el numero de d�a del a�o (desde el 0 hasta ese dia)
Select *, Datepart(DAYOFYEAR, FechaHora) From Mediciones

-- Agrega una columna en este caso el trimestre al que corresponde esa fecha
Select *, Datepart(QUARTER, FechaHora) From Mediciones

-- Agrega una columna en este caso el dia de la semana al que corresponde esa fecha (Del 1 al 7)
Select *, Datepart(WEEKDAY, FechaHora) From Mediciones

-- Todos los registros de Temperatura entre 10� y 25�C con AND
Select * From Mediciones
Where Temperatura >= 10 And Temperatura <= 25

-- Todos los registros de Temperatura entre 10� y 25�C con BETWEEN (Incluye los extremos)
Select * From Mediciones
Where Temperatura between 10 And 25

-- Todos los registros de Temperatura QUE NO EST�N entre 10� y 25�C se agrega el NOT
Select * From Mediciones
Where Not Temperatura >= 10 And Temperatura <= 25

-- Todos los registros donde lluvia fue NULL se usa el operador IS
Select * From Mediciones
Where Lluvia Is Null

-- Todos los registros donde lluvia NO fue NULL se usa el operador IS NOT
Select * From Mediciones
Where Lluvia Is not Null

-- Todos los registros de medici�n en los que no se haya 
-- registrado medici�n de lluvia reemplazando el valor null por 0
-- con el ISNULL los registros nulos se convierten en 0 y los que tienen valores no se ven afectados
Select ID, ISNULL(Lluvia, 0) From Mediciones

-- Cambiar valores a partir de una o m�s condiciones
Select Nombre, Severidad, 
Case -- Es una especie de SWITCH
When Severidad between 1 and 2 then 'Green' -- Cambia los valores de Nombre segun el int�rvalo de Severidad
When Severidad between 3 and 5 then 'Yellow'
Else 'Red' -- A los dem�s les asigna el rojo
End As 'Colour' -- Nombre de la Columna
From NivelesPeligrosidad

Select * From NivelesPeligrosidad

-- Uso de distinct (Quita los valores repetidos) en una columna
Select distinct DuracionMinutosEstimada From AlertasMeteorologicos
Order by DuracionMinutosEstimada asc

-- Uso de distinct (Quita las COMBINACIONES de valores repetidos) en varias columnas
Select distinct DuracionMinutosEstimada, IDNivelPeligrosidad From AlertasMeteorologicos
Order by DuracionMinutosEstimada asc