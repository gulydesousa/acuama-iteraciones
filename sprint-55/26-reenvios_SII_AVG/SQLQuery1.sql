DECLARE @id INT = 5129;

SELECT * FROM facturas WHERE facPerCod='202402' AND facCtrCod=@id;

SELECT F.facCod, F.facPerCod, F.facCtrCod, F.facVersion, F.facNumero, f.facObs, S.* 
FROM facturas AS F 
LEFT JOIN dbo.facSII AS S
ON F.facCod = S.fcSiiFacCod
AND F.facPerCod = S.fcSiiFacPerCod
AND F.facCtrCod = S.fcSiiFacCtrCod
AND F.facVersion = S.fcSiiFacVersion
WHERE facPerCod='202402'  AND facCtrCod=@id;



--SELECT * FROM facturas WHERE facPerCod='202402' AND facNumero LIKE '%410008330%'
SELECT * FROM facSII WHERE fcSiiNumSerieFacturaEmisor='A-2024/2410008330' AND fcSiiFacPerCod='202402'


SELECT * FROM facSII WHERE fcSiiFacCtrCod IN (14,5129) AND fcSiiFacPerCod='202402'


SELECT * 
--UPDATE F SET facFecUltimoReenvioSII=GETDATE()
FROM facturas AS F WHERE facCtrCod=33141 AND facPerCod='202402'