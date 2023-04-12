@isTest
public class wsPearsonvueComPingWsdlTest {

    class wsPearsonvueComPingWsdlMock implements WebServiceMock {
        public void doInvoke(
                Object stub,
                Object request,
                Map<String, Object> response,
                String endpoint,
                String soapAction,
                String requestName,
                String responseNS,
                String responseName,
                String responseType
        ) {
            if (request instanceof wsPearsonvueComPingSchema.pingRequestType) {
                response.put('response_x', new wsPearsonvueComPingSchema.pingResponseType());
            }
            return;
        }
    }

    @isTest
    static void coverWsPearsonvueComPingWsdlWsdl() {
        wsPearsonvueComPingWsdl.PingSOAPPort pd = new wsPearsonvueComPingWsdl.PingSOAPPort();
        Test.setMock(WebServiceMock.class, new wsPearsonvueComPingWsdlMock());
        pd.pingDatabase();
        pd.pingService();
    }

}