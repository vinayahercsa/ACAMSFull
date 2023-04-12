global without sharing class ACAMSOrderAssetGenerateBatch implements Schedulable, Database.Batchable<SObject> {

    global void execute(SchedulableContext context) {
Database.executeBatch(new ACAMSOrderAssetGenerateBatch(), integer.valueOf(system.label.OrderAssetRegenerateScope));
    }

    global Database.QueryLocator start(Database.BatchableContext context) {
        Datetime dt = System.now().addHours(-1);
        return Database.getQueryLocator([
                SELECT
                        Id,
                        (
                                SELECT Id
                                FROM Assets__r
                        )
                FROM
                        ccrz__E_Order__c
                WHERE
                (
                        (
                                Assets_Assigned__c = 0
                                OR
                                Assets_Assigned__c = NULL
                        )
                    AND (
                                Assets_Unassigned__c = 0
                                OR
                                Assets_Unassigned__c = NULL
                        )
                )
                AND
                        CreatedDate >= :dt
                AND
                        ccrz__Name__c != 'Refunded Order'
        ]);
    }


    global void execute(Database.BatchableContext param1, List<ccrz__E_Order__c> orders) {
       /* for (ccrz__E_Order__c o : orders) {
            if (o.Assets__r.isEmpty()) {
                ACAMSAssetHelper.generateAssets(o.Id);
            } 
        }*/
    }

    global void finish(Database.BatchableContext param1) {
     // ACAMSActivateAssetsBatch aoa= new ACAMSActivateAssetsBatch();
    //Database.executeBatch(aoa,1);
    }
}