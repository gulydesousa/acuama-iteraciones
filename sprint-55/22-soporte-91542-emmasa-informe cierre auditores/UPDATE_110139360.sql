SELECT facNumeroAqua, facFechaVto, facFechaVtoOrig, *
--UPDATE F SET facSerieRectif='1', facNumeroRectif='2112002211', facFechaRectif='20210702'
FROM facturas AS F WHERE facPerCod='000001' AND facCtrCod=110139360 and facCod=1 AND facVersion=1