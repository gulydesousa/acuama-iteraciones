DECLARE @faccod INT
DECLARE @facPerCod VARCHAR(6)
DECLARE @facCtrcod INT
DECLARE @facVersion INT

/*
DECLARE CUR CURSOR FOR 

SELECT F.facCod, F.facPerCod, F.facCtrCod, F.facVersion 
FROM BUG91542.NumerosOcupados 
INNER JOIN facturas AS F
ON F.facPerCod='202402' AND facNumero=NumFactura AND Ocupado=0

OPEN CUR;

FETCH NEXT FROM CUR INTO @faccod, @facPerCod, @facCtrcod, @facVersion

WHILE @@FETCH_STATUS = 0
    BEGIN
        UPDATE facturas 
		SET  facFecUltimoReenvioSII=GETDATE() 
		WHERE facCod = @faccod AND facPerCod= @facpercod AND  facCtrCod = @facCtrcod AND facVersion = @facVersion
		
		FETCH NEXT FROM CUR INTO @faccod, @facPerCod, @facCtrcod, @facVersion


    END;

CLOSE CUR;

DEALLOCATE CUR;

*/


--EXEC Task_Schedule_respuesta_SII



WITH S AS(
SELECT fcSiiFacCod,fcSiiFacPerCod, fcSiiFacCtrCod, fcSiiFacVersion, S.fcSiiNumSerieFacturaEmisor, S.fcSiicodErr, S.fcSiidescErr, S.fcSiiNumEnvio, S.fcSiiestado, fcSiiLoteID
, RN = ROW_NUMBER() OVER (PARTITION BY fcSiiFacCod,fcSiiFacPerCod, fcSiiFacCtrCod, fcSiiFacVersion ORDER BY  IIF(S.fcSiiestado IS NOT NULL AND S.fcSiiestado=1, 1, S.fcSiiestado), S.fcSiiNumEnvio)
FROM facSII AS S
WHERE fcSiiFacPerCod='202402')

--6788
SELECT facCod, facPerCod, facCtrCod, facVersion, facNumero, facNumeroAqua
, RN = ROW_NUMBER() OVER(PARTITION BY facCod, facPerCod, facCtrCod ORDER BY facVersion DESC)
, CN = COUNT(facVersion) OVER(PARTITION BY facCod, facPerCod, facCtrCod)
, SUM(IIF(S.fcSiiestado IS NULL OR S.fcSiiestado<>1, 1, 0))  OVER(PARTITION BY facCod, facPerCod, facCtrCod)
, S.fcSiiNumSerieFacturaEmisor
, S.fcSiicodErr
, S.fcSiidescErr
, S.fcSiiNumEnvio
, S.fcSiiestado
, fcSiiLoteID
FROM facturas AS F
LEFT JOIN S
ON S.fcSiiFacCtrCod = F.facCtrCod
AND S.fcSiiFacPerCod = F.facPerCod
AND S.fcSiiFacVersion = F.facVersion
AND S.fcSiiFacCod = F.facCod
AND S.RN=1
WHERE facPerCod='202402'

