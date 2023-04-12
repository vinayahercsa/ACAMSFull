global without sharing class ACAMSOrderAssetRecalculationBatch implements Database.Batchable<AggregateResult>, Database.Stateful, Schedulable {

    private Datetime lastModifiedDateThreshold = Datetime.now().addHours(-1).addMinutes(-1);

    public ACAMSOrderAssetRecalculationBatch(Datetime lastModifiedDateThreshold) {
        this.lastModifiedDateThreshold = lastModifiedDateThreshold;
    }

    public ACAMSOrderAssetRecalculationBatch() {}

    global void execute(SchedulableContext context) {
        Database.executeBatch(new ACAMSOrderAssetRecalculationBatch());
    }

    global void finish(Database.BatchableContext context) {}

    global Iterable<AggregateResult> start(Database.BatchableContext context) {
        return [
                SELECT CC_Order__c
                FROM Asset
                WHERE LastModifiedDate > :THIS.lastModifiedDateThreshold
                GROUP BY CC_Order__c
                LIMIT 10000
        ];
    }

    global void execute(Database.BatchableContext context, List<AggregateResult> orderAggregateResults) {
        Set<Id> orderIds = new Set<Id>();
        Map<Id, Decimal> unassignedAssetCountByOrderId = new Map<Id, Decimal>();
        Map<Id, Decimal> assignedAssetCountByOrderId = new Map<Id, Decimal>();
        List<ccrz__E_Order__c> ordersToUpdate = new List<ccrz__E_Order__c>();

        for (AggregateResult aggregateResult : orderAggregateResults) {
            orderIds.add((Id) aggregateResult.get('CC_Order__c'));
        }
        collectAssetSummary(orderIds, assignedAssetCountByOrderId, unassignedAssetCountByOrderId);
        for (ccrz__E_Order__c orderToCheck : [
                SELECT Id, Assets_Assigned__c, Assets_Unassigned__c
                FROM ccrz__E_Order__c
                WHERE Id IN :orderIds
        ]) {
            Decimal assetsAssigned = assignedAssetCountByOrderId.get(orderToCheck.Id);
            Decimal assetsUnassigned = unassignedAssetCountByOrderId.get(orderToCheck.Id);
            assetsAssigned = assetsAssigned == null ? 0 : assetsAssigned;
            assetsUnassigned = assetsUnassigned == null ? 0 : assetsUnassigned;
            if (orderToCheck.Assets_Assigned__c != assetsAssigned ||
                    orderToCheck.Assets_Unassigned__c != assetsUnassigned) {
                orderToCheck.Assets_Assigned__c = assetsAssigned;
                orderToCheck.Assets_Unassigned__c = assetsUnassigned;
                ordersToUpdate.add(orderToCheck);
            }
        }

        List<Database.SaveResult> results = Database.update(ordersToUpdate, false);
        for (Database.SaveResult result : results) {
            if (!result.isSuccess()) {
                System.debug(LoggingLevel.ERROR, result);
            }
        }

    }

    private void collectAssetSummary(
            Set<Id> orderIds,
            Map<Id, Decimal> assignedAssetCountByOrderId,
            Map<Id, Decimal> unassignedAssetCountByOrderId
    ) {
        for (AggregateResult assetAssignedAggregateResult : [
                SELECT COUNT(Id) AssetCount, CC_Order__c
                FROM Asset
                WHERE Assignee__c != NULL
                AND CC_Order__c IN :orderIds
                GROUP BY CC_Order__c
                LIMIT 200
        ]) {
            assignedAssetCountByOrderId.put(
                    (Id) assetAssignedAggregateResult.get('CC_Order__c'),
                    (Decimal) assetAssignedAggregateResult.get('AssetCount')
            );
        }
        for (AggregateResult assetUnassignedAggregateResult : [
                SELECT COUNT(Id) AssetCount, CC_Order__c
                FROM Asset
                WHERE Assignee__c = NULL
                AND CC_Order__c IN :orderIds
                AND CC_Product__c != NULL
                GROUP BY CC_Order__c
                LIMIT 200
        ]) {
            unassignedAssetCountByOrderId.put(
                    (Id) assetUnassignedAggregateResult.get('CC_Order__c'),
                    (Decimal) assetUnassignedAggregateResult.get('AssetCount')
            );
        }
    }


}