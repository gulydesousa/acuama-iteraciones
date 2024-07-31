--Insertamos nuevas tarifas y damos de baja la anterior
--SELECT * FROM [AVG].Tarifas WHERE tarifa IN (10402, 12402) and ServicioCod=1
--Consumo Terciario: es "CONSUMO DE AGUA" y es para los códigos 10402 (consumo terciarios) y 12402 (consumo terciarios) Guly este está duplicado, se puede unificar

--SELECT * FROM  tarifas WHERE trfsrvcod= 1 AND trfcod IN (10402, 12402)
--SELECT * FROM tarifas WHERE trfsrvcod= 1 AND trfcod IN (10403, 12403)

BEGIN TRAN

	DECLARE @usuario VARCHAR(10) = 'gmdesousa';
	DECLARE @fechaReg DATE = '20240729';
	--La fecha inicio de la nueva tarifa
	DECLARE @fechaFinTrf DATE = '20240801';
	DECLARE @fechaIniTrf DATE = DATEADD(DAY, 1, @fechaFinTrf);

	--21.037:
	--Alta de los nuevos servicios
	INSERT INTO dbo.contratoServicio OUTPUT INSERTED.*
	SELECT C.ctsctrcod
	, ctslin = T.maxLinea+T.iLinea
	, C.ctssrv
	, ctstar = IIF(C.ctstar IN(10402, 12402), 10403, C.ctstar +1)
	, C.ctsuds
	, ctsusr=@usuario
	, ctsfecalt = @fechaIniTrf
	, ctsfecbaj = T.ctsfecbaj
	, ctsfecrealbaja = T.ctsfecrealbaja
	FROM [AVG].ServiciosContrato AS T
	INNER JOIN dbo.contratoServicio AS C
	ON C.ctsctrcod = T.ctsctrcod
	AND C.ctslin = T.ctslin
	AND C.ctssrv = T.ctssrv
	AND C.ctstar = T.ctstar;

	
	
	--Le ponemos fecha fin al servicio
	--SELECT C.* 
	UPDATE C SET ctsfecbaj=@fechaFinTrf, ctsfecrealbaja=@fechaReg OUTPUT INSERTED.*
	FROM [AVG].ServiciosContrato AS T
	INNER JOIN dbo.contratoServicio AS C
	ON C.ctsctrcod = T.ctsctrcod
	AND C.ctslin = T.ctslin
	AND C.ctssrv = T.ctssrv
	AND C.ctstar = T.ctstar;

	SELECT * FROM contratoServicio WHERE ctsfecalt=@fechaIniTrf AND ctsfecbaj IS NOT NULL;

--COMMIT
--ROLLBACK