public with sharing class ACAMSValidateQueueNameTriggerHandler  extends CCAviTriggerHandler{
    
    private List<Assignment_Group_Queues__c> newList;
    private List<Assignment_Group_Queues__c> oldList;
    private Map<Id, Assignment_Group_Queues__c> newMap;
    private Map<Id, Assignment_Group_Queues__c> oldMap;
    
    public ACAMSValidateQueueNameTriggerHandler(){
        super();
        this.newList = (List<Assignment_Group_Queues__c>) Trigger.new;
        this.oldList = (List<Assignment_Group_Queues__c>) Trigger.old;
        this.newMap = (Map<Id, Assignment_Group_Queues__c>) Trigger.newMap;
        this.oldMap = (Map<Id, Assignment_Group_Queues__c>) Trigger.oldMap;
    }
    
    public override void beforeInsert(){
        this.ValidateQueueNameProcess(this.newList);  
    }
    public override void beforeUpdate(){
        List<Assignment_Group_Queues__c> Assignedgroupqueuelist = new List<Assignment_Group_Queues__c>();
        for(Assignment_Group_Queues__c Assig: this.newList){
            if(Assig.Name != this.oldMap.get(Assig.id).Name)
               Assignedgroupqueuelist.add(Assig); 
        }
        if(!Assignedgroupqueuelist.isEmpty())
            this.ValidateQueueNameProcess(Assignedgroupqueuelist);
            
    }
    
    @TestVisible
    private void ValidateQueueNameProcess(List<Assignment_Group_Queues__c> Assignedgroupqueuelist){
     //Determine if the value of the Queue Name has been updated.  If so Break.
      List<Data_Migration_User__mdt>  dMig = [select MasterLabel, ProfileId__c from Data_Migration_User__mdt where MasterLabel =: 'ProfileId' limit 1 ];
      String pfid = null;
      if(dMig != null && dMig.size() > 0){
        pfid= dMig[0].ProfileId__c;
      }
      ID ProfId = userinfo.getProfileId();
      system.debug(ProfId );
      system.debug(pfid );
      system.debug(ProfId  != pfid);
      if(ProfId  != pfid ){
  
    //Setup Queue lookup Xref map
    //NOTE: the number of Queues supported is limited by Map size (ie. 1000)
    Map<String,Group> Queues = new Map<String,Group>();     //Queue name --> Queue
    
      for (Group[] q :  [SELECT Name FROM Group WHERE Type= 'Queue']) {
        for (Integer i = 0; i < q.size() ; i++) {
            Queues.put(q[i].Name, q[i]);
        }
      }

    
    Map<String,String> agNames = new Map<String,String> ();
      for (Assignment_Group_Queues__c agq : [SELECT Name, Assignment_Group_Name__r.Name
                                            FROM Assignment_Group_Queues__c 
                                            WHERE Active__c = 'True']) {
        agNames.put(agq.Name, agq.Assignment_Group_Name__r.Name);
      }
    
    //Find Queues matching on name
    for (Assignment_Group_Queues__c agq : Assignedgroupqueuelist)
    {
        if (Queues.containsKey(agq.Name))
        {
            Id qId = Queues.get(agq.Name).Id;
            System.debug('>>>>>Queue Id for name ' + agq.Name + ': '+qId);
            
            //Check if Queue is already assigned to an Assignment_Group_Queues__c record
            if (agNames.containsKey(agq.Name)) {
                agq.Valid_Queue__c = false;
                agq.addError('Queue "'+agq.Name+'" already assigned to another Assignment Group "'+agNames.get(agq.Name)+'".');
            } else {
                agq.QueueId__c = qId;
                agq.Valid_Queue__c = true;
            }
        } else {
            //Error: queue not found
            agq.Valid_Queue__c = false;
            agq.addError('Invalid Queue name: Queue name ' + agq.Name + ' cannot be found.');
        }   
    }

    }
    
    }
}