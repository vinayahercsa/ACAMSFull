@isTest
global class SAPSalesforceIntegrationMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        return res;
    }
}