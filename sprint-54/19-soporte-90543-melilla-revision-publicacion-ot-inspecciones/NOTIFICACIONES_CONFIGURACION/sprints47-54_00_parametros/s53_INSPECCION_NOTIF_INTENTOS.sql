IF(NOT EXISTS (SELECT * FROM parametros WHERE pgsclave='INSPECCION_NOTIF_INTENTOS'))

INSERT INTO parametros 
OUTPUT INSERTED.pgsclave, INSERTED.pgsvalor
VALUES(
'INSPECCION_NOTIF_INTENTOS',
'Reintentos para el envio de notificaciones de inspección',
1, 
'1',
0,
1, 
1)

ELSE
SELECT pgsclave, pgsvalor FROM parametros WHERE pgsclave LIKE 'INSPECCION_NOTIF_INTENTOS';