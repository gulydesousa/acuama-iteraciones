# 🧨SYR-549588 - EMISIÓN FACTURAS CON MISMO Nº 2º TRIMESTRE 2024

## Situación actual

Tenemos facturas del periodo 202402 con números repetidos, como consecuencia de un Bug en Acuama.

Algunas facturas han sido enviadas en pdf  a los representantes de clientes (Inmobiliarias).

Los clientes de la oficina virtual han recibido email informándoles que la pueden descargar la factura.

La emisión de facturas en papel no se ha realizado.

Se ha mandado una Facurae a través de SERES.

En el SII han entrado facturas con número repetido al tener distintas fechas de operación y otras se han identificado como duplicadas quedando rechazadas.

 
## Solución propuesta

Identificar las facturas que no han pasado al SII para modificar su número por otro que no exista y hacer el envío al SII

Identificar las facturas que han entrado en el SII con número de factura duplicado para hacer su anulación y crear la nueva factura, haciendo el envío de la (información rectificada) nueva factura.


# ✨ Gestión de los Datos

## 1. Crear un esquema BUG91542

```SQL
CREATE SCHEMA BUG91542; 
```

## 2. Seleccionar las facturas afectadas: <span style="color:coral">[BUG91542].[facEmitidas]</span>

Recuperamos el numero de factura de la emisión inicial que quedó en  la columna **facObs**

- 5.356 Facturas emitidas
- 3.085  Facturas afectadas por el update de emergencia


```SQL
SELECT * FROM BUG91542.facEmitidas;
```

> Inicialización de la tabla
```SQL
DECLARE @cadenaBuscar VARCHAR(MAX) = 'SYR-549588 -facnu repe ';
DECLARE @posicion INT;

--*****************************************************
--[01]Inicializar la tabla
SELECT facCod, facPerCod, facCtrCod, facVersion, facEnvSERES,  facfecReg
--facNumero: despues del update
, facNumero 
--FacNumero: Antes del update
, NumeroEmision = facNumero 
--facNumero: cambiado por el update
, NumeroKO = TRIM(SUBSTRING(F.facObs,  CHARINDEX(@cadenaBuscar, F.facObs) + LEN(@cadenaBuscar), LEN(F.facObs) -  CHARINDEX(@cadenaBuscar, F.facObs) + LEN(@cadenaBuscar) + 1))
, facObs
INTO BUG91542.facEmitidas
FROM facturas AS F 
WHERE facPerCod='202402' AND facNumero IS NOT NULL;



--*****************************************************
--[02]Actualizamos en NumeroEmision el numero original antes del update de emergencia
--3.085 filas afectadas por el update
SELECT *
--UPDATE F SET NumeroEmision = NumeroKO
FROM BUG91542.facEmitidas AS F WHERE LEN(NumeroKO) > 0
```

## 3. Selección de los envíos al SII: <span style="color:coral">[BUG91542].[EnviosSII]</span>

Aqui relacionamos todas las facturas de la emisión con los envíos al SII.

```SQL
SELECT * FROM BUG91542.EnviosSII;
```

Aplicamos un orden en la columna **RN_SII** para quedarnos solo con el último envio de cada factura segun esta precedencia:

> 1. Envio con  fcSiiestado = 1 (éxito)
> 2. Envio con  fcSiiestado = NULL (pendiente de enviar)
> 2. Envio con  fcSiiestado > 1 (último envio)

Si seleccionamos aquellas con **RN_SII**= 1 tenemos el último envío exitoso al SII.


```SQL
SELECT F.*, S.fcSiiNumSerieFacturaEmisor, S.fcSiiFechaExpedicionFacturaEmisor, S.fcSiiestado, S.fcSiicodErr, S.fcSiidescErr, S.fcSiiNumEnvio, S.fcSiiLoteID, L.fcSiiLtFecEnvSap, L.fcSiiLtEnvEstado, L.fcSiiLtEnvErrorDescripcion
--Orden para quedarnos con el ultimo envio
--Orden: Si ha sido aceptado, no ha sido aceptado pero esta pendiente de envio, si no est� en los dos casos previos: trae el ultimo envio.
, RN_SII = ROW_NUMBER() OVER (PARTITION BY faccod, facPerCod, facCtrCod, facVersion ORDER BY CASE WHEN fcSiiestado IS NOT NULL AND  fcSiiestado=1 THEN 0 WHEN fcSiiestado IS  NULL THEN 1 ELSE 99 END, fcSiiNumEnvio DESC)

INTO BUG91542.EnviosSII
FROM BUG91542.facEmitidas AS F
LEFT JOIN dbo.facSII AS S
ON S.fcSiiFacCod = F.facCod
AND S.fcSiiFacPerCod = F.facpercod
AND S.fcSiiFacCtrCod = F.facCtrcod
AND S.fcSiiFacVersion = F.facversion
LEFT JOIN facSIILote AS L
ON L.fcSiiLtID = S.fcSiiLoteID
```

## 4. Ultimo envio al SII: <span style="color:coral">[BUG91542].[SII]</span>

Obtenemos todas las facturas ordenadas por el último lote en el que o bien se procesó con éxito la factura, y si no hay estado existoso, el retornamos el ultimo intento de envio-

```SQL
SELECT * FROM BUG91542.SII ORDER BY DRxN, RNxN
```

- **DRxN**: DenseRank-Autonumerico que comparten todas las facturas de acumama que comparten el mismo numero del SII **fcSiiNumSerieFacturaEmisor** . 

- **CNxN**: Count-Total de facturas que tienen el mismo **fcSiiNumSerieFacturaEmisor** . 

- **RNxN**: RowNumber-Autonumerico que se incrementa para cada factura que comparte el mismo **fcSiiNumSerieFacturaEmisor** . 

> Ejemplo: Todas las facturas con fcSiiNumSerieFacturaEmisor='A-2024/2410005507' tienen el mismo valor DRxN=264 y CNxN=7 los valores de RNxN empiezan irán del 1 al 7 

> ```SQL
> SELECT * FROM BUG91542.SII 
>WHERE fcSiiNumSerieFacturaEmisor='A-2024/2410005507'
> ORDER BY DRxN, RNxN
>```

<span style="color:coral">No encontramos forma de identificar con exactitud por numero de factura el ultimo envio al SII.</span>
Para asegurarnos que vamos a tener un orden deterministico hemos tenido que combinar el id del lote con la fecha de registro y numero de contrato.


```SQL
SELECT * 
--Numero de envios al SII por numero de factura: Enumera cada numero de factura SII
, DRxN = DENSE_RANK() OVER(ORDER BY fcSiiNumSerieFacturaEmisor)
--Total de facturas acuama associadas a una misma factura SII
, CNxN = COUNT(fcSiiNumSerieFacturaEmisor) OVER (PARTITION BY fcSiiNumSerieFacturaEmisor)
--Orden dentro de un mismo grupo de factura SII
, RNxN = ROW_NUMBER() OVER (PARTITION BY fcSiiNumSerieFacturaEmisor ORDER BY fcSiiLtFecEnvSap DESC, facfecReg DESC, facCtrCod DESC)
INTO BUG91542.SII
FROM BUG91542.EnviosSII WHERE RN_SII=1 OR RN_SII IS NULL
ORDER BY DRxN, RNxN
```
