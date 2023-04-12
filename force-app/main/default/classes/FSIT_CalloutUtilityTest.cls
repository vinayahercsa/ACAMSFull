/***
 * test class for test CalloutUtility
 * test cases should test whole class method by method
 * @ Ray - May 14, 2020
 */
@IsTest
public with sharing class FSIT_CalloutUtilityTest {
    public FSIT_CalloutUtilityTest() {
        CalloutUtility util = new CalloutUtility();
        System.assertNotEquals(util, null);
    }

    @IsTest
    public static void testGenerateHMACToken() {
        CalloutUtility.secretKey = 'test_private_key';
        //CalloutUtility.generateHMACToken('test-UTF-8');
    }

    @IsTest
    public static void testSendRequest(){
        List<Contact> cnList = FSIT_CalloutUtilityTestDataFactory.createContactRecord();
        insert cnList;

        List<User> userList = FSIT_CalloutUtilityTestDataFactory.createSystemAdminUsers();
        for(User u : userList){
            u.ContactId = cnList[0].Id;
        }

        List<Global_Variable__c> globalVals = FSIT_CalloutUtilityTestDataFactory.createGlobalVariable();
        insert globalVals;

        List<BeckerLMS_Enrollment__c> beckLmsRecords = FSIT_CalloutUtilityTestDataFactory.createBeckLMSEnrollmentRecords(1);
        insert beckLmsRecords;
        List<LMSUtility.LMSUserRequest> lmsuserList = new List<LMSUtility.LMSUserRequest>();
        LMSUtility.LMSUserRequest lmsUser = new LMSUtility.LMSUserRequest();
        lmsUser.username = userList[0].Email;
        lmsUser.lastName=userList[0].lastName;
        //lmsUser.timezone=userList[0].timezone;
        lmsUser.language='English';
        lmsUser.role='CEO';
        lmsUser.customerType='test';
        lmsUser.enabled=true;
        lmsuserList.add(lmsUser);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FSIT_CalloutMock()); 
        CalloutUtility.SendRequest('UserIntegration',true,JSON.serialize(lmsuserList));
        CalloutUtility.SendRequest('EnrollmentIntegration',true,JSON.serialize(lmsuserList));
        CalloutUtility.SendRequest('AccountMergeIntegration',true,JSON.serialize(lmsuserList));
        CalloutUtility.SendRequest('EnrollmentMergeIntegration',true,JSON.serialize(lmsuserList));
        CalloutUtility.GetWebinarEnrollments();
        Test.stopTest();
        
    }

    @isTest
    public static void testSendRequestMerge(){
        List<Contact> cnList = FSIT_CalloutUtilityTestDataFactory.createContactRecord();
        insert cnList;

        List<User> userList = FSIT_CalloutUtilityTestDataFactory.createSystemAdminUsers();
        for(User u : userList){
            u.ContactId = cnList[0].Id;
        }

        List<Global_Variable__c> globalVals = FSIT_CalloutUtilityTestDataFactory.createGlobalVariable();
        insert globalVals;

        List<BeckerLMS_Enrollment__c> beckLmsRecords = FSIT_CalloutUtilityTestDataFactory.createBeckLMSEnrollmentRecords(1);
        insert beckLmsRecords;
        List<LMSUtility.LMSUserRequest> lmsuserList = new List<LMSUtility.LMSUserRequest>();
        LMSUtility.LMSUserRequest lmsUser = new LMSUtility.LMSUserRequest();
        lmsUser.username = userList[0].Email;
        lmsUser.lastName=userList[0].lastName;
        //lmsUser.timezone=userList[0].timezone;
        lmsUser.language='English';
        lmsUser.role='CEO';
        lmsUser.customerType='test';
        lmsUser.enabled=true;
        lmsuserList.add(lmsUser);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FSIT_CalloutMock()); 
        CalloutUtility.SendRequestMerge('UserIntegration',true,JSON.serialize(lmsuserList),cnList[0].Id,'123456678','12345678');
        CalloutUtility.SendRequestMerge('EnrollmentIntegration',true,JSON.serialize(lmsuserList),cnList[0].Id,'123456678','12345678');
        CalloutUtility.SendRequestMerge('AccountMergeIntegration',true,JSON.serialize(lmsuserList),cnList[0].Id,'123456678','12345678');
        CalloutUtility.SendRequestMerge('EnrollmentMergeIntegration',true,JSON.serialize(lmsuserList),cnList[0].Id,'123456678','12345678');
        Test.stopTest();
    }
}