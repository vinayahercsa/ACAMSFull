public with sharing class ACAMSCCOrderCCInvoiceEntryService {

    public class InvoiceData {
        public ccrz__E_Invoice__c           invoice      { get; set; }
        public List<ccrz__E_InvoiceItem__c> invoiceItems { get; set; }
    }

    /**
     * By given order item finds parent invoice and its items available to split
     */
    public static ACAMSCCOrderCCInvoiceEntryService.InvoiceData getParentInvoiceData(Id orderId) {
        InvoiceData parentInvoiceData = new InvoiceData();
        parentInvoiceData.invoice = getParentInvoice(orderId);
        if (parentInvoiceData.invoice != null) {
            parentInvoiceData.invoiceItems = getAvailableParentInvoiceItems(parentInvoiceData.invoice.Id);
        }
        return parentInvoiceData;
    }

    /**
     * Adds Quantity__c values to target items from sourceItems.
     * targetItem.Quantity += sourceItem.Quantity__c
     */
    public static void addItemsQuantity(
        List<ccrz__E_InvoiceItem__c> targetItems,
        List<ccrz__E_InvoiceItem__c> sourceItems
    ) {
        addItemsQuantityWithCoefficient(targetItems, sourceItems, 1);
    }

    /**
     * Subtracts Quantity__c values in target items taken from sourceItems.
     * targetItem.Quantity -= sourceItem.Quantity__c
     */
    public static void subtractItemsQuantity(
        List<ccrz__E_InvoiceItem__c> targetItems,
        List<ccrz__E_InvoiceItem__c> sourceItems
    ) {
        addItemsQuantityWithCoefficient(targetItems, sourceItems, -1);
    }

    /**
     * Validates if the requested in source items can be subtracted in target items
     */
    public static Boolean validateItemsQuantityToSubtract(
        List<ccrz__E_InvoiceItem__c> targetItems,
        List<ccrz__E_InvoiceItem__c> sourceItems
    ) {
        Map<Id, ccrz__E_InvoiceItem__c> targetItemByOrderItemId = new Map<Id, ccrz__E_InvoiceItem__c>();
        for (ccrz__E_InvoiceItem__c targetItem : targetItems) {
            targetItemByOrderItemId.put(targetItem.ccrz__CCOrderItem__c, targetItem);
        }
        Boolean quantityIsValid = true;
        for (ccrz__E_InvoiceItem__c sourceItem : sourceItems) {
            ccrz__E_InvoiceItem__c targetItem = targetItemByOrderItemId.get(sourceItem.ccrz__CCOrderItem__c);
            quantityIsValid &= (
                (targetItem != null) &&
                (sourceItem.Quantity__c > 0) &&
                ((targetItem.Quantity__c - sourceItem.Quantity__c) >= 0)
            );
        }
        return quantityIsValid;
    }

    /**
    * By given order Id finds invoice that can be the base to split the invoice
    */
    private static ccrz__E_Invoice__c getParentInvoice(Id orderId) {
        ccrz__E_Invoice__c parentInvoice;
        List<ccrz__E_Invoice__c> parentInvoices = [
            SELECT
                Id, ccrz__Contact__c, ccrz__Status__c, ccrz__User__c, ccrz__CCOrder__c, ccrz__DateIssued__c,
                ccrz__Storefront__c, ccrz__SoldTo__c, ccrz__BillTo__c, ccrz__CurrencyCode__c,
                ccrz__BillAddress__c, ccrz__SoldAddress__c,
                ccrz__BillAddress__r.ccrz__FirstName__c, ccrz__BillAddress__r.ccrz__MiddleName__c,
                ccrz__BillAddress__r.ccrz__LastName__c, ccrz__BillAddress__r.ccrz__Email__c,
                ccrz__BillAddress__r.ccrz__AddressFirstline__c, ccrz__BillAddress__r.ccrz__AddressSecondline__c,
                ccrz__BillAddress__r.ccrz__City__c, ccrz__BillAddress__r.ccrz__StateISOCode__c,
                ccrz__BillAddress__r.ccrz__State__c, ccrz__BillAddress__r.ccrz__CountryISOCode__c,
                ccrz__BillAddress__r.ccrz__Country__c, ccrz__BillAddress__r.ccrz__PostalCode__c,
                ccrz__SoldAddress__r.ccrz__CountryISOCode__c
            FROM ccrz__E_Invoice__c
            WHERE
                ccrz__ParentInvoice__c = NULL AND
                ccrz__CCOrder__c = :orderId
        ];
        if (!parentInvoices.isEmpty()) {
            parentInvoice = parentInvoices[0];
        }
        return parentInvoice;
    }

    /**
     * By given parent invoice id, finds invoice items and filters the items
     * which are already split into child invoices
     */
    private static List<ccrz__E_InvoiceItem__c> getAvailableParentInvoiceItems(Id parentInvoiceId) {
        Map<Id, ccrz__E_InvoiceItem__c> parentInvoiceItemByOrderItemId = new Map<Id, ccrz__E_InvoiceItem__c>();
        // collect parent invoice items, fill quantity field and store in map {invoiceItem.orderItemId => invoice item}
        for(ccrz__E_InvoiceItem__c parentInvoiceItem : [
            SELECT
                ccrz__CCOrder__c, ccrz__CCOrderItem__c, ccrz__CCOrderItem__r.ccrz__Quantity__c, ccrz__OriginalAmount__c,
                ccrz__Invoice__c, ccrz__Invoice__r.ccrz__BillAddress__r.ccrz__Country__c,
                ccrz__Invoice__r.ccrz__BillAddress__r.ccrz__CountryISOCode__c,
                ccrz__Invoice__r.ccrz__SoldAddress__r.ccrz__CountryISOCode__c, Quantity__c, ccrz__Sequence__c,
                ccrz__Status__c,  ccrz__Comments__c, ItemQuantity__c, Tax_Amount__c, ccrz__Type__c,
                ccrz__CCOrderItem__r.Name, ccrz__CCOrderItem__r.ccrz__Product_Name__c, Legal_Entity__c,
                Product_Level_1__c, Product_Level_2__c, Product_Level_3__c, Destination_Country__c, ccrz__CCOrderItem__r.ccrz__Product__r.is_Virtual__c, ccrz__CCOrderItem__r.ccrz__Product__r.Is_live__c, ccrz__CCOrderItem__r.ccrz__Product__r.Is_Digital__c FROM ccrz__E_InvoiceItem__c
            WHERE
                ccrz__Invoice__c = :parentInvoiceId
        ]) {
            parentInvoiceItem.Quantity__c = parentInvoiceItem.ItemQuantity__c;
            parentInvoiceItemByOrderItemId.put(parentInvoiceItem.ccrz__CCOrderItem__c, parentInvoiceItem);
        }
        // collect invoice items from child invoices and subtract their quantities
        // from corresponding parent invoice items (calculation of remaining qty)
        for (ccrz__E_InvoiceItem__c childInvoiceItem : [
            SELECT Id, Quantity__c, ccrz__CCOrderItem__c
            FROM ccrz__E_InvoiceItem__c
            WHERE ccrz__Invoice__r.ccrz__ParentInvoice__c = :parentInvoiceId
        ]) {
            ccrz__E_InvoiceItem__c parentInvoiceItem =
                    parentInvoiceItemByOrderItemId.get(childInvoiceItem.ccrz__CCOrderItem__c);
            if (
                parentInvoiceItem != null &&
                parentInvoiceItem.Quantity__c != null &&
                childInvoiceItem.Quantity__c != null
            ) {
                parentInvoiceItem.Quantity__c -= childInvoiceItem.Quantity__c;
            }
        }
        // store only the invoice items with remaining qty > 0
        List<ccrz__E_InvoiceItem__c> availableParentInvoiceItems = new List<ccrz__E_InvoiceItem__c>();
        for (ccrz__E_InvoiceItem__c parentInvoiceItem : parentInvoiceItemByOrderItemId.values()) {
            if (parentInvoiceItem.Quantity__c != null && parentInvoiceItem.Quantity__c > 0) {
                availableParentInvoiceItems.add(parentInvoiceItem);
            }
        }
        return availableParentInvoiceItems;
    }

    private static void addItemsQuantityWithCoefficient(
        List<ccrz__E_InvoiceItem__c> targetItems,
        List<ccrz__E_InvoiceItem__c> sourceItems,
        Decimal coefficient
    ) {
        Map<Id, ccrz__E_InvoiceItem__c> targetItemByOrderItemId = new Map<Id, ccrz__E_InvoiceItem__c>();
        for (ccrz__E_InvoiceItem__c targetItem : targetItems) {
            targetItemByOrderItemId.put(targetItem.ccrz__CCOrderItem__c, targetItem);
        }
        for (ccrz__E_InvoiceItem__c sourceItem : sourceItems) {
            ccrz__E_InvoiceItem__c targetItem = targetItemByOrderItemId.get(sourceItem.ccrz__CCOrderItem__c);
            Decimal quantityChange = sourceItem.Quantity__c * coefficient;
            if (targetItem != null) {
                targetItem.Quantity__c = targetItem.Quantity__c + quantityChange;
            } else if (quantityChange > 0) {
                targetItemByOrderItemId.put(sourceItem.ccrz__CCOrderItem__c, sourceItem);
            }
        }
    }
}