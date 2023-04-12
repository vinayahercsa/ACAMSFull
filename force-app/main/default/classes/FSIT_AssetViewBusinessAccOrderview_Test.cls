@IsTest
public class FSIT_AssetViewBusinessAccOrderview_Test {
    
    public static testmethod void testAssetView() {
        Account account = new Account(Name = 'Facebook');
        insert account;

        Contact contact = new Contact(AccountId = account.Id,LastName = 'Karl');
        insert contact;

        ccrz__E_Product__c prod = new ccrz__E_Product__c();
        prod.Name = 'name';
        prod.ccrz__SKU__c = 'CAMS';
        prod.ccrz__ProductStatus__c = 'Released';
        prod.Level_1__c = 'Certification';
        prod.Level_2__c = 'CAMS';
        insert prod;

        ccrz__E_Order__c theOrder = new ccrz__E_Order__c();        
        theOrder.ccrz__Account__c = account.Id;
        theOrder.ccrz__Contact__c = contact.Id;
        theOrder.ccrz__EncryptedId__c = 'encOrder123';
        //Assumes CC sets the orderdate to the date of order.....
        theOrder.ccrz__OrderDate__c = Date.today();
        theOrder.ccrz__OrderNumber__c = 12345;
        insert theOrder;

        Asset asst = new Asset(Name = 'test_Asset',Status__c = 'Active',CC_Product__c = prod.Id,CC_Order__c = theOrder.Id,
            Assignee__c = contact.Id,ContactId = contact.Id);
        insert asst;
        
        Test.startTest();
            PageReference pageRef = Page.FSIT_AssetViewBisOrderDetailPage;
            pageRef.getParameters().put('id', String.valueOf(account.Id));
            FSIT_AssetViewBusinessAccOrderview testCtrNo = new FSIT_AssetViewBusinessAccOrderview();
            Test.setCurrentPage(pageRef);
            testCtrNo.assetTypes = 'Assigned_Asset';
            testCtrNo.productId = prod.Id;
            testCtrNo.dataInit();
            testCtrNo.getAssigneeRecords();
            testCtrNo.runSearch();
            //testCtrNo.buildProductOrderAssetList();
        Test.stopTest();
    }
    
    public static testmethod void testAssetViewAuthorizedAsset() {
        Account account = new Account(Name = 'Facebook');
        insert account;

        Contact contact = new Contact(AccountId = account.Id,LastName = 'Karl');
        insert contact;

        ccrz__E_Product__c prod = new ccrz__E_Product__c();
        prod.Name = 'name';
        prod.ccrz__SKU__c = 'CAMS';
        prod.ccrz__ProductStatus__c = 'Released';
        prod.Level_1__c = 'Certification';
        prod.Level_2__c = 'CAMS';
        insert prod;

        ccrz__E_Order__c theOrder = new ccrz__E_Order__c();        
        theOrder.ccrz__Account__c = account.Id;
        theOrder.ccrz__Contact__c = contact.Id;
        theOrder.ccrz__EncryptedId__c = 'encOrder123';
        //Assumes CC sets the orderdate to the date of order.....
        theOrder.ccrz__OrderDate__c = Date.today();
        theOrder.ccrz__OrderNumber__c = 12345;
        insert theOrder;

        Asset asst = new Asset(Name = 'test_Asset',Status__c = 'Active',CC_Product__c = prod.Id,CC_Order__c = theOrder.Id,
            Assignee__c = contact.Id,ContactId = contact.Id);
        insert asst;
        
        Test.startTest();
            PageReference pageRef = Page.FSIT_AssetViewBisOrderDetailPage;
            pageRef.getParameters().put('id', String.valueOf(account.Id));
            FSIT_AssetViewBusinessAccOrderview testCtrNo = new FSIT_AssetViewBusinessAccOrderview();
            Test.setCurrentPage(pageRef);
            testCtrNo.assetTypes = 'Authorized_Asset';
            testCtrNo.productId = prod.Id;
            testCtrNo.dataInit();
            testCtrNo.getAssigneeRecords();
            testCtrNo.runSearch();
            //testCtrNo.buildProductOrderAssetList();
        Test.stopTest();
    }
    
    public static testmethod void testAssetViewUnaasignedAsset() {
        Account account = new Account(Name = 'Facebook');
        insert account;

        Contact contact = new Contact(AccountId = account.Id,LastName = 'Karl');
        insert contact;

        ccrz__E_Product__c prod = new ccrz__E_Product__c();
        prod.Name = 'name';
        prod.ccrz__SKU__c = 'CAMS';
        prod.ccrz__ProductStatus__c = 'Released';
        prod.Level_1__c = 'Certification';
        prod.Level_2__c = 'CAMS';
        insert prod;

        ccrz__E_Order__c theOrder = new ccrz__E_Order__c();        
        theOrder.ccrz__Account__c = account.Id;
        theOrder.ccrz__Contact__c = contact.Id;
        theOrder.ccrz__EncryptedId__c = 'encOrder123';
        //Assumes CC sets the orderdate to the date of order.....
        theOrder.ccrz__OrderDate__c = Date.today();
        theOrder.ccrz__OrderNumber__c = 12345;
        insert theOrder;

        Asset asst = new Asset(Name = 'test_Asset',Status__c = 'Active',CC_Product__c = prod.Id,CC_Order__c = theOrder.Id,
            Assignee__c = contact.Id,ContactId = contact.Id);
        insert asst;
        
        Test.startTest();
            PageReference pageRef = Page.FSIT_AssetViewBisOrderDetailPage;
            pageRef.getParameters().put('id', String.valueOf(account.Id));
            FSIT_AssetViewBusinessAccOrderview testCtrNo = new FSIT_AssetViewBusinessAccOrderview();
            Test.setCurrentPage(pageRef);
            testCtrNo.assetTypes = 'Unassigned_Asset';
            testCtrNo.productId = prod.Id;
            testCtrNo.dataInit();
            testCtrNo.getAssigneeRecords();
            testCtrNo.runSearch();
            //testCtrNo.buildProductOrderAssetList();
        Test.stopTest();
    }
    
     public static testmethod void testAssetViewexpiredAsset() {
        Account account = new Account(Name = 'Facebook');
        insert account;

        Contact contact = new Contact(AccountId = account.Id,LastName = 'Karl');
        insert contact;

        ccrz__E_Product__c prod = new ccrz__E_Product__c();
        prod.Name = 'name';
        prod.ccrz__SKU__c = 'CAMS';
        prod.ccrz__ProductStatus__c = 'Released';
        prod.Level_1__c = 'Certification';
        prod.Level_2__c = 'CAMS';
        insert prod;

        ccrz__E_Order__c theOrder = new ccrz__E_Order__c();        
        theOrder.ccrz__Account__c = account.Id;
        theOrder.ccrz__Contact__c = contact.Id;
        theOrder.ccrz__EncryptedId__c = 'encOrder123';
        //Assumes CC sets the orderdate to the date of order.....
        theOrder.ccrz__OrderDate__c = Date.today();
        theOrder.ccrz__OrderNumber__c = 12345;
        insert theOrder;

        Asset asst = new Asset(Name = 'test_Asset',Status__c = 'Active',CC_Product__c = prod.Id,CC_Order__c = theOrder.Id,
            Assignee__c = contact.Id,ContactId = contact.Id);
        insert asst;
        
        Test.startTest();
            PageReference pageRef = Page.FSIT_AssetViewBisOrderDetailPage;
            pageRef.getParameters().put('id', String.valueOf(account.Id));
            FSIT_AssetViewBusinessAccOrderview testCtrNo = new FSIT_AssetViewBusinessAccOrderview();
            Test.setCurrentPage(pageRef);
            testCtrNo.assetTypes = 'UnAssigned_Expired_Assets';
            testCtrNo.productId = prod.Id;
            testCtrNo.dataInit();
            testCtrNo.getAssigneeRecords();
            testCtrNo.runSearch();
            //testCtrNo.buildProductOrderAssetList();
        Test.stopTest();
    }
    
     public static testmethod void testAssetViewUnpaidAsset() {
        Account account = new Account(Name = 'Facebook');
        insert account;

        Contact contact = new Contact(AccountId = account.Id,LastName = 'Karl');
        insert contact;

        ccrz__E_Product__c prod = new ccrz__E_Product__c();
        prod.Name = 'name';
        prod.ccrz__SKU__c = 'CAMS';
        prod.ccrz__ProductStatus__c = 'Released';
        prod.Level_1__c = 'Certification';
        prod.Level_2__c = 'CAMS';
        insert prod;

        ccrz__E_Order__c theOrder = new ccrz__E_Order__c();        
        theOrder.ccrz__Account__c = account.Id;
        theOrder.ccrz__Contact__c = contact.Id;
        theOrder.ccrz__EncryptedId__c = 'encOrder123';
        //Assumes CC sets the orderdate to the date of order.....
        theOrder.ccrz__OrderDate__c = Date.today();
        theOrder.ccrz__OrderNumber__c = 12345;
        insert theOrder;

        Asset asst = new Asset(Name = 'test_Asset',Status__c = 'Active',CC_Product__c = prod.Id,CC_Order__c = theOrder.Id,
            Assignee__c = contact.Id,ContactId = contact.Id);
        insert asst;
        
        Test.startTest();
            PageReference pageRef = Page.FSIT_AssetViewBisOrderDetailPage;
            pageRef.getParameters().put('recordid', String.valueOf(account.Id));
            pageRef.getParameters().put('searchText', String.valueOf(account.Id));
            pageRef.getParameters().put('pdid', String.valueOf(prod.Id));
            FSIT_AssetViewBusinessAccOrderview testCtrNo = new FSIT_AssetViewBusinessAccOrderview();
            Test.setCurrentPage(pageRef);
            testCtrNo.assetTypes = 'Unpaid_Asset';
            testCtrNo.productId = prod.Id;
            testCtrNo.dataInit();
            testCtrNo.getAssigneeRecords();
            testCtrNo.runSearch();            
            
            testCtrNo.assetTypes = null;
            testCtrNo.runSearch();
            
        Test.stopTest();
    }
}