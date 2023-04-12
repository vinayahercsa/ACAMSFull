global class ACAMSEnrollmentCallOutBatch implements schedulable, Database.Batchable<sObject>, Database.AllowsCallouts{
  global void execute(SchedulableContext context) {
       // Database.executeBatch(new ACAMSEnrollmentCallOutBatch(),1); // FSA-2464 changed the scope 
    }
     
    global Database.QueryLocator start(Database.BatchableContext bc){
      Datetime dt = System.now().addHours(-2);
        system.debug('dt::'+dt);
        return Database.getQueryLocator([
            SELECT Id,Time_stamp__c,Response_status__c,Status_code__c,Created_LMS__c,Updated_LMS__c,CreatedById, Account__c, LMS_Course_ID__c,
            Name,Start_Date__c,End_Date__c,Purchase_Date__c
            FROM BeckerLMS_Enrollment__c
            WHERE (Response_status__c != 'OK' OR Status_code__c != '200') 
            AND createdDate >= :dt 
          //AND LastModifiedDate >= :dt
            AND Asset__c != NULL
            
            ]);
    }
     
    global void execute(Database.BatchableContext bc, List<BeckerLMS_Enrollment__c> scope){
        /*for(BeckerLMS_Enrollment__c b : scope) {
            system.debug('b.Id::'+b.Id);
        }
      ACAMSBeckerLMSTriggerHandler.CreateLMSEnrollment(scope); */
    }
  global void finish(Database.BatchableContext param1) {
        
    }
}