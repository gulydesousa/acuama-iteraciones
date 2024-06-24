declare @fechaFacturaD datetime = '01/02/2023'
declare @fechaFacturaH datetime = '31/12/2023'
declare @fechaLiquidacionD datetime
declare @fechaLiquidacionH datetime


DECLARE @fDesde DATE, @fHasta DATE, @flDesde DATE, @flHasta DATE;
SELECT @fDesde = @fechaFacturaD, @flDesde = @fechaLiquidacionD
	 , @flHasta= DATEADD(DAY, 1, @fechaLiquidacionH)
	 , @fHasta= DATEADD(DAY, 1, @fechaFacturaH);

--SELECT @fDesde, @fHasta, @flHasta, @flDesde;

declare @periodoCalculadoD varchar(6) = NULL
declare @periodoCalculadoH varchar(6) = NULL
declare @perLiqAnt as varchar(6) = null
SET @perLiqAnt = (select top 1 przcodper from perzona where przfPeriodoD = DATEADD(MM, -6, @fechaFacturaD))

if(@fechaFacturaD is not null and @fechaFacturaH is not null)
begin
	declare @mes as varchar(2) = (select month(@fechaFacturaH))

	if(@mes = '12')
	begin
		--si voy a sacar el 2º semestre, tengo que incluir todos los periodos del año mientras entre en rango de fecha
		set @periodoCalculadoD = substring((select top 1 przcodper from perzona where przfPeriodoD = @fechaFacturaD), 0, 5) + '01'
		set @periodoCalculadoH = (select top 1 przcodper from perzona where przfPeriodoH = CONVERT(date, @fechaFacturaH))
	end
	else
	begin
		set @periodoCalculadoD = (select top 1 przcodper from perzona where przfPeriodoD = @fechaFacturaD)
		set @periodoCalculadoH = (select top 1 przcodper from perzona where przfPeriodoH = CONVERT(date, @fechaFacturaH))
	end
end
else
begin
	set @periodoCalculadoD = (select top 1 przcodper from perzona where przfPeriodoD = @fechaFacturaD)
	set @periodoCalculadoH = (select top 1 przcodper from perzona where przfPeriodoH = CONVERT(date, @fechaFacturaH))
end


SELECT F.facCod, facPerCod,facCtrCod, facVersion, F.facFecha, F.facFechaRectif
FROM  dbo.facturas AS F
INNER JOIN dbo.faclin AS FL
	ON  FL.fclFacCtrCod= F.facCtrCod 
	AND FL.fclFacPerCod= F.facPerCod 
	AND FL.fclFacCod= F.facCod 
	AND FL.fclFacVersion= F.facVersion
	AND F.facCtrCod=7474
	AND FL.fclFecLiqImpuesto IS NOT NULL
	AND FL.fclTrfSvCod IN (19, 20, 60)	
	AND (@flDesde IS NULL OR FL.fclFecLiqImpuesto >= @flDesde) 
	AND (@flHasta IS NULL OR FL.fclFecLiqImpuesto < @flHasta) 
WHERE (
		--Facturada dentro 
		(@fDesde IS NULL OR F.facFecha>=@fDesde) AND (@fHasta IS NULL OR F.facFecha<@fHasta) 
		AND 
		--Rectificada fuera:
		(F.facFechaRectif IS NULL OR ((@fDesde IS NOT NULL AND F.facFechaRectif<@fDesde) OR (@fHasta IS NULL AND F.facFechaRectif>=@fHasta)))
	  ) OR (
		--Facturada fuera
		((@fDesde IS NOT NULL AND F.facFecha<@fDesde) OR (@fHasta IS NULL AND F.facFecha>=@fHasta)) 
		AND
		--Rectificada dentro
		(F.facFechaRectif IS NOT NULL AND ((@fDesde IS NULL OR F.facFechaRectif>=@fDesde) AND (@fHasta IS NULL OR F.facFechaRectif<@fHasta)))
	  )
		 
		
