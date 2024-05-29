USE ACUAMA_GUADALAJARA;
GO

--SELECT * FROm facturas WHERE facctrcod=55051 
--SELECT * FROm facturas WHERE facctrcod=54596 
--SELECT ctrcod, ctrfecreg, ctrfecanu, ctrnuevo FROm contratos WHERE ctrcod=55051 
--SELECT ctrcod, ctrfecreg, ctrfecanu, ctrnuevo FROm contratos WHERE ctrcod=54596


--Habilitamos el contrato para hacer una rectificativa
SELECT ctrcod, ctrversion, ctrfecreg, ctrfecanu, ctrnuevo , ctrbaja
--UPDATE C SET ctrbaja=0, ctrfecanu=NULL
FROm contratos AS C WHERE ctrcod=55051 AND ctrbaja=1 AND ctrfecanu='20211021'


--**** CREAMOS UNA RECTIFICATIVA DE TOTAL 0,00 

--Deshabilitamos el contrato para hacer una rectificativa
SELECT ctrcod, ctrversion, ctrfecreg, ctrfecanu, ctrnuevo , ctrbaja
--UPDATE C SET ctrbaja=1, ctrfecanu='20211021'
FROm contratos AS C WHERE ctrcod=55051 AND ctrbaja=0 AND ctrfecanu IS NULL

SELECT * 
--UPDATE F SET facObs='SYR-542525'
FROm facturas AS F WHERE facctrcod=55051 AND facVersion=2