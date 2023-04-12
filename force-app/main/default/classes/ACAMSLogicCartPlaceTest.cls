@IsTest
public class ACAMSLogicCartPlaceTest {
    static CCAviTestUtil util = new CCAviTestUtil();

    @IsTest
    public static void processTest() {
        Map<String, Object> testData = util.initData();

        ccrz__E_Product__c product = (ccrz__E_Product__c) testData.get(CCAviTestUtil.PN_PRODUCT);
        ccrz__E_Order__c order = (ccrz__E_Order__c) testData.get(CCAviTestUtil.PN_ORDER);
        
        List<ccrz__E_OrderItem__c> orderItemList = [SELECT ccrz__Quantity__c FROM ccrz__E_OrderItem__c];
        for(ccrz__E_OrderItem__c orderItem : orderItemList){
            orderItem.ccrz__Quantity__c = 2;
        }
        update orderItemList;
        
        List<ccrz__E_TransactionPayment__c> payments = [SELECT ccrz__AccountType__c FROM ccrz__E_TransactionPayment__c];
        payments[0].ccrz__AccountType__c = ACAMSUtil.PO;
        payments[1].ccrz__AccountType__c = ACAMSUtil.WT_CAPS;
        payments[1].Bank__c = 'AUS_Chapter';
        update payments;
        

        Map<String, Object> inputData = new Map<String, Object>{
                ccrz.ccApi.SUCCESS => true,
                ccrz.ccApiCart.ORDER_ID => order.Id
        };


        ACAMSLogicCartPlace acamsLogicCartPlace = new ACAMSLogicCartPlace();

        Test.startTest();

        Map<String, Object> outputData = acamsLogicCartPlace.process(inputData);
        Test.stopTest();

        product = [
                SELECT
                        Id
                FROM
                        ccrz__E_Product__c
                WHERE
                        Id = :product.Id
        ];

        order = [
                SELECT
                        Id,
                        ccrz__OrderStatus__c
                FROM
                        ccrz__E_Order__c
                WHERE
                        Id = :order.Id
        ];

        System.assertNotEquals(null, outputData);

    }
    
    @IsTest
    public static void processTestWithWirePayment() {
        Map<String, Object> testData = util.initData();

        ccrz__E_Product__c product = (ccrz__E_Product__c) testData.get(CCAviTestUtil.PN_PRODUCT);
        ccrz__E_Order__c order = (ccrz__E_Order__c) testData.get(CCAviTestUtil.PN_ORDER);
        
        List<ccrz__E_TransactionPayment__c> payments = [SELECT ccrz__AccountType__c FROM ccrz__E_TransactionPayment__c];
        payments[0].ccrz__AccountType__c = ACAMSUtil.WT_CAPS;
        payments[1].ccrz__AccountType__c = ACAMSUtil.WT_CAPS;
        payments[0].Bank__c = 'AUS_Chapter';
        payments[1].Bank__c = 'AUS_Chapter';
        update payments;
        

        Map<String, Object> inputData = new Map<String, Object>{
                ccrz.ccApi.SUCCESS => true,
                ccrz.ccApiCart.ORDER_ID => order.Id
        };


        ACAMSLogicCartPlace acamsLogicCartPlace = new ACAMSLogicCartPlace();

        Test.startTest();

        Map<String, Object> outputData = acamsLogicCartPlace.process(inputData);
        Test.stopTest();
        System.assertNotEquals(null, outputData);

    }
    
    @IsTest
    public static void processTestWithZeroDollar() {
        Map<String, Object> testData = util.initData();

        ccrz__E_Product__c product = (ccrz__E_Product__c) testData.get(CCAviTestUtil.PN_PRODUCT);
        ccrz__E_Order__c order = (ccrz__E_Order__c) testData.get(CCAviTestUtil.PN_ORDER);
        
        List<ccrz__E_TransactionPayment__c> payments = [SELECT ccrz__AccountType__c FROM ccrz__E_TransactionPayment__c];
        payments[0].ccrz__AccountType__c = ACAMSUtil.ZERO_DOLLAR_API;
        payments[1].ccrz__AccountType__c = ACAMSUtil.ZERO_DOLLAR_API;
        update payments;
        

        Map<String, Object> inputData = new Map<String, Object>{
                ccrz.ccApi.SUCCESS => true,
                ccrz.ccApiCart.ORDER_ID => order.Id
        };


        ACAMSLogicCartPlace acamsLogicCartPlace = new ACAMSLogicCartPlace();

        Test.startTest();

        Map<String, Object> outputData = acamsLogicCartPlace.process(inputData);
        Test.stopTest();
        System.assertNotEquals(null, outputData);

    }
    
    @IsTest
    public static void processTestWithCheckPayment() {
        Map<String, Object> testData = util.initData();

        ccrz__E_Product__c product = (ccrz__E_Product__c) testData.get(CCAviTestUtil.PN_PRODUCT);
        ccrz__E_Order__c order = (ccrz__E_Order__c) testData.get(CCAviTestUtil.PN_ORDER);
        
        List<ccrz__E_TransactionPayment__c> payments = [SELECT ccrz__AccountType__c FROM ccrz__E_TransactionPayment__c];
        payments[0].ccrz__AccountType__c = ACAMSUtil.ACH_CAPS;
        payments[1].ccrz__AccountType__c = ACAMSUtil.ACH_CAPS;
        payments[0].Bank__c = 'AUS_Chapter';
        payments[1].Bank__c = 'AUS_Chapter';
        update payments;
        

        Map<String, Object> inputData = new Map<String, Object>{
                ccrz.ccApi.SUCCESS => true,
                ccrz.ccApiCart.ORDER_ID => order.Id
        };


        ACAMSLogicCartPlace acamsLogicCartPlace = new ACAMSLogicCartPlace();

        Test.startTest();

        Map<String, Object> outputData = acamsLogicCartPlace.process(inputData);
        Test.stopTest();System.assertNotEquals(null, outputData);

    }
    
    @IsTest
    public static void processTestWithInvoicePayment() {
        Map<String, Object> testData = util.initData();

        ccrz__E_Product__c product = (ccrz__E_Product__c) testData.get(CCAviTestUtil.PN_PRODUCT);
        ccrz__E_Order__c order = (ccrz__E_Order__c) testData.get(CCAviTestUtil.PN_ORDER);
        
        List<ccrz__E_TransactionPayment__c> payments = [SELECT Id FROM ccrz__E_TransactionPayment__c];
        delete payments;
        
        List<ccrz__E_AccountAddressBook__c> addressBookList = [SELECT Id FROM ccrz__E_AccountAddressBook__c];
        delete addressBookList;
        
        List<ccrz__E_Product__c> prodList = [SELECT Level_1__c FROM ccrz__E_Product__c];
        for(ccrz__E_Product__c prod : prodList){
            prod.Level_1__c = ACAMSUtil.CERTIFICATION;
        }
        update prodList;

        Map<String, Object> inputData = new Map<String, Object>{
                ccrz.ccApi.SUCCESS => true,
                ccrz.ccApiCart.ORDER_ID => order.Id
        };


        ACAMSLogicCartPlace acamsLogicCartPlace = new ACAMSLogicCartPlace();

        Test.startTest();

        Map<String, Object> outputData = acamsLogicCartPlace.process(inputData);
        Test.stopTest();System.assertNotEquals(null, outputData);

    }

    @IsTest
    public static void processTestWithMinorLineItems() {
        Map<String, Object> testData = util.initData();
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Opportunity opp = new Opportunity(Name = 'test', stageName = 'Agreement', CloseDate = System.today(), AccountId = acc.Id);
        insert opp;
        
        ccrz__E_Product__c product = (ccrz__E_Product__c) testData.get(CCAviTestUtil.PN_PRODUCT);
        ccrz__E_Order__c o = (ccrz__E_Order__c) testData.get(CCAviTestUtil.PN_ORDER);
        o.ccrz__OrderStatus__c = 'In Process';
        o.ccrz__ShipAmount__c = 1;
        o.Opportunity__c = opp.Id;

        ccrz__E_TransactionPayment__c tp =
                (ccrz__E_TransactionPayment__c) testData.get(CCAviTestUtil.PN_TRANSACTION_PAYMENT_AUTH);

        tp.ccrz__RequestAmount__c = 1.00;
        update tp;

        product.ccrz__ProductType__c = ACAMSUtil.BUNDLE;
        product.ccrz__SKU__c = '1234';
        update product;

        ccrz__E_Product__c product2 = new ccrz__E_Product__c();
        product2.Name = 'TestProduct2';
        product2.ccrz__SKU__c = 'ABCDE';
        product2.ccrz__ProductType__c = 'Bundle';
        product2.ccrz__ProductStatus__c = 'Released';
        product2.ccrz__Storefront__c = 'acams';
        product2.Level_1__c = 'Membership';
        insert product2;

        ccrz__E_OrderItem__c oi3 = new ccrz__E_OrderItem__c();
        o.ccrz__OrderStatus__c = 'In Process';
        update o;
        oi3.ccrz__Order__c = o.id;
        oi3.ccrz__OrderItemId__c = 'oi3';
        oi3.ccrz__OrderLineType__c = 'Major';
        oi3.ccrz__Product__c = product.id;
        oi3.ccrz__ParentOrderItem__c = null;
        oi3.ccrz__ParentProduct__c = null;
        oi3.ccrz__Price__c = 1.00;
        oi3.ccrz__Quantity__c = 2;
        oi3.ccrz__SubAmount__c = 1;

        insert oi3;

        ccrz__E_OrderItem__c oi4 = new ccrz__E_OrderItem__c();
        oi4.ccrz__Order__c = o.id;
        oi4.ccrz__OrderItemId__c = 'oi4';
        oi4.ccrz__OrderLineType__c = 'Minor';
        oi4.ccrz__Product__c = product2.id;
        oi4.ccrz__ParentOrderItem__c = oi3.id;
        oi4.ccrz__ParentProduct__c = product.id;
        oi4.ccrz__Price__c = 1.00;
        oi4.ccrz__Quantity__c = 2;
        oi4.ccrz__SubAmount__c = 1;

        insert oi4;

        ccrz__E_CompositeProduct__c cp = new ccrz__E_CompositeProduct__c();

        cp.ccrz__Component__c = product2.id;
        cp.ccrz__Composite__c = product.id;

        insert cp;

        Map<String, Object> inputData = new Map<String, Object>{
                ccrz.ccApi.SUCCESS => true,
                ccrz.ccApiCart.ORDER_ID => o.Id
        };

        ACAMSLogicCartPlace acamsLogicCartPlace = new ACAMSLogicCartPlace();

        Test.startTest();
        Map<String, Object> outputData = acamsLogicCartPlace.process(inputData);
        Test.stopTest();

        product = [
                SELECT
                        Id
                FROM
                        ccrz__E_Product__c
                WHERE
                        Id = :product.Id
        ];

        System.assertNotEquals(null, outputData);
    }
}