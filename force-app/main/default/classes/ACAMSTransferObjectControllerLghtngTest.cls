@IsTest
public with sharing class ACAMSTransferObjectControllerLghtngTest {
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
    static void testAssetTransfer() {
        Asset testAsset = [
                SELECT
                        Id,
                        CC_Order__c,
                        CC_Order_Item__c
                FROM
                        Asset
                WHERE
                        Name = 'test1'
        ];
        Id orderId = testAsset.CC_Order__c;
        Id orderItemId = testAsset.CC_Order_Item__c;
        Id id = ACAMSTransferObjectControllerLightning.transferAsset(testAsset.Id);
        Asset clonedAsset = [
                SELECT
                        Id,
                        CancelDate__c,
                        Cancel_Reason__c,
                        CC_Order__c,
                        CC_Order_Item__c,
                        Status__c,
                        Exam_Schedule_Date__c,
                        Assignee__c,
                        ContactId,
                        ParentId,
                        Enterprise_Welcome_Email_Source__c,
                        Enterprise_Welcome_Email__c,
                        Enterprise_Renewal_Email__c,
                        Application_Date__c,
                        Application_Received__c,
                        Certification_Approved_Application__c,
                        Certification_Exam_Passed__c,
                        ExamResult__c,
                        White_Paper_Approved_Date__c,
                        White_Paper_Assignment_Approved__c,
                        White_Paper_Published__c,
                        Paid_Cert__c
                FROM
                        Asset
                WHERE
                        Id = :id
        ];

        Asset originalAsset = [
                SELECT
                        Id,
                        Cancel_Reason__c,
                        CancelDate__c,
                        CC_Order__c,
                        CC_Order_Item__c
                FROM
                        Asset
                WHERE
                        Id = :testAsset.Id
        ];

        System.assert(originalAsset.CC_Order__c == null);
        System.assert(originalAsset.CC_Order_Item__c == null);
        System.assert(originalAsset.Cancel_Reason__c != null);
        System.assert(originalAsset.CancelDate__c != null);

        System.assert(clonedAsset.Status__c == 'Active');
        System.assert(clonedAsset.Cancel_Reason__c == null);
        System.assert(clonedAsset.CancelDate__c == null);
        System.assert(clonedAsset.Exam_Schedule_Date__c == null);
        System.assert(clonedAsset.Assignee__c == null);
        System.assert(clonedAsset.ContactId == null);
        System.assert(clonedAsset.ParentId == null);
        System.assert(clonedAsset.Enterprise_Welcome_Email_Source__c == null);
        System.assert(clonedAsset.Enterprise_Welcome_Email__c == false);
        System.assert(clonedAsset.Enterprise_Renewal_Email__c == false);
        System.assert(clonedAsset.Application_Date__c == null);
        System.assert(clonedAsset.Application_Received__c == false);
        System.assert(clonedAsset.Certification_Approved_Application__c == false);
        System.assert(clonedAsset.Certification_Exam_Passed__c == false);
        System.assert(clonedAsset.ExamResult__c == null);
        System.assert(clonedAsset.White_Paper_Approved_Date__c == null);
        System.assert(clonedAsset.White_Paper_Assignment_Approved__c == false);
        System.assert(clonedAsset.White_Paper_Published__c == false);
        System.assert(clonedAsset.Paid_Cert__c == false);
        System.assert(clonedAsset.CC_Order__c == orderId);
        System.assert(clonedAsset.CC_Order_Item__c == orderItemId);

    }

}