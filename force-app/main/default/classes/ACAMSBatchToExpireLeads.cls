global class ACAMSBatchToExpireLeads  implements Schedulable,  Database.Batchable<SObject>  {
    
       global void execute(SchedulableContext context) {
        Database.executeBatch(new ACAMSBatchToExpireLeads(),500);
    }
    
        global Database.QueryLocator start(Database.BatchableContext context) {
         Date d = System.today().addDays(-90);
         Date dStart = System.today().addDays(Integer.valueOf(label.ExpireLeadsStartDate));
        return Database.getQueryLocator([
            SELECT ID,
      Expired__c,Status

            FROM
            Lead
            WHERE
            (Status =:'Attempting Contact' OR Status =:'Not Contacted') AND Expired__c =:false AND isconverted =:false AND
          CreatedDate <: d AND CreatedDate >: dStart limit 15000
        ]);
    }
    
     global void execute(Database.BatchableContext param1, List<Lead> Leads) {
         system.debug('Expired leads List size:'+Leads.size());
         List<Lead> leadsToUpdate = new List<Lead>();
         for (Lead l : Leads) {
             l.Expired__c =true;
             leadsToUpdate.add(l);
     }
         system.debug('leadsToUpdate list:'+leadsToUpdate);
            if (leadsToUpdate != NULL && leadsToUpdate.size() > 0) {
                try{
            DMLUtility.UpdateSObjects(leadsToUpdate);
                }
      catch(DmlException e) {
    System.debug('The following exception has occurred: ' + e.getMessage());
}
        }
     }
    global void finish(Database.BatchableContext param1) {
        
    }

}