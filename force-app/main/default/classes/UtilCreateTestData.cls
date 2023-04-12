@isTest(SeeAllData=true)
public class UtilCreateTestData {
    /** Added Jul 17, 2019 by Larry Resnik. Use to make "unique" usernames. */
    public static Integer staticAutoNumber {
        get {
            if (staticAutoNumber == null)
                staticAutoNumber = 0;
            return staticAutoNumber++;
        }
        private set;
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
    

    public static Asset CreateAsset(){
        Account account = UtilCreateTestData.CreateAccount();
        insert account;
        
        Asset asset = new Asset();
        asset.Name = 'Test Asset 1';
        
        return asset;
    }

    public static Asset CreateAsset(String name, Id assignee, Id productId, Id accountId){
        Asset asset = new Asset();
        asset.Name = name;
        asset.Assignee__c = assignee;
        asset.AccountId = accountId;
        asset.Product2Id = productId;
        asset.Status = 'Active';
        asset.Paid_Cert1__c = true;

        return asset;
    }


    
    public static User CreateUser(String profileName){
        //Profile p = [select id from profile where name = 'Customer Community Login User-clone' LIMIT 1];
        Profile p = [select id from profile where name = 'Customer Community Login User - CCL License Profile Clone' LIMIT 1];
         
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
    public static User CreateUserSysAdmin(String profileName){
        //Profile p = [select id from profile where name = 'Customer Community Login User-clone' LIMIT 1];
        Profile p = [select id from profile where name = 'System Administrator' LIMIT 1];
         
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
    
    public static Contact CreateContact(User u){
        Contact c = CreateContact();
        c.FirstName = u.firstname;
        c.LastName = u.LastName;
        c.Email = u.Email;
        
        return c;
    }    
    
    public static Contact CreateContact(){
        Contact c = new Contact();
        c.LastName = 'lastname';
        
        return c;
    }

    public static Contact CreateContact(String firstName, String lastName, Id accountId){
        return new Contact(FirstName = firstName, LastName = lastName, AccountId = accountId);
    }

    public static User RegisterTestUser(String accId, User u){
        //  Create Contact and Insert
        Contact c = UtilCreateTestData.CreateContact(u);
        c.AccountId = accid;
        insert c;
        
system.debug('@@@c: ' + c);
        
        //  Insert User Record
        u.ContactId = c.Id;
//      u.AccountId = accid;
        insert u;
system.debug('@@@u: ' + u);

        return u;       
    }

    public static Global_Variable__c CreateGlobalVariable(String name, String value){
        return new Global_Variable__c(Name = name, Value__c = value);
    }

    public static LMSCourse__c CreateLMSCourse(String name, String description, Integer credits, String lmsId){
        return new LMSCourse__c(Name = name, Description__c = description, Credits__c = credits, LMSID__c = lmsId);
    }

    public static BeckerLMS_Enrollment__c CreateLMSEnrollment(Id lmsCourseId, Id contactId, Date startDate, Date endDate){
        return new BeckerLMS_Enrollment__c(LMS_Course__c = lmsCourseId, Contact__c = contactId, Start_Date__c = startDate, End_Date__c = endDate, Purchase_Date__c = system.today(), LMS_ID__c = '1');
    }



  
}