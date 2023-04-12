public class ACAMSCeregoService {

    private static String ceregoUrl = 'https://cerego.com/api/v3/courses/';
    private static String ceregoUsersUrl = '/users';

    @Future(Callout=true)
    public static void ceregoProductCall(Set<String> ceregoIds, String ceregoUsername, String ceregoEmail, Id orderId) {
        List<Case> cases = new List<Case>();
        for (String id : ceregoIds) {
            performCeregoProductCallout(id, ceregoUsername, ceregoEmail, orderId, cases);
        }
        insert cases;
    }

    public static HttpResponse performCeregoProductCallout(String id, String ceregoUsername, String ceregoEmail, Id orderId, List<Case> cases) {
        String bearerToken = getBearerToken();
        Http http = new Http();

        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(ceregoUrl + id + ceregoUsersUrl);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + bearerToken);
        req.setBody(generateJsonBody(ceregoUsername, ceregoEmail));
        HttpResponse res = http.send(req);

        if (res.getStatusCode() != 200) {
            Case newCase = new Case(
                    Subject = 'Cerego Integration Failed',
                    CC_Order__c = orderId,
                    Description = 'Cerego Integration Failed with error code: ' + res.getStatusCode()
            );
            cases.add(newCase);
        }
        return res;
    }

    private static String generateJsonBody(String ceregoUsername, String ceregoEmail) {
        return '{"email": "' + ceregoEmail + '", "name": "' + ceregoUsername + '"}';
    }

    private static String getBearerToken() {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint('callout:cerego');
        HttpResponse res = new HttpResponse();
        res = http.send(req);

        ACAMSCeregoDTO acamsCeregoDTO = ACAMSCeregoDTO.parse(res.getBody());

        try {
            return acamsCeregoDTO.data.get(0).attributes.token;
        } catch (NullPointerException e) {
            System.debug('No token data received from server');
        }
        return null;
    }

}