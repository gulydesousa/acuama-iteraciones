





DELETE FROM apremios WHERE aprFechaGeneracion>='20240522'

SELECT * 
--DELETE
FROM Task_Schedule WHERE tskUser = 'gmdesousa' and tskNumber<13

--TRUNCATE TABLE dbo.apremiosTrab

INSERT INTO dbo.apremiosTrab
SELECT  * FROM Trabajo.apremiosTrab WHERE aptFacPerCod BETWEEN'201802' and '201802' And aptFacVersion=1

--TRUNCATE TABLE Trabajo.apremiosTrab

SELECT  * FROM Trabajo.apremiosTrab
SELECT * FROM  dbo.apremiosTrab ORDER BY aptFacCtrCod, aptFacPerCod, aptFacVersion


--DELETE FROM parametros WHERE pgsclave='cApremiosTrabBL'
--SELECT * FROM parametros WHERE pgsclave='cApremiosTrabBL'

DECLARE @valor AS VARCHAR(5)= '54'

IF(NOT EXISTS (SELECT * FROM parametros WHERE pgsclave='cApremiosTrabBL'))
	INSERT INTO parametros 
	OUTPUT INSERTED.pgsclave, INSERTED.pgsvalor
	VALUES('cApremiosTrabBL','Version por Sprint',2, @valor,0,1, 0)
ELSE 
	UPDATE P SET pgsvalor=@valor
	OUTPUT INSERTED.pgsclave, INSERTED.pgsvalor
	FROM parametros AS P WHERE pgsclave='cApremiosTrabBL'



	SELECT * FROM apremiosTrab


	SELECT 'gdesousa', A.aprFacCod, A.aprFacPerCod, A.aprFacCtrCod, A.aprFacVersion, 1 FROM apremios AS A
	INNER JOIN periodos AS P
	ON P.percod = A.aprFacPerCod
	INNER JOIN dbo.facturas AS F
	ON F.facCod = A.aprFacCod
	AND F.facCtrCod = A.aprFacCtrCod
	AND F.facVersion = A.aprFacVersion
	AND F.facPerCod =A.aprFacPerCod
	AND YEAR(F.facFecha) <> YEAR(P.perFecFinPagoVol)
	ORDER BY facPerCod


	INSERT INTO Trabajo.ApremiosTrab
SELECT 'gmdesousa', A.aprFacCod, A.aprFacPerCod, A.aprFacCtrCod, A.aprFacVersion, 1 FROM apremios AS A
	INNER JOIN periodos AS P
	ON P.percod = A.aprFacPerCod
	INNER JOIN dbo.facturas AS F
	ON F.facCod = A.aprFacCod
	AND F.facCtrCod = A.aprFacCtrCod
	AND F.facVersion = A.aprFacVersion
	AND F.facPerCod =A.aprFacPerCod
	AND YEAR(F.facFecha) <> YEAR(P.perFecFinPagoVol)
	AND facPerCod='202103'

--Borramos estos apremios de la tabla
DELETE A
FROM apremios AS A
	INNER JOIN periodos AS P
	ON P.percod = A.aprFacPerCod
	INNER JOIN dbo.facturas AS F
	ON F.facCod = A.aprFacCod
	AND F.facCtrCod = A.aprFacCtrCod
	AND F.facVersion = A.aprFacVersion
	AND F.facPerCod =A.aprFacPerCod
	AND YEAR(F.facFecha) <> YEAR(P.perFecFinPagoVol)
	AND facPerCod='202103'	



	
	SELECT F.facNumero, F.facVersion, F.facFecha, F.facFechaRectif, P.perFecFinPagoVol, P.perFecIniPagoVol 
	FROM Trabajo.ApremiosTrab AS T
	INNER JOIN dbo.facturas AS F
	ON F.facCod = T.aptFacCod
	AND F.facPerCod = T.aptFacPerCod
	AND F.facCtrCod = T.aptFacCtrCod
	AND F.facVersion = T.aptFacVersion
	LEFT JOIN periodos AS P
	ON P.percod = F.facPerCod
	WHERE YEAR(P.perFecIniPagoVol)<>YEAR(F.facFecha) AND facVersion=1




	--INSERT INTO Trabajo.ApremiosTrab
SELECT 'gmdesousa', A.aprFacCod, A.aprFacPerCod, A.aprFacCtrCod, A.aprFacVersion, 1 FROM apremios AS A
	INNER JOIN periodos AS P
	ON P.percod = A.aprFacPerCod
	INNER JOIN dbo.facturas AS F
	ON F.facCod = A.aprFacCod
	AND F.facCtrCod = A.aprFacCtrCod
	AND F.facVersion = A.aprFacVersion
	AND F.facPerCod =A.aprFacPerCod
	AND F.facVersion=1
	AND YEAR(F.facFecha) <> YEAR(P.perFecIniPagoVol)
	AND facPerCod>'201800'
	

