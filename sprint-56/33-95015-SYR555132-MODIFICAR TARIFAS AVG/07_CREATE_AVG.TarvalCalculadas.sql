--Valores de las tarifas potencialmente actualizables con el calculo de margari
SELECT TV.* 
INTO [AVG].tarvalCalculadas
FROM [AVG].tarifasCalculadas AS T
INNER JOIN tarval AS TV
ON TV.trvsrvcod = T.trfsrvcod
AND TV.trvtrfcod = T.trfcod;
GO


SELECT * FROM [AVG].tarvalCalculadas