@istest
public class UpdateAccountAfterOrderRufundTest {
   @istest  
     static void UpdateAccountAfterOrderRufundMethodtest(){ 
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
        account1.Work_Email__pc = 'sftest@test.com';
        account1.FirstName = 'testFirstName';
        account1.LastName = 'testLastName';
        account1.RecordTypeId=Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        accounts.add(account1);
        Account account2 = new Account();
        account2.Work_Email__pc = 'Governament@benefits.gov';
        account2.FirstName = 'GovFirstName';
        account2.LastName = 'GovLastName';
        account2.Industry = ACAMSUtil.INDUSTRY_GOV_ENFORCEMENT;
        //account2.Membership_Type__pc = ACAMSUtil.MEMBER_CAPS;  
        //account2.Chapter_Member__pc=true;
        account2.RecordTypeId=Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        accounts.add(account2); 
        Account account3 = new Account();
        account3.Work_Email__pc = 'Governamenttest@benefits.gov';
        account3.FirstName = 'GovtestFirstName';
        account3.LastName = 'GovtestLastName';
        account3.Industry = ACAMSUtil.INDUSTRY_GOV_REGULATORY;
        account3.ccrz__E_AccountGroup__c = null;
        //account3.Chapter_Member__pc=true;
        account3.RecordTypeId=Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        accounts.add(account3); 
        Account account4 = new Account();
        account4.Name = 'BusinessAccount';
        account4.Company_Name__c = 'TestCompany';
        account4.Industry=ACAMSUtil.INDUSTRY_GOV_ENFORCEMENT; 
        //account4.Run_Membership_Certification_Logic__pc=true;
        //account4.Chapter_Member__pc=true;
        //account4.RecordTypeId=Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        accounts.add(account4);  
        insert accounts;
       
        set<id> setid=new set<id>();
        setid.add(accounts[0].id);
        setid.add(accounts[1].id);
        setid.add(accounts[2].id);
        setid.add(accounts[3].id); 
        UpdateAccountAfterOrderRufund.UpdateAccountAfterOrderRufundMethod(setid);

     }
}