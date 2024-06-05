

IF(NOT EXISTS (SELECT * FROM parametros WHERE pgsclave='INSPECCION_FICHEROS_SUBD'))

INSERT INTO parametros 
OUTPUT INSERTED.pgsclave, INSERTED.pgsvalor
VALUES(
'INSPECCION_FICHEROS_SUBD',
'Subdirectorio al que se envian los ficheros de inspeccion',
2, 
'inspecciones',
0,
1, 
1)
ELSE
SELECT pgsclave, pgsvalor FROM parametros WHERE pgsclave='INSPECCION_FICHEROS_SUBD';