--Borramos estos apremios de la tabla


SELECT A.*, T.fctDeuda 
FROM Trabajo.ApremiosTrab AS A
INNER JOIN dbo.facTotales AS T
ON A.aptFacCod = T.fctCod
AND A.aptFacPerCod = T.fctPerCod
AND A.aptFacCtrCod = T.fctCtrCod
AND A.aptFacVersion = T.fctVersion
ORDER BY fctDeuda




SELECT * FROM  dbo.apremiosTrab


SELECT * 
--DELETE
FROM Task_Schedule WHERE tskUser = 'gmdesousa' 


DELETE FROM apremios WHERE aprFechaGeneracion>='20240522'


TRUNCATE TABLE dbo.apremiosTrab
GO

INSERT INTO dbo.apremiosTrab
--Solo si tienen deuda pendiente
SELECT DISTINCT A.*
FROM Trabajo.ApremiosTrab AS A
INNER JOIN dbo.facTotales AS T
ON A.aptFacCod = T.fctCod
AND A.aptFacPerCod = T.fctPerCod
AND A.aptFacCtrCod = T.fctCtrCod
AND A.aptFacVersion = T.fctVersion
WHERE fctDeuda>0 AND fctVersion>1

SELECT * FROM apremios WHERE aprFacCtrCod=60154 AND aprFacPerCod='201902'

	SELECT F.facNumero, F.facVersion, F.facFecha, F.facFechaRectif, P.perFecFinPagoVol, P.perFecIniPagoVol, YYYYFactura=YEAR(F.facFecha), YYYYPagoVol=YEAR(P.perFecIniPagoVol), facPerCod, facCtrCod, A.fctDeuda
	, mas60dias = DATEADD(DAY, 60, F.facFecha)
	FROM trabajo.ApremiosTrab AS T
	INNER JOIN dbo.facturas AS F
	ON F.facCod = T.aptFacCod
	AND F.facPerCod = T.aptFacPerCod
	AND F.facCtrCod = T.aptFacCtrCod
	AND F.facVersion = T.aptFacVersion
	LEFT JOIN periodos AS P
	ON P.percod = F.facPerCod
	INNER JOIN dbo.facTotales AS A
	ON T.aptFacCod = A.fctCod
	AND T.aptFacPerCod = A.fctPerCod
	AND T.aptFacCtrCod = A.fctCtrCod
	AND T.aptFacVersion = A.fctVersion
	WHERE facNumero LIKE '%2400248'


	--DELETE FROM parametros WHERE pgsclave='cApremiosTrabBL'
--SELECT * FROM parametros WHERE pgsclave='cApremiosTrabBL'

DECLARE @valor AS VARCHAR(5)= ''

IF(NOT EXISTS (SELECT * FROM parametros WHERE pgsclave='cApremiosTrabBL'))
	INSERT INTO parametros 
	OUTPUT INSERTED.pgsclave, INSERTED.pgsvalor
	VALUES('cApremiosTrabBL','Version por Sprint',2, @valor,0,1, 0)
ELSE 
	UPDATE P SET pgsvalor=@valor
	OUTPUT INSERTED.pgsclave, INSERTED.pgsvalor
	FROM parametros AS P WHERE pgsclave='cApremiosTrabBL'


	--CA001-1
	
	--CA001-2

	
	--CA001-3


	--INSERT INTO dbo.apremiosTrab
	SELECT T.*	
	FROM Trabajo.ApremiosTrab AS T
	INNER JOIN dbo.facturas AS F
	ON F.facCod = T.aptFacCod
	AND F.facPerCod = T.aptFacPerCod
	AND F.facCtrCod = T.aptFacCtrCod
	AND F.facVersion = T.aptFacVersion
	LEFT JOIN periodos AS P
	ON P.percod = F.facPerCod
	INNER JOIN dbo.facTotales AS A
	ON T.aptFacCod = A.fctCod
	AND T.aptFacPerCod = A.fctPerCod
	AND T.aptFacCtrCod = A.fctCtrCod
	AND T.aptFacVersion = A.fctVersion
	--WHERE F.facVersion=1 AND (P.perFecIniPagoVol IS NOT NULL AND YEAR(P.perFecIniPagoVol)<> YEAR(F.facFecha))
	--WHERE F.facVersion=1 AND NOT (P.perFecIniPagoVol IS NOT NULL AND YEAR(P.perFecIniPagoVol)<> YEAR(F.facFecha))
	--WHERE F.facVersion<>1

