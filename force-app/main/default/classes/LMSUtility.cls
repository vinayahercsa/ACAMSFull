/*
 * Class Name: LMSUtility - Utility class for LMS Integration
 * 5/2/2017           mmurphy               Created class.
*/

public class LMSUtility {
    public class LMSUserRequest {
        public Id contactId;
        public String username;
        public String firstName;
        public String lastName;
        public String timezone;
        public String language;
        public String role;
        public String customerType;
        public String memberExpireDate;
        public String premiumWebinarSubscriberExpirationDate;
        public Boolean premiumWebinarSubscriber;
        public Boolean enabled;
    }

    public class LMSCreateEnrollmentRequest {
        public Id id;
        public String name;
        public String lmsCourseId;
        public String startDate;
        public String endDate;
        public String completionDate;
        public String purchaseDate;
        public Id enrolleeId;
    }
    
     public class LMSMergeRequest {
     
        public Id contactId;
        public String username;
        public String firstName;
        public String lastName;
        public Boolean master;
        
    }
     public class LMSMergeRequestList {
        public List<LMSUtility.LMSMergeRequest> MergeAccounts=new List<LMSUtility.LMSMergeRequest>();
        
        
    }
    
     public class EnrollmentMergeRequest {
     
        public Id contactId;
        public String username;
        public String subscriptionId;
        public String purchaseDate;
        public Boolean master;
        
    }
     public class EnrollmentMergeRequestList {
       public List<LMSUtility.EnrollmentMergeRequest> MergeSubscriptionEnrollmentProgress=new List<LMSUtility.EnrollmentMergeRequest>();
        
        
    }

    public class LMSUpdateEnrollmentRequest {
        public Id id;
        public String endDate;
        public String completionDate;
        public String status;
        public String purchaseDate; //FSA-2464
        public String startDate;  // FSA-2464
    }
     public class AcamsOrgClone {
      public  String clientId;
      public String clientSecret;
      public  String usernameOldAcams;
      public  String passwordOldAcams;
    }
   

    public static String BuildJson(List<LMSUserRequest> lmsUserRequest){
        String json_string = JSON.serialize(lmsUserRequest);
        System.debug('*****LMSUtility.BuildJson.json_string: ' + json_string);
        return json_string;
    }

    public static String BuildJson(List<LMSCreateEnrollmentRequest> lmsCreateEnrollmentRequest){
        String json_string = JSON.serialize(lmsCreateEnrollmentRequest);
        System.debug('*****LMSUtility.BuildJson.json_string: ' + json_string);
        return json_string;
    }

    public static String BuildJson(List<LMSUpdateEnrollmentRequest> lmsUpdateEnrollmentRequest){
        String json_string = JSON.serialize(lmsUpdateEnrollmentRequest);
        System.debug('*****LMSUtility.BuildJson.json_string: ' + json_string);
        return json_string;
    }
}