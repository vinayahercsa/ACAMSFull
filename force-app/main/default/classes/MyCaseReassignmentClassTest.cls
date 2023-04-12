@IsTest
public with Sharing class MyCaseReassignmentClassTest {
     public testmethod static void TestReassignCaseWithActiveRule(){
        
        profile objProfile = [select id, name from profile where name ='System Administrator' limit 1];
        User objUser = new User();
        objUser.email = 'user@gmail.com';
        objUser.username = 'username@use.com';
        objUser.lastname = 'testuser';
        objUser.Alias = 'alias';
        objUser.TimeZoneSidKey = 'America/Chicago';
        objUser.LocaleSidKey = 'en_US';
        objUser.EmailEncodingKey = 'UTF-8';
        objUser.ProfileId = objProfile.id;
        objUser.LanguageLocaleKey = 'en_US';

        insert objUser;
        
        System.RunAs(objUser){
                   
            test.starttest();
                
                // Create Account
             //   Account accObj = TestUtils.createAccount('Accname' ,true);
                 Account accObj = new Account();
                 accObj.FirstName = 'contactName';
                accObj.LastName = 'contactName';
              //  accObj.MailingCountry = 'United States';
                //objCon.MailingCountryCode = 'US';
              //  accObj.MailingCity = 'liale';
              //  accObj.MailingState = 'AL';
                //objCon.MailingStateCode = 'AL';
             //   accObj.MailingPostalCode = '60532';
              //  accObj.MailingStreet = 'test street';
            //    accObj.email = 'test@gmail.com';
                accObj.Work_Email__pc=String.valueOf(String.valueOf(Date.today()))+'@test.com';
                insert accObj;

                system.assert(accObj.id <> Null);
               
               // Create Contact
                Contact objCon = new Contact();
                objCon.FirstName = 'contactName';
                objCon.LastName = 'contactName';
              //  objCon.AccountId = accObj.id;
                objCon.MailingCountry = 'US';
                //objCon.MailingCountryCode = 'US';
                objCon.MailingCity = 'Chicago';
                objCon.MailingState = 'IL';
                //objCon.MailingStateCode = 'AL';
                objCon.MailingPostalCode = '60616';
                objCon.MailingStreet = 'test street';
                objCon.email = 'test@gmail.com';
                
                insert objCon;
                system.assert(objCon.id <> Null);  
                
                // Create Case
                Case objCase = new Case();
                objCase.subject = 'Subject';
                objCase.description = 'description';
                objCase.status = 'New';
                objCase.Priority = 'Medium';
              
                
                insert objCase;
                system.assert(objCase.id <> Null);
            objCase.Priority = 'High';
            Update objCase;
                
                MyCaseReassignmentClass.reassignCaseWithActiveRule(objCase.id);
                
            test.stoptest();
        }
        
    }


}