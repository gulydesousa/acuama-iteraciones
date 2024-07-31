

ALTER VIEW [AVG].vTarifas
AS
SELECT Tarifa = IIF(CHARINDEX(' - ', trfdes)=0, trfdes, LEFT(trfdes, CHARINDEX(' - ', trfdes) - 1)) 
	 , BOP = IIF(CHARINDEX(' - ', trfdes)=0, '', SUBSTRING(trfdes, CHARINDEX(' - ', trfdes) + 3, LEN(trfdes)))
	 , MM= [AVG].ExtractNumberBeforeMM(trfdes)
, * 
FROM dbo.tarifas
GO
