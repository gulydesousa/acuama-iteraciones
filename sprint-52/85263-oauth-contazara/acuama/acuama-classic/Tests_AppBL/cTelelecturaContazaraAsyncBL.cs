
using Moq;
using BL.Facturacion;
using BusinessObject = BO.Facturacion.Telelectura.Contazara;
using BO.Facturacion;

namespace ContazaraTests;

public class cTelelecturaContazaraAsyncBLTests
{
    [Fact]
    public async Task ConexionContazara_RequestAsync()
    {
        // Arrange
        var configMock = new Mock<IApiConfiguration>();
        configMock.Setup(x => x.GetApiConfiguration())
                             .Returns(new BusinessObject.cApiConfigurationBO(
                                 "https://api.contazara.es", 
                                 "api_sacyr", 
                                 "e9okA/DwQuagsvSX,8", 
                                 "service-iot-api", 
                                 "/auth/realms/cz-iot-platform/protocol/openid-connect/token", 
                                 "/meters/readings/search",
                                 "/api/2019-06-01"));

        cTelelecturaContazaraAsyncBL.apiConfigurator = configMock.Object;


        // Busqueda por defecto
        var requestParams = new BusinessObject.cRequestSearchBO();
        Root result = await cTelelecturaContazaraAsyncBL.GetLecturasContazaraAsync(requestParams);
        //Pagina NEXT
        Root result2 = await cTelelecturaContazaraAsyncBL.GetLecturasContazaraAsync(result.metadata.next);
        //Pagina NEXT NEXT
        Root result3 = await cTelelecturaContazaraAsyncBL.GetLecturasContazaraAsync(result2.metadata.next);

        // Caducar el token
        cTelelecturaContazaraAsyncBL.AUTH_Response.expires_in=10;
        await Task.Delay(15000);
        Root result4 = await cTelelecturaContazaraAsyncBL.GetLecturasContazaraAsync(result3.metadata.next);
    }

    [Fact]
    public void ConexionContazara_Request()
    {
        // Arrange
        var configMock = new Mock<IApiConfiguration>();
        configMock.Setup(x => x.GetApiConfiguration())
                             .Returns(new BusinessObject.cApiConfigurationBO(
                                 "https://api.contazara.es",
                                 "api_sacyr",
                                 "e9okA/DwQuagsvSX,8",
                                 "service-iot-api",
                                 "/auth/realms/cz-iot-platform/protocol/openid-connect/token",
                                 "/meters/readings/search",
                                 "/api/2019-06-01"));

        cTelelecturaContazaraAsyncBL.apiConfigurator = configMock.Object;

        // Busqueda por defecto
        var requestParams = new BusinessObject.cRequestSearchBO();
        Root result =  cTelelecturaContazaraAsyncBL.GetLecturasContazara(requestParams);
        //Pagina NEXT
        Root result2 =  cTelelecturaContazaraAsyncBL.GetLecturasContazara(result.metadata.next);
        //Pagina NEXT NEXT
        Root result3 =  cTelelecturaContazaraAsyncBL.GetLecturasContazara(result2.metadata.next);

        // Caducar el token
        cTelelecturaContazaraAsyncBL.AUTH_Response.expires_in = 10;
        
        Task.Delay(15000);
        Root result4 =  cTelelecturaContazaraAsyncBL.GetLecturasContazara(result3.metadata.next);
    }

    [Fact]
    public void ConexionContazara_RequestLoop()
    {
        // Arrange
        var configMock = new Mock<IApiConfiguration>();
        configMock.Setup(x => x.GetApiConfiguration())
                             .Returns(new BusinessObject.cApiConfigurationBO(
                                 "https://api.contazara.es",
                                 "api_sacyr",
                                 "e9okA/DwQuagsvSX,8",
                                 "service-iot-api",
                                 "/auth/realms/cz-iot-platform/protocol/openid-connect/token",
                                 "/meters/readings/search",
                                 "/api/2019-06-01"));

        cTelelecturaContazaraAsyncBL.apiConfigurator = configMock.Object;

        // Busqueda por defecto  
         Root result = cTelelecturaContazaraAsyncBL.GetLecturasContazara(string.Empty);
        
        //Iterar en todas las paginas
        while (!string.IsNullOrEmpty(result.metadata.next))
        {
            result = cTelelecturaContazaraAsyncBL.GetLecturasContazara(result.metadata.next);

            if (result.metadata.page % 5 == 0)
            {
                // Caducar el token
                cTelelecturaContazaraAsyncBL.AUTH_Response.expires_in = 2;
                Task.Delay(3000).Wait();
            }
        }

    }

}
