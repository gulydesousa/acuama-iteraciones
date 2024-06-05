

IF(NOT EXISTS (SELECT * FROM parametros WHERE pgsclave='INSPECCION_FICHEROS'))

INSERT INTO parametros 
OUTPUT INSERTED.pgsclave, INSERTED.pgsvalor
VALUES(
'INSPECCION_FICHEROS',
'Directorio destino de los ficheros de las OT de inspecciones',
2, 
'__INSPECCION_FICHEROS__',
0,
1, 
1)
ELSE
SELECT pgsclave, pgsvalor FROM parametros WHERE pgsclave='INSPECCION_FICHEROS';