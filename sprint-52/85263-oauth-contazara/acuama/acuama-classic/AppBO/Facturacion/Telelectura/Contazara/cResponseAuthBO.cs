using System;
using System.Collections.Generic;
/*
 El API de autenticación parece estar utilizando el protocolo OAuth 2.0, que es un estándar de la industria para la autorización. 
1.	Tu aplicación envía una solicitud de autenticación al servidor de autenticación. 
    Esta solicitud incluye el nombre de usuario y la contraseña, así como información sobre tu aplicación (como el client_id).
2.	El servidor de autenticación verifica la solicitud. 
    Si el nombre de usuario y la contraseña son correctos, y la aplicación tiene permiso para acceder, el servidor genera un token de acceso.
3.	El servidor de autenticación envía una respuesta que incluye el token de acceso. 
    Esta respuesta puede tener el formato de la clase AuthenticationResponse que proporcionaste.
4.	Tu aplicación recibe la respuesta y extrae el token de acceso. 
    Este token se utiliza para autenticar las solicitudes futuras que tu aplicación hace al servidor.

En tu clase AuthenticationResponse, los campos representan lo siguiente:
•	access_token: Este es el token de acceso que tu aplicación debe incluir en las solicitudes futuras para autenticarse.
•	expires_in: Este es el tiempo, en segundos, hasta que el token de acceso expire.
•	refresh_expires_in: Este es el tiempo, en segundos, hasta que el token de actualización expire.
•	refresh_token: Este es el token de actualización que tu aplicación puede usar para obtener un nuevo token de acceso cuando el actual expire.
•	token_type: Este es el tipo de token que se ha emitido. Normalmente, este valor es "Bearer".
•	not-before-policy: Este es el tiempo, en segundos, antes del cual el token no debe ser aceptado para su procesamiento.
•	session_state: Este es un identificador único para la sesión.
•	scope: Este es el alcance del token, que especifica los recursos y operaciones que están permitidos para este token.
 
 
 */

namespace BO.Facturacion.Telelectura.Contazara
{
    /// <summary>
    /// Clase que representa la respuesta de autenticación de Telelectura Contazara.
    /// </summary>
    public class cResponseAuthBO
    {
        public DateTime initDate { get; set; }

        /// <summary>
        /// Obtiene o establece el token de acceso.
        /// </summary>
        public string access_token { get; set; }

        /// <summary>
        /// Obtiene o establece el tiempo de expiración del token en segundos.
        /// </summary>
        public int expires_in { get; set; } = 0;

        /// <summary>
        /// Obtiene o establece el tiempo de expiración del token de actualización en segundos.
        /// </summary>
        public int refresh_expires_in { get; set; } = 0;

        /// <summary>
        /// Obtiene o establece el token de actualización.
        /// </summary>
        public string refresh_token { get; set; }

        /// <summary>
        /// Obtiene o establece el tipo de token.
        /// </summary>
        public string token_type { get; set; }

        /// <summary>
        /// Obtiene o establece el tiempo de inicio de la política de no antes en segundos.
        /// </summary>
        public int not_before_policy { get; set; }

        /// <summary>
        /// Obtiene o establece el estado de la sesión.
        /// </summary>
        public string session_state { get; set; }

        /// <summary>
        /// Obtiene o establece el ámbito del token.
        /// </summary>
        public string scope { get; set; }

        public cResponseAuthBO()
        {
            initDate = DateTime.UtcNow;
        }

        public bool TokenHasExpired
        {
            get
            {
                return DateTime.UtcNow >= initDate.AddSeconds(this.expires_in);
            }
        }

        public Dictionary<string, string> RefreshCollection (string clientId)
        {
           
            return new Dictionary<string, string>
            {
                { "refresh_token", this.refresh_token },
                { "grant_type", "refresh_token" },
                { "client_id", clientId }
            };           
        }
    }
}
