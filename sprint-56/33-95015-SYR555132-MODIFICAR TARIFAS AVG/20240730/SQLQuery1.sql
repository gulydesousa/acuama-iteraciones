SELECT ServicioCod, Servicio, tarifa, Calibre, trvCuota, trvprecio1, trvprecio1_2024, trvprecio2, trvprecio2_2024, trvprecio3, trvprecio3_2024, TT.trfFechaBaja, TT.trfFecReg, TT.trfdes
FROM [AVG].Tarifas AS T
LEFT JOIN tarifas AS TT
ON TT.trfsrvcod = T.ServicioCod
AND T.Tarifa = TT.trfcod

SELECT * FROM contratoServicio  WHERE ctsfecalt>='20240802'
SELECT ctrzoncod FROM contratos WHERE ctrcod=12

SELECT * FROm contratos WHERE ctrcod=131

SELECT * FROm contratoServicio WHERE ctssrv IN (100,102,107)


SELECT * FROM tarifas WHERE  trfsrvcod IN (100,102,107) order by trfsrvcod, trfdes, IIF(trfFechaBaja IS NULL, 1, 0), trfFechaBaja

SELECT * FROM tarifas WHERE trfdes LIKE '%la loma%' 
SELECT * FROm tarv
SELECT * FROM servicios


00002
0005

Parametro a
Parametro b