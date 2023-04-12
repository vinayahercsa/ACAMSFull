@IsTest
class ACAMSCaseTriggerHandlerTest {

    @IsTest
    static void createCaseWithCountry() {
        Test.startTest();
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(Alias = 'standt', Email = 'standarduser@testorg.com',
                EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = p.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = uniqueUserName);
        insert u;

        Assignment_Group_Queues__c agq = new Assignment_Group_Queues__c();


        List<Case> testCases = new List<Case>{
                new Case(
                        Subject = 'Test 1',
                        AddressCountry__c = 'CA'
                ),
                new Case(
                        Subject = 'Test 2',
                        AddressCountry__c = 'AU'
                )
        };
        insert testCases;

        Assignment_Group_Name__c G1 = new Assignment_Group_Name__c();
        G1.Name = 'TestG';
        G1.Type__c = 'Cases';
        insert G1;

        Group gq1 = new Group();
        gq1.Type = 'Queue';
        gq1.Name = 'Testq';
        insert gq1;

        agq.Active__c = 'True';
        agq.QueueId__c = u.Id;
        agq.Name = 'Testq';
        agq.Assignment_Group_Name__c = G1.id;
        insert agq;

        for (Case cs : testCases) {
            cs.ownerId = u.Id;
        }
        update testCases;

        for (Case testCase : [
                SELECT AddressCountry__c, AddressRegion__c
                FROM Case
                WHERE Id IN :testCases
        ]) {
            if (testCase.AddressCountry__c == 'CA') {
                System.assertEquals('Americas', testCase.AddressRegion__c);
            } else if (testCase.AddressCountry__c == 'AU') {
                System.assertEquals('APAC', testCase.AddressRegion__c);
            }
        }
        Test.stopTest();
    }

