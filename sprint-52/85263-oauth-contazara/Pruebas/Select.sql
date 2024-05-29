SELECT * FROM perzona WHERE przcierrereal IS NULL

SELECT * FROM facturas WHERE facPerCod='202303' AND facZonCod='7'


select * from contador where conNumSerie='P23NE855734A'
select * from facturas where facctrcod IN (23694, 23695)

SELECT  F.facPerCod, F.facInspeccion, C.conNumSerie, CC.conTeleLectura
, CO.ctrComunitario
, CO.numHijosComunitarios
, DIAS = DATEDIFF(DAY, facLecAntFec, GETDATE())
, F.*
FROM facturas AS F
LEFT JOIN dbo.vCambiosContador AS C
ON C.ctrCod = F.facCtrCod 
AND C.esUltimaInstalacion=1
LEFT JOIN dbo.contador AS CC
ON CC.conID = C.conId
LEFT JOIN dbo.vContratosUltimaVersion AS CO
ON CO.ctrCod = F.facCtrCod

WHERE --F.facZonCod='7'AND 
F.facPerCod='202304' 
--AND F.facCtrCod= 23581
--AND F.facLote = 7
--AND CC.conNumSerie='P23NE855734A'
AND CC.conTeleLectura=1


ORDER BY facLote


SELECT * FROM dbo.vContratosUltimaVersion






