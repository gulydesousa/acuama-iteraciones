SELECT * FROM facturas WHERE facCtrCod=59164  and facPerCod='202312' AND facVersion=4
SELECT * FROM facturas WHERE facCtrCod=59164  and facPerCod='202312' AND facVersion IN (3, 4)

SELECT * 
--UPDATE F SET facSerieRectif=NULL, facNumeroRectif=NULL,	facFechaRectif=NULL, facCtrVersion=6
FROM facturas AS F WHERE facCtrCod=59164  and facPerCod='202312' AND facVersion=3

SELECT * FROM contratos WHERE ctrcod=59164
SELECT * FROM parametros WHERE pgsclave LIKE '%EXPLOTACION_CODIGO%'

SELECT * 
--DELETE
FROM faclin WHERE fclfacCtrCod=59164  and fclfacPerCod='202312' AND fclfacVersion=4


SELECT * 
--DELETE
FROM dbo.facSIIDesgloseFactura WHERE fclSiifacCtrCod=59164  and fclSiifacPerCod='202312' AND fclSiifacVersion=4

SELECT * 
--DELETE
FROM facturas WHERE facCtrCod=59164  and facPerCod='202312' AND facVersion=4

SELECT * 
--DELETE
FROM facSII WHERE fcSiifacCtrCod=59164  and fcSiifacPerCod='202312' AND fcSiifacVersion=4 


SELECT * FROM Task_Schedule WHERE tskNumber=61
EXEC Task_Schedule_respuesta_SERES

Select * from sociedades

SELECT * 
--UPDATE P SET pgsvalor='Estados/backup'
--UPDATE P SET pgsvalor='Estados/backup/1100' --BIAR
--UPDATE P SET pgsvalor='Estados/backup/300' --SVB
--UPDATE P SET pgsvalor='Estados/backup/400' --GUADALAJARA
--UPDATE P SET pgsvalor='Estados/backup/100' --ALMADEN
--UPDATE P SET pgsvalor='Estados/backup/200' --ALAMILLA
--UPDATE P SET pgsvalor='Estados/Valdaliga700' --VALDALIGA
FROM parametros AS P WHERE pgsclave='DIR_FTP_ESTADOS_SERES' AND pgsvalor='Estados/backup'
P3909100D

SELECT * FROM dbo.sociedades
SELECT * FROM parametros WHERE pgsclave LIKE '%SOC%'
