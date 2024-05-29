IF(NOT EXISTS (SELECT * FROM parametros WHERE pgsclave='CONTAZARA_POINT_AUTH'))

INSERT INTO parametros 
OUTPUT INSERTED.*
VALUES(
'CONTAZARA_POINT_AUTH',
'End Point para obtener el token para loguearnos con el API Contazara',
2, 
'/auth/realms/cz-iot-platform/protocol/openid-connect/token',
0,
1, 
0)

ELSE
SELECT * FROM parametros WHERE pgsclave LIKE 'CONTAZARA_POINT_AUTH';