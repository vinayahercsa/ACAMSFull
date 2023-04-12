@IsTest
public class LMSUtilityTest {
    
    
    public static LMSCourse__c CreateLMSCourse(String name, String description, Integer credits, String lmsId){
        return new LMSCourse__c(Name = name, Description__c = description, Credits__c = credits, LMSID__c = lmsId);
    }

    public static BeckerLMS_Enrollment__c CreateLMSEnrollment(Id lmsCourseId, Id contactId, Date startDate, Date endDate){
        return new BeckerLMS_Enrollment__c(LMS_Course__c = lmsCourseId, Contact__c = contactId, Start_Date__c = startDate, End_Date__c = endDate, Purchase_Date__c = system.today(), LMS_ID__c = '1');
    }
    

	@isTest
    public static void testUserBuildJson(){

        Account a = new Account(FirstName='FirstName', LastName='LastName',Work_Email__pc=String.valueOf(String.valueOf(Date.today()))+'@test.com');
        insert a;   

        Contact c = new Contact(FirstName='FirstName', LastName='LastName');
        insert c; 
        
        LMSUtility.LMSUserRequest lms = new LMSUtility.LMSUserRequest();
        lms.contactId = c.Id;
        lms.username = 'usernameTest';
        lms.firstName = 'firstName Test';
        lms.lastName = 'lastName Test';
        lms.timezone = 'America/New York';
        lms.language = 'es';
        lms.role = 'STUDENT';
        lms.enabled = true;

        String json_string = LMSUtility.BuildJson(new List<LMSUtility.LMSUserRequest> {lms});
        System.assert(String.isNotBlank(json_string));

    }
    
    
    @isTest
    public static void testEnrollmentCreateBuildJson(){

        Account a = new Account(FirstName='FirstName', LastName='LastName',Work_Email__pc=String.valueOf(String.valueOf(Date.today()))+'@test.com');
        insert a;   

        Contact c = new Contact(FirstName='FirstName', LastName='LastName');
        insert c; 
        
        LMSCourse__c lmsc = CreateLMSCourse('Test Course', 'Test Course Description', 4, '1');
        insert lmsc;
        System.assert(lmsc.Id != NULL);
        
        BeckerLMS_Enrollment__c lmse = CreateLMSEnrollment(lmsc.Id, c.Id, system.today(), system.today().addDays(10));
        insert lmse;
        System.assert(lmse.Id != NULL);
        
        LMSUtility.LMSCreateEnrollmentRequest lms = new LMSUtility.LMSCreateEnrollmentRequest();
        lms.id = lmse.Id;
        lms.enrolleeId = c.Id;
        lms.lmsCourseId = lmsc.LMSID__c;
        lms.name = lmse.Name;
        lms.startDate = (datetime.newInstance(lmse.Start_Date__c.year(), lmse.Start_Date__c.month(),lmse.Start_Date__c.day())).format('YYYY-MM-DD');
        lms.endDate = (datetime.newInstance(lmse.End_Date__c.year(), lmse.End_Date__c.month(),lmse.End_Date__c.day())).format('YYYY-MM-DD');
        lms.purchaseDate = (datetime.newInstance(lmse.Purchase_Date__c.year(), lmse.Purchase_Date__c.month(),lmse.Purchase_Date__c.day())).format('YYYY-MM-DD');
        
        String json_string = LMSUtility.BuildJson(new List<LMSUtility.LMSCreateEnrollmentRequest> {lms});
        System.assert(String.isNotBlank(json_string));
        
    }
    
    
    static testMethod void testEnrollmentUpdateBuildJson(){
        
        Account a = new Account(FirstName='FirstName', LastName='LastName',Work_Email__pc=String.valueOf(String.valueOf(Date.today()))+'@test.com');
        insert a;   

        Contact c = new Contact(FirstName='FirstName', LastName='LastName');
        insert c; 

        LMSCourse__c lmsc = CreateLMSCourse('Test Course', 'Test Course Description', 4, '1');
        insert lmsc;
        System.assert(lmsc.Id != NULL);

        BeckerLMS_Enrollment__c lmse = CreateLMSEnrollment(lmsc.Id, c.Id, system.today(), system.today().addDays(10));
        insert lmse;
        System.assert(lmse.Id != NULL);

        LMSUtility.LMSUpdateEnrollmentRequest lms = new LMSUtility.LMSUpdateEnrollmentRequest();
        lms.id = lmse.Id;
        lms.endDate = (datetime.newInstance(lmse.End_Date__c.year(), lmse.End_Date__c.month(),lmse.End_Date__c.day())).format('YYYY-MM-DD');
        lms.status = lmse.Status__c;

        String json_string = LMSUtility.BuildJson(new List<LMSUtility.LMSUpdateEnrollmentRequest> {lms});
        System.assert(String.isNotBlank(json_string));

    }
    
       
}