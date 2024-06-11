using System;
using System.Linq;
using System.Text;
using BO.Comun;
using BO.Cobros;
using DL.Cobros;
using BO.Facturacion;
using BL.Facturacion;
using BL.Sistema;
using BL.Tasks;
using BO.Catastro;
using BO.Resources;
using BO.Sistema;
using BO.Tasks;
using System.IO;
using System.Text.RegularExpressions;
using System.Transactions;
using System.Web;
using BL.Comun;
using BL.Catastro;
using BL.Contabilidad;

namespace BL.Cobros
{
    /// <summary>
    /// Enumerado para establecer el valor de los c�digos de subconceptos facilitados por el ayuntamiento. Fichero apremios
    /// </summary>
    public enum SubconceptoCodigo
    {
        Alcantarillado,
        Agua,
        Contador
    }

    public static class cApremiosTrabBL
    {
        /// <summary>
        /// Devuelve el c�digo del subConcepto
        /// </summary>
        /// <returns></returns>
        public static string SubContepto(SubconceptoCodigo subConcepto)
        {
            string codigo = null;

            if (subConcepto == SubconceptoCodigo.Agua)
                codigo = "01";
            if (subConcepto == SubconceptoCodigo.Contador)
                codigo = "02";
            if (subConcepto == SubconceptoCodigo.Alcantarillado)
                codigo = "03";
            return codigo;
        }

        /// <summary>
        /// Realiza la inserci�n de apremiosTrab a partir de la selecci�n del usuario
        /// </summary>
        /// <param name="apremiosTrabSeleccion">Objeto a insertar</param>
        /// <param name="regAfectados">N�mero de registros insertados</param>
        /// <returns>Objeto Respuesta con el resultado de la operacion</returns>
        public static cRespuesta Insertar(cApremioTrabBO_Seleccion apremioTrabSeleccion, out int regAfectados)
        {
            regAfectados = 0;
            cApremiosTrabDL.Parametros parametros = new cApremiosTrabDL.Parametros();
            parametros.ApremioTrab_Seleccion = apremioTrabSeleccion;

            return new cApremiosTrabDL().Insertar(ref parametros, out regAfectados);
        }

        /// <summary>
        /// Borra un registro
        /// </summary>
        /// <param name="apremioTrab">Registro a borrar</param>
        /// <returns>Resultado de la operaci�n</returns>
        public static cRespuesta Borrar(cApremioTrabBO apremioTrab)
        {
            cApremiosTrabDL.Parametros parametros = new cApremiosTrabDL.Parametros();

            if (apremioTrab != null)
            {
                parametros.ApremioTrab = new cApremioTrabBO();
                parametros.ApremioTrab.UsuarioCodigo = apremioTrab.UsuarioCodigo;
                parametros.ApremioTrab.Tipo = apremioTrab.Tipo;
                parametros.ApremioTrab.FacturaCodigo = apremioTrab.FacturaCodigo;
                parametros.ApremioTrab.PeriodoCodigo = apremioTrab.PeriodoCodigo;
                parametros.ApremioTrab.ContratoCodigo = apremioTrab.ContratoCodigo;
                parametros.ApremioTrab.FacturaVersion = apremioTrab.FacturaVersion;
            }

            return new cApremiosTrabDL().Borrar(parametros);
        }

        /// <summary>
        /// Obtiene una lista enlazable
        /// </summary>
        /// <param name="seleccion">Selecci�n de apremios en la tabla de trabajo</param>
        /// <param name="respuesta">Resultado de la operaci�n</param>
        /// <returns>Lista enlazable</returns>
        public static cBindableList<cApremioTrabBO> Obtener(cApremioTrabBO_Seleccion seleccion, string usuarioCodigo, short tipo, out cRespuesta respuesta)
        {
            cApremiosTrabDL.Parametros parametros = new cApremiosTrabDL.Parametros();
            parametros.ApremioTrab_Seleccion = seleccion != null ? seleccion : new cApremioTrabBO_Seleccion();
            parametros.ApremioTrab_Seleccion.Usuario = usuarioCodigo;
            parametros.ApremioTrab_Seleccion.Tipo = tipo;

            return new cApremiosTrabDL().Obtener(null, parametros, out respuesta);
        }

        /// <summary>
        /// Obtiene una lista enlazable por usuario
        /// </summary>
        /// <param name="seleccion">Selecci�n de apremios en la tabla de trabajo</param>
        /// <param name="respuesta">Resultado de la operaci�n</param>
        /// <returns>Lista enlazable</returns>
        public static cBindableList<cApremioTrabBO> Obtener(string usuarioCodigo, short tipo, out cRespuesta respuesta)
        {
            cApremiosTrabDL.Parametros parametros = new cApremiosTrabDL.Parametros();
            parametros.ApremioTrab_Seleccion = new cApremioTrabBO_Seleccion();
            parametros.ApremioTrab_Seleccion.Usuario = usuarioCodigo;
            parametros.ApremioTrab_Seleccion.Tipo = tipo;

            return new cApremiosTrabDL().Obtener(null, parametros, out respuesta);
        }

        /// <summary>
        /// M�todo para borrar
        /// </summary>
        /// <returns>Resultado de la operaci�n</returns>
        public static cRespuesta Borrar(string usuario, short tipo)
        {
            cApremiosTrabDL.Parametros parametros = new cApremiosTrabDL.Parametros();
            parametros.ApremioTrab = new cApremioTrabBO();
            parametros.ApremioTrab.UsuarioCodigo = usuario;
            parametros.ApremioTrab.Tipo = tipo;

            return new cApremiosTrabDL().Borrar(parametros);
        }

        public static cRespuesta GenerarCobros(String usuarioCodigo, DateTime fechaCobro, DateTime fechaContabilizacion, out int apremiosProcesados)
        {
            return GenerarCobros(usuarioCodigo, fechaCobro, fechaContabilizacion, out apremiosProcesados, null, null, null);
        }

        public static cRespuesta GenerarCobros(String usuarioCodigo, DateTime fechaCobro, DateTime fechaContabilizacion, out int apremiosProcesados, string taskUser, ETaskType? taskType, int? taskNumber)
        {
            cRespuesta respuesta = new cRespuesta();
            cBindableList<cApremioTrabBO> apremiosTrab = null;
            apremiosProcesados = 0;
            short puntoPagoCodigo = 0, medioPagoCodigo = 0;
            cValidator validador = new cValidator();

            using (TransactionScope scope = cAplicacion.NewTransactionScope())
            {
                // Obtener sociedad por defecto
                string strSociedadCodigo = cParametroBL.ObtenerValor("SOCIEDAD_POR_DEFECTO", out respuesta);
                if (String.IsNullOrEmpty(strSociedadCodigo))
                    cExcepciones.ControlarER(new Exception(Resource.errorParametroNoTieneValor.Replace("@item", "SOCIEDAD_POR_DEFECTO")), TipoExcepcion.Error, out respuesta);
                short sociedadCodigo = Convert.ToInt16(strSociedadCodigo);

                if (respuesta.Resultado == ResultadoProceso.OK)
                {
                    //Comprobar que la fecha sea mayor que la fecha de cierre contable
                    cSociedadBO sociedad = new cSociedadBO();
                    sociedad.Codigo = sociedadCodigo;
                    cSociedadBL.Obtener(ref sociedad, out respuesta);
                    if (sociedad.FechaCierreContable.HasValue && respuesta.Resultado == ResultadoProceso.OK)
                    {
                        if (sociedad.FechaCierreContable.Value >= fechaContabilizacion)
                        {
                            validador.AddCustomMessage(Resource.val_fechaAnteriorEstricta.Replace("@field2", Resource.fechaContable).Replace("@field1", Resource.fechaCierreContable));
                            cExcepciones.ControlarER(new Exception(validador.Validate(true)), TipoExcepcion.Error, out respuesta);
                            return respuesta;
                        }
                    }
                }

                // Obtener los apremiosTrab para generar el fichero
                if (respuesta.Resultado == ResultadoProceso.OK)
                    apremiosTrab = Obtener(usuarioCodigo, (short)cApremioTrabBO.ETipo.Recibir, out respuesta);

                int? asientoAInserta = null, asientoInsertado = null;
                Int64 asientosInsertados = 0;

                // Contabilizaci�n del apremio, el tipo Debe
                if (respuesta.Resultado == ResultadoProceso.OK)
                    respuesta = cContabVentasBL.ContabilidadApremios(sociedadCodigo, fechaContabilizacion, usuarioCodigo, cApremioTrabBO.ETipo.Recibir, 'D', out asientosInsertados, asientoAInserta, out asientoInsertado);

                // Contabilizaci�n del apremio, el tipo Haber
                if (respuesta.Resultado == ResultadoProceso.OK)
                {
                    asientoAInserta = asientoInsertado;
                    respuesta = cContabVentasBL.ContabilidadApremios(sociedadCodigo, fechaContabilizacion, usuarioCodigo, cApremioTrabBO.ETipo.Recibir, 'H', out asientosInsertados, asientoAInserta, out asientoInsertado);
                }

                //Establecer n�mero de pasos de la tarea
                if (taskNumber.HasValue && taskType.HasValue && !String.IsNullOrEmpty(taskUser))
                    cTaskManagerBL.SetTotalSteps(taskUser, taskType.Value, taskNumber.Value, apremiosTrab.Count);

                //Recorro los apremiosTrab de la tabla de trabajo
                for (int i = 0; respuesta.Resultado == ResultadoProceso.OK && i < apremiosTrab.Count; i++)
                {
                    cCobroBO cobro = new cCobroBO();
                    respuesta = cParametroBL.GetShort("PUNTO_PAGO_APREMIOS", out puntoPagoCodigo);

                    if (respuesta.Resultado == ResultadoProceso.OK)
                    {
                        cobro.PPagoCodigo = puntoPagoCodigo;
                        respuesta = cParametroBL.GetShort("MEDIO_PAGO_APREMIOS", out medioPagoCodigo);
                    }

                    if (respuesta.Resultado == ResultadoProceso.OK)
                    {
                        cobro.MpcCodigo = medioPagoCodigo;
                        cobro.Concepto = "Apremio: " + apremiosTrab[i].NumeroGeneracion.ToString();

                        cobro.ContratoCodigo = apremiosTrab[i].ContratoCodigo.Value;
                        cobro.UsuarioCodigo = usuarioCodigo;
                        cobro.Origen = cCobroBO.EOrigenCobro.Apremio;
                        cobro.SociedadCodigo = sociedadCodigo;
                        cobro.Fecha = fechaCobro;

                        cobro.LineasCobro = new cBindableList<cCobroLinBO>();
                        cCobroLinBO cobLin = new cCobroLinBO();
                        cobLin.PeriodoCodigo = apremiosTrab[i].PeriodoCodigo;
                        cobLin.CodigoFactura = apremiosTrab[i].FacturaCodigo.Value;
                        cobLin.Importe = apremiosTrab[i].Importe.Value;
                        cobLin.SociedadCodigo = cobro.SociedadCodigo;
                        cobLin.PPagoCodigo = cobro.PPagoCodigo;
                        cobro.LineasCobro.Add(cobLin);
                    }

                    // Actualizar de la tabla apremios
                    if (respuesta.Resultado == ResultadoProceso.OK)
                    {
                        cApremioCabBO apremio = new cApremioCabBO();
                        apremio.Numero = apremiosTrab[i].NumeroGeneracion;
                        apremio.PeriodoCodigo = apremiosTrab[i].PeriodoCodigo;
                        apremio.FacturaCodigo = apremiosTrab[i].FacturaCodigo;
                        apremio.ContratoCodigo = apremiosTrab[i].ContratoCodigo;
                        apremio.FechaCobro = fechaCobro;

                        respuesta = cApremiosCabBL.Actualizar(apremio);
                    }

                    //Insertar cobro y su l�nea
                    if (respuesta.Resultado == ResultadoProceso.OK)
                        cCobrosBL.InsertarConLineas(ref cobro, out respuesta);

                    // Borrar el apremio de la tabla de trabajo
                    if (respuesta.Resultado == ResultadoProceso.OK)
                        respuesta = Borrar(apremiosTrab[i]);

                    if (respuesta.Resultado == ResultadoProceso.OK)
                        apremiosProcesados++;
                }

                if (respuesta.Resultado == ResultadoProceso.OK)
                    scope.Complete();
            }

            return respuesta;
        }

        /// <summary>
        /// M�todo pensado para funcionar en forma de TAREA.
        /// Genera un String con un formato espec�fico con todos los cobros realizados correctamente.
        /// </summary>
        /// <param name="usuarioCodigo">C�digo del usuario</param>
        /// <param name="numeroApremioGenerado">N�mero de apremio generado</param>
        /// <param name="log">Log</param>
        /// <param name="respuesta">Respuesta</param>
        /// <param name="apremiosProcesados"></param>
        /// <returns>Contenido del fichero</returns>
        public static String Procesar(String usuarioCodigo, out int? numeroApremioGenerado, DateTime fechaContabilizacion, out String log, out cRespuesta respuesta, out int apremiosProcesados)
        {
            string codigoExplotacion;
            string salida = string.Empty;
            numeroApremioGenerado = 0;
            log = string.Empty;
            respuesta = cParametroBL.GetString("EXPLOTACION_CODIGO", out codigoExplotacion);
            if (respuesta.Resultado == ResultadoProceso.OK && codigoExplotacion == "004")
            {
                string DOCUMENTOS = cParametroBL.ObtenerValor("RUTADOCUMENTOS");
                string rutaDoc = HttpContext.Current.Server.MapPath(DOCUMENTOS);

                salida = ProcesarGuadalajara(usuarioCodigo, out numeroApremioGenerado, fechaContabilizacion, out log, out respuesta, out apremiosProcesados, rutaDoc, null, null, null);
            }
            else
            {
                salida = ProcesarCiudadReal(usuarioCodigo, out numeroApremioGenerado, fechaContabilizacion, out log, out respuesta, out apremiosProcesados, null, null, null);
            }
            return salida;
        }

        private static cLineaFacturaBO Clone_FacLin(cLineaFacturaBO input)
        {
            cLineaFacturaBO result = new cLineaFacturaBO();

            var propInfo = input.GetType().GetProperties();
            foreach (var item in propInfo)
            {
                try
                {
                    result.GetType().GetProperty(item.Name).SetValue(result, item.GetValue(input, null), null);
                }
                catch { }
            }
            return result;
        }

        private static cLineaFacturaBO lineaAjustada(cBindableList<cLineaFacturaBO> lineasFactura, decimal totalFactura, out decimal impAjuste)
        {
            cLineaFacturaBO facLin = null;
            cLineaFacturaBO result = null;

            decimal totalLineas;
            //Hacemos la sumatoria de las lineas Base + Impuesto a 2 decimales.
            totalLineas = lineasFactura.Sum(x => Math.Round(x.CBase, 2, MidpointRounding.AwayFromZero) + Math.Round(x.ImpImpuesto, 2, MidpointRounding.AwayFromZero));

            impAjuste = Math.Round(totalFactura, 2) - totalLineas;

            //Si hay que aplicar ajuste, retornamos la linea con mayor importe con la base ajustada
            if (impAjuste != 0)
            {
                facLin = lineasFactura.OrderByDescending(x => x.CBase).FirstOrDefault();
                if (facLin != null)
                {
                    result = Clone_FacLin(facLin);
                    result.CBase = Math.Round(facLin.CBase, 2) + impAjuste;
                    result.Total = result.CBase + result.ImpImpuesto;
                }
            }

            return result;
        }

        private static string LogApremiosCSV(StringBuilder logAjustes, int numApremio, string rutaDoc)
        {
            string result = string.Empty;
            string APREMIOS = "_APREMIOS_LOG";

            try
            {
                APREMIOS = string.Format(@"{0}\{1}", rutaDoc, APREMIOS);
                var ficheroCSV = string.Format(@"{0}\[{1}]ajuste{2}.csv", APREMIOS, AcuamaDateTime.Now.ToString("yyMMddHHmmss"), numApremio);

                if (!Directory.Exists(APREMIOS))
                    Directory.CreateDirectory(APREMIOS);

                if (Directory.Exists(ficheroCSV))
                    Directory.Delete(ficheroCSV, true);

                StreamWriter sw = new StreamWriter(ficheroCSV, false, Encoding.ASCII);
                sw.Write(logAjustes.ToString());
                sw.Flush();
                sw.Close();

            }
            catch (Exception ex)
            {
                result = ex.Message;
            }
            return result;
        }

        private static string a�oValor(cFacturaBO factura)
        {
            //A�o del Valor => INICIO:9, LONGITUD:4; TIPO:N
            int longitud = 4;
            string result = string.Empty;
            result = result.PadLeft(longitud, '0');

            if (!string.IsNullOrEmpty(factura.Periodo.Tipo))
                result = factura.PeriodoCodigo.Substring(0, 4);
            else if (factura.Fecha.HasValue)
                result = factura.Fecha.Value.ToString("yyyy");
            else if (factura.FechaRegistro.HasValue)
                result = factura.FechaRegistro.Value.ToString("yyyy");

            return result.PadLeft(longitud, '0');
        }

        private static string numeroValor(cFacturaBO factura)
        {
            //N�mero de valor => INICIO:13, LONGITUD:7; TIPO:N
            int longitud = 7;
            string result = string.Empty;

            if (!string.IsNullOrEmpty(factura.Numero))
            {
                result = factura.Numero;
                result = result.Length >= longitud ? result.Substring(result.Length - longitud, longitud) : result;
            }
            return result.PadLeft(longitud, '0');
        }

        private static string periodoValor(cFacturaBO factura)
        {
            //Periodo, por defecto 00 => INICIO:20, LONGITUD:2; TIPO:N
            int longitud = 2;
            string result = string.Empty;

            if (!string.IsNullOrEmpty(factura.PeriodoCodigo) && !string.IsNullOrEmpty(factura.Periodo.Tipo))
            {
                result = factura.PeriodoCodigo;
                result = result.Substring(result.Length - 2);
            }
            return result.PadLeft(longitud, '0');
        }


