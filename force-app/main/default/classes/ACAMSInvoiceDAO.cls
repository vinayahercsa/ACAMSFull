public with sharing class ACAMSInvoiceDAO {

    public static List<ccrz__E_InvoiceItem__c> getInvoiceIdsFromInvoiceItems(Set<Id> invoiceItemIds) {
        List<ccrz__E_InvoiceItem__c> invoiceItemsWithIds = [
                SELECT
                        Id,
                        ccrz__Invoice__c
                FROM
                        ccrz__E_InvoiceItem__c
                WHERE
                        Id IN :invoiceItemIds
        ];

        return invoiceItemsWithIds;
    }

    public static List<ccrz__E_Invoice__c> getInvoices(Set<Id> invoiceIds) {
        List<ccrz__E_Invoice__c> invoices = [
                SELECT
                        Id,
                        ccrz__OriginalAmount__c,
                        ccrz__Status__c,
                        Invoice_Status__c,
                        Refund_Date__c,
                        ccrz__BillAddress__c,
                        ccrz__BillTo__c,
                        ccrz__SoldTo__c,
                (
                        SELECT
                                Id
                        FROM
                                ccrz__ChildInvoices__r
                ), (
                        SELECT
                                Id
                        FROM
                                S_Docs_Relationships__r
                ),
                        ccrz__CCOrder__c,
                        ccrz__CCOrder__r.ccrz__OrderStatus__c,
                        ccrz__CCOrder__r.ccrz__PaymentMethod__c,
                        ccrz__Storefront__c,
                        ccrz__Type__c,
                        Destination_Address_1__c,
                        Destination_City__c,
                        Destination_Country__c,
                        Customer_Name__c,
                        Legal_Entity__c,
                        ccrz__Contact__c,
                        ccrz__User__c,
                        ccrz__CurrencyCode__c,
                        ccrz__DateIssued__c,
                        ccrz__PaidAmount__c,
                        ccrz__RemainingAmount__c,
                        Sold_To_Tax_Area_Id__c,
                        Invoice_Item_Taxes__c,
                        Finalized__c,
                        Seller_Tax_Registration_ID__c
                FROM
                        ccrz__E_Invoice__c
                WHERE
                        Id IN :invoiceIds
        ];

        return invoices;
    }

    public static List<ccrz__E_InvoiceItem__c> getInvoiceItemsWithOrderItemIds(Set<Id> invoiceIds, Set<Id> orderItemIds) {
        List<ccrz__E_InvoiceItem__c> invoices = [
                SELECT
                        Id,
                        ccrz__Invoice__c,
                        ccrz__CCOrder__c,
                        ccrz__CCOrderItem__c,
                        ItemQuantity__c,
                        Product_Level_1__c,
                        Product_Level_2__c,
                        Product_Level_3__c,
                        Parent_Object_Type__c,
                        Legal_Entity_Formula__c,
                        Legal_Entity__c,
                        Legal_Entity_Code__c,
                        Total_Amount__c,
                        ccrz__Status__c,
                        ccrz__OriginalAmount__c,
                        ccrz__Type__c
                FROM
                        ccrz__E_InvoiceItem__c
                WHERE
                        ccrz__Invoice__c IN :invoiceIds
                AND
                        ccrz__CCOrderItem__c IN :orderItemIds
        ];

        return invoices;
    }
}