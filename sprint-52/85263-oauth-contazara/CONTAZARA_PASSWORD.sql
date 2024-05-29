IF(NOT EXISTS (SELECT * FROM parametros WHERE pgsclave='CONTAZARA_PASSWORD'))

INSERT INTO parametros 
OUTPUT INSERTED.*
VALUES(
'CONTAZARA_PASSWORD',
'Password para la conexion con el API Contazara',
2, 
'e9okA/DwQuagsvSX,8',
0,
1, 
0)

ELSE
SELECT * FROM parametros WHERE pgsclave LIKE 'CONTAZARA_PASSWORD';