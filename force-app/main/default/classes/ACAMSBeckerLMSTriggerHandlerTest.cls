@isTest
Public class ACAMSBeckerLMSTriggerHandlerTest {
    static CCAviTestUtil util = new CCAviTestUtil();
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
        a.name = 'Test Account';
        a.BillingCountry = 'US';
        a.BillingPostalCode = '11111';
        a.BillingState = 'FL';
        a.BillingStreet = ' 1001 Main Street';
        a.Phone = '555-555-5555';
        insert a;
        System.assert(a.Id != NULL);

        Contact c = new Contact(LastName = 'Contact Last Name', AccountId = a.Id);
        insert c;
        system.assert(c.Id != Null);

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
        lmse.Account__c=a.Id;
        lmse.Status__c = 'Enrolled';
        lmse.Start_Date__c= System.today();
        lmse.LMS_Course__c = lmsc.id;
        lmse.End_Date__c = system.today()+7;
 		ls.add(lmse);
        Insert ls;
        system.runAs(u1){
            ls[0].End_Date__c = system.today()+14;
            ls[0].Status__c = 'Cancelled';
            Update ls;
        }        
        test.stopTest();
    }
    static testMethod void test_UpsertAssetEnrollments() {
    	ACAMSBeckerLMSTriggerHandler.raiseException = false;
        ACAMSBeckerLMSTriggerHandler.isAssetEnrollmentUpdated=false;
        ACAMSBeckerLMSTriggerHandler.isAssetEnrollmentCreated=false;
        ACAMSBeckerLMSTriggerHandler.isLMSEnrollmentUpdated = True;
        ACAMSAssetTriggerHandler.isLMSUserCreated = false;
        ACAMSBeckerLMSTriggerHandler.alreadyProcessedInsertAssetEnrollments = false;
        
        Account a = new Account();
        a.name = 'Test Account';
        a.BillingCountry = 'US';
        a.BillingPostalCode = '11111';
        a.BillingState = 'FL';
        a.BillingStreet = ' 1001 Main Street';
        a.Phone = '555-555-5555';
        insert a;
        System.assert(a.Id != NULL);

        Contact c = new Contact(LastName = 'Contact Last Name', AccountId = a.Id);
        insert c;
        system.assert(c.Id != Null);
        
        Global_Variable__c gv2=new Global_Variable__c();
        gv2.Name='LMS.Username';
        gv2.Value__c='lmsintegration@acams2.org.acams';
        insert gv2;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = new User(Alias = 'standt', Email = 'standarduser@testorg.com',
            EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles', UserName = 'lmsintegration@acams2.org.acams');
        insert u;
        System.assert(u.Id != NULL);
        
        LMSCourse__c lmsc = new LMSCourse__c();
        lmsc.Name= 'Test Course';
        lmsc.Description__c = 'Test Course Description';
        lmsc.Credits__c = 10;
        insert lmsc;
        
        lmsc.Credits__c = 3;
        update lmsc;
        system.assert(lmsc.Credits__c != NULL);
         
     
        ccrz__E_Product__c p1 = new ccrz__E_Product__c();
        p1.LMS_Course__c = lmsc.id;
        p1.Level_1__c = 'Certification';
        p1.Level_1__c = 'Membership';
        p1.ProductCategory__c = 'Memberships';
        p1.ccrz__SKU__c= '1234';
        insert p1;
        System.assert(p1.Id != NULL);
        
        Map<String, Object> testData = util.initData();
        Contact con = (Contact) testData.get(CCAviTestUtil.PN_USER_CONTACT);
        con.AccountId = a.Id;
        update con;
        
        test.starttest();
        List<Asset> assLst =new List<Asset>();
        Asset asst = new Asset();
        asst.Name = 'Test Asset';
        asst.AccountId = a.Id;
        asst.ContactId = c.Id;
        asst.CC_Product__c = p1.Id;
        asst.PurchaseDate = System.today();
        asst.CurrentExpirationDate__c = System.today().addDays(20);
        asst.Paid_Cert__c = true;
        asst.Assignee__c = con.Id;
        asst.Payment_Status__c = 'Completed';
        asst.LMS_Access_Exp_Date__c = system.today()+7;
        asst.RecordTypeId = Schema.getGlobalDescribe().get('Asset').getDescribe().getRecordTypeInfosByName().get('Registrant').getRecordTypeId();
        //insert asst;
        assLst.add(asst);
        
        Asset asst1 = new Asset();
        asst1.Name = 'Test Asset1';
        asst1.AccountId = a.Id;
        asst1.ContactId = c.Id;
        asst1.CC_Product__c = p1.Id;
        asst1.PurchaseDate = System.today();
        asst1.CurrentExpirationDate__c = System.today().addDays(20);
        asst1.Paid_Cert__c = true;
        asst1.Payment_Status__c = 'Completed';
        asst1.Assignee__c = con.Id;
        asst1.LMS_Access_Exp_Date__c = system.today()+7;
        //insert asst;
        assLst.add(asst1);
        Insert assLst;
        
        set < id > astids = new set < id > ();
        astids.add(assLst[0].id);
        astids.add(assLst[1].id);
    	
        
        LMSCourse__c lmsc2 = new LMSCourse__c();
        lmsc2.Name= 'Test Course';
        lmsc2.Description__c = 'Test Course Description';
        lmsc2.Credits__c = 10;
        insert lmsc2;
        System.assert(lmsc2.Id != NULL);

        BeckerLMS_Enrollment__c lmse = new BeckerLMS_Enrollment__c();
        lmse.Account__c=a.Id;
        lmse.Status__c = 'Enrolled';
        lmse.Start_Date__c= System.today();
        lmse.LMS_Course__c = lmsc.id;
        lmse.Asset__c = assLst[0].id;
        insert lmse;
		System.assert(lmse.Id != NULL);

        System.assert(asset.Id != NULL);
		Map<Id,Asset> oldMap = new Map<Id,Asset>();
        for(Asset ass: assLst){
            ass.Paid_Cert__c = false;
            ass.CurrentExpirationDate__c = System.today().addDays(25);
            oldMap.put(ass.Id,ass);
        }
        Date expDate = System.today().addDays(15);
        assLst[0].CurrentExpirationDate__c = expDate;
        assLst[1].CurrentExpirationDate__c = expDate;
        assLst[0].Paid_Cert__c = true;
        assLst[1].Paid_Cert__c = true;
        //update assLst;
       	
        //lmse.Status__c = 'Completed';
        //Update lmse;
        assLst[0].CancelDate__c = system.today().addDays(50);
        assLst[1].CancelDate__c = system.today().addDays(50);
        //Update assLst;
        
        test.stoptest();
    }
    /*static testMethod void test_UpsertAttendeeEnrollments() {
        ACAMSBeckerLMSTriggerHandler.raiseException = false;
        ACAMSBeckerLMSTriggerHandler.isAssetEnrollmentUpdated=false;
        ACAMSBeckerLMSTriggerHandler.isAssetEnrollmentCreated=false;
        ACAMSBeckerLMSTriggerHandler.isLMSEnrollmentUpdated = True;
        ACAMSAssetTriggerHandler.isLMSUserCreated = false;
        ACAMSBeckerLMSTriggerHandler.alreadyProcessedInsertAssetEnrollments = false;
        test.starttest();
        Account a = new Account();
        a.name = 'Test Account';
        a.BillingCountry = 'US';
        a.BillingPostalCode = '11111';
        a.BillingState = 'FL';
        a.BillingStreet = ' 1001 Main Street';
        a.Phone = '555-555-5555';
        insert a;
        System.assert(a.Id != NULL);

        Contact c = new Contact(LastName = 'Contact Last Name', AccountId = a.Id);
        insert c;
        system.assert(c.Id != Null);
        
        Global_Variable__c gv2=new Global_Variable__c();
        gv2.Name='LMS.Username';
        gv2.Value__c='lmsintegration@acams2.org.acams';
        insert gv2;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = new User(Alias = 'standt', Email = 'standarduser@testorg.com',
            EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles', UserName = 'lmsintegration@acams2.org.acams');
        insert u;
        System.assert(u.Id != NULL);
       
        LMSCourse__c lmsc = new LMSCourse__c();
        lmsc.Name= 'Test Course';
        lmsc.Description__c = 'Test Course Description';
        lmsc.Credits__c = 10;
        insert lmsc;
        
        lmsc.Credits__c = 3;
        update lmsc;
        system.assert(lmsc.Credits__c != NULL);
         
     
        ccrz__E_Product__c p1 = new ccrz__E_Product__c();
        p1.LMS_Course__c = lmsc.id;
        p1.Level_1__c = 'Certification';
        p1.Level_1__c = 'Membership';
        p1.ProductCategory__c = 'Memberships';
        p1.ccrz__SKU__c= '1234';
        insert p1;
        System.assert(p1.Id != NULL);
        
        Map<String, Object> testData = util.initData();
        Contact con = (Contact) testData.get(CCAviTestUtil.PN_USER_CONTACT);
        con.AccountId = a.Id;
        update con;
        
        //List<Asset> assLst =new List<Asset>();
        Asset asst = new Asset();
        asst.Name = 'Test Asset';
        asst.AccountId = a.Id;
        asst.ContactId = c.Id;
        asst.CC_Product__c = p1.Id;
        asst.PurchaseDate = System.today();
        asst.CurrentExpirationDate__c = System.today().addDays(20);
        asst.Paid_Cert__c = false;
        asst.Assignee__c = con.Id;
        asst.LMS_Access_Exp_Date__c = system.today()+7;
        asst.RecordTypeId = Schema.getGlobalDescribe().get('Asset').getDescribe().getRecordTypeInfosByName().get('Registrant').getRecordTypeId();
        insert asst;
        Map<Id,Asset> oldMaps = new Map<Id,Asset>();
        oldMaps.put(asst.Id, asst);
        asst.CurrentExpirationDate__c = System.today().addDays(15);
        asst.Paid_Cert__c = true;
        Update asst;
        Set<Id> astids = new Set<Id>();
        astids.add(asst.Id);
        //assLst.add(asst);
        ACAMSBeckerLMSTriggerHandler.UpsertAttendeeEnrollments(astids,oldMaps);
        oldMaps.clear();
        ACAMSBeckerLMSTriggerHandler.UpsertAttendeeEnrollments(astids,oldMaps);
        
        //For Else block
        asst.Paid_Cert__c = true;
        asst.CurrentExpirationDate__c = System.today().addDays(7);
        asst.CancelDate__c = System.today().addDays(17);
        Update asst;
        asst.Paid_Cert__c = false;
        asst.CurrentExpirationDate__c = System.today().addDays(17);
        oldMaps.put(asst.Id, asst);
        ACAMSBeckerLMSTriggerHandler.UpsertAttendeeEnrollments(astids,oldMaps);
    }*/
    static testMethod void test_UpsertEnterpriseMembershipEnrollments() { 
    	ACAMSBeckerLMSTriggerHandler.isEnterpriseLMSEnrollmentExecutedInsert = false;
        ACAMSBeckerLMSTriggerHandler.isAssetEnrollmentCreated = TRUE;
        
        Account a = new Account();
        a.name = 'Test Account';
        a.BillingCountry = 'US';
        a.BillingPostalCode = '11111';
        a.BillingState = 'FL';
        a.BillingStreet = ' 1001 Main Street';
        a.Phone = '555-555-5555';
        insert a;
        System.assert(a.Id != NULL);

        Contact c = new Contact(LastName = 'Contact Last Name', AccountId = a.Id);
        insert c;
        system.assert(c.Id != Null);
        
        Global_Variable__c gv2=new Global_Variable__c();
        gv2.Name='LMS.Username';
        gv2.Value__c='lmsintegration@acams2.org.acams';
        insert gv2;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = new User(Alias = 'standt', Email = 'standarduser@testorg.com',
            EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles', UserName = 'lmsintegration@acams2.org.acams');
        insert u;
        System.assert(u.Id != NULL);
        
        LMSCourse__c lmsc = new LMSCourse__c();
        lmsc.Name= 'Enterprise Webinar Subscription';
        lmsc.Description__c = 'Test Course Description';
        lmsc.Credits__c = 10;
        insert lmsc;
        
        lmsc.Credits__c = 3;
        update lmsc;
        system.assert(lmsc.Credits__c != NULL);

        ccrz__E_Product__c p1 = new ccrz__E_Product__c();
        p1.LMS_Course__c = lmsc.id;
        p1.Level_1__c = 'Enterprise Bundle';
        //p1.Level_1__c = 'Membership';
        p1.ProductCategory__c = 'Memberships';
        p1.ccrz__SKU__c= '1234';
        insert p1;
        System.assert(p1.Id != NULL);
        
        Map<String, Object> testData = util.initData();
        Contact con = (Contact) testData.get(CCAviTestUtil.PN_USER_CONTACT);
        con.AccountId = a.Id;
        update con;
        
        List<Asset> assLst =new List<Asset>();
        Asset asst = new Asset();
        asst.Name = 'Test Asset';
        asst.AccountId = a.Id;
        asst.ContactId = c.Id;
        asst.CC_Product__c = p1.Id;
        //asst.CC_Product__r.Level_1__c = 'Enterprise Bundle';
        asst.PurchaseDate = System.today();
        asst.CurrentExpirationDate__c = System.today().addDays(20);
        asst.Paid_Cert__c = true;
        asst.Assignee__c = con.Id;
        asst.LMS_Access_Exp_Date__c = system.today()+7;
        //asst.Product_level_1__c = 'Enterprise Bundle';
        asst.RecordTypeId = Schema.getGlobalDescribe().get('Asset').getDescribe().getRecordTypeInfosByName().get('Registrant').getRecordTypeId();
        //insert asst;
        assLst.add(asst);
        Insert assLst;
        asst.Paid_Cert__c = true;
        asst.CC_Product__c = p1.Id;

        //Update assLst;
        //assLst.add(asst);
        Set<Id> asstIds = new Set<Id>();
        asstIds.add(assLst[0].Id);
        
        list<BeckerLMS_Enrollment__c> ls = new list<BeckerLMS_Enrollment__c>();
        BeckerLMS_Enrollment__c lmse = new BeckerLMS_Enrollment__c();
        lmse.Account__c=a.Id;
        lmse.Asset__c = assLst[0].Id;
        lmse.Status__c = 'Enrolled';
        lmse.Start_Date__c= System.today();
        lmse.LMS_Course__c = lmsc.id;
        lmse.End_Date__c = assLst[0].CurrentExpirationDate__c;
 		ls.add(lmse);
        Insert ls;
        
        
        Test.startTest();
        
        ACAMSBeckerLMSTriggerHandler lmsHandler = new ACAMSBeckerLMSTriggerHandler();
        ACAMSBeckerLMSTriggerHandler.UpsertEnterpriseMembershipEnrollments(asstIds,asstIds);
        ACAMSBeckerLMSTriggerHandler.CreateLMSEnrollment(ls);
        ACAMSBeckerLMSTriggerHandler.UpdateLMSEnrollment(ls,null);
        ACAMSBeckerLMSTriggerHandler.UpsertAssetEnrollments(asstIds,null,true,false);
        ACAMSBeckerLMSTriggerHandler.UpsertAssetEnrollments(asstIds,null,false,true);
        ACAMSBeckerLMSTriggerHandler.UpsertAttendeeEnrollments(asstIds,null);
        //List<Database.SaveResult> results = EventBus.publish(AssetEmPlatformEvents);
        Test.stopTest();
    }


    static testMethod void test_UpsertEnterpriseMembershipEnrollments2() { 
    	ACAMSBeckerLMSTriggerHandler.isEnterpriseLMSEnrollmentExecutedInsert = false;
        ACAMSBeckerLMSTriggerHandler.isAssetEnrollmentCreated = TRUE;
        
        Test.startTest();
        Account a = new Account();
        a.name = 'Test Account';
        a.BillingCountry = 'US';
        a.BillingPostalCode = '11111';
        a.BillingState = 'FL';
        a.BillingStreet = ' 1001 Main Street';
        a.Phone = '555-555-5555';
        insert a;
        System.assert(a.Id != NULL);

        Contact c = new Contact(LastName = 'Contact Last Name', AccountId = a.Id);
        insert c;
        system.assert(c.Id != Null);
        
        Global_Variable__c gv2=new Global_Variable__c();
        gv2.Name='LMS.Username';
        gv2.Value__c='lmsintegration@acams2.org.acams';
        insert gv2;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = new User(Alias = 'standt', Email = 'standarduser@testorg.com',
            EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles', UserName = 'lmsintegration@acams2.org.acams');
        insert u;
        System.assert(u.Id != NULL);
        
        LMSCourse__c lmsc = new LMSCourse__c();
        lmsc.Name= 'Test Course';
        lmsc.Description__c = 'Test Course Description';
        lmsc.Credits__c = 10;
        insert lmsc;
        
        lmsc.Credits__c = 3;
        update lmsc;
        system.assert(lmsc.Credits__c != NULL);

        ccrz__E_Product__c p1 = new ccrz__E_Product__c();
        p1.LMS_Course__c = lmsc.id;
        p1.Level_1__c = 'Enterprise Bundle';
        //p1.Level_1__c = 'Membership';
        p1.ProductCategory__c = 'Memberships';
        p1.ccrz__SKU__c= '1234';
        insert p1;
        System.assert(p1.Id != NULL);
        
        Map<String, Object> testData = util.initData();
        Contact con = (Contact) testData.get(CCAviTestUtil.PN_USER_CONTACT);
        con.AccountId = a.Id;
        update con;
        
        List<Asset> assLst =new List<Asset>();
        Asset asst = new Asset();
        asst.Name = 'Test Asset';
        asst.AccountId = a.Id;
        asst.ContactId = c.Id;
        asst.CC_Product__c = p1.Id;
        asst.Payment_Status__c = 'Authorized';
        //asst.CC_Product__r.Level_1__c = 'Enterprise Bundle';
        asst.PurchaseDate = System.today();
        asst.CurrentExpirationDate__c = System.today().addDays(20);
        asst.Paid_Cert__c = true;
        asst.Assignee__c = con.Id;
        asst.LMS_Access_Exp_Date__c = system.today()+7;
        //asst.Product_level_1__c = 'Enterprise Bundle';
        asst.RecordTypeId = Schema.getGlobalDescribe().get('Asset').getDescribe().getRecordTypeInfosByName().get('Registrant').getRecordTypeId();
        //insert asst;
        assLst.add(asst);
        Insert assLst;
        asst.Paid_Cert__c = true;
        asst.CC_Product__c = p1.Id;

        //Update assLst;
        //assLst.add(asst);
        Set<Id> asstIds = new Set<Id>();
        asstIds.add(assLst[0].Id);
        
        /*list<BeckerLMS_Enrollment__c> ls = new list<BeckerLMS_Enrollment__c>();
        BeckerLMS_Enrollment__c lmse = new BeckerLMS_Enrollment__c();
        lmse.Account__c=a.Id;
        lmse.Asset__c = assLst[0].Id;
        lmse.Status__c = 'Enrolled';
        lmse.Start_Date__c= System.today();
        lmse.LMS_Course__c = lmsc.id;
        lmse.End_Date__c = assLst[0].CurrentExpirationDate__c;
 		ls.add(lmse);
        Insert ls;*/
        
       	/*List<Asset_EM_Enrollment_Event__e> AssetEmPlatformEvents = new List<Asset_EM_Enrollment_Event__e>();
            for(BeckerLMS_Enrollment__c req : ls){
                AssetEmPlatformEvents.add(new Asset_EM_Enrollment_Event__e(Asset_ID__c=req.Id,isInsertLMS__c = true));
                
            }*/
        ACAMSBeckerLMSTriggerHandler lmsHandler = new ACAMSBeckerLMSTriggerHandler();
        ACAMSBeckerLMSTriggerHandler.UpsertEnterpriseMembershipEnrollments(asstIds,asstIds);
        Test.stopTest();
    }
    
    //CSA-fix - testMethod written to cover PE for UpsertEnterpriseMembershipEnrollments
    static testMethod void test_UpsertEnterpriseMembershipEnrollments3() { 
    	ACAMSBeckerLMSTriggerHandler.isEnterpriseLMSEnrollmentExecutedInsert = false;
        ACAMSBeckerLMSTriggerHandler.isAssetEnrollmentCreated = TRUE;
        
        
        Account a = new Account();
        a.name = 'Test Account';
        a.BillingCountry = 'US';
        a.BillingPostalCode = '11111';
        a.BillingState = 'FL';
        a.BillingStreet = ' 1001 Main Street';
        a.Phone = '555-555-5555';
        insert a;
        System.assert(a.Id != NULL);

        Contact c = new Contact(LastName = 'Contact Last Name', AccountId = a.Id);
        insert c;
        system.assert(c.Id != Null);
        
        Global_Variable__c gv2=new Global_Variable__c();
        gv2.Name='LMS.Username';
        gv2.Value__c='lmsintegration@acams2.org.acams';
        insert gv2;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = new User(Alias = 'standt', Email = 'standarduser@testorg.com',
            EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles', UserName = 'lmsintegration@acams2.org.acams');
        insert u;
        System.assert(u.Id != NULL);
        
        LMSCourse__c lmsc = new LMSCourse__c();
        lmsc.Name= 'Enterprise Webinar Subscription';
        lmsc.Description__c = 'Test Course Description';
        lmsc.Credits__c = 10;
        insert lmsc;
        
        lmsc.Credits__c = 3;
        update lmsc;
        system.assert(lmsc.Credits__c != NULL);

        ccrz__E_Product__c p1 = new ccrz__E_Product__c();
        p1.LMS_Course__c = lmsc.id;
        p1.Level_1__c = 'Enterprise Bundle';
        //p1.Level_1__c = 'Membership';
        p1.ProductCategory__c = 'Memberships';
        p1.ccrz__SKU__c= '1234';
        insert p1;
        System.assert(p1.Id != NULL);
        
        Map<String, Object> testData = util.initData();
        Contact con = (Contact) testData.get(CCAviTestUtil.PN_USER_CONTACT);
        con.AccountId = a.Id;
        update con;
        
       
        List<Asset> assLst =new List<Asset>();
        Asset asst = new Asset();
        asst.Name = 'Test Asset';
        asst.AccountId = a.Id;
        asst.ContactId = c.Id;
        asst.CC_Product__c = p1.Id;
        asst.Payment_Status__c = 'Authorized';
        //asst.CC_Product__r.Level_1__c = 'Enterprise Bundle';
        asst.PurchaseDate = System.today();
        asst.CurrentExpirationDate__c = System.today().addDays(20);
        asst.Paid_Cert__c = true;
        asst.Assignee__c = con.Id;
        asst.LMS_Access_Exp_Date__c = system.today()+7;
        //asst.Product_level_1__c = 'Enterprise Bundle';
        asst.RecordTypeId = Schema.getGlobalDescribe().get('Asset').getDescribe().getRecordTypeInfosByName().get('Registrant').getRecordTypeId();
        //insert asst;
        assLst.add(asst);
        Insert assLst;
        assLst[0].Paid_Cert__c = true;
        assLst[0].CC_Product__c = p1.Id;

        //Update assLst;
        //assLst.add(asst);
        Set<Id> asstIds = new Set<Id>();
        asstIds.add(assLst[0].Id);
        
        list<BeckerLMS_Enrollment__c> ls = new list<BeckerLMS_Enrollment__c>();
        BeckerLMS_Enrollment__c lmse = new BeckerLMS_Enrollment__c();
        lmse.Account__c=a.Id;
        lmse.Asset__c = assLst[0].Id;
        lmse.Status__c = 'Enrolled';
        lmse.Start_Date__c= System.today();
        lmse.LMS_Course__c = lmsc.id;
        lmse.End_Date__c = assLst[0].CurrentExpirationDate__c;
 		ls.add(lmse);
        
        BeckerLMS_Enrollment__c lmse1 = new BeckerLMS_Enrollment__c();
        lmse1.Account__c=a.Id;
        //lmse.Asset__c = assLst[0].Id;
        lmse1.Status__c = 'Enrolled';
        lmse1.Start_Date__c= System.today();
        lmse1.LMS_Course__c = lmsc.id;
        lmse1.End_Date__c = assLst[0].CurrentExpirationDate__c;
 		ls.add(lmse1);
        Insert ls;
        
        ls[0].Start_Date__c= System.today()+1;
        ls[1].Start_Date__c= System.today()+1;
        update ls;
        
        
       	/*List<Asset_EM_Enrollment_Event__e> AssetEmPlatformEvents = new List<Asset_EM_Enrollment_Event__e>();
            for(BeckerLMS_Enrollment__c req : ls){
                AssetEmPlatformEvents.add(new Asset_EM_Enrollment_Event__e(Asset_ID__c=req.Id,isInsertLMS__c = true));
                
            }*/
         Test.startTest();
        ACAMSBeckerLMSTriggerHandler lmsHandler = new ACAMSBeckerLMSTriggerHandler();
        ACAMSBeckerLMSTriggerHandler.UpsertEnterpriseMembershipEnrollments(asstIds,asstIds);
        Test.stopTest();
    }
   
}