@IsTest
class ACAMSAccountTriggerHandlerTest {

    @IsTest
    static void testBillingCountryCodeUpdated() {
        List<Account> accounts = new List<Account>();
        Account account1 = new Account();
        account1.Name = 'testAccount1';
        account1.BillingCountryCode = 'US';
        accounts.add(account1);
        Account account2 = new Account();
        account2.Name = 'testAccount2';
        account2.BillingCountryCode = 'US';
        accounts.add(account2);
        insert accounts;

        account1.BillingCountryCode = 'UY';
        account2.BillingCountryCode = 'SI';
        update accounts;

        List<Account> updatedAccounts = [
                SELECT
                        Id,
                        Billing_Named_Territory__c
                FROM
                        Account
                WHERE
                        Id IN :accounts
        ];

        System.assert(updatedAccounts.get(0).Billing_Named_Territory__c.equals('LATAM'));
        System.assert(updatedAccounts.get(1).Billing_Named_Territory__c.equals('Other Europe'));
    }

    @IsTest
    static void testPrimaryEmailCheck() {
        RecordType personAccountRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'PersonAccount' AND SobjectType = 'Account'];

        Account newAccount = new Account();
        newAccount.Work_Email__pc = 'sftest@test.com';
        newAccount.FirstName = 'testFirstName';
        newAccount.LastName = 'testLastName';
        newAccount.RecordTypeId = personAccountRecordType.Id;
        insert newAccount;

        Account updatedAccount = [
                SELECT
                        PersonEmail
                FROM
                        Account
                WHERE
                        Id = :newAccount.Id
        ];

        System.assertEquals(newAccount.Work_Email__pc, updatedAccount.PersonEmail);
    Integer randomIntper = Integer.valueOf(math.rint(math.random()*1000000));
        newAccount.Secondary_Email__pc = 'personalemail'+randomIntper+'@test.com';
        newAccount.Primary_Email__pc = 'Personal';
        update newAccount;

        updatedAccount = [
                SELECT
                        PersonEmail
                FROM
                        Account
                WHERE
                        Id = :newAccount.Id
        ];

        System.assertEquals(newAccount.Secondary_Email__pc, updatedAccount.PersonEmail);
    Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        newAccount.Other_Email__pc = 'otheremail'+randomInt+'@test.com';
        newAccount.Primary_Email__pc = 'Other';
        update newAccount;

        updatedAccount = [
                SELECT
                        PersonEmail
                FROM
                        Account
                WHERE
                        Id = :newAccount.Id
        ];

        System.assertEquals(newAccount.Other_Email__pc, updatedAccount.PersonEmail);
    }

    @IsTest
    static void testAccountGroupUpdatesPrivate() {
        CCAviTestUtil testUtil = new CCAviTestUtil();
        testUtil.initData();
        RecordType personAccountRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'PersonAccount' AND SobjectType = 'Account'];


        User testUser1 = new User();
	testUser1.FirstName = 'Test';
	testUser1.LastName = 'User 1';
	testUser1.Username = 'testuser1@example.com';
	testUser1.Profile.Name = 'Sales Manager';
     Insert testUser1;
        
        Account newAccount = new Account();
        newAccount.Work_Email__pc = 'sftest@test.com';
        newAccount.FirstName = 'testFirstName';
        newAccount.LastName = 'testLastName';
        newAccount.ACAMS_Cert__c = true;
        newAccount.Member_Flag__c=true;
        newAccount.Created_By_User__c=testUser1.Id;
        newAccount.RecordTypeId = personAccountRecordType.Id;
        insert newAccount;

        Account updatedAccount = [
                SELECT
                        ccrz__E_AccountGroup__r.Name
                FROM
                        Account
                WHERE
                        Id = :newAccount.Id
        ];

        System.assertEquals(ACAMSUtil.PORTAL_ACCOUNT, updatedAccount.ccrz__E_AccountGroup__r.Name);

        updatedAccount.Membership_Type__pc = ACAMSUtil.MEMBER_CAPS;
        update updatedAccount;

        updatedAccount = [
                SELECT
                        ccrz__E_AccountGroup__r.Name
                FROM
                        Account
                WHERE
                        Id = :newAccount.Id
        ];

        System.assertEquals(ACAMSUtil.PORTAL_ACCOUNT_MEMBER, updatedAccount.ccrz__E_AccountGroup__r.Name);

        updatedAccount.Membership_Type__pc = ACAMSUtil.ENTERPRISE_CAPS;
        update updatedAccount;

        updatedAccount = [
                SELECT
                        ccrz__E_AccountGroup__r.Name
                FROM
                        Account
                WHERE
                        Id = :newAccount.Id
        ];

        System.assertEquals(ACAMSUtil.PORTAL_ACCOUNT_MEMBER, updatedAccount.ccrz__E_AccountGroup__r.Name);

        updatedAccount.Membership_Type__pc = ACAMSUtil.NON_MEMBER_CAPS;
        update updatedAccount;

        updatedAccount = [
                SELECT
                        ccrz__E_AccountGroup__r.Name
                FROM
                        Account
                WHERE
                        Id = :newAccount.Id
        ];

        System.assertEquals(ACAMSUtil.PORTAL_ACCOUNT, updatedAccount.ccrz__E_AccountGroup__r.Name);
    }

    @IsTest
    static void testAccountGroupUpdatesPublic() {
        CCAviTestUtil testUtil = new CCAviTestUtil();
        testUtil.initData();
        RecordType personAccountRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'PersonAccount' AND SobjectType = 'Account'];

        Account newAccount = new Account();
        newAccount.Work_Email__pc = 'test@test.mil';
        newAccount.FirstName = 'testFirstName';
        newAccount.LastName = 'testLastName';
        newAccount.RecordTypeId = personAccountRecordType.Id;
        newAccount.PersonEmail = 'workemail@test.mil';
        newAccount.Industry = ACAMSUtil.INDUSTRY_GOV_REGULATORY;
        insert newAccount;

        Account updatedAccount = [
                SELECT
                        ccrz__E_AccountGroup__r.Name
                FROM
                        Account
                WHERE
                        Id = :newAccount.Id
        ];

        System.assertEquals(ACAMSUtil.PORTAL_ACCOUNT_GOV, updatedAccount.ccrz__E_AccountGroup__r.Name);

        updatedAccount.Membership_Type__pc = ACAMSUtil.MEMBER_CAPS;
        update updatedAccount;

        updatedAccount = [
                SELECT
                        ccrz__E_AccountGroup__r.Name
                FROM
                        Account
                WHERE
                        Id = :newAccount.Id
        ];

        System.assertEquals(ACAMSUtil.PORTAL_ACCOUNT_GOV_MEMBER, updatedAccount.ccrz__E_AccountGroup__r.Name);

        updatedAccount.Chapter_Member__pc = true;
        update updatedAccount;

        updatedAccount = [
                SELECT
                        ccrz__E_AccountGroup__r.Name
                FROM
                        Account
                WHERE
                        Id = :newAccount.Id
        ];

        System.assertEquals('Government/Member', updatedAccount.ccrz__E_AccountGroup__r.Name);

        updatedAccount.Membership_Type__pc = ACAMSUtil.ENTERPRISE_CAPS;
        update updatedAccount;

        updatedAccount = [
                SELECT
                        ccrz__E_AccountGroup__r.Name
                FROM
                        Account
                WHERE
                        Id = :newAccount.Id
        ];

        System.assertEquals('Government/Member', updatedAccount.ccrz__E_AccountGroup__r.Name);

        updatedAccount.Membership_Type__pc = ACAMSUtil.NON_MEMBER_CAPS;
        update updatedAccount;

        updatedAccount = [
                SELECT
                        ccrz__E_AccountGroup__r.Name
                FROM
                        Account
                WHERE
                        Id = :newAccount.Id
        ];

        System.assertEquals(ACAMSUtil.PORTAL_ACCOUNT_GOV, updatedAccount.ccrz__E_AccountGroup__r.Name);
        
         List<Account_method__e> accountMethodEvents = new List<Account_method__e>();
        accountMethodEvents.add(new Account_method__e(Record_ID__c= newAccount.Id,Method_Name__c='MemberUpdateOnUser'));
      Test.startTest();
        List<Database.SaveResult> results = EventBus.publish(accountMethodEvents);
      Test.stopTest();
      System.assertEquals(true, results[0].isSuccess());
    }
   //csa fix:added method for code coverage: 
     @IsTest
    static void testAfterInsert(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', FirstName='Drupal', LastName='Integration', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName='drupalintegration@adtalem.com.acamsprd.acamsprod');
        insert u;

        System.runAs(u){
        Test.startTest();
        Account ac=new Account();
         ac.Name='Test Account';   
         ac.ACAMS_Cert__c=true;
         ac.Member_Flag__c=true;
          insert ac;  
        }
        Test.stopTest();
    }  
 @IsTest
    static void testAfterUp(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', FirstName='Drupal', LastName='Integration', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName='drupalintegration@adtalem.com.acamsprd.acamsprod');
        insert u;

        System.runAs(u){
            Account ac=new Account();
         ac.Name='Test Account';   
         ac.ACAMS_Cert__c=false;
         ac.Member_Flag__c=false;
          insert ac; 
        Test.startTest();
         ac.ACAMS_Cert__c=true;
         ac.Member_Flag__c=true;
            update ac;
        }
        Test.stopTest();
    }  
}