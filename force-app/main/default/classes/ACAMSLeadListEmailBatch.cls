global without sharing class ACAMSLeadListEmailBatch implements Schedulable, Database.Batchable<SObject> {
    
       global void execute(SchedulableContext context) {
        Database.executeBatch(new ACAMSLeadListEmailBatch());
    }
    global Database.QueryLocator start(Database.BatchableContext context) {
        Datetime dt = System.now().addHours(-1);
        return Database.getQueryLocator([
                SELECT
                        id, whoid , Whatid, status from task where whoid != null AND WhatId != null AND CreatedDate >= :dt
        ]);
    }
    
   global void execute(Database.BatchableContext param1, List<task> tasks) {
       system.debug('List<task> tasks: '+tasks);
       Set<Id> leadidSet = new Set<Id>();
       for(task t : tasks){
           leadidSet.add(t.whoid);
       }
       system.debug('leadidSet : '+leadidSet);
       list<Lead> notContactedLeads = new list<Lead>();
       list<Lead> LeadstoUpdate = new list<Lead>();
       notContactedLeads = [select id,status from lead where id in:leadidSet AND status=:'Not Contacted'];
       system.debug('notContactedLeads : '+notContactedLeads);
       for(Lead l : notContactedLeads){
           l.Status = 'Attempting Contact';
           LeadstoUpdate.add(l);
       }
        system.debug('LeadstoUpdate : '+LeadstoUpdate);
       try{
       update LeadstoUpdate;
       }
       catch(exception ex){
           
       }
    }

    global void finish(Database.BatchableContext param1) {
      
    }


}