@isTest
public class ACAMSValidateQueueNameTriggerHandlerTest {
    
    public Static TestMethod void testM1(){
      Test.startTest();
      Assignment_Group_Name__c G1 = new Assignment_Group_Name__c(); 
        G1.Name= 'TestG';
        G1.Type__c = 'Cases';
        insert G1;
        
        Group gq1 = new Group();
        gq1.Type = 'Queue';
        gq1.Name = 'Testq';
        insert gq1;
        
      Assignment_Group_Queues__c q1 = new Assignment_Group_Queues__c();
        q1.Name = 'Testq';
        q1.Active__c = 'True';
        q1.Assignment_Group_Name__c = G1.id;
        insert q1;

        q1.Valid_Queue__c = true;
        update q1;
        

     List<Assignment_Group_Queues__c>  Assignedgroupqueuelist = new List<Assignment_Group_Queues__C>();
        Assignedgroupqueuelist.add(q1);
        ACAMSValidateQueueNameTriggerHandler s1= new ACAMSValidateQueueNameTriggerHandler();
        s1.ValidateQueueNameProcess(Assignedgroupqueuelist);
        Test.stopTest();
    }

}