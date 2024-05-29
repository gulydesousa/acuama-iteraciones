using BO.Facturacion;
using System.Collections.Generic;
using System.Net.Http;
using System;
using System.Threading.Tasks;
using Newtonsoft.Json;
using BL.Sistema;
using BO.Comun;
using BO.Sistema;
using System.Linq;
using BusinessObject = BO.Facturacion.Telelectura.Contazara;
using System.Net;


namespace BL.Facturacion
{
    public interface IApiConfiguration
    {
        BusinessObject.cApiConfigurationBO GetApiConfiguration();
    }


    /// <summary>
    /// Clase para obtener la configuración de la API de telelectura de contadores Contazara.
    /// </summary>
    public class cTelelecturaConfiguration : IApiConfiguration
    {
        /// <summary>
        /// Obtiene la configuración de la API desde los parametros de BBDD.
        /// </summary>
        public Dictionary<string, string> SelectApiConfiguration()
        {
            cRespuesta cRespuesta = new cRespuesta();
            Dictionary<string, string> result = new Dictionary<string, string>();

            cBindableList<cParametroBO> contazaraValues =
            cParametroBL.ObtenerPorFiltro("WHERE pgsclave LIKE 'CONTAZARA%'", out cRespuesta);

            if (cRespuesta.EsResultadoCorrecto)
            {
                result = contazaraValues.ToDictionary(param => param.Clave, param => param.Valor);
            }

            return result;
        }

        /// <summary>
        /// Asigna las propiedades de la conexion con la API de Contazara.
        /// </summary>
        public BusinessObject.cApiConfigurationBO GetApiConfiguration()
        {
            Dictionary<string, string> contazaraValues;
            contazaraValues = SelectApiConfiguration();

            var result = new BusinessObject.cApiConfigurationBO(contazaraValues["CONTAZARA_BASEURL"],
                                                              contazaraValues["CONTAZARA_USERNAME"],
                                                              contazaraValues["CONTAZARA_PASSWORD"],
                                                              contazaraValues["CONTAZARA_CLIENTID"],
                                                              contazaraValues["CONTAZARA_POINT_AUTH"],
                                                              contazaraValues["CONTAZARA_POINT_SEARCH"],
                                                              contazaraValues["CONTAZARA_API_VERSION"]);

            return result;
        }
    }

    /// <summary>
    /// Clase que contiene métodos sincronos y  asincronos para la telelectura de contadores Contazara.
    /// </summary>
    public static class cTelelecturaContazaraApiConBL
    {
        #region STATIC PROPERTIES

        /// <summary>
        /// Implementacion usada para obtener la configuración de la API.
        /// </summary>
        public static IApiConfiguration apiConfigurator { get; set; }

        /// <summary>
        /// Existe un token de autenticación válido.
        /// </summary>
        private static bool isInitialized = false;

        /// <summary>
        /// Respuesta de autenticación.
        /// </summary>
        public static BusinessObject.cResponseAuthBO AUTH_Response { get; set; }

        /// <summary>
        /// Configuración de la api
        /// </summary>
        private static BusinessObject.cApiConfigurationBO API_Configuration { get; set; }

        #endregion STATIC PROPERTIES

        #region constructor

        /// <summary>
        /// Este metodo se ejecuta al cargar la clase. Hace la configuración de la API.
        /// </summary>
        static cTelelecturaContazaraApiConBL()
        {
            ServicePointManager.ServerCertificateValidationCallback = delegate { return true; };

            if (apiConfigurator == null)
            {
                //Establecer el protocolo de seguridad
                //You can specify the version of the SSL/TLS protocol to use for your requests.
                ////For example, if your server requires TLS 1.2, you can specify this in your application
                ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
                apiConfigurator = new cTelelecturaConfiguration();
                API_Configuration = apiConfigurator.GetApiConfiguration();
            }
        }

        #endregion constructor

        #region ConexionContazara

