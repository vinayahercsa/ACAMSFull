public class HttpRetryDummy {
    private static final Integer MAX_RETRY_ATTEMPTS = 3;
    private static final Integer MAX_TIMEOUT_MILLISECONDS = 3000;
    
    public static HttpResponse sendRequest(String url, String method, String body) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod(method);
        request.setBody(body);
        request.setTimeout(MAX_TIMEOUT_MILLISECONDS);
        
        return sendRequestWithRetry(request);
    }
    
    private static HttpResponse sendRequestWithRetry(HttpRequest request) {
        Integer retryCount = 0;
        HttpResponse response = null;
        
        while (retryCount < MAX_RETRY_ATTEMPTS) {
            try {
                Http http = new Http();
                response = http.send(request);
                
                if (response.getStatusCode() == 200) {
                    break;
                }
            } catch (Exception e) {
                System.debug('Exception during HTTP callout: ' + e.getMessage());
            }
            
            retryCount++;
            
            if (retryCount < MAX_RETRY_ATTEMPTS) {
                Integer waitTimeMilliseconds = 1000;
                Long currentTimeMillis = Datetime.now().getTime();
                Long retryTimeMillis = currentTimeMillis + waitTimeMilliseconds;
                
                while (Datetime.now().getTime() < retryTimeMillis) {
                }
            }
        }
        
        return response;
    }
}