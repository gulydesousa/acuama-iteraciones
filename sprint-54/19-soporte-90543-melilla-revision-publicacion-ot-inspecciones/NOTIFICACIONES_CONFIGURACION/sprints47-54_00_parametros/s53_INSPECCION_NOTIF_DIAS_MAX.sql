IF(NOT EXISTS (SELECT * FROM parametros WHERE pgsclave='INSPECCION_NOTIF_DIAS_MAX'))

insert into parametros 
OUTPUT INSERTED.pgsclave, INSERTED.pgsvalor
VALUES
('INSPECCION_NOTIF_DIAS_MAX', 'Días Naturales máximo que deben transcurrir desde la notificación para crear la OT de cambio de contador', 2, '60', 0, 1, 0)

ELSE
SELECT pgsclave, pgsvalor FROM parametros WHERE pgsclave LIKE 'INSPECCION_NOTIF_DIAS_MAX';