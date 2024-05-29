DECLARE  @periodoD NVARCHAR(6) = '202304'
, @periodoH NVARCHAR(6) = '202304'
, @preFactura BIT = 1
, @fechaD NVARCHAR(4000)
, @fechaH NVARCHAR(4000)
, @versionD NVARCHAR(4000)
, @versionH NVARCHAR(4000)
select facCtrCod,
	fclfacpercod, perdes, faczoncod, zondes, fcltrfsvcod, svcdes,
	ctrUsoCod,usodes, fcltrfcod,  trfdes
from faclin
	inner join Servicios on svccod = fcltrfsvcod
	inner join Tarifas on trfsrvcod = fcltrfsvcod and trfcod = fcltrfcod 
	inner join Facturas on faccod = fclfaccod and facpercod = fclfacpercod and facctrcod = fclfacctrcod and facversion = fclfacversion
	inner join Contratos on ctrcod = facctrcod and ctrversion = facctrversion
	inner join usos on ctrUsoCod = usos.usocod
	left join sociedades on scdcod=ISNULL(facserscdcod,ISNULL((select pgsvalor from parametros where pgsclave='SOCIEDAD_POR_DEFECTO'),1))
	inner join Zonas on zoncod = faczoncod
	inner join Periodos on percod = fclfacpercod

where (facPerCod >= @periodoD OR @periodoD IS NULL)
	and (facPerCod <= @periodoH OR @periodoH IS NULL)
	and svccod=5 AND trfcod=1

	--and (facZonCod >= @zonaD  OR @zonaD IS NULL)
	--and (facZonCod <= @zonaH OR @zonaH IS NULL)
	--and (facFecha>= @fechaD OR @fechaD IS NULL)
	--and (facFecha <= @fechaH OR @fechaH IS NULL)
	--and (facCtrCod >= @contratoD OR @contratoD IS NULL)
	--and (facCtrCod <= @contratoH OR @contratoH IS NULL)
	--and (facVersion >= @versionD OR @versionD IS NULL)
	--and (facVersion <= @versionH OR @versionH IS NULL)
	--and (fcltrfsvcod >= @servicioD OR @servicioD IS NULL)
	--and (fcltrfsvcod <= @servicioH OR @servicioH IS NULL)
	and ((facFechaRectif IS NULL) or (facFechaRectif > isnull(@fechaH,GETDATE())) or (@versionD = @versionH))
	--AND((fclFecLiq>=@fechaH) OR	(fclFecLiq IS NULL AND fclUsrLiq IS NULL))	
	--AND (@tbRuta1D IS NULL OR ctrRuta1 >= @tbRuta1D) AND (@tbRuta1H IS NULL OR ctrRuta1 <= @tbRuta1H)
	--AND (@tbRuta2D IS NULL OR ctrRuta2 >= @tbRuta2D) AND (@tbRuta2H IS NULL OR ctrRuta2 <= @tbRuta2H)
	--AND (@tbRuta3D IS NULL OR ctrRuta3 >= @tbRuta3D) AND (@tbRuta3H IS NULL OR ctrRuta3 <= @tbRuta3H)
	--AND (@tbRuta4D IS NULL OR ctrRuta4 >= @tbRuta4D) AND (@tbRuta4H IS NULL OR ctrRuta4 <= @tbRuta4H)
	--AND (@tbRuta5D IS NULL OR ctrRuta5 >= @tbRuta5D) AND (@tbRuta5H IS NULL OR ctrRuta5 <= @tbRuta5H)
	--AND (@tbRuta6D IS NULL OR ctrRuta6 >= @tbRuta6D) AND (@tbRuta6H IS NULL OR ctrRuta6 <= @tbRuta6H)
	and ((facNumero IS NOT NULL and @preFactura=0) OR @preFactura=1 OR @preFactura IS NULL)--- Si @preFactura es 0 entonces saca las facturas definitivas y si es 1 saca todas junto con las preFACTURAS
--group by fclfacpercod, perdes, faczoncod, zondes, fcltrfsvcod, svcdes,ctrUsoCod,usodes, fcltrfcod, trfdes, scdImpNombre
--order by fclfacpercod, faczoncod, fcltrfsvcod,ctrUsoCod, fcltrfcod