/*
Necesito anular un contrato ya que es Subrogacion y no cambio de titularidad. 
El contrato a anular es el 33321 
y que se quede el anterior 33267 para poder hacer la Subrogacion.
*/
--Anulado desde acuama
SELECT * FROM contratos WHERE ctrcod=33321

SELECT ctrnuevo,* FROM contratos WHERE ctrcod=33267 

--INSERT INTO contratos
SELECT [ctrcod]
      ,[ctrversion] + 1
      ,[ctrfec]
      ,[ctrfecini]
      ,[ctrfecreg] = GETDATE()
      ,[ctrusrcod] = 'gmdesousa'
      ,[ctrfecanu] = NULL
      ,[ctrusrcodanu] = NULL
      ,[ctrinmcod]
      ,[ctremplaza]
      ,[ctrbatfila]
      ,[ctrbatcolum]
      ,[ctravisolector]
      ,[ctrzoncod]
      ,[ctrbaja] = 0
      ,[ctrRuta1]
      ,[ctrRuta2]
      ,[ctrRuta3]
      ,[ctrRuta4]
      ,[ctrRuta5]
      ,[ctrRuta6]
      ,[ctrobs] = 'SYR-532760: Revertir Cambio titular'
      ,[ctrLecturaUlt]
      ,[ctrLecturaUltFec]
      ,[ctrUsoCod]
      ,[ctrFecSolAlta]
      ,[ctrFecSolBaja] = NULL
      ,[ctrTitCod]
      ,[ctrTitTipDoc]
      ,[ctrTitDocIden]
      ,[ctrTitNom]
      ,[ctrTitNac]
      ,[ctrTitDir]
      ,[ctrTitPrv]
      ,[ctrTitPob]
      ,[ctrTitCPos]
      ,[ctrPagTipDoc]
      ,[ctrPagDocIden]
      ,[ctrPagNom]
      ,[ctrPagNac]
      ,[ctrPagDir]
      ,[ctrPagPrv]
      ,[ctrPagPob]
      ,[ctrPagCPos]
      ,[ctrCCC]
      ,[ctrEnvNom]
      ,[ctrEnvNac]
      ,[ctrEnvDir]
      ,[ctrEnvPob]
      ,[ctrEnvPrv]
      ,[ctrEnvCPos]
      ,[ctrTlf1]
      ,[ctrTlfRef1]
      ,[ctrTlf2]
      ,[ctrTlfRef2]
      ,[ctrTlf3]
      ,[ctrTlfRef3]
      ,[ctrFax]
      ,[ctrFaxRef]
      ,[ctrEmail]
      ,[ctrNumChapa]
      ,[ctrNuevo] = NULL
      ,[ctrComunitario]
      ,[ctrEmpadronados]
      ,[ctrCalculoComunitario]
      ,[ctrRepresent]
      ,[ctrValorc1]
      ,[ctrValorc2]
      ,[ctrValorc3]
      ,[ctrValorc4]
      ,[ctrTvipCodigo]
      ,[ctrAcoCod]
      ,[ctrSctCod]
      ,[ctrIban]
      ,[ctrBic]
      ,[ctrManRef]
      ,[ctrFace]
      ,[ctrFaceMinimo]
      ,[ctrFaceOficCon]
      ,[ctrFaceOrgGest]
      ,[ctrFaceUnitrmi]
      ,[ctrFacePortal]
      ,[ctrFaceMail]
      ,[ctrFaceTipoEnvio]
      ,[ctrFaceAdmPublica]
      ,[ctrFaceTipo]
      ,[ctrFaceOrgProponente]
      ,[ctrNoEmision]
      ,[ctrTitDocIdenValidado]
      ,[ctrPagDocIdenValidado]
      ,[ctrTitNacionalidad]
      ,[ctrPagNacionalidad]
  FROM [dbo].[contratos]
  WHERE ctrcod=33267 


  SELECT * 
  --UPDATE C SET ctsfecbaj= NULL
  FROM contratoServicio AS C WHERE ctsctrcod=33267 AND ctsfecbaj = '20240416'


  SELECT * 
  --UPDATE C SET ctrfecanu='20240417T10:10:48.950', ctrobs='SYR-532760: Revertir Cambio titular'
  FROM contratos WHERE ctrcod=33267 AND ctrfecanu='2024-04-16T00:00:00.000'