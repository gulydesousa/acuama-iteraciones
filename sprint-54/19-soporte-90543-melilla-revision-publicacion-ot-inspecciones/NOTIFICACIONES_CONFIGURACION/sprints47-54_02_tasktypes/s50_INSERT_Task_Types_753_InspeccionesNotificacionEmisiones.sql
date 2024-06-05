IF NOT EXISTS(SELECT 1 FROM Task_Types WHERE tskTDesc='InspeccionesNotificacionEmisiones')
INSERT INTO Task_Types VALUES(753, 'InspeccionesNotificacionEmisiones', 0);


SELECT * 
--DELETE
FROM Task_Types WHERE tskTDesc='InspeccionesNotificacionEmisiones'
