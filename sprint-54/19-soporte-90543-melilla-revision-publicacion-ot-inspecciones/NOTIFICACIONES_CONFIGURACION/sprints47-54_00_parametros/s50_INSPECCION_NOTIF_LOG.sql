IF(NOT EXISTS (SELECT * FROM parametros WHERE pgsclave='INSPECCION_NOTIF_LOG'))

INSERT INTO parametros 
OUTPUT INSERTED.*
VALUES(
'INSPECCION_NOTIF_LOG',
'ON/OFF se guarda en una tabla los datos usados para las cartas de notificaciones en el reporte TO039_EmisionNotificaciones',
2, 
'ON',
0,
1, 
1)

ELSE
SELECT * FROM parametros WHERE pgsclave LIKE 'INSPECCION_NOTIF_LOG';