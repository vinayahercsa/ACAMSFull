public with sharing class ACAMSTransactionPaymentTriggerHandler extends CCAviTriggerHandler {
    private List<ccrz__E_TransactionPayment__c> newTransactionPayments;

    public ACAMSTransactionPaymentTriggerHandler() {
        this.newTransactionPayments = (List<ccrz__E_TransactionPayment__c>) Trigger.new;
    }

    public override void beforeInsert() {
        List<ccrz__E_TransactionPayment__c> captureList = new List<ccrz__E_TransactionPayment__c>();
        Set<String> tokens = new Set<String>();
        for (ccrz__E_TransactionPayment__c tp : newTransactionPayments) {
            if (tp.ccrz__AccountType__c == 'sopcc') {
                if (tp.ccrz__AccountNumber__c.startsWith('3') && tp.ccrz__PaymentType__c != '003_sopcc') {
                    tp.ccrz__PaymentType__c = '003_sopcc';
                } else if (tp.ccrz__AccountNumber__c.startsWith('4') && tp.ccrz__PaymentType__c != '001_sopcc') {
                    tp.ccrz__PaymentType__c = '001_sopcc';
                } else if ((tp.ccrz__AccountNumber__c.startsWith('5') || tp.ccrz__AccountNumber__c.startsWith('2')) &&
                        tp.ccrz__PaymentType__c != '002_sopcc') {
                    tp.ccrz__PaymentType__c = '002_sopcc';
                } else if (tp.ccrz__AccountNumber__c.startsWith('6') && tp.ccrz__PaymentType__c != '004_sopcc') {
                    tp.ccrz__PaymentType__c = '004_sopcc';
                }
            }
           if (tp.ccrz__TransactionType__c.equalsIgnoreCase('capture')) {
                captureList.add(tp);
            }
            if (tp.ccrz__Token__c != null) {
                tokens.add(tp.ccrz__Token__c);
            }
        }

        Set<Id> orderIds = new Set<Id>();
        for (ccrz__E_TransactionPayment__c tp : captureList) {
            orderIds.add(tp.ccrz__CCOrder__c);
        }

        List<ccrz__E_Order__c> orderList = ACAMSOrderDAO.getInvoiceOrders(orderIds);

        Map<Id, ccrz__E_Order__c> orderIdMap = new Map<Id, ccrz__E_Order__c>();
        for (ccrz__E_Order__c order : orderList) {
            if (!orderIdMap.containsKey(order.Id)) {
                orderIdMap.put(order.Id, order);
            }
        }

        List<ccrz__E_Invoice__c> invoiceUpdateList = new List<ccrz__E_Invoice__c>();
        for (ccrz__E_TransactionPayment__c tp : captureList) {
            ccrz__E_Order__c order = orderIdMap.get(tp.ccrz__CCOrder__c);
            if (order != null && order.ccrz__CCInvoices__r != null && !order.ccrz__CCInvoices__r.isEmpty() &&
                    order.ccrz__CCInvoices__r.get(0) != null) {
                ccrz__E_Invoice__c invoice = order.ccrz__CCInvoices__r.get(0);
                if (tp.ccrz__InvoiceAppliedFor__c != null) {
                    for (ccrz__E_Invoice__c orderInvoice : order.ccrz__CCInvoices__r) {
                        if (orderInvoice.Id == tp.ccrz__InvoiceAppliedFor__c) {
                            invoice = orderInvoice;
                        }
                    }
                }
                invoice.ccrz__RemainingAmount__c = invoice.ccrz__RemainingAmount__c - tp.ccrz__Amount__c;
               if (invoice.ccrz__RemainingAmount__c == 0) {
                    invoice.Invoice_Status__c = 'Closed';
                    invoice.ccrz__Status__c = 'Closed';
                    invoice.Paid_in_Full_Date__c = Date.today();
                    if (invoice.ccrz__ParentInvoice__c != null) {
                        Boolean closeParent = true;
                        ccrz__E_Invoice__c parentInvoice = null;
                        for (ccrz__E_Invoice__c inv : order.ccrz__CCInvoices__r) {
                            if (inv.ccrz__ParentInvoice__c == null) {
                                parentInvoice = inv;
                            }
                            if (inv.Invoice_Status__c != 'Closed' && inv.ccrz__ParentInvoice__c != null) {
                                closeParent = false;
                                parentInvoice = null;
                            }
                        }
                        if (closeParent && parentInvoice != null) {
                            parentInvoice.Invoice_Status__c = 'Closed';
                            parentInvoice.ccrz__Status__c = 'Closed';
                            parentInvoice.ccrz__RemainingAmount__c = 0;
                            parentInvoice.Paid_in_Full_Date__c = Date.today();
                            invoiceUpdateList.add(parentInvoice);
                        }
                    }
                }
                invoiceUpdateList.add(invoice);
            }
        }
        if (!invoiceUpdateList.isEmpty()) {
            try{
                update invoiceUpdateList;
            }catch(Exception ex){
                ACAMSUtil.reportException(null, null,'ACAMSTransPaymentTrigHandler beforeInsert Method', null, ex.getMessage(), null, null);
            }
        }
       //csa fix : commenting this line as teh method calling is done above
       // orderList = ACAMSOrderDAO.getInvoiceOrders(orderIds);   //FSA-409 
        
        List<ccrz__E_Order__c> ordersToUpdate = new List<ccrz__E_Order__c>();
       for (ccrz__E_Order__c order : orderList) {
            Boolean paid = true;
            for (ccrz__E_Invoice__c invoice : order.ccrz__CCInvoices__r) {
                if (invoice.Invoice_Status__c != 'Closed') {
                    paid = false;
                    break;
                }
                if(paid){
                    
                order.ccrz__OrderStatus__c = ACAMSUtil.COMPLETED;
                }
            }
            
                
            ordersToUpdate.add(order);
        }
        if (!ordersToUpdate.isEmpty()) {
            ACAMSUtil.bypassPhoneValidation = true;
            try {
               
    		update ordersToUpdate; 
           } catch(Exception e) {
               ACAMSUtil.reportException(null, null,'ACAMSTransPaymentTrigHandler beforeInsert', null, e.getMessage(), null, null);
            }
            ACAMSUtil.bypassPhoneValidation = false;
        }

        Map<String, ccrz__E_StoredPayment__c> storedPaymentMap = new Map<String, ccrz__E_StoredPayment__c>();
        for (ccrz__E_StoredPayment__c storedPayment : [
                SELECT Id, ccrz__Token__c
                FROM ccrz__E_StoredPayment__c
                WHERE ccrz__Token__c IN :tokens
        ]) {
            storedPaymentMap.put(storedPayment.ccrz__Token__c, storedPayment);
        }
        Map<Id, String> orderIdsToStoredPaymentMap = new Map<Id, String>();
        for (ccrz__E_TransactionPayment__c transactionPayment : newTransactionPayments) {
            if (transactionPayment.ccrz__StoredPayment__c == null &&
                    storedPaymentMap.containsKey(transactionPayment.ccrz__Token__c)) {
                transactionPayment.ccrz__StoredPayment__c = storedPaymentMap.get(transactionPayment.ccrz__Token__c).Id;
                orderIdsToStoredPaymentMap.put(
                        transactionPayment.ccrz__CCOrder__c, transactionPayment.ccrz__StoredPayment__c);
            }
        }
        List<ccrz__E_Subscription__c> subscriptionsToUpdate = new List<ccrz__E_Subscription__c>();
        for (ccrz__E_Subscription__c subscription : [
                SELECT ccrz__StoredPayment__c, ccrz__CCOrder__c
                FROM ccrz__E_Subscription__c
                WHERE ccrz__CCOrder__c IN :orderIdsToStoredPaymentMap.keySet()
        ]) {
            subscription.ccrz__StoredPayment__c = orderIdsToStoredPaymentMap.get(subscription.ccrz__CCOrder__c);
            subscriptionsToUpdate.add(subscription);
        }
        try{
            update subscriptionsToUpdate;
        }catch(Exception ex){
            ACAMSUtil.reportException(null, null,'ACAMSTransPaymentTrigHandler beforeInsert', null, ex.getMessage(), null, null);
        }
    }

    public override void afterInsert() {
        List<ccrz__E_TransactionPayment__c> authsToCapture = new List<ccrz__E_TransactionPayment__c>();
        List<ACAMSPaymentProcessing.CapturePayment> capturePayments = new List<ACAMSPaymentProcessing.CapturePayment>();

        for (ccrz__E_TransactionPayment__c tp : newTransactionPayments) {
            //FSA-1323 Removed tp.Web_Invoice_Payment__c for creating capture record
            if (tp.ccrz__TransactionType__c.containsIgnoreCase(ACAMSUtil.AUTHORIZATION)) {
                authsToCapture.add(tp);
            }
        }

        Set<Id> orderIds = new Set<Id>();
        for (ccrz__E_TransactionPayment__c tp : authsToCapture) {
            orderIds.add(tp.ccrz__CCOrder__c);
        }

        Map<Id, ccrz__E_Order__c> idToOrderMap = new Map<Id, ccrz__E_Order__c>(ACAMSOrderDAO.getOrders(orderIds));

        if (!authsToCapture.isEmpty()) {
            for (ccrz__E_TransactionPayment__c transactionPayment : authsToCapture) {
                Id transactionId = transactionPayment.Id;
                String orderNumber;
                String storeFront;
                String memberNumber;

                ccrz__E_Order__c order = idToOrderMap.get(transactionPayment.ccrz__CCOrder__c);
                if (transactionId != null) {
                    try {
                        if (orderNumber == null) {
                            orderNumber = order.ccrz__OrderNumber__c.toPlainString();
                        }
                        if (storeFront == null) {
                            storeFront = order.ccrz__Storefront__c;
                        }
                        if (memberNumber == null) {
                            memberNumber = order.ccrz__Account__r.Member_Number__c;
                        }
                    } catch (Exception e) {
                         }
                    if (!Test.isRunningTest()) {
                    		ACAMSPaymentProcessing.CapturePayment capturePayment = new ACAMSPaymentProcessing.CapturePayment(transactionId,
                            transactionPayment.ccrz__Amount__c, orderNumber, null, storeFront, memberNumber,
                            transactionPayment.ccrz__InvoiceAppliedFor__c);
                    		capturePayments.add(capturePayment);
                	}
            	}
        	}
        }

        Integer length = capturePayments.size();
        for (Integer y = 0; y < length - 1; y++) {
            capturePayments[y].setChainedJob(capturePayments[y + 1]);
        }

        if (capturePayments.size() > 0) {
            System.enqueueJob(capturePayments[0]);
        }
    }
    
    
   
}