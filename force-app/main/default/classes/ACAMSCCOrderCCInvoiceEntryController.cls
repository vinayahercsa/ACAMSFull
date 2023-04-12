public with sharing class ACAMSCCOrderCCInvoiceEntryController {

    private Id orderId;

    public Boolean                      modalOpened           { get; set; }
    public Boolean                      isError               { get; set; }

    public String                       modalErrorMessage     { get; set; }
    public List<InvoiceWrapper>         invoiceData           { get; set; }
    public List<ccrz__E_InvoiceItem__c> availableInvoiceItems { get; set; }
    public ccrz__E_Invoice__c           parentInvoice         { get; set; }
    public Id                           targetInvoiceItemId   { get; set; }
    public Integer                      activeInvoiceIndex    { get; set; }
    public InvoiceWrapper               activeInvoice         { get; set; }

    public String getAddedOrderItemIds() {
        Set<String> addedOrderItemIds = new Set<String>();
        for (ccrz__E_InvoiceItem__c addedItem : this.activeInvoice.itemsList) {
            addedOrderItemIds.add(addedItem.ccrz__CCOrderItem__c);
        }
        return String.join(new List<String>(addedOrderItemIds), ';');
    }

    public class InvoiceWrapper {
        public Integer                         index               { get; set; }
        public ccrz__E_Invoice__c              invoice             { get; set; }
        public ccrz__E_ContactAddr__c          billingAddress      { get; set; }
        public ccrz__E_ContactAddr__c          shippingAddress     { get; set; }
        public Boolean                         showShippingAddress { get; set; }
        public List<ccrz__E_InvoiceItem__c>    itemsList           { get; set; }

        public InvoiceWrapper(ccrz__E_Invoice__c parentInvoice, Integer index) {
            this.invoice = new ccrz__E_Invoice__c(
                ccrz__CCOrder__c         = parentInvoice.ccrz__CCOrder__c,
                ccrz__ParentInvoice__c   = parentInvoice.Id,
                ccrz__Contact__c         = parentInvoice.ccrz__Contact__c,
                ccrz__Status__c          = parentInvoice.ccrz__Status__c,
                Invoice_Status__c        = parentInvoice.ccrz__Status__c,
                ccrz__User__c            = parentInvoice.ccrz__User__c,
                ccrz__OriginalAmount__c  = 0,
                ccrz__RemainingAmount__c = 0,
                ccrz__Storefront__c      = parentInvoice.ccrz__Storefront__c,
                ccrz__SoldTo__c          = parentInvoice.ccrz__SoldTo__c,
                ccrz__BillTo__c          = parentInvoice.ccrz__BillTo__c,
                ccrz__CurrencyCode__c    = parentInvoice.ccrz__CurrencyCode__c,
                ccrz__DateIssued__c      = parentInvoice.ccrz__DateIssued__c
            );
            this.billingAddress      = new ccrz__E_ContactAddr__c(
                ccrz__FirstName__c = parentInvoice.ccrz__BillAddress__r.ccrz__FirstName__c,
                ccrz__MiddleName__c = parentInvoice.ccrz__BillAddress__r.ccrz__MiddleName__c,
                ccrz__LastName__c = parentInvoice.ccrz__BillAddress__r.ccrz__LastName__c,
                ccrz__Email__c = parentInvoice.ccrz__BillAddress__r.ccrz__Email__c,
                ccrz__AddressFirstline__c = parentInvoice.ccrz__BillAddress__r.ccrz__AddressFirstline__c,
                ccrz__AddressSecondline__c = parentInvoice.ccrz__BillAddress__r.ccrz__AddressSecondline__c,
                ccrz__City__c = parentInvoice.ccrz__BillAddress__r.ccrz__City__c,
                ccrz__StateISOCode__c = parentInvoice.ccrz__BillAddress__r.ccrz__StateISOCode__c,
                ccrz__State__c = parentInvoice.ccrz__BillAddress__r.ccrz__State__c,
                ccrz__CountryISOCode__c = parentInvoice.ccrz__BillAddress__r.ccrz__CountryISOCode__c,
                ccrz__Country__c = parentInvoice.ccrz__BillAddress__r.ccrz__Country__c,
                ccrz__PostalCode__c = parentInvoice.ccrz__BillAddress__r.ccrz__PostalCode__c
            );
            this.shippingAddress     = new ccrz__E_ContactAddr__c();
            this.showShippingAddress = false;
            this.itemsList           = new List<ccrz__E_InvoiceItem__c>();
            this.index               = index;
        }

        public void recalculateAmounts() {
            this.invoice.ccrz__RemainingAmount__c = 0;
            this.invoice.ccrz__OriginalAmount__c  = 0;
            for (ccrz__E_InvoiceItem__c item : this.itemsList) {
                Decimal itemAmount = item.ccrz__OriginalAmount__c * item.Quantity__c / item.ItemQuantity__c;
                this.invoice.ccrz__RemainingAmount__c += itemAmount;
                this.invoice.ccrz__OriginalAmount__c  += itemAmount;
            }
        }
    }

    public ACAMSCCOrderCCInvoiceEntryController(ApexPages.StandardController ccOrderController) {
        this.orderId = ccOrderController.getId();
        this.isError = false;
        this.modalErrorMessage = '';
        this.initParentInvoiceData();
        this.modalOpened = false;
        this.invoiceData = new List<InvoiceWrapper>();
        this.addNewInvoice();
    }

    public void addNewInvoice() {
        Integer index = this.invoiceData.size() + 1;
        invoiceData.add(new InvoiceWrapper(this.parentInvoice, index));
    }

    public void removeLastInvoice() {
        if (this.invoiceData.size() > 0) {
            Integer lastInvoiceIndex = this.invoiceData.size() - 1;
            InvoiceWrapper lastInvoice = this.invoiceData[lastInvoiceIndex];
            ACAMSCCOrderCCInvoiceEntryService.addItemsQuantity(this.availableInvoiceItems, lastInvoice.itemsList);
            invoiceData.remove(this.invoiceData.size() - 1);
        }
    }

    public void changeShowShippingAddress() {
    }

    public PageReference saveInvoices() {
        List<ccrz__E_ContactAddr__c> addresses    = new List<ccrz__E_ContactAddr__c>();
        List<ccrz__E_Invoice__c>     invoices     = new List<ccrz__E_Invoice__c>();
        List<ccrz__E_InvoiceItem__c> invoiceItems = new List<ccrz__E_InvoiceItem__c>();
        Savepoint savepoint = Database.setSavepoint();
        try {
            for (InvoiceWrapper invoiceRecord : this.invoiceData) {
                addresses.add(invoiceRecord.billingAddress);
                if (invoiceRecord.showShippingAddress) {
                    addresses.add(invoiceRecord.shippingAddress);
                }
            }
            insert addresses;
            for (InvoiceWrapper invoiceRecord : this.invoiceData) {
                if (invoiceRecord.billingAddress.Id != null) {
                    invoiceRecord.invoice.ccrz__BillAddress__c = invoiceRecord.billingAddress.Id;
                }
                if (invoiceRecord.shippingAddress.Id != null) {
                    invoiceRecord.invoice.ccrz__SoldAddress__c = invoiceRecord.shippingAddress.Id;
                }
                invoices.add(invoiceRecord.invoice);
            }
            insert invoices;
            for (InvoiceWrapper invoiceRecord : this.invoiceData) {
                for (ccrz__E_InvoiceItem__c invoiceItem : invoiceRecord.itemsList) {
                    invoiceItems.add(createInvoiceItem(invoiceItem, invoiceRecord));
                }
            }
            insert invoiceItems;
        } catch (Exception e) {
            Database.rollback(savepoint);
            showErrorMessage(e.getMessage());
            return null;
        }
        PageReference orderPage = new PageReference('/' + this.orderId);
        orderPage.setRedirect(true);
        return orderPage;
    }

    private ccrz__E_InvoiceItem__c createInvoiceItem(ccrz__E_InvoiceItem__c sourceItem) {
        Decimal newAmount = sourceItem.ccrz__OriginalAmount__c * sourceItem.Quantity__c / sourceItem.ItemQuantity__c;
        ccrz__E_InvoiceItem__c newItem = new ccrz__E_InvoiceItem__c(
            ccrz__CCOrder__c        = sourceItem.ccrz__CCOrder__c,
            ccrz__CCOrderItem__c    = sourceItem.ccrz__CCOrderItem__c,
            ccrz__Comments__c       = sourceItem.ccrz__Comments__c,
            ccrz__OriginalAmount__c = newAmount,
            ccrz__Sequence__c       = sourceItem.ccrz__Sequence__c,
            ccrz__Status__c         = sourceItem.ccrz__Status__c,
            Tax_Amount__c           = sourceItem.Tax_Amount__c,
            ccrz__Type__c           = sourceItem.ccrz__Type__c,
            Quantity__c             = sourceItem.Quantity__c
        );
        return newItem;
    }

    private ccrz__E_InvoiceItem__c createInvoiceItem(ccrz__E_InvoiceItem__c sourceItem, InvoiceWrapper invoiceRecord) {
        ccrz__E_InvoiceItem__c newItem = createInvoiceItem(sourceItem);
        newItem.ccrz__Invoice__c = invoiceRecord.invoice.Id;
        return newItem;
    }

    private void initParentInvoiceData() {
        ACAMSCCOrderCCInvoiceEntryService.InvoiceData parentInvoiceData =
            ACAMSCCOrderCCInvoiceEntryService.getParentInvoiceData(this.orderId);
        this.parentInvoice         = parentInvoiceData.invoice;
        this.availableInvoiceItems = parentInvoiceData.invoiceItems;
        if (this.parentInvoice == null) {
            showErrorMessage(Label.ACAMSCCOrderCCInvoicePage_MissingParentInvoice);
        }
    }

    public void openItemsModal() {
        this.modalOpened   = true;
        this.activeInvoice = this.invoiceData[this.activeInvoiceIndex - 1];
        ACAMSCCOrderCCInvoiceEntryService.addItemsQuantity(
                this.availableInvoiceItems,
                this.activeInvoice.itemsList
        );
    }

    public void closeItemsModal() {
        this.modalErrorMessage = '';
        if (ACAMSCCOrderCCInvoiceEntryService.validateItemsQuantityToSubtract(
                this.availableInvoiceItems,
                this.activeInvoice.itemsList
        )) {
            this.modalOpened = false;
            ACAMSCCOrderCCInvoiceEntryService.subtractItemsQuantity(
                    this.availableInvoiceItems,
                    this.activeInvoice.itemsList
            );
            this.activeInvoice.recalculateAmounts();
            this.invoiceData[this.activeInvoiceIndex - 1] = this.activeInvoice;
        } else {
            this.modalErrorMessage = Label.ACAMSCCOrderCCInvoicePage_InvalidQuantitiesEntered;
        }
    }

    public void addItem() {
        Integer index = findItemIndex(this.availableInvoiceItems, this.targetInvoiceItemId);
        if (index > -1) {
            ccrz__E_InvoiceItem__c addedItem = this.availableInvoiceItems[index].clone(true, true);
            addedItem.Tax_Amount__c = null;
            this.activeInvoice.itemsList.add(addedItem);
        }
    }

    public void removeItem() {
        Integer index = findItemIndex(this.activeInvoice.itemsList, this.targetInvoiceItemId);
        if (index > -1) {
            this.activeInvoice.itemsList.remove(index);
        }
    }

    private Integer findItemIndex(List<ccrz__E_InvoiceItem__c> items, Id targetId) {
        Integer i = 0;
        for (;i < items.size() && items[i].Id != targetId; i++);
        if (i >= items.size()) {
            i = -1;
        }
        return i;
    }

    private void showErrorMessage(String message) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
        this.isError = true;
    }
}