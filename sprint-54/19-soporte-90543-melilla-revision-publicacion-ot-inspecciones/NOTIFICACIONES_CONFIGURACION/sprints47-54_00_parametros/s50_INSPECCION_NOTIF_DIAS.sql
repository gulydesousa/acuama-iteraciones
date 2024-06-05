IF(NOT EXISTS (SELECT * FROM parametros WHERE pgsclave='INSPECCION_NOTIF_DIAS'))

INSERT INTO parametros 
OUTPUT INSERTED.pgsclave, INSERTED.pgsvalor
VALUES(
'INSPECCION_NOTIF_DIAS',
'Días Naturales que deben transcurrir desde la notificación para crear la OT de cambio de contador',
2, 
'21',
0,
1, 
0)

ELSE
SELECT pgsclave, pgsvalor FROM parametros WHERE pgsclave LIKE 'INSPECCION_NOTIF_DIAS';