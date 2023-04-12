@isTest
private class TestAttachmentHelper {

    static testMethod void testController() {
        Account a = CreateAccount();
        insert a;
        System.assert(a.Id != NULL);

        Contact c = new Contact(LastName = 'Contact Last Name', AccountId = a.id);
        insert c;
        System.assert(c.Id != NULL);
        
        User u = CreateUser('Overage Authenticated Website User ACAMS');
        u.ContactId = c.Id;
        insert u;
        System.assert(u.Id != NULL);
        
        Certification_Application__c ca = new Certification_Application__c(Contact__c = c.Id, Status__c = 'Started');
        insert ca;
        Education__c eduRed = createEducationRecord(ca,'Associate Degree (Diploma)');
        Memberships_and_Certifications__c memCertRec = createMemCertRecord(ca);
        Training__c extTrainRec = createExtTrainRecord(ca);
        System.assert(ca.Id != NULL); 
        Test.StartTest();
        insert eduRed;
        insert memCertRec;
        insert extTrainRec;
        Attachment att1 = createAttachment(eduRed.ID);
        Attachment att2 = createAttachment(memCertRec.ID);
        Attachment att3 = createAttachment(extTrainRec.Id);
        insert new List <Attachment>{att1,att2,att3};
        Test.StopTest();
   }
       public static Attachment createAttachment(Id parId){
        Attachment attach=new Attachment();     
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=parId;
        return attach;
    }
       public static Account CreateAccount(){

        Account a = new Account();
        a.Name = 'Test Account';
        a.BillingCountry = 'US';
        a.BillingPostalCode = '11111';
        a.BillingState = 'FL';
        a.BillingStreet = '1000 Main Street';
        a.Phone = '555-555-5555';
        
        
        return a;
    }
       public static User CreateUser(String profileName){
        //Profile p = [select id from profile where name = 'Customer Community Login User-clone' LIMIT 1];
        Profile p = [select id from profile where name = 'B2B Storefront Registered Login Users acams' LIMIT 1];
         
        User u = new User
        (
            alias = 'alias',
            email='email' + staticAutoNumber + '@salesforce.com',
            emailencodingkey='UTF-8',
            lastname='lastname',
            languagelocalekey='en_US',
            localesidkey='en_US',
            profileid = p.Id,
            timezonesidkey='America/Los_Angeles',
            username='username' + staticAutoNumber + '@salesforce.com'
        );
        
        return u;
    }
    public static Integer staticAutoNumber {
        get {
            if (staticAutoNumber == null)
                staticAutoNumber = 0;
            return staticAutoNumber++;
        }
        private set;
    }
        public static Education__c createEducationRecord(Certification_Application__c certAppRec , string education)    {
        Education__c  eduRec = new Education__c (Certification_Application__c = certAppRec.Id,Education__c = education);
        return eduRec;
    }
     public static Memberships_and_Certifications__c createMemCertRecord(Certification_Application__c certAppRec)    {
        Memberships_and_Certifications__c memCertRed = new Memberships_and_Certifications__c(Certification_Application__c = certAppRec.Id,Certification_or_Membership__c = 'CPA');
        return memCertRed ;
    }
    public static Training__c createExtTrainRecord(Certification_Application__c certAppRec)    {
        Training__c extTrainRec = new Training__c(Certification_Application__c = certAppRec.Id,Name__c = 'test', Credit_hours__c=2);
        return extTrainRec ;
        }

}