select 
	max(FacPerCod) periodo,
	max(sercodAlternativo) serie,
	facNumero numero,
	facCtrCod contrato,
	facFecha fecha,
	facFechaRectif fechaRectif,
	max(case when fclTrfSvCod IN (19,20,60) THEN trfdes end) usoCanon, --tarifa ?
	sum(case when fclTrfSvCod IN (19,60) THEN fclBase else 0 end) as ImporteCF,
	sum(case when fclTrfSvCod IN (19,60) THEN fclImpImpuesto else 0 end) as ImpuestoCF,
	sum(case when fclTrfSvCod=20 and fclTrfCod<>8501 then fclUnidades1 else 0 end) as MetrosTramo1,
	sum(case when fclTrfSvCod=20 and fclTrfCod<>8501 then fclUnidades1*fclPrecio1 else 0 end) as ImporteTramo1,
	sum(case when fclTrfSvCod=20 and fclTrfCod<>8501 then fclPrecio1 else 0 end )as TarifaTramo1,
	sum(case when fclTrfSvCod=20 and fclTrfCod<>8501 then fclUnidades2 else 0 end) as MetrosTramo2,
	sum(case when fclTrfSvCod=20 and fclTrfCod<>8501 then fclUnidades2*fclPrecio2 else 0 end)as ImporteTramo2,
	sum(case when fclTrfSvCod=20 and fclTrfCod<>8501 then fclPrecio2 else 0 end) as TarifaTramo2,
	sum(case when fclTrfSvCod=20 and fclTrfCod<>8501 then fclUnidades3 else 0 end) as MetrosTramo3,
	sum(case when fclTrfSvCod=20 and fclTrfCod<>8501 then fclUnidades3*fclPrecio3 else 0 end) as ImporteTramo3,
	sum(case when fclTrfSvCod=20 and fclTrfCod<>8501 then fclPrecio3 else 0 end) as TarifaTramo3,
	sum(case when fclTrfSvCod=20 and fclTrfCod<>8501 then fclUnidades4 else 0 end) as MetrosTramo4,
	sum(case when fclTrfSvCod=20 and fclTrfCod<>8501 then fclUnidades4*fclPrecio4 else 0 end) as ImporteTramo4,
	sum(case when fclTrfSvCod=20 and fclTrfCod<>8501 then fclPrecio4 else 0 end) as TarifaTramo4,
	sum(case when fclTrfSvCod=20 and fclTrfCod=8501 then fclUnidades1 +  fclUnidades2 + fclUnidades3 + fclUnidades4 + fclUnidades5 + fclUnidades6 + fclUnidades7 + fclUnidades8 else 0 end) as MetrosTramoFuga,
	sum(case when fclTrfSvCod=20 and fclTrfCod=8501 then fclBase else 0 end) as ImporteTramoFuga,
	sum(case when fclTrfSvCod=20 and fclTrfCod=8501 then fclUnidades4*fclPrecio4 else 0 end) as TarifaTramoFuga,
	sum(case when fclTrfSvCod=20 then fclBase else 0 end) as ImporteCv,
	sum(case when fclTrfSvCod=20 then fclImpImpuesto else 0 end) as ImpuestoCv,
	1 TipoFac,--?
	max(case when (facNumeroRectif IS NOT NULL OR (fclTrfSvCod = 20 AND fclBase < 0)) then 'R' else 'F' end) as Origen,
	max(facLecAntFec) FecLecAnt,
	max(facLecActFec) FecLecAct,
	case when ((facFechaRectif between @fechaFacturaD and @fechaFacturaH) and (facFecha not between @fechaFacturaD and @fechaFacturaH)) then 1 else 0 end as Negativo
 from facturas
 INNER JOIN faclin 
	on fclFacCtrCod= facCtrCod and fclFacPerCod= facPerCod and fclFacCod= facCod and fclFacVersion= facVersion
	AND facCtrCod=7474
 INNER JOIN series
	on sercod= facSerCod
