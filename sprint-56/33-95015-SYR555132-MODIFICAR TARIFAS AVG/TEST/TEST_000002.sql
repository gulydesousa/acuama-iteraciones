SELECT ctrcod, ctrValorc1 
FROM contratos WHERE ctrfecanu IS NULL

SELECT * FROm facturas WHERE facPerCod='000005'
SELECT * FROM series

SELECT * 
FROM contratoServicio WHERE ctsctrcod=12

--***********************************
--Deshacer la baja
SELECT * 
--UPDATE C SET ctsfecbaj=NULL
FROM contratoServicio AS C
WHERE ctsctrcod=12 AND ctsfecbaj='20240815'

SELECT * 
--DELETE
FROM facSIIDesgloseFactura WHERE fclSiiFacPerCod='000002' AND fclSiiFacCtrCod=12

SELECT * 
--DELETE
FROM faclin WHERE fclFacCtrCod=12 and fclFacPerCod='000002'

SELECT * 
--DELETE
FROM facSII WHERE fcSiiFacPerCod='000002' AND fcSiiFacCtrCod=12

SELECT *
--DELETE
FROM facturas WHERE facPerCod='000002' AND facCtrCod=12

SELECT * 
--UPDATE C set ctrfecanu=NULL,	ctrusrcodanu=NULL, ctrbaja=0, ctrLecturaUlt=52817, ctrLecturaUltFec='20240514', ctrFecSolBaja=NULL
FROM contratos AS C WHERE ctrcod=12 AND ctrversion=3


SELECT * 
--DELETE
FROM ctrcon where ctcCtr=12 AND ctcFec='20240731'


