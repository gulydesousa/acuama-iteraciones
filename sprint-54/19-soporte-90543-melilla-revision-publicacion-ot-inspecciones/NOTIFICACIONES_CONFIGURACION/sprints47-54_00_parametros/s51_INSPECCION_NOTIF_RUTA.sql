IF(NOT EXISTS (SELECT * FROM parametros WHERE pgsclave='INSPECCION_NOTIF_RUTA'))

INSERT INTO parametros 
OUTPUT INSERTED.pgsclave, INSERTED.pgsvalor
VALUES(
'INSPECCION_NOTIF_RUTA',
'Directorio del gestor documental donde quedan guardadas las notificaciones de inspeccion',
2, 
'INSPECCION_NOTIF',
0,
1, 
0)

ELSE
SELECT pgsclave, pgsvalor FROM parametros WHERE pgsclave LIKE 'INSPECCION_NOTIF_RUTA';