INNER JOIN tarifas
	on trfsrvcod= fclTrfSvCod and trfcod=fclTrfCod
       where   		  
		  (fclFecLiqImpuesto is not null) AND
	      (fclFecLiqImpuesto >= @fechaLiquidacionD OR @fechaLiquidacionD IS NULL) AND
	      (fclFecLiqImpuesto <= @fechaLiquidacionH OR @fechaLiquidacionH IS NULL) AND
		  
		  fclTrfSvCod IN (19, 20, 60)

		  AND
		  (
		  --totales
		  (			  	
			(					  
			  ((facFecha between @fechaFacturaD and @fechaFacturaH) and (facFechaRectif is null OR (facFechaRectif not between @fechaFacturaD and @fechaFacturaH)))
			  OR
			  ((facFechaRectif between @fechaFacturaD and @fechaFacturaH) and ((facFecha not between @fechaFacturaD and @fechaFacturaH)))
			)		

		   )

		   OR
		   --totalesPA
		   (
		    (					  
			  ((facFecha between @fechaFacturaD and @fechaFacturaH) and (facFechaRectif is null OR (facFechaRectif not between @fechaFacturaD and @fechaFacturaH)))
			  OR
			  ((facFechaRectif between @fechaFacturaD and @fechaFacturaH) and (facFecha not between @fechaFacturaD and @fechaFacturaH))
			)
								  
			  AND
			   (fclFacPerCod like '20%' and fclFacPerCod not between @periodoCalculadoD and @periodoCalculadoH)
			AND facPerCod >= @perLiqAnt
			)
		   )

		 
group by facNumero, facPerCod, facVersion, facCtrCod, facFecha, facFechaRectif
		 

	/*	  
-- INNER JOIN series
--	on sercod= facSerCod
--INNER JOIN tarifas
--	on trfsrvcod= fclTrfSvCod and trfcod=fclTrfCod
       where   		  
	      
		  
		  AND
		  (
		  --totales
		  (			  	
			(					  
			  ((facFecha between @fechaFacturaD and @fechaFacturaH) and (facFechaRectif is null OR (facFechaRectif not between @fechaFacturaD and @fechaFacturaH)))
			  OR
			  ((facFechaRectif between @fechaFacturaD and @fechaFacturaH) and ((facFecha not between @fechaFacturaD and @fechaFacturaH)))
			)		
		  
			
		   )

		   OR
		   --totalesPA
		   (
		    (					  
			  ((facFecha between @fechaFacturaD and @fechaFacturaH) and (facFechaRectif is null OR (facFechaRectif not between @fechaFacturaD and @fechaFacturaH)))
			  OR
			  ((facFechaRectif between @fechaFacturaD and @fechaFacturaH) and (facFecha not between @fechaFacturaD and @fechaFacturaH))
			)
								  
			  AND
			   (fclFacPerCod like '20%' and fclFacPerCod not between @periodoCalculadoD and @periodoCalculadoH)
			AND facPerCod >= @perLiqAnt
			)
		   )

		

group by facNumero, facPerCod, facVersion, facCtrCod, facFecha, facFechaRectif















;with aux as 
(
	select 
	max(FacPerCod) periodo,
	max(sercodAlternativo) serie,
	facNumero numero,
	facCtrCod contrato,
	facFecha fecha,
	facFechaRectif fechaRectif,
	max(case when fclTrfSvCod IN (19,20,60) THEN trfdes end) usoCanon, --tarifa ?
	sum(case when fclTrfSvCod IN (19,60) THEN fclBase else 0 end) as ImporteCF,
	sum(case when fclTrfSvCod IN (19,60) THEN fclImpImpuesto else 0 end) as ImpuestoCF,
	sum(case when fclTrfSvCod=20 and fclTrfCod<>8501 then fclUnidades1 else 0 end) as MetrosTramo1,
	sum(case when fclTrfSvCod=20 and fclTrfCod<>8501 then fclUnidades1*fclPrecio1 else 0 end) as ImporteTramo1,
	sum(case when fclTrfSvCod=20 and fclTrfCod<>8501 then fclPrecio1 else 0 end )as TarifaTramo1,
	sum(case when fclTrfSvCod=20 and fclTrfCod<>8501 then fclUnidades2 else 0 end) as MetrosTramo2,
	sum(case when fclTrfSvCod=20 and fclTrfCod<>8501 then fclUnidades2*fclPrecio2 else 0 end)as ImporteTramo2,
	sum(case when fclTrfSvCod=20 and fclTrfCod<>8501 then fclPrecio2 else 0 end) as TarifaTramo2,
	sum(case when fclTrfSvCod=20 and fclTrfCod<>8501 then fclUnidades3 else 0 end) as MetrosTramo3,
	sum(case when fclTrfSvCod=20 and fclTrfCod<>8501 then fclUnidades3*fclPrecio3 else 0 end) as ImporteTramo3,
	sum(case when fclTrfSvCod=20 and fclTrfCod<>8501 then fclPrecio3 else 0 end) as TarifaTramo3,
	sum(case when fclTrfSvCod=20 and fclTrfCod<>8501 then fclUnidades4 else 0 end) as MetrosTramo4,
	sum(case when fclTrfSvCod=20 and fclTrfCod<>8501 then fclUnidades4*fclPrecio4 else 0 end) as ImporteTramo4,
	sum(case when fclTrfSvCod=20 and fclTrfCod<>8501 then fclPrecio4 else 0 end) as TarifaTramo4,
	sum(case when fclTrfSvCod=20 and fclTrfCod=8501 then fclUnidades1 +  fclUnidades2 + fclUnidades3 + fclUnidades4 + fclUnidades5 + fclUnidades6 + fclUnidades7 + fclUnidades8 else 0 end) as MetrosTramoFuga,
	sum(case when fclTrfSvCod=20 and fclTrfCod=8501 then fclBase else 0 end) as ImporteTramoFuga,
	sum(case when fclTrfSvCod=20 and fclTrfCod=8501 then fclUnidades4*fclPrecio4 else 0 end) as TarifaTramoFuga,
	sum(case when fclTrfSvCod=20 then fclBase else 0 end) as ImporteCv,
	sum(case when fclTrfSvCod=20 then fclImpImpuesto else 0 end) as ImpuestoCv,
	1 TipoFac,--?
	max(case when (facNumeroRectif IS NOT NULL OR (fclTrfSvCod = 20 AND fclBase < 0)) then 'R' else 'F' end) as Origen,
	max(facLecAntFec) FecLecAnt,
	max(facLecActFec) FecLecAct,
	case when ((facFechaRectif between @fechaFacturaD and @fechaFacturaH) and (facFecha not between @fechaFacturaD and @fechaFacturaH)) then 1 else 0 end as Negativo
 from facturas
 INNER JOIN faclin 
	on fclFacCtrCod= facCtrCod and fclFacPerCod= facPerCod and fclFacCod= facCod and fclFacVersion= facVersion
 INNER JOIN series
	on sercod= facSerCod
INNER JOIN tarifas
	on trfsrvcod= fclTrfSvCod and trfcod=fclTrfCod
       where   		  
		  (fclFecLiqImpuesto is not null) AND
	      (fclFecLiqImpuesto >= @fechaLiquidacionD OR @fechaLiquidacionD IS NULL) AND
	      (fclFecLiqImpuesto <= @fechaLiquidacionH OR @fechaLiquidacionH IS NULL) AND
		  
		  fclTrfSvCod IN (19, 20, 60)

		  AND
		  (
		  --totales
		  (			  	
			(					  
			  ((facFecha between @fechaFacturaD and @fechaFacturaH) and (facFechaRectif is null OR (facFechaRectif not between @fechaFacturaD and @fechaFacturaH)))
			  OR
			  ((facFechaRectif between @fechaFacturaD and @fechaFacturaH) and ((facFecha not between @fechaFacturaD and @fechaFacturaH)))
			)		
		  
			--AND
			-- ((facPerCod between @periodoCalculadoD and @periodoCalculadoH)
			-- or
			-- ((facPerCod like '0%') AND (facLecActFec between @fechaFacturaD AND @fechaFacturaH))
			-- --or ((fclFacPerCod like '20%' and (fclFacPerCod not between @periodoCalculadoD and @periodoCalculadoH)) )
			-- )
		   )

		   OR
		   --totalesPA
		   (
		    (					  
			  ((facFecha between @fechaFacturaD and @fechaFacturaH) and (facFechaRectif is null OR (facFechaRectif not between @fechaFacturaD and @fechaFacturaH)))
			  OR
			  ((facFechaRectif between @fechaFacturaD and @fechaFacturaH) and (facFecha not between @fechaFacturaD and @fechaFacturaH))
			)
								  
			  AND
			   (fclFacPerCod like '20%' and fclFacPerCod not between @periodoCalculadoD and @periodoCalculadoH)
			AND facPerCod >= @perLiqAnt
			)
		   )

		 -- AND			  	
		 -- ((
			--(					  
			--  ((facFecha between @fechaFacturaD and @fechaFacturaH) and (facFechaRectif is null OR (facFechaRectif not between @fechaFacturaD and @fechaFacturaH)))
			--  OR
			--  ((facFechaRectif between @fechaFacturaD and @fechaFacturaH) and (facFecha not between @fechaFacturaD and @fechaFacturaH))
			--)			
			--AND (facLecActFec between @fechaFacturaD AND @fechaFacturaH)
			--AND (facPerCod between @periodoCalculadoD and @periodoCalculadoH)
		 -- )
			--OR
	  --    (
			--(					  
			--  ((facFecha between @fechaFacturaD and @fechaFacturaH) and (facFechaRectif is null OR (facFechaRectif not between @fechaFacturaD and @fechaFacturaH)))
			--  OR
			--  ((facFechaRectif between @fechaFacturaD and @fechaFacturaH) and (facFecha not between @fechaFacturaD and @fechaFacturaH))
			--)		
			--AND
			--((facPerCod like '20%' and (facPerCod not between @periodoCalculadoD and @periodoCalculadoH)) )
		 -- ))

group by facNumero, facPerCod, facVersion, facCtrCod, facFecha, facFechaRectif


), final as
(
	select 
	periodo,
	serie,
	numero,
	contrato,
	fecha,
	fechaRectif,
	usoCanon,
	case when Negativo = 1 then ImporteCF * -1 else ImporteCF end as ImporteCF,
	case when Negativo = 1 then ImpuestoCF * -1 else ImpuestoCF end as ImpuestoCF,
	case when Negativo = 1 then MetrosTramo1 * -1 else MetrosTramo1 end as MetrosTramo1,
	case when Negativo = 1 then ImporteTramo1 * -1 else ImporteTramo1 end as ImporteTramo1,
	case when Negativo = 1 then TarifaTramo1 * -1 else TarifaTramo1 end as TarifaTramo1,
	case when Negativo = 1 then MetrosTramo2 * -1 else MetrosTramo2 end as MetrosTramo2,
	case when Negativo = 1 then ImporteTramo2 * -1 else ImporteTramo2 end as ImporteTramo2,
	case when Negativo = 1 then TarifaTramo2 * -1 else TarifaTramo2 end as TarifaTramo2,
	case when Negativo = 1 then MetrosTramo3 * -1 else MetrosTramo3 end as MetrosTramo3,
	case when Negativo = 1 then ImporteTramo3 * -1 else ImporteTramo3 end as ImporteTramo3,
	case when Negativo = 1 then TarifaTramo3 * -1 else TarifaTramo3 end as TarifaTramo3,
	case when Negativo = 1 then MetrosTramo4 * -1 else MetrosTramo4 end as MetrosTramo4,
	case when Negativo = 1 then ImporteTramo4 * -1 else ImporteTramo4 end as ImporteTramo4,
	case when Negativo = 1 then TarifaTramo4 * -1 else TarifaTramo4 end as TarifaTramo4,
	case when Negativo = 1 then MetrosTramoFuga * -1 else MetrosTramoFuga end as MetrosTramoFuga,
	case when Negativo = 1 then ImporteTramoFuga * -1 else ImporteTramoFuga end as ImporteTramoFuga,
	case when Negativo = 1 then TarifaTramoFuga * -1 else TarifaTramoFuga end as TarifaTramoFuga,
	case when Negativo = 1 then ImporteCv * -1 else ImporteCv end as ImporteCv,
	case when Negativo = 1 then ImpuestoCv * -1 else ImpuestoCv end as ImpuestoCv,
	TipoFac,
	Origen,
	FecLecAnt,
	FecLecAct,
	Negativo
	
	from aux
)

select * 
from final
order by  periodo, contrato, fecha

*/