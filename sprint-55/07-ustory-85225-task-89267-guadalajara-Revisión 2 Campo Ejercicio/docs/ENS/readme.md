# 📦 DEMO: Apremios Guadalajara PRE

## Complejidad

 🤼‍♂️ Comprender los requisitos  *'Word' vs 'Stories' vs 'Código-Base acuama'* 🔮

🚥 "Parar" varias veces la tarea y luego volver a retomarla. 

🚀 Como el resultado es un fichero de texto, hemos tenido que crear una aplicación para parsear el texto <span style="color:pink">(app. en phyton)</span> a excel y facilitar la comprobación que solo se ha visto afectado lo que hemos tocado-y nada mas-. 

🔗 https://dev.azure.com/sacyr-sf/Sacyr.Acuama/_git/complementos?path=/apremios%20parsear%20xls%20Guadalajara

🪂 Una vez realizado el cambio hemos tenido que volver a hacerlo para ofrecer la posibilidad por parametros de cambiar entre esta nueva versión y la version original. 

<br><br>

## 👉 Ventanas
```
1. Guadalajarara PRE
2. SQL
3. C:\Gdesousa\Sacyr\acuama-iteraciones\sprint-54\07-ustory-85225-task-89267-guadalajara-Revisión 2 Campo Ejercicio\docs\Pruebas_PRE\ApremiosParser\resultados
4. Beyond Compare 
```
<br><br>

# 💸Evidencias: Apremios Guadalajara

1. Se ordenan los apremios descendente `Cobros\Apremios\Apremios` 

2. Comprobar la observación nueva en las facturas rectificativas. **Contrato: 56029**

3. Cambios en el fichero de emisión de apremios `Cobros/Apremios/Generar Apremios`

<br><br>
## 📜 Generar Apremios

1. Parametro para cambiar entre la versión anterior y la nueva de este sprint `cApremiosTrabBL = 54`

1. Obtener una muestra de datos en la tabla `Trabajo.ApremiosTrab `

1. Hacer dos emisiones identicas, una con la versión original, otra con la nueva para poder comparar los resultados

<br>

### ✨ Emisiones para las pruebas:
```SQL
- Facturas v1 donde el año de inicio pago voluntario sea diferente al de la factura (65)
- Facturas v1 donde el año de inicio pago voluntario sea igual al de la factura (245)
- Facturas rectificativas (74)
```

<br>

### ⚙ Parsear los ficheros de salida y comparar. 

Solo deben haber diferencias en la `Fecha de Emision = fecha de la factura` y la `fecha de vencimento = fecha de la factura + 60 días`

<br>

### 👨‍💻 Cambios implementados

```
	⚡ FechaEmision = Fecha factura  📌igual para todas 

	⚡ Año Liquidacion = YEAR(FechaEmision)  📌igual para todas
	   Siempre ha usado la fecha de la factura - NO CAMBIA
	
	⚡ NO-Rectificativas : Sin cambio en la fecha de vencimiento	
	
	⚡ Rectificativas: Fecha Vencimiento = FechaEmision + 60
```

### Demostrar:

	Facturas v1 donde el año de inicio pago voluntario sea diferente al de la factura (65)
	⚡ FechaEmision = Cambia porque antes era la fecha de inicio de pago voluntario ✔

	Facturas v1 donde el año de inicio pago voluntario sea igual al de la factura (245)
	⚡ FechaEmision = Cambia porque antes era la fecha de inicio de pago voluntario ✔
	
	Facturas rectificativas (74)
	⚡ FechaEmision = Cambia porque antes era la fecha de inicio de pago voluntario ✔
	⚡ Vencimiento = Fecha emisión + 60 días ✔
	
<br>
<br>
<br>
<br>

# FACTURAS
```SQL
	SELECT F.facNumero, F.facVersion, F.facFecha, F.facFechaRectif, P.perFecFinPagoVol, P.perFecIniPagoVol, YYYYFactura=YEAR(F.facFecha), YYYYPagoVol=YEAR(P.perFecIniPagoVol), facPerCod, facCtrCod, A.fctDeuda
	, mas60dias = DATEADD(DAY, 60, F.facFecha)
	FROM trabajo.ApremiosTrab AS T
	INNER JOIN dbo.facturas AS F
	ON F.facCod = T.aptFacCod
	AND F.facPerCod = T.aptFacPerCod
	AND F.facCtrCod = T.aptFacCtrCod
	AND F.facVersion = T.aptFacVersion
	LEFT JOIN periodos AS P
	ON P.percod = F.facPerCod
	INNER JOIN dbo.facTotales AS A
	ON T.aptFacCod = A.fctCod
	AND T.aptFacPerCod = A.fctPerCod
	AND T.aptFacCtrCod = A.fctCtrCod
	AND T.aptFacVersion = A.fctVersion
	WHERE facNumero LIKE '%61100'
```




