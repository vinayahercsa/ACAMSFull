/*
 * Class Name: schBatchWebinarsUpdate - Schedule Batch class to update Webinars
 * 8/28/2017           mmurphy               Created class.
*/

global class schBatchWebinarsUpsert implements Schedulable {
    global void execute(SchedulableContext SC) {
         integer batchScope;
         Map<String, Global_Variable__c> global_variableMap = Global_Variable__c.getAll();
         batchScope = Integer.ValueOf(global_variableMap.get('LMS.WebinarIntegration.BatchSize').Value__c);
        BatchWebinarsUpsert  objBatch = new BatchWebinarsUpsert();
       Id Batchid = database.executebatch(objBatch,batchScope);
       //Id Batchid = database.executebatch(objBatch);
    }
}