trigger ACAMSGenerateAssetsTrigger on Generate_Asset__e (after insert) {
    
    
    for (Generate_Asset__e event : Trigger.New) {
        System.debug('Order ID: ' + event.Order_ID__c);
        if (event.Order_ID__c != null) {
            ACAMSAssetHelper.generateAssets(event.Order_ID__c);
        }
    }
    
    
}