# APREMIOS
```SQL
--INSERT INTO dbo.apremiosTrab
	SELECT T.*	
	FROM Trabajo.ApremiosTrab AS T
	INNER JOIN dbo.facturas AS F
	ON F.facCod = T.aptFacCod
	AND F.facPerCod = T.aptFacPerCod
	AND F.facCtrCod = T.aptFacCtrCod
	AND F.facVersion = T.aptFacVersion
	LEFT JOIN periodos AS P
	ON P.percod = F.facPerCod
	INNER JOIN dbo.facTotales AS A
	ON T.aptFacCod = A.fctCod
	AND T.aptFacPerCod = A.fctPerCod
	AND T.aptFacCtrCod = A.fctCtrCod
	AND T.aptFacVersion = A.fctVersion
	--WHERE F.facVersion=1 AND (P.perFecIniPagoVol IS NOT NULL AND YEAR(P.perFecIniPagoVol)<> YEAR(F.facFecha))
	--WHERE F.facVersion=1 AND NOT (P.perFecIniPagoVol IS NOT NULL AND YEAR(P.perFecIniPagoVol)<> YEAR(F.facFecha))
	WHERE F.facVersion<>1	
```



<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

# 🔥 Pruebas

Partimos de la selección de la muestra que hemos hecho anteriormente [Seleccion de la muestra](#-seleccion-de-la-muestra)


### Borrar tareas previas de mi usuario (opcional)

```SQL
SELECT * 
--DELETE
FROM Task_Schedule WHERE tskUser = 'gmdesousa' and tskNumber<13
```

### Opción de menu

> `Cobros/Apremios/Generar Apremios`

Procesar siempre como **TAREA**

Si lo ejecutas en local, los ficheros quedan en el directorio: 

`C:\Sacyr\workspace-git\Sacyr.Acuama\classic\Website\Ficheros\Documentos\__personal__`

### ⚙ Parsear el resultado para poder ver los datos del txt en excel

1. El ejecutable está en el directorio: `ApremiosParser`
2. Seleccionar los resultados **txt** de cada tarea
3. Se genera un excel con los datos de cada txt en `ApremiosParser/resultados`


**<span style="color:red;">Repetir los pasos 0, 1, 2 para cada valor de parametro</span>**


### 0. Configurar el parametro `cApremiosTrabBL`

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
--Solo si tienen deuda pendiente
SELECT DISTINCT A.*
FROM Trabajo.ApremiosTrab AS A
INNER JOIN dbo.facTotales AS T
ON A.aptFacCod = T.fctCod
AND A.aptFacPerCod = T.fctPerCod
AND A.aptFacCtrCod = T.fctCtrCod
AND A.aptFacVersion = T.fctVersion
WHERE fctDeuda>0

```








<br><br><br><br><br><br><br><br><br>

# 🔍 Seleccion de la muestra

Deberíamos mirar que tengan deuda pendiente las seleccionadas porque sino la tarea de apremios falla.

```SQL
SELECT A.*, T.fctDeuda 
FROM Trabajo.ApremiosTrab AS A
INNER JOIN dbo.facTotales AS T
ON A.aptFacCod = T.fctCod
AND A.aptFacPerCod = T.fctPerCod
AND A.aptFacCtrCod = T.fctCtrCod
AND A.aptFacVersion = T.fctVersion
ORDER BY fctDeuda
```


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

### 6. Buscar apremios donde el `año de la factura` es diferente al año del `inicio pago voluntario`


```SQL
INSERT INTO Trabajo.ApremiosTrab
SELECT 'gmdesousa', A.aprFacCod, A.aprFacPerCod, A.aprFacCtrCod, A.aprFacVersion, 1 FROM apremios AS A
	INNER JOIN periodos AS P
	ON P.percod = A.aprFacPerCod
	INNER JOIN dbo.facturas AS F
	ON F.facCod = A.aprFacCod
	AND F.facCtrCod = A.aprFacCtrCod
	AND F.facVersion = A.aprFacVersion
	AND F.facPerCod =A.aprFacPerCod
	AND F.facVersion=1
	AND YEAR(F.facFecha) <> YEAR(P.perFecIniPagoVol)
	AND facPerCod>'201800'

--Borramos estos apremios de la tabla
DELETE A
FROM apremios AS A
	INNER JOIN periodos AS P
	ON P.percod = A.aprFacPerCod
	INNER JOIN dbo.facturas AS F
	ON F.facCod = A.aprFacCod
	AND F.facCtrCod = A.aprFacCtrCod
	AND F.facVersion = A.aprFacVersion
	AND F.facPerCod =A.aprFacPerCod
	AND F.facVersion=1
	AND YEAR(F.facFecha) <> YEAR(P.perFecIniPagoVol)
	AND facPerCod>'201800'
```



## Con esto tenemos ya una muestra en  `Trabajo.ApremiosTrab`

```SQL
SELECT * 
INTO Trabajo.ApremiosTrab
FROM apremiosTrab AS A
```

Con estos datos ya podemos empezar a [probar](#-pruebas)