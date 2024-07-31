
--Revertir el alta
SELECT * 
--DELETE T
FROM tarval AS T WHERE [trvfecha] = '20240802'

SELECT * 
--DELETE T
FROM tarifas AS T WHERE trfFecReg= '20240729' AND trfUsrReg='gmdesousa';


--Revertir la baja
SELECT * 
--UPDATE T SET trvfechafin=NULL
FROM tarval AS T WHERE trvfechafin = '20240801'

SELECT * 
--UPDATE T trfFechaBaja=NULL, trfUsrBaja=NULL
FROM dbo.tarifas AS T WHERE trfFecUltMod= '20240729' AND trfUsrUltMod='gmdesousa';


--Revertir ContratosServicios
SELECT * 
--DELETE C
FROM dbo.contratoServicio AS C WHERE ctsfecalt='20240802'

SELECT C.*
--UPDATE C SET C.ctsfecbaj=T.ctsfecbaj, C.ctsfecrealbaja=T.ctsfecrealbaja
FROM [AVG].ServiciosContrato AS T
INNER JOIN dbo.contratoServicio AS C
ON C.ctsctrcod = T.ctsctrcod
AND C.ctslin = T.ctslin
AND C.ctssrv = T.ctssrv
AND C.ctstar = T.ctstar;

