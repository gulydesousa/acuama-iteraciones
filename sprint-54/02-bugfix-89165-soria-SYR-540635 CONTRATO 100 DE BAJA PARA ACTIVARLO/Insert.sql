--SYR-540635 CONTRATO 100 DE BAJA PARA ACTIVARLO
--INSERT INTO contratos
SELECT [ctrcod]
      ,[ctrversion]= [ctrversion]+1
      ,[ctrfec]
      ,[ctrfecini]
      ,[ctrfecreg]=GETDATE()
      ,[ctrusrcod]='gmdesousa'
      ,[ctrfecanu]=NULL
      ,[ctrusrcodanu]=NULL
      ,[ctrinmcod]
      ,[ctremplaza]
      ,[ctrbatfila]
      ,[ctrbatcolum]
      ,[ctravisolector]
      ,[ctrzoncod]
      ,[ctrbaja]=0
      ,[ctrRuta1]
      ,[ctrRuta2]
      ,[ctrRuta3]
      ,[ctrRuta4]
      ,[ctrRuta5]
      ,[ctrRuta6]
      ,[ctrobs]= 'SYR-540635 CONTRATO 100 DE BAJA PARA ACTIVARLO'
      ,[ctrLecturaUlt]
      ,[ctrLecturaUltFec]
      ,[ctrUsoCod]
      ,[ctrFecSolAlta] 
      ,[ctrFecSolBaja]=NULL
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
      ,[ctrNuevo]
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
FROM contratos WHERE ctrcod=100 AND ctrversion=4


SELECT * 
--UPDATE F SET facCtrVersion=5
FROM facturas AS F WHERE facCtrCod=100 AND facNumero='2260046774'