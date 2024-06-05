

IF(NOT EXISTS (SELECT * FROM parametros WHERE pgsclave='INSPECCION_FICHEROS_CARGA'))

INSERT INTO parametros 
OUTPUT INSERTED.pgsclave, INSERTED.pgsvalor
VALUES(
'INSPECCION_FICHEROS_CARGA',
'Directorio para la tarea de carga de los ficheros de las OT de inspecciones',
2, 
'__INSPECCION_FICHEROS_TASK__',
0,
1, 
1)

ELSE
 SELECT pgsclave, pgsvalor FROM parametros WHERE pgsclave='INSPECCION_FICHEROS_CARGA';