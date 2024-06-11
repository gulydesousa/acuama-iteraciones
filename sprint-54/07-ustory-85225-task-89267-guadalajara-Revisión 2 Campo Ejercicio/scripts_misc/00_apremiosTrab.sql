
SELECT * FROM apremiosTrab order by aptFacVersion
--TRUNCATE TABLE apremiosTrab

exec ApremiosTrab_Select @aptTipo=1,@aptUsrCod='gmdesousa'


SELECT * 
FROM apremiosTrab AS A
LEFT JOIN facturas AS F
ON F.facCtrCod


--Selecciono toda la zona AM01 y borro las que tienen version 1
SELECT * 
--DELETE A
FROM apremiosTrab AS A WHERE aptFacVersion=1


SELECT * FROM apremiosTrab order by aptFacVersion


--****************************************
--PRUEBAS:
--0:Borramos apremios rectificativos de contado
DELETE FROM apremios WHERE aprFacPerCod<'200000' AND aprFacVersion>1

--1: Seleccionamos desde acuama apremios de consumo 
--Periodos 000001 - 200000

--2: Dejamos una muestra para probar:
--Todas las rectificativas de contado
--Maximo 10 por cada original de contado

WITH T AS(
SELECT *
, RN=ROW_NUMBER() OVER (PARTITION BY aptFacPerCod ORDER BY aptFacCtrCod)
FROM apremiosTrab 
WHERE aptFacVersion =1)

SELECT * 
--DELETE A
FROM apremiosTrab AS A
INNER JOIN T 
ON T.aptFacCtrCod = A.aptFacCtrCod 
AND T.aptFacPerCod = A.aptFacPerCod 
AND T.aptFacVersion = A.aptFacVersion 
AND T.aptFacCod = A.aptFacCod
AND T.RN>10

--3: Hacemos algo similar con las de consumo
--Seleccionamos todos los apremios de consumo
--Periodos 200000
--Dejaremos a lo sumo tres de consumo y tres rectificativas por cada periodo

WITH T AS(
SELECT *
, RN=ROW_NUMBER() OVER (PARTITION BY aptFacPerCod, aptFacVersion ORDER BY aptFacCtrCod)
FROM apremiosTrab 
WHERE aptFacPerCod >'200000')
SELECT * 
--DELETE A
FROM apremiosTrab AS A
INNER JOIN T 
ON T.aptFacCtrCod = A.aptFacCtrCod 
AND T.aptFacPerCod = A.aptFacPerCod 
AND T.aptFacVersion = A.aptFacVersion 
AND T.aptFacCod = A.aptFacCod
AND T.RN>3

--Con esto sacamos una muestra que vamos a guardar en una tabla
SELECT * 
INTO Trabajo.ApremiosTrab
FROM apremiosTrab AS A

--**************************
--***************************
--Para probar, seleccionamos todo, y borramos aquellas que no aparezcan en nuestra tabla de pruebas
SELECT * 
--DELETE A
FROM apremiosTrab AS A
LEFT JOIN Trabajo.ApremiosTrab AS T 
ON T.aptFacCtrCod = A.aptFacCtrCod 
AND T.aptFacPerCod = A.aptFacPerCod 
AND T.aptFacVersion = A.aptFacVersion 
AND T.aptFacCod = A.aptFacCod
WHERE T.aptUsrCod IS NULL


DELETE FROM apremios WHERE aprFechaGeneracion>='20240522'

SELECT * 
--DELETE
FROM Task_Schedule WHERE tskUser = 'gmdesousa' and tskNumber<13


INSERT INTO dbo.apremiosTrab
SELECT * FROM Trabajo.apremiosTrab

SELECT * FROM contratos