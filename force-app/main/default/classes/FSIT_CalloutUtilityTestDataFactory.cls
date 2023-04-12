@isTest
public with sharing class FSIT_CalloutUtilityTestDataFactory {
    public FSIT_CalloutUtilityTestDataFactory() {

    }

    public static List<Global_Variable__c> createGlobalVariable() {
        List<Global_Variable__c> globalRecords = new List<Global_Variable__c>();
        Global_Variable__c lmsAccountMergeIntegrationEndpoint = new Global_Variable__c(Name='LMS.AccountMergeIntegration.Endpoint',Value__c='/integration/users/merge/{0}',ACAMS_Migrated__c=false);
        Global_Variable__c lmsAccountMergeIntegrationMethod = new Global_Variable__c(Name='LMS.AccountMergeIntegration.Method', Value__c='POST',ACAMS_Migrated__c=false);
        Global_Variable__c lmsAccountMergeIntegrationTimeout = new Global_Variable__c(Name='LMS.AccountMergeIntegration.TimeOut', Value__c='120000',ACAMS_Migrated__c=false);
        Global_Variable__c lmsAppServer = new Global_Variable__c(Name='LMS.APP.Server', Value__c='https://lmsacams-qa.becker.com',ACAMS_Migrated__c=true);
        Global_Variable__c lmsUserInegrationMethod = new Global_Variable__c(Name='LMS.UserIntegration.Method', Value__c='POST',ACAMS_Migrated__c=true);
        
        Global_Variable__c lmsEnrlmtMergeIntegrationEndPoint = new Global_Variable__c(Name='LMS.EnrlmntMergeIntegration.Endpoint', Value__c='/integration/users/merge/subscriptions/{0}');
        Global_Variable__c lmsEnrollmentIntegrationCMethod = new Global_Variable__c(Name='LMS.EnrollmentIntegration.C.Method', Value__c='POST');
        Global_Variable__c lmsEnrollmentIntegrationEndpoint = new Global_Variable__c(Name='LMS.EnrollmentIntegration.Endpoint', Value__c='/integration/enrollment/{0}');
        Global_Variable__c lmsEnrollmentIntegrationTimeout = new Global_Variable__c(Name='LMS.EnrollmentIntegration.TimeOut', Value__c='120000');
        Global_Variable__c lmsEnrollmentIntegrationUMethod = new Global_Variable__c(Name='LMS.EnrollmentIntegration.U.Method', Value__c='PUT');
        Global_Variable__c lmsSecretKey = new Global_Variable__c(Name='LMS.SecretKey', Value__c='prdMMjNcXVAcmLXKyV2NceFfSS7BuZwNCzZ59446tnBcxGjJ2uK8aHvLcCf4KZAJGGwh7HgLrhgpepaKpXpM7g4jjr7FWLyWUV7muCmSntD6RyAh6ajLUC6VQs3PdwqnLpZ');
        Global_Variable__c lmsServer = new Global_Variable__c(Name='LMS.Server', Value__c='https://lmsacams-api.becker.com');    
        Global_Variable__c lmsUserInterationTimeout = new Global_Variable__c(Name='LMS.UserIntegration.TimeOut', Value__c='120000');
        Global_Variable__c lmsUserIntegrationEndPoint = new Global_Variable__c(Name='LMS.UserIntegration.Endpoint', Value__c='/integration/user/{0}');
        Global_Variable__c lmsWebinarIntegrationTimeOut = new Global_Variable__c(Name='LMS.WebinarIntegration.TimeOut', Value__c='12000');
        Global_Variable__c lmsWebinarIntegrationEndPoint = new Global_Variable__c(Name='LMS.WebinarIntegration.Endpoint', Value__c='/integration/enrollments/status/{0}');
        Global_Variable__c lmsWebinarIntegrationStartDate = new Global_Variable__c(Name='LMS.WebinarIntegration.StartDate', Value__c='2020-06-02T17:59:54Z');
        
        globalRecords.add(lmsAccountMergeIntegrationEndpoint);
        globalRecords.add(lmsAccountMergeIntegrationMethod);
        globalRecords.add(lmsAccountMergeIntegrationTimeout);
        globalRecords.add(lmsAppServer);
        globalRecords.add(lmsEnrlmtMergeIntegrationEndPoint);
        globalRecords.add(lmsEnrollmentIntegrationCMethod);
        globalRecords.add(lmsEnrollmentIntegrationEndpoint);
        globalRecords.add(lmsEnrollmentIntegrationTimeout);
        globalRecords.add(lmsEnrollmentIntegrationUMethod);
        globalRecords.add(lmsSecretKey);
        globalRecords.add(lmsServer);
        globalRecords.add(lmsUserInegrationMethod);
        globalRecords.add(lmsUserInterationTimeout);
        globalRecords.add(lmsUserIntegrationEndPoint);
        globalRecords.add(lmsWebinarIntegrationTimeOut);
        globalRecords.add(lmsWebinarIntegrationEndPoint);
        globalRecords.add(lmsWebinarIntegrationStartDate);
        return globalRecords;
    }

    public static List<Contact> createContactRecord(){
        List<Contact> cList = new List<Contact>();
        Contact c = new Contact();
        c.Email = 'test@contactemail.com';
        c.LastName = 'Contact Last Name';
        c.firstName = 'test Contact First';
        cList.add(c);
        return cList;
    }

    public static List<Account> createAccount(Integer accountNum){
        List<Account> acctList = new List<Account>();
        for(Integer i=0; i < accountNum; i++){
            Account a = new Account(Name='testAcct'+i, BillingCountry='US', BillingPostalCode='41234', BillingState='FL', BillingStreet='some street',Assets_Assigned__c = 1);
            acctList.add(a);
        }

        return acctList;
    }

    public static List<User> createSystemAdminUsers(){
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        List<User> uList = new List<User>();
        User u = new User
        (
            alias = 'alias',
            email='email' + '1' + '@salesforce.com',
            emailencodingkey='UTF-8',
            lastname='lastname',
            languagelocalekey='en_US',
            localesidkey='en_US',
            profileId = profile.Id,
            timezonesidkey='America/Los_Angeles',
            username='username' + '1' + '@salesforce.com'
        );

        uList.add(u);
        return uList;
    }

    public static List<BeckerLMS_Enrollment__c> createBeckLMSEnrollmentRecords(Integer num){
        List<BeckerLMS_Enrollment__c> beckLMSEnrollmentRecords = new List<BeckerLMS_Enrollment__c>();
        for(Integer i=0; i < num; i++){
            BeckerLMS_Enrollment__c beckerLMS = new BeckerLMS_Enrollment__c();
            beckerLMS.Status__c = 'Enrolled';
            beckLMSEnrollmentRecords.add(beckerLMS);
        }
        return beckLMSEnrollmentRecords;
    }
    /**
     * Asset data generation
     */
    public static List<Asset> createAssetList(Integer num,String assetName){
        List<Asset> assetList = new List<Asset>();
        for(Integer i=0; i < num; i++){
            Asset a = new Asset();
            //a.Name='Memberships';
            a.Name = assetName;
            a.Status__c = 'Active';
            a.CurrentExpirationDate__c = Date.today().addDays(-14);
            
            a.Certification_Approved_Application__c = false;
            a.Paid_Cert__c=true;
            
            assetList.add(a);
        }
        return assetList;
    }

    public static List<Asset> createAssetListWithRecordType(Integer num, String assetName, String recordTypeName){
        List<RecordType> rtList = [SELECT DeveloperName, Name FROM RecordType WHERE DeveloperName =: recordTypeName];
        List<Asset> assetList = new List<Asset>();
        for(Integer i = 0; i < num; i++){
            Asset a = new Asset();
            a.Name = assetName;
            a.Status__c = 'Active';
            a.CurrentExpirationDate__c = Date.today().addDays(-1);
            a.Certification_Approved_Application__c = false;
            a.Paid_Cert__c=true;

            if(rtList != null && rtList.size() > 0){
                a.recordTypeId = rtList[0].Id;
            }
            assetList.add(a);
        }

        return assetList;
    }
    /**
     * RecApplication data generation
     */

    public static List<Recertification_Application__c> createRecApplications(Integer num, String status){
        List<Recertification_Application__c> recerticationList = new List<Recertification_Application__c>();
        for(Integer i = 0; i < num; i++){
            Recertification_Application__c recert = new Recertification_Application__c();
            recert.Asset_Pending_to_Process__c = true;
            recert.Status__c = status;
            recert.Application_Approval_Date__c = Date.today();
            recerticationList.add(recert);
        }
        return recerticationList;
    }


    /**
     * @generate cc product records 
     */

     public static List<ccrz__E_Product__c> generateCCProductRecords(Integer num){
        List<ccrz__E_Product__c> returnList = new List<ccrz__E_Product__c>();
        for(Integer i = 0; i < num; i++){
            ccrz__E_Product__c ccProd = new ccrz__E_Product__c();
            ccProd.Name = 'Webinar';
            ccProd.Level_1__c = 'Certification';
            ccProd.Level_2__c = 'CAMS';
            ccProd.ccrz__SKU__c = 'CAMS';
            ccProd.Event_Date__c = Date.today().addDays(-14);
            returnList.add(ccProd);
        }

        return returnList;
     }    
    
}