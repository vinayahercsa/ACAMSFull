@isTest
public class ACAMSDeleteCartItemsTest {
    @IsTest 
   public static  void testHandler1() {
        Account acc = new Account(
                ccrz__TaxExemptAccount__c = true,
                Name = 'acc'
        );
        insert acc;
        Contact contact = new Contact(
                AccountId = acc.Id,
                LastName = 'Karl'
        );
        insert contact;
        ccrz__E_ContactAddr__c testAddress = new ccrz__E_ContactAddr__c(
                OwnerId = UserInfo.getUserId(),
                ccrz__AddressFirstline__c = 'line1',
                ccrz__AddressSecondline__c = 'line2',
                ccrz__AddressThirdline__c = 'line3',
                ccrz__City__c = 'city',
                ccrz__State__c = 'state',
                ccrz__Country__c = 'country',
                ccrz__CountryISOCode__c = 'US',
                ccrz__PostalCode__c = 'postalCode',
                Vertex_Tax_Area_Id__c = 780123322
        );
        ACAMSContactAddressTriggerHandler.skipAddressValidation = true;
        insert testAddress;
        System.debug(testAddress.Id);
        ccrz__E_Cart__c cartUnSync = new ccrz__E_Cart__c(
                ccrz__ShipAmount__c = 2,
                ccrz__TotalDiscount__c = 2,
                ccrz__BillTo__c = testAddress.Id,
                ccrz__ShipTo__c = testAddress.Id,
                ccrz__Account__c = acc.Id
        );
        insert cartUnSync;
        ccrz__E_Cart__c cartSync = new ccrz__E_Cart__c(
                ccrz__ShipAmount__c = 2,
                ccrz__TotalDiscount__c = 2,
                ccrz__BillTo__c = testAddress.Id,
                ccrz__ShipTo__c = testAddress.Id,
                ccrz__Account__c = acc.Id
        );
        insert cartSync;
        ccrz__E_CartItem__c cItem = new ccrz__E_CartItem__c(
                ccrz__Cart__c = cartUnSync.Id,
                ccrz__SubAmount__c = 300,
                ccrz__Price__c = 20,
                ccrz__Quantity__c = 1,
                ccrz__cartItemType__c = 'Major',
                ccrz__ProductType__c = 'Product',
                ccrz__StoreID__c = 'acams'
        );
        insert cItem;
        ccrz__E_CartItem__c cItem2 = new ccrz__E_CartItem__c(
                ccrz__Cart__c = cartUnSync.Id,
                ccrz__SubAmount__c = 300,
                ccrz__Price__c = 20,
                ccrz__Quantity__c = 1,
                ccrz__cartItemType__c = 'Major',
                ccrz__ProductType__c = 'Product',
                ccrz__StoreID__c = 'acams'
        );
        insert cItem2;
        Opportunity testOpportunity = new Opportunity(
                CloseDate = Date.today().addDays(2000),
                ForecastCategoryName = 'Pipeline',
                Name = 'testOpp',
                Probability = 100,
                StageName = 'Qualification',
                SyncedQuoteId = null,
                Coupon_Code__c = 'test',
                CC_Cart__c = cartUnSync.Id,
                AccountId = acc.Id
        );
        insert testOpportunity;
        testOpportunity = [
                SELECT Id, CC_Cart__c, CC_Cart__r.ccrz__ShipTo__c, CC_Cart__r.ccrz__BillTo__c,
                        CC_Cart__r.ccrz__TotalQuantity__c
                FROM Opportunity
                WHERE Id = :testOpportunity.Id
        ];
        system.debug('Oppo::'+testOpportunity);
        Test.startTest();
        String message = ACAMSCartItemsDeleteAction.getCartItemsToDelete(String.valueOf(cItem.Id));
        system.debug('Message::'+message);
        system.assertEquals(message, 'Selected CC Cart Item is deleted');
        
        //OrderCreation
        CCACAMSTestUtil testUtil = new CCACAMSTestUtil();
        ACAMSContactAddressTriggerHandler.skipAddressValidation = true;
        Map<String, Object> testData = testUtil.initData();
        ccrz__E_Order__c testOrder = (ccrz__E_Order__c) testData.get(CCAviTestUtil.PN_ORDER);
        testOrder.ccrz__OrderStatus__c = 'In Process';
        testOrder.ccrz__CurrencyISOCode__c = 'USD';
        testOrder.ccrz__OriginatedCart__c = cartUnSync.Id;
        update testOrder;
        
        ApexPages.StandardController opportunityController = new ApexPages.StandardController(testOpportunity);
        ACAMSOpportunityCreateOrderController controller = new ACAMSOpportunityCreateOrderController(
                opportunityController
        );
        ACAMSOpportunityCreateOrderController.testOrderId = testOrder.Id;
        Test.setCurrentPage(Page.ACAMSOpportunityCreateOrder);
        ApexPages.PageReference opportunityReference = controller.goToOpportunityPage();
        System.assert(opportunityReference.getUrl().contains(testOpportunity.Id));
        controller.createOrder();
        //Order Creation
        String message1 = ACAMSCartItemsDeleteAction.getCartItemsToDelete(String.valueOf(cItem2.Id));
        system.debug('Message1::'+message1);
        system.assertEquals(message1, 'Cannot delete cart items on Opportunity with an Order on it');
        Test.stopTest();
        
   }
    @IsTest 
   public static  void testHandler2() {
        Account acc = new Account(
                ccrz__TaxExemptAccount__c = true,
                Name = 'acc'
        );
        insert acc;
        Contact contact = new Contact(
                AccountId = acc.Id,
                LastName = 'Karl'
        );
        insert contact;
        ccrz__E_ContactAddr__c testAddress = new ccrz__E_ContactAddr__c(
                OwnerId = UserInfo.getUserId(),
                ccrz__AddressFirstline__c = 'line1',
                ccrz__AddressSecondline__c = 'line2',
                ccrz__AddressThirdline__c = 'line3',
                ccrz__City__c = 'city',
                ccrz__State__c = 'state',
                ccrz__Country__c = 'country',
                ccrz__CountryISOCode__c = 'US',
                ccrz__PostalCode__c = 'postalCode',
                Vertex_Tax_Area_Id__c = 780123322
        );
        ACAMSContactAddressTriggerHandler.skipAddressValidation = true;
        insert testAddress;
        System.debug(testAddress.Id);
        ccrz__E_Cart__c cartUnSync = new ccrz__E_Cart__c(
                ccrz__ShipAmount__c = 2,
                ccrz__TotalDiscount__c = 2,
                ccrz__BillTo__c = testAddress.Id,
                ccrz__ShipTo__c = testAddress.Id,
                ccrz__Account__c = acc.Id
        );
        insert cartUnSync;
        ccrz__E_Cart__c cartSync = new ccrz__E_Cart__c(
                ccrz__ShipAmount__c = 2,
                ccrz__TotalDiscount__c = 2,
                ccrz__BillTo__c = testAddress.Id,
                ccrz__ShipTo__c = testAddress.Id,
                ccrz__Account__c = acc.Id
        );
        insert cartSync;
        ccrz__E_CartItem__c cItem = new ccrz__E_CartItem__c(
                ccrz__Cart__c = cartUnSync.Id,
                ccrz__SubAmount__c = 300,
                ccrz__Price__c = 20,
                ccrz__Quantity__c = 1,
                ccrz__cartItemType__c = 'Major',
                ccrz__ProductType__c = 'Product',
                ccrz__StoreID__c = 'acams'
        );
        insert cItem;
        ccrz__E_CartItem__c cItem2 = new ccrz__E_CartItem__c(
                ccrz__Cart__c = cartUnSync.Id,
                ccrz__SubAmount__c = 300,
                ccrz__Price__c = 20,
                ccrz__Quantity__c = 1,
                ccrz__cartItemType__c = 'Major',
                ccrz__ProductType__c = 'Product',
                ccrz__StoreID__c = 'acams'
        );
        insert cItem2;
        Opportunity testOpportunity = new Opportunity(
                CloseDate = Date.today().addDays(2000),
                ForecastCategoryName = 'Pipeline',
                Name = 'testOpp',
                Probability = 100,
                StageName = 'Qualification',
                SyncedQuoteId = null,
                Coupon_Code__c = 'test',
                CC_Cart__c = cartUnSync.Id,
                AccountId = acc.Id
        );
        insert testOpportunity;
        testOpportunity = [
                SELECT Id, CC_Cart__c, CC_Cart__r.ccrz__ShipTo__c, CC_Cart__r.ccrz__BillTo__c,
                        CC_Cart__r.ccrz__TotalQuantity__c
                FROM Opportunity
                WHERE Id = :testOpportunity.Id
        ];
        system.debug('Oppo::'+testOpportunity);
        Test.startTest();
        cartUnSync = [Select ID, (Select ID FROM ccrz__E_Orders__r), (Select ID FROM ccrz__E_CartItems__r) FROM ccrz__E_Cart__c Where Id=:cartUnSync.Id];
        system.debug('cartUnSync::'+cartUnSync.Id+cartUnSync);
        system.debug('cartUnSync.ccrz__E_Orders__r::'+cartUnSync.ccrz__E_Orders__r);
        system.debug('cartUnSync.ccrz__E_CartItems__r::'+cartUnSync.ccrz__E_CartItems__r);
        
        ApexPages.StandardSetController controller = new ApexPages.StandardSetController(cartUnSync.ccrz__E_CartItems__r);   
        
        String testUrl = 'https://acams--acamsdev.lightning.force.com/lightning/r/'+cartUnSync.Id+'/related/ccrz__E_CartItems__r/view#/sObject/'+cartUnSync.Id+'/rlName/ccrz__E_CartItems__r/view';
         system.debug('testUrl::'+testUrl);
         ApexPages.currentPage().getParameters().put('vfRetURLInSFX', testUrl);
         ApexPages.currentPage().getParameters().put('retURL', testUrl);
            
         
         DeleteCartItemsListbuttonExtension coe = new DeleteCartItemsListbuttonExtension(controller);
         coe.selected = cartUnSync.ccrz__E_CartItems__r;
         coe.getAndDeleteSelectedCartItems();
        
        cartUnSync = [Select ID, (Select ID FROM ccrz__E_Orders__r), (Select ID FROM ccrz__E_CartItems__r) FROM ccrz__E_Cart__c Where Id=:cartUnSync.Id];
        system.debug('cartUnSync After::'+cartUnSync);
        system.debug('cartUnSync.ccrz__E_Orders__r After::'+cartUnSync.ccrz__E_Orders__r);
        system.debug('cartUnSync.ccrz__E_CartItems__r After::'+cartUnSync.ccrz__E_CartItems__r.size());
        system.assertEquals(cartUnSync.ccrz__E_CartItems__r.size(),0);
        Test.stopTest();    
        
   }
   @IsTest 
   public static  void testHandler3() {
        Account acc = new Account(
                ccrz__TaxExemptAccount__c = true,
                Name = 'acc'
        );
        insert acc;
        Contact contact = new Contact(
                AccountId = acc.Id,
                LastName = 'Karl'
        );
        insert contact;
        ccrz__E_ContactAddr__c testAddress = new ccrz__E_ContactAddr__c(
                OwnerId = UserInfo.getUserId(),
                ccrz__AddressFirstline__c = 'line1',
                ccrz__AddressSecondline__c = 'line2',
                ccrz__AddressThirdline__c = 'line3',
                ccrz__City__c = 'city',
                ccrz__State__c = 'state',
                ccrz__Country__c = 'country',
                ccrz__CountryISOCode__c = 'US',
                ccrz__PostalCode__c = 'postalCode',
                Vertex_Tax_Area_Id__c = 780123322
        );
        ACAMSContactAddressTriggerHandler.skipAddressValidation = true;
        insert testAddress;
        System.debug(testAddress.Id);
        ccrz__E_Cart__c cartUnSync = new ccrz__E_Cart__c(
                ccrz__ShipAmount__c = 2,
                ccrz__TotalDiscount__c = 2,
                ccrz__BillTo__c = testAddress.Id,
                ccrz__ShipTo__c = testAddress.Id,
                ccrz__Account__c = acc.Id
        );
        insert cartUnSync;
        ccrz__E_Cart__c cartSync = new ccrz__E_Cart__c(
                ccrz__ShipAmount__c = 2,
                ccrz__TotalDiscount__c = 2,
                ccrz__BillTo__c = testAddress.Id,
                ccrz__ShipTo__c = testAddress.Id,
                ccrz__Account__c = acc.Id
        );
        insert cartSync;
        ccrz__E_CartItem__c cItem = new ccrz__E_CartItem__c(
                ccrz__Cart__c = cartUnSync.Id,
                ccrz__SubAmount__c = 300,
                ccrz__Price__c = 20,
                ccrz__Quantity__c = 1,
                ccrz__cartItemType__c = 'Major',
                ccrz__ProductType__c = 'Product',
                ccrz__StoreID__c = 'acams'
        );
        insert cItem;
        ccrz__E_CartItem__c cItem2 = new ccrz__E_CartItem__c(
                ccrz__Cart__c = cartUnSync.Id,
                ccrz__SubAmount__c = 300,
                ccrz__Price__c = 20,
                ccrz__Quantity__c = 1,
                ccrz__cartItemType__c = 'Major',
                ccrz__ProductType__c = 'Product',
                ccrz__StoreID__c = 'acams'
        );
        insert cItem2;
        Opportunity testOpportunity = new Opportunity(
                CloseDate = Date.today().addDays(2000),
                ForecastCategoryName = 'Pipeline',
                Name = 'testOpp',
                Probability = 100,
                StageName = 'Qualification',
                SyncedQuoteId = null,
                Coupon_Code__c = 'test',
                CC_Cart__c = cartUnSync.Id,
                AccountId = acc.Id
        );
        insert testOpportunity;
        testOpportunity = [
                SELECT Id, CC_Cart__c, CC_Cart__r.ccrz__ShipTo__c, CC_Cart__r.ccrz__BillTo__c,
                        CC_Cart__r.ccrz__TotalQuantity__c
                FROM Opportunity
                WHERE Id = :testOpportunity.Id
        ];
        system.debug('Oppo::'+testOpportunity);
        
        //OrderCreation
        CCACAMSTestUtil testUtil = new CCACAMSTestUtil();
        ACAMSContactAddressTriggerHandler.skipAddressValidation = true;
        Map<String, Object> testData = testUtil.initData();
        ccrz__E_Order__c testOrder = (ccrz__E_Order__c) testData.get(CCAviTestUtil.PN_ORDER);
        testOrder.ccrz__OrderStatus__c = 'In Process';
        testOrder.ccrz__CurrencyISOCode__c = 'USD';
        testOrder.ccrz__OriginatedCart__c = cartUnSync.Id;
        update testOrder;
        
        ApexPages.StandardController opportunityController = new ApexPages.StandardController(testOpportunity);
        ACAMSOpportunityCreateOrderController controller = new ACAMSOpportunityCreateOrderController(
                opportunityController
        );
        ACAMSOpportunityCreateOrderController.testOrderId = testOrder.Id;
        Test.setCurrentPage(Page.ACAMSOpportunityCreateOrder);
        ApexPages.PageReference opportunityReference = controller.goToOpportunityPage();
        System.assert(opportunityReference.getUrl().contains(testOpportunity.Id));
        controller.createOrder();
        //Order Creation
        
        Test.startTest();
        cartUnSync = [Select ID, (Select ID FROM ccrz__E_Orders__r), (Select ID FROM ccrz__E_CartItems__r) FROM ccrz__E_Cart__c Where Id=:cartUnSync.Id];
        system.debug('cartUnSync::'+cartUnSync.Id+cartUnSync);
        system.debug('cartUnSync.ccrz__E_Orders__r::'+cartUnSync.ccrz__E_Orders__r);
        system.debug('cartUnSync.ccrz__E_CartItems__r::'+cartUnSync.ccrz__E_CartItems__r);
        
        ApexPages.StandardSetController controller1 = new ApexPages.StandardSetController(cartUnSync.ccrz__E_CartItems__r);   
        
        String testUrl = 'https://acams--acamsdev.lightning.force.com/lightning/r/'+cartUnSync.Id+'/related/ccrz__E_CartItems__r/view#/sObject/'+cartUnSync.Id+'/rlName/ccrz__E_CartItems__r/view';
         system.debug('testUrl::'+testUrl);
         ApexPages.currentPage().getParameters().put('vfRetURLInSFX', testUrl);
         ApexPages.currentPage().getParameters().put('retURL', testUrl);
            
         
         DeleteCartItemsListbuttonExtension coe = new DeleteCartItemsListbuttonExtension(controller1);
         coe.selected = cartUnSync.ccrz__E_CartItems__r;
         coe.getAndDeleteSelectedCartItems();
        
        cartUnSync = [Select ID, (Select ID FROM ccrz__E_Orders__r), (Select ID FROM ccrz__E_CartItems__r) FROM ccrz__E_Cart__c Where Id=:cartUnSync.Id];
        system.debug('cartUnSync After::'+cartUnSync);
        system.debug('cartUnSync.ccrz__E_Orders__r After::'+cartUnSync.ccrz__E_Orders__r);
        system.debug('cartUnSync.ccrz__E_CartItems__r After::'+cartUnSync.ccrz__E_CartItems__r.size());
        system.assertEquals(cartUnSync.ccrz__E_CartItems__r.size(),2);
        Test.stopTest();
        
   }
}