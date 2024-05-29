DELETE FROM apremios WHERE aprFechaGeneracion>='20240522'


SELECT *
--DELETE
FROM apremios WHERE aprFechaGeneracion>='20240522'


SELECT * FROM apremios WHERE aprFechaGeneracion>='20240522' and aprFacVersion>1

SELECT facCtrCod, facVersion, facFecha, facNumero 
FROM facturas WHERE facPerCod = '202201' AND

facCtrCod IN (--2528,
4592,
4646,
6445
--8969,
--11362,
--26585,
--26678,
--27035,
--31409,
--31795,
--31965
--60150
)
order by facCtrCod


SELECT * 
--DELETE
FROM Task_Schedule WHERE tskUser='gmdesousa' AND tskFinishedDate IS NULL 