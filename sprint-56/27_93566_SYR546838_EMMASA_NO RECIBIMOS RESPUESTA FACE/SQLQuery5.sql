SELECT scdNif FROM dbo.sociedades
SELECT * FROM dbo.parametros WHERE pgsclave='CB_SERES'
SELECT * FROM ftpSites

SELECT * FROM parametros WHERE pgsclave LIKE 'EXPLO%'

SELECT * 
--UPDATE P SET  pgsvalor='Estados/backup/Test'
FROM parametros AS P WHERE pgsclave='DIR_FTP_ESTADOS_SERES' AND pgsvalor='Estados/backup'


EXEC Task_Schedule_respuesta_SERES 

SELECT * FROM facEstadoSeres WHERE facEfecGrabaAcuama>'20240709 11:44'


--INSERT INTO dbo.facEstadoSeres
SELECT * FROM BUGSERES.facEstadoSeres


SELECT * 
--UPDATE F SET  ftpPassiveMode=1
FROM ftpSites AS F WHERE ftpName LIKE 'SERES%'

--TRUNCATE TABLE BUGSERES.facEstadoSeres