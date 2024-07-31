SELECT * FROM tarifas where trfsrvcod=2  and trfdes LIKE '%13%'

SELECT * FROm tarval WHERE trvtrfcod IN (1301, 11301, 11302) and trvsrvcod=2

SELECT * FROM servicios


SELECT * 
, IIF(CHARINDEX(' - ', trfdes)=0, trfdes, LEFT(trfdes, CHARINDEX(' - ', trfdes) - 1)) AS Column1
, IIF(CHARINDEX(' - ', trfdes)=0, '', SUBSTRING(trfdes, CHARINDEX(' - ', trfdes) + 3, LEN(trfdes))) AS Column2
,   TRIM(CASE 
      WHEN CHARINDEX('MM', trfdes) > 0 
      THEN SUBSTRING(
          trfdes, 
          CHARINDEX(' ', trfdes) + 1, 
          CHARINDEX('MM', trfdes) + 1 - CHARINDEX(' ', trfdes)
      )
      ELSE ''
  END)
FROM tarifas
WHERE trfsrvcod=2

