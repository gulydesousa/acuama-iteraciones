SELECT * 
FROM vCambiosContador AS CC
WHERE esUltimaInstalacion=1 AND opRetirada IS NULL



SELECT * FROM vContratosUltimaVersion where ctrBaja=0 and ctrfecanu is null

--Contratos con el ultimo contador instalado

SELECT C.ctrCod, C.ctrBaja, C.ctrfecanu, CC.conNumSerie, CC.opRetirada, CC.[I.ctcFec] 
FROM vContratosUltimaVersion AS C
LEFT JOIN vCambiosContador AS CC
ON CC.ctrCod = C.ctrCod
AND CC.esUltimaInstalacion=1
WHERE ctrzoncod='ZMUN' AND
--Retirado y anulado
(ctrfecanu IS NULL AND opRetirada IS NULL)
ORDER BY CC.opRetirada