        /// <summary>
        /// La creación del objeto establece la conexión inicial (o la refresca en caso de ser necesario).
        /// </summary>
        /// <returns>Un valor booleano que indica si la telelectura se realizó correctamente.</returns>
        private static async Task<bool> ConexionContazaraAsync()
        {
            bool result = false;

            try
            {
                //Si no he ha inicializado o el token ha expirado
                if (!isInitialized || AUTH_Response.TokenHasExpired)
                {
                    if (!isInitialized)
                    {
                        AUTH_Response = await GetTokenAsync(API_Configuration);
                    }
                    else
                    {
                        await RefreshTokenAsync(AUTH_Response, API_Configuration);
                    }
                    isInitialized = true;
                }
                result = true;
            }
            catch
            {
                isInitialized = false;
            }
            finally
            {
                // Clean up resources
            }
            return result;
        }


        /// <summary>
        /// La creación del objeto establece la conexión inicial (o la refresca en caso de ser necesario).
        /// </summary>
        /// <returns>Un valor booleano que indica si la telelectura se realizó correctamente.</returns>
        private static bool ConexionContazara()
        {
            bool result = false;

            try
            {
                if (apiConfigurator == null)
                {
                    //Establecer el protocolo de seguridad
                    //You can specify the version of the SSL/TLS protocol to use for your requests.
                    ////For example, if your server requires TLS 1.2, you can specify this in your application
                    ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
                    apiConfigurator = new cTelelecturaConfiguration();
                }

                //Si no he ha inicializado o el token ha expirado
                if (!isInitialized || AUTH_Response.TokenHasExpired)
                {
                    if (!isInitialized)
                    {
                        AUTH_Response = GetToken(API_Configuration);
                    }
                    else
                    {
                        RefreshToken(AUTH_Response, API_Configuration);
                    }
                    isInitialized = true;
                }
                result = true;
            }
            catch
            {
                isInitialized = false;
            }
            finally
            {
                // Clean up resources
            }
            return result;
        }

        #endregion ConexionConzara

        #region GetToken

        /// <summary>
        /// Obtiene el token de autenticación para realizar la telelectura de contadores Contazara.
        /// </summary>
        /// <returns>El objeto que contiene la respuesta de autenticación.</returns>
        private static async Task<BusinessObject.cResponseAuthBO> GetTokenAsync(BusinessObject.cApiConfigurationBO apiConfig)
        {
            var response = new BusinessObject.cResponseAuthBO();

            var collection = apiConfig.AuthCollection;

            string result = await PostRequestAsync(apiConfig.EndPointAuthorization, collection);
            Console.WriteLine(result);

            JsonConvert.PopulateObject(result, response);
            return response;
        }


        /// <summary>
        /// Obtiene el token de autenticación para realizar la telelectura de contadores Contazara.
        /// </summary>
        /// <returns>El objeto que contiene la respuesta de autenticación.</returns>
        private static BusinessObject.cResponseAuthBO GetToken(BusinessObject.cApiConfigurationBO apiConfig)
        {
            var response = new BusinessObject.cResponseAuthBO();

            var collection = apiConfig.AuthCollection;

            string result = PostRequest(apiConfig.EndPointAuthorization, collection);
            Console.WriteLine(result);

            JsonConvert.PopulateObject(result, response);
            return response;
        }

        #endregion

        #region RefreshToken

        /// <summary>
        /// Actualiza el token de autenticación para realizar la telelectura de contadores Contazara.
        /// </summary>
        private static async Task RefreshTokenAsync(BusinessObject.cResponseAuthBO auth, BusinessObject.cApiConfigurationBO apiConfig)
        {
            auth.initDate = DateTime.UtcNow;

            Dictionary<string, string> refreshCollection = auth.RefreshCollection(apiConfig.ClientId);

            string result = await PostRequestAsync(apiConfig.EndPointAuthorization, refreshCollection);

            // Populate the existing authResponse object with the new token data
            JsonConvert.PopulateObject(result, AUTH_Response);
        }

        /// <summary>
        /// Actualiza el token de autenticación para realizar la telelectura de contadores Contazara.
        /// </summary>
        private static void RefreshToken(BusinessObject.cResponseAuthBO auth, BusinessObject.cApiConfigurationBO apiConfig)
        {
            auth.initDate = DateTime.UtcNow;

            Dictionary<string, string> refreshCollection = auth.RefreshCollection(apiConfig.ClientId);

            string result = PostRequest(apiConfig.EndPointAuthorization, refreshCollection);

            // Populate the existing authResponse object with the new token data
            JsonConvert.PopulateObject(result, AUTH_Response);
        }

