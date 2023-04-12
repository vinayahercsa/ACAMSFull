@IsTest
public class ACAMSLeadTriggerHandlerTest {
    @IsTest
    public static  void createLeadWithReassign(){
        List<Lead> leadList = new List<Lead>{
            new Lead(Status='New',LastName='TestLast',FirstName='TestFirstName',Company='test company',Reassign__c=false,Country='US', State='IL',Phone='+85223456789',MobilePhone='+45223456789')
        };
        insert leadList;
        
        for(Lead l : leadList){
            l.Reassign__c = true;
        }
        update leadList;
        System.assertEquals(true, leadList[0].Reassign__c);
    }
}