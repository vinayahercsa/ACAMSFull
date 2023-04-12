global without sharing class ACAMSEnrollmentsAltBatch implements Schedulable,  Database.Batchable<SObject> {
    
   global void execute(SchedulableContext context) {
       // Database.executeBatch(new ACAMSEnrollmentsAltBatch());
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext context) {
        User drupalUser = ACAMSUserDAO.getDrupalIntegrationUser();
        Datetime dt = System.now().addHours(-2);
        return Database.getQueryLocator([
            SELECT
            Id,Assignee__c,Assignee__r.name, account.name ,Assignee__r.accountid, Accountid,Effective_Date__c,
            LMS_Access_Exp_Date__c,CC_Product__r.LMS_Course__c,CC_Product__r.ccrz__SKU__c,
            (
                SELECT Id
                FROM BeckerLMS_Enrollments__r
            )
            FROM
            Asset
            WHERE
            CC_Product__r.LMS_Course__c != NULL AND 
            Assignee__c != NULL AND (Payment_Status__c =: 'Completed' OR Payment_Status__c =: 'Authorized')
            
            AND
            LastModifiedDate >= :dt
            //AND CreatedById = :drupalUser.Id      commenting this line becasue of FSA-2455
            
              ]);
    }
    
    
    global void execute(Database.BatchableContext param1, List<Asset> Assets) {
        /*List<BeckerLMS_Enrollment__c> lmsEnrollmentsToInsert = new List<BeckerLMS_Enrollment__c>();
        for (Asset a : Assets) {
            if (a.BeckerLMS_Enrollments__r.isEmpty()) {
                BeckerLMS_Enrollment__c lmsEnrollment = new BeckerLMS_Enrollment__c();
                lmsEnrollment.Asset__c = a.Id;
                lmsEnrollment.Contact__c = a.Assignee__c;
                if(a.Assignee__r.name != null && a.account.name != null && a.Assignee__r.name != a.account.name  ){
                    lmsEnrollment.Account__c = a.Assignee__r.accountid;
                    
                } else{
                    lmsEnrollment.Account__c = a.Accountid;
                }
                Date startDate = (a.Effective_Date__c != NULL ? a.Effective_Date__c : System.today());
                lmsEnrollment.Purchase_Date__c = startDate;
                lmsEnrollment.Start_Date__c = startDate;
                lmsEnrollment.End_Date__c = a.LMS_Access_Exp_Date__c;
                lmsEnrollment.LMS_Course__c = a.CC_Product__r.LMS_Course__c;
                lmsEnrollment.GenerateCEU__c = ACAMSBeckerLMSTriggerHandler.GenerateCEU(a.CC_Product__r.ccrz__SKU__c);
                lmsEnrollmentsToInsert.add(lmsEnrollment);
            } 
        }
        System.debug('*****LMSEnrollmentHelper.UpsertEnrollment.lmsEnrollmentsToInsert: ' + lmsEnrollmentsToInsert);
        if (lmsEnrollmentsToInsert != NULL && lmsEnrollmentsToInsert.size() > 0) {
            DMLUtility.InsertSObjects(lmsEnrollmentsToInsert);
        }*/
    }
    
    global void finish(Database.BatchableContext param1) {
        
    }
}