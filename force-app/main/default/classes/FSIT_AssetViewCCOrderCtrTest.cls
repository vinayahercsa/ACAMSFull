/***
 * Test Class for FSIT_AssetViewCCOrderController
 */
@Istest
public with sharing class FSIT_AssetViewCCOrderCtrTest {
    public FSIT_AssetViewCCOrderCtrTest() {

    }

    @IsTest
    static void testAssetView() {
        Account account = new Account(
            Name = 'Facebook'
        );
        insert account;

        Contact contact = new Contact(
                AccountId = account.Id,
                LastName = 'Karl'
        );
        insert contact;

        ccrz__E_Product__c prod = new ccrz__E_Product__c();
        prod.Name = 'name';
        prod.ccrz__SKU__c = 'CAMS';
        prod.ccrz__ProductStatus__c = 'Released';
        prod.Level_1__c = 'Certification';
        prod.Level_2__c = 'CAMS';
        insert prod;

        ccrz__E_Order__c ccOrder = new ccrz__E_Order__c (
                ccrz__Account__c = account.Id,
                ccrz__Contact__c = contact.Id,
                ccrz__EncryptedId__c = '4a0644e2-8ac5-48b1-b83e-54254e37e67e',
                ccrz__Name__c = 'New Chart',
                ccrz__OrderNumber__c = 1050011
        );
        insert ccOrder;

        Asset asst = new Asset(
            Name = 'test_Asset',
            Status__c = 'Inactive',
            CC_Product__c = prod.Id,
            CC_Order__c = ccOrder.Id,
            Assignee__c = contact.Id,
            ContactId = contact.Id
        );
        insert asst;

        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(ccOrder);
        FSIT_AssetViewCCOrderController testCtr = new FSIT_AssetViewCCOrderController(sc);
        FSIT_AssetViewCCOrderController testCtrExp = new FSIT_AssetViewCCOrderController();
        PageReference pageRef = Page.FSIT_AssetViewCCOrderPage;
        pageRef.getParameters().put('id', String.valueOf(account.Id));
        Test.setCurrentPage(pageRef);
        testCtr.dataInit();
        testCtr.searchText = 'CAMS';
        testCtr.runSearch();

        Test.stopTest();
    }
}