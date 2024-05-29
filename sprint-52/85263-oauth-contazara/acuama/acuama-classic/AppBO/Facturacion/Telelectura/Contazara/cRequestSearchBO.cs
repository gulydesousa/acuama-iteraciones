using System;

namespace BO.Facturacion.Telelectura.Contazara
{
    /// <summary>
    /// Clase que se usa para enviar los parametros al servicio de lecturas
    /// /meters/readings/search?page=0&perPage=50&readType=offline&dateType=read_date&fromDate=20231215&toDate=20231216&plrType=1
    /// </summary>
    public class cRequestSearchBO
    {
        /// <summary>
        /// Numero de pagina
        /// </summary>
        public int Page { get; set; } = 0;
        /// <summary>
        /// Registros por pagina
        /// </summary>
        public int PerPage { get; set; } = 50;
        public string ReadType { get; set; } = "offline";
        public string DateType { get; set; } = "read_date";
        /// <summary>
        /// Fecha Inicio
        /// </summary>
        public DateTime FromDate { get; set; } = DateTime.Now.AddDays(-1);
        /// <summary>
        /// Fecha Fin
        /// </summary>
        public DateTime ToDate { get; set; } = DateTime.Now;
        public string PlrType { get; set; } = "1";

        public override string ToString()
        {
            return $"?page={Page}&perPage={PerPage}&readType={ReadType}&dateType={DateType}&fromDate={FromDate.ToString("yyyyMMdd")}&toDate={ToDate.ToString("yyyyMMdd")}&plrType={PlrType}";
        }
    }
}