        /// <summary>
        /// M�todo pensado para funcionar en forma de TAREA GUADALAJARA.
        /// Genera los cobros a partir de los registros de la tabla de trabajo de apremios y 
        /// un String con un formato espec�fico con todos los cobros realizados correctamente.
        /// Los cobros realizados se borran de la tabla de trabajo
        /// </summary>
        /// <param name="usuarioCodigo">C�digo del usuario</param>
        /// <param name="numeroApremioGenerado">N�mero de apremio generado</param>
        /// <param name="log">Log</param>
        /// <param name="respuesta">Respuesta</param>
        /// <param name="apremiosProcesados"></param>
        /// <param name="taskUser">Usuario que ejecuta la tarea</param>
        /// <param name="taskType">Tipo de tarea</param>
        /// <param name="taskNumber">N�mero de tarea</param>
        /// <returns>Contenido del fichero</returns>
        public static String ProcesarGuadalajara(String usuarioCodigo, out int? numeroApremioGenerado, DateTime fechaContabilizacion, out String log, out cRespuesta respuesta, out int apremiosProcesados, string rutaDoc, string taskUser, ETaskType? taskType, int? taskNumber)
        {
            StringBuilder salida = new StringBuilder(String.Empty);
            log = String.Empty;
            apremiosProcesados = 0;
            cCobroBO cobro = new cCobroBO();
            cCobroLinBO cobroLinea = new cCobroLinBO();
            String saltoDeLinea = Environment.NewLine;
            string strPoblacion = String.Empty
                 , strProvincia = String.Empty
                 , strCodigoPostal = String.Empty
                 , strDireccionSuministro = String.Empty
                 , strCCC = String.Empty
                 , strTitularNif = String.Empty
                 , strTitularNombre = String.Empty;
            numeroApremioGenerado = null;
            DateTime? fechaGeneracion = null;
            int diasPagoVoluntario = 0;
            cBindableList<cApremioTrabBO> apremiosTrab = null;
            cContratoBO contrato = null;
            cInmuebleBO inmueble = null;
            cApremioLinBO apremio = null;
            cFacturaBO factura = null;
            cCalleBO calle = null;
            cPeriodoBO periodoFactura = null;
            bool existeEfectoPdte = false;
            cValidator validador = new cValidator();

            //Informaci�n de las lineas ajustadas
            decimal impAjuste;
            bool hayCobros;
            decimal MAXAJUSTE = 0.03m;
            StringBuilder logAjustesCSV = new StringBuilder("facCod;facPerCod;facCtrCod;facVersion;facTotal;indiceCabecera;lineasxFactura;lineasConDeuda;hayCobros;TotalCobrado;importeAjuste(*);conAjuste;fclFacNumLinea;fclBaseAjustada;fclBase;indiceLinea;");
            int apremioSalida = 0;
            respuesta = new cRespuesta();
            try
            {
                using (TransactionScope scope = cAplicacion.NewTransactionScope())
                {
                    string strContabilizar = null;
                    bool contabilizar = false;

                    /*Obtener sociedad por defecto*/
                    string strSociedadCodigo = cParametroBL.ObtenerValor("SOCIEDAD_POR_DEFECTO", out respuesta);
                    if (String.IsNullOrEmpty(strSociedadCodigo))
                        cExcepciones.ControlarER(new Exception(Resource.errorParametroNoTieneValor.Replace("@item", "SOCIEDAD_POR_DEFECTO")), TipoExcepcion.Error, out respuesta);
                    short sociedadCodigo = Convert.ToInt16(strSociedadCodigo);

                    if (respuesta.Resultado == ResultadoProceso.OK)
                    {
                        /*Obtener par�metro que determina si se contabiliza o no*/
                        strContabilizar = cParametroBL.ObtenerValor("CONTABILIZAR", out respuesta);
                        if (String.IsNullOrEmpty(strContabilizar))
                            cExcepciones.ControlarER(new Exception(Resource.errorParametroNoTieneValor.Replace("@item", "CONTABILIZAR")), TipoExcepcion.Error, out respuesta);
                        contabilizar = Convert.ToBoolean(strContabilizar);
                    }

                    if (respuesta.Resultado == ResultadoProceso.OK && contabilizar)
                    {
                        //Comprobar que la fecha sea mayor que la fecha de cierre contable
                        cSociedadBO sociedad = new cSociedadBO();
                        sociedad.Codigo = sociedadCodigo;
                        cSociedadBL.Obtener(ref sociedad, out respuesta);
                        if (sociedad.FechaCierreContable.HasValue && respuesta.Resultado == ResultadoProceso.OK)
                        {
                            if (sociedad.FechaCierreContable.Value >= fechaContabilizacion)
                            {
                                validador.AddCustomMessage(Resource.val_fechaAnteriorEstricta.Replace("@field2", Resource.fechaContable).Replace("@field1", Resource.fechaCierreContable));
                                cExcepciones.ControlarER(new Exception(validador.Validate(true)), TipoExcepcion.Error, out respuesta);
                                return null;
                            }
                        }
                    }

                    if (respuesta.Resultado == ResultadoProceso.OK)
                        apremiosTrab = Obtener(usuarioCodigo, (short)cApremioTrabBO.ETipo.Enviar, out respuesta);//Obtener los apremiosTrab para generar el fichero

                    //Si el resultado es ERROR o SIN REGISTROS NO HACEMOS NADA
                    if (respuesta.Resultado == ResultadoProceso.OK)
                    {
                        //Establecer n�mero de pasos de la tarea
                        if (taskNumber.HasValue && taskType.HasValue && !String.IsNullOrEmpty(taskUser))
                            cTaskManagerBL.SetTotalSteps(taskUser, taskType.Value, taskNumber.Value, apremiosTrab.Count);

                        if (contabilizar)
                        {
                            int? asientoAInserta = null, asientoInsertado = null;
                            Int64 asientosInsertados = 0;

                            // Contabilizaci�n del apremio, el tipo Debe
                            if (respuesta.Resultado == ResultadoProceso.OK)
                                respuesta = cContabVentasBL.ContabilidadApremios(sociedadCodigo, fechaContabilizacion, usuarioCodigo, cApremioTrabBO.ETipo.Enviar, 'D', out asientosInsertados, asientoAInserta, out asientoInsertado);
                            // Contabilizaci�n del apremio, el tipo Haber
                            if (respuesta.Resultado == ResultadoProceso.OK)
                            {
                                asientoAInserta = asientoInsertado;
                                respuesta = cContabVentasBL.ContabilidadApremios(sociedadCodigo, fechaContabilizacion, usuarioCodigo, cApremioTrabBO.ETipo.Enviar, 'H', out asientosInsertados, asientoAInserta, out asientoInsertado);
                            }
                        }
                        int indiceLinea = 0;
                        int indiceCabecera = 0;

                        //Recorro los apremiosTrab de la tabla de trabajo
                        for (int i = 0; respuesta.Resultado == ResultadoProceso.OK && i < apremiosTrab.Count; i++)
                        {
                            //Obtener la factura a la cual hace referencia el apremio
                            factura = new cFacturaBO();
                            factura.FacturaCodigo = apremiosTrab[i].FacturaCodigo;
                            factura.PeriodoCodigo = apremiosTrab[i].PeriodoCodigo;
                            factura.ContratoCodigo = apremiosTrab[i].ContratoCodigo;
                            factura.Version = apremiosTrab[i].FacturaVersion;

                            cFacturasBL.Obtener(ref factura, out respuesta);
                            if (respuesta.Resultado != ResultadoProceso.OK)
                                continue; // Si la factura falla no se procesa

                            cFacturasBL.ObtenerPeriodo(ref factura, out respuesta);
                            if (respuesta.Resultado != ResultadoProceso.OK)
                                continue; // Si la factura falla no se procesa

                            cFacturasBL.ObtenerLineasConDeuda(ref factura, out respuesta);


                            if (respuesta.Resultado == ResultadoProceso.OK && !factura.FechaContabilizacion.HasValue && contabilizar)
                                continue; // Si la factura no est� contabilizada no se procesa
                            if (respuesta.Resultado == ResultadoProceso.OK && factura.FechaFactRectificativa.HasValue)//Comprobamos si existe factura rectificativa
                                continue; //Si tiene fecha rectificativa quiere decir que se ha generado la rectificativa despu�s de realizar la selecci�n de los apremios a procesar. No se procesa el apremio                        
                            if (respuesta.Resultado == ResultadoProceso.OK) //Comprobamos si existen efectos pendientes a remesar y que no esten rechazados
                                existeEfectoPdte = cEfectosPendientesBL.Existe(factura.ContratoCodigo.Value, factura.PeriodoCodigo, factura.FacturaCodigo.Value, factura.SociedadCodigo.Value, false, false, out respuesta);
                            if (respuesta.Resultado == ResultadoProceso.OK && existeEfectoPdte) //Si existe efecto pendiente no se procesa el apremio
                                continue;
                            if (respuesta.Resultado == ResultadoProceso.OK)
                            {
                                apremio = new cApremioLinBO();
                                apremio.Numero = numeroApremioGenerado;
                                apremio.FechaGeneracion = fechaGeneracion;
                                apremio.UsuarioCodigo = apremiosTrab[i].UsuarioCodigo;
                                apremio.PeriodoCodigo = apremiosTrab[i].PeriodoCodigo;
                                apremio.ContratoCodigo = apremiosTrab[i].ContratoCodigo;
                                apremio.FacturaCodigo = apremiosTrab[i].FacturaCodigo;
                                apremio.FacturaVersion = apremiosTrab[i].FacturaVersion;

                                respuesta = cApremiosLinBL.Insertar(apremio);
                            }
                            if (respuesta.Resultado == ResultadoProceso.OK)
                            {
                                apremioSalida = apremio.Numero ?? 0;
                                numeroApremioGenerado = apremio.Numero;
                                fechaGeneracion = apremio.FechaGeneracion;
                                cFacturasBL.ObtenerTotalFacturado(ref factura, fechaGeneracion.Value, out respuesta);
                            }
                            if (respuesta.Resultado == ResultadoProceso.OK)
                                cFacturasBL.ObtenerContrato(ref factura, out respuesta);


                            //Si estamos ejecutando en modo tarea...
                            //Puede que no inserte el cobro y debe realizarse una vez por cada iteraci�n
                            if (taskNumber.HasValue && taskType.HasValue && !String.IsNullOrEmpty(taskUser))
                            {
                                cRespuesta tskRespuesta = new cRespuesta();
                                //Comprobar si se desea cancelar
                                if (cTaskManagerBL.CancelRequested(taskUser, taskType.Value, taskNumber.Value, out tskRespuesta) && respuesta.Resultado == ResultadoProceso.OK)
                                {
                                    apremiosProcesados = 0;
                                    return String.Empty;
                                }
                                //Incrementar el n�mero de pasos
                                cTaskManagerBL.PerformStep(taskUser, taskType.Value, taskNumber.Value);
                            }


                            //----------------------
                            //Generaci�n del fichero Guadalajara
                            //----------------------
                            if (respuesta.Resultado == ResultadoProceso.OK)
                            {
                                strTitularNif = factura.Contrato.TitularDocIden;
                                strCCC = factura.Contrato.CodCueCli;
                                strTitularNombre = factura.Contrato.TitularNombre;

                                //----------------------
                                // Cabecera del fichero
                                //----------------------
                                indiceCabecera = indiceLinea + 1;
                                //INICIO:01, LONGITUD:02; TIPO:T | Tipo de Registro "00" Registro de Cargo                          
                                salida.Append("00");
                                //INICIO:03, LONGITUD:06; TIPO:5 | Concepto Tributario
                                salida.Append(cAplicacion.FixedLengthString("04", 6, '0', true, true));
                                //INICIO:09, LONGITUD:04; TIPO:N | A�o del Valor
                                salida.Append(a�oValor(factura));
                                //INICIO:13, LONGITUD:07; TIPO:N | N�mero de valor
                                salida.Append(numeroValor(factura));
                                //INICIO:20, LONGITUD:02; TIPO:N | Periodo, por defecto 00
                                salida.Append(periodoValor(factura));
                                //INICIO:22, LONGITUD:02; TIPO:T | Dos espacios en blanco
                                salida.Append("00");
                                //INICIO:24, LONGITUD:01; TIPO:T | Tipo de Valor: R-Recibo; L-Liquidaci�n; A-Autoliquidaci�n 
                                salida.Append("R");
                                //INICIO:25, LONGITUD:11; TIPO:N | Principal (C�ntimos de Euro)
                                salida.Append(cAplicacion.FixedLengthString(factura.TotalFacturado.Value.ToString("N2").Replace(",", "").Replace(".", ""), 12, '0', true, true)); //Principal. 12 d�gitos

                                logAjustesCSV = logAjustesCSV.Append(string.Format("\n{0};{1};{2};{3};{4};{5};"
                                                                         , factura.FacturaCodigo
                                                                         , factura.PeriodoCodigo
                                                                         , factura.ContratoCodigo
                                                                         , factura.Version
                                                                         , factura.TotalFacturado
                                                                         , indiceCabecera));

                                //Obtener inmueble para coger los datos Fiscales
                                contrato = factura.Contrato;
                                cContratoBL.ObtenerInmueble(ref contrato, out respuesta);
                            }
                            if (respuesta.Resultado == ResultadoProceso.OK)
                            {
                                strDireccionSuministro = contrato.InmuebleBO.Direccion;
                                salida.Append(cAplicacion.FixedLengthString(strTitularNif, 10, ' ', false, false)); //NIF. 10 d�gitos
                                salida.Append(cAplicacion.FixedLengthString(strTitularNombre, 30, ' ', false, false)); //Nombre. 30 d�gitos
                                salida.Append(cAplicacion.Replicate(" ", 25));
                                inmueble = contrato.InmuebleBO;
                                //Obtener la calle
                                respuesta = cInmuebleBL.ObtenerCalle(ref inmueble);
                            }
                            if (respuesta.Resultado == ResultadoProceso.OK)
                            {
                                calle = inmueble.Calle;
                                //Obtener Tipo de v�a para la sigla fiscal
                                respuesta = cCalleBL.ObtenerTipoVia(ref calle);
                            }
                            if (respuesta.Resultado == ResultadoProceso.OK)
                            {
                                //Obtener el tipo de v�a para la sigla fiscal
                                salida.Append(cAplicacion.FixedLengthString(calle.TipoVia.Abreviado, 2, ' ', false, false)); // --> Sigla fiscal. 2 D�gitos
                                salida.Append(cAplicacion.FixedLengthString(inmueble.Calle.Descripcion, 30, ' ', false, false)); // --> Calle fiscal. 30 D�gitos
                                salida.Append(cAplicacion.FixedLengthString(contrato.InmuebleBO.Finca, 4, ' ', false, false)); // --> N�mero/Finca de la calle fiscal. 4 D�gitos
                                salida.Append(cAplicacion.FixedLengthString(contrato.InmuebleBO.Entrada, 2, ' ', false, false)); // --> Portal/Entrada de la calle fiscal. 2 D�gitos
                                salida.Append(cAplicacion.FixedLengthString(contrato.InmuebleBO.Bloque, 4, ' ', false, false)); // --> Bloque fiscal. 4 D�gitos
                                salida.Append(cAplicacion.FixedLengthString(contrato.InmuebleBO.Escalera, 2, ' ', false, false)); // --> Escalera fiscal. 2 D�gitos
                                salida.Append(cAplicacion.FixedLengthString(contrato.InmuebleBO.Planta, 3, ' ', false, false)); // --> Planta fiscal. 3 D�gitos
                                salida.Append(cAplicacion.FixedLengthString(contrato.InmuebleBO.Puerta, 4, ' ', false, false)); // --> Puerta fiscal. 4 D�gitos
                                                                                                                                //Obtener poblaci�n
                                respuesta = cInmuebleBL.ObtenerPoblacion(ref inmueble);
                            }
                            if (respuesta.Resultado == ResultadoProceso.OK)
                            {
                                strPoblacion = inmueble.Poblacion.Descripcion;
                                strCodigoPostal = inmueble.Poblacion.CodigoPostal;
                                //Obtener provincia
                                respuesta = cInmuebleBL.ObtenerProvincia(ref inmueble);
                            }
                            if (respuesta.Resultado == ResultadoProceso.OK)
                            {
                                strProvincia = inmueble.Provincia.Descripcion;

                                salida.Append(cAplicacion.FixedLengthString(strPoblacion, 35, ' ', false, false)); // Poblaci�n fiscal. 35 D�gitos
                                salida.Append(cAplicacion.FixedLengthString(strProvincia, 35, ' ', false, false)); // Provincia fiscal. 35 D�gitos
                                salida.Append(cAplicacion.FixedLengthString(strCodigoPostal, 5, ' ', false, false)); // C�digo Postal fiscal. 5 D�gitos
                                salida.Append(cAplicacion.FixedLengthString(strPoblacion, 25, ' ', false, false)); // N�cleo de poblaci�n. 25 D�gitos
                                salida.Append(cAplicacion.FixedLengthString(contrato.TitularNacion, 35, ' ', false, false)); // Pa�s del contribuyente. 35 D�gitos
                                salida.Append(cAplicacion.Replicate("0", 8)); //Recargo de extemporaneidad. 8 d�gitos
                                                                              //Cuaderno 60
                                salida.Append(cAplicacion.Replicate("0", 6)); //Fecha creacion carta pago. 6 d�gitos
                                salida.Append(cAplicacion.Replicate("0", 6)); //Fecha vencimiento carta pago. 6 d�gitos
                                salida.Append(cAplicacion.Replicate("0", 3)); //C�digo de tributo. 3 d�gitos
                                salida.Append(cAplicacion.Replicate("0", 10)); //Referencia 10 d�gitos
                                salida.Append(cAplicacion.Replicate(" ", 5)); //5 blancos

                                periodoFactura = factura.Periodo;
                                if (respuesta.Resultado == ResultadoProceso.OK && periodoFactura != null)
                                {
                                    //Si en el periodo est� establecida una fecha de inicio de periodo voluntario se usa esa, en caso contrario se usa la fecha de factura
                                    if (periodoFactura.FechaInicioPagoVoluntario.HasValue)
                                    {
                                        //Fecha emisi�n factura es la fecha de inicio de pago Voluntaria. 8 D�gitos
                                        salida.Append(cAplicacion.FixedLengthString(periodoFactura.FechaInicioPagoVoluntario.Value.Year.ToString(), 4, '0', true, true)); // --> Fecha inicio pago voluntario, AAAA (a�o). 4 D�gitos
                                        salida.Append(cAplicacion.FixedLengthString(periodoFactura.FechaInicioPagoVoluntario.Value.Month.ToString(), 2, '0', true, true)); // --> Fecha inicio pago voluntario, MM (mes). 2 D�gitos
                                        salida.Append(cAplicacion.FixedLengthString(periodoFactura.FechaInicioPagoVoluntario.Value.Day.ToString(), 2, '0', true, true)); // --> Fecha inicio pago voluntario, DD (d�a). 2 D�gitos
                                    }
                                    else
                                    {
                                        //Fecha emisi�n factura es la fecha de inicio de pago Voluntaria. 8 D�gitos
                                        salida.Append(cAplicacion.FixedLengthString(factura.Fecha.Value.Year.ToString(), 4, '0', true, true)); // --> Fecha factura, AAAA (a�o). 4 D�gitos
                                        salida.Append(cAplicacion.FixedLengthString(factura.Fecha.Value.Month.ToString(), 2, '0', true, true)); // --> Fecha factura, MM (mes). 2 D�gitos
                                        salida.Append(cAplicacion.FixedLengthString(factura.Fecha.Value.Day.ToString(), 2, '0', true, true)); // --> Fecha factura, DD (d�a). 2 D�gitos
                                    }
                                }

                                // Fecha notificaci�n factura. 8 D�gitos en blanco
                                salida.Append(cAplicacion.Replicate(" ", 8));
                            }

                            //Obtener l�neas de la factura
                            cBindableList<cLineaFacturaBO> lineasConDeuda = new cBindableList<cLineaFacturaBO>(); //Lista vac�a, para evitar posibles referencias a nulo
                            if (respuesta.Resultado == ResultadoProceso.OK)
                            {
                                //lineasFactura = cFacturasBL.ObtenerLineas(ref factura, out respuesta); 
                                //Ahora 10/10/2019 lineas con deuda
                                lineasConDeuda = cFacturasBL.ObtenerLineasConDeuda(ref factura, out respuesta);
                                respuesta.Resultado = respuesta.Resultado == ResultadoProceso.SinRegistros ? ResultadoProceso.OK : respuesta.Resultado;

                                //Seteamos en la factura las lineas de la factura
                                cFacturasBL.ObtenerLineas(ref factura, out respuesta);
                                respuesta.Resultado = respuesta.Resultado == ResultadoProceso.SinRegistros ? ResultadoProceso.OK : respuesta.Resultado;

                                //Seteamos el Importe Cobrado
                                cFacturasBL.ObtenerImporteCobrado(ref factura, null);
                            }

                            if (respuesta.Resultado == ResultadoProceso.OK)
                            {
                                // Fecha fin pago voluntario factura. 8 D�gitos
                                respuesta = cParametroBL.GetInteger("DIAS_PAGO_VOLUNTARIO", out diasPagoVoluntario);
                                if (respuesta.Resultado == ResultadoProceso.OK)
                                {
                                    //Si en el periodo est� establecida una fecha de fin de periodo voluntario se usa esa
                                    if (periodoFactura.FechaFinPagoVoluntario.HasValue)
                                    {
                                        salida.Append(cAplicacion.FixedLengthString(periodoFactura.FechaFinPagoVoluntario.Value.Year.ToString(), 4, '0', true, true)); // --> Fecha inicio pago voluntario, AAAA (a�o). 4 D�gitos
                                        salida.Append(cAplicacion.FixedLengthString(periodoFactura.FechaFinPagoVoluntario.Value.Month.ToString(), 2, '0', true, true)); // --> Fecha inicio pago voluntario, MM (mes). 2 D�gitos
                                        salida.Append(cAplicacion.FixedLengthString(periodoFactura.FechaFinPagoVoluntario.Value.Day.ToString(), 2, '0', true, true)); // --> Fecha inicio pago voluntario, DD (d�a). 2 D�gitos
                                    }
                                    else //Sino se suman los d�as de pago voluntario a la fecha de factura
                                    {
                                        salida.Append(cAplicacion.FixedLengthString(factura.Fecha.Value.AddDays(Convert.ToDouble(diasPagoVoluntario)).Year.ToString(), 4, '0', true, true)); // --> Fecha fin pago voluntario, AAAA (a�o). 4 D�gitos
                                        salida.Append(cAplicacion.FixedLengthString(factura.Fecha.Value.AddDays(Convert.ToDouble(diasPagoVoluntario)).Month.ToString(), 2, '0', true, true)); // --> Fecha fin pago voluntario, MM (mes). 2 D�gitos
                                        salida.Append(cAplicacion.FixedLengthString(factura.Fecha.Value.AddDays(Convert.ToDouble(diasPagoVoluntario)).Day.ToString(), 2, '0', true, true)); // --> Fecha fin pago voluntario, DD (d�a). 2 D�gitos
                                    }
                                }

                                salida.Append(cAplicacion.FixedLengthString(factura.Fecha.Value.Year.ToString(), 4, ' ', false, false)); // --> A�o al que se refiere la liquidaci�n /a�o de factura. 4 D�gitos
                                salida.Append(cAplicacion.Replicate("0", 12)); //Importe del recargo provincial. 12 ceros
                                salida.Append(cAplicacion.Replicate(" ", 20)); // Matricula para impuestos de vehiculos... 20 D�gitos
                                salida.Append(cAplicacion.FixedLengthString(strDireccionSuministro, 50, ' ', false, false)); // --> Direcci�n Fiscal. 50 D�gitos

                                //El periodo y el consumo se asignan a las observaciones
                                string periodoCodigo = Resource.periodo + ":" + cAplicacion.FixedLengthString(factura.PeriodoCodigo, 6, ' ', false, false);
                                string consumo = Resource.consumo + ":" + cAplicacion.FixedLengthString(factura.ConsumoFactura.ToString(), 7, ' ', false, false);
                                salida.Append(cAplicacion.FixedLengthString(periodoCodigo + " " + consumo, 70, ' ', false, false)); //Observaciones-->Periodo y Consumo

                                salida.Append(cAplicacion.Replicate("0", 8)); //Intereses de expontaneidad. 8 ceros

                                //Las 21 posiciones que se reservaban para los datos del IVA se dejan en blanco
                                salida.Append(cAplicacion.Replicate(" ", 21));


                                salida.Append(cAplicacion.Replicate("0", 20)); // CCC. 20 d�gitos

                                salida.Append(cAplicacion.Replicate("0", 8)); // Fecha Domiciliaci�n. 8 D�gitos
                                salida.Append(cAplicacion.Replicate(" ", 10)); //NIF. 10 d�gitos
                                salida.Append(cAplicacion.Replicate(" ", 40)); //Nombre. 40 d�gitos

                                //---------------------------------------
                                // Detalle del fichero. L�neas de factura
                                //---------------------------------------
                                salida.Append(saltoDeLinea);
                                indiceLinea++;
                                salida.Append("01"); //Registro de cargo. Fijo --> 01. 2 D�gitos
                                salida.Append(cAplicacion.FixedLengthString("04", 6, '0', true, true)); //Concepto Tributario. 6 D�gitos
                                salida.Append(cAplicacion.FixedLengthString(factura.PeriodoCodigo.Substring(0, 4), 4, '0', true, true)); //A�o del valor. 4 D�gitos
                                salida.Append(cAplicacion.FixedLengthString(factura.Numero.ToString(), 7, '0', true, true)); //N�mero de factura. 7 D�gitos
                                salida.Append("0000"); //N�mero de orden del valor. Fijo--> 0000. 4 D�gitos
                                salida.Append("R"); //Tipo de valor. Fijo--> R (Recibo). 1 D�gitos
                            }


                            //new test
                            //comprobamos si hay que ajustar, antes de pintar en fichero
                            cLineaFacturaBO fclLineaAjustada = lineaAjustada(lineasConDeuda, factura.TotalFacturado ?? 0, out impAjuste);

                            hayCobros = (factura.TotalCobrado != 0);
                            logAjustesCSV = logAjustesCSV.Append(string.Format("{0};{1};{2};{3};{4};"
                                , factura.LineasFactura.Count
                                , lineasConDeuda.Count
                                , hayCobros ? "si" : "no"//Hay Cobros
                                , factura.TotalCobrado  //Total Cobrado
                                , impAjuste             //impAjuste    
                                ));

                            if (hayCobros || fclLineaAjustada == null || Math.Abs(impAjuste) > MAXAJUSTE)
                            {
                                //No hay linea con ajuste ni importe del ajuste
                                logAjustesCSV = logAjustesCSV.Append(string.Format("{0};{1};{2};{3};{4};"
                                                                        , "no"              //conAjuste
                                                                        , string.Empty      //fclFacNumLinea
                                                                        , string.Empty      //fclBaseAjustada
                                                                        , string.Empty      //fclBase
                                                                        , string.Empty));   //indiceLinea
                            }


                            //Recorrer l�neas de la factura
                            for (int j = 0; j < 7 && respuesta.Resultado == ResultadoProceso.OK; j++)
                            {
                                if (lineasConDeuda.Count >= j + 1)
                                {
                                    string strServicio = String.Empty, strTarifa = String.Empty;
                                    cLineaFacturaBO linea = lineasConDeuda[j];
                                    new cLineasFacturaBL().ObtenerServicio(ref linea, out respuesta);
                                    if (respuesta.Resultado == ResultadoProceso.OK)
                                        strServicio = linea.Servicio.Descripcion;
                                    new cLineasFacturaBL().ObtenerTarifa(ref linea, out respuesta);
                                    if (respuesta.Resultado == ResultadoProceso.OK)
                                        strTarifa = linea.Tarifa.Descripcion;

                                    //SYR-207165: Usamos la linea ajustada, cuando existe y su importe no excede al maximo considerado redondeo y no hay cobros parciales para esa factura 
                                    if (!hayCobros && fclLineaAjustada != null && fclLineaAjustada.NumeroLinea == linea.NumeroLinea && Math.Abs(impAjuste) <= MAXAJUSTE)
                                    {
                                        logAjustesCSV = logAjustesCSV.Append(string.Format("{0};{1};{2};{3};{4};"
                                                                             , "si"                     //conAjuste
                                                                             , linea.NumeroLinea        //fclFacNumLinea
                                                                             , fclLineaAjustada.CBase   //fclBaseAjustada
                                                                             , linea.CBase              //fclBase
                                                                             , indiceLinea));           //indiceLinea
                                        linea = fclLineaAjustada;
                                    }
                                    //SYR-207165: fin

                                    //Lineas de detalle por servicio
                                    string servicioTarifa = cAplicacion.FixedLengthString(strServicio + "/" + strTarifa, 48, ' ', false, false);
                                    string lBase = cAplicacion.FixedLengthString(linea.CBase.ToString("N4").Replace(",", String.Empty).Replace(".", String.Empty), 8, ' ', true, true);
                                    string impImp = cAplicacion.FixedLengthString(linea.ImpImpuesto.ToString("N4").Replace(",", String.Empty).Replace(".", String.Empty), 6, ' ', true, true);
                                    string total = cAplicacion.FixedLengthString(linea.Total.ToString("N4").Replace(",", String.Empty).Replace(".", String.Empty), 8, ' ', true, true);

                                    salida.Append(cAplicacion.FixedLengthString(servicioTarifa + lBase + impImp + total, 70, ' ', false, false));
                                }
                                else
                                    salida.Append(cAplicacion.Replicate(" ", 70)); //L�nea de detalle en blanco. 70 d�gitos
                            }

                            salida.Append(cAplicacion.Replicate(" ", 98)); //Espacios en blanco
                            salida.Append(saltoDeLinea);
                            indiceLinea++;

                            //----------------------------------------
                            // Registro o l�nea del desglose del valor
                            //----------------------------------------
                            //SYR-207165: Si el total de la factura es diferente al total de las lineas 
                            //tendremos que ajustar la base de la linea con mayor importe
                            
                            //cLineaFacturaBO fclLineaAjustada = lineaAjustada(lineasConDeuda, factura.TotalFacturado ?? 0, out impAjuste);

                            //hayCobros = (factura.TotalCobrado != 0);
                            //logAjustesCSV = logAjustesCSV.Append(string.Format("{0};{1};{2};{3};{4};"
                            //    , factura.LineasFactura.Count
                            //    , lineasConDeuda.Count
                            //    , hayCobros ? "si" : "no"//Hay Cobros
                            //    , factura.TotalCobrado  //Total Cobrado
                            //    , impAjuste             //impAjuste    
                            //    ));

                            //if (hayCobros || fclLineaAjustada == null || Math.Abs(impAjuste) > MAXAJUSTE)
                            //{
                            //    //No hay linea con ajuste ni importe del ajuste
                            //    logAjustesCSV = logAjustesCSV.Append(string.Format("{0};{1};{2};{3};{4};"
                            //                                            , "no"              //conAjuste
                            //                                            , string.Empty      //fclFacNumLinea
                            //                                            , string.Empty      //fclBaseAjustada
                            //                                            , string.Empty      //fclBase
                            //                                            , string.Empty));   //indiceLinea
                            //}

                            //Recorrer l�neas de la factura
                            for (int k = 0; k < lineasConDeuda.Count && respuesta.Resultado == ResultadoProceso.OK; k++)
                            {
                                cLineaFacturaBO linea = lineasConDeuda[k];
                                //SYR-207165: Usamos la linea ajustada, cuando existe y su importe no excede al maximo considerado redondeo y no hay cobros parciales para esa factura 
                                if (!hayCobros && fclLineaAjustada != null && fclLineaAjustada.NumeroLinea == linea.NumeroLinea && Math.Abs(impAjuste) <= MAXAJUSTE)
                                {
                                    logAjustesCSV = logAjustesCSV.Append(string.Format("{0};{1};{2};{3};{4};"
                                                                         , "si"                     //conAjuste
                                                                         , linea.NumeroLinea        //fclFacNumLinea
                                                                         , fclLineaAjustada.CBase   //fclBaseAjustada
                                                                         , linea.CBase              //fclBase
                                                                         , indiceLinea));           //indiceLinea
                                    linea = fclLineaAjustada;
                                }
                            //SYR-207165: fin


                                string subconceptoCodigo = "0";
                                new cLineasFacturaBL().ObtenerServicio(ref linea, out respuesta);
                                if (respuesta.Resultado == ResultadoProceso.OK)
                                {
                                    //Establecer el subconcepto asociado al servicio, dato facilitado por el Ayuntamiento.
                                    if (linea.Servicio.Codigo == 1) //Agua
                                        subconceptoCodigo = SubContepto(SubconceptoCodigo.Agua);
                                    else if (linea.Servicio.Codigo == 2) //Mtto contador
                                        subconceptoCodigo = SubContepto(SubconceptoCodigo.Contador);
                                    else //Alcantarillado
                                        subconceptoCodigo = SubContepto(SubconceptoCodigo.Alcantarillado);
                                }
                                //Lineas de registros de desglose del valor por servicio
                                salida.Append("03"); //Registro de desglose del valor. Fijo --> 03. 2 D�gitos

                                string subconcepto = cAplicacion.FixedLengthString(subconceptoCodigo.ToString(), 2, '0', true, true); //C�digo del subconcepto. 2 D�gitos.
                                string total = cAplicacion.FixedLengthString(linea.CBase.ToString("N2").Replace(",", String.Empty).Replace(".", String.Empty), 12, '0', true, true);
                                string ptjImp = cAplicacion.FixedLengthString(linea.PtjImpuesto.ToString("F0"), 2, '0', true, true);
                                string impImp = cAplicacion.FixedLengthString(linea.ImpImpuesto.ToString("N2").Replace(",", String.Empty).Replace(".", String.Empty), 12, '0', true, true);

                                salida.Append(cAplicacion.FixedLengthString(subconceptoCodigo + total + ptjImp + impImp, 28, ' ', false, false));

                                salida.Append(cAplicacion.Replicate(" ", 582)); //Espacios en blanco
                                salida.Append(saltoDeLinea);
                                indiceLinea++;
                            }

                            //Si el fichero se ha realizado correctamente, se borra el apremio de la tabla de trabajo
                            if (respuesta.Resultado == ResultadoProceso.OK)
                                respuesta = Borrar(apremiosTrab[i]);

                            if (respuesta.Resultado == ResultadoProceso.OK)
                                apremiosProcesados++;

                            //Si algo no va bien se a�ade al mensaje de la respuesta, el periodo y el c�digo de factura en el cual se ha producido el error
                            if (respuesta.Resultado != ResultadoProceso.OK)
                                cExcepciones.ControlarER(new Exception(respuesta.Ex.Message + ", " + Resource.periodo + ": " + factura.PeriodoCodigo + ", " + Resource.contrato + ": " + factura.ContratoCodigo), TipoExcepcion.Informacion, out respuesta);

                        }//fin del for

                        if (respuesta.Resultado == ResultadoProceso.OK)
                            scope.Complete();
                        else
                        {
                            apremiosProcesados = 0;
                            return String.Empty;
                        }
                    } //Fin if(Respuesta.Resultado == OK)
                } //Fin TransactionScope

                //Solo se inserta en el log 
                if (respuesta.Resultado == ResultadoProceso.OK && apremiosProcesados > 0 && apremiosProcesados != apremiosTrab.Count)
                    log = Resource.apremioXGeneradaConIncidencias.Replace("@apremio", numeroApremioGenerado.HasValue ? numeroApremioGenerado.Value.ToString() : String.Empty);
                if (respuesta.Resultado == ResultadoProceso.OK && apremiosProcesados == 0)
                    log = Resource.errorApremiosNoProcesados;
            }
            catch (Exception ex)
            {
                logAjustesCSV = logAjustesCSV.Append("\n" + ex.Message);
            }
            finally
            {
                //Informaci�n de las lineas ajustadas
                log += LogApremiosCSV(logAjustesCSV, apremioSalida, rutaDoc);
            }
            return salida.ToString();
        }

        

