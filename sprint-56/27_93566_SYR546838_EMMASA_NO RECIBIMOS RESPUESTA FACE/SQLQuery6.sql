SELECT * 
--UPDATE P SET  pgsvalor='Estados/backup'
FROM parametros AS P WHERE pgsclave='DIR_FTP_ESTADOS_SERES' AND pgsvalor='Estados/backup'

SELECT * 
--UPDATE F SET ftpServer='62.37.231.5', ftpProtocol=1, ftpPassiveMode=1
FROM ftpSites AS F WHERE ftpName LIKE 'SERES%' 


EXEC Task_Schedule_respuesta_SERES 


SELECT * FROM facEstadoSeres ORDER BY facEfecGrabaAcuama DESC


--CREATE SCHEMA BUGSERES

--TRUNCATE TABLE BUGSERES.facEstadoSeres

--INSERT INTO BUGSERES.facEstadoSeres
SELECT *
FROM facEstadoSeres WHERE facEfecGrabaAcuama>'20240709 11:44'

ORDER BY facEfecGrabaAcuama DESC