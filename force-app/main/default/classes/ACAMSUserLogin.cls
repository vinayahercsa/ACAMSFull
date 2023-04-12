@RestResource(UrlMapping='/api/user/login')
global with sharing class ACAMSUserLogin {

    @HttpPost
    global static LoginResponse login(String username, String password, String domain) {

        LoginResponse objResponse = new LoginResponse();

        try {
            String loginXML = '<?xml version="1.0" encoding="utf-8"?>';
            loginXML += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:enterprise.soap.sforce.com">';
            loginXML += '<soapenv:Header>';
            loginXML += '<urn:LoginScopeHeader>';
            loginXML += '<urn:organizationId>' + UserInfo.getOrganizationId() + '</urn:organizationId>';
            loginXML += '</urn:LoginScopeHeader>';
            loginXML += '</soapenv:Header>';
            loginXML += '<soapenv:Body>';
            loginXML += '<urn:login>';
            loginXML += '<urn:username>' + username + '</urn:username>';
            loginXML += '<urn:password>' + password + '</urn:password>';
            loginXML += '</urn:login>';
            loginXML += '</soapenv:Body>';
            loginXML += '</soapenv:Envelope>';

            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://' + domain + '.salesforce.com/services/Soap/c/44.0');
            request.setTimeout(60000);
            request.setMethod('POST');
            request.setHeader('SOAPAction', 'login');
            request.setHeader('Accept', 'text/xml');
            request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
            request.setBody(loginXML);
            HttpResponse response = new Http().send(request);

            String responseBody = response.getBody();
            String sessionId = UserInfo.getSessionId(); // Removed getValueFromXMLString(responseBody, 'sessionId') due to session id error when logging into a community.
            String userId = getValueFromXMLString(responseBody, 'userId');

            if (response.getStatusCode() == 200) {
                objResponse.statusCode = response.getStatusCode();
                objResponse.statusMessage = response.getStatus();
                objResponse.isSuccess = true;
            } else {
                objResponse.statusCode = 401;
                objResponse.statusMessage = getValueFromXMLString(responseBody, 'sf:exceptionMessage');
                objResponse.isSuccess = false;
            }

            objResponse.sessionId = sessionId;
            objResponse.userId = userId;

        } catch (System.Exception ex) {
            objResponse.isSuccess = false;
            objResponse.statusMessage = ex.getMessage();
        }
        return objResponse;

    }

    public static String getValueFromXMLString(String xmlString, String keyField) {
        String xmlKeyValue = '';
        if (xmlString.contains('<' + keyField + '>')) {
            try {
                xmlKeyValue = xmlString.substring(xmlString.indexOf('<' + keyField + '>') + keyField.length() + 2, xmlString.indexOf('</' + keyField + '>'));
            } catch (Exception e) {

            }
        }
        return xmlKeyValue;
    }

    global class LoginResponse {
        public String sessionId { get; set; }
        public String userId { get; set; }
        public Boolean isSuccess { get; set; }
        public String statusMessage { get; set; }
        public Integer statusCode { get; set; }
    }

}