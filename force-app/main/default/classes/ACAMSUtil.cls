//csa fix changed the class as without sharing to resolve the exception.
public without sharing class ACAMSUtil {
    /** Utility class for static string constants and utility methods */

    /* STRING CONSTANTS */
    public static final String ACAMS_TODAY = 'ACAMS Today';
    public static final String ACCOUNT_RECORD_TYPE_BUSINESS = 'Business_Account';
    public static final String ACCOUNT_RECORD_TYPE_PERSON = 'PersonAccount';
    public static final String ACH_CAPS = 'ACH';
    public static final String ACTIVE = 'Active';
    public static final String ADVANCED = 'Advanced';
    public static final String ASYNCHRONOUS = 'Asynchronous';
    public static final String ATTENDANCE = 'Attendance';
    public static final String AUTHORIZATION = 'authorization';
    public static final String AUTO = 'auto';
    public static final String B2B_COMMERCE_USER_PROFILE = 'B2B Storefront Registered Login Users acams';
    public static final String BUNDLE = 'Bundle';
    public static final String CAMS = 'CAMS';
    public static final String CANCELLED = 'Cancelled';
    public static final String CAPTURE = 'capture';
    public static final String CC = 'Credit Card';
    public static final String CERTIFICATE_COURSES = 'Certificate Courses';
    public static final String CERTIFICATES = 'Certificates';
    public static final String CERTIFICATION = 'Certification';
    public static final String CGSS = 'CGSS';
    public static final String CHAPTER = 'Chapter';
    public static final String CHECK = 'Check';
    public static final String CLOSED = 'Closed';
    public static final String COMPLETED = 'Completed';
    public static final String CONFERENCES = 'Conferences';
    public static final String CREDIT = 'CREDIT';
    public static final String CREDIT_TYPE_REFUND = 'Refund';
    public static final String CSR_ZERO_DOLLAR = 'CSR Zero Dollar';
    public static final String CSR_PROFILE = 'ACAMS - Customer Service';
    public static final String CUSTOM_TRAINING = 'Custom Training';
    public static final String CUSTOMER = 'Customer';
    public static final String DIGITAL = 'DIGITAL';
    public static final String ENTERPRISE_CAPS = 'ENTERPRISE';
    public static final String ENTERPRISE_BUNDLE = 'Enterprise Bundle';
    public static final String EVENT = 'Event';
    public static final String EVENTS = 'Events';
    public static final String EXAM_PREP = 'Exam Prep';
    public static final String FACE_TO_FACE = 'Face to Face';
    public static final String INACTIVE = 'Inactive';
    public static final String INDUSTRY_GOV_ENFORCEMENT = 'Government - Enforcement';
    public static final String INDUSTRY_GOV_REGULATORY = 'Government - Regulatory';
    public static final String IN_PROCESS = 'In Process';
    public static final String INVOICE = 'Invoice';
    public static final String INVOICED = 'Invoiced';
    public static final String KIT = 'Kit';
    public static final String DYNAMIC_KIT = 'Dynamic Kit';
    public static final String AGGREGATED = 'Aggregated';
    public static final String MAJOR = 'Major';
    public static final String MEMBER_CAPS = 'MEMBER';
    public static final String MEMBERSHIP = 'Membership';
    public static final String MINOR = 'Minor';
    public static final String MONEYLAUNDERINGDOTCOM = 'Moneylaundering.com';
    public static final String NO_UPGRADE_MSG = 'You have not previously enrolled in the lower tier product.';
    public static final String NON_MEMBER_CAPS = 'NON-MEMBER';
    public static final String ON_HOLD = 'On Hold';
    public static final String ORDER_ITEM_STATUS_REFUNDED_CREDIT = 'Refunded - Credit';
    public static final String ORDER_NUMBER_START = '1000000'; // TODO: Change to correct value
    public static final String ORDER_STATUS_REFUNDED_CREDIT = 'Refunded - Credit';
    public static final String ORDER_SUBMITTED = 'Order Submitted';
    public static final String PARTNERSHIPS = 'Partnerships';
    public static final String PAYMENT = 'Payment';
    public static final String PHONE_NUMBER_FORMAT_ERROR = 'Phone number format is incorrect';
    public static final String PHYSICAL = 'PHYSICAL';
    public static final String PO = 'po';
    public static final String PORTAL_ACCOUNT = 'Private/Non-Member';
    public static final String PORTAL_ACCOUNT_CHAPTER_MEMBER = 'Private Chapter Member';
    public static final String PORTAL_ACCOUNT_GOV = 'Government/Non-Member';
    public static final String PORTAL_ACCOUNT_GOV_CHAPTER_MEMBER = 'Government Chapter Member';
    public static final String PORTAL_ACCOUNT_MEMBER = 'Private/Member';
    public static final String PORTAL_ACCOUNT_GOV_MEMBER = 'Government/Member';
    public static final String PREREQUISITE_MSG = 'You have not carted or purchased the prerequisite product(s).';
    public static final String PRICELIST_PUBLIC_NON_MEMBER = 'Government/Non-Member';
    public static final String PRICELIST_PUBLIC_MEMBER = 'Government/Member';
    public static final String PRICELIST_PRIVATE_NON_MEMBER = 'Private/Non-Member';
    public static final String PRICELIST_PRIVATE_MEMBER = 'Private/Member';
    public static final String PRINTED_SUBSCRIPTION = 'Printed Subscription';
    public static final String PUBLICATIONS = 'Publications';
    public static final String RELEASED = 'RELEASED';
    public static final String REPLACE_PRODUCT_MSG = 'Previously carted product was replaced by the now displayed product.';
    public static final String REFUNDED = 'Refunded';
    public static final String REFUNDED_CREDIT_ORDER = 'Refunded Credit Order';
    public static final String REFUNDED_ORDER = 'Refunded Order';
    public static final String REGIME_EXAM = 'Regime Exam';
    public static final String SALES_PROFILE = 'ACAMS - Sales';
    public static final String SEMINARS = 'Seminars';
    public static final String SHIPPING_PRODUCT_SKU = 'SHPCST';
    public static final String SPONSORSHIP = 'Sponsorship';
    public static final String TRAINING = 'Training';
    public static final String USER_EMAIL = 'userEmail';
    public static final String VIRTUAL_CLASSROOM = 'Virtual Classroom';
    public static final String WEBINARS = 'Webinars';
    public static final String WIRE_TRANSFER = 'Wire Transfer';
    public static final String WT_CAPS = 'WT';
    public static final String ZERO_DOLLAR_API = 'zero_dollar';
    public static final String ZERO_DOLLAR = 'Zero Dollar';

    // This variable is used to bypass validating potentially invalid migrated phone numbers when updating
    // entitlement statuses on Person Accounts
    public static Boolean bypassPhoneValidation = false;

    public class UpdateObject implements Queueable {
        List<SObject> toUpdate;

        public UpdateObject(List<SObject> toUpdate) {
            this.toUpdate = toUpdate;
        }

        public void execute(QueueableContext context) {
            try {
                update toUpdate;
            } catch (Exception e) {
                //csa fix added exception logger statement. 
            ACAMSUtil.reportException(null, null,'UpdateObject Method', null, e.getMessage(), null, null);
            }
        }
    }
    
    //CalloutFromFutureTrigger - Not ideal but needed to meet the existing setup of ACAMS flow - FSA-950
    
    public class LMSCalloutRequest implements Queueable, Database.AllowsCallouts {
        HttpRequest req;
        Boolean SHASignature;
        String serviceName;
        String body ;

        public LMSCalloutRequest(HttpRequest req, String serviceName, String json_string) {
            this.req = req;
            this.serviceName = serviceName;
            body = json_string;
        }
        public LMSCalloutRequest(Boolean SHASignature, String serviceName, String json_string) {
            this.SHASignature = SHASignature;
            this.serviceName = serviceName;
            body = json_string;
        } 

        public void execute(QueueableContext context) {
            try {
              HTTPRequest req = CalloutUtility.makeRequest(serviceName, SHASignature, body);
              
              HTTPResponse res = CalloutUtility.sendRequest(req); //FSA-2455
              System.debug('*****CalloutUtility.SendRequest.res.getBody(): ' + res.getBody());
              System.debug('*****CalloutUtility.SendRequest.res.getStatus(): ' + res.getStatus());
              System.debug('*****CalloutUtility.SendRequest.res.getStatusCode(): ' + res.getStatusCode());            
              
              if(res != null){
                  if(res.getStatus() != 'OK' || res.getStatusCode() != 200 || !res.getBody().contains('200')){
                  //ACAMSUtil.reportException(res.getStatus(), res.getStatusCode(), ServiceName, body,  res.getBody(), body.substringBetween('contactId":"', '"}]'), body.substringBetween('"id":"', '",') );
                                    ACAMSUtil.reportException(res.getStatus(), res.getStatusCode(), ServiceName, body,  res.getBody(), body.substringBetween('contactId":"', '"}]'),null );

                  }
                  CallOutUtility.updateLMSEnrollmentFromRes(res,body);//FSA-2455
              }
          }
          catch(Exception ex){
               ACAMSUtil.reportException(null, null, ServiceName, body,  ex.getMessage(), null , null);
          }        
       }
    }
    public class InsertObject implements Queueable {
        List<SObject> toInsert;

        public InsertObject(List<SObject> toInsert) {
            this.toInsert = toInsert;
        }

        public void execute(QueueableContext context) {
            try {
                insert toInsert;
            } catch (Exception e) {
                 //csa fix added exception logger statement. 
            ACAMSUtil.reportException(null, null,'InsertObject Method', null, e.getMessage(), null, null);
            }
        }
    }

    public class UpdateObjectChainJob implements Queueable {
        List<SObject> toUpdateFirst;
        List<SObject> toUpdateSecond;

        public UpdateObjectChainJob(List<SObject> toUpdateFirst, List<SObject> toUpdateSecond) {
            this.toUpdateFirst = toUpdateFirst;
            this.toUpdateSecond = toUpdateSecond;
        }

        public void execute(QueueableContext context) {
            try {
                update toUpdateFirst;
                System.enqueueJob(new ACAMSUtil.UpdateObject(toUpdateSecond));
            } catch (Exception e) {
                 //csa fix added exception logger statement. 
            ACAMSUtil.reportException(null, null,'UpdateObjectChainJob Method', null, e.getMessage(), null, null);
            }
        }
    }

    public static String getISO3Country(String country) {
        List<String> countrySettings = new List<String>();
        for (CountrySettings__mdt countrySetting : [
                SELECT IsoCode_3__c
                FROM CountrySettings__mdt
                WHERE IsoCode_2__c = :country
        ]) {
            countrySettings.add(countrySetting.IsoCode_3__c);
        }

        if (countrySettings != null) {
            return countrySettings[0];
        }
        return '';
    }

    public static String getPhonecode(String country) {
        List<String> countrySettings = new List<String>();
        for (CountrySettings__mdt countrySetting : [
                SELECT PhoneCode__c
                FROM CountrySettings__mdt
                WHERE IsoCode_2__c = :country
        ]) {
            countrySettings.add(countrySetting.PhoneCode__c);
        }

        if (countrySettings != null) {
            return countrySettings[0];
        }
        return '';

    }

    public static String getISO2DigitState(String state) {
        List<StateSettings__mdt> stateSettings = [
                SELECT IsoCode__c
                FROM StateSettings__mdt
                WHERE MasterLabel = :state
                LIMIT 1
        ];

        if (!stateSettings.isEmpty()) {
            return stateSettings[0].IsoCode__c;
        } else {
            stateSettings = [
                    SELECT IsoCode__c
                    FROM StateSettings__mdt
                    WHERE IsoCode__c = :state
                    LIMIT 1
            ];
            if (!stateSettings.isEmpty()) {
                return stateSettings[0].IsoCode__c;
            }
        }
        return '';
    }
    
    public static void reportException(String status, Integer statusCode, String Type, String requestBody, String exceptionOccured, String accountId, String enrollmentId) {
        try{
        // CSA-fix - commented as the exception record will be inserted from platform event
        /*Exception__c ex = new Exception__c();
        ex.Response_Status__c = status;
        ex.Response_Status_Code__c = statusCode;
        ex.Type__c = Type;
        ex.Exception__c = exceptionOccured;
        ex.Request_Body__c = requestBody;
        ex.Account__c = accountId;
        ex.BeckerLMS_Enrollment__c   = enrollmentId;
        system.debug('current user'+UserInfo.getUserId());
        insert ex;*/
            list<Exception_Logger__e> exePlatformEvents = new list<Exception_Logger__e>();

            Exception_Logger__e excpLogger = new Exception_Logger__e();
            excpLogger.Response_Status__c = status;
            excpLogger.Response_Status_Code__c = statusCode;
            excpLogger.Type__c = Type;
            excpLogger.Exception__c = exceptionOccured;
            excpLogger.Request_Body__c = requestBody;
            excpLogger.Account_Id__c = accountId;
            excpLogger.BeckerLMS_Enrollment_Id__c = enrollmentId;
            exePlatformEvents.add(excpLogger);

            List<Database.SaveResult> results = EventBus.publish(exePlatformEvents);
            
            // Inspect publishing result for each event
            //csa fix not performing anything.
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    System.debug('Successfully published event.');
                } else {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Error returned: ' +
                                    err.getStatusCode() +
                                    ' - ' +
                                    err.getMessage());
                    }
                }       
            }

        }
        catch (Exception e) {
            ACAMSUtil.reportException(null, null,'reportException Method', null, e.getMessage(), null, null);
            }
        
    }

    public static Pattern getPhoneFormattingPattern() {
        String regex = '^\\+(?:[0-9][- ]?){6,14}[0-9]$';
        return Pattern.compile(regex);
    }

    public static String getLanguageByCode(String langCode) {
        switch on langCode {
            when 'en_US' {
                return 'English';
            }
            when 'de' {
                return 'German';
            }
            when 'zh_CN' {
                return 'Simplified Chinese';
            }
            when 'zh_TW' {
                return 'Traditional Chinese';
            }
            when 'fr' {
                return 'French';
            }
            when 'ja' {
                return 'Japanese';
            }
            when 'pl' {
                return 'Polish';
            }
            when 'pt_BR' {
                return 'Portuguese';
            }
            when 'es' {
                return 'Spanish';
            }
            when 'ru' {
                return 'Russian';
            }
            when else {
                return 'English';
            }
        }
    }

    public static String getIsoCodeFromCountryName(String countryName) {
        CountrySettings__mdt metaData = [
                SELECT
                        Id,
                        Isocode__c
                FROM
                        CountrySettings__mdt
                WHERE
                        MasterLabel = :countryName
        ];

        return metaData.Isocode__c;
    }

    public static List<String> getMetadataFromStateName(String stateName, String countryName) {
        try {
            StateSettings__mdt metaData = [
                    SELECT
                            Id,
                            IsoCode__c,
                            Integration_Value__c
                    FROM
                            StateSettings__mdt
                    WHERE
                    MasterLabel = :stateName
                    AND
                    (Country__r.MasterLabel = :countryName
                    OR
                    Country__r.Isocode__c = :countryName)
                    LIMIT 1
            ];
            return new List<String>{
                    metaData.IsoCode__c, metaData.Integration_Value__c
            };
        } catch (System.QueryException e) {
            return new List<String>{
                    null, null
            };
        }
    }
    // FSA-950 and FSA-875
    public static Boolean canAddQueueableJob(){
      return (Limits.getLimitQueueableJobs()- Limits.getQueueableJobs())>0 ? true:false;
    }    
}