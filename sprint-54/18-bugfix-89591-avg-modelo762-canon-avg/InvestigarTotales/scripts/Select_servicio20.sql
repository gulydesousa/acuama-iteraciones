SELECT * 
FROM facturas AS F
INNER JOIN faclin AS FL
ON FL.fclfaccod = F.faccod
AND FL.fclFacPerCod = F.facPerCod
AND FL.fclFacCtrCod = F.facCtrCod
AND FL.fclFacVersion = F.facVersion
AND FL.fclTrfSvCod=20
WHERE facfecha>'20230101' AND facFecha<'20240101' AND fcltotal<>0