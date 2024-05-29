using System.Collections.Generic;

namespace BO.Facturacion.Telelectura.Contazara
{
    public class cApiConfigurationBO
    {
        public string BaseUrl { get; }
        public string Username { get;}
        public string Password { get;}
        public string ClientId { get; }
        public string PointAuth { get; }
        public string PointSearch { get; }
        public string ApiVersion { get; }

        //Constructor por parametros
        public cApiConfigurationBO(string baseUrl, string username, string password, string clientId, string pointAuth, string pointSearch, string apiVersion)
        {
            this.BaseUrl = baseUrl;
            this.Username = username;
            this.Password = password;
            this.ClientId = clientId;
            this.PointAuth = pointAuth;
            this.PointSearch = pointSearch;
            this.ApiVersion = apiVersion;
        }

        public Dictionary<string, string> AuthCollection
        {
            get
            {
                return new Dictionary<string, string>
                {
                    { "username", this.Username },
                    { "password", this.Password },
                    { "client_id", this.ClientId },
                    { "grant_type", "password" }
                };
            }
        }

        public string EndPointAuthorization
        {
            get { return $"{this.BaseUrl}{this.PointAuth}"; }
        }

        public string EndPointSearch
        {
            get { return $"{this.BaseUrl}{this.ApiVersion}{this.PointSearch}"; }
        }

        public string SearchPageBaseUrl
        {
            get { return $"{this.BaseUrl}{this.ApiVersion}"; }
        }
    }
}
