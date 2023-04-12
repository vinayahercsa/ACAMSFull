@isTest
public class GlobalAccountManagerTest {
   @IsTest
    static void UpdateManagerOnAccounttest() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u1 = new User(Alias = 'gmanager', Email = 'gmanager@testorg.com',
        EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',ProfileId = p.Id,
        LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles', UserName = 'gmanager@acams2.org.acams');
        insert u1;
        User u2 = new User(Alias = 'globalm', Email = 'globalm@testorg.com',
        EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',ProfileId = p.Id,
        LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles', UserName = 'globalm@acams2.org.acams');
        insert u2;
        Account_Global_Manager__c AGM = new Account_Global_Manager__c();
        AGM.Name ='ACAMS Test';
        AGM.Global_Account_Manager__c=u1.id;
        insert AGM;
        
        List<Account> accounts = new List<Account>();
        Account account1 = new Account();
        account1.Name = 'testGAM1Account1';
        account1.BillingCountryCode = 'US';
        account1.Company_Name_Inactive__c='ACAMS Test'; 
        accounts.add(account1);
        Account account2 = new Account();
        account2.Name = 'testGAM2Account2';
        account2.BillingCountryCode = 'US';
        account2.Company_Name_Inactive__c='ACAMS Test'; 
        accounts.add(account2);
        insert accounts;
       
        Map<String,id> Mgma= new Map<String,id>();
        AGM.Global_Account_Manager__c= u2.id;
        update AGM;
        Mgma.put(AGM.Name,AGM.Global_Account_Manager__c);
        GlobalAccountManager.UpdateManagerOnAccount(Mgma);            
    }
 }