    private static testMethod void test_CaseTriggeremails() {

        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(Alias = 'standt', Email = 'standarduser@testorg.com',
                EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = p.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = uniqueUserName);
        insert u;
        Test.startTest();
        System.runAs(u) {
            Case cas = new Case();
            cas.subject = 'Technical_Support_Access_Issue_';
            cas.description = 'Test Case 4';
            cas.Origin = 'Email - Test';
            cas.addresscountry__c = 'IN';
            cas.SuppliedEmail = 'acams@acams.com';
            cas.Type = 'Pending Categorization';
            insert cas;
            
            cas.type = 'Data entry updates';
            cas.Status = 'closed';
            cas.Secondary_Case_Type__c = 'Closed due to no response';
            cas.Type = 'Pending Categorization';
            update cas;
            
            cas.type = 'Data entry updates';
            cas.Status = 'closed';
            cas.Secondary_Case_Type__c = 'Closed due to no response';
            cas.subject = 'Technical_Support_Resend_';
            Update cas;
            
            cas.type = 'Data entry updates';
            cas.Status = 'closed';
            cas.Secondary_Case_Type__c = 'Closed due to no response';
            cas.subject = 'Technical_Support_';
            Update cas;
            
            cas.type = 'Data entry updates';
            cas.Status = 'closed';
            cas.Secondary_Case_Type__c = 'Closed due to no response';
            cas.subject = 'General_inquiry_Memberships_';
            Update cas;
            
            cas.type = 'Data entry updates';
            cas.Status = 'closed';
            cas.Secondary_Case_Type__c = 'Closed due to no response';
            cas.subject = 'General_inquiry_Chapters_';
            Update cas;
            
            cas.type = 'Data entry updates';
            cas.Status = 'closed';
            cas.Secondary_Case_Type__c = 'Closed due to no response';
            cas.subject = 'General_inquiry_Certifications_';
            Update cas;
            
            cas.type = 'Data entry updates';
            cas.Status = 'closed';
            cas.Secondary_Case_Type__c = 'Closed due to no response';
            cas.subject = 'General_inquiry_Training_';
            Update cas;
            
            cas.type = 'Data entry updates';
            cas.Status = 'closed';
            cas.Secondary_Case_Type__c = 'Closed due to no response';
            cas.subject = 'General_inquiry_RA_';
            Update cas;
            
            cas.type = 'Data entry updates';
            cas.Status = 'closed';
            cas.Secondary_Case_Type__c = 'Closed due to no response';
            cas.subject = 'General_inquiry_Other_';
            Update cas;
            
            cas.type = 'Data entry updates';
            cas.Status = 'closed';
            cas.Secondary_Case_Type__c = 'Closed due to no response';
            cas.subject = 'General_inquiry_Other_';
            Update cas;
            
            cas.type = 'Data entry updates';
            cas.Status = 'closed';
            cas.Secondary_Case_Type__c = 'Closed due to no response';
            cas.subject = 'Enterprise_Onboarding_';
            Update cas;
            
            cas.type = 'Data entry updates';
            cas.Status = 'closed';
            cas.Secondary_Case_Type__c = 'Closed due to no response';
            cas.subject = 'Enterprise_Change_';
            Update cas;
            
            cas.type = 'Data entry updates';
            cas.Status = 'closed';
            cas.Secondary_Case_Type__c = 'Closed due to no response';
            cas.subject = 'Enterprise_Other_';
            Update cas;
            
            cas.type = 'Data entry updates';
            cas.Status = 'closed';
            cas.Secondary_Case_Type__c = 'Closed due to no response';
            cas.subject = 'Enterprise_';
            Update cas;
            
            cas.type = 'Data entry updates';
            cas.Status = 'closed';
            cas.Secondary_Case_Type__c = 'Closed due to no response';
            cas.subject = 'Certifications_Cert_App_';
            Update cas;
            
            cas.type = 'Data entry updates';
            cas.Status = 'closed';
            cas.Secondary_Case_Type__c = 'Closed due to no response';
            cas.subject = 'Certifications_Recert_App_';
            Update cas;
            
            cas.type = 'Data entry updates';
            cas.Status = 'closed';
            cas.Secondary_Case_Type__c = 'Closed due to no response';
            cas.subject = 'Certifications_Retake_';
            Update cas;
            
            cas.type = 'Data entry updates';
            cas.Status = 'closed';
            cas.Secondary_Case_Type__c = 'Closed due to no response';
            cas.subject = 'Certifications_Extension_';
            Update cas;
            
            cas.type = 'Data entry updates';
            cas.Status = 'closed';
            cas.Secondary_Case_Type__c = 'Closed due to no response';
            cas.subject = 'Certifications_Reissue_VC_';
            Update cas;
            
            cas.type = 'Data entry updates';
            cas.Status = 'closed';
            cas.Secondary_Case_Type__c = 'Closed due to no response';
            cas.subject = 'Certifications_Group_Exam_';
            Update cas;
            
            cas.type = 'Data entry updates';
            cas.Status = 'closed';
            cas.Secondary_Case_Type__c = 'Closed due to no response';
            cas.subject = 'Certifications_Resend_Cert_';
            Update cas;
            
            cas.type = 'Data entry updates';
            cas.Status = 'closed';
            cas.Secondary_Case_Type__c = 'Closed due to no response';
            cas.type = 'Other';
            update cas;


        }
        Test.stopTest();
    }
    private static testMethod void test_CaseTriggeremails1() {
        Test.startTest();
        Case cas = new Case();
        cas.subject = 'Technical_Support_Access_Issue_';
        cas.description = 'Test Case 4';
        cas.Origin = 'Email - Test';
        cas.addresscountry__c = 'IN';
        cas.SuppliedEmail = 'acams@acams.com';
        cas.Type = 'Pending Categorization';


        insert cas;
        cas.subject = 'Certifications_Reschedule_';
        cas.type = 'Data entry updates';
        cas.Status = 'closed';
        cas.Secondary_Case_Type__c = 'Closed due to no response';
        Update cas;
        
        cas.type = 'Data entry updates';
        cas.Status = 'closed';
        cas.Secondary_Case_Type__c = 'Closed due to no response';
        cas.subject = 'Certifications_Other_';
        Update cas;
        
                cas.type = 'Data entry updates';
        cas.Status = 'closed';
        cas.Secondary_Case_Type__c = 'Closed due to no response';
        cas.subject = 'Certifications_';
        Update cas;
        
                cas.type = 'Data entry updates';
        cas.Status = 'closed';
        cas.Secondary_Case_Type__c = 'Closed due to no response';
        cas.subject = 'Revenue_Impacting_Invoice_';
        Update cas;
        
                cas.type = 'Data entry updates';
        cas.Status = 'closed';
        cas.Secondary_Case_Type__c = 'Closed due to no response';
        cas.subject = 'Revenue_Impacting_Payment_';
        Update cas;
        
                cas.type = 'Data entry updates';
        cas.Status = 'closed';
        cas.Secondary_Case_Type__c = 'Closed due to no response';
        cas.subject = 'Revenue_Impacting_Group_Order_';
        Update cas;
        
                cas.type = 'Data entry updates';
        cas.Status = 'closed';
        cas.Secondary_Case_Type__c = 'Closed due to no response';
        cas.subject = 'Revenue_Impacting_Refund_';
        Update cas;
        
                cas.type = 'Data entry updates';
        cas.Status = 'closed';
        cas.Secondary_Case_Type__c = 'Closed due to no response';
        cas.subject = 'Revenue_Impacting_Credit_';
        Update cas;
        
                cas.type = 'Data entry updates';
        cas.Status = 'closed';
        cas.Secondary_Case_Type__c = 'Closed due to no response';
        cas.subject = 'Revenue_Impacting_Transfer_';
        Update cas;
        
                cas.type = 'Data entry updates';
        cas.Status = 'closed';
        cas.Secondary_Case_Type__c = 'Closed due to no response';
        cas.subject = 'Revenue_Wire_';
        Update cas;
        
                cas.type = 'Data entry updates';
        cas.Status = 'closed';
        cas.Secondary_Case_Type__c = 'Closed due to no response';
        cas.subject = 'Revenue_Impacting_RegOnline_';
        Update cas;
        
                cas.type = 'Data entry updates';
        cas.Status = 'closed';
        cas.Secondary_Case_Type__c = 'Closed due to no response';
        cas.subject = 'Revenue_Comp_';
        Update cas;
        
                cas.type = 'Data entry updates';
        cas.Status = 'closed';
        cas.Secondary_Case_Type__c = 'Closed due to no response';
        cas.subject = 'Revenue_Impacting_Other_';
        Update cas;
        
                cas.type = 'Data entry updates';
        cas.Status = 'closed';
        cas.Secondary_Case_Type__c = 'Closed due to no response';
        cas.subject = 'Revenue_Impacting_';
        Update cas;
        
                cas.type = 'Data entry updates';
        cas.Status = 'closed';
        cas.Secondary_Case_Type__c = 'Closed due to no response';
        cas.subject = 'Data_entry_updates_Contact_Info_';
        Update cas;
        cas.subject = 'Data_entry_updates_Merge_Dups_';
        Update cas;
        cas.subject = 'Data_entry_updates_Missing_ECU_';
        Update cas;
        cas.subject = 'Data_entry_updates_Other_';
        Update cas;
        cas.subject = 'Data_entry_updates_';
        Update cas;
        cas.subject = 'Report_Issue_Case_';
        Update cas;
        cas.subject = 'Other_Case_';
        Update cas;

        cas.SuppliedEmail = 'achalerts_mail@comerica.com';
        cas.Subject = 'abcOther';
        Update cas;

        cas.SuppliedEmail = 'notification@securemail.comerica.com';
        cas.Subject = 'abcOther';
        Update cas;

        cas.SuppliedEmail = 'events@regonline.com';
        cas.Subject = 'abcOther';
        Update cas;
        Test.stopTest();
    }

    // test case business hours
    private static testMethod void test_CaseBusinessHours() {
        Test.startTest();
        Case cas = new Case();
        cas.subject = 'Technical_Support_Access_Issue_';
        cas.description = 'Test Case 4';
        cas.Origin = 'Email - EMEA';
        //cas.type = 'Other';

        List<Case> caseList = new List<Case>();
        caseList.add(cas);
        insert caseList;        
        
        List<Case_SLA__c> sla = new List<Case_SLA__c>();
        Case_SLA__c la = new Case_SLA__c();
        la.Case_Type__c = 'Revenue Impacting';
        la.Secondary_Case_Type__c = 'Credit';
        la.SLA__c = 8;
        la.Comment__c = 'test';
        sla.add(la);
        
        Case_SLA__c la1 = new Case_SLA__c();
        la1.Case_Type__c = 'Revenue Impacting';
        la1.Secondary_Case_Type__c = 'Credit';
        la1.SLA__c = 8;
        la1.Comment__c = 'test';
        sla.add(la1);       
        insert sla;
        
        //businesshoursid = ? 

        caseList[0].type = 'Data entry updates';
        caseList[0].Status = 'closed';
        caseList[0].Secondary_Case_Type__c = 'Closed due to no response';
        cas.description = 'Test Case 5';
        update caseList;

        ACAMSCaseTriggerHandler handler = new ACAMSCaseTriggerHandler();
        //handler.getCaseWithBusinessHours(caseList,null);

        Test.stopTest();
    }
}