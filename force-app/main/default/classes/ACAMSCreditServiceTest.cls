@IsTest
class ACAMSCreditServiceTest {
    @TestSetup
    static void initData() {
        ACAMSContactAddressTriggerHandler.skipAddressValidation = true;
        Map<String, Object> initialData = new CCACAMSTestUtil().initData();
        ACAMSContactAddressTriggerHandler.skipAddressValidation = false;
        ccrz__E_Order__c order = (ccrz__E_Order__c) initialData.get(CCAviTestUtil.PN_ORDER);
        order.ccrz__CurrencyISOCode__c = 'USD';
        update order;
    }

    @IsTest
    static void refundOrderItem() {
        ccrz__E_OrderItem__c majorItem = [
                SELECT Id, ccrz__Order__c, ccrz__Order__r.ccrz__Account__c, ccrz__ItemTotal__c
                FROM ccrz__E_OrderItem__c
                WHERE ccrz__ParentOrderItem__c != NULL
                LIMIT 1
        ];
        Integer initialCreditRecordQuantity = [SELECT COUNT() FROM Credit__c];
        majorItem.ccrz__OrderItemStatus__c = 'Refunded - Credit';
        Test.startTest();
        update majorItem;
        Test.stopTest();
        Integer newCreditRecordQuantity = [SELECT COUNT() FROM Credit__c];
        System.assertEquals(initialCreditRecordQuantity + 1, newCreditRecordQuantity);
        Credit__c newCredit = [
                SELECT
                        Account__c, Amount__c, CC_Order__c, Credit_Date__c,
                        Credit_Type__c, Currency__c
                FROM Credit__c
                LIMIT 1
        ];
        ccrz__E_Order__c cloneOrder = [
                SELECT
                        Id, ccrz__TotalAmount__c
                FROM
                        ccrz__E_Order__c
                WHERE
                        ccrz__Name__c = 'Refunded Order'
        ];
        System.assertEquals(majorItem.ccrz__Order__r.ccrz__Account__c, newCredit.Account__c);
        System.assertEquals(majorItem.ccrz__ItemTotal__c, newCredit.Amount__c);
        System.assertEquals(majorItem.ccrz__Order__c, newCredit.CC_Order__c);
        System.assertEquals(Date.today(), newCredit.Credit_Date__c);
        System.assertEquals('Refund', newCredit.Credit_Type__c);
        System.assertEquals('USD', newCredit.Currency__c);
    }

    @IsTest
    static void refundOrderItemWithTaxes() {
        ccrz__E_OrderItem__c majorItem = [
                SELECT Id, ccrz__Order__c, ccrz__ItemTotal__c, Total_Item_Taxes__c, ccrz__Order__r.ccrz__Account__c
                FROM ccrz__E_OrderItem__c
                WHERE ccrz__ParentOrderItem__c != NULL
                LIMIT 1
        ];
        Integer initialCreditRecordQuantity = [SELECT COUNT() FROM Credit__c];
        majorItem.Total_Item_Taxes__c = 10;
        update majorItem;
        majorItem.ccrz__OrderItemStatus__c = 'Refunded - Credit';
        Test.startTest();
        update majorItem;
        Test.stopTest();
        Integer newCreditRecordQuantity = [SELECT COUNT() FROM Credit__c];
        System.assertEquals(initialCreditRecordQuantity + 1, newCreditRecordQuantity);
        Credit__c newCredit = [
                SELECT
                        Account__c, Amount__c, CC_Order__c, Credit_Date__c,
                        Credit_Type__c, Currency__c
                FROM Credit__c
                LIMIT 1
        ];
        ccrz__E_Order__c cloneOrder = [
                SELECT
                        Id, ccrz__TotalAmount__c
                FROM
                        ccrz__E_Order__c
                WHERE
                        ccrz__Name__c = 'Refunded Order'
        ];
        System.assertEquals(majorItem.ccrz__Order__r.ccrz__Account__c, newCredit.Account__c);
        System.assertEquals(majorItem.ccrz__ItemTotal__c + 10, newCredit.Amount__c);
        System.assertEquals(majorItem.ccrz__Order__c, newCredit.CC_Order__c);
        System.assertEquals(Date.today(), newCredit.Credit_Date__c);
        System.assertEquals('Refund', newCredit.Credit_Type__c);
        System.assertEquals('USD', newCredit.Currency__c);

    }

