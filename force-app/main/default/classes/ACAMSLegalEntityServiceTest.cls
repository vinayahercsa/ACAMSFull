@IsTest
class ACAMSLegalEntityServiceTest {

    @TestSetup
    static void initData() {
        Map<String, Object> initialData = new CCACAMSTestUtil().initData();
        ccrz__E_Order__c order = (ccrz__E_Order__c) initialData.get(CCAviTestUtil.PN_ORDER);
        User u = [SELECT Id FROM user WHERE profile.name='System Administrator' AND isActive = true limit 1];
        order.OwnerId=u.id;
        update order;
        List<ccrz__E_OrderItem__c> orderItems = (List<ccrz__E_OrderItem__c>) initialData.get(CCAviTestUtil.PN_ORDER_ITEMS);
        ccrz__E_OrderItem__c orderItem = orderItems[0];
        ccrz__E_Invoice__c invoice = new ccrz__E_Invoice__c (
                ccrz__BillAddress__c = order.ccrz__BillTo__c,
                ccrz__SoldAddress__c = order.ccrz__ShipTo__c,
                ccrz__BillTo__c = order.ccrz__Account__c,
                ccrz__SoldTo__c = order.ccrz__Account__c,
                ccrz__OriginalAmount__c = order.ccrz__SubtotalAmount__c,
                ccrz__RemainingAmount__c = order.ccrz__SubtotalAmount__c,
                ccrz__CCOrder__c = order.Id,
                ccrz__Contact__c = order.ccrz__Contact__c,
                ccrz__User__c = order.ccrz__User__c,
                ccrz__CurrencyCode__c = order.ccrz__CurrencyISOCode__c
        );
        insert invoice;
        ccrz__E_InvoiceItem__c invoiceItem = new ccrz__E_InvoiceItem__c(
                ccrz__Invoice__c = invoice.Id,
                ccrz__CCOrder__c = order.Id,
                ccrz__CCOrderItem__c = orderItem.Id,
                ccrz__OriginalAmount__c = orderItem.ccrz__SubAmount__c
        );
        insert invoiceItem;
    }

    @IsTest
    static void insertCartItem() {
        for (ccrz__E_CartItem__c cartItem : [
                SELECT Legal_Entity__c, Legal_Entity_Formula__c
                FROM ccrz__E_CartItem__c
        ]) {
            System.assertEquals(cartItem.Legal_Entity_Formula__c, cartItem.Legal_Entity__c);
        }
    }

    @IsTest
    static void updateCartItem() {
        ccrz__E_CartItem__c cartItem = [
                SELECT ccrz__Cart__c, ccrz__Cart__r.ccrz__BillTo__c
                FROM ccrz__E_CartItem__c
                LIMIT 1
        ];
        update new ccrz__E_Cart__c (
                Id = cartItem.ccrz__Cart__c,
                ccrz__CurrencyISOCode__c = 'CNY'
        );
        update new ccrz__E_ContactAddr__c (
                Id = cartItem.ccrz__Cart__r.ccrz__BillTo__c,
                ccrz__CountryISOCode__c = 'CN'
        );
        update cartItem;
        cartItem = [
                SELECT Legal_Entity__c, Legal_Entity_Formula__c
                FROM ccrz__E_CartItem__c
                WHERE Id = :cartItem.Id
        ];
        System.assertEquals(cartItem.Legal_Entity_Formula__c, cartItem.Legal_Entity__c);
    }

    @IsTest
    static void insertOrderItem() {
        for (ccrz__E_OrderItem__c orderItem : [
                SELECT Legal_Entity__c, Legal_Entity_Formula__c
                FROM ccrz__E_OrderItem__c
        ]) {
            System.assertEquals(orderItem.Legal_Entity_Formula__c, orderItem.Legal_Entity__c);
        }
    }

    @IsTest
    static void updateOrderItem() {
        ccrz__E_OrderItem__c orderItem = [
                SELECT ccrz__Order__c, ccrz__Order__r.ccrz__BillTo__c
                FROM ccrz__E_OrderItem__c
                LIMIT 1
        ];
        update new ccrz__E_Order__c (
                Id = orderItem.ccrz__Order__c,
                ccrz__OrderStatus__c = 'In Process',
                ccrz__CurrencyISOCode__c = 'CNY'
        );
        update new ccrz__E_ContactAddr__c (
                Id = orderItem.ccrz__Order__r.ccrz__BillTo__c,
                ccrz__CountryISOCode__c = 'CN'
        );
        update orderItem;
        orderItem = [
                SELECT Legal_Entity__c, Legal_Entity_Formula__c
                FROM ccrz__E_OrderItem__c
                WHERE Id = :orderItem.Id
        ];
        System.assertEquals(orderItem.Legal_Entity_Formula__c, orderItem.Legal_Entity__c);
    }

    @IsTest
    static void insertInvoiceItem() {
        for (ccrz__E_InvoiceItem__c invoiceItem : [
                SELECT Legal_Entity__c, Legal_Entity_Formula__c
                FROM ccrz__E_InvoiceItem__c
        ]) {
            System.assertEquals(invoiceItem.Legal_Entity_Formula__c, invoiceItem.Legal_Entity__c);
        }
    }

    @IsTest
    static void updateInvoiceItem() {
        ccrz__E_InvoiceItem__c invoiceItem = [
                SELECT ccrz__Invoice__c, ccrz__Invoice__r.ccrz__BillAddress__c
                FROM ccrz__E_InvoiceItem__c
                LIMIT 1
        ];
        update new ccrz__E_Invoice__c (
                Id = invoiceItem.ccrz__Invoice__c,
                ccrz__CurrencyCode__c = 'CNY'
        );
        update new ccrz__E_ContactAddr__c (
                Id = invoiceItem.ccrz__Invoice__r.ccrz__BillAddress__c,
                ccrz__CountryISOCode__c = 'CN'
        );
        update invoiceItem;
        invoiceItem = [
                SELECT Legal_Entity__c, Legal_Entity_Formula__c
                FROM ccrz__E_InvoiceItem__c
                WHERE Id = :invoiceItem.Id
        ];
        System.assertEquals(invoiceItem.Legal_Entity_Formula__c, invoiceItem.Legal_Entity__c);
    }

    @IsTest
    static void updateCart() {
        ccrz__E_CartItem__c cartItem = [
                SELECT ccrz__Cart__c, ccrz__Cart__r.ccrz__BillTo__c
                FROM ccrz__E_CartItem__c
                LIMIT 1
        ];
        update new ccrz__E_Cart__c (
                Id = cartItem.ccrz__Cart__c,
                ccrz__CurrencyISOCode__c = 'CNY'
        );
        update new ccrz__E_ContactAddr__c (
                Id = cartItem.ccrz__Cart__r.ccrz__BillTo__c,
                ccrz__CountryISOCode__c = 'CN'
        );
        update cartItem;
        cartItem = [
                SELECT Legal_Entity__c, ccrz__Cart__r.Legal_Entity__c
                FROM ccrz__E_CartItem__c
                WHERE Id = :cartItem.Id
        ];
        System.assert(cartItem.ccrz__Cart__r.Legal_Entity__c.contains(cartItem.Legal_Entity__c));
    }

    @IsTest
    static void updateOrder() {
        ccrz__E_OrderItem__c orderItem = [
                SELECT ccrz__Order__c, ccrz__Order__r.ccrz__BillTo__c
                FROM ccrz__E_OrderItem__c
                LIMIT 1
        ];
        update new ccrz__E_Order__c (
                Id = orderItem.ccrz__Order__c,
                ccrz__OrderStatus__c = 'In Process',
                ccrz__CurrencyISOCode__c = 'CNY'
        );
        update new ccrz__E_ContactAddr__c (
                Id = orderItem.ccrz__Order__r.ccrz__BillTo__c,
                ccrz__CountryISOCode__c = 'CN'
        );
        update orderItem;
        orderItem = [
                SELECT Legal_Entity__c, ccrz__Order__r.Legal_Entity__c
                FROM ccrz__E_OrderItem__c
                WHERE Id = :orderItem.Id
        ];
        System.assert(orderItem.ccrz__Order__r.Legal_Entity__c.contains(orderItem.Legal_Entity__c));
    }

    @IsTest
    static void updateInvoice() {
        ccrz__E_InvoiceItem__c invoiceItem = [
                SELECT ccrz__Invoice__c, ccrz__Invoice__r.ccrz__BillAddress__c
                FROM ccrz__E_InvoiceItem__c
                LIMIT 1
        ];
        update new ccrz__E_Invoice__c (
                Id = invoiceItem.ccrz__Invoice__c,
                ccrz__CurrencyCode__c = 'CNY'
        );
        update new ccrz__E_ContactAddr__c (
                Id = invoiceItem.ccrz__Invoice__r.ccrz__BillAddress__c,
                ccrz__CountryISOCode__c = 'CN'
        );
        update invoiceItem;
        invoiceItem = [
                SELECT Legal_Entity__c, ccrz__Invoice__r.Legal_Entity__c
                FROM ccrz__E_InvoiceItem__c
                WHERE Id = :invoiceItem.Id
        ];
        System.assert(invoiceItem.ccrz__Invoice__r.Legal_Entity__c.contains(invoiceItem.Legal_Entity__c));
    }

}