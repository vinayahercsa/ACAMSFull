@isTest
public class ACAMSMemsandCertTriggerHandler_Test {
    static TestMethod void testCertification(){
        Account a = New Account();
        a.Name = 'Test Account';
        a.BillingCountry = 'US';
        a.BillingPostalCode = '11111';
        a.BillingState = 'FL';
        a.BillingStreet = '1001 Main Street';
        a.Phone = '555-555-5555';
        insert a;
        System.assert(a.Id != Null);
        
        Contact c = New Contact(LastName = 'Contact Last Name', AccountId = a.Id);
        insert c;
        system.assert(c.Id != Null);
        
        Certification_Application__c ca = New Certification_Application__c();
        ca.Contact__c = c.Id;
        ca.Asset_Pending_to_Process__c = true;
        insert ca;
        System.assert(ca.Id != Null);
        
        Memberships_and_Certifications__c memCertRed = New Memberships_and_Certifications__c();
        memCertRed.Certification_Application__c = ca.Id;
        memCertRed.Certification_or_Membership__c = 'ACCA Membership';
        memCertRed.Approved__c = True;
        insert memCertRed;
        
        memCertRed.Certification_or_Membership__c = 'CPA';
        Update memCertRed;
        system.assert(memCertRed.Id != Null);
        
    }
}