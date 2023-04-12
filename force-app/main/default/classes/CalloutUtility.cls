public class CalloutUtility {
    public static string secretKey;
    public static String baseurl = '';
    public static String method = '';
    public static String endPoint = '';
    public static Integer timeOut = 120000;
    public static String body = '';
    public class customException extends Exception {}

    private static String generateHMACToken(String input){
        Blob Signature = Crypto.generateMac('HmacSHA1', Blob.ValueOf(input), Blob.ValueOf(secretKey));
        String hmac = EncodingUtil.urlEncode(EncodingUtil.base64encode(Signature), 'UTF-8').replaceAll('\\r\\n', '');
        return hmac;
    }
    //FSA-950
    public static void SendRequest(String serviceName, Boolean SHASignature, String json_string) {
       if (Trigger.isExecuting && !System.isFuture() && !System.isBatch()){
             SendRequestFuture(serviceName, SHASignature, json_string);
        } else {//if(!Trigger.isExecuting && (System.isFuture() || System.isBatch())){
          if(ACAMSUtil.canAddQueueableJob()){
            SendRequestInQueue(serviceName, SHASignature, json_string);
          }      
        } 
    }

    //*** Async Callouts ***// //Made private to public
    @Future(callout=true)
    public static void SendRequestFuture(String serviceName, Boolean SHASignature, String body) {
        try{
          HTTPRequest req = makeRequest(serviceName, SHASignature, body);

           HTTPResponse res = sendRequest(req); //FSA-2455

            System.debug('*****CalloutUtility.SendRequest.res.getBody(): ' + res.getBody());
            System.debug('*****CalloutUtility.SendRequest.res.getStatus(): ' + res.getStatus());
            System.debug('*****CalloutUtility.SendRequest.res.getStatusCode(): ' + res.getStatusCode());
            
            if(res != null){
                if(res.getStatus() != 'OK' || res.getStatusCode() != 200 || !res.getBody().contains('200')){
               ACAMSUtil.reportException(res.getStatus(), res.getStatusCode(), ServiceName, body,  res.getBody(), body.substringBetween('contactId":"', '"}]'), null );
                
                }
                 updateLMSEnrollmentFromRes(res,body);//FSA-2455
            }
        }
        catch(Exception ex){
             ACAMSUtil.reportException(null, null, ServiceName, body,  ex.getMessage(), null , null);
        }   
    }
    public static HTTPResponse sendRequest(HTTPRequest req){ //FSA-2455
      Http http = new Http();
        HTTPResponse res = http.send(req);
      return res;
    } //FSA-2455
    
    public static void updateLMSEnrollmentFromRes(HTTPResponse res,string body){ //FSA-2455
      if(res!=null && body != null){
        List<Object> listOfEnrollments = (List<Object>)JSON.deserializeUntyped(body);
        List<BeckerLMS_Enrollment__c> LmsListToUpdate = new List<BeckerLMS_Enrollment__c>();
        for(Object o : listOfEnrollments ){
          Map<String, Object> resultMap = (Map<String, Object>)o;
          system.debug('resultMap::'+resultMap);
          String LMSid = (String)resultMap.get('id');
            if(LMSid !=null){
                BeckerLMS_Enrollment__c be = new BeckerLMS_Enrollment__c();
                be.id=LMSid;
                be.Response_status__c=res.getStatus();
                be.Status_code__c=String.valueOf(res.getStatusCode());
                be.Time_stamp__c=DateTime.now();
                be.Created_LMS__c = false;
                be.Updated_LMS__c = false;
                LmsListToUpdate.add(be);
            }
         
        }
       if(LmsListToUpdate.size() > 0){
            try{
                update LmsListToUpdate;
            }catch(Exception ex){
                ACAMSUtil.reportException(null, null,'updateLMSEnrollmentFromRes Method', null, ex.getMessage(), null, null);
            }
      }
    }
    
    } //FSA-2455
    
    
    private static void SendRequestInQueue(String serviceName, Boolean SHASignature, String body) {
      //HTTPRequest req = makeRequest(serviceName, SHASignature, body);
        //System.enqueueJob(new ACAMSUtil.LMSCalloutRequest(req,serviceName, body));
        System.enqueueJob(new ACAMSUtil.LMSCalloutRequest(SHASignature,serviceName, body));
        
    }
    
    public static HTTPRequest makeRequest(String serviceName, Boolean SHASignature, String json_string){

            Map<String, Global_Variable__c> global_variableMap = Global_Variable__c.getAll();
            HttpRequest req = new HttpRequest();
            req.setHeader('Content-Encoding', 'UTF-8');
            req.setHeader('Content-type', 'application/json');
            body = json_string;
            req.setBody(body);

            if (SHASignature){
                secretKey = global_variableMap.get('LMS.SecretKey').Value__c;
                String ts = String.Valueof(dateTime.now().getTime()/1000);
               if (ServiceName == 'UserIntegration'){
                    timeOut = Integer.valueOf(global_variableMap.get('LMS.UserIntegration.TimeOut').Value__c);
                    method = global_variableMap.get('LMS.UserIntegration.Method').Value__c;
                    baseurl = String.format(global_variableMap.get('LMS.UserIntegration.Endpoint').Value__c, new String[]{ts});
                    endPoint = global_variableMap.get('LMS.Server').Value__c + baseurl + '/' + generateHMACToken(baseurl);
                }
                else if (ServiceName.contains('EnrollmentIntegration')){
                    timeOut = Integer.valueOf(global_variableMap.get('LMS.EnrollmentIntegration.TimeOut').Value__c);
                    method = (ServiceName.StartsWith('Create') ? global_variableMap.get('LMS.EnrollmentIntegration.C.Method').Value__c : global_variableMap.get('LMS.EnrollmentIntegration.U.Method').Value__c)   ;
                    baseurl = String.format(global_variableMap.get('LMS.EnrollmentIntegration.Endpoint').Value__c, new String[]{ts});
                    endPoint = global_variableMap.get('LMS.Server').Value__c + baseurl + '/' + generateHMACToken(baseurl);
                }
               else if (ServiceName.contains('AccountMergeIntegration')){
                    timeOut = Integer.valueOf(global_variableMap.get('LMS.UserIntegration.TimeOut').Value__c);
                    method = global_variableMap.get('LMS.UserIntegration.Method').Value__c;
                    baseurl = String.format(global_variableMap.get('LMS.AccountMergeIntegration.Endpoint').Value__c, new String[]{ts});
                    endPoint = global_variableMap.get('LMS.Server').Value__c + baseurl + '/' + generateHMACToken(baseurl);
                }  
                 else if (ServiceName.contains('EnrollmentMergeIntegration')){
                    timeOut = Integer.valueOf(global_variableMap.get('LMS.UserIntegration.TimeOut').Value__c);
                    method = global_variableMap.get('LMS.UserIntegration.Method').Value__c;
                    baseurl = String.format(global_variableMap.get('LMS.EnrlmntMergeIntegration.Endpoint').Value__c, new String[]{ts});
                    endPoint = global_variableMap.get('LMS.Server').Value__c + baseurl + '/' + generateHMACToken(baseurl);
                }
            } else {
                //Callouts not using SHASignature
            }

            req.setMethod(method);
            req.setTimeout(timeOut);
            req.setEndpoint(endpoint);
			return req;  
    }
        

    
     @Future(callout=true)
    public static void SendRequestMerge(String serviceName, Boolean SHASignature, String json_string,String masterIDmerge, String cntIDmerge, String usernamemerge) {
       
        try{
            Map<String, Global_Variable__c> global_variableMap = Global_Variable__c.getAll();
            HttpRequest req = new HttpRequest();
            req.setHeader('Content-Encoding', 'UTF-8');
            req.setHeader('Content-type', 'application/json');
            body = json_string;
            req.setBody(body);

            if (SHASignature){
                secretKey = global_variableMap.get('LMS.SecretKey').Value__c;
                String ts = String.Valueof(dateTime.now().getTime()/1000);
               
              if (ServiceName.contains('AccountMergeIntegration')){
                    timeOut = Integer.valueOf(global_variableMap.get('LMS.UserIntegration.TimeOut').Value__c);
                    method = global_variableMap.get('LMS.UserIntegration.Method').Value__c;
                    baseurl = String.format(global_variableMap.get('LMS.AccountMergeIntegration.Endpoint').Value__c, new String[]{ts});
                    endPoint = global_variableMap.get('LMS.Server').Value__c + baseurl + '/' + generateHMACToken(baseurl);
                }  
                 
            } else {
                //Callouts not using SHASignature
            }

            req.setMethod(method);
            req.setTimeout(timeOut);
            req.setEndpoint(endpoint);

            Http http = new Http();
            HTTPResponse res = http.send(req);
               if(res.getStatus() == 'OK' && res.getStatusCode() == 200){
                Account cnt;
                cnt = [select id,Merge_Status__c,Old_Contact_Id__c,Old_Contact_Username__c from Account where id=: masterIDmerge limit 1];
                if(cnt != null){
                    cnt.Merge_Status__c = true;
                    cnt.Old_Contact_Id__c=cntIDmerge;
                    cnt.Old_Contact_Username__c=usernamemerge;
                    update cnt;
                }
                
            }
        if(res != null){
            if(res.getStatus() != 'OK' || res.getStatusCode() != 200 || !res.getBody().contains('200')){
                ACAMSUtil.reportException(res.getStatus(), res.getStatusCode(), ServiceName, body,  res.getBody(),  null , null  );
            }
            }
        
        }
        catch(Exception ex){
            ACAMSUtil.reportException(null, null, ServiceName, body,  ex.getMessage(), null, null);
        }
        
    }
    
    

    //*** END - Async Callouts ***//

    //*** Webinar Integration ***//
    public class Response {
        String startDate;
        String endDate;
        List<AsyncEnrollmentJSON> status;
    }
    public class AsyncEnrollmentJSON {
        public String id;
        public Id lmsEnrollmentId;
        public Id enrollee;
        public String lmsCourseId;
        public Date startDate;
        public Date endDate;
        public Date completionDate;
        public Date purchaseDate;
        public Boolean selfEnrolled;
        public Id parentLMSEnrollmentId;
        public Integer webinarViewTime;
        public Integer recordingViewTime;
        public String status;
        public Integer score;
    }

    public static List<AsyncEnrollmentJSON> GetWebinarEnrollments() {
        List<AsyncEnrollmentJSON> webinars = new List<AsyncEnrollmentJSON>();
        try{
            Map<String, Global_Variable__c> global_variableMap = Global_Variable__c.getAll();
            Global_Variable__c gvStartDate = global_variableMap.get('LMS.WebinarIntegration.StartDate');
            HttpRequest req = new HttpRequest();
            req.setHeader('Content-Encoding', 'UTF-8');
            req.setHeader('Content-type', 'application/json');
            secretKey = global_variableMap.get('LMS.SecretKey').Value__c;
            String ts = String.Valueof(dateTime.now().getTime()/1000);
           timeOut = Integer.valueOf(global_variableMap.get('LMS.WebinarIntegration.TimeOut').Value__c);
            baseurl = String.format(global_variableMap.get('LMS.WebinarIntegration.Endpoint').Value__c, new String[]{ts});
            String since = ( String.isNotBlank(gvStartDate.Value__c) && gvStartDate.Value__c != 'NA' ? '?q=' + gvStartDate.Value__c : '' );
            endPoint = global_variableMap.get('LMS.Server').Value__c + baseurl + '/' + generateHMACToken(baseurl) + since;

            req.setMethod('GET');
            req.setTimeout(timeOut);
            req.setEndpoint(endpoint);

            Http http = new Http();
            HTTPResponse res = (!Test.isRunningTest() ? http.send(req) : FakeGetWebinarsResponse());

           
          Response r = (Response)JSON.deserialize(res.getBody(), Response.class);
           System.debug('*****CalloutUtility.GetWebinarEnrollments.r: ' + r);
          /*  String jsonsString = '{"startDate":"2017-10-20T17:29:00Z", "endDate":"2017-10-27T11:08:46Z", "status": [{"id":"C-1164","lmsEnrollmentId": null,"parentLMSEnrollmentId": null,"enrollee": "0010m00000ekj52","lmsCourseId": "418/418","startDate": "2017-11-11","endDate": "2018-05-11","purchaseDate": "2017-11-11","selfEnrolled": false,"webinarViewTime": 239,"recordingViewTime": 0,"status": "Completed","score": 90}]}';
            r = (Response)JSON.deserialize(jsonsString, Response.class); */

            if (r != null && r.status.size() > 0){
                webinars = r.status;
                if (r.endDate != NULL){
                    gvStartDate.Value__c = r.endDate;
                    update gvStartDate;
                }
            }

            if (Test.isRunningTest()) throw new customException('Testing code');
        }
        catch(Exception ex){
            ACAMSUtil.reportException(null, null, 'GetWebinarEnrollments', body,  ex.getMessage(), null, null);

        }
        return webinars;
    }

    private static HTTPResponse FakeGetWebinarsResponse() {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        List<BeckerLMS_Enrollment__c> e = [SELECT Id FROM BeckerLMS_Enrollment__c LIMIT 2];
        AsyncEnrollmentJSON w = new AsyncEnrollmentJSON();
        w.lmsEnrollmentId = e[0].Id;
        w.webinarViewTime = 90;
        w.recordingViewTime = 100;
        w.status = 'Completed';
        w.score = 100;
     //   w.parentLMSEnrollmentId = e[1].Id;
        w.lmsCourseId = '1/1';
        
        AsyncEnrollmentJSON w1 = new AsyncEnrollmentJSON();
        w1.Id = '123';
        w1.webinarViewTime = 90;
        w.recordingViewTime = 100;
        w1.status = 'Completed';
        w1.score = 100;
        w1.lmsCourseId = '1/1';

        Response r = new Response();
        r.status = new List<AsyncEnrollmentJSON>{w,w1};
        r.startDate = '2019-01-01T17:29:00Z';
        r.endDate = '2019-02-03T11:08:46Z';
        res.setBody(JSON.serialize(r));
        res.setStatusCode(200);
        return res;
    }

    //*** END - Webinar Integration ***//

}