        /// <summary>
        /// M�todo pensado para funcionar en forma de TAREA Almaden y Alamillo.
        /// Genera los cobros a partir de los registros de la tabla de trabajo de apremios y 
        /// un String con un formato espec�fico con todos los cobros realizados correctamente.
        /// Los cobros realizados se borran de la tabla de trabajo
        /// </summary>
        /// <param name="usuarioCodigo">C�digo del usuario</param>
        /// <param name="numeroApremioGenerado">N�mero de apremio generado</param>
        /// <param name="log">Log</param>
        /// <param name="respuesta">Respuesta</param>
        /// <param name="apremiosProcesados"></param>
        /// <param name="taskUser">Usuario que ejecuta la tarea</param>
        /// <param name="taskType">Tipo de tarea</param>
        /// <param name="taskNumber">N�mero de tarea</param>
        /// <returns>Contenido del fichero</returns>
        public static String ProcesarCiudadReal(String usuarioCodigo, out int? numeroApremioGenerado, DateTime fechaContabilizacion, out String log, out cRespuesta respuesta, out int apremiosProcesados, string taskUser, ETaskType? taskType, int? taskNumber)
        {
            StringBuilder salida = new StringBuilder(String.Empty);
            log = String.Empty;
            apremiosProcesados = 0;
            cCobroBO cobro = new cCobroBO();
            cCobroLinBO cobroLinea = new cCobroLinBO();
            String saltoDeLinea = Environment.NewLine;
            string codigoExplotacion;


            log = string.Empty;
            string strPoblacion = String.Empty, strProvincia = String.Empty, PROVINCIA_INE = "13", FecIniPer = "", FecFinPer = "",
                  FecIniPerAux = "", FecFinPerAux = "", strCodigoPostal = String.Empty, strDireccionSuministro = String.Empty,
                   strCCC = String.Empty, strTitularNif = String.Empty, strTipodoc = String.Empty,
                   strTitularNombre = String.Empty;
            string MUNICIPIO_INE = String.Empty;
            respuesta = cParametroBL.GetString("EXPLOTACION_CODIGO", out codigoExplotacion);
            if (respuesta.Resultado == ResultadoProceso.OK && codigoExplotacion == "001")
            {
                MUNICIPIO_INE = "011"; //Almaden
            }
            else
            {

                MUNICIPIO_INE = "003"; //Alamillo
            }
            numeroApremioGenerado = null;
            DateTime? fechaGeneracion = null;
            int diasPagoVoluntario = 0;
            cBindableList<cApremioTrabBO> apremiosTrab = null;
            cContratoBO contrato = null;
            cInmuebleBO inmueble = null;
            cApremioLinBO apremio = null;
            cFacturaBO factura = null;
            cCalleBO calle = null;
            cPeriodoBO periodoFactura = null;
            bool existeEfectoPdte = false;
            cValidator validador = new cValidator();
            int importeTotalFactura = 0;
            int importeTotalFichero = 0;
            bool cabecera = true;

            using (TransactionScope scope = cAplicacion.NewTransactionScope())
            {
                string strContabilizar = null;
                bool contabilizar = false;

                /*Obtener sociedad por defecto*/
                string strSociedadCodigo = cParametroBL.ObtenerValor("SOCIEDAD_POR_DEFECTO", out respuesta);
                if (String.IsNullOrEmpty(strSociedadCodigo))
                    cExcepciones.ControlarER(new Exception(Resource.errorParametroNoTieneValor.Replace("@item", "SOCIEDAD_POR_DEFECTO")), TipoExcepcion.Error, out respuesta);
                short sociedadCodigo = Convert.ToInt16(strSociedadCodigo);

                if (respuesta.Resultado == ResultadoProceso.OK)
                {
                    /*Obtener par�metro que determina si se contabiliza o no*/
                    strContabilizar = cParametroBL.ObtenerValor("CONTABILIZAR", out respuesta);
                    if (String.IsNullOrEmpty(strContabilizar))
                        cExcepciones.ControlarER(new Exception(Resource.errorParametroNoTieneValor.Replace("@item", "CONTABILIZAR")), TipoExcepcion.Error, out respuesta);
                    contabilizar = Convert.ToBoolean(strContabilizar);
                }

                if (respuesta.Resultado == ResultadoProceso.OK && contabilizar)
                {
                    //Comprobar que la fecha sea mayor que la fecha de cierre contable
                    cSociedadBO sociedad = new cSociedadBO();
                    sociedad.Codigo = sociedadCodigo;
                    cSociedadBL.Obtener(ref sociedad, out respuesta);
                    if (sociedad.FechaCierreContable.HasValue && respuesta.Resultado == ResultadoProceso.OK)
                    {
                        if (sociedad.FechaCierreContable.Value >= fechaContabilizacion)
                        {
                            validador.AddCustomMessage(Resource.val_fechaAnteriorEstricta.Replace("@field2", Resource.fechaContable).Replace("@field1", Resource.fechaCierreContable));
                            cExcepciones.ControlarER(new Exception(validador.Validate(true)), TipoExcepcion.Error, out respuesta);
                            return null;
                        }
                    }
                }

                if (respuesta.Resultado == ResultadoProceso.OK)
                    apremiosTrab = Obtener(usuarioCodigo, (short)cApremioTrabBO.ETipo.Enviar, out respuesta);//Obtener los apremiosTrab para generar el fichero

                //Si el resultado es ERROR o SIN REGISTROS NO HACEMOS NADA
                if (respuesta.Resultado == ResultadoProceso.OK)
                {
                    //Establecer n�mero de pasos de la tarea
                    if (taskNumber.HasValue && taskType.HasValue && !String.IsNullOrEmpty(taskUser))
                        cTaskManagerBL.SetTotalSteps(taskUser, taskType.Value, taskNumber.Value, apremiosTrab.Count);

                    if (contabilizar)
                    {
                        int? asientoAInserta = null, asientoInsertado = null;
                        Int64 asientosInsertados = 0;

                        // Contabilizaci�n del apremio, el tipo Debe
                        if (respuesta.Resultado == ResultadoProceso.OK)
                            respuesta = cContabVentasBL.ContabilidadApremios(sociedadCodigo, fechaContabilizacion, usuarioCodigo, cApremioTrabBO.ETipo.Enviar, 'D', out asientosInsertados, asientoAInserta, out asientoInsertado);
                        // Contabilizaci�n del apremio, el tipo Haber
                        if (respuesta.Resultado == ResultadoProceso.OK)
                        {
                            asientoAInserta = asientoInsertado;
                            respuesta = cContabVentasBL.ContabilidadApremios(sociedadCodigo, fechaContabilizacion, usuarioCodigo, cApremioTrabBO.ETipo.Enviar, 'H', out asientosInsertados, asientoAInserta, out asientoInsertado);
                        }
                    }

                    //Recorro los apremiosTrab de la tabla de trabajo
                    for (int i = 0; respuesta.Resultado == ResultadoProceso.OK && i < apremiosTrab.Count; i++)
                    {
                        //Obtener la factura a la cual hace referencia el apremio
                        factura = new cFacturaBO();
                        factura.FacturaCodigo = apremiosTrab[i].FacturaCodigo;
                        factura.PeriodoCodigo = apremiosTrab[i].PeriodoCodigo;
                        factura.ContratoCodigo = apremiosTrab[i].ContratoCodigo;
                        factura.Version = apremiosTrab[i].FacturaVersion;

                        cFacturasBL.Obtener(ref factura, out respuesta);

                        cFacturasBL.ObtenerLineas(ref factura, out respuesta);

                        if (respuesta.Resultado == ResultadoProceso.OK && !factura.FechaContabilizacion.HasValue && contabilizar)
                            continue; // Si la factura no est� contabilizada no se procesa
                        if (respuesta.Resultado == ResultadoProceso.OK && factura.FechaFactRectificativa.HasValue)//Comprobamos si existe factura rectificativa
                            continue; //Si tiene fecha rectificativa quiere decir que se ha generado la rectificativa despu�s de realizar la selecci�n de los apremios a procesar. No se procesa el apremio                        
                        if (respuesta.Resultado == ResultadoProceso.OK) //Comprobamos si existen efectos pendientes a remesar y que no esten rechazados
                            existeEfectoPdte = cEfectosPendientesBL.Existe(factura.ContratoCodigo.Value, factura.PeriodoCodigo, factura.FacturaCodigo.Value, factura.SociedadCodigo.Value, false, false, out respuesta);
                        if (respuesta.Resultado == ResultadoProceso.OK && existeEfectoPdte) //Si existe efecto pendiente no se procesa el apremio
                            continue;
                        if (respuesta.Resultado == ResultadoProceso.OK)
                        {
                            apremio = new cApremioLinBO();
                            apremio.Numero = numeroApremioGenerado;
                            apremio.FechaGeneracion = fechaGeneracion;
                            apremio.UsuarioCodigo = apremiosTrab[i].UsuarioCodigo;
                            apremio.PeriodoCodigo = apremiosTrab[i].PeriodoCodigo;
                            apremio.ContratoCodigo = apremiosTrab[i].ContratoCodigo;
                            apremio.FacturaCodigo = apremiosTrab[i].FacturaCodigo;
                            apremio.FacturaVersion = apremiosTrab[i].FacturaVersion;

                            respuesta = cApremiosLinBL.Insertar(apremio);
                        }
                        if (respuesta.Resultado == ResultadoProceso.OK)
                        {
                            numeroApremioGenerado = apremio.Numero;
                            fechaGeneracion = apremio.FechaGeneracion;
                            cFacturasBL.ObtenerTotalFacturado(ref factura, fechaGeneracion.Value, out respuesta);
                        }
                        if (respuesta.Resultado == ResultadoProceso.OK)
                            cFacturasBL.ObtenerContrato(ref factura, out respuesta);


                        //Si estamos ejecutando en modo tarea...
                        //Puede que no inserte el cobro y debe realizarse una vez por cada iteraci�n
                        if (taskNumber.HasValue && taskType.HasValue && !String.IsNullOrEmpty(taskUser))
                        {
                            //Comprobar si se desea cancelar
                            if (cTaskManagerBL.CancelRequested(taskUser, taskType.Value, taskNumber.Value, out respuesta) && respuesta.Resultado == ResultadoProceso.OK)
                            {
                                apremiosProcesados = 0;
                                return String.Empty;
                            }
                            //Incrementar el n�mero de pasos
                            cTaskManagerBL.PerformStep(taskUser, taskType.Value, taskNumber.Value);
                        }



                        //----------------------
                        //Generaci�n del fichero Ciudad Real
                        //----------------------
                        if (respuesta.Resultado == ResultadoProceso.OK)
                        {
                            strTitularNif = factura.Contrato.TitularDocIden;
                            strTipodoc = factura.Contrato.TitularTipoDoc;

                            if (strTipodoc == "0" || strTipodoc == "1")
                            {
                                strTipodoc = "1";
                            }
                            else
                            {
                                strTipodoc = "2";
                            }
                            strCCC = factura.Contrato.CodCueCli;
                            strTitularNombre = factura.Contrato.TitularNombre;


                            if (cabecera)
                            {
                                //----------------------
                                // Cabecera del fichero
                                //----------------------
                                salida.Append("1"); // A(1) -TIPO DE REGISTRO
                                salida.Append(PROVINCIA_INE); //N(2) -CODIGPO DE PROVINCIA INE
                                salida.Append(MUNICIPIO_INE); //N(3) - CODIGO DE MUNICIPIO INE
                                salida.Append("042"); //N(3) - CONCEPTO TRIBUTARIO ===========================reVISAR EN FUNCI�N DEL SERVICIO DE LA LINEA
                                salida.Append("[Ejercicio]"); //N(4) - EJERCICIO AL QUE CORRESPONDE
                                salida.Append("00"); //N(2)PERIODO 00- Anual
                                salida.Append(cAplicacion.FixedLengthString("PADRON AGUA " + apremio.PeriodoCodigo.Substring(0, 4), 40, ' ', false, false)); //A(40) Descripcion del contenido del fichero
                                salida.Append("2");// N(1)  SITUACION -- 2 EJECUTIVA
                                salida.Append("[FecIniPer]"); // A(8)FECHA INICIO VOLUNTARIA EN EL FICHERO DE EJEMPLO VIE3NE COMO DDMMYYY
                                salida.Append("[FecFinPer]"); // A(8)FECHA FIN VOLUNTARIA EN EL FICHERO DE EJEMPLO VIE3NE COMO DDMMYYY
                                salida.Append("1");// N(1) TIPO VALOR 1 Liquidaci�n
                                salida.Append("0000");// N(4) a 0
                                salida.Append("0000000000");// N(10) a 0
                                salida.Append(cAplicacion.FixedLengthString(" ", 613, ' ', false, false));// N(613) a blancos

                                cabecera = false;
                            }

                            // TIPO DE REGISTRO 2 -DETALLE OBLIGATORIO
                            salida.Append(saltoDeLinea);
                            salida.Append("2");// A(1) a 2 TIPO DE REGISTRO
                            salida.Append("042");//CONCEPTO TRIBUTARIO N(3) '003' p.e. IVTM. (Ver anexo concepto C60)
                            salida.Append(factura.Fecha.Value.Year.ToString().PadLeft(4));//EJERCICIO N(4) 2999 (ejercicio al que corresponde)

                            salida.Append(cAplicacion.FixedLengthString(i.ToString(), 8, '0', true, true)); //NUMERO DE RECIBO N(8) 0
                            salida.Append("00");//PERIODO N(2) 00 � Anual (seg�n anexo 00-anual,....99 � sin periodo)

                            salida.Append(cAplicacion.FixedLengthString(factura.Numero, 20, ' ', false, false));//REFERENCIA A(20) Objeto tributario (identificar� un�vocamente el recibo)1

                            //FECHA INICIO PERIODO A(8) '99/99/99 ' - Fecha inicio de voluntaria
                            cFacturasBL.ObtenerPeriodo(ref factura, out respuesta);
                            periodoFactura = factura.Periodo;

                            string dia, mes, a�o;

                            if (respuesta.Resultado == ResultadoProceso.OK && periodoFactura != null)
                            {
                                //Si en el periodo est� establecida una fecha de inicio de periodo voluntario se usa esa, en caso contrario se usa la fecha de factura
                                if (periodoFactura.FechaInicioPagoVoluntario.HasValue)
                                {
                                    //Fecha emisi�n factura es la fecha de inicio de pago Voluntaria. 8 D�gitos

                                    dia = cAplicacion.FixedLengthString(periodoFactura.FechaInicioPagoVoluntario.Value.Day.ToString(), 2, '0', true, true);
                                    mes = cAplicacion.FixedLengthString(periodoFactura.FechaInicioPagoVoluntario.Value.Month.ToString(), 2, '0', true, true);
                                    a�o = cAplicacion.FixedLengthString(periodoFactura.FechaInicioPagoVoluntario.Value.Year.ToString(), 4, '0', true, true);

                                    salida.Append(dia); // --> Fecha inicio pago voluntario, DD (d�a). 2 D�gitos
                                    salida.Append(mes); // --> Fecha inicio pago voluntario, MM (mes). 2 D�gitos
                                    salida.Append(a�o); // --> Fecha inicio pago voluntario, AAAA (a�o). 4 D�gitos

                                    FecIniPerAux = a�o + mes + dia;

                                    if (FecIniPer == "")
                                    {
                                        FecIniPer = FecIniPerAux;
                                    }
                                    if (Int32.Parse(FecIniPer) > Int32.Parse(FecIniPerAux))
                                    {
                                        FecIniPer = FecIniPerAux;
                                    }
                                }
                                else
                                {
                                    dia = cAplicacion.FixedLengthString(factura.Fecha.Value.Day.ToString(), 2, '0', true, true);
                                    mes = cAplicacion.FixedLengthString(factura.Fecha.Value.Month.ToString(), 2, '0', true, true);
                                    a�o = cAplicacion.FixedLengthString(factura.Fecha.Value.Year.ToString(), 4, '0', true, true);

                                    //Fecha emisi�n factura es la fecha de inicio de pago Voluntaria. 8 D�gitos
                                    salida.Append(dia); // --> Fecha factura, DD (d�a). 2 D�gitos
                                    salida.Append(mes); // --> Fecha factura, MM (mes). 2 D�gitos
                                    salida.Append(a�o); // --> Fecha factura, AAAA (a�o). 4 D�gitos

                                    FecIniPerAux = a�o + mes + dia;

                                    if (FecIniPer == "")
                                    {
                                        FecIniPer = FecIniPerAux;
                                    }
                                    if (Int32.Parse(FecIniPer) > Int32.Parse(FecIniPerAux))
                                    {
                                        FecIniPer = FecIniPerAux;
                                    }
                                }
                            }

                            //FECHA FIN PERIODO A(8) '99/99/99 ' - Fecha fin de voluntaria IMPORTANTE!!!

                            // Fecha fin pago voluntario factura. 8 D�gitos
                            respuesta = cParametroBL.GetInteger("DIAS_PAGO_VOLUNTARIO", out diasPagoVoluntario);
                            if (respuesta.Resultado == ResultadoProceso.OK)
                            {
                                //Si en el periodo est� establecida una fecha de fin de periodo voluntario se usa esa
                                if (periodoFactura.FechaFinPagoVoluntario.HasValue)
                                {
                                    dia = cAplicacion.FixedLengthString(periodoFactura.FechaFinPagoVoluntario.Value.Day.ToString(), 2, '0', true, true);
                                    mes = cAplicacion.FixedLengthString(periodoFactura.FechaFinPagoVoluntario.Value.Month.ToString(), 2, '0', true, true);
                                    a�o = cAplicacion.FixedLengthString(periodoFactura.FechaFinPagoVoluntario.Value.Year.ToString(), 4, '0', true, true);

                                    salida.Append(dia); // --> Fecha inicio pago voluntario, DD (d�a). 2 D�gitos
                                    salida.Append(mes); // --> Fecha inicio pago voluntario, MM (mes). 2 D�gitos
                                    salida.Append(a�o); // --> Fecha inicio pago voluntario, AAAA (a�o). 4 D�gitos

                                    FecFinPerAux = a�o + mes + dia;

                                    if (FecFinPer == "")
                                    {
                                        FecFinPer = FecFinPerAux;
                                    }
                                    if (Int32.Parse(FecFinPer) > Int32.Parse(FecFinPerAux))
                                    {
                                        FecFinPer = FecFinPerAux;
                                    }
                                }
                                else //Sino se suman los d�as de pago voluntario a la fecha de factura
                                {
                                    dia = cAplicacion.FixedLengthString(factura.Fecha.Value.AddDays(Convert.ToDouble(diasPagoVoluntario)).Day.ToString(), 2, '0', true, true);
                                    mes = cAplicacion.FixedLengthString(factura.Fecha.Value.AddDays(Convert.ToDouble(diasPagoVoluntario)).Month.ToString(), 2, '0', true, true);
                                    a�o = cAplicacion.FixedLengthString(factura.Fecha.Value.AddDays(Convert.ToDouble(diasPagoVoluntario)).Year.ToString(), 4, '0', true, true);

                                    salida.Append(dia); // --> Fecha fin pago voluntario, DD (d�a). 2 D�gitos
                                    salida.Append(mes); // --> Fecha fin pago voluntario, MM (mes). 2 D�gitos
                                    salida.Append(a�o); // --> Fecha fin pago voluntario, AAAA (a�o). 4 D�gitos

                                    FecFinPerAux = a�o + mes + dia;
                                    if (FecFinPer == "")
                                    {
                                        FecFinPer = FecFinPerAux;
                                    }
                                    if (Int32.Parse(FecFinPer) > Int32.Parse(FecFinPerAux))
                                    {
                                        FecFinPer = FecFinPerAux;
                                    }
                                }
                            }

                            //IMPORTE N(12) Importe del recibo * 100
                            //string totfac = cAplicacion.FixedLengthString(factura.TotalFacturado.Value.ToString("N2").Replace(",", String.Empty).Replace(".", String.Empty), 12, '0', true, true);
                            //salida.Append(totfac);

                            //V2 para resolver problema de decimales
                            //Ahora pongo [ImporteFactura] para el total de la factura que despu�s reemplazar� con el c�lculo del total de la factura sumado l�nea a l�nea
                            salida.Append("[ImporteFactura]");
                            importeTotalFactura = 0;

                            //importeTotalRecibo += int.Parse(totfac);

                            //FECHA PROVIDENCIA APREMIO A(8) '99/99/99' Es muy IMPORTANTE que venga rellena.
                            salida.Append(cAplicacion.FixedLengthString(fechaContabilizacion.Day.ToString(), 2, '0', true, true)); // --> Fecha PROVIDENCIA, DD (d�a). 2 D�gitos
                            salida.Append(cAplicacion.FixedLengthString(fechaContabilizacion.Month.ToString(), 2, '0', true, true)); // --> Fecha PROVIDENCIA, MM (mes). 2 D�gitos
                            salida.Append(cAplicacion.FixedLengthString(fechaContabilizacion.Year.ToString(), 4, '0', true, true)); // --> Fecha PROVIDENCIA, AAAA (a�o). 4 D�gitos

                            //Obtener inmueble para coger los datos Fiscales
                            contrato = factura.Contrato;
                            cContratoBL.ObtenerInmueble(ref contrato, out respuesta);
                        }
                        if (respuesta.Resultado == ResultadoProceso.OK)
                        {
                            inmueble = contrato.InmuebleBO;
                            //Obtener la calle
                            respuesta = cInmuebleBL.ObtenerCalle(ref inmueble);
                        }
                        if (respuesta.Resultado == ResultadoProceso.OK)
                        {
                            calle = inmueble.Calle;
                            //Obtener Tipo de v�a para la sigla fiscal
                            respuesta = cCalleBL.ObtenerTipoVia(ref calle);
                        }
                        //DOMICILIO TRIBUTARIO A(60)
                        if (respuesta.Resultado == ResultadoProceso.OK)
                        {
                            StringBuilder domicilio = new StringBuilder(String.Empty);
                            //Obtener el tipo de v�a para la sigla fiscal
                            domicilio.Append(cAplicacion.FixedLengthString(calle.TipoVia.Abreviado, 2, ' ', false, false)); // --> Sigla fiscal. 2 D�gitos
                            domicilio.Append(cAplicacion.FixedLengthString(inmueble.Calle.Descripcion, 30, ' ', false, false)); // --> Calle fiscal. 30 D�gitos
                            domicilio.Append(cAplicacion.FixedLengthString(Regex.Replace(contrato.InmuebleBO.Finca, @"[^0-9]", "0"), 4, ' ', false, false)); // --> N�mero/Finca de la calle fiscal. 4 D�gitos
                            domicilio.Append(cAplicacion.FixedLengthString(contrato.InmuebleBO.Entrada, 2, ' ', false, false)); // --> Portal/Entrada de la calle fiscal. 2 D�gitos
                            domicilio.Append(cAplicacion.FixedLengthString(contrato.InmuebleBO.Bloque, 4, ' ', false, false)); // --> Bloque fiscal. 4 D�gitos
                            domicilio.Append(cAplicacion.FixedLengthString(contrato.InmuebleBO.Escalera, 2, ' ', false, false)); // --> Escalera fiscal. 2 D�gitos
                            domicilio.Append(cAplicacion.FixedLengthString(contrato.InmuebleBO.Planta, 3, ' ', false, false)); // --> Planta fiscal. 3 D�gitos
                            domicilio.Append(cAplicacion.FixedLengthString(contrato.InmuebleBO.Puerta, 4, ' ', false, false)); // --> Puerta fiscal. 4 D�gitos
                            //Obtener poblaci�n

                            salida.Append(cAplicacion.FixedLengthString(domicilio.ToString(), 60, ' ', false, false));


                            respuesta = cInmuebleBL.ObtenerPoblacion(ref inmueble);
                        }
                        if (respuesta.Resultado == ResultadoProceso.OK)
                        {
                            strPoblacion = inmueble.Poblacion.Descripcion;
                            strCodigoPostal = inmueble.Poblacion.CodigoPostal;
                            //Obtener provincia
                            respuesta = cInmuebleBL.ObtenerProvincia(ref inmueble);
                        }
                        if (respuesta.Resultado == ResultadoProceso.OK)
                        {
                            strProvincia = inmueble.Provincia.Descripcion;

                            //  salida.Append(cAplicacion.FixedLengthString(strPoblacion, 35, ' ', false, false)); // Poblaci�n fiscal. 35 D�gitos
                            //  salida.Append(cAplicacion.FixedLengthString(strProvincia, 35, ' ', false, false)); // Provincia fiscal. 35 D�gitos
                            //  salida.Append(cAplicacion.FixedLengthString(strCodigoPostal, 5, ' ', false, false)); // C�digo Postal fiscal. 5 D�gitos
                            //  salida.Append(cAplicacion.FixedLengthString(strPoblacion, 25, ' ', false, false)); // N�cleo de poblaci�n. 25 D�gitos
                            //  salida.Append(cAplicacion.FixedLengthString(contrato.TitularNacion, 35, ' ', false, false)); // Pa�s del contribuyente. 35 D�gitos
                            //   salida.Append(cAplicacion.Replicate("0", 8)); //Recargo de extemporaneidad. 8 d�gitos
                            //Cuaderno 60
                            //  salida.Append(cAplicacion.Replicate("0", 6)); //Fecha creacion carta pago. 6 d�gitos
                            //  salida.Append(cAplicacion.Replicate("0", 6)); //Fecha vencimiento carta pago. 6 d�gitos
                            //  salida.Append(cAplicacion.Replicate("0", 3)); //C�digo de tributo. 3 d�gitos
                            //  salida.Append(cAplicacion.Replicate("0", 10)); //Referencia 10 d�gitos
                            //   salida.Append(cAplicacion.Replicate(" ", 5)); //5 blancos



                            // Fecha notificaci�n factura. 8 D�gitos en blanco
                            // salida.Append(cAplicacion.Replicate(" ", 8));

                            // Fecha notificaci�n factura. 8 D�gitos
                            //salida.Append(cAplicacion.FixedLengthString(factura.Fecha.Value.Year.ToString(), 4, '0', true, true)); // --> Fecha factura, AAAA (a�o). 4 D�gitos
                            //salida.Append(cAplicacion.FixedLengthString(factura.Fecha.Value.Month.ToString(), 2, '0', true, true)); // --> Fecha factura, MM (mes). 2 D�gitos
                            //salida.Append(cAplicacion.FixedLengthString(factura.Fecha.Value.Day.ToString(), 2, '0', true, true)); // --> Fecha factura, DD (d�a). 2 D�gitos
                        }
                        if (respuesta.Resultado == ResultadoProceso.OK)
                        {
                            strDireccionSuministro = contrato.InmuebleBO.Direccion;
                            salida.Append(strTipodoc);//TIPO DE DOCUMENTO N(1) 1 = DNI/CIF, 2 = Otros (Pasaporte, Tarjeta de //Residencia, ...)

                            salida.Append(cAplicacion.FixedLengthString(strTitularNif, 20, ' ', false, false)); //A(20) DNI/CIF (y d�gito de control), Pasaporte, �
                            salida.Append(cAplicacion.FixedLengthString(strTitularNombre, 30, ' ', false, false)); //PRIMER APELLIDO A(30)
                            salida.Append(cAplicacion.Replicate(" ", 30));//SEGUNDO APELLIDO A(30)
                            salida.Append(cAplicacion.Replicate(" ", 80));//NOMBRE O RAZ�N SOCIAL A(80)
                            salida.Append("0");//TIPO DE DOMICILIO N(1) 0
                            salida.Append(PROVINCIA_INE);//C�DIGO DE PROVINCIA N(2) C�digo de Provincia INE
                            salida.Append(MUNICIPIO_INE);//C�DIGO DE MUNICIPIO N(3) C�digo de Municipio INE

                            salida.Append(cAplicacion.FixedLengthString(inmueble.Calle.TipoVia.Abreviado, 5, ' ', false, false));//TIPO DE V�A A(5)
                            salida.Append(cAplicacion.FixedLengthString(inmueble.Calle.Descripcion, 25, ' ', false, false));//NOMBRE DE LA VIA A(25)

                            salida.Append(cAplicacion.FixedLengthString(Regex.Replace(inmueble.Finca, @"[^0-9]", "0"), 4, '0', false, false));//PRIMER N�MERO N(4)
                            salida.Append(cAplicacion.FixedLengthString(" ", 1, ' ', false, false)); //LETRA PRIMER N�MERO A(1)
                            salida.Append(cAplicacion.FixedLengthString(" ", 4, '0', false, false)); //SEGUNDO N�MERO N(4) 0
                            salida.Append(cAplicacion.FixedLengthString(" ", 1, ' ', false, false)); //LETRA SEGUNDO N�MERO A(1) ' '
                            salida.Append(cAplicacion.FixedLengthString(Regex.Replace(inmueble.Kilometro, @"[^0-9]", "0"), 4, '0', false, false));//KILOMETRO N(4) 0
                            salida.Append(cAplicacion.FixedLengthString("", 2, '0', false, false));//HECT�METRO N(2) 0
                            salida.Append(cAplicacion.FixedLengthString(inmueble.Bloque, 2, ' ', false, false));//BLOQUE A(2) ' '
                            salida.Append(cAplicacion.FixedLengthString(inmueble.Entrada, 2, ' ', false, false));//PORTAL A(2) ' '
                            salida.Append(cAplicacion.FixedLengthString(inmueble.Escalera, 20, ' ', false, false));//ESCALERA A(20) ESCALERA
                            salida.Append(cAplicacion.FixedLengthString(inmueble.Planta, 3, '0', false, false));//PLANTA A(3) PLANTA
                            salida.Append(cAplicacion.FixedLengthString(inmueble.Puerta, 4, '0', false, false));//PUERTA A(4) PUERTA
                            salida.Append(cAplicacion.FixedLengthString(strPoblacion, 40, '0', false, false));//LOCALIDAD A(40) N-MPIO
                            salida.Append(cAplicacion.FixedLengthString(inmueble.Direccion, 60, ' ', false, false));//DOMICILIO NO ESTRUCTURADO A(60) ' ...'
                            salida.Append(cAplicacion.FixedLengthString(Regex.Replace(inmueble.CodigoPostal, @"[^0-9]", "0"), 5, '0', false, false));//CP N(5) CODIGO POSTAL
                            salida.Append(cAplicacion.FixedLengthString(" ", 252, ' ', false, false));//RESTO N(252) BLANCOS

                        }


                        //Carlos

                        // TIPO DE REGISTRO 3 -DETALLE CONCEPTOS

                        StringBuilder reg3 = new StringBuilder(String.Empty);

                        salida.Append(saltoDeLinea);
                        reg3.Append("3");// A(1) a 3 TIPO DE REGISTRO
                        reg3.Append("042");//CONCEPTO TRIBUTARIO N(3) '003' p.e. IVTM. (Ver anexo concepto C60)
                        reg3.Append(factura.Fecha.Value.Year.ToString().PadLeft(4));//EJERCICIO N(4) 2999 (ejercicio al que corresponde)
                        reg3.Append(cAplicacion.FixedLengthString(i.ToString(), 8, '0', true, true)); //NUMERO DE RECIBO N(8) 0
                        reg3.Append("00");//PERIODO N(2) 00 � Anual (seg�n anexo 00-anual,....99 � sin periodo)


                        //Obtener l�neas de la factura
                        cBindableList<cLineaFacturaBO> lineasFactura = new cBindableList<cLineaFacturaBO>(); //Lista vac�a, para evitar posibles referencias a nulo
                        if (respuesta.Resultado == ResultadoProceso.OK)
                        {
                            //lineasFactura = cFacturasBL.ObtenerLineas(ref factura, out respuesta); 
                            //Ahora 10/10/2019 lineas con deuda
                            lineasFactura = cFacturasBL.ObtenerLineasConDeuda(ref factura, out respuesta);
                            respuesta.Resultado = respuesta.Resultado == ResultadoProceso.SinRegistros ? ResultadoProceso.OK : respuesta.Resultado;
                        }

                        if (respuesta.Resultado == ResultadoProceso.OK)
                        {
                            ////Obtener iva
                            ///*var groupByImpuesto = lineasFactura.Where(a => a.ImpImpuesto > 0).OrderBy(a => a.PtjImpuesto).GroupBy(a => a.PtjImpuesto).ToList();
                            //decimal tipoIva1 = groupByImpuesto.Count > 0 ? groupByImpuesto[0].Key : 0;
                            //decimal importeIva1 = groupByImpuesto.Count > 0 ? groupByImpuesto[0].Sum(a => a.ImpImpuesto) : 0;
                            //decimal tipoIva2 = groupByImpuesto.Count > 1 ? groupByImpuesto[1].Key : 0;
                            //decimal importeIva2 = groupByImpuesto.Count > 1 ? groupByImpuesto[1].Sum(a => a.ImpImpuesto) : 0;
                            //*/
                            ///*if (factura.Version > 1) //Es rectificativa suma de los dias de pago voluntario a la fecha de factura
                            //{
                            //    salida.Append(cAplicacion.FixedLengthString(factura.Fecha.Value.AddDays(Convert.ToDouble(diasPagoVoluntario)).Year.ToString(), 4, '0', true, true)); // --> Fecha fin pago voluntario, AAAA (a�o). 4 D�gitos
                            //    salida.Append(cAplicacion.FixedLengthString(factura.Fecha.Value.AddDays(Convert.ToDouble(diasPagoVoluntario)).Month.ToString(), 2, '0', true, true)); // --> Fecha fin pago voluntario, MM (mes). 2 D�gitos
                            //    salida.Append(cAplicacion.FixedLengthString(factura.Fecha.Value.AddDays(Convert.ToDouble(diasPagoVoluntario)).Day.ToString(), 2, '0', true, true)); // --> Fecha fin pago voluntario, DD (d�a). 2 D�gitos
                            //}
                            //*/

                            //salida.Append(cAplicacion.FixedLengthString(factura.Fecha.Value.Year.ToString(), 4, ' ', false, false)); // --> A�o al que se refiere la liquidaci�n /a�o de factura. 4 D�gitos
                            //salida.Append(cAplicacion.Replicate("0", 12)); //Importe del recargo provincial. 12 ceros
                            //salida.Append(cAplicacion.Replicate(" ", 20)); // Matricula para impuestos de vehiculos... 20 D�gitos
                            //salida.Append(cAplicacion.FixedLengthString(strDireccionSuministro, 50, ' ', false, false)); // --> Direcci�n Fiscal. 50 D�gitos

                            ////El periodo y el consumo se asignan a las observaciones
                            //string periodoCodigo = Resource.periodo + ":" + cAplicacion.FixedLengthString(factura.PeriodoCodigo, 6, ' ', false, false);
                            //string consumo = Resource.consumo + ":" + cAplicacion.FixedLengthString(factura.ConsumoFactura.ToString(), 7, ' ', false, false);
                            //salida.Append(cAplicacion.FixedLengthString(periodoCodigo + " " + consumo, 70, ' ', false, false)); //Observaciones-->Periodo y Consumo

                            //salida.Append(cAplicacion.Replicate("0", 8)); //Intereses de expontaneidad. 8 ceros
                            //                                              /* ------------------------------------ */
                            //                                              /* IVA ahora se detalla en el registro 3
                            //                                                 -----------------------------------
                            //                                              salida.Append(cAplicacion.Replicate(" ", 1)); //Espacion en blanco. 1 d�gito
                            //                                              salida.Append(cAplicacion.FixedLengthString(tipoIva1.ToString("F0"), 2, '0', true, true)); //IVA 1�. 2 d�gito
                            //                                              salida.Append(cAplicacion.FixedLengthString((cAplicacion.Round(importeIva1, 2) * 100).ToString("F0"), 8, '0', true, true)); //IVA 1 centimos euro. 8 d�gito
                            //                                              salida.Append(cAplicacion.FixedLengthString(tipoIva2.ToString("F0"), 2, '0', true, true)); //IVA 2�. 2 d�gito
                            //                                              salida.Append(cAplicacion.FixedLengthString((cAplicacion.Round(importeIva2, 2) * 100).ToString("F0"), 8, '0', true, true)); //IVA 2 centimos euro. 8 d�gito
                            //                                              */
                            //                                              //Las 21 posiciones que se reservaban para los datos del IVA se dejan en blanco
                            //salida.Append(cAplicacion.Replicate(" ", 21));

                            ////TODO: Solicitado por el cliente (Guadalagua), soluci�n temporal
                            ////Datos de domiciliaci�n bancaria del titular, si no existen se pondr� todo a ceros
                            ///*if (!String.IsNullOrEmpty(contrato.CodCueCli))
                            //{
                            //    salida.Append(cAplicacion.FixedLengthString(contrato.CodCueCli.Substring(0, 4), 4, '0', true, true)); //Entidad
                            //    salida.Append(cAplicacion.FixedLengthString(contrato.CodCueCli.Substring(4, 4), 4, '0', true, true)); //Oficina
                            //    salida.Append(cAplicacion.FixedLengthString(contrato.CodCueCli.Substring(8, 2), 2, '0', true, true)); //Digito Control
                            //    salida.Append(cAplicacion.FixedLengthString(contrato.CodCueCli.Substring(10, 10), 10, '0', true, true)); //Cuenta
                            //}
                            //else*/
                            //salida.Append(cAplicacion.Replicate("0", 20)); // CCC. 20 d�gitos

                            //salida.Append(cAplicacion.Replicate("0", 8)); // Fecha Domiciliaci�n. 8 D�gitos
                            //salida.Append(cAplicacion.Replicate(" ", 10)); //NIF. 10 d�gitos
                            //salida.Append(cAplicacion.Replicate(" ", 40)); //Nombre. 40 d�gitos

                            ////---------------------------------------
                            //// Detalle del fichero. L�neas de factura
                            ////---------------------------------------
                            //salida.Append(saltoDeLinea);
                            //salida.Append("01"); //Registro de cargo. Fijo --> 01. 2 D�gitos
                            //salida.Append(cAplicacion.FixedLengthString("04", 6, '0', true, true)); //Concepto Tributario. 6 D�gitos
                            //salida.Append(cAplicacion.FixedLengthString(factura.PeriodoCodigo.Substring(0, 4), 4, '0', true, true)); //A�o del valor. 4 D�gitos
                            //salida.Append(cAplicacion.FixedLengthString(factura.Numero.ToString(), 7, '0', true, true)); //N�mero de factura. 7 D�gitos
                            //salida.Append("0000"); //N�mero de orden del valor. Fijo--> 0000. 4 D�gitos
                            //salida.Append("R"); //Tipo de valor. Fijo--> R (Recibo). 1 D�gitos
                        }

                        //Recorrer l�neas de la factura
                        //m�ximo 7 conceptos + 1 (original) de 'CONCEPTO TRIBUTARIO'
                        for (int j = 0; j < 9 && j < lineasFactura.Count && respuesta.Resultado == ResultadoProceso.OK; j++)
                        {
                            //EJERCICIO CONCEPTO 1
                            //CODIGO CONCEPTO 1
                            //IMPORTE 1
                            //RESTO 1
                            //if (lineasFactura.Count >= j + 1)
                            //{
                            string strServicio = String.Empty, strTarifa = String.Empty;
                            cLineaFacturaBO linea = lineasFactura[j];
                            new cLineasFacturaBL().ObtenerServicio(ref linea, out respuesta);

                            if (respuesta.Resultado == ResultadoProceso.OK)
                            {
                                //strServicio = linea.Servicio.Descripcion;

                                //salida.Append(apremio.PeriodoCodigo.PadLeft(4));//EJERCICIO N(4) 2999 (ejercicio al que corresponde)
                                reg3.Append(factura.Fecha.Value.Year.ToString());//EJERCICIO N(4) 2999 (ejercicio al que corresponde)

                                if (MUNICIPIO_INE == "011") //Almaden
                                {

                                    //convertimos nuestro c�digo de servicio al del anexo concepto C60
                                    switch (linea.Servicio.Codigo)
                                    {
                                        case 1:
                                            strServicio = "042"; //AGUA
                                            break;
                                        case 3:
                                            strServicio = "100"; //MANTENIMIENTO DE CONTADOR
                                            break;
                                        case 11:
                                            strServicio = "011"; //BASURAS
                                            break;
                                        case 12:
                                            strServicio = "168"; //TASA SERVICIO PUNTO LIMPIO
                                            break;
                                        default:
                                            strServicio = "*";  //SI NO ES NINGUNO DE LOS RECONOCIDOS, LO MARCAMOS CON *
                                            break;
                                    }

                                }

                                else //Alamillo
                                {
                                    /*Agua Potable    1
                                    Mtto.de Contador   2
                                    Depuraci�n de agua residual 5
                                    Residuos Solidos    11*/

                                    //convertimos nuestro c�digo de servicio al del anexo concepto C60
                                    switch (linea.Servicio.Codigo)
                                    {
                                        case 1:
                                            strServicio = "042"; //AGUA
                                            break;
                                        case 2:
                                            strServicio = "100"; //MANTENIMIENTO DE CONTADOR
                                            break;
                                        case 11:
                                            strServicio = "011"; //BASURAS
                                            break;
                                        case 5:
                                            strServicio = "111"; //DEPURACION-CUOTA 111 DEPURACION
                                            break;
                                        default:
                                            strServicio = "*";  //SI NO ES NINGUNO DE LOS RECONOCIDOS, LO MARCAMOS CON *
                                            break;
                                    }


                                }

                                //salida.Append(strServicio.PadLeft(3));//CODIGO CONCEPTO N(3)
                                reg3.Append(strServicio.PadLeft(3));//CODIGO CONCEPTO N(3)

                                string totfaclin = cAplicacion.FixedLengthString(linea.Total.ToString("N2").Replace(",", String.Empty).Replace(".", String.Empty), 12, '0', true, true);

                                importeTotalFactura += int.Parse(totfaclin);

                                //salida.Append(cAplicacion.FixedLengthString(totfac.ToString(), 12, '0', true, true));
                                reg3.Append(cAplicacion.FixedLengthString(totfaclin.ToString(), 12, '0', true, true));

                                //strServicio = linea.Servicio.Codigo;
                            }

                            //new cLineasFacturaBL().ObtenerTarifa(ref linea, out respuesta);
                            //if (respuesta.Resultado == ResultadoProceso.OK)
                            //    strTarifa = linea.Tarifa.Descripcion;



                            //Ajustar a los servicios del C60
                            //Lineas de detalle por servicio
                            //ejercicio, c�digo, importe

                            //string servicioTarifa = cAplicacion.FixedLengthString(strServicio + "/" + strTarifa, 48, ' ', false, false);
                            //string lBase = cAplicacion.FixedLengthString(linea.CBase.ToString("N4").Replace(",", String.Empty).Replace(".", String.Empty), 8, ' ', true, true);
                            //string impImp = cAplicacion.FixedLengthString(linea.ImpImpuesto.ToString("N4").Replace(",", String.Empty).Replace(".", String.Empty), 6, ' ', true, true);

                            //string total = cAplicacion.FixedLengthString(linea.Total.ToString("N4").Replace(",", String.Empty).Replace(".", String.Empty), 8, ' ', true, true);
                            //IMPORTE N(12) Importe del concepto * 100


                            //salida.Append(cAplicacion.FixedLengthString(servicioTarifa + lBase + impImp + total, 70, ' ', false, false));

                            //}
                            //else
                            //    salida.Append(cAplicacion.Replicate(" ", 70)); //L�nea de detalle en blanco. 70 d�gitos
                        }

                        //salida.Append(cAplicacion.Replicate(" ", 530)); //Espacios en blanco
                        //salida.Append(saltoDeLinea);

                        salida.Append(cAplicacion.FixedLengthString(reg3.ToString(), 700, ' ', false, false));


                        //----------------------------------------
                        // Registro o l�nea del desglose del valor
                        //----------------------------------------

                        // TIPO DE REGISTRO 4 -REGISTRO DE DETALLE

                        StringBuilder reg4 = new StringBuilder(String.Empty);

                        salida.Append(saltoDeLinea);
                        reg4.Append("4");// A(1) a 4 REGISTRO DE DETALLE
                        reg4.Append("042");//CONCEPTO TRIBUTARIO N(3) '003' p.e. IVTM. (Ver anexo concepto C60)
                        reg4.Append(factura.Fecha.Value.Year.ToString().PadLeft(4));//EJERCICIO N(4) 2999 (ejercicio al que corresponde)
                        reg4.Append(cAplicacion.FixedLengthString(i.ToString(), 8, '0', true, true)); //NUMERO DE RECIBO N(8) 0
                        reg4.Append("00");//PERIODO N(2) 00 � Anual (seg�n anexo 00-anual,....99 � sin periodo)


                        //Recorrer l�neas de la factura m�ximo 11 l�neas
                        for (int k = 0; k < lineasFactura.Count && respuesta.Resultado == ResultadoProceso.OK && k <= 11; k++)
                        {
                            cLineaFacturaBO linea = lineasFactura[k];
                            //string subconceptoCodigo = "0";
                            new cLineasFacturaBL().ObtenerServicio(ref linea, out respuesta);

                            //if (respuesta.Resultado == ResultadoProceso.OK)
                            //{
                            //    //Establecer el subconcepto asociado al servicio, dato facilitado por el Ayuntamiento.
                            //    if (linea.Servicio.Codigo == 1) //Agua
                            //        subconceptoCodigo = SubContepto(SubconceptoCodigo.Agua);
                            //    else if (linea.Servicio.Codigo == 2) //Mtto contador
                            //        subconceptoCodigo = SubContepto(SubconceptoCodigo.Contador);
                            //    else //Alcantarillado
                            //        subconceptoCodigo = SubContepto(SubconceptoCodigo.Alcantarillado);
                            //}

                            //Lineas de registros de desglose del valor por servicio
                            //salida.Append("03"); //Registro de desglose del valor. Fijo --> 03. 2 D�gitos

                            //string subconcepto = cAplicacion.FixedLengthString(subconceptoCodigo.ToString(), 2, '0', true, true); //C�digo del subconcepto. 2 D�gitos.
                            string total = linea.Total.ToString("N2").Replace(",", String.Empty).Replace(".", String.Empty);
                            //string ptjImp = cAplicacion.FixedLengthString(linea.PtjImpuesto.ToString("F0"), 2, '0', true, true);
                            //string impImp = cAplicacion.FixedLengthString(linea.ImpImpuesto.ToString("N2").Replace(",", String.Empty).Replace(".", String.Empty), 12, '0', true, true);

                            //salida.Append(cAplicacion.FixedLengthString(subconceptoCodigo + total + ptjImp + impImp, 28, ' ', false, false));

                            //a�ado en la l�nea el contrato, el servicio y el total
                            reg4.Append(cAplicacion.FixedLengthString("Contrato:" + linea.Contrato, 40, ' ', false, false));
                            reg4.Append(cAplicacion.FixedLengthString("Servicio:" + linea.Servicio.Descripcion, 40, ' ', false, false));
                            reg4.Append(cAplicacion.FixedLengthString("Total:" + total, 40, ' ', false, false));

                            //salida.Append(cAplicacion.Replicate(" ", 582)); //Espacios en blanco
                            //salida.Append(saltoDeLinea);
                        }

                        //salida.Append(cAplicacion.Replicate(" ", 582)); //Espacios en blanco

                        //V2 sustituimos [ImporteFactura] por el sumatorio de las l�neas                
                        salida.Replace("[ImporteFactura]", cAplicacion.FixedLengthString(importeTotalFactura.ToString(), 12, '0', true, true));
                        importeTotalFichero += importeTotalFactura;

                        salida.Append(cAplicacion.FixedLengthString(reg4.ToString(), 700, ' ', false, false));

                        //Si el fichero se ha realizado correctamente, se borra el apremio de la tabla de trabajo
                        if (respuesta.Resultado == ResultadoProceso.OK)
                            respuesta = Borrar(apremiosTrab[i]);

                        if (respuesta.Resultado == ResultadoProceso.OK)
                            apremiosProcesados++;

                        //Si algo no va bien se a�ade al mensaje de la respuesta, el periodo y el c�digo de factura en el cual se ha producido el error
                        if (respuesta.Resultado != ResultadoProceso.OK)
                            cExcepciones.ControlarER(new Exception(respuesta.Ex.Message + ", " + Resource.periodo + ": " + factura.PeriodoCodigo + ", " + Resource.contrato + ": " + factura.ContratoCodigo), TipoExcepcion.Informacion, out respuesta);


                        //s�lo lo pintamos si hemos terminado de pintar recibos
                        if (i + 1 == apremiosTrab.Count)
                        {

                            //Hago replace de las fechas de periodos inicio y fin del TipoRegistro 1 y del ejercicio
                            salida.Replace("[FecIniPer]", FecIniPer.Substring(6, 2) + FecIniPer.Substring(4, 2) + FecIniPer.Substring(0, 4));
                            salida.Replace("[FecFinPer]", FecFinPer.Substring(6, 2) + FecFinPer.Substring(4, 2) + FecFinPer.Substring(0, 4));
                            salida.Replace("[Ejercicio]", FecIniPer.Substring(0, 4));

                            // TIPO DE REGISTRO 6 -REGISTRO DE TOTALES
                            salida.Append(saltoDeLinea);
                            salida.Append("6"); // A(1) a 4 TIPO DE REGISTRO
                            salida.Append("13"); // N(2) CODIGO DE PROVINCIA INE
                            salida.Append("011"); // N(3) CODIGO DE MUNICIPIO INE
                            salida.Append("042"); // N(3) CONCEPTO TRIBUTARIO '003' p.e. IVTM. (Ver anexo concepto C60)
                            salida.Append(FecIniPer.Substring(0, 4)); // EJERCICIO N(4) 2999 (ejercicio al que corresponde)
                            salida.Append("00");//PERIODO N(2) 00 � Anual (seg�n anexo 00-anual,....99 � sin periodo)

                            salida.Append(cAplicacion.FixedLengthString(apremiosProcesados.ToString(), 8, '0', true, true)); // N(8)  NUMERO TOTAL DE RECIBOS
                            salida.Append(cAplicacion.FixedLengthString(importeTotalFichero.ToString(), 12, '0', true, true)); // N(12)  IMPORTE TOTAL DE RECIBOS

                            salida.Append(cAplicacion.FixedLengthString("", 24, '0', true, true)); // RELLENO A CEROS
                            salida.Append(cAplicacion.FixedLengthString("", 641, ' ', true, true)); // RELLENO A BLANCOS
                        }

                    }//fin del for

                    if (respuesta.Resultado == ResultadoProceso.OK)
                        scope.Complete();
                    else
                    {
                        apremiosProcesados = 0;
                        return String.Empty;
                    }
                } //Fin if(Respuesta.Resultado == OK)
            } //Fin TransactionScope

            //Solo se inserta en el log 
            if (respuesta.Resultado == ResultadoProceso.OK && apremiosProcesados > 0 && apremiosProcesados != apremiosTrab.Count)
                log = Resource.apremioXGeneradaConIncidencias.Replace("@apremio", numeroApremioGenerado.HasValue ? numeroApremioGenerado.Value.ToString() : String.Empty);
            if (respuesta.Resultado == ResultadoProceso.OK && apremiosProcesados == 0)
                log = Resource.errorApremiosNoProcesados;

            return salida.ToString();
        }


