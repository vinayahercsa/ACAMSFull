@Istest
public class ACAMSAssetHelperTest {
  
    @isTest
    static void testCancelAssetsByOrderIdsFuture() {
      ccrz__E_Order__c newOrder = new ccrz__E_Order__c(
    ccrz__OrderStatus__c='CANCELLED'
);

// Create a list and add the new order to it
List<ccrz__E_Order__c> orderList = new List<ccrz__E_Order__c>();
orderList.add(newOrder);

// Insert the list of orders in a single DML statement
insert orderList;
        
        List<ccrz__E_Invoice__c> invoicesToUpdate = new List<ccrz__E_Invoice__c>();
        invoicesToUpdate.addAll(new List<ccrz__E_Invoice__c>{
    new ccrz__E_Invoice__c(Invoice_Status__c = 'Cancelled',Refund_Date__c = Date.today(),ccrz__CCOrder__c=newOrder.Id),
    new ccrz__E_Invoice__c(Invoice_Status__c = 'Cancelled',Refund_Date__c = Date.today(),ccrz__CCOrder__c=newOrder.Id),
    new ccrz__E_Invoice__c(Invoice_Status__c = 'Cancelled',Refund_Date__c = Date.today(),ccrz__CCOrder__c=newOrder.Id)
});

         Set<Id> orderIds = new Set<Id>();
        orderIds.add(newOrder.Id);

        Asset testAsset = new Asset(Name = 'Test Asset',Status__c = 'Inactive',CancelDate__c=Date.today(),CC_Order__c=newOrder.Id);
        insert testAsset;
        

        
       

        // Call the future method
        Test.startTest();
        ACAMSAssetHelper.cancelAssetsByOrderIdsFuture(orderIds);
        Test.stopTest();

        // Verify the results
        List<Asset> updatedAssets = [SELECT Id, Status__c, CancelDate__c FROM Asset WHERE Id = :testAsset.Id];
        System.assertEquals(1, updatedAssets.size());
        System.assertEquals(ACAMSUtil.INACTIVE, updatedAssets[0].Status__c);
        System.assertEquals(Date.today(), updatedAssets[0].CancelDate__c);
    }



}