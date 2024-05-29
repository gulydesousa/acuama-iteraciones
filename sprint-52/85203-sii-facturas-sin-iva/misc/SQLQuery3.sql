WITH S AS(
SELECT S.fcSiiFacCod
, S.fcSiiFacPerCod
, S.fcSiiFacCtrCod
, S.fcSiiFacVersion
, S.fcSiiNumEnvio
, RN = ROW_NUMBER() OVER (
PARTITION BY S.fcSiiFacCod, S.fcSiiFacPerCod, S.fcSiiFacCtrCod, S.fcSiiFacVersion 
ORDER BY  S.fcSiiNumEnvio DESC)
FROM facSII AS S)

SELECT  S.fcSiiFacCod, S.fcSiiFacPerCod, S.fcSiiFacCtrCod, S.fcSiiFacVersion, S.fcSiiNumEnvio
, baseImponible = SUM(D.fclSiiBaseImponible)
FROM S 
INNER JOIN facSIIDesgloseFactura AS D
ON S.fcSiiFacCtrCod = D.fclSiiFacCtrCod
AND S.fcSiiFacPerCod = D.fclSiiFacPerCod
AND S.fcSiiFacCod = D.fclSiiFacCod
AND S.fcSiiFacVersion = D.fclSiiFacVersion
AND S.fcSiiNumEnvio = D.fclSiiNumEnvio
WHERE RN=1
GROUP BY S.fcSiiFacCod, S.fcSiiFacPerCod, S.fcSiiFacCtrCod, S.fcSiiFacVersion, S.fcSiiNumEnvio
HAVING SUM(D.fclSiiBaseImponible) = 0;

RETURN


SELECT * 

FROM facSIIDesgloseFactura AS F 
where F.fclSiiBaseImponible = 0