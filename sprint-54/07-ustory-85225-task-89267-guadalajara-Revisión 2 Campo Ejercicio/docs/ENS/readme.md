# 🔥 Pruebas

Partimos de la selección de la muestra que hemos hecho anteriormente [Seleccion de la muestra](#-seleccion-de-la-muestra)


### Borrar tareas previas de mi usuario (opcional)

```SQL
SELECT * 
--DELETE
FROM Task_Schedule WHERE tskUser = 'gmdesousa' and tskNumber<13
```

### 1. Borrar los apremios generados en pruebas anteriores

```SQL
DELETE FROM apremios WHERE aprFechaGeneracion>='20240522'
```


### 2. Insertar la muestra en la tabla que se usa para `Generar Apremios`



Con esto nos saltamos el paso de la seleccion de apremios.
```SQL
TRUNCATE TABLE dbo.apremiosTrab
GO

INSERT INTO dbo.apremiosTrab
SELECT * FROM Trabajo.apremiosTrab
```

### 3. Configurar el parametro `cApremiosTrabBL`

Este parametro nos permite cambiar de versión, `cApremiosTrabBL` es la clase que se usar para el metodo de `Generar apremios Guadalajara`


|Valor|Descripcion|
|---|---|
|No definido|Versión inicial|
|Nulo o Vacio|Versión inicial|
|54|Versión para el sprint 54|
|<> 54|Versión inválida|


**Script para la configuración del parametro**
```SQL
DELETE FROM parametros WHERE pgsclave='cApremiosTrabBL'

DECLARE @valor AS VARCHAR(5)= '540'
IF(NOT EXISTS (SELECT * FROM parametros WHERE pgsclave='cApremiosTrabBL'))
	INSERT INTO parametros 
	OUTPUT INSERTED.pgsclave, INSERTED.pgsvalor
	VALUES('cApremiosTrabBL','Version por Sprint',2, @valor,0,1, 0)
ELSE 
	UPDATE P SET pgsvalor=@valor
	OUTPUT INSERTED.pgsclave, INSERTED.pgsvalor
	FROM parametros AS P WHERE pgsclave='cApremiosTrabBL'
```






<br><br><br><br><br><br><br><br><br>

# 🔍 Seleccion de la muestra

### 1. Borramos apremios rectificativos de contado

```SQL
DELETE FROM apremios WHERE aprFacPerCod<'200000' AND aprFacVersion>1
```

### 2. Seleccionamos desde acuama apremios de contado 

Periodos `000001` - `200000`

Dejamos una muestra para probar

> Todas las rectificativas de contado Maximo 10 por cada original de contado

```SQL
WITH T AS(
SELECT *
, RN=ROW_NUMBER() OVER (PARTITION BY aptFacPerCod ORDER BY aptFacCtrCod)
FROM apremiosTrab 
WHERE aptFacVersion =1)

SELECT * 
--DELETE A
FROM apremiosTrab AS A
INNER JOIN T 
ON T.aptFacCtrCod = A.aptFacCtrCod 
AND T.aptFacPerCod = A.aptFacPerCod 
AND T.aptFacVersion = A.aptFacVersion 
AND T.aptFacCod = A.aptFacCod
AND T.RN>10
```

### 3. Seleccionamos desde acuama apremios de consumo 

Periodos superior al `200000`

Dejamos una muestra para probar

> A lo sumo tres de cada periodo y version

```SQL
WITH T AS(
SELECT *
, RN=ROW_NUMBER() OVER (PARTITION BY aptFacPerCod, aptFacVersion ORDER BY aptFacCtrCod)
FROM apremiosTrab 
WHERE aptFacPerCod >'200000')
SELECT * 
--DELETE A
FROM apremiosTrab AS A
INNER JOIN T 
ON T.aptFacCtrCod = A.aptFacCtrCod 
AND T.aptFacPerCod = A.aptFacPerCod 
AND T.aptFacVersion = A.aptFacVersion 
AND T.aptFacCod = A.aptFacCod
AND T.RN>3

```

### 4. Con esto tenemos una muestra en  `Trabajo.ApremiosTrab`

```SQL
SELECT * 
INTO Trabajo.ApremiosTrab
FROM apremiosTrab AS A
```

Con estos datos ya podemos empezar a [probar](#-pruebas)