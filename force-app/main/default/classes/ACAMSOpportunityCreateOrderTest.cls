@IsTest
class ACAMSOpportunityCreateOrderTest {

    @IsTest
    static void createOrder() {
        //CCACAMSTestUtil testUtil = new CCACAMSTestUtil();
        ACAMSContactAddressTriggerHandler.skipAddressValidation = true;
        //Map<String, Object> testData = testUtil.initData();
        
        ACAMSContactAddressTriggerHandler.skipAddressValidation = false;
        Account testAccount = new account(name = 'test');
        insert testAccount;
        ccrz__E_Cart__c testCart = new ccrz__E_Cart__c(ccrz__Name__c = 'cart');
           insert testCart;
        ccrz__E_Order__c testOrder = new ccrz__E_Order__c(ccrz__Name__c = 'order');
        insert testorder;
        testOrder.ccrz__OrderStatus__c = 'In Process';
        update testOrder;
        
        Opportunity testOpportunity;
        testOpportunity = new Opportunity(
                AccountId = testAccount.Id,
                CC_Cart__c = testCart.Id,
                Name = 'Test Opportunity',
                StageName = Opportunity.StageName.getDescribe().getPicklistValues()[0].getValue(),
                CloseDate = Date.today().addDays(10)
        );
        ACAMSOpportunityTriggerHandler.skipCartCreationOnInsert = true;
        insert testOpportunity;
        ACAMSOpportunityTriggerHandler.skipCartCreationOnInsert = false;
        ApexPages.StandardController opportunityController = new ApexPages.StandardController(testOpportunity);
        ACAMSOpportunityCreateOrderController controller = new ACAMSOpportunityCreateOrderController(
                opportunityController
        );
        ACAMSOpportunityCreateOrderController.testOrderId = testOrder.Id;
        Test.setCurrentPage(Page.ACAMSOpportunityCreateOrder);
        ApexPages.PageReference opportunityReference = controller.goToOpportunityPage();
        System.assert(opportunityReference.getUrl().contains(testOpportunity.Id));
        controller.createOrder();
        System.assert(!controller.successful);
        //ApexPages.PageReference oderReference = controller.goToOrderPage();
        //System.assert(oderReference.getUrl().contains(testOrder.Id));
        System.assert(!ApexPages.getMessages().isEmpty());
    }

    @IsTest
    static void createOrderError() {
        //CCACAMSTestUtil testUtil = new CCACAMSTestUtil();
        ACAMSContactAddressTriggerHandler.skipAddressValidation = true;
       // Map<String, Object> testData = testUtil.initData();
        ACAMSContactAddressTriggerHandler.skipAddressValidation = false;
         Account testAccount = new account(name = 'test');
        insert testAccount;
        ccrz__E_Cart__c testCart = new ccrz__E_Cart__c(ccrz__Name__c = 'cart');
           insert testCart;
        ccrz__E_Order__c testOrder = new ccrz__E_Order__c(ccrz__Name__c = 'order');
        insert testorder;
        
        Opportunity testOpportunity;
        testOpportunity = new Opportunity(
                AccountId = testAccount.Id,
                CC_Cart__c = null,
                Name = 'Test Opportunity',
                StageName = Opportunity.StageName.getDescribe().getPicklistValues()[0].getValue(),
                CloseDate = Date.today().addDays(10)
        );
        ACAMSOpportunityTriggerHandler.skipCartCreationOnInsert = true;
        insert testOpportunity;
        ACAMSOpportunityTriggerHandler.skipCartCreationOnInsert = false;
        ApexPages.StandardController opportunityController = new ApexPages.StandardController(testOpportunity);
        ACAMSOpportunityCreateOrderController controller = new ACAMSOpportunityCreateOrderController(
                opportunityController
        );
        ACAMSOpportunityCreateOrderController.testOrderId = testOrder.Id;
        ApexPages.PageReference opportunityReference = controller.goToOpportunityPage();
        System.assert(opportunityReference.getUrl().contains(testOpportunity.Id));
        controller.createOrder();
        System.assert(!controller.successful);
        System.assert(!ApexPages.getMessages().isEmpty());
    }
    //FSA-496
    @isTest
    public static void createOrderError1() {
        Account acc = new Account(
                ccrz__TaxExemptAccount__c = true,
                Name = 'acc'
        );
        insert acc;

        ccrz__E_ContactAddr__c testAddress = new ccrz__E_ContactAddr__c(
                OwnerId = UserInfo.getUserId(),
                ccrz__AddressFirstline__c = 'line1',
                ccrz__AddressSecondline__c = 'line2',
                ccrz__AddressThirdline__c = 'line3',
                ccrz__City__c = 'city',
                ccrz__State__c = 'state',
                ccrz__Country__c = 'country',
                ccrz__CountryISOCode__c = 'US',
                ccrz__PostalCode__c = 'postalCode'
                //Vertex_Tax_Area_Id__c = 780123322
        );
        ACAMSContactAddressTriggerHandler.skipAddressValidation = true;
        insert testAddress;
        System.debug('testAddress::'+testAddress);
        ccrz__E_Cart__c cartUnSync = new ccrz__E_Cart__c(
                ccrz__ShipAmount__c = 2,
                ccrz__TotalDiscount__c = 2,
                ccrz__BillTo__c = testAddress.Id,
                ccrz__ShipTo__c = testAddress.Id,
                ccrz__Account__c = acc.Id
        );
        insert cartUnSync;
        System.debug('cartUnSync::'+cartUnSync);
                Opportunity testOpportunity = new Opportunity(
                CloseDate = Date.today().addDays(2000),
                ForecastCategoryName = 'Pipeline',
                Name = 'testOpp',
                Probability = 100,
                StageName = 'Qualification',
                CC_Cart__c = cartUnSync.Id,
                AccountId = acc.Id
        );
        insert testOpportunity;
        Opportunity testOpp = [
                SELECT Id, CC_Cart__c, CC_Cart__r.ccrz__ShipTo__c, CC_Cart__r.ccrz__BillTo__c,
                        CC_Cart__r.ccrz__TotalQuantity__c,CC_Cart__r.Id,CC_Cart__r.ccrz__BillTo__r.Vertex_Tax_Area_Id__c
                FROM Opportunity
                WHERE Id = :testOpportunity.Id
        ];
        System.debug(testOpp.CC_Cart__c);
        System.debug(testOpp.CC_Cart__r.ccrz__BillTo__c);
        System.debug('taxareaId::' + testOpp.CC_Cart__r.ccrz__BillTo__r.Vertex_Tax_Area_Id__c);
        Test.startTest();
    ApexPages.StandardController opportunityController = new ApexPages.StandardController(testOpp);
        ACAMSOpportunityCreateOrderController controller = new ACAMSOpportunityCreateOrderController(
                opportunityController
        );
        controller.createOrder();
        system.debug('error Msg::'+ApexPages.getMessages());
        System.assert(!controller.successful);
        System.assert(!ApexPages.getMessages().isEmpty());
        Test.stopTest();
    }
    //FSA-496
   ////start test class FSA-954-Chinna
    @isTest
    public static void createCart(){
        
        Account acc = new Account(
                ccrz__TaxExemptAccount__c = true,
                Name = 'acc'
        );
        insert acc;

        ccrz__E_ContactAddr__c testAddress = new ccrz__E_ContactAddr__c(
                OwnerId = UserInfo.getUserId(),
                ccrz__AddressFirstline__c = 'line1',
                ccrz__AddressSecondline__c = 'line2',
                ccrz__AddressThirdline__c = 'line3',
                ccrz__City__c = 'city',
                ccrz__State__c = 'state',
                ccrz__Country__c = 'country',
                ccrz__CountryISOCode__c = 'US',
                ccrz__PostalCode__c = 'postalCode'
                //Vertex_Tax_Area_Id__c = 780123322
        );
        ACAMSContactAddressTriggerHandler.skipAddressValidation = true;
        insert testAddress;
        System.debug('testAddress::'+testAddress);
        ccrz__E_Cart__c cartUnSync = new ccrz__E_Cart__c(
                ccrz__ShipAmount__c = 2,
                ccrz__TotalDiscount__c = 2,
                ccrz__BillTo__c = testAddress.Id,
                ccrz__ShipTo__c = testAddress.Id,
               ccrz__CartStatus__c = 'Closed',
                ccrz__Account__c = acc.Id
        );
        insert cartUnSync;
        System.debug('cartUnSync::'+cartUnSync);
                Opportunity testOpportunity = new Opportunity(
                CloseDate = Date.today().addDays(2000),
                ForecastCategoryName = 'Pipeline',
                Name = 'testOpp',
                Probability = 100,
                StageName = 'Qualification',
                CC_Cart__c = cartUnSync.Id,
                AccountId = acc.Id
        );
        insert testOpportunity;
        
         ccrz__E_Order__c testOrder = new ccrz__E_Order__c(ccrz__Name__c = 'order',ccrz__OrderStatus__c = 'In Process',ccrz__OrderDate__c= Date.today());
        insert testorder;
         testOrder.ccrz__ShipAmount__c = 0;
		testOrder.ccrz__TaxAmount__c = 0;
		testOrder.ccrz__AdjustmentAmount__c = 0;
		testOrder.ccrz__ShipDiscountAmount__c = 0;
		testOrder.ccrz__TotalSurcharge__c = 0;
         testOrder.ccrz__PaymentMethod__c = 'Zero Dollar';
        testOrder.Paid_in_Full_Date__c = testOrder.ccrz__OrderDate__c;
         testOrder.ccrz__OrderStatus__c = 'Completed';
        testOrder.ccrz__Account__c = acc.id;
        update testOrder;
        
        Opportunity testOpp = [
                SELECT Id, CC_Cart__c, CC_Cart__r.ccrz__ShipTo__c, CC_Cart__r.ccrz__BillTo__c,
                        CC_Cart__r.ccrz__TotalQuantity__c,CC_Cart__r.Id,CC_Cart__r.ccrz__BillTo__r.Vertex_Tax_Area_Id__c
                FROM Opportunity
                WHERE Id = :testOpportunity.Id
        ];
        
   ccrz__E_TransactionPayment__c transpay = new ccrz__E_TransactionPayment__c(ccrz__AccountType__c='zero_dollar',
 ccrz__Amount__c=testOrder.Total_Order_Amount__c,
 ccrz__RequestAmount__c = testOrder.Total_Order_Amount__c,
 ccrz__CurrencyISOCode__c = 'USD',
 ccrz__TransactionType__c = 'capture',
 ccrz__PaymentType__c = 'zero_dollar',
 ccrz__Storefront__c = 'acams',
 ccrz__SoldTo__c =testOrder.ccrz__Account__c,
 ccrz__CCOrder__c = testOrder.Id,
 ccrz__BillTo__c =testOrder.ccrz__Account__c,
  ccrz__Account__c =testOrder.ccrz__Account__c);
        
        insert transpay;
        
        ccrz__E_Invoice__c invoice = new ccrz__E_Invoice__c(ccrz__CCOrder__c =testOrder.Id);
        insert invoice;
        
        System.debug(testOpp.CC_Cart__c);
        System.debug(testOpp.CC_Cart__r.ccrz__BillTo__c);
        System.debug('taxareaId::' + testOpp.CC_Cart__r.ccrz__BillTo__r.Vertex_Tax_Area_Id__c);
        
        Test.startTest();
    ApexPages.StandardController opportunityController = new ApexPages.StandardController(testOpp);
        ACAMSOpportunityCreateOrderController controller = new ACAMSOpportunityCreateOrderController(
                opportunityController
        );
        ACAMSOpportunityCreateOrderController.testOrderId = testOrder.Id;
             controller.placeCart();
        controller.reopenCartIfRequired(cartUnSync);
       
        Test.stopTest();
   
        
    }   
       
}