        #endregion RefreshToken

        #region public.GetLecturasContazara

        /// <summary>
        /// Obtiene las lecturas de contadores Contazara con los valores configurados en el objeto  BO.Facturacion.Telelectura.Contazara.cRequestSearchBO.
        /// </summary>
        /// <param name="requestParams">Los parámetros de búsqueda para las lecturas.</param>
        /// <returns>El objeto que contiene las lecturas de contadores.</returns>
        public static async Task<Root> GetLecturasContazaraAsync(BusinessObject.cRequestSearchBO requestParams)
        {
            bool conexion = await ConexionContazaraAsync();
            if (!conexion) return null;

            string requestUri = $"{API_Configuration.EndPointSearch}{requestParams.ToString()}";

            var response = await GetRequestAsync(requestUri);

            Root rootLecturas = JsonConvert.DeserializeObject<Root>(response);

            return rootLecturas;
        }

        /// <summary>
        /// Obtiene las lecturas. 
        /// Si se omite el parametro o se envia un string en blanco se sacan las lecturas con la configuración por defecto en el objeto  BO.Facturacion.Telelectura.Contazara.cRequestSearchBO
        /// El string enviado por parametros debe corresponder con los parametros esperados por el servicio
        /// Ejemplo: /meters/readings/search?page=0&perPage=50&readType=offline&dateType=read_date&fromDate=20231215&toDate=20231216&plrType=1"
        /// </summary>
        /// <param name="searchPath">Parametros para la búsqueda. </param>
        /// <returns>Root</returns>
        public static async Task<Root> GetLecturasContazaraAsync(string searchPath = "")
        {
            string requestUri = string.Empty;

            bool conexion = await ConexionContazaraAsync();
            if (!conexion) return null;


            if (!string.IsNullOrEmpty(searchPath))
            {
                requestUri = $"{API_Configuration.SearchPageBaseUrl}{searchPath}";
            }
            else
            {
                var requestParams = new BusinessObject.cRequestSearchBO();
                requestUri = $"{API_Configuration.EndPointSearch}{requestParams.ToString()}";
            }

            var response = await GetRequestAsync(requestUri);

            Root rootLecturas = JsonConvert.DeserializeObject<Root>(response);

            return rootLecturas;
        }

        /// <summary>
        /// Obtiene las lecturas de contadores Contazara con los valores configurados en el objeto  BO.Facturacion.Telelectura.Contazara.cRequestSearchBO.
        /// </summary>
        /// <param name="requestParams">Los parámetros de búsqueda para las lecturas.</param>
        /// <returns>El objeto que contiene las lecturas de contadores.</returns>
        public static Root GetLecturasContazara(BusinessObject.cRequestSearchBO requestParams)
        {
            bool conexion = ConexionContazara();
            if (!conexion) return null;

            string requestUri = $"{API_Configuration.EndPointSearch}{requestParams.ToString()}";

            var response = GetRequest(requestUri);

            Root rootLecturas = JsonConvert.DeserializeObject<Root>(response);

            return rootLecturas;
        }

        /// <summary>
        /// Obtiene las lecturas. 
        /// Si se omite el parametro o se envia un string en blanco se sacan las lecturas con la configuración por defecto en el objeto  BO.Facturacion.Telelectura.Contazara.cRequestSearchBO
        /// El string enviado por parametros debe corresponder con los parametros esperados por el servicio
        /// Ejemplo: /meters/readings/search?page=0&perPage=50&readType=offline&dateType=read_date&fromDate=20231215&toDate=20231216&plrType=1"
        /// </summary>
        /// <param name="searchPath">Parametros para la búsqueda. </param>
        /// <returns>Root</returns>
        public static Root GetLecturasContazara(string searchPath = "")
        {
            string requestUri = string.Empty;

            bool conexion = ConexionContazara();
            if (!conexion) return null;


            if (!string.IsNullOrEmpty(searchPath))
            {
                requestUri = $"{API_Configuration.SearchPageBaseUrl}{searchPath}";
            }
            else
            {
                var requestParams = new BusinessObject.cRequestSearchBO();
                requestUri = $"{API_Configuration.EndPointSearch}{requestParams.ToString()}";
            }

            var response = GetRequest(requestUri);

            Root rootLecturas = JsonConvert.DeserializeObject<Root>(response);

            return rootLecturas;
        }

        #endregion public.GetLecturasContazara

        #region GET REQUEST        

        /// <summary>
        /// Realiza una solicitud GET asincrónica.
        /// </summary>
        /// <param name="requestUri">La URI de la solicitud.</param>
        /// <returns>La respuesta de la solicitud.</returns>
        private static async Task<string> GetRequestAsync(string requestUri)
        {
            using (var client = new HttpClient())
            {
                var request = new HttpRequestMessage(HttpMethod.Get, requestUri);
                request.Headers.Add("Authorization", $"Bearer {AUTH_Response.access_token}");
                var response = await client.SendAsync(request);
                response.EnsureSuccessStatusCode();
                return await response.Content.ReadAsStringAsync();
            }
        }


        /// <summary>
        /// Realiza una solicitud GET sincrónica.
        /// </summary>
        /// <param name="requestUri">La URI de la solicitud.</param>
        /// <returns>La respuesta de la solicitud.</returns>
        private static string GetRequest(string requestUri)
        {
            using (var client = new HttpClient())
            {
                var request = new HttpRequestMessage(HttpMethod.Get, requestUri);
                request.Headers.Add("Authorization", $"Bearer {AUTH_Response.access_token}");
                var response = client.SendAsync(request).Result;
                response.EnsureSuccessStatusCode();
                return response.Content.ReadAsStringAsync().Result;
            }
        }


        #endregion GET REQUEST

        #region POST REQUEST
        /// <summary>
        /// Realiza una solicitud POST asincrona.
        /// </summary>
        /// <param name="requestUri">La URI de la solicitud.</param>
        /// <param name="data">Los datos de la solicitud.</param>
        /// <returns>La respuesta de la solicitud.</returns>
        private static async Task<string> PostRequestAsync(string requestUri, Dictionary<string, string> data)
        {
            try
            {
                using (var client = new HttpClient())
                {
                    var request = new HttpRequestMessage(HttpMethod.Post, requestUri);
                    request.Headers.Add("ContentType", "application/x-www-form-urlencoded");

                    var content = new FormUrlEncodedContent(data);
                    request.Content = content;
                    var response = await client.SendAsync(request);
                    response.EnsureSuccessStatusCode();
                    var responseBody = await response.Content.ReadAsStringAsync();
                    return responseBody;
                }
            }
            catch (Exception ex)
            {
                // Handle the exception here
                Console.WriteLine($"An error occurred during the POST request: {ex.Message}");
                throw; // Rethrow the exception to propagate it to the caller
            }
        }


        /// <summary>
        /// Realiza una solicitud POST sincrona.
        /// </summary>
        /// <param name="requestUri">La URI de la solicitud.</param>
        /// <param name="data">Los datos de la solicitud.</param>
        /// <returns>La respuesta de la solicitud.</returns>
        private static string PostRequest(string requestUri, Dictionary<string, string> data)
        {
            try
            {
                using (var client = new HttpClient())
                {
                    var request = new HttpRequestMessage(HttpMethod.Post, requestUri);
                    request.Headers.Add("ContentType", "application/x-www-form-urlencoded");

                    var content = new FormUrlEncodedContent(data);
                    request.Content = content;
                    var response = client.SendAsync(request).Result;
                    response.EnsureSuccessStatusCode();
                    var responseBody = response.Content.ReadAsStringAsync().Result;
                    return responseBody;
                }
            }
            catch (Exception ex)
            {
                // Handle the exception here
                Console.WriteLine($"An error occurred during the POST request: {ex.Message}");
                throw; // Rethrow the exception to propagate it to the caller
            }
        }

        #endregion POST REQUEST

    }
}
