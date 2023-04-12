@isTest
public class ACAMSCCOrderCCInvoiceEntryControllerTest {

    @TestSetup
    static void setup() {
        insert new CCACAMSTestUtil().createVertexTaxCalculationBypassSettings();
        Account account = new Account(
                Name = 'Facebook'
        );
        insert account;
        Contact contact = new Contact(
                AccountId = account.Id,
                LastName = 'Karl'
        );
        insert contact;
        ccrz__E_ContactAddr__c adr = new ccrz__E_ContactAddr__c(
                OwnerId = UserInfo.getUserId()
        );
        insert adr;
        
        ccrz__E_Order__c ccOrder = new ccrz__E_Order__c (
                ccrz__Account__c = account.Id,
                ccrz__BillTo__c = adr.Id,
                ccrz__Contact__c = contact.Id,
                ccrz__EncryptedId__c = '4a0644e2-8ac5-48b1-b83e-54254e37e67e',
                ccrz__Name__c = 'New Chart',
                ccrz__OrderNumber__c = 1050011,
                OwnerId = UserInfo.getUserId()
        );
        insert ccOrder;
        ccrz__E_OrderItem__c parentOrderItem = new ccrz__E_OrderItem__c(
                ccrz__Order__c = ccOrder.Id,
                ccrz__Price__c = 20,
                ccrz__Quantity__c = 2,
                ccrz__SubAmount__c = 2
        );
        insert parentOrderItem;
        ccrz__E_Invoice__c invoice = new ccrz__E_Invoice__c(
                ccrz__CCOrder__c = ccOrder.Id,
                ccrz__Type__c = 'String',
                ccrz__BillAddress__c = adr.Id,
                ccrz__Status__c = 'Open',
                ccrz__CurrencyCode__c = 'USD',
                ccrz__BillTo__c = account.Id,
                ccrz__SoldAddress__c = adr.Id
        );
        insert invoice;
       
        ccrz__E_InvoiceItem__c inItem = new ccrz__E_InvoiceItem__c(
                ccrz__Invoice__c = invoice.Id,
                ccrz__CCOrderItem__c = parentOrderItem.Id,
                ccrz__Comments__c = ' ',
                ccrz__OriginalAmount__c = 2,
                ccrz__Type__c = 'Tax',
                ccrz__Status__c = 'Open',
                ccrz__Sequence__c = 1
        );
        insert inItem;
        ccrz__E_Invoice__c childInvoice = new ccrz__E_Invoice__c(
                ccrz__CCOrder__c = ccOrder.Id,
                ccrz__Type__c = 'String',
                ccrz__BillAddress__c = adr.Id,
                ccrz__Status__c = 'Open',
                ccrz__CurrencyCode__c = 'USD',
                ccrz__BillTo__c = account.Id,
                ccrz__SoldAddress__c = adr.Id,
                ccrz__ParentInvoice__c = invoice.Id
        );
        insert childInvoice;
        ccrz__E_InvoiceItem__c childInvoiceItem = new ccrz__E_InvoiceItem__c(
                ccrz__Invoice__c = childInvoice.Id,
                ccrz__CCOrderItem__c = parentOrderItem.Id,
                ccrz__Comments__c = ' ',
                ccrz__OriginalAmount__c = 2,
                ccrz__Type__c = 'Tax',
                ccrz__Status__c = 'Open',
                ccrz__Sequence__c = 1,
                Quantity__c = 1
        );
        insert childInvoiceItem;
    }

    @isTest
    public static void testRightExtensionFlow() {
 
        ccrz__E_Order__c ccOrder = [
                SELECT Id
                FROM ccrz__E_Order__c
        ];
        ccrz__E_Invoice__c invoice = [
                SELECT Id
                FROM ccrz__E_Invoice__c
                WHERE ccrz__ParentInvoice__c = NULL
        ];
        Account acc = [
                SELECT Id
                FROM Account
        ];
        ccrz__E_ContactAddr__c adr = [
                SELECT Id
                FROM ccrz__E_ContactAddr__c
        ];

        Apexpages.StandardController sc = new Apexpages.StandardController(ccOrder);
        ACAMSCCOrderCCInvoiceEntryController ext = new ACAMSCCOrderCCInvoiceEntryController(sc);

        ext.changeShowShippingAddress();
        ext.invoiceData[0].showShippingAddress = true;
        ext.invoiceData[0].invoice = new ccrz__E_Invoice__c(
                ccrz__CCOrder__c = ccOrder.Id,
                ccrz__ParentInvoice__c = invoice.Id,
                ccrz__Type__c = 'String',
                ccrz__BillAddress__c = adr.Id,
                ccrz__Status__c = 'Open',
                ccrz__CurrencyCode__c = 'USD',
                ccrz__BillTo__c = acc.Id,
                ccrz__SoldAddress__c = adr.Id
        );
        ext.activeInvoice = ext.invoiceData[0];
        ext.targetInvoiceItemId = ext.availableInvoiceItems[0].Id;
        ext.addItem();
        System.assert(!String.isBlank(ext.getAddedOrderItemIds()));
        ext.saveInvoices();
        ext.addNewInvoice();
        ext.removeLastInvoice();
        ext.activeInvoiceIndex = 1;
        ext.openItemsModal();
        ext.closeItemsModal();
        ext.removeItem();

        List<ccrz__E_Invoice__c> childInvoices = [
                SELECT Id
                FROM ccrz__E_Invoice__c
                WHERE ccrz__CCOrder__c = :ccOrder.Id
                AND ccrz__ParentInvoice__c = :invoice.Id
        ];
        System.assertEquals(2, childInvoices.size());
    }

    @isTest
    public static void wrongdataTest() {
        ccrz__E_Order__c ccOrder = [
                SELECT Id
                FROM ccrz__E_Order__c
        ];
        ccrz__E_ContactAddr__c adr = [
                SELECT Id
                FROM ccrz__E_ContactAddr__c
        ];
        ccrz__E_Invoice__c invoice = [
                SELECT Id
                FROM ccrz__E_Invoice__c
                WHERE ccrz__ParentInvoice__c = NULL
        ];
        Apexpages.StandardController sc = new Apexpages.StandardController(ccOrder);
        ACAMSCCOrderCCInvoiceEntryController ext = new ACAMSCCOrderCCInvoiceEntryController(sc);
        ext.invoiceData[0].invoice = new ccrz__E_Invoice__c(
                ccrz__CCOrder__c = ccOrder.Id,
                ccrz__Type__c = 'String',
                ccrz__BillAddress__c = adr.Id,
                ccrz__Status__c = 'Open',
                ccrz__CurrencyCode__c = 'USD',
                ccrz__SoldAddress__c = adr.Id
        );
        ext.saveInvoices();
        ext.addItem();

        List<ccrz__E_Invoice__c> childInvoices = [
                SELECT Id
                FROM ccrz__E_Invoice__c
                WHERE ccrz__CCOrder__c = :ccOrder.Id
                AND ccrz__ParentInvoice__c = :invoice.Id
        ];
        System.assertEquals(1, childInvoices.size());
    }

}