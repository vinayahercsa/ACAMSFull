public with sharing class ACAMSCreditTriggerHandler extends CCAviTriggerHandler {

    private List<Credit__c> newList;
    private List<Credit__c> oldList;
    private Map<Id, Credit__c> newMap;
    private Map<Id, Credit__c> oldMap;
    private Map<Id, ccrz__E_Order__c> orders;
    private Map<Id, ccrz__E_Invoice__c> invoices; //FSA-464

    public ACAMSCreditTriggerHandler() {
        this.newList = (List<Credit__c>) Trigger.new;
        this.oldList = (List<Credit__c>) Trigger.old;
        this.newMap = (Map<Id, Credit__c>) Trigger.newMap;
        this.oldMap = (Map<Id, Credit__c>) Trigger.oldMap;
        Set<Id> orderIds = new Set<Id>();
        Set<Id> invoiceIds = new Set<Id>();
        if (Trigger.isUpdate || Trigger.isDelete) {
            for (Credit__c credit : oldList) {
                orderIds.add(credit.CC_Order__c);
                invoiceIds.add(credit.Invoice_Applied_For__c);	//FSA-464
            }
        }
        if (Trigger.isUpdate || Trigger.isInsert) {
            for (Credit__c credit : newList) {
                orderIds.add(credit.CC_Order__c);
                invoiceIds.add(credit.Invoice_Applied_For__c);	//FSA-464
            }
        }
        orders = new Map<Id, ccrz__E_Order__c> (ACAMSOrderDAO.getOrders(orderIds));
        invoices = new Map<Id, ccrz__E_Invoice__c> (ACAMSInvoiceDAO.getInvoices(invoiceIds));	//FSA-464
    }
    public override void afterInsert() {
        applyCredits();
        createTransferCreditObject();
    }

    public override void afterUpdate() {
        applyCredits();
    }

    public override void afterDelete() {
        applyCredits();
    }

    private void applyCredits() {
        Map<Id, Credit__c> oldCreditMap = new Map<Id, Credit__c>();
        Map<Id, Credit__c> newCreditMap = new Map<Id, Credit__c>();
        //FSA-464
        Map<Id, Credit__c> oldCreditInvMap = new Map<Id, Credit__c>();
        Map<Id, Credit__c> newCreditInvMap = new Map<Id, Credit__c>();
        //FSA-464
        if (Trigger.isUpdate || Trigger.isDelete) {
            for (Credit__c credit : oldList) {
                if (credit.Credit_Type__c == 'Credit Applied') {
                    oldCreditMap.put(credit.CC_Order__c, credit);
                    oldCreditInvMap.put(credit.Invoice_Applied_For__c, credit);	//FSA-464
                }
            }
        }
        if (Trigger.isUpdate || Trigger.isInsert) {
            for (Credit__c credit : newList) {
                if (credit.Credit_Type__c == 'Credit Applied') {
                    newCreditMap.put(credit.CC_Order__c, credit);
                    newCreditInvMap.put(credit.Invoice_Applied_For__c, credit); //FSA-464
                }
            }
        }

        List<ccrz__E_Order__c> ordersToUpdate = new List<ccrz__E_Order__c>();
        for (ccrz__E_Order__c order : orders.values()) {
            Credit__c creditFromOrder;
            if (Trigger.isDelete || Trigger.isUpdate) {
                if (oldCreditMap.containsKey(order.Id)) {
                    creditFromOrder = oldCreditMap.get(order.Id);
                    system.debug('order.Applied_Credits__c Operation::'+Trigger.operationType+'creditsbefore::'+order.Applied_Credits__c);
                    order.Applied_Credits__c = order.Applied_Credits__c - Math.abs(creditFromOrder.Amount__c);
                    system.debug('order.Applied_Credits__c Operation::'+Trigger.operationType+'creditsAfter::'+order.Applied_Credits__c);
                }
                if (Trigger.isUpdate) {
                    if (newCreditMap.containsKey(order.Id)) {
                        creditFromOrder = newCreditMap.get(order.Id);
                        ccrz__E_Order__c newOrder = orders.get(creditFromOrder.CC_Order__c);
                        newOrder.Applied_Credits__c = newOrder.Applied_Credits__c + Math.abs(creditFromOrder.Amount__c);
                        system.debug('order.Applied_Credits__c Operation2::'+Trigger.operationType+'credits::'+order.Applied_Credits__c);
                    }
                }
            } else {
                if (newCreditMap.containsKey(order.Id)) {
                    creditFromOrder = newCreditMap.get(order.Id);
                    order.Applied_Credits__c = order.Applied_Credits__c + Math.abs(creditFromOrder.Amount__c);
                    system.debug('order.Applied_Credits__c Operation3::'+Trigger.operationType+'creditsAfter::'+order.Applied_Credits__c);
                }
            }
            ordersToUpdate.add(order);
        }
        //FSA-464
        system.debug('invoices.values()::'+invoices.values());
        List<ccrz__E_Invoice__c> invoicesToUpdate = new List<ccrz__E_Invoice__c>();
        for (ccrz__E_Invoice__c invoice : invoices.values()) {
            Credit__c creditFromInvoice;
            if (Trigger.isDelete || Trigger.isUpdate) {
                if (oldCreditInvMap.containsKey(invoice.Id)) {
                    creditFromInvoice = oldCreditInvMap.get(invoice.Id);
                    system.debug('invoice.ccrz__RemainingAmount__c Operation::'+Trigger.operationType+'creditsbefore::'+invoice.ccrz__RemainingAmount__c);
                    invoice.ccrz__RemainingAmount__c = invoice.ccrz__RemainingAmount__c + Math.abs(creditFromInvoice.Amount__c);
                    system.debug('invoice.ccrz__RemainingAmount__c Operation::'+Trigger.operationType+'creditsAfter::'+invoice.ccrz__RemainingAmount__c);
                }
                if (Trigger.isUpdate) {
                    if (newCreditInvMap.containsKey(invoice.Id)) {
                        creditFromInvoice = newCreditInvMap.get(invoice.Id);
                        ccrz__E_Invoice__c newInvoice = invoices.get(creditFromInvoice.Invoice_Applied_For__c);
                        system.debug('newInvoice.ccrz__RemainingAmount__c Operation2 before::'+Trigger.operationType+'credits before::'+newInvoice.ccrz__RemainingAmount__c);
                        newInvoice.ccrz__RemainingAmount__c = newInvoice.ccrz__RemainingAmount__c - Math.abs(creditFromInvoice.Amount__c);
                        system.debug('newInvoice.ccrz__RemainingAmount__c Operation2 After::'+Trigger.operationType+'credits After::'+newInvoice.ccrz__RemainingAmount__c);
                    }
                }
            } else {
                if (newCreditInvMap.containsKey(invoice.Id)) {
                    creditFromInvoice = newCreditInvMap.get(invoice.Id);
                    invoice.ccrz__RemainingAmount__c = invoice.ccrz__RemainingAmount__c - Math.abs(creditFromInvoice.Amount__c);
                    system.debug('invoice.ccrz__RemainingAmount__c Operation3::'+Trigger.operationType+'creditsAfter::'+invoice.ccrz__RemainingAmount__c);
                }
            }
            invoicesToUpdate.add(invoice);
        }
        if(ordersToUpdate.size()>0) {
        	update ordersToUpdate;
        }
        if(invoicesToUpdate.size()>0) {
        	update invoicesToUpdate;
        }
        //FSA-464
    }

    private void createTransferCreditObject() {
        List<Credit__c> creditsToInsert = new List<Credit__c>();
        for (Credit__c credit : newList) {
            if (credit.Credit_Type__c == 'Transfer between accounts' && credit.Amount__c > 0) {
                Credit__c clonedCredit = credit.clone();
                clonedCredit.Amount__c = -(credit.Amount__c);
                clonedCredit.Account__c = credit.Origin_Account__c;
                clonedCredit.Origin_Account__c = credit.Account__c;

                creditsToInsert.add(clonedCredit);
            }
        }
        insert creditsToInsert;
    }
}