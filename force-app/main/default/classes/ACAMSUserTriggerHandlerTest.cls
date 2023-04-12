@IsTest
public class ACAMSUserTriggerHandlerTest {
     String orgId = UserInfo.getOrganizationId();
     String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
     Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
     String uniqueName = orgId + dateString + randomInt;

    @IsTest
    public static void testPortalAccountSet() {
        String orgId = UserInfo.getOrganizationId();
     String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
     Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
     String uniqueName = orgId + dateString + randomInt;

        User drupalIntegrationUser = ACAMSUserDAO.getDrupalIntegrationUser();
        System.runAs(drupalIntegrationUser) {
            ccrz__E_AccountGroup__c portalAccountGroup = new ccrz__E_AccountGroup__c(
                    Name = ACAMSUtil.PORTAL_ACCOUNT
            );
            insert portalAccountGroup;

            RecordType personAccountRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'PersonAccount' AND SobjectType = 'Account'];

            Account newAccount = new Account();
            newAccount.Work_Email__pc = 'test21@test.com';
            newAccount.FirstName = 'testFirstName';
            newAccount.LastName = 'testLastName';
            newAccount.RecordTypeId = personAccountRecordType.Id;
            insert newAccount;

            Account updatedAccount = [
                    SELECT
                            Id, PersonContactId
                    FROM
                            Account
                    WHERE
                            PersonEmail = 'test21@test.com'
            ];

            User newUser = new User();
            newUser.ContactId = updatedAccount.PersonContactId;
            newUser.Username = uniqueName + '@test' + orgId + '.org';
            newUser.LastName = uniqueName + '@test' + orgId + '.org';
            newUser.Email = 'test21@test.com';
            newUser.Alias = 'alias';
            newUser.TimeZoneSidKey = 'GMT';
            newUser.LocaleSidKey = 'en_US';
            newUser.EmailEncodingKey = 'UTF-8';
            newUser.ProfileId = ACAMSUserDAO.getB2BProfile().Id;
            newUser.LanguageLocaleKey = 'en_US';
            insert newUser;

            Account updatedAccount2 = [
                    SELECT
                            Id, ccrz__E_AccountGroup__c
                    FROM
                            Account
                    WHERE
                            PersonEmail = 'test21@test.com'
            ];

            System.assert(updatedAccount2.ccrz__E_AccountGroup__c == portalAccountGroup.Id);
        }
    }

    @IsTest
    public static void testMilPortalAccountSet() {
  String orgId = UserInfo.getOrganizationId();
     String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
     Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
     String uniqueName = orgId + dateString + randomInt;
        User drupalIntegrationUser = ACAMSUserDAO.getDrupalIntegrationUser();
        System.runAs(drupalIntegrationUser) {
            ccrz__E_AccountGroup__c portalAccountGroup = new ccrz__E_AccountGroup__c(
                    Name = ACAMSUtil.PORTAL_ACCOUNT_GOV
            );
            insert portalAccountGroup;

            RecordType personAccountRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'PersonAccount' AND SobjectType = 'Account'];

            Account newAccount = new Account();
            newAccount.Work_Email__pc = 'test@test.mil';
            newAccount.FirstName = 'testFirstName';
            newAccount.LastName = 'testLastName';
            newAccount.RecordTypeId = personAccountRecordType.Id;
            insert newAccount;

            Account updatedAccount = [
                    SELECT
                            Id, PersonContactId
                    FROM
                            Account
                    WHERE
                            PersonEmail = 'test@test.mil'
            ];

            User newUser = new User();
            newUser.ContactId = updatedAccount.PersonContactId;
            newUser.Username = uniqueName + '@test' + orgId + '.org';
            newUser.LastName = 'testLastName';
            newUser.Email = uniqueName + '@test' + orgId + '.org';
            newUser.Alias = 'alias';
            newUser.TimeZoneSidKey = 'GMT';
            newUser.LocaleSidKey = 'en_US';
            newUser.EmailEncodingKey = 'UTF-8';
            newUser.ProfileId = ACAMSUserDAO.getB2BProfile().Id;
            newUser.LanguageLocaleKey = 'en_US';
            test.startTest();
            insert newUser;
            test.stopTest();

            Account updatedAccount2 = [
                    SELECT
                            Id, ccrz__E_AccountGroup__c
                    FROM
                            Account
                    WHERE
                            PersonEmail = 'test@test.mil'
            ];

            System.assert(updatedAccount2.ccrz__E_AccountGroup__c == portalAccountGroup.Id);
        }
    }

    @IsTest
    public static void testGovPortalAccountSet() {

        User drupalIntegrationUser = ACAMSUserDAO.getDrupalIntegrationUser();
        System.runAs(drupalIntegrationUser) {
            ccrz__E_AccountGroup__c portalAccountGroup = new ccrz__E_AccountGroup__c(
                    Name = ACAMSUtil.PORTAL_ACCOUNT_GOV
            );
            insert portalAccountGroup;

            RecordType personAccountRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'PersonAccount' AND SobjectType = 'Account'];

            Account newAccount = new Account();
            newAccount.Work_Email__pc = 'sftest@test.gov';
            newAccount.FirstName = 'testFirstName';
            newAccount.LastName = 'testLastName';
            newAccount.RecordTypeId = personAccountRecordType.Id;
            insert newAccount;

            Account updatedAccount = [
                    SELECT
                            Id, PersonContactId
                    FROM
                            Account
                    WHERE
                            PersonEmail = 'sftest@test.gov'
            ];

            User newUser = new User();
            newUser.ContactId = updatedAccount.PersonContactId;
            newUser.Username = 'sftest@test.gov';
            newUser.LastName = 'testLastName';
            newUser.Email = 'sftest@test.gov';
            newUser.Alias = 'alias';
            newUser.TimeZoneSidKey = 'GMT';
            newUser.LocaleSidKey = 'en_US';
            newUser.EmailEncodingKey = 'UTF-8';
            newUser.ProfileId = ACAMSUserDAO.getB2BProfile().Id;
            newUser.LanguageLocaleKey = 'en_US';
            insert newUser;

            Account updatedAccount2 = [
                    SELECT
                            Id, ccrz__E_AccountGroup__c
                    FROM
                            Account
                    WHERE
                            PersonEmail = 'sftest@test.gov'
            ];

            System.assert(updatedAccount2.ccrz__E_AccountGroup__c == portalAccountGroup.Id);
        }
    }
    @IsTest
    public static void testResetPassword() {
        User newUser = new User();
        User drupalIntegrationUser = ACAMSUserDAO.getDrupalIntegrationUser();
        System.runAs(drupalIntegrationUser) {
            ccrz__E_AccountGroup__c portalAccountGroup = new ccrz__E_AccountGroup__c(Name = ACAMSUtil.PORTAL_ACCOUNT);
            insert portalAccountGroup;

            RecordType personAccountRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'PersonAccount' AND SobjectType = 'Account'];
            Test.startTest();
            Account newAccount = new Account();
            newAccount.Work_Email__pc = 'test221@test.com';
            newAccount.FirstName = 'testFirstName';
            newAccount.LastName = 'testLastName';
            newAccount.RecordTypeId = personAccountRecordType.Id;
            insert newAccount;

            Account updatedAccount = [
                    SELECT
                            Id, PersonContactId
                    FROM
                            Account
                    WHERE
                            PersonEmail = 'test221@test.com'
            ];

            
            newUser.ContactId = updatedAccount.PersonContactId;
            newUser.Username = 'test221@test.com';
            newUser.LastName = 'testLastName';
            newUser.Email = 'test221@test.com';
            newUser.Alias = 'alias';
            newUser.TimeZoneSidKey = 'GMT';
            newUser.LocaleSidKey = 'en_US';
            newUser.EmailEncodingKey = 'UTF-8';
            newUser.ProfileId = ACAMSUserDAO.getB2BProfile().Id;
            newUser.LanguageLocaleKey = 'en_US';
            insert newUser;
            Test.stopTest();
            }
            User nuser = new User(Id=newUser.id, Reset_Password__c=true);
            update nuser;
            
            
            nuser = [Select ID, Generated_Password__c FROM USER where Id=:nuser.id];
          
            System.assertNotEquals(null,nuser.Generated_Password__c);
    }
    @IsTest
    public static void testLMSuserTest() {
           ccrz__E_AccountGroup__c portalAccountGroup = new ccrz__E_AccountGroup__c(
                    Name = ACAMSUtil.PORTAL_ACCOUNT
            );
            insert portalAccountGroup;

            RecordType personAccountRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'PersonAccount' AND SobjectType = 'Account'];

            Account newAccount = new Account();
            newAccount.Work_Email__pc = 'test212@test.com';
            newAccount.FirstName = 'testFirstName';
            newAccount.LastName = 'testLastName';
            newAccount.RecordTypeId = personAccountRecordType.Id;
            insert newAccount;

            Account updatedAccount = [
                    SELECT
                            Id, PersonContactId
                    FROM
                            Account
                    WHERE
                            PersonEmail = 'test212@test.com'
            ];

            User newUser = new User();
            newUser.ContactId = updatedAccount.PersonContactId;
            newUser.Username = 'test212@test.com';
            newUser.LastName = 'testLastName';
            newUser.Email = 'test212@test.com';
            newUser.Alias = 'alias';
            newUser.TimeZoneSidKey = 'GMT';
            newUser.LocaleSidKey = 'en_US';
            newUser.EmailEncodingKey = 'UTF-8';
            newUser.ProfileId = ACAMSUserDAO.getB2BProfile().Id;
            newUser.LanguageLocaleKey = 'en_US';
            newUser.LMS_Role__c = 'SUPPORT';
            insert newUser;
            newUser = [Select ID, ContactId, LMS_Role__c, TimeZoneSidKey, Membership_Type__c, AccountId, Username, FirstName, LastName, Contact_Member_Type__c FROM User where ID=:newUser.Id];
            ACAMSUserTriggerHandler.UpsertLMSUser(new List<user>{newUser},null);

        }
}