@IsTest
global class ACAMSAddressValidationServiceMockError implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
                '<soapenv:Header/><soapenv:Body>' +
                '<VertexEnvelope xmlns="urn:vertexinc:o-series:tps:9:0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
                '<Login><TrustedId>$tr.BcTQ05Ym</TrustedId></Login><FindTaxAreasResponse><TaxAreaLookupResult><LookupException>' +
                '<ExceptionType>com.vertexinc.taxgis.common.idomain.VertexInvalidAddressException</ExceptionType>' +
                '<RootCause>No tax areas were found during the lookup. The address fields are inconsistent for the specified asOfDate. (Street Information=415 MISSION STREET, Street Information 2=null, Postal Code=null, City=SNFERERO, Sub Division=null, Main Division=null, Country=USA, As Of Date=20200114) Failed to cleanse address. (fault code=E101, fault code text=Last line is bad or missing.)</RootCause>' +
                '</LookupException></TaxAreaLookupResult></FindTaxAreasResponse><ApplicationData><ResponseTimeMS>49.1</ResponseTimeMS>' +
                '</ApplicationData></VertexEnvelope></soapenv:Body> </soapenv:Envelope>');
        res.setStatusCode(400);
        return res;
    }
}