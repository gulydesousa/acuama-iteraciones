
--facEstado: cFacturaBO.EEstados
--CobroBloqueado = 6
--SinDeterminar = 0

SELECT facEstado, * 
--UPDATE F SET facEstado=0
FROM facturas AS F
WHERE facCod = 1
AND facCtrCod='109901757' 
AND facPerCod IN ('202304', '202305')
AND facVersion=2
AND facFechaRectif IS NULL 
AND facEstado<>0 

