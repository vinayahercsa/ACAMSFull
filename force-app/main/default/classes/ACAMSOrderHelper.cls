public with sharing class ACAMSOrderHelper {

    private static List<ccrz__E_OrderItem__c> orderItemsToCreate = new List<ccrz__E_OrderItem__c>();
    private static Map<Id, Id> oldOrderItemIdToNewOrderItemIdMap = new Map<Id, Id>();

    public static void cloneOrders(Set<Id> orderIds, List<ccrz__E_OrderItem__c> orderItemsToClone,
            Map<Id, ccrz__E_Order__c> idToOrderMap, Map<Id, List<ccrz__E_OrderItem__c>> idToOrderItemsMap, String status) {
        List<ccrz__E_Order__c> ordersToCreate = new List<ccrz__E_Order__c>();
        Map<Id, ccrz__E_Order__c> idToClonedOrderMap = new Map<Id, ccrz__E_Order__c>();
        Map<Id, ccrz__E_OrderItem__c> idToClonedOrderItemMap = new Map<Id, ccrz__E_OrderItem__c>();
        for (Id orderId : orderIds) {
            ccrz__E_Order__c returnOrder = idToOrderMap.get(orderId).clone(false, true, false, false);
            returnOrder.ccrz__OrderNumber__c = null;
            returnOrder.ccrz__Name__c = ACAMSUtil.REFUNDED_ORDER;
            returnOrder.ccrz__Order__c = orderId;
            returnOrder.ccrz__OrderDate__c = Date.today();
            returnOrder.Paid_in_Full_Date__c = Date.today();
            if(returnOrder.ccrz__TaxAmount__c == null){
                returnOrder.ccrz__TaxAmount__c = 0;
            }
            else if (status == ACAMSUtil.REFUNDED || status == ACAMSUtil.ORDER_STATUS_REFUNDED_CREDIT || status == ACAMSUtil.CANCELLED){ 
                returnOrder.ccrz__TaxAmount__c = -(returnOrder.ccrz__TaxAmount__c);
            } 
            else{
                returnOrder.ccrz__TaxAmount__c = 0;
            }
            returnOrder.ccrz__ShipAmount__c = 0;
            returnOrder.ccrz__OrderStatus__c = status;
            ordersToCreate.add(returnOrder);
        }
        insert ordersToCreate;

        for (ccrz__E_Order__c order : ordersToCreate) {
            idToClonedOrderMap.put(order.ccrz__Order__c, order);
            order.Refund_Finalized__c = true;
        }

        System.enqueueJob(new ACAMSUtil.UpdateObject(ordersToCreate));

        idToClonedOrderItemMap = cloneOrderItems(idToClonedOrderMap, orderItemsToClone, idToOrderItemsMap,
                idToClonedOrderItemMap, status);
        insert orderItemsToCreate;
        Map<Id, ccrz__E_OrderItem__c> productIdToOrderItemMap = new Map<Id, ccrz__E_OrderItem__c>();
        Set<Id> orderItemIdsToClone = new Set<Id>();
        for (ccrz__E_OrderItem__c orderItem : orderItemsToClone) {
            productIdToOrderItemMap.put(orderItem.ccrz__Product__c, orderItem);
            if (idToOrderItemsMap.containsKey(orderItem.Id)) {
                for (ccrz__E_OrderItem__c childOrderItem : idToOrderItemsMap.get(orderItem.Id)) {
                    productIdToOrderItemMap.put(childOrderItem.ccrz__Product__c, childOrderItem);
                }
            }
            orderItemIdsToClone.add(orderItem.Id);
        }
        for (ccrz__E_OrderItem__c orderItem : orderItemsToCreate) {
            if (productIdToOrderItemMap.containsKey(orderItem.ccrz__Product__c)) {
                idToClonedOrderItemMap.put(productIdToOrderItemMap.get(orderItem.ccrz__Product__c).Id, orderItem);
            }
        }

        Set<Id> clonedOrderIds = new Set<Id>();
        for (ccrz__E_Order__c order : ordersToCreate) {
            clonedOrderIds.add(order.Id);
        }
        List<ccrz__E_OrderItem__c> orderItemsList = ACAMSOrderDAO.getOrderItems(clonedOrderIds);
        List<ccrz__E_Order__c> ordersToUpdate = new List<ccrz__E_Order__c>();
        for (ccrz__E_OrderItem__c orderItem : orderItemsList) {
            orderItem.ccrz__Order__r.ccrz__TaxAmount__c += orderItem.Total_Item_Taxes__c != null ? orderItem.Total_Item_Taxes__c : 0;
            if (orderItem.ccrz__SubAmount__c == 0) {
                orderItem.ccrz__Order__r.ccrz__ShipAmount__c += orderItem.ccrz__Price__c;
            }
            if (status == ACAMSUtil.REFUNDED) {
                orderItem.ccrz__Order__r.ccrz__OrderStatus__c = ACAMSUtil.REFUNDED;
            } else if (status == ACAMSUtil.ORDER_STATUS_REFUNDED_CREDIT) {
                orderItem.ccrz__Order__r.ccrz__OrderStatus__c = ACAMSUtil.ORDER_STATUS_REFUNDED_CREDIT;
            }
            orderItem.ccrz__Order__r.ccrz__OrderNumber__c = Long.valueOf(orderItem.ccrz__Order__r.Name.substring(2)) + Long.valueOf(ACAMSUtil.ORDER_NUMBER_START);
            ordersToUpdate.add(orderItem.ccrz__Order__r);
        }
        Set<ccrz__E_Order__c> ordersToUpdateSet = new Set<ccrz__E_Order__c>();
        ordersToUpdateSet.addAll(ordersToUpdate);
        ordersToUpdate.clear();
        ordersToUpdate.addAll(ordersToUpdateSet);
        update ordersToUpdate;

        List<ccrz__E_TransactionPayment__c> transactionPayments = ACAMSOrderDAO.getTransactionPayments(orderIds);
        Map<Id, List<ccrz__E_TransactionPayment__c>> orderIdToTransactionPaymentsMap = new Map<Id, List<ccrz__E_TransactionPayment__c>>();
        for (ccrz__E_TransactionPayment__c tp : transactionPayments) {
            if (orderIdToTransactionPaymentsMap.containsKey(tp.ccrz__CCOrder__c)) {
                List<ccrz__E_TransactionPayment__c> transactionPaymentsList = orderIdToTransactionPaymentsMap.get(tp.ccrz__CCOrder__c);
                transactionPaymentsList.add(tp);
                orderIdToTransactionPaymentsMap.put(tp.ccrz__CCOrder__c, transactionPaymentsList);
            } else {
                List<ccrz__E_TransactionPayment__c> transactionPaymentsList = new List<ccrz__E_TransactionPayment__c>{
                        tp
                };
                orderIdToTransactionPaymentsMap.put(tp.ccrz__CCOrder__c, transactionPaymentsList);
            }
        }
        List<ccrz__E_TransactionPayment__c> transactionsToRefund = new List<ccrz__E_TransactionPayment__c>();
        List<ccrz__E_Order__c> clonedOrdersList = ACAMSOrderDAO.getOrders(clonedOrderIds);
        Boolean fullRefund = false;
        Map<Id, Decimal> clonedOrderIdsToCreditTotals = new Map<Id, Decimal>();
        for (ccrz__E_Order__c order : clonedOrdersList) {
            if (orderIdToTransactionPaymentsMap.containsKey(order.ccrz__Order__c)) {
                for (ccrz__E_TransactionPayment__c tp : orderIdToTransactionPaymentsMap.get(order.ccrz__Order__c)) {
                    if ('sopcc'.equalsIgnoreCase(tp.ccrz__AccountType__c) &&
                            ACAMSUtil.CAPTURE.equalsIgnoreCase(tp.ccrz__TransactionType__c)) {
                        if (ACAMSUtil.REFUNDED.equalsIgnoreCase(order.ccrz__Order__r.ccrz__OrderStatus__c)) {
                            transactionsToRefund.add(tp);
                            fullRefund = true;
                        } else {
                            if (transactionsToRefund.isEmpty()) {
                                transactionsToRefund.add(tp);
                                Decimal creditTotal = 0;

                                for (ccrz__E_OrderItem__c orderItem : orderItemsList) {
                                    Decimal taxAmount = orderItem.Total_Item_Taxes__c != null ?
                                            orderItem.Total_Item_Taxes__c : 0;
                                    Decimal customerTotal = orderItem.ccrz__Product__r.ccrz__SKU__c == 'SHPCST' ?
                                            orderItem.ccrz__Price__c + taxAmount :
                                            orderItem.ccrz__SubAmount__c + taxAmount;
                                    if (clonedOrderIdsToCreditTotals.containsKey(orderItem.ccrz__Order__c)) {
                                        creditTotal = clonedOrderIdsToCreditTotals.get(orderItem.ccrz__Order__c);
                                        creditTotal += customerTotal;
                                        clonedOrderIdsToCreditTotals.put(orderItem.ccrz__Order__c, creditTotal);
                                    } else {
                                        creditTotal += customerTotal;
                                    }
                                }
                                clonedOrderIdsToCreditTotals.put(tp.ccrz__CCOrder__c, creditTotal);
                            }
                        }
                    }
                }
            }
        }
        if (status != ACAMSUtil.ORDER_STATUS_REFUNDED_CREDIT) {
            Set<Id> transactionIds = new Set<Id>();
            List<ccrz__E_TransactionPayment__c> transactionsToClone = new List<ccrz__E_TransactionPayment__c>();
            Set<Id> orderIdsWithTransactions = new Set<Id>();
            Map<Id, Decimal> transactionIdsToCreditTotals = new Map<Id, Decimal>();
            for (ccrz__E_TransactionPayment__c tp : transactionsToRefund) {
                transactionIds.add(tp.Id);
                ccrz__E_TransactionPayment__c clonedTp = tp.clone(false, true, false, false);
                if (idToClonedOrderMap.containsKey(tp.ccrz__CCOrder__c)) {
                    clonedTp.ccrz__TransactionPaymentId__c = null;
                    clonedTp.ccrz__TransactionType__c = ACAMSUtil.CREDIT;
                    clonedTp.ccrz__TransactionTS__c = Datetime.now();
                    clonedTp.ccrz__CCOrder__c = idToClonedOrderMap.get(tp.ccrz__CCOrder__c).Id;
                    if (fullRefund) {
                        if (!orderIdsWithTransactions.contains(tp.ccrz__CCOrder__c)) {
                            clonedTp.ccrz__Amount__c = -(tp.ccrz__CCOrder__r.ccrz__TotalAmount__c);
                            clonedTp.ccrz__RequestAmount__c = -(tp.ccrz__CCOrder__r.ccrz__TotalAmount__c);
                            transactionsToClone.add(clonedTp);
                            orderIdsWithTransactions.add(tp.ccrz__CCOrder__c);
                        }
                    } else {
                        if (!orderIdsWithTransactions.contains(tp.ccrz__CCOrder__c) &&
                                clonedOrderIdsToCreditTotals.containsKey(tp.ccrz__CCOrder__c)) {
                            Decimal creditTotal = clonedOrderIdsToCreditTotals.get(tp.ccrz__CCOrder__c);
                            clonedTp.ccrz__Amount__c = -(creditTotal);
                            clonedTp.ccrz__RequestAmount__c = -(creditTotal);
                            transactionsToClone.add(clonedTp);
                            transactionIdsToCreditTotals.put(tp.Id, -(creditTotal));
                        }
                    }
                }
            }
            insert transactionsToClone;

            if (!fullRefund) {
                ACAMSPaymentProcessing.refundTransactionsFuture(transactionIds, transactionIdsToCreditTotals);
            }
        }
        cloneInvoices(idToClonedOrderMap, orderItemsToClone, status); //FSA-904
    }

    private static void cloneInvoices(Map<Id, ccrz__E_Order__c> idToClonedOrderMap, List<ccrz__E_OrderItem__c> orderItems, String orderStatus) { //FSA-904
        Map<Id, ccrz__E_Order__c> invoiceIdToOrderMap = new Map<Id, ccrz__E_Order__c>();
        Map<Id, ccrz__E_Invoice__c> oldIdToClonedInvoices = new Map<Id, ccrz__E_Invoice__c>();
        Map<Id, Id> parentOrderIdToClonedOrderId = new Map<Id, Id>();
        Map<Id,ccrz__E_Invoice__c> oldIdToOldInvoices = new Map<Id,ccrz__E_Invoice__c>();//FSA-358
        system.debug('idToClonedOrderMap.values()::'+idToClonedOrderMap.values());
        for (ccrz__E_Order__c order : idToClonedOrderMap.values()) {
            parentOrderIdToClonedOrderId.put(order.ccrz__Order__c, order.Id);
        }
        for (ccrz__E_Order__c order : ACAMSOrderDAO.getOrders(idToClonedOrderMap.keySet())) {
            for (ccrz__E_Invoice__c invoice : order.ccrz__CCInvoices__r) {
                invoiceIdToOrderMap.put(invoice.Id, order);
            }
        }
    system.debug('invoiceIdToOrderMap::'+invoiceIdToOrderMap);
        Set<Id> refundedInvoiceItemIds = new Set<Id>();
        system.debug('orderItems::'+orderItems);
        for (ccrz__E_OrderItem__c orderItem : orderItems) {
            refundedInvoiceItemIds.add(orderItem.Id);
        }

        List<ccrz__E_Invoice__c> invoicesToClone = ACAMSInvoiceDAO.getInvoices(invoiceIdToOrderMap.keySet());
        system.debug('invoicesToClone::'+invoicesToClone);
    //FSA-358       
        for(ccrz__E_Invoice__c invoice:invoicesToClone){
           oldIdToOldInvoices.put(invoice.Id, invoice);
        }

        List<ccrz__E_InvoiceItem__c> invoiceItemsToClone = ACAMSInvoiceDAO.getInvoiceItemsWithOrderItemIds(invoiceIdToOrderMap.keySet(), refundedInvoiceItemIds);
        system.debug('invoiceItemsToClone::'+invoiceItemsToClone);
        Map<Id, List<ccrz__E_InvoiceItem__c>> idToInvoiceItemMap = new Map<Id, List<ccrz__E_InvoiceItem__c>>();
        for (ccrz__E_InvoiceItem__c invoiceItem : invoiceItemsToClone) {
            if (idToInvoiceItemMap.containsKey(invoiceItem.ccrz__Invoice__c)) {
                idToInvoiceItemMap.get(invoiceItem.ccrz__Invoice__c).add(invoiceItem);
            } else {
                idToInvoiceItemMap.put(invoiceItem.ccrz__Invoice__c, new List<ccrz__E_InvoiceItem__c>{
                        invoiceItem
                });
            }
        }
        for (ccrz__E_Invoice__c invoice : invoicesToClone) {
            ccrz__E_Invoice__c clonedInvoice = invoice.clone(false, true, false, false);
            clonedInvoice.ccrz__RemainingAmount__c = 0;
            clonedInvoice.ccrz__CCOrder__c = parentOrderIdToClonedOrderId.get(invoiceIdToOrderMap.get(invoice.Id).Id);
            clonedInvoice.Finalized__c = false;
            clonedInvoice.Sent_to_Vertex__c = false;
            Decimal originalAmount = 0;
            system.debug('idToInvoiceItemMap::'+idToInvoiceItemMap);
            for (ccrz__E_InvoiceItem__c invoiceItem : idToInvoiceItemMap.get(invoice.Id)) {
                originalAmount = originalAmount + invoiceItem.ccrz__OriginalAmount__c;
            }
            clonedInvoice.ccrz__OriginalAmount__c = -(originalAmount);
            oldIdToClonedInvoices.put(invoice.Id, clonedInvoice);
        }

        insert oldIdToClonedInvoices.values();

        List<ccrz__E_InvoiceItem__c> invoiceItemsToInsert = new List<ccrz__E_InvoiceItem__c>();
        for (Id invoiceId : oldIdToClonedInvoices.keySet()) {
            List<ccrz__E_InvoiceItem__c> invoiceItems = idToInvoiceItemMap.get(invoiceId);
            for (ccrz__E_InvoiceItem__c invoiceItem : invoiceItems) {
                ccrz__E_InvoiceItem__c clonedInvoiceItem = invoiceItem.clone(false, true, false, false);
                clonedInvoiceItem.ccrz__Invoice__c = oldIdToClonedInvoices.get(invoiceId).Id;
                clonedInvoiceItem.ccrz__OriginalAmount__c = -(invoiceItem.ccrz__OriginalAmount__c);
                clonedInvoiceItem.ccrz__CCOrder__c = parentOrderIdToClonedOrderId.get(invoiceIdToOrderMap.get(invoiceId).Id);
                clonedInvoiceItem.ccrz__CCOrderItem__c = oldOrderItemIdToNewOrderItemIdMap.get(invoiceItem.ccrz__CCOrderItem__c);
                invoiceItemsToInsert.add(clonedInvoiceItem);
            }
        }

        insert invoiceItemsToInsert;
        //FSA-358
        for(ID parentInvoiceID : oldIdToClonedInvoices.keyset()){
          ccrz__E_Invoice__c clonedInvoice = oldIdToClonedInvoices.get(parentInvoiceID);
          system.debug('orderStatus::'+orderStatus);
          //system.debug('clonedInvoice.Invoice_Status__c::'+clonedInvoice.Invoice_Status__c);
          if(oldIdToOldInvoices.get(parentInvoiceID).Invoice_Status__c == 'Cancelled') {
            clonedInvoice.Invoice_Status__c = oldIdToOldInvoices.get(parentInvoiceID).Invoice_Status__c; 
            clonedInvoice.Refund_Date__c = Date.today();//FSA-904
          } else {
            clonedInvoice.Invoice_Status__c = 'Closed';
          }
          if(oldIdToOldInvoices.get(parentInvoiceID).Finalized__c){
              clonedInvoice.Finalized__c = true;
          }
        }
/*        for (ccrz__E_Invoice__c clonedInvoice : oldIdToClonedInvoices.values()) {
            clonedInvoice.Invoice_Status__c = 'Closed';
            clonedInvoice.Finalized__c = true;
        }
*/
        System.enqueueJob(new ACAMSUtil.UpdateObject(oldIdToClonedInvoices.values()));
    }


    // FSA-61
    private static Map<Id, ccrz__E_OrderItem__c> cloneOrderItems(Map<Id, ccrz__E_Order__c> idToClonedOrderMap,
            List<ccrz__E_OrderItem__c> orderItems, Map<Id, List<ccrz__E_OrderItem__c>> idToOrderItemsMap,
            Map<Id, ccrz__E_OrderItem__c> idToClonedOrderItemMap, String status) {
            // FSA-61
            Map<Id, ccrz__E_OrderItem__c> orderItemReturnItemMap = new Map<Id, ccrz__E_OrderItem__c>();

        for (ccrz__E_OrderItem__c orderItem : orderItems) {
            ccrz__E_OrderItem__c returnOrderItem = orderItem.clone(false, true, false, false);
            returnOrderItem.ccrz__Order__c = idToClonedOrderMap.get(orderItem.ccrz__Order__c) != null ? idToClonedOrderMap.get(orderItem.ccrz__Order__c).Id : null;
            returnOrderItem.Original_Order_Item__c = orderItem.Id;
            returnOrderItem.ccrz__SubAmount__c = -(returnOrderItem.ccrz__SubAmount__c);
            returnOrderItem.Total_Item_Taxes__c = returnOrderItem.Total_Item_Taxes__c != null ? -(returnOrderItem.Total_Item_Taxes__c) : 0;
            returnOrderItem.ccrz__Quantity__c = -(returnOrderItem.ccrz__Quantity__c); //FSA-5181
            if (returnOrderItem.ccrz__OriginalItemPrice__c != null) {
                returnOrderItem.ccrz__OriginalItemPrice__c = -(returnOrderItem.ccrz__OriginalItemPrice__c);
            }
            // FSA-61
            orderItemReturnItemMap.put(orderItem.Id, returnOrderItem);
        }
        // FSA-61
        if(orderItemReturnItemMap.size() > 0){
            insert orderItemReturnItemMap.values();
        }

        for (ccrz__E_OrderItem__c orderItem : orderItems) {
            idToClonedOrderItemMap.put(orderItem.Id, orderItemReturnItemMap.get(orderItem.Id));
            oldOrderItemIdToNewOrderItemIdMap.put(orderItem.Id, orderItemReturnItemMap.get(orderItem.Id).Id);
            if (idToOrderItemsMap.containsKey(orderItem.Id)) {
                for (ccrz__E_OrderItem__c childOrderItem : idToOrderItemsMap.get(orderItem.Id)) {
                    ccrz__E_OrderItem__c returnChildOrderItem = childOrderItem.clone(false, true, false, false);
                    returnChildOrderItem.ccrz__Order__c = idToClonedOrderMap.get(childOrderItem.ccrz__Order__c) != null ? idToClonedOrderMap.get(childOrderItem.ccrz__Order__c).Id : null;
                    returnChildOrderItem.ccrz__ParentOrderItem__c = orderItemReturnItemMap.get(orderItem.Id).Id;
                    returnChildOrderItem.Original_Order_Item__c = childOrderItem.Id;
                    returnChildOrderItem.ccrz__AdjustmentAmount__c = -(returnChildOrderItem.ccrz__AdjustmentAmount__c);
                    returnChildOrderItem.ccrz__SubAmount__c = -(returnChildOrderItem.ccrz__SubAmount__c);
                    returnChildOrderItem.ccrz__OriginalItemPrice__c = -(returnChildOrderItem.ccrz__OriginalItemPrice__c);
                    returnChildOrderItem.ccrz__Quantity__c = -(returnChildOrderItem.ccrz__Quantity__c); //FSA-5181
                    orderItemsToCreate.add(returnChildOrderItem);
                }
            }
        }
        return idToClonedOrderItemMap;
    }

}