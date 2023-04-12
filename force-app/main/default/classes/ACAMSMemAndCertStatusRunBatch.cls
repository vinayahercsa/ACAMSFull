//FSA-557
global class ACAMSMemAndCertStatusRunBatch implements Schedulable, Database.Batchable<SObject> {

    global void execute(SchedulableContext context) {
        Database.executeBatch(new ACAMSMemAndCertStatusRunBatch());
    }

    global Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([
                SELECT Id, AccountId, ContactId, Status__c, Assignee__c, CurrentExpirationDate__c
                FROM Asset
                WHERE CurrentExpirationDate__c = LAST_N_DAYS:3
                AND Assignee__c <> NULL // AND Id='02i2g000003Mhyk'
        ]);
    }

    global void execute(Database.BatchableContext context, List<Asset> assets) {
        Set<Id> contactIds = new Set<Id>();
        //List<Asset> assetsToUpdate = new List<Asset>();
        for (Asset asset : assets) {
          if(asset.Assignee__c != null) {
              contactIds.add(asset.Assignee__c);
          }
        }
    ACAMSMembershipAndCertificationsStatuses.updateMemsAndCertsStatusesByContact(contactIds, true);
    }

    global void finish(Database.BatchableContext context) {

    }

}