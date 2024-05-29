# 📡 TELELECTURA CONTAZARA

> `Facturación/Facturación/Telelectura Contazara`

- Zona
- Ruta

Se permite seleccionar solo las **zonas abiertas**

```SQL
SELECT * FROM perzona WHERE przcierrereal IS NULL
```

[ ] Selección de un lote

[ ] Seleccion de multiples lotes

Telelectura se omite si: 
[ ] Con FacInspección 

[ ] F.Lectura Actual > F.Telelectura

[ ] F.Telelectura no puede superar en 91 dias la fecha de lectura anterior

### 🕐 Contadores con telelecturas

```sql
SELECT F.facPerCod, C.conNumSerie, CC.conTeleLectura, F.*
FROM facturas AS F
LEFT JOIN dbo.vCambiosContador AS C
ON C.ctrCod = F.facCtrCod 
AND C.esUltimaInstalacion=1
LEFT JOIN dbo.contador AS CC
ON CC.conID = C.conId
WHERE --F.facZonCod='7'AND 
F.facPerCod='202304'
--AND F.facLote = 7
--AND CC.conNumSerie='P23NE855734A'
AND CC.conTeleLectura=1
ORDER BY facLote

```

## ⌛ Ejecución por tarea

- Abrir una zona : **ZONA 7**

- Lecturas antes de la ejecución.



