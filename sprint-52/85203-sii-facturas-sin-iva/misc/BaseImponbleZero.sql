WITH S AS(
SELECT S.fcSiiFacCod
, S.fcSiiFacPerCod
, S.fcSiiFacCtrCod
, S.fcSiiFacVersion
, S.fcSiiNumEnvio
, S.fcSiiFechaExpedicionFacturaEmisor
, S.fcSiiLoteID
, RN = ROW_NUMBER() OVER (
PARTITION BY S.fcSiiFacCod, S.fcSiiFacPerCod, S.fcSiiFacCtrCod, S.fcSiiFacVersion 
ORDER BY  S.fcSiiNumEnvio DESC)
FROM facSII AS S
WHERE S.fcSiiFacCtrCod=64594)

SELECT  S.fcSiiFacCod, S.fcSiiFacPerCod, S.fcSiiFacCtrCod, S.fcSiiFacVersion, S.fcSiiNumEnvio
, fecha =  MAX(S.fcSiiFechaExpedicionFacturaEmisor)
, baseImponible = SUM(D.fclSiiBaseImponible)
, LOTE = MAX(S.fcSiiLoteID)
FROM S 
LEFT JOIN facSIIDesgloseFactura AS D
ON S.fcSiiFacCtrCod = D.fclSiiFacCtrCod
AND S.fcSiiFacPerCod = D.fclSiiFacPerCod
AND S.fcSiiFacCod = D.fclSiiFacCod
AND S.fcSiiFacVersion = D.fclSiiFacVersion
AND S.fcSiiNumEnvio = D.fclSiiNumEnvio
WHERE RN=1
GROUP BY S.fcSiiFacCod, S.fcSiiFacPerCod, S.fcSiiFacCtrCod, S.fcSiiFacVersion, S.fcSiiNumEnvio
HAVING ISNULL(SUM(D.fclSiiCuotaRepercutida), 0) = 0
ORDER BY fecha DESC;

--NO SE ENVIAN LAS QUE NO TIENEN LINEAS.
