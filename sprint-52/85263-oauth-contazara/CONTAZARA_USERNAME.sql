IF(NOT EXISTS (SELECT * FROM parametros WHERE pgsclave='CONTAZARA_USERNAME'))

INSERT INTO parametros 
OUTPUT INSERTED.*
VALUES(
'CONTAZARA_USERNAME',
'Usuario para la conexion con el API Contazara',
2, 
'api_sacyr',
0,
1, 
0)

ELSE
SELECT * FROM parametros WHERE pgsclave LIKE 'CONTAZARA_USERNAME';