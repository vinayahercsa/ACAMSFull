@IsTest
public class ACAMS_MergeHelper_Test {

    
    public static LMSCourse__c CreateLMSCourse(String name, String description, Integer credits, String lmsId){
        return new LMSCourse__c(Name = name, Description__c = description, Credits__c = credits, LMSID__c = lmsId);
    }
    public static BeckerLMS_Enrollment__c CreateLMSEnrollment(Id lmsCourseId, Id contactId, Date startDate, Date endDate){
        return new BeckerLMS_Enrollment__c(LMS_Course__c = lmsCourseId, Contact__c = contactId, Account__c = '1234', Start_Date__c = startDate, End_Date__c = endDate, Purchase_Date__c = system.today(), LMS_ID__c = '1');
    }
    

    @IsTest
    public static void MergeLMSUser_Test(){
        
        Test.startTest();
        List<Contact> ctList = new List<Contact>{
            new Contact(FirstName='initialFirstName', LastName='LastName', Description='sometest')
                };
                    insert ctList;
        
        List<Account> acList = new List<Account>{
            new Account(FirstName='initialFirstName', LastName='LastName', Description='sometest', Website='www.test.com',Work_Email__pc=String.valueOf(String.valueOf(Date.today()))+'@test.com')
                };
                    insert acList;

        LMSCourse__c lmsCourse = new LMSCourse__c();
        lmsCourse.Name = 'lmsCourseName';
        insert lmsCourse;


        
        List<BeckerLMS_Enrollment__c> lmsEnrollment = new List<BeckerLMS_Enrollment__c>{
            new BeckerLMS_Enrollment__c(Account__c = acList[0].Id,Purchase_Date__c = Date.today().addDays(-14), LMS_Course__c=lmsCourse.Id)
        };
        insert lmsEnrollment;
        
        set<Id> ids = new set<Id>();     
        map<Id,Account> idac = new map<Id,Account>();
        idac.put(acList[0].Id, acList[0]);
        ACAMS_MergeHelper.MergeLMSUser(acList, idac, 'test', 'test', 'test');   // List<Account> acList, Map<Id, Account> idac, String masterIDmerge, String cntIDmerge, String usernamemerge
        ACAMS_MergeHelper.MergeEnrollment(acList,'testid123');
        Test.stopTest();
       
    }
    
    
    @IsTest
    public static void MergeEnrollment_Test(){
    	List<Account> acList = new List<Account>();
        Account a = new Account(FirstName='FirstName', LastName='LastName', Phone='+13221232321',Work_Email__pc = 'testworkemail@email.com');
        acList.add(a);
        insert acList;   
        

        Contact c = new Contact(FirstName='FirstName', LastName='LastName', Phone='+13221232321');
        insert c; 

        string  masterID = a.id;    // hrj34hr445hkg6h
        string     cntId = 'eu5y22dcck678cq';
        string  username = 'theuser';
        string     LibID = c.id;  // vb36kfawo268dla                    
        
        set<Id> ids = new set<Id>();     
        map<Id,Account> idac = new map<Id,Account>();
        
        LMSCourse__c course = new LMSCourse__c(Name = 'test', LMSID__c = a.id);
        insert course;
        
        BeckerLMS_Enrollment__c enrol = new BeckerLMS_Enrollment__c(Account__c = a.id, LMS_Course__c = course.id, Purchase_Date__c = system.today(), LMS_ID__c = '1');
        insert enrol;
        

        //Account__c = :masterID AND LMS_Course__c =:LibID
                

        ACAMS_MergeHelper.MergeEnrollment(acList, course.Id);          // public static void MergeEnrollment(String masterID, String cntId, String username, String LibID)                                      
    }
    
}