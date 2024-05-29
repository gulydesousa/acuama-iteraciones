###  🧿 01 - User Story 88136: Cartas inspecciones - Correspondencia campos con BBDD Inspecciones
#### 📦 Task 89015:  Revisar proceso de Actulización de Aptos no aptos

> *Branch*: **feature/88062-sprint53-to039-inspeccionplantilla-melilla**  
*Publicado en Preproducción*: 20-05-2024  
Menú: <span style="color:pink">Técnica/Notificaciones/Insp. Validaciones/ **Actualizar OT Inspecciones**</span>  


Procedimiento que actualiza el Valor de las OTs de Inspecciones según la configuración actual en "Inspecciones Validaciones".

El cambio es porque ahora una linea de validaciones puede depender de mas de una columna, para agrupar los valores se usa la columna "clave".

> 📃Tras la ejecución se genera automaticamente el informe de "Inspecciones Aptas" que nos permite comprobar las inspecciones afectadas por el cambio de configuración.

![alt text](<files/Task 89015.png>)


# Inspecciones
```SQL
SELECT * FROM otInspecciones_Melilla --4.770
```

# Limpiar las tablas
```SQL
SELECT * 
--DELETE
FROM otInspeccionesContratos_Melilla

SELECT *
--DELETE
FROM otInspeccionesNotificacionEdo_Melilla

--EMISIONES
--DBCC CHECKIDENT ('otInspeccionesNotificacionEmisiones_Melilla', RESEED, 0);
SELECT * 
--DELETE
FROM otInspeccionesNotificacionEmisiones_Melilla

SELECT * 
--DELETE
FROM otInspecciones_Melilla

SELECT *
--DELETE
FROM Task_Schedule WHERE tskUser='gmdesousa'

--DISABLE TRIGGER ordenTrabajo_DeleteCascada ON ordenTrabajo;
SELECT * 
--DELETE
FROM otDatosValor WHERE otdvOdtCodigo=2001

select * 
--DELETE
from ordenTrabajo
where otTipoOrigen='INSPMASIVO'
GO

--ENABLE TRIGGER ordenTrabajo_DeleteCascada ON ordenTrabajo;

SELECT *
--DELETE
FROM ReportingServices.TO039_EmisionNotificaciones_Notificaciones

--DBCC CHECKIDENT ('ReportingServices.TO039_EmisionNotificaciones_Emisiones', RESEED, 0);
SELECT * 
--DELETE
FROM ReportingServices.TO039_EmisionNotificaciones_Emisiones
```


## ✨ Prueba 1
1. Hacemos una carga masiva
2. Sacamos el informe de aptas
3. Borramos **TODOS** los DatosValor para ver si la actualización sin estado las vuelve a refrescar.
```SQL
SELECT * 
--DELETE
FROM otDatosValor WHERE otdvOdtCodigo=2001
```
4. Lanzamos el SP para actualizar todos los estados todos las inspecciones

```SQL
DECLARE @ReturnValue INT;
DECLARE @odtValor AS VARCHAR(25) = NULL;
DECLARE @ultimoxservicio BIT = NULL;
DECLARE @usuario VARCHAR(10)= 'gmdesousa';

EXEC @ReturnValue = otInspecciones_ActualizarOtDatosValor_Melilla @odtValor, @ultimoxservicio, @usuario ;
SELECT @ReturnValue AS 'Return Value';
```

5. **Resultado Esperado:** Se vuelven a insertar los estados de todas las inspecciones, los datos coinciden con lo inicialmente insertado.




## ✨Prueba 2
1. Hacemos una carga masiva
2. Sacamos el informe de aptas
3. Seteamos **TODOS** los DatosValor a '?'.
```SQL
SELECT * 
--UPDATE D SET D.otdvValor='?'
FROM otDatosValor AS D WHERE otdvOdtCodigo=2001
```
4. Lanzamos el SP para actualizar todos los estados todos las inspecciones

```SQL
DECLARE @ReturnValue INT;
DECLARE @odtValor AS VARCHAR(25) = NULL;
DECLARE @ultimoxservicio BIT = NULL;
DECLARE @usuario VARCHAR(10)= 'gmdesousa';

EXEC @ReturnValue = otInspecciones_ActualizarOtDatosValor_Melilla @odtValor, @ultimoxservicio, @usuario ;
SELECT @ReturnValue AS 'Return Value';
```

5. **Resultado Esperado:** Se vuelven a insertar los estados de todas las inspecciones, los datos coinciden con lo inicialmente insertado.


## ✨ Prueba 3
1. Borramos **TODOS** los DatosValor para ver si la actualización sin estado las vuelve a refrescar.
2. Lanzamos la tarea para actualizar desde acuama
3. **Resultado Esperado:** Se actualiza Apto solo las ultimas inspecciones por cada contrato : RN1

```SQL
DECLARE @ReturnValue INT;
DECLARE @odtValor AS VARCHAR(25) = NULL;
DECLARE @ultimoxservicio BIT = NULL;
DECLARE @usuario VARCHAR(10)= 'gmdesousa';

EXEC @ReturnValue = otInspecciones_ActualizarOtDatosValor_Melilla  @usuario ;
SELECT @ReturnValue AS 'Return Value';
```

[**sprint review**](../../../54_sprint-review/readme.md)