@isTest
public with sharing class ACAMSEnrollmentCallOutBatchTest {
    private static Map<String, Object> initData = new Map<String, Object>();

    @TestSetup
    static void initData() {
        CCACAMSTestUtil testUtil = new CCACAMSTestUtil();
        initData = testUtil.initData();
    }

    @IsTest
    static void enrollmentCalloutScheduled() {
        Test.startTest();
        Id jobId = System.schedule('Enrollment Callout', '0 0 23 * * ?', new ACAMSEnrollmentCallOutBatch());
        Test.stopTest();
        CronTrigger job = [
                SELECT TimesTriggered
                FROM CronTrigger
                WHERE Id = :jobId
        ];
        System.assertNotEquals(null, job);
    }
    static testMethod void test_LMSEnrollment() {
    	ACAMSBeckerLMSTriggerHandler.isAssetEnrollmentCreated=true;
        ACAMSBeckerLMSTriggerHandler.isAssetEnrollmentUpdated=false;
        ACAMSBeckerLMSTriggerHandler.raiseException = false;
        //Inserting Gloabl Variable record
        Global_Variable__c gv2=new Global_Variable__c();
        gv2.Name='LMS.Username';
        gv2.Value__c='lmsintegration@acams2.org.acams';
        insert gv2;
        //Creating User under system admin Profile
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = new User(Alias = 'standt', Email = 'standarduser@testorg.com',
            EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles', UserName = 'lmsintegration@acams2.org.acams');
        insert u;
        
        User u1 = new User(Alias = 'standt', Email = 'standarduser@testorg.com',
            EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles', UserName = 'lmsintegration1@acams2.org.acams');
        insert u1;
        
        User lmsUser = [SELECT Id, Username FROM User WHERE Username = 'lmsintegration@acams2.org.acams'];
        System.assert(u.Id != NULL);
        System.assert(lmsUser.Username == 'lmsintegration@acams2.org.acams');
        
        test.starttest();
        Account a = new Account();
        a.name = 'Test Account'+ system.now();
        a.BillingCountry = 'US';
        a.BillingPostalCode = '11111';
        a.BillingState = 'FL';
        a.BillingStreet = ' 1001 Main Street';
        a.Phone = '555-555-5555';
        system.debug('Insert::' + a);
       /* insert a;
        
        System.assert(a.Id != NULL);

        Contact c = new Contact(LastName = 'Contact Last Name', AccountId = a.Id);
        insert c;
        system.assert(c.Id != Null);*/

        LMSCourse__c lmsc = new LMSCourse__c();
        lmsc.Name= 'Test Course';
        lmsc.Description__c = 'Test Course Description';
        lmsc.Credits__c = 10;
        insert lmsc;
        
        lmsc.Credits__c = 3;
        update lmsc;
        system.assert(lmsc.Credits__c != NULL);
        System.assert(lmsc.Id != NULL);
        
        list < BeckerLMS_Enrollment__c > ls = new list < BeckerLMS_Enrollment__c > ();
        BeckerLMS_Enrollment__c lmse = new BeckerLMS_Enrollment__c();
       // lmse.Account__c=a.Id;
        lmse.Status__c = 'Enrolled';
        lmse.Start_Date__c= System.today();
        lmse.LMS_Course__c = lmsc.id;
        lmse.End_Date__c = system.today()+7;
 		ls.add(lmse);
        Insert ls;
        system.debug('ls::'+ls);
        ACAMSEnrollmentCallOutBatch abc = new ACAMSEnrollmentCallOutBatch();
        List<BeckerLMS_Enrollment__c> enrollmentList = [
            SELECT Id,Time_stamp__c,Response_status__c,Status_code__c,Created_LMS__c,Updated_LMS__c,CreatedById, Account__c, LMS_Course_ID__c,
            Name,Start_Date__c,End_Date__c,Purchase_Date__c
            FROM BeckerLMS_Enrollment__c
            WHERE (Response_status__c != 'OK' OR Status_code__c != '200') 
            AND Asset__c != NULL 
            
            ]; 
        
        abc.execute(null,enrollmentList);
        List<BeckerLMS_Enrollment__c> enrollmentListAfterCallout = [
            SELECT Id,Time_stamp__c,Response_status__c,Status_code__c,Created_LMS__c,Updated_LMS__c,CreatedById, Account__c, LMS_Course_ID__c,
            Name,Start_Date__c,End_Date__c,Purchase_Date__c
            FROM BeckerLMS_Enrollment__c]; 
        system.debug('enrollmentListAfterCallout[0].Response_status__c::'+enrollmentListAfterCallout[0].Response_status__c);
        system.debug('enrollmentListAfterCallout[0].Status_code__c'+enrollmentListAfterCallout[0].Status_code__c);
        test.stopTest();
    }
}