global without sharing class ACAMSInvoice extends ccrz.cc_hk_Invoice {

    /**
     * Workaround in place to delete the Tax invoice since we recalculate taxes on a final invoice.
     *
     */
    global override Map<String, Object> onOrder(Map<String, Object> inputData) {
        Map<String, Object> outputData = super.onOrder(inputData);
        List<ccrz__E_InvoiceItem__c> invoiceItemsToDelete = new List<ccrz__E_InvoiceItem__c>();
        List<ccrz__E_InvoiceItem__c> invoiceItems = (List<ccrz__E_InvoiceItem__c>) outputData.get(ccrz.cc_hk_Invoice.PARAM_INVOICE_ITEMS);
        for (ccrz__E_InvoiceItem__c invoiceItem : invoiceItems) {
            if (invoiceItem.ccrz__Type__c == 'Tax') {
                invoiceItemsToDelete.add(invoiceItem);
            }
        }
        delete invoiceItemsToDelete;
        return outputData;
    }
}