    @IsTest
    static void refundOrderItemWithEnterpriseAccount() {
        Account enterpriseAccount = new Account(
                Name = 'Enterprise Account'
        );
        insert enterpriseAccount;
        ccrz__E_AccountGroup__c accountGroup = [
                SELECT Id, Enterprise_Account__c
                FROM ccrz__E_AccountGroup__c
                LIMIT 1
        ];
        accountGroup.Enterprise_Account__c = enterpriseAccount.Id;
        update accountGroup;
        ccrz__E_OrderItem__c majorItem = [
                SELECT Id, ccrz__Order__c, ccrz__ItemTotal__c, Total_Item_Taxes__c
                FROM ccrz__E_OrderItem__c
                WHERE ccrz__ParentOrderItem__c != NULL
                LIMIT 1
        ];
        update new ccrz__E_Order__c (
                Id = majorItem.ccrz__Order__c,
                Account_Group__c = accountGroup.Id
        );
        Integer initialCreditRecordQuantity = [SELECT COUNT() FROM Credit__c];
        majorItem.ccrz__OrderItemStatus__c = 'Refunded - Credit';
        Test.startTest();
        update majorItem;
        Test.stopTest();
        Integer newCreditRecordQuantity = [SELECT COUNT() FROM Credit__c];
        System.assertEquals(initialCreditRecordQuantity + 1, newCreditRecordQuantity);
        Credit__c newCredit = [
                SELECT
                        Account__c, Amount__c, CC_Order__c, Credit_Date__c,
                        Credit_Type__c, Currency__c
                FROM Credit__c
                LIMIT 1
        ];
        ccrz__E_Order__c cloneOrder = [
                SELECT
                        Id, ccrz__TotalAmount__c
                FROM
                        ccrz__E_Order__c
                WHERE
                        ccrz__Name__c = 'Refunded Order'
        ];
        System.assertEquals(enterpriseAccount.Id, newCredit.Account__c);
        System.assertEquals(majorItem.ccrz__ItemTotal__c, newCredit.Amount__c);
        System.assertEquals(majorItem.ccrz__Order__c, newCredit.CC_Order__c);
        System.assertEquals(Date.today(), newCredit.Credit_Date__c);
        System.assertEquals('Refund', newCredit.Credit_Type__c);
        System.assertEquals('USD', newCredit.Currency__c);
    }

    @IsTest
    static void refundOrder() {
        ccrz__E_Order__c refundOrder = [
                SELECT Id, ccrz__Account__c, ccrz__TotalAmount__c, ccrz__OrderStatus__c
                FROM ccrz__E_Order__c
                LIMIT 1
        ];
        Integer initialCreditQuantity = [SELECT COUNT() FROM Credit__c];
        refundOrder.ccrz__OrderStatus__c = 'Refunded - Credit';
        Test.startTest();
        update refundOrder;
        Test.stopTest();
        Integer newCreditQuantity = [SELECT COUNT() FROM Credit__c];
        System.assertEquals(initialCreditQuantity + 1, newCreditQuantity);
        Credit__c newCredit = [
                SELECT
                        Account__c, Amount__c, CC_Order__c, Credit_Date__c,
                        Credit_Type__c, Currency__c
                FROM Credit__c
                LIMIT 1
        ];
        ccrz__E_Order__c cloneOrder = [
                SELECT
                        Id, ccrz__TotalAmount__c
                FROM
                        ccrz__E_Order__c
                WHERE
                        ccrz__Name__c = 'Refunded Order'
        ];
        System.assertEquals(refundOrder.ccrz__Account__c, newCredit.Account__c);
        System.assertEquals(-(cloneOrder.ccrz__TotalAmount__c), newCredit.Amount__c);
        System.assertEquals(refundOrder.Id, newCredit.CC_Order__c);
        System.assertEquals(Date.today(), newCredit.Credit_Date__c);
        System.assertEquals('Refund', newCredit.Credit_Type__c);
        System.assertEquals('USD', newCredit.Currency__c);
    }

    @IsTest
    static void refundOrderToEnterpriseAccount() {
        Account enterpriseAccount = new Account(
                Name = 'Enterprise Account'
        );
        insert enterpriseAccount;
        ccrz__E_AccountGroup__c accountGroup = [
                SELECT Id, Enterprise_Account__c
                FROM ccrz__E_AccountGroup__c
                LIMIT 1
        ];
        accountGroup.Enterprise_Account__c = enterpriseAccount.Id;
        update accountGroup;
        ccrz__E_Order__c refundOrder = [
                SELECT Id, ccrz__Account__c, ccrz__TotalAmount__c, ccrz__OrderStatus__c
                FROM ccrz__E_Order__c
                LIMIT 1
        ];
        Integer initialCreditQuantity = [SELECT COUNT() FROM Credit__c];
        refundOrder.Account_Group__c = accountGroup.Id;
        refundOrder.ccrz__OrderStatus__c = 'Refunded - Credit';
        Test.startTest();
        update refundOrder;
        Test.stopTest();
        Integer newCreditQuantity = [SELECT COUNT() FROM Credit__c];
        System.assertEquals(initialCreditQuantity + 1, newCreditQuantity);
        Credit__c newCredit = [
                SELECT
                        Account__c, Amount__c, CC_Order__c, Credit_Date__c,
                        Credit_Type__c, Currency__c
                FROM Credit__c
                LIMIT 1
        ];
        ccrz__E_Order__c cloneOrder = [
                SELECT
                        Id, ccrz__TotalAmount__c
                FROM
                        ccrz__E_Order__c
                WHERE
                        ccrz__Name__c = 'Refunded Order'
        ];
        System.assertEquals(enterpriseAccount.Id, newCredit.Account__c);
        System.assertEquals(-(cloneOrder.ccrz__TotalAmount__c), newCredit.Amount__c);
        System.assertEquals(refundOrder.Id, newCredit.CC_Order__c);
        System.assertEquals(Date.today(), newCredit.Credit_Date__c);
        System.assertEquals('Refund', newCredit.Credit_Type__c);
        System.assertEquals('USD', newCredit.Currency__c);
    }

    @IsTest
    static void refundOrderDuringPartial() {
         Test.startTest();
        ccrz__E_OrderItem__c majorItem = [
                SELECT Id, ccrz__Order__c, ccrz__Order__r.ccrz__Account__c, ccrz__ItemTotal__c, ccrz__OrderItemStatus__c
                FROM ccrz__E_OrderItem__c
                WHERE ccrz__ParentOrderItem__c != NULL
                LIMIT 1
        ];
        Integer initialCreditRecordQuantity = [SELECT COUNT() FROM Credit__c];
        majorItem.ccrz__OrderItemStatus__c = 'Refunded - Credit';
        update majorItem;
        Integer newCreditRecordQuantity = [SELECT COUNT() FROM Credit__c];
        System.assertEquals(initialCreditRecordQuantity + 1, newCreditRecordQuantity);
        ccrz__E_Order__c refundOrder = new ccrz__E_Order__c (
                Id = majorItem.ccrz__Order__c,
                ccrz__OrderStatus__c = 'Refunded - Credit'
        );

        Database.SaveResult orderSaveResult = Database.update(refundOrder, false);
        Test.stopTest();
        System.assert(!orderSaveResult.isSuccess());
        Integer lastCreditQuantity = [SELECT COUNT() FROM Credit__c];
        System.assertEquals(newCreditRecordQuantity, lastCreditQuantity);
    }
}