SELECT RN= ROW_NUMBER() OVER (PARTITION BY CC.cobCtr ORDER BY cobNUm)
, CN = COUNT(cobNUm) OVER (PARTITION BY CC.cobCtr)
, *
FROM SYR547225_CTRCOD AS CC
LEFT JOIN 
cobros AS C 
ON CC.cobCtr = C.cobCtr
AND cobFecReg>='20240613' --AND cobOrigen='Remesa'

--****************
--NO HAN ENTRADO EN LA REMESA #1317
--110192674
--109400547
--110152940


--*******************************
--¿CUALES se remesaron en la #1317 y no estaban en la 1313?
SELECT * FROM cobros AS C 
LEFT JOIN SYR547225_CTRCOD AS CC
ON CC.cobctr = C.cobCtr

WHERE cobOrigen='Remesa' AND cobFecReg>='20240614' AND cobConcepto LIKE '%Remesa: 1317. Fecha: 14/06/2024%'
ORDER BY  CC.cobCtr

--********************************
--Entraron en esta remesa y no entraron ayer
--67522
--109802555
