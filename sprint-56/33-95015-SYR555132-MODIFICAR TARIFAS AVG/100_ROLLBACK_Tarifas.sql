--Borramos las nuevas tarifas y sus nuevos valores de tarifa
BEGIN TRAN 

BEGIN TRY

DECLARE @fechareg DATE ='20240730' 


DECLARE @TRFBAJA AS TABLE(trfsrvcod INT, trfcod INT, trvfecha DATETIME);
DECLARE @TRFALTA AS TABLE(trfsrvcod INT, trfcod INT, trvfecha DATETIME);
DECLARE @CTS AS TABLE(ctsctrcod INT, ctslin	INT, ctssrv INT, ctstar INT, ctsuds	INT, ctsusr VARCHAR(20), ctsfecalt DATETIME, ctsfecbaj DATETIME, ctsfecrealbaja DATETIME,
					  ctsctrcod1 INT, ctslin1	INT, ctssrv1 INT, ctstar1 INT, ctsuds1	INT, ctsusr1 VARCHAR(20), ctsfecalt1 DATETIME, ctsfecbaj1 DATETIME,	ctsfecrealbaja1 DATETIME);

--[01]Valores de tarifa en el excel
INSERT INTO @TRFALTA
SELECT trfsrvcod, trfcod,  trvfecha
FROM dbo.tarifas AS T 
INNER JOIN dbo.tarval AS TV
ON T.trfsrvcod = TV.trvsrvcod
AND T.trfcod = TV.trvtrfcod
AND T.trfFecReg = @fechareg --Tarifas del excel del syrena dadas de alta
AND T.trfUsrReg = 'gmdesousa';

INSERT INTO @TRFBAJA
SELECT trfsrvcod, trfcod,  trvfecha
FROM dbo.tarifas AS T 
INNER JOIN dbo.tarval AS TV
ON T.trfsrvcod = TV.trvsrvcod
AND T.trfcod = TV.trvtrfcod
AND T.trfFecUltMod = @fechareg --Tarifas que hay que se han dado de baja
AND T.trfUsrUltMod= 'gmdesousa'
AND T.trfFechaBaja ='20240801'
AND TV.trvfechafin ='20240801';


--Seleccionamos los cambios de contratos x servicios
--20.989
INSERT INTO @CTS
SELECT *
FROM contratoServicio AS CS
INNER JOIN contratoServicio AS CS1
ON  CS1.ctsctrcod = CS.ctsctrcod
AND CS1.ctssrv = CS.ctssrv 
AND CS1.ctstar = IIF(CS.ctstar = 12402 AND CS.ctssrv=1, 10402, CS.ctstar)+1  
--Se les ha dado de baja porque se va a crear uno nuevo
WHERE CS.ctsfecbaj='20240801' AND CS.ctsfecrealbaja=@fechareg 
AND CS1.ctsusr='gmdesousa' AND CS1.ctsfecalt='20240802'
ORDER BY CS1.ctsusr;


--**************************************************
--************    ROLLBACK    **********************
--************  CONTRATOSERVICIO  ******************
--[01] Las nuevas tarifas las borramos
DELETE CS OUTPUT DELETED.*
FROM contratoServicio AS CS
INNER JOIN @CTS AS CC 
ON CS.ctsctrcod = CC.ctsctrcod1
AND CS.ctssrv = CC.ctssrv1
AND CS.ctstar = CC.ctstar1
AND CS.ctslin = CC.ctslin1;


--[02] La tarifa original deshacemos la baja
UPDATE CS SET CS.ctsfecbaj = CC.ctsfecbaj1, CS.ctsfecrealbaja=CC.ctsfecrealbaja1
OUTPUT INSERTED.*
FROM contratoServicio AS CS
INNER JOIN @CTS AS CC 
ON CS.ctsctrcod = CC.ctsctrcod
AND CS.ctssrv = CC.ctssrv
AND CS.ctstar = CC.ctstar
AND CS.ctslin = CC.ctslin;

--********** TARIFAS ****************
--[11] Borramos los valores de tarifa nueva
--SELECT * 
DELETE FROM TV OUTPUT DELETED.*
FROM dbo.tarval AS TV
INNER JOIN @TRFALTA AS T
ON TV.trvsrvcod = T.trfsrvcod
AND TV.trvtrfcod = T.trfcod
AND TV.trvfecha = T.trvfecha;

--[12] Borramos las tarifas nuevas
--SELECT *
DELETE FROM T OUTPUT DELETED.*
FROM tarifas AS T
INNER JOIN @TRFALTA AS TT
ON T.trfcod = TT.trfcod
AND T.trfsrvcod = TT.trfsrvcod;


--[21] Revertimos la baja del valor de la tarifa antigua
--SELECT TV.* 
UPDATE TV  SET trvfechafin=NULL OUTPUT INSERTED.*
FROM dbo.tarval AS TV
INNER JOIN @TRFBAJA AS T
ON TV.trvsrvcod = T.trfsrvcod
AND TV.trvtrfcod = T.trfcod
AND TV.trvfecha = T.trvfecha;

--[22] Revertimos la baja de la tarifa antigua
--SELECT T.*
UPDATE T SET trfFechaBaja=NULL, trfUsrBaja=NULL, trfFecUltMod=NULL, trfUsrUltMod=NULL OUTPUT INSERTED.*
FROM tarifas AS T
INNER JOIN @TRFBAJA AS TT
ON T.trfcod = TT.trfcod
AND T.trfsrvcod = TT.trfsrvcod;
COMMIT
END TRY

BEGIN CATCH
ROLLBACK
END CATCH