        /// <summary>
        /// Genera los cobros a partir de los registros de la tabla de trabajo de apremios y 
        /// un String con un formato espec�fico con todos los cobros realizados correctamente.
        /// Los cobros realizados se borran de la tabla de trabajo
        /// </summary>
        /// <param name="usuarioCodigo">C�digo del usuario</param>
        /// <param name="numeroApremioGenerado">N�mero de apremio generado</param>
        /// <param name="log">Log</param>
        /// <param name="respuesta">Respuesta</param>
        /// <param name="apremiosProcesados"></param>
        /// <param name="taskUser">Usuario que ejecuta la tarea</param>
        /// <param name="taskType">Tipo de tarea</param>
        /// <param name="taskNumber">N�mero de tarea</param>
        /// <returns>Contenido del fichero</returns>
        // DE MOMENTO NO SE VA A USAR, SE VAN A LIQUIDAR LOS SERVICIOS
        public static String ProcesarRibadesella(String usuarioCodigo, out int? numeroApremioGenerado, DateTime fechaContabilizacion, out String log, out cRespuesta respuesta, out int apremiosProcesados, string taskUser, ETaskType? taskType, int? taskNumber)
        {
            StringBuilder salida = new StringBuilder(String.Empty);
            log = String.Empty;
            apremiosProcesados = 0;
            cCobroBO cobro = new cCobroBO();
            cCobroLinBO cobroLinea = new cCobroLinBO();
            String saltoDeLinea = Environment.NewLine;
            string strPoblacion = String.Empty, strProvincia = String.Empty, PROVINCIA_INE = "33", MUNICIPIO_INE = "056",
                   strCodigoPostal = String.Empty, strDireccionSuministro = String.Empty,
                   strCCC = String.Empty, strTitularNif = String.Empty, strTipodoc = String.Empty,
                   strTitularNombre = String.Empty;
            numeroApremioGenerado = null;
            DateTime? fechaGeneracion = null;
            int diasPagoVoluntario = 0;
            cBindableList<cApremioTrabBO> apremiosTrab = null;
            cContratoBO contrato = null;
            cInmuebleBO inmueble = null;
            cApremioLinBO apremio = null;
            cFacturaBO factura = null;
            cCalleBO calle = null;
            cPeriodoBO periodoFactura = null;
            bool existeEfectoPdte = false;
            cValidator validador = new cValidator();

            using (TransactionScope scope = cAplicacion.NewTransactionScope())
            {
                string strContabilizar = null;
                bool contabilizar = false;

                /*Obtener sociedad por defecto*/
                string strSociedadCodigo = cParametroBL.ObtenerValor("SOCIEDAD_POR_DEFECTO", out respuesta);
                if (String.IsNullOrEmpty(strSociedadCodigo))
                    cExcepciones.ControlarER(new Exception(Resource.errorParametroNoTieneValor.Replace("@item", "SOCIEDAD_POR_DEFECTO")), TipoExcepcion.Error, out respuesta);
                short sociedadCodigo = Convert.ToInt16(strSociedadCodigo);

                if (respuesta.Resultado == ResultadoProceso.OK)
                {
                    /*Obtener par�metro que determina si se contabiliza o no*/
                    strContabilizar = cParametroBL.ObtenerValor("CONTABILIZAR", out respuesta);
                    if (String.IsNullOrEmpty(strContabilizar))
                        cExcepciones.ControlarER(new Exception(Resource.errorParametroNoTieneValor.Replace("@item", "CONTABILIZAR")), TipoExcepcion.Error, out respuesta);
                    contabilizar = Convert.ToBoolean(strContabilizar);
                }

                if (respuesta.Resultado == ResultadoProceso.OK && contabilizar)
                {
                    //Comprobar que la fecha sea mayor que la fecha de cierre contable
                    cSociedadBO sociedad = new cSociedadBO();
                    sociedad.Codigo = sociedadCodigo;
                    cSociedadBL.Obtener(ref sociedad, out respuesta);
                    if (sociedad.FechaCierreContable.HasValue && respuesta.Resultado == ResultadoProceso.OK)
                    {
                        if (sociedad.FechaCierreContable.Value >= fechaContabilizacion)
                        {
                            validador.AddCustomMessage(Resource.val_fechaAnteriorEstricta.Replace("@field2", Resource.fechaContable).Replace("@field1", Resource.fechaCierreContable));
                            cExcepciones.ControlarER(new Exception(validador.Validate(true)), TipoExcepcion.Error, out respuesta);
                            return null;
                        }
                    }
                }

                if (respuesta.Resultado == ResultadoProceso.OK)
                    apremiosTrab = Obtener(usuarioCodigo, (short)cApremioTrabBO.ETipo.Enviar, out respuesta);//Obtener los apremiosTrab para generar el fichero

                //Si el resultado es ERROR o SIN REGISTROS NO HACEMOS NADA
                if (respuesta.Resultado == ResultadoProceso.OK)
                {
                    //Establecer n�mero de pasos de la tarea
                    if (taskNumber.HasValue && taskType.HasValue && !String.IsNullOrEmpty(taskUser))
                        cTaskManagerBL.SetTotalSteps(taskUser, taskType.Value, taskNumber.Value, apremiosTrab.Count);

                    if (contabilizar)
                    {
                        int? asientoAInserta = null, asientoInsertado = null;
                        Int64 asientosInsertados = 0;

                        // Contabilizaci�n del apremio, el tipo Debe
                        if (respuesta.Resultado == ResultadoProceso.OK)
                            respuesta = cContabVentasBL.ContabilidadApremios(sociedadCodigo, fechaContabilizacion, usuarioCodigo, cApremioTrabBO.ETipo.Enviar, 'D', out asientosInsertados, asientoAInserta, out asientoInsertado);
                        // Contabilizaci�n del apremio, el tipo Haber
                        if (respuesta.Resultado == ResultadoProceso.OK)
                        {
                            asientoAInserta = asientoInsertado;
                            respuesta = cContabVentasBL.ContabilidadApremios(sociedadCodigo, fechaContabilizacion, usuarioCodigo, cApremioTrabBO.ETipo.Enviar, 'H', out asientosInsertados, asientoAInserta, out asientoInsertado);
                        }
                    }


                    #region Fichero F211 (S�lo Canon)

                    //----------------------
                    //Fichero impagos 211 para Principado Asturias (s�lo Canon)
                    //----------------------

                    salida.Append("*FICHERO FORMATO 211 PRINCIPADO DE ASTURIAS (SOLO CANON)*"); // cabecera propia
                    salida.Append(saltoDeLinea);

                    //Recorro los apremiosTrab de la tabla de trabajo
                    for (int i = 0; respuesta.Resultado == ResultadoProceso.OK && i < apremiosTrab.Count; i++)
                    {
                        //Obtener la factura a la cual hace referencia el apremio
                        factura = new cFacturaBO();
                        factura.FacturaCodigo = apremiosTrab[i].FacturaCodigo;
                        factura.PeriodoCodigo = apremiosTrab[i].PeriodoCodigo;
                        factura.ContratoCodigo = apremiosTrab[i].ContratoCodigo;
                        factura.Version = apremiosTrab[i].FacturaVersion;

                        cFacturasBL.Obtener(ref factura, out respuesta);

                        cFacturasBL.ObtenerLineas(ref factura, out respuesta);

                        if (respuesta.Resultado == ResultadoProceso.OK && !factura.FechaContabilizacion.HasValue && contabilizar)
                            continue; // Si la factura no est� contabilizada no se procesa
                        if (respuesta.Resultado == ResultadoProceso.OK && factura.FechaFactRectificativa.HasValue)//Comprobamos si existe factura rectificativa
                            continue; //Si tiene fecha rectificativa quiere decir que se ha generado la rectificativa despu�s de realizar la selecci�n de los apremios a procesar. No se procesa el apremio                        
                        if (respuesta.Resultado == ResultadoProceso.OK) //Comprobamos si existen efectos pendientes a remesar y que no esten rechazados
                            existeEfectoPdte = cEfectosPendientesBL.Existe(factura.ContratoCodigo.Value, factura.PeriodoCodigo, factura.FacturaCodigo.Value, factura.SociedadCodigo.Value, false, false, out respuesta);
                        if (respuesta.Resultado == ResultadoProceso.OK && existeEfectoPdte) //Si existe efecto pendiente no se procesa el apremio
                            continue;
                        //if (respuesta.Resultado == ResultadoProceso.OK)
                        //{
                        //    apremio = new cApremioLinBO();
                        //    apremio.Numero = numeroApremioGenerado;
                        //    apremio.FechaGeneracion = fechaGeneracion;
                        //    apremio.UsuarioCodigo = apremiosTrab[i].UsuarioCodigo;
                        //    apremio.PeriodoCodigo = apremiosTrab[i].PeriodoCodigo;
                        //    apremio.ContratoCodigo = apremiosTrab[i].ContratoCodigo;
                        //    apremio.FacturaCodigo = apremiosTrab[i].FacturaCodigo;
                        //    apremio.FacturaVersion = apremiosTrab[i].FacturaVersion;

                        //    respuesta = cApremiosLinBL.Insertar(apremio);
                        //}
                        //if (respuesta.Resultado == ResultadoProceso.OK)
                        //{
                        //    numeroApremioGenerado = apremio.Numero;
                        //    fechaGeneracion = apremio.FechaGeneracion;
                        //    cFacturasBL.ObtenerTotalFacturado(ref factura, fechaGeneracion.Value, out respuesta);
                        //}

                        if (respuesta.Resultado == ResultadoProceso.OK)
                            cFacturasBL.ObtenerContrato(ref factura, out respuesta);


                        ////Si estamos ejecutando en modo tarea...
                        ////Puede que no inserte el cobro y debe realizarse una vez por cada iteraci�n
                        //if (taskNumber.HasValue && taskType.HasValue && !String.IsNullOrEmpty(taskUser))
                        //{
                        //    //Comprobar si se desea cancelar
                        //    if (cTaskManagerBL.CancelRequested(taskUser, taskType.Value, taskNumber.Value, out respuesta) && respuesta.Resultado == ResultadoProceso.OK)
                        //    {
                        //        apremiosProcesados = 0;
                        //        return String.Empty;
                        //    }
                        //    //Incrementar el n�mero de pasos
                        //    cTaskManagerBL.PerformStep(taskUser, taskType.Value, taskNumber.Value);
                        //}

                        //----------------------
                        //Generaci�n del fichero Ribadesella
                        //----------------------
                        if (respuesta.Resultado == ResultadoProceso.OK)
                        {
                            strTitularNif = factura.Contrato.TitularDocIden;
                            strCCC = factura.Contrato.CodCueCli;
                            strTitularNombre = factura.Contrato.TitularNombre;

                            //S�lo escribo si tiene impago una factura con canon de saneamiento
                            //Obtener l�neas de la factura
                            cBindableList<cLineaFacturaBO> lineasFactura = new cBindableList<cLineaFacturaBO>(); //Lista vac�a, para evitar posibles referencias a nulo
                            if (respuesta.Resultado == ResultadoProceso.OK)
                            {
                                //lineasFactura = cFacturasBL.ObtenerLineas(ref factura, out respuesta);
                                lineasFactura = cFacturasBL.ObtenerLineasConDeuda(ref factura, out respuesta);
                                respuesta.Resultado = respuesta.Resultado == ResultadoProceso.SinRegistros ? ResultadoProceso.OK : respuesta.Resultado;
                            }

                            bool canonEnFactura = false;
                            decimal importeCanonFactura = 0;

                            //Recorrer l�neas de la factura 
                            for (int j = 0; j < lineasFactura.Count && respuesta.Resultado == ResultadoProceso.OK; j++)
                            {
                                cLineaFacturaBO linea = lineasFactura[j];
                                new cLineasFacturaBL().ObtenerServicio(ref linea, out respuesta);

                                if (respuesta.Resultado == ResultadoProceso.OK)
                                {
                                    if (linea.Servicio.Codigo == 7 || linea.Servicio.Codigo == 9 || linea.Servicio.Codigo == 11 || linea.Servicio.Codigo == 12)
                                    {
                                        canonEnFactura = true;

                                        string totfaclinCanon = cAplicacion.FixedLengthString(linea.CBase.ToString("N2").Replace(",", String.Empty).Replace(".", String.Empty), 9, '0', true, true);

                                        importeCanonFactura += int.Parse(totfaclinCanon);
                                    }
                                }
                            }

                            if (canonEnFactura)
                            {
                                salida.Append(cAplicacion.FixedLengthString(((DateTime)factura.Fecha).Year.ToString().Substring(2, 2), 2, '0', true, true)); // N(2) Ejercicio
                                salida.Append("901"); // N(3) entemisora
                                salida.Append("056"); // N(3) ayuntamiento
                                salida.Append("181"); // N(3) tributo 181 canon saneamiento
                                salida.Append(cAplicacion.FixedLengthString(((DateTime)factura.Fecha).Year.ToString().Substring(2, 2), 2, '0', true, true)); // N(2) a�o de liquidaci�n del recibo

                                // Factura
                                salida.Append(cAplicacion.FixedLengthString(factura.Numero, 12, '0', true, true)); // N(12) n�mero recibo
                                salida.Append(cAplicacion.FixedLengthString(factura.ContratoCodigo.ToString(), 12, '0', true, true)); // N(12) n�mero abonado

                                salida.Append(cAplicacion.FixedLengthString(importeCanonFactura.ToString(), 9, '0', true, true)); // N(9)

                                // A(6)FECHA INICIO VOLUNTARIA DDMMYY
                                cFacturasBL.ObtenerPeriodo(ref factura, out respuesta);
                                periodoFactura = factura.Periodo;

                                string dia = string.Empty, mes = string.Empty, a�o = string.Empty, fecLiquidacion = string.Empty;

                                if (respuesta.Resultado == ResultadoProceso.OK && periodoFactura != null)
                                {
                                    //Si en el periodo est� establecida una fecha de inicio de periodo voluntario se usa esa, en caso contrario se usa la fecha de factura
                                    if (periodoFactura.FechaInicioPagoVoluntario.HasValue)
                                    {
                                        //Fecha emisi�n factura es la fecha de inicio de pago Voluntaria. 8 D�gitos

                                        dia = cAplicacion.FixedLengthString(periodoFactura.FechaInicioPagoVoluntario.Value.Day.ToString(), 2, '0', true, true);
                                        mes = cAplicacion.FixedLengthString(periodoFactura.FechaInicioPagoVoluntario.Value.Month.ToString(), 2, '0', true, true);
                                        a�o = cAplicacion.FixedLengthString(periodoFactura.FechaInicioPagoVoluntario.Value.Year.ToString(), 4, '0', true, true).Substring(2, 2);

                                        fecLiquidacion = string.Concat(dia, mes, a�o);

                                        salida.Append(dia); // --> Fecha inicio pago voluntario, DD (d�a). 2 D�gitos
                                        salida.Append(mes); // --> Fecha inicio pago voluntario, MM (mes). 2 D�gitos
                                        salida.Append(a�o); // --> Fecha factura, AA (a�o). 2 D�gitos
                                    }
                                    else
                                    {
                                        dia = cAplicacion.FixedLengthString(factura.Fecha.Value.Day.ToString(), 2, '0', true, true);
                                        mes = cAplicacion.FixedLengthString(factura.Fecha.Value.Month.ToString(), 2, '0', true, true);
                                        a�o = cAplicacion.FixedLengthString(factura.Fecha.Value.Year.ToString(), 4, '0', true, true).Substring(2, 2);

                                        //Fecha emisi�n factura es la fecha de inicio de pago Voluntaria. 6 D�gitos
                                        salida.Append(dia); // --> Fecha factura, DD (d�a). 2 D�gitos
                                        salida.Append(mes); // --> Fecha factura, MM (mes). 2 D�gitos
                                        salida.Append(a�o); // --> Fecha factura, AA (a�o). 2 D�gitos
                                    }
                                }

                                // A(6)FECHA FIN VOLUNTARIA DDMMYY
                                respuesta = cParametroBL.GetInteger("DIAS_PAGO_VOLUNTARIO", out diasPagoVoluntario);
                                if (respuesta.Resultado == ResultadoProceso.OK)
                                {
                                    //Si en el periodo est� establecida una fecha de fin de periodo voluntario se usa esa
                                    if (periodoFactura.FechaFinPagoVoluntario.HasValue)
                                    {
                                        dia = cAplicacion.FixedLengthString(periodoFactura.FechaFinPagoVoluntario.Value.Day.ToString(), 2, '0', true, true);
                                        mes = cAplicacion.FixedLengthString(periodoFactura.FechaFinPagoVoluntario.Value.Month.ToString(), 2, '0', true, true);
                                        a�o = cAplicacion.FixedLengthString(periodoFactura.FechaFinPagoVoluntario.Value.Year.ToString(), 4, '0', true, true).Substring(2, 2);

                                        salida.Append(dia); // --> Fecha inicio pago voluntario, DD (d�a). 2 D�gitos
                                        salida.Append(mes); // --> Fecha inicio pago voluntario, MM (mes). 2 D�gitos
                                        salida.Append(a�o); // --> Fecha inicio pago voluntario, AA (a�o). 2 D�gitos
                                    }
                                    else //Sino se suman los d�as de pago voluntario a la fecha de factura
                                    {
                                        dia = cAplicacion.FixedLengthString(factura.Fecha.Value.AddDays(Convert.ToDouble(diasPagoVoluntario)).Day.ToString(), 2, '0', true, true);
                                        mes = cAplicacion.FixedLengthString(factura.Fecha.Value.AddDays(Convert.ToDouble(diasPagoVoluntario)).Month.ToString(), 2, '0', true, true);
                                        a�o = cAplicacion.FixedLengthString(factura.Fecha.Value.AddDays(Convert.ToDouble(diasPagoVoluntario)).Year.ToString(), 4, '0', true, true).Substring(2, 2);

                                        salida.Append(dia); // --> Fecha fin pago voluntario, DD (d�a). 2 D�gitos
                                        salida.Append(mes); // --> Fecha fin pago voluntario, MM (mes). 2 D�gitos
                                        salida.Append(a�o); // --> Fecha fin pago voluntario, AA (a�o). 2 D�gitos
                                    }
                                }

                                salida.Append(cAplicacion.FixedLengthString(strTitularNombre, 40, ' ', false, false)); // A(40) Contribuyente
                                salida.Append(cAplicacion.FixedLengthString(strTitularNif, 9, ' ', false, false)); // A(9) NIF

                                //Obtener inmueble para coger los datos Fiscales
                                contrato = factura.Contrato;
                                cContratoBL.ObtenerInmueble(ref contrato, out respuesta);

                                if (respuesta.Resultado == ResultadoProceso.OK)
                                {
                                    inmueble = contrato.InmuebleBO;
                                    //Obtener la calle
                                    respuesta = cInmuebleBL.ObtenerCalle(ref inmueble);
                                }
                                if (respuesta.Resultado == ResultadoProceso.OK)
                                {
                                    calle = inmueble.Calle;
                                    //Obtener Tipo de v�a para la sigla fiscal
                                    respuesta = cCalleBL.ObtenerTipoVia(ref calle);
                                }
                                //DOMICILIO A(38)
                                if (respuesta.Resultado == ResultadoProceso.OK)
                                {
                                    salida.Append(cAplicacion.FixedLengthString(calle.TipoVia.Abreviado, 2, ' ', false, false)); // --> Siglas_via. 2 D�gitos
                                    salida.Append(cAplicacion.FixedLengthString(inmueble.Direccion, 38, ' ', false, false)); // --> domicilio. 38 D�gitos

                                    respuesta = cInmuebleBL.ObtenerPoblacion(ref inmueble);
                                }
                                if (respuesta.Resultado == ResultadoProceso.OK)
                                {
                                    strPoblacion = inmueble.Poblacion.Descripcion;
                                    strCodigoPostal = inmueble.Poblacion.CodigoPostal;
                                    //Obtener provincia
                                    respuesta = cInmuebleBL.ObtenerProvincia(ref inmueble);
                                }
                                if (respuesta.Resultado == ResultadoProceso.OK)
                                {
                                    strProvincia = inmueble.Provincia.Descripcion;
                                }
                                if (respuesta.Resultado == ResultadoProceso.OK)
                                {
                                    salida.Append(cAplicacion.FixedLengthString(strPoblacion, 15, ' ', false, false));//Poblaci�n A(15)
                                    salida.Append(MUNICIPIO_INE);//C�DIGO DE MUNICIPIO N(3) C�digo de Municipio INE
                                    salida.Append(PROVINCIA_INE);//C�DIGO DE PROVINCIA N(2) C�digo de Provincia INE
                                    salida.Append(cAplicacion.FixedLengthString(String.IsNullOrEmpty(strCodigoPostal) ? contrato.TitularCpostal : strCodigoPostal, 5, '0', true, true)); //C�digo postal N(5)
                                }

                                salida.Append(cAplicacion.FixedLengthString(" ", 20, ' ', false, false));// Filler A(20)
                                salida.Append(cAplicacion.FixedLengthString("", 1, '0', true, true)); // Filler N(1)

                                salida.Append(cAplicacion.FixedLengthString(" ", 40, ' ', false, false));//A(40) C�nyuge
                                salida.Append(cAplicacion.FixedLengthString(" ", 9, ' ', false, false));// A(9) NIF c�nyuge

                                salida.Append(cAplicacion.FixedLengthString("", 6, '0', true, true)); // Filler N(6)

                                salida.Append(cAplicacion.FixedLengthString(string.Concat("Numero de abonado : ", factura.Contrato.Codigo.ToString()), 64, ' ', false, false));// A(64) Detalle: N�mero de abonado

                                salida.Append(cAplicacion.FixedLengthString(factura.ConsumoFactura.ToString() == "" ? string.Empty : string.Concat("m3 : ", factura.ConsumoFactura.ToString()), 64, ' ', false, false));// Otrasinf (m�tros c�bicos facturados) A(64)
                                salida.Append(cAplicacion.FixedLengthString(" ", 78, ' ', false, false));// otrasinf2 A(78)                            
                                salida.Append(cAplicacion.FixedLengthString("", 4, '0', true, true)); // num_lote N(4)
                                salida.Append(cAplicacion.FixedLengthString(" ", 1, ' ', false, false));// Filler A(1)

                                salida.Append(cAplicacion.FixedLengthString(fecLiquidacion, 6, '0', true, true)); // fecLiquidacion N(6) puede coincidir con inicio vol
                                salida.Append(cAplicacion.FixedLengthString(string.Concat(factura.PeriodoCodigo.Substring(5, 1), "B"), 2, ' ', false, false)); //Periodo A(2)

                                salida.Append(cAplicacion.FixedLengthString("", 6, '0', true, true)); // Filler N(6)

                                salida.Append(cAplicacion.FixedLengthString(" ", 40, ' ', false, false));// Representante A(40)
                                salida.Append(cAplicacion.FixedLengthString(" ", 2, ' ', false, false));// siglas_repres A(2)
                                salida.Append(cAplicacion.FixedLengthString(" ", 38, ' ', false, false));// domi_repres A(38)
                                salida.Append(cAplicacion.FixedLengthString(" ", 15, ' ', false, false));// pobla_repres A(15)
                                salida.Append(cAplicacion.FixedLengthString("", 3, '0', true, true)); // mun_repres N(3)
                                salida.Append(cAplicacion.FixedLengthString("", 2, '0', true, true)); // prov_repres N(2)
                                salida.Append(cAplicacion.FixedLengthString("", 5, '0', true, true)); // postal_repres N(5)
                                salida.Append(cAplicacion.FixedLengthString("", 9, '0', true, true)); // Impentrega N(9)
                                salida.Append(cAplicacion.FixedLengthString("", 6, '0', true, true)); // fechaingreso N(6)
                                salida.Append(cAplicacion.FixedLengthString("", 11, '0', true, true)); // Filler N(11)

                                salida.Append(saltoDeLinea);
                            }
                        }
                    }//fin del for

                    #endregion

                    #region Fichero Ayuntamiento Ribadesella (resto factura)

                    //----------------------
                    //Fichero impagos resto factura para Ayuntamiento Ribadesella
                    //----------------------

                    salida.Append(saltoDeLinea);
                    salida.Append("*FICHERO AYUNTAMIENTO RIBADESELLA (RESTO FACTURA)*"); // cabecera propia
                    salida.Append(saltoDeLinea);

                    //Recorro los apremiosTrab de la tabla de trabajo
                    for (int i = 0; respuesta.Resultado == ResultadoProceso.OK && i < apremiosTrab.Count; i++)
                    {
                        //Obtener la factura a la cual hace referencia el apremio
                        factura = new cFacturaBO();
                        factura.FacturaCodigo = apremiosTrab[i].FacturaCodigo;
                        factura.PeriodoCodigo = apremiosTrab[i].PeriodoCodigo;
                        factura.ContratoCodigo = apremiosTrab[i].ContratoCodigo;
                        factura.Version = apremiosTrab[i].FacturaVersion;

                        cFacturasBL.Obtener(ref factura, out respuesta);

                        cFacturasBL.ObtenerLineas(ref factura, out respuesta);

                        if (respuesta.Resultado == ResultadoProceso.OK && !factura.FechaContabilizacion.HasValue && contabilizar)
                            continue; // Si la factura no est� contabilizada no se procesa
                        if (respuesta.Resultado == ResultadoProceso.OK && factura.FechaFactRectificativa.HasValue)//Comprobamos si existe factura rectificativa
                            continue; //Si tiene fecha rectificativa quiere decir que se ha generado la rectificativa despu�s de realizar la selecci�n de los apremios a procesar. No se procesa el apremio                        
                        if (respuesta.Resultado == ResultadoProceso.OK) //Comprobamos si existen efectos pendientes a remesar y que no esten rechazados
                            existeEfectoPdte = cEfectosPendientesBL.Existe(factura.ContratoCodigo.Value, factura.PeriodoCodigo, factura.FacturaCodigo.Value, factura.SociedadCodigo.Value, false, false, out respuesta);
                        if (respuesta.Resultado == ResultadoProceso.OK && existeEfectoPdte) //Si existe efecto pendiente no se procesa el apremio
                            continue;
                        if (respuesta.Resultado == ResultadoProceso.OK)
                        {
                            apremio = new cApremioLinBO();
                            apremio.Numero = numeroApremioGenerado;
                            apremio.FechaGeneracion = fechaGeneracion;
                            apremio.UsuarioCodigo = apremiosTrab[i].UsuarioCodigo;
                            apremio.PeriodoCodigo = apremiosTrab[i].PeriodoCodigo;
                            apremio.ContratoCodigo = apremiosTrab[i].ContratoCodigo;
                            apremio.FacturaCodigo = apremiosTrab[i].FacturaCodigo;
                            apremio.FacturaVersion = apremiosTrab[i].FacturaVersion;

                            respuesta = cApremiosLinBL.Insertar(apremio);
                        }
                        if (respuesta.Resultado == ResultadoProceso.OK)
                        {
                            numeroApremioGenerado = apremio.Numero;
                            fechaGeneracion = apremio.FechaGeneracion;
                            cFacturasBL.ObtenerTotalFacturado(ref factura, fechaGeneracion.Value, out respuesta);
                        }
                        if (respuesta.Resultado == ResultadoProceso.OK)
                            cFacturasBL.ObtenerContrato(ref factura, out respuesta);


                        //Si estamos ejecutando en modo tarea...
                        //Puede que no inserte el cobro y debe realizarse una vez por cada iteraci�n
                        if (taskNumber.HasValue && taskType.HasValue && !String.IsNullOrEmpty(taskUser))
                        {
                            //Comprobar si se desea cancelar
                            if (cTaskManagerBL.CancelRequested(taskUser, taskType.Value, taskNumber.Value, out respuesta) && respuesta.Resultado == ResultadoProceso.OK)
                            {
                                apremiosProcesados = 0;
                                return String.Empty;
                            }
                            //Incrementar el n�mero de pasos
                            cTaskManagerBL.PerformStep(taskUser, taskType.Value, taskNumber.Value);
                        }

                        //----------------------
                        //Generaci�n del fichero Ribadesella
                        //----------------------
                        if (respuesta.Resultado == ResultadoProceso.OK)
                        {
                            strTitularNif = factura.Contrato.TitularDocIden;
                            strCCC = factura.Contrato.CodCueCli;
                            strTitularNombre = factura.Contrato.TitularNombre;

                            //S�lo escribo si tiene impago una factura con canon de saneamiento
                            //Obtener l�neas de la factura
                            cBindableList<cLineaFacturaBO> lineasFactura = new cBindableList<cLineaFacturaBO>(); //Lista vac�a, para evitar posibles referencias a nulo
                            if (respuesta.Resultado == ResultadoProceso.OK)
                            {
                                //lineasFactura = cFacturasBL.ObtenerLineas(ref factura, out respuesta);
                                lineasFactura = cFacturasBL.ObtenerLineasConDeuda(ref factura, out respuesta);
                                respuesta.Resultado = respuesta.Resultado == ResultadoProceso.SinRegistros ? ResultadoProceso.OK : respuesta.Resultado;
                            }

                            bool aguaInsertada = false;
                            decimal importeAguaFactura = 0;

                            //Recorrer l�neas de la factura 
                            for (int j = 0; j < lineasFactura.Count && respuesta.Resultado == ResultadoProceso.OK; j++)
                            {
                                cLineaFacturaBO linea = lineasFactura[j];
                                new cLineasFacturaBL().ObtenerServicio(ref linea, out respuesta);

                                if (respuesta.Resultado == ResultadoProceso.OK)
                                {
                                    bool lineaAgua = (linea.Servicio.Codigo == 1 || linea.Servicio.Codigo == 2 || linea.Servicio.Codigo == 5 || linea.Servicio.Codigo == 6);
                                    bool lineaCanon = (linea.Servicio.Codigo == 7 || linea.Servicio.Codigo == 9 || linea.Servicio.Codigo == 11 || linea.Servicio.Codigo == 12);

                                    if (lineaCanon)
                                        continue;

                                    if (lineaAgua && !aguaInsertada)
                                    {
                                        //Recorrer l�neas de la factura para acumular para el caso del agua, que ir� todo en una misma l�nea sumado
                                        for (int k = 0; k < lineasFactura.Count && respuesta.Resultado == ResultadoProceso.OK; k++)
                                        {
                                            cLineaFacturaBO lineaAux = lineasFactura[k];
                                            new cLineasFacturaBL().ObtenerServicio(ref lineaAux, out respuesta);

                                            if (respuesta.Resultado == ResultadoProceso.OK)
                                            {
                                                if (lineaAux.Servicio.Codigo == 1 || lineaAux.Servicio.Codigo == 2 || lineaAux.Servicio.Codigo == 5 || lineaAux.Servicio.Codigo == 6)
                                                {
                                                    importeAguaFactura += lineaAux.CBase;
                                                }
                                            }
                                        }
                                    }

                                    if (lineaAgua && aguaInsertada)
                                        continue;

                                    salida.Append(cAplicacion.FixedLengthString(((DateTime)factura.Fecha).Year.ToString().Substring(2, 2), 2, '0', true, true)); // N(2) Ejercicio
                                    salida.Append("056"); // N(3) entemisora
                                    salida.Append("056"); // N(3) ayuntamiento.

                                    salida.Append(cAplicacion.FixedLengthString(linea.CodigoServicio == 3 ? "123" : linea.CodigoServicio == 4 ? "124" : "225", 3, '0', true, true)); // N(3)
                                    salida.Append(cAplicacion.FixedLengthString(((DateTime)factura.Fecha).Year.ToString().Substring(2, 2), 2, '0', true, true)); // N(2) a�o de liquidaci�n del recibo

                                    // Factura
                                    salida.Append(cAplicacion.FixedLengthString(factura.Numero, 12, ' ', false, false)); // <> A(12) n�mero recibo
                                    salida.Append(cAplicacion.FixedLengthString(factura.ContratoCodigo.ToString(), 12, ' ', false, false)); // <> A(12) n�mero abonado

                                    string totfaclin = string.Empty;

                                    if (!lineaAgua)
                                    {
                                        totfaclin = cAplicacion.FixedLengthString(linea.CBase.ToString("N2").Replace(",", String.Empty).Replace(".", String.Empty), 9, '0', true, true);
                                    }
                                    else
                                    {
                                        totfaclin = cAplicacion.FixedLengthString(importeAguaFactura.ToString("N2").Replace(",", String.Empty).Replace(".", String.Empty), 9, '0', true, true);
                                        aguaInsertada = true;
                                    }

                                    salida.Append(cAplicacion.FixedLengthString(totfaclin.ToString(), 9, ' ', false, false)); // <> A(9) Importe

                                    // A(6)FECHA INICIO VOLUNTARIA DDMMYY
                                    cFacturasBL.ObtenerPeriodo(ref factura, out respuesta);
                                    periodoFactura = factura.Periodo;

                                    string dia = string.Empty, mes = string.Empty, a�o = string.Empty, fecLiquidacion = string.Empty;

                                    if (respuesta.Resultado == ResultadoProceso.OK && periodoFactura != null)
                                    {
                                        //Si en el periodo est� establecida una fecha de inicio de periodo voluntario se usa esa, en caso contrario se usa la fecha de factura
                                        if (periodoFactura.FechaInicioPagoVoluntario.HasValue)
                                        {
                                            //Fecha emisi�n factura es la fecha de inicio de pago Voluntaria. 8 D�gitos

                                            dia = cAplicacion.FixedLengthString(periodoFactura.FechaInicioPagoVoluntario.Value.Day.ToString(), 2, '0', true, true);
                                            mes = cAplicacion.FixedLengthString(periodoFactura.FechaInicioPagoVoluntario.Value.Month.ToString(), 2, '0', true, true);
                                            a�o = cAplicacion.FixedLengthString(periodoFactura.FechaInicioPagoVoluntario.Value.Year.ToString(), 4, '0', true, true).Substring(2, 2);

                                            fecLiquidacion = string.Concat(dia, mes, a�o);

                                            salida.Append(dia); // --> Fecha inicio pago voluntario, DD (d�a). 2 D�gitos
                                            salida.Append(mes); // --> Fecha inicio pago voluntario, MM (mes). 2 D�gitos
                                            salida.Append(a�o); // --> Fecha factura, AA (a�o). 2 D�gitos
                                        }
                                        else
                                        {
                                            dia = cAplicacion.FixedLengthString(factura.Fecha.Value.Day.ToString(), 2, '0', true, true);
                                            mes = cAplicacion.FixedLengthString(factura.Fecha.Value.Month.ToString(), 2, '0', true, true);
                                            a�o = cAplicacion.FixedLengthString(factura.Fecha.Value.Year.ToString(), 4, '0', true, true).Substring(2, 2);

                                            //Fecha emisi�n factura es la fecha de inicio de pago Voluntaria. 6 D�gitos
                                            salida.Append(dia); // --> Fecha factura, DD (d�a). 2 D�gitos
                                            salida.Append(mes); // --> Fecha factura, MM (mes). 2 D�gitos
                                            salida.Append(a�o); // --> Fecha factura, AA (a�o). 2 D�gitos
                                        }
                                    }

                                    // A(6)FECHA FIN VOLUNTARIA DDMMYY
                                    respuesta = cParametroBL.GetInteger("DIAS_PAGO_VOLUNTARIO", out diasPagoVoluntario);
                                    if (respuesta.Resultado == ResultadoProceso.OK)
                                    {
                                        //Si en el periodo est� establecida una fecha de fin de periodo voluntario se usa esa
                                        if (periodoFactura.FechaFinPagoVoluntario.HasValue)
                                        {
                                            dia = cAplicacion.FixedLengthString(periodoFactura.FechaFinPagoVoluntario.Value.Day.ToString(), 2, '0', true, true);
                                            mes = cAplicacion.FixedLengthString(periodoFactura.FechaFinPagoVoluntario.Value.Month.ToString(), 2, '0', true, true);
                                            a�o = cAplicacion.FixedLengthString(periodoFactura.FechaFinPagoVoluntario.Value.Year.ToString(), 4, '0', true, true).Substring(2, 2);

                                            salida.Append(dia); // --> Fecha inicio pago voluntario, DD (d�a). 2 D�gitos
                                            salida.Append(mes); // --> Fecha inicio pago voluntario, MM (mes). 2 D�gitos
                                            salida.Append(a�o); // --> Fecha inicio pago voluntario, AA (a�o). 2 D�gitos
                                        }
                                        else //Sino se suman los d�as de pago voluntario a la fecha de factura
                                        {
                                            dia = cAplicacion.FixedLengthString(factura.Fecha.Value.AddDays(Convert.ToDouble(diasPagoVoluntario)).Day.ToString(), 2, '0', true, true);
                                            mes = cAplicacion.FixedLengthString(factura.Fecha.Value.AddDays(Convert.ToDouble(diasPagoVoluntario)).Month.ToString(), 2, '0', true, true);
                                            a�o = cAplicacion.FixedLengthString(factura.Fecha.Value.AddDays(Convert.ToDouble(diasPagoVoluntario)).Year.ToString(), 4, '0', true, true).Substring(2, 2);

                                            salida.Append(dia); // --> Fecha fin pago voluntario, DD (d�a). 2 D�gitos
                                            salida.Append(mes); // --> Fecha fin pago voluntario, MM (mes). 2 D�gitos
                                            salida.Append(a�o); // --> Fecha fin pago voluntario, AA (a�o). 2 D�gitos
                                        }
                                    }

                                    salida.Append(cAplicacion.FixedLengthString(strTitularNombre, 40, ' ', false, false)); // A(40) Contribuyente
                                    salida.Append(cAplicacion.FixedLengthString(strTitularNif, 9, ' ', false, false)); // A(9) NIF

                                    //Obtener inmueble para coger los datos Fiscales
                                    contrato = factura.Contrato;
                                    cContratoBL.ObtenerInmueble(ref contrato, out respuesta);

                                    if (respuesta.Resultado == ResultadoProceso.OK)
                                    {
                                        inmueble = contrato.InmuebleBO;
                                        //Obtener la calle
                                        respuesta = cInmuebleBL.ObtenerCalle(ref inmueble);
                                    }
                                    if (respuesta.Resultado == ResultadoProceso.OK)
                                    {
                                        calle = inmueble.Calle;
                                        //Obtener Tipo de v�a para la sigla fiscal
                                        respuesta = cCalleBL.ObtenerTipoVia(ref calle);
                                    }
                                    //DOMICILIO A(38)
                                    if (respuesta.Resultado == ResultadoProceso.OK)
                                    {
                                        salida.Append(cAplicacion.FixedLengthString(calle.TipoVia.Abreviado, 2, ' ', false, false)); // --> Siglas_via. 2 D�gitos
                                        salida.Append(cAplicacion.FixedLengthString(inmueble.Direccion, 38, ' ', false, false)); // --> domicilio. 38 D�gitos

                                        respuesta = cInmuebleBL.ObtenerPoblacion(ref inmueble);
                                    }
                                    if (respuesta.Resultado == ResultadoProceso.OK)
                                    {
                                        strPoblacion = inmueble.Poblacion.Descripcion;
                                        strCodigoPostal = inmueble.Poblacion.CodigoPostal;
                                        //Obtener provincia
                                        respuesta = cInmuebleBL.ObtenerProvincia(ref inmueble);
                                    }
                                    if (respuesta.Resultado == ResultadoProceso.OK)
                                    {
                                        strProvincia = inmueble.Provincia.Descripcion;
                                    }
                                    if (respuesta.Resultado == ResultadoProceso.OK)
                                    {
                                        salida.Append(cAplicacion.FixedLengthString(strPoblacion, 15, ' ', false, false));//Poblaci�n A(15)
                                        salida.Append(MUNICIPIO_INE);//C�DIGO DE MUNICIPIO N(3) C�digo de Municipio INE
                                        salida.Append(PROVINCIA_INE);//C�DIGO DE PROVINCIA N(2) C�digo de Provincia INE
                                        salida.Append(cAplicacion.FixedLengthString(String.IsNullOrEmpty(strCodigoPostal) ? contrato.TitularCpostal : strCodigoPostal, 5, '0', true, true)); //C�digo postal N(5)
                                    }

                                    salida.Append(cAplicacion.FixedLengthString(" ", 20, ' ', false, false));// Filler A(20)
                                    salida.Append(cAplicacion.FixedLengthString("", 1, '0', true, true)); // Filler N(1)

                                    salida.Append(cAplicacion.FixedLengthString(" ", 40, ' ', false, false));//A(40) C�nyuge
                                    salida.Append(cAplicacion.FixedLengthString(" ", 9, ' ', false, false));// A(9) NIF c�nyuge

                                    salida.Append(cAplicacion.FixedLengthString("", 6, ' ', false, false)); // <> Filler A(6)

                                    salida.Append(cAplicacion.FixedLengthString(string.Concat("Numero de abonado : ", factura.Contrato.Codigo.ToString()), 64, ' ', false, false));// A(64) Detalle: N�mero de abonado

                                    salida.Append(cAplicacion.FixedLengthString(factura.ConsumoFactura.ToString() == "" ? string.Empty : string.Concat("m3 : ", factura.ConsumoFactura.ToString()), 64, ' ', false, false));// Otrasinf (m�tros c�bicos facturados) A(64)
                                    salida.Append(cAplicacion.FixedLengthString(" ", 78, ' ', false, false));// otrasinf2 A(78)                            
                                    salida.Append(cAplicacion.FixedLengthString("", 4, '0', true, true)); // num_lote N(4)
                                    salida.Append("C");// <> Filler A(1)

                                    salida.Append(cAplicacion.FixedLengthString(fecLiquidacion, 6, '0', true, true)); // fecLiquidacion N(6) puede coincidir con inicio vol
                                    salida.Append(cAplicacion.FixedLengthString(string.Concat(factura.PeriodoCodigo.Substring(5, 1), "B"), 2, ' ', false, false)); //Periodo A(2)

                                    salida.Append(cAplicacion.FixedLengthString("", 6, '0', true, true)); // Filler N(6)

                                    salida.Append(cAplicacion.FixedLengthString(" ", 40, ' ', false, false));// Representante A(40)
                                    salida.Append(cAplicacion.FixedLengthString(" ", 2, ' ', false, false));// siglas_repres A(2)
                                    salida.Append(cAplicacion.FixedLengthString(" ", 38, ' ', false, false));// domi_repres A(38)
                                    salida.Append(cAplicacion.FixedLengthString(" ", 15, ' ', false, false));// pobla_repres A(15)
                                    salida.Append(cAplicacion.FixedLengthString(" ", 3, ' ', false, false)); // <> mun_repres N(3)
                                    salida.Append(cAplicacion.FixedLengthString(" ", 2, ' ', false, false)); // <> prov_repres N(2)
                                    salida.Append(cAplicacion.FixedLengthString(" ", 5, ' ', false, false)); // <> postal_repres N(5)
                                    salida.Append(cAplicacion.FixedLengthString("", 9, '0', true, true)); // Impentrega N(9)
                                    salida.Append(cAplicacion.FixedLengthString("", 6, '0', true, true)); // fechaingreso N(6)

                                    salida.Append(cAplicacion.FixedLengthString(" ", 2, ' ', false, false)); // <> NEW Filler A(2)
                                    salida.Append(cAplicacion.FixedLengthString("", 9, '0', true, true)); // <> Filler N(9)

                                    salida.Append(saltoDeLinea);
                                }
                            }

                            //Si el fichero se ha realizado correctamente, se borra el apremio de la tabla de trabajo
                            if (respuesta.Resultado == ResultadoProceso.OK)
                                respuesta = Borrar(apremiosTrab[i]);

                            if (respuesta.Resultado == ResultadoProceso.OK)
                                apremiosProcesados++;

                        }
                    }//fin del for

                    #endregion

                    if (respuesta.Resultado == ResultadoProceso.OK)
                        scope.Complete();
                    else
                    {
                        apremiosProcesados = 0;
                        return String.Empty;
                    }
                } //Fin if(Respuesta.Resultado == OK)
            } //Fin TransactionScope

            //Solo se inserta en el log 
            if (respuesta.Resultado == ResultadoProceso.OK && apremiosProcesados > 0 && apremiosProcesados != apremiosTrab.Count)
                log = Resource.apremioXGeneradaConIncidencias.Replace("@apremio", numeroApremioGenerado.HasValue ? numeroApremioGenerado.Value.ToString() : String.Empty);
            if (respuesta.Resultado == ResultadoProceso.OK && apremiosProcesados == 0)
                log = Resource.errorApremiosNoProcesados;

            return salida.ToString();
        }
    }
}