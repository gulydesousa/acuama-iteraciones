--SELECT * FROM tarval WHERE trvsrvcod=20 AND trvfecha='20230101'


--Trucamos los precios para el ejercicio 2023
BEGIN TRAN
SELECT * 
--UPDATE T SET trvprecio2=0.1, trvprecio3=0.2, trvprecio4=0.6
FROM tarval AS T WHERE t.trvfecha=('01/01/2023') 
AND t.trvsrvcod=20 AND t.trvtrfcod=101 
AND  trvprecio2=0 AND trvprecio3=0 AND trvprecio4=0;


SELECT * 
--UPDATE T SET trvprecio1=0.25
FROM tarval AS T WHERE t.trvfecha=('01/01/2023') 
AND t.trvsrvcod=20 AND t.trvtrfcod=201 
AND  trvprecio1=0 

SELECT * 
--UPDATE T SET trvprecio1=0.25
FROM tarval AS T WHERE t.trvfecha=('01/01/2023') 
AND t.trvsrvcod=20 AND t.trvtrfcod=8501 
AND  trvprecio1=0 
--COMMIT TRAN
ROLLBACK TRAN


--Dejamos los precios para el ejercicio 2023
BEGIN TRAN
SELECT * 
--UPDATE T SET trvprecio2=0, trvprecio3=0 , trvprecio4=0
FROM tarval AS T WHERE t.trvfecha=('01/01/2023') 
AND t.trvsrvcod=20 AND t.trvtrfcod=101 
AND  trvprecio2=0.1 AND trvprecio3=0.2 AND trvprecio4=0.6;


SELECT * 
--UPDATE T SET trvprecio1=0.0
FROM tarval AS T WHERE t.trvfecha=('01/01/2023') 
AND t.trvsrvcod=20 AND t.trvtrfcod=201 
AND  trvprecio1=0.25 

SELECT * 
--UPDATE T SET trvprecio1=0.0
FROM tarval AS T WHERE t.trvfecha=('01/01/2023') 
AND t.trvsrvcod=20 AND t.trvtrfcod=8501 
AND  trvprecio1=0.25 
--COMMIT TRAN
ROLLBACK TRAN




