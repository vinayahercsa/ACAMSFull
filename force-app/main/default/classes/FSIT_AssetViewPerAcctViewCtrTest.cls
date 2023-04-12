@Istest
public with sharing class FSIT_AssetViewPerAcctViewCtrTest {
    public FSIT_AssetViewPerAcctViewCtrTest() {

    }

    @IsTest
    static void testAssetView() {
        Account account = new Account(
                Name = 'Facebook'
        );
        insert account;

        Contact contact = new Contact(
                AccountId = account.Id,
                LastName = 'Karl',
                Work_Email__c = 'test@test12.com'
        );
        insert contact;

        ccrz__E_Product__c prod = new ccrz__E_Product__c();
        prod.Name = 'name';
        prod.ccrz__SKU__c = 'CAMS';
        prod.ccrz__ProductStatus__c = 'Released';
        prod.Level_1__c = 'Certification';
        prod.Level_2__c = 'CAMS';
        insert prod;

        Asset asst = new Asset(
            Name = 'test_Asset',
            Status__c = 'Active',
            CC_Product__c = prod.Id,
            Assignee__c = contact.Id,
            ContactId = contact.Id
        );
        insert asst;

        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(account);
        FSIT_AssetViewPersonalAccountController testCtr = new FSIT_AssetViewPersonalAccountController(sc);
        FSIT_AssetViewPersonalAccountController testCtrNo = new FSIT_AssetViewPersonalAccountController();

        PageReference pageRef = Page.FSIT_AssetViewPersonalAccountPage;
        pageRef.getParameters().put('id', String.valueOf(account.Id));
        Test.setCurrentPage(pageRef);
        testCtr.dataInit();
        testCtr.displayAssetsByGroupName();
        testCtr.searchText = 'CAMS';
        testCtr.runSearch();

        prod.Level_1__c = 'Certification';
        prod.Level_2__c = 'CGSS';
        update prod;
        testCtr.dataInit();

        prod.Level_1__c = 'Membership';
        prod.Level_2__c = null;
        update prod;
        testCtr.dataInit();

        prod.Level_1__c = 'Chapter';
        prod.Level_2__c = 'Membership';
        update prod;
        testCtr.dataInit();

        prod.Level_1__c = 'Certification';
        prod.Level_2__c = 'CKYCA';
        update prod;
        testCtr.dataInit();

        prod.Level_1__c = 'Certification';
        prod.Level_2__c = 'Advanced CAMS - Audit';
        prod.Name = 'CAMS-Audit';
        update prod;
        testCtr.dataInit();
        
        prod.Level_1__c = 'Certification';
        prod.Level_2__c = 'Regime Exam';
        update prod;
        testCtr.dataInit();
        
        prod.Level_1__c = 'Training';
        prod.Level_2__c = 'Certificates';
        update prod;
        testCtr.dataInit();

        prod.Level_1__c = 'Training';
        prod.Level_2__c = 'Seminars';
        update prod;
        testCtr.dataInit();

        prod.Level_1__c = 'Chapter';
        prod.Level_2__c = 'Event';
        update prod;
        testCtr.dataInit();

        prod.Level_1__c = 'Publications';
        prod.Level_2__c = 'Moneylaundering.com';
        update prod;
        testCtr.dataInit();

        prod.Level_1__c = 'Advertising/Other';
        prod.Level_2__c = 'Advertising';
        update prod;
        testCtr.dataInit();

        prod.Level_1__c = 'Advertising/Other';
        prod.Level_2__c = 'Other';
        update prod;
        testCtr.dataInit();

        prod.Level_1__c = 'Risk Assessment';
        prod.Level_2__c = null;
        update prod;
        testCtr.dataInit();

        prod.Level_1__c = 'Conferences';
        prod.Level_2__c = null;
        update prod;
        testCtr.dataInit();
        Test.stopTest();
    }
}