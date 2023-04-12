@isTest
public class ACAMSCreditTriggerHandlerTest {
      @IsTest 
   public static  void testHandler1() {
        Account acc = new Account(
                ccrz__TaxExemptAccount__c = true,
                Name = 'acc'
        );
        insert acc;
        Credit__c cred = new Credit__c(
              Account__c = acc.Id,
              Amount__c = 200.00,
              Credit_Date__c = Date.today().addDays(1),
              Currency__c = 'USD',
              Credit_Type__c = 'Customer Loyalty'
        );
        insert cred;
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
        cartUnSync = [select Id,ccrz__SubtotalAmount__c from ccrz__E_Cart__c where Id=:cartUnSync.Id];
        system.debug('cartUnSync::'+cartUnSync);
        System.debug('oppo cart in testclass::'+testOpportunity.CC_Cart__c);
        System.debug('oppo cart adress in testclass'+testOpportunity.CC_Cart__r.ccrz__ShipTo__c);
        /*ccrz__E_Order__c ccOrder = new ccrz__E_Order__c (
                ccrz__Account__c = acc.Id,
                ccrz__BillTo__c = testAddress.Id,
                ccrz__Contact__c = contact.Id,
                ccrz__EncryptedId__c = '4a0644e2-8ac5-48b1-b83e-54254e37e67e',
                ccrz__Name__c = 'New Chart',
                ccrz__OrderNumber__c = 1050011,
              ccrz__OrderStatus__c = 'Order Submitted',
                 Opportunity__c = testOpportunity.Id,
                 ccrz__OriginatedCart__c = cartUnSync.Id,
                OwnerId = UserInfo.getUserId()
        );
        insert ccOrder;*/
        CCACAMSTestUtil testUtil = new CCACAMSTestUtil();
        ACAMSContactAddressTriggerHandler.skipAddressValidation = true;
        Map<String, Object> testData = testUtil.initData();
        User u = [SELECT Id FROM user WHERE profile.name='System Administrator' AND isActive = true limit 1];
        ccrz__E_Order__c testOrder = (ccrz__E_Order__c) testData.get(CCAviTestUtil.PN_ORDER);
        testOrder.ccrz__OrderStatus__c = 'In Process';
        testOrder.ccrz__CurrencyISOCode__c = 'USD';
        testOrder.OwnerId=u.id;
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
        ccrz__E_Order__c cOrders1 = [select Id,ccrz__OrderStatus__c, ccrz__TotalAmount__c,Applied_Credits__c,Total_Revenue__c, Total_Order_Amount__c,
                                          (select Id,Invoice_Status__c,Finalized__c from ccrz__CCInvoices__r ) 
                                          from ccrz__E_Order__c where Id =:testOrder.Id];
        system.debug('cOrders1.Applied_Credits__c::'+cOrders1.Applied_Credits__c);
        system.debug('cOrders1.ccrz__TotalAmount__c::'+cOrders1.ccrz__TotalAmount__c);
        system.debug('cOrders1.Total_Revenue__c::'+cOrders1.Total_Revenue__c);
        
        ccrz__E_Invoice__c invoice = new ccrz__E_Invoice__c(
                ccrz__CCOrder__c  = cOrders1.Id,
                ccrz__Type__c = 'String',
                ccrz__BillAddress__c = testAddress.Id,
                ccrz__Status__c = 'Open',
                ccrz__CurrencyCode__c = 'USD',
                ccrz__BillTo__c = acc.Id,
                ccrz__SoldAddress__c = testAddress.Id,
              Finalized__c = true,
              Invoice_Status__c = 'Open',
              ccrz__RemainingAmount__c = 100.00,
              ccrz__OriginalAmount__c = 100.00,
              ccrz__ParentInvoice__c = null
        );
       
        insert invoice;
       
        ccrz__E_Order__c cOrders2 = [select Id,ccrz__OrderStatus__c, ccrz__TotalAmount__c,Applied_Credits__c,Total_Revenue__c, Total_Order_Amount__c,
                                          (select Id,Invoice_Status__c,Finalized__c,ccrz__RemainingAmount__c from ccrz__CCInvoices__r ) 
                                          from ccrz__E_Order__c where Id =:cOrders1.Id];
        system.debug('cOrders2.Applied_Credits__c::'+cOrders2.Applied_Credits__c);
        system.debug('cOrders2.Total_Revenue__c::'+cOrders2.Total_Revenue__c);
        system.debug('cOrders2.ccrz__CCInvoices__r::'+cOrders2.ccrz__CCInvoices__r);
         system.debug('cOrders2.ccrz__CCInvoices__r[0].ccrz__RemainingAmount__c::'+cOrders2.ccrz__CCInvoices__r[0].ccrz__RemainingAmount__c);
      Test.startTest();
       Credit__c applyCred = new Credit__c(
              Account__c = acc.Id,
              Amount__c = -10.00,
              Credit_Date__c = Date.today().addDays(1),
              Currency__c = 'USD',
              Credit_Type__c = 'Credit Applied',
              CC_Order__c = cOrders2.Id,
              Invoice_Applied_For__c = invoice.Id
        );
       insert applyCred;
       
       ccrz__E_Order__c cOrders3 = [select Id,ccrz__OrderStatus__c, ccrz__TotalAmount__c,Applied_Credits__c,Total_Revenue__c, Total_Order_Amount__c,
                                          (select Id,Invoice_Status__c,Finalized__c,ccrz__RemainingAmount__c from ccrz__CCInvoices__r ) ,
                                          (select Id, Amount__c,Credit_Type__c from Credits__r)
                                          from ccrz__E_Order__c where Id =:cOrders1.Id];
        system.debug('cOrders3.Applied_Credits__c::'+cOrders3.Applied_Credits__c);
        system.debug('cOrders3.Total_Revenue__c::'+cOrders3.Total_Revenue__c);
        system.debug('cOrders3.ccrz__CCInvoices__r::'+cOrders3.ccrz__CCInvoices__r);
        system.debug('cOrders3.Credits__r::'+cOrders3.Credits__r);
         system.debug('cOrders3.ccrz__CCInvoices__r[0].ccrz__RemainingAmount__c::'+cOrders3.ccrz__CCInvoices__r[0].ccrz__RemainingAmount__c);
       system.assertEquals(90.00,cOrders3.ccrz__CCInvoices__r[0].ccrz__RemainingAmount__c);
       
       Credit__c applyCred1 = new Credit__c(Id=applyCred.Id,
              
              Amount__c = -20.00
              
        );
       update applyCred1;
       
       Test.stopTest();
        
   }
}