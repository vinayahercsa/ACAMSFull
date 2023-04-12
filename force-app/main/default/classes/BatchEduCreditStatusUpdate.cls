global class BatchEduCreditStatusUpdate implements Database.Batchable<sObject> {
  global Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        String query = 'select Id, Credit_End_Date__c, Status__c from Educational_Credit_Unit_Legacy__c where Credit_End_Date__c = Yesterday';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Educational_Credit_Unit_Legacy__c> records){
        // process each batch of records
        List<Educational_Credit_Unit_Legacy__c> eduCreditList = new List<Educational_Credit_Unit_Legacy__c>();
        Date beforeday = Date.Today().addDays(-1);
        for(Educational_Credit_Unit_Legacy__c eduCredit : records){
            if(eduCredit.Credit_End_Date__c == beforeday && eduCredit.Status__c != 'Dormant'){
                eduCredit.Status__c = 'Dormant';
                eduCreditList.add(eduCredit);
            }            
        }
        if(!eduCreditList.isEmpty()){
            Database.update(eduCreditList);
        }
    }
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}