global class ACAMSAssetTermRecalculationScheduler implements Schedulable, Database.Batchable<SObject> {

    private static final String ASSET_STATUS_INACTIVE = 'Inactive';

    global void execute(SchedulableContext context) {
        Database.executeBatch(new ACAMSAssetTermRecalculationScheduler());
    }

    global Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([
                SELECT Id, AccountId, Status__c, CC_Product__c, Paid_Cert__c
                FROM Asset
                WHERE CurrentExpirationDate__c = YESTERDAY
        ]);
    }

    global void execute(Database.BatchableContext context, List<Asset> assets) {
        Set<Id> targetAssetIds = new Set<Id>();
        List<Asset> assetsToUpdate = new List<Asset>();
        for (Asset asset : assets) {
            targetAssetIds.add(asset.Id);
        }
        for (Asset targetAsset : assets) {
            assetsToUpdate.add(new Asset(
                    Id = targetAsset.Id,
                    Status__c = ASSET_STATUS_INACTIVE
            ));
        }
        if (!assetsToUpdate.isEmpty()) {
            List<Database.SaveResult> results = Database.update(assetsToUpdate, false);
            for (Database.SaveResult result : results) {
                if (!result.isSuccess()) {
                    System.debug(LoggingLevel.ERROR, result);
                }
            }
        }
    }

    global void finish(Database.BatchableContext context) {

    }

}