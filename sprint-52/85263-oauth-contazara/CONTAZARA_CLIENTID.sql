IF(NOT EXISTS (SELECT * FROM parametros WHERE pgsclave='CONTAZARA_CLIENTID'))

INSERT INTO parametros 
OUTPUT INSERTED.*
VALUES(
'CONTAZARA_CLIENTID',
'Client ID para la conexion con el API Contazara',
2, 
'service-iot-api',
0,
1, 
0)

ELSE
SELECT * FROM parametros WHERE pgsclave LIKE 'CONTAZARA_CLIENTID';