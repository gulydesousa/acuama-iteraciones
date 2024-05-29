IF(NOT EXISTS (SELECT * FROM parametros WHERE pgsclave='CONTAZARA_API_VERSION'))

INSERT INTO parametros 
OUTPUT INSERTED.*
VALUES(
'CONTAZARA_API_VERSION',
'Version del api conexion con el API Contazara',
2, 
'/api/2019-06-01',
0,
1, 
0)

ELSE
SELECT * FROM parametros WHERE pgsclave LIKE 'CONTAZARA_API_VERSION';