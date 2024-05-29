SELECT F.facCtrCod,   F.facLecAntFec,C.[I.ctcFec], F.facLecActFec, F.facLecAnt, R.[R.ctcLec], C.[I.ctcLec], F.facLecAct, facConsumoFactura, C.* , R.*
FROM facturas AS F 
INNER JOIN vCambiosContador AS C
ON C.ctrCod = F.facCtrCod
AND C.[I.ctcFec]>= F.facLecAntFec
AND C.[I.ctcFec]<= F.facLecActFec
AND (C.[R.ctcFec]<=F.facLecActFec OR C.[R.ctcFec] IS NULL)
AND facpercod='202402' AND facLote=1 AND F.facFechaRectif IS NULL 
LEFT JOIN vCambiosContador AS R
ON R.ctrCod = F.facCtrCod
AND R.[I.RN] = (C.[I.RN]-1) 
ORDER BY facLecAnt, C.[I.ctcFec], facCtrCod

--SELECT * FROM ctrcon WHERE ctcCtr=3660614





--SELECT * FROM vCambiosContador WHERE ctrcod=10333116



