@IsTest
public with sharing class ACAMSTransferAssetControllerTest {
    @TestSetup
    static void initData() {
        ccrz__E_Order__c testOrder = new ccrz__E_Order__c();
        insert testOrder;
        ccrz__E_OrderItem__c testOrderItem = new ccrz__E_OrderItem__c(
                ccrz__Order__c = testOrder.Id,
                ccrz__Price__c = 10,
                ccrz__Quantity__c = 1,
                ccrz__SubAmount__c = 10
        );
        insert testOrderItem;
        Account testAccount = new Account(
                Name = 'test'
        );
        insert testAccount;
        ccrz__E_Product__c prod = new ccrz__E_Product__c();
        prod.Name = 'name';
        prod.ccrz__SKU__c = 'sku123';
        prod.ccrz__ProductType__c = 'Product';
        prod.ccrz__ProductStatus__c = 'Released';
        prod.ccrz__Storefront__c = 'storefront';
        prod.Level_1__c = 'Certification';
        prod.Level_2__c = 'CAMS';
        prod.Level_3__c = 'Recertification';
        prod.Certification_Level__c='Specialist';
        insert prod;
        Asset testAsset = new Asset(
                Name = 'test1',
                CC_Order__c = testOrder.Id,
                CC_Order_Item__c = testOrderItem.Id,
                AccountId = testAccount.Id,
                CC_Product__c = prod.Id
        );
        insert testAsset;
    }

    @IsTest
    static void assetTransferTest() {
        Asset testAsset = [
                SELECT
                        Id,
                        CC_Order__c,
                        CC_Order_Item__c,
                        Enterprise_Product_HL__c,
                        Cancel_Reason__c
                FROM
                        Asset
                WHERE
                        Name = 'test1'
        ];
        ACAMSTransferAssetController controller = new ACAMSTransferAssetController();
        controller.assetToTransfer = testAsset;
        controller.redirect();
    }
}