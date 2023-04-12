global without sharing class ACAMSActivateAssetsBatch implements Database.Batchable<SObject>{

	public static final string INACTIVE_STATUS = 'Inactive';
	public static final string ORDER_STATUS = 'Completed';
	public static final string ORDER_NAME = 'Refunded Order';
	
    global Database.QueryLocator start(Database.BatchableContext bc) {
    	Datetime dt = System.now().addHours(-1);
    	return Database.getQueryLocator([
                SELECT
                        Id,
                        (
                                SELECT Id
                                FROM Assets__r where Status__c =: INACTIVE_STATUS
                        )
                FROM
                        ccrz__E_Order__c
                WHERE
                
                 CreatedDate >= :dt AND
                 ccrz__Name__c !=: ORDER_NAME AND 
                 ccrz__OrderStatus__c =: ORDER_STATUS
                 //AND Id='a0n2g000000MQ0IAAW'
                
        ]);
    }
    global void execute(Database.BatchableContext bc, List<ccrz__E_Order__c> orders) {
    	for (ccrz__E_Order__c o : orders) {
            if (o.Assets__r.size() > 0) {
            	system.debug('In Activating Assets::'+o.Id);
            	ccrz__E_Order__c order = ACAMSOrderDAO.getOrderForUpdate(o.Id);
            	Map<Id, Decimal> orderItemsMap = new Map<Id, Decimal>();
        		for (ccrz__E_OrderItem__c orderItem : order.ccrz__E_OrderItems__r) {
            		orderItemsMap.put(orderItem.Id, orderItem.ccrz__Quantity__c);
        		}
        		ACAMSAssetHelper.activateAssets(orderItemsMap);
            }
        }
    }
    global void finish(Database.BatchableContext bc){
    }
}