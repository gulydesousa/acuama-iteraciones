ALTER TABLE ReportingServices.TO039_EmisionNotificaciones_Notificaciones
ADD ID AS FORMAT(EmisionID, 'D4') + '-' + FORMAT(ISNULL(RN, 0), 'D6')

--SELECT * FROM ReportingServices.TO039_EmisionNotificaciones_Notificaciones
--ALTER TABLE ReportingServices.TO039_EmisionNotificaciones_Notificaciones DROP COLUMN ID;