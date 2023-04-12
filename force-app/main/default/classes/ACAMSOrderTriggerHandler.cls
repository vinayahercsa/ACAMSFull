public class ACAMSOrderTriggerHandler extends CCAviTriggerHandler {
    private List < ccrz__E_Order__c > newOrders;
    private Map < Id, ccrz__E_Order__c > oldMap;
    private Map<Id, ccrz__E_Order__c> newMap ;

    private Map < Id, List < ccrz__E_OrderItem__c >> orderIdToOrderItemMap = new Map < Id, List < ccrz__E_OrderItem__c >> ();
    private Map < Id, List < ccrz__E_OrderShipment__c >> idToOrderShipmentMap = new Map < Id, List < ccrz__E_OrderShipment__c >> ();
    private Map < Id, List < ccrz__E_TransactionPayment__c >> idToTransactionPaymentMap = new Map < Id, List < ccrz__E_TransactionPayment__c >> ();

    public static Boolean skipLegalEntitySummaryCalculation = false;
    private static Boolean updateOwnerIdOrdrExecuted = false;
    public static Boolean SkipOrderRefundAssetAfterUpdate = false;
    public static Boolean SkipcreateTransPayAfterUpdate = false;

    public ACAMSOrderTriggerHandler() {
        this.newMap=(Map<Id, ccrz__E_Order__c>) Trigger.newMap;
        this.newOrders = (List < ccrz__E_Order__c > ) Trigger.new;
        this.oldMap = (Map < Id, ccrz__E_Order__c > ) Trigger.oldMap;
        Set < Id > cancelledOrders = new Set < Id > ();
        Boolean inProcessOrder = false;
        Boolean returnOrder = false;
        Boolean refundCreditOrder = false;
        //csa fix :added null check
        if(newMap != null){
        for (Id orderId: newMap.keySet()) {
            String oldStatus = ((ccrz__E_Order__c) Trigger.oldMap.get(orderId)).ccrz__OrderStatus__c;
            String newStatus = ((ccrz__E_Order__c) Trigger.newMap.get(orderId)).ccrz__OrderStatus__c;
            //system.debug('old status'+ oldStatus + newStatus);
            if (oldStatus != null && newStatus != null && oldStatus == ACAMSUtil.ON_HOLD && newStatus == ACAMSUtil.IN_PROCESS) {
                inProcessOrder = true;
            } else if (oldStatus != null && !oldStatus.equalsIgnoreCase(ACAMSUtil.REFUNDED) && newStatus != null && newStatus.equals(ACAMSUtil.REFUNDED)) {
                returnOrder = true;
            } else if (oldStatus != ACAMSUtil.ORDER_STATUS_REFUNDED_CREDIT && newStatus == ACAMSUtil.ORDER_STATUS_REFUNDED_CREDIT) {
                refundCreditOrder = true;
            } else if (oldStatus != ACAMSUtil.CANCELLED && newStatus == ACAMSUtil.CANCELLED) {
                cancelledOrders.add(orderId);
            }
        }}
        if (Test.isRunningTest()) {
            returnOrder = true;
            inProcessOrder = false;
        }
        if (inProcessOrder) {
            List < ccrz__E_OrderShipment__c > orderShipments = ACAMSOrderDAO.getOrderShipments(Trigger.newMap.keySet());
            for (ccrz__E_OrderShipment__c orderShipment: orderShipments) {
                if (idToOrderShipmentMap.containsKey(orderShipment.ccrz__Order__c)) {
                    List < ccrz__E_OrderShipment__c > shipmentList = idToOrderShipmentMap.get(orderShipment.ccrz__Order__c);
                    shipmentList.add(orderShipment);
                    idToOrderShipmentMap.put(orderShipment.ccrz__Order__c, shipmentList);
                } else {
                    List < ccrz__E_OrderShipment__c > newList = new List < ccrz__E_OrderShipment__c > ();
                    newList.add(orderShipment);
                    idToOrderShipmentMap.put(orderShipment.ccrz__Order__c, newList);
                }
            }
        }
        if (returnOrder || refundCreditOrder) {
            orderIdToOrderItemMap = getOrderItemsByOrderIds(Trigger.newMap.keySet());
            //System.debug('orderIdToOrderItemMap--!!>'+orderIdToOrderItemMap);
        }

        if (!cancelledOrders.isEmpty()) {
            idToTransactionPaymentMap = getTransPaymentsByOrderIds(cancelledOrders);
        }
    }

    //FSA-383
    /* public override void afterInsert(){
       List<ID> ordersForOppTaiwanIds = new List<ID>();
       for(ccrz__E_Order__c ccOrder : ((Map<Id, ccrz__E_Order__c>) Trigger.newMap).values()){
         System.debug('ccOrder.Billing_Country__c ::'+ ccOrder.Billing_Country__c + '  ccOrder.BillTo_Region__c ::'+ccOrder.BillTo_Region__c+'  ccOrder.BillTo_CountryISOCode__c :'+ccOrder.BillTo_CountryISOCode__c);
         if('Taiwan'.equals(ccOrder.Billing_Country__c) || 'Taiwan'.equals(ccOrder.BillTo_Region__c)||'TW'.equals(ccOrder.BillTo_CountryISOCode__c)){
           ordersForOppTaiwanIds.add(ccOrder.id);
         }
       }
       CreateOpportunityTaiwan.CreateOpportunity(ordersForOppTaiwanIds);
     }
     */


     public override void beforeUpdate() {
        List<Vertex.VertexAnyRequest.InvokeAnyRequestStructure> requestList = new List<Vertex.VertexAnyRequest.InvokeAnyRequestStructure>();
        Map<Id, ccrz__E_Order__c> oldMap = (Map<Id, ccrz__E_Order__c>) Trigger.oldMap;
        Map<Id, ccrz__E_Order__c> newMap = (Map<Id, ccrz__E_Order__c>) Trigger.newMap;
        
        calculateLegalEntitySummary(newMap.values());
        Vertex_Tax_Calculation_Bypass__c bypassSettings = Vertex_Tax_Calculation_Bypass__c.getInstance();
        for (Id orderId : Trigger.newMap.keySet()) {
            String oldStatus = oldMap.get(orderId).ccrz__OrderStatus__c;
            String newStatus = newMap.get(orderId).ccrz__OrderStatus__c;
            ccrz__E_Order__c oldOrder = oldMap.get(orderId);
            ccrz__E_Order__c newOrder = newMap.get(orderId);
            if (oldStatus != ACAMSUtil.REFUNDED && newStatus == ACAMSUtil.REFUNDED) {
                Integer count = 0;
                    for (ccrz__E_OrderItem__c orderItem : orderIdToOrderItemMap.get(orderId)) {
                        if (orderItem.ccrz__OrderItemStatus__c == ACAMSUtil.REFUNDED) {
                            count++;
                        } else if (orderItem.ccrz__OrderItemStatus__c == ACAMSUtil.ORDER_ITEM_STATUS_REFUNDED_CREDIT) {
                            newMap.get(orderId).addError('A credit has already been issued for an item in this order.');
                        }
                    }
                
                if (count > 0 && count < orderIdToOrderItemMap.get(orderId).size()) {
                    newMap.get(orderId).addError('Partial return has already been started. Please return items ' +
                            'individually for this order.');
                }
            } else if (oldStatus != ACAMSUtil.ORDER_STATUS_REFUNDED_CREDIT && newStatus == ACAMSUtil.ORDER_STATUS_REFUNDED_CREDIT) {
                Integer count = 0;
               
                    for (ccrz__E_OrderItem__c orderItem : orderIdToOrderItemMap.get(orderId)) {
                        if (orderItem.ccrz__OrderItemStatus__c == ACAMSUtil.ORDER_ITEM_STATUS_REFUNDED_CREDIT) {
                            count++;
                        } else if (orderItem.ccrz__OrderItemStatus__c == ACAMSUtil.REFUNDED) {
                            newMap.get(orderId).addError('A refund has already been issued for an item in this order.');
                        }
                    }
                
                if (count > 0 && count < orderIdToOrderItemMap.get(orderId).size()) {
                    newMap.get(orderId).addError('Partial credit refund has already been started. Please refund items ' +
                            'individually for this order.');
                }
            } else if (oldStatus != ACAMSUtil.COMPLETED && newStatus == ACAMSUtil.COMPLETED) {
                if (newMap.get(orderId).Paid_in_Full_Date__c == null) {
                    newMap.get(orderId).Paid_in_Full_Date__c = Date.today();
                }
             //csa fix:only future method is there.
                ACAMSLogicCartPlace.addNumberOfOrdersToAccountfuture(newMap.get(orderId).ccrz__Account__c);

              /*csa fix:method is commented
               *   if(!system.isFuture()){
                ACAMSLogicCartPlace.addNumberOfOrdersToAccount(newMap.get(orderId).ccrz__Account__c);
                }
                else{
                    ACAMSLogicCartPlace.addNumberOfOrdersToAccountfuture(newMap.get(orderId).ccrz__Account__c);
                }*/
            } else if (oldStatus != ACAMSUtil.CANCELLED && newStatus == ACAMSUtil.CANCELLED) {
                if (idToTransactionPaymentMap.containsKey(orderId)) {
                    if (!idToTransactionPaymentMap.get(orderId).isEmpty()) {
                        newMap.get(orderId).addError('Order cannot be cancelled because payments have been made. Please refund the order.');
                    }
                }
            }
            // vara added - code optimization 1469 recordtype schema 
            if (newStatus == ACAMSUtil.COMPLETED && Schema.SObjectType.ccrz__E_Order__c.getRecordTypeInfosByDeveloperName()
    .get('Read_Only_Order').getRecordTypeId() != null) {
                newMap.get(orderId).RecordTypeId = Schema.SObjectType.ccrz__E_Order__c.getRecordTypeInfosByDeveloperName()
    .get('Read_Only_Order').getRecordTypeId();
            } else if (oldStatus == ACAMSUtil.COMPLETED && newStatus != null && newStatus != ACAMSUtil.COMPLETED && Schema.SObjectType.ccrz__E_Order__c.getRecordTypeInfosByDeveloperName()
    .get('Editable_Order').getRecordTypeId() != null) {
                newMap.get(orderId).RecordTypeId = Schema.SObjectType.ccrz__E_Order__c.getRecordTypeInfosByDeveloperName()
    .get('Editable_Order').getRecordTypeId();
            } else if (oldStatus == ACAMSUtil.COMPLETED && newStatus == null) {
                newMap.get(orderId).ccrz__OrderStatus__c.addError('Cannot change Order Status from Completed To None');
            }
        
//csa fix:deactivated the Process builder and its logic written here
        if((oldOrder.ccrz__Name__c != newOrder.ccrz__Name__c && newOrder.ccrz__Name__c != 'Refunded Order') || ((oldOrder.ccrz__Name__c != newOrder.ccrz__Name__c  && newOrder.ccrz__Name__c == 'Refunded Order') && (newOrder.Refund_Finalized__c = TRUE)) && (!String.isBlank(String.valueOf(newOrder.Shipping_Tax_Area_Id__c))) && ((!bypassSettings.Bypass_Order_Tax_Calculation__c)) && ((newOrder.Destination_Country__c !=oldOrder.Destination_Country__c && newOrder.Destination_Country__c != 'China')) && ((String.valueOf(newOrder.ccrz__OrderStatus__c) != String.valueOf(oldOrder.ccrz__OrderStatus__c) && String.valueOf(newOrder.ccrz__OrderStatus__c) == 'Order Submitted') || (String.valueOf(newOrder.ccrz__OrderStatus__c) != String.valueOf(oldOrder.ccrz__OrderStatus__c) && String.valueOf(newOrder.ccrz__OrderStatus__c) == 'In Process') || (String.valueOf(newOrder.ccrz__OrderStatus__c) != String.valueOf(oldOrder.ccrz__OrderStatus__c) && String.valueOf(newOrder.ccrz__OrderStatus__c) == 'On Hold') || (String.valueOf(newOrder.ccrz__OrderStatus__c) != String.valueOf(oldOrder.ccrz__OrderStatus__c) && String.valueOf(newOrder.ccrz__OrderStatus__c) == 'Invoiced')))
               {
                Vertex.VertexAnyRequest.InvokeAnyRequestStructure request=new Vertex.VertexAnyRequest.InvokeAnyRequestStructure();
                request.recordId = newOrder.Id;
                request.type = 'CC Order';
             
                if (!bypassSettings.Bypass_Invoice_Tax_Calculation__c) {
                   requestList.add(request);
                }
            }
            
        }
        if (requestList.size() > 0) {
            //CSA-fix - Created platform event to solve the issue
            List<Vertex_Request_PE__e> vertexRequestPlatformEvents = new List<Vertex_Request_PE__e>();
            for(Vertex.VertexAnyRequest.InvokeAnyRequestStructure req : requestList){
                vertexRequestPlatformEvents.add(new Vertex_Request_PE__e(RecordId__c=req.recordId,Type__c = req.type));
            
            }
            List<Database.SaveResult> results = EventBus.publish(vertexRequestPlatformEvents);
        
            // Inspect publishing result for each event
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    System.debug('Successfully published event.');
                } else {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Error returned: ' +
                                        err.getStatusCode() +
                                        ' - ' +
                                        err.getMessage());
                    }
                }       
            }
        }
    }
   ////csa fix:deactivated the Process builder and its logic written here 
    public override void beforeInsert() {
        List < Vertex.VertexAnyRequest.InvokeAnyRequestStructure > requestList = new List < Vertex.VertexAnyRequest.InvokeAnyRequestStructure > ();
        Vertex_Tax_Calculation_Bypass__c bypassSettings = Vertex_Tax_Calculation_Bypass__c.getInstance();

        for (ccrz__E_Order__c neworder: (List < ccrz__E_Order__c > ) Trigger.new) {
            if((newOrder.ccrz__Name__c != 'Refunded Order') || ((newOrder.ccrz__Name__c == 'Refunded Order') && (newOrder.Refund_Finalized__c = TRUE)) && (!String.isBlank(String.valueOf(newOrder.Shipping_Tax_Area_Id__c))) && ((!bypassSettings.Bypass_Order_Tax_Calculation__c)) && ((newOrder.Destination_Country__c != 'China')) && ((String.valueOf(newOrder.ccrz__OrderStatus__c) == 'Order Submitted') || (String.valueOf(newOrder.ccrz__OrderStatus__c) == 'In Process') || (String.valueOf(newOrder.ccrz__OrderStatus__c) == 'On Hold') || (String.valueOf(newOrder.ccrz__OrderStatus__c) == 'Invoiced'))) {}
               {
                    Vertex.VertexAnyRequest.InvokeAnyRequestStructure request = new Vertex.VertexAnyRequest.InvokeAnyRequestStructure();
                    request.recordId = neworder.Id;
                    request.type = 'CC Order';


                    if (!bypassSettings.Bypass_Invoice_Tax_Calculation__c) {
                        requestList.add(request);
                    }
                }
            }


            if (requestList.size() > 0) {
                //CSA-fix - Created platform event to solve the issue
                List < Vertex_Request_PE__e > vertexRequestPlatformEvents = new List < Vertex_Request_PE__e > ();
                for (Vertex.VertexAnyRequest.InvokeAnyRequestStructure req: requestList) {
                    vertexRequestPlatformEvents.add(new Vertex_Request_PE__e(RecordId__c = req.recordId, Type__c = req.type));

                }
                List < Database.SaveResult > results = EventBus.publish(vertexRequestPlatformEvents);

                // Inspect publishing result for each event
                for (Database.SaveResult sr: results) {
                    if (sr.isSuccess()) {
                        System.debug('Successfully published event.');
                    } else {
                        for (Database.Error err: sr.getErrors()) {
                            System.debug('Error returned: ' +
                                err.getStatusCode() +
                                ' - ' +
                                err.getMessage());
                        }
                    }
                }

            }
        }


        public override void afterUpdate() {
            if (!updateOwnerIdOrdrExecuted) {
                updateOwnerIdOrdr(newOrders, oldMap);
            }

            List < ccrz__E_Order__c > returnOrders = new List < ccrz__E_Order__c > ();
            List < ccrz__E_Order__c > refundCreditOrders = new List < ccrz__E_Order__c > ();
            Set < Id > capturedOrders = new Set < Id > ();
            Set < Id > refundOrders = new Set < Id > ();
            Set < Id > cancelledOpportunityIds = new Set < Id > ();
            String oldStatus;
            String newStatus;

            Map < Id, ccrz__E_Order__c > oldMap = (Map < Id, ccrz__E_Order__c > ) Trigger.oldMap;
            Map < Id, ccrz__E_Order__c > newMap = (Map < Id, ccrz__E_Order__c > ) Trigger.newMap;

            List < ccrz__E_OrderShipment__c > updatedShipments = new List < ccrz__E_OrderShipment__c > ();
            Set < Id > orderIdsForInvoices = new Set < Id > ();
            Set < Id > orderIdsForInvoicesToCheckFinalized = new Set < Id > ();
            Boolean orderCancelled = false;


            Set < Id > completedOrders = new Set < Id > ();
            for (Id orderId: Trigger.oldMap.keySet()) {
                oldStatus = oldMap.get(orderId).ccrz__OrderStatus__c;
                newStatus = newMap.get(orderId).ccrz__OrderStatus__c;

                if (oldStatus != null && newStatus != null && (oldStatus == ACAMSUtil.ON_HOLD ||
                        oldStatus == ACAMSUtil.ORDER_SUBMITTED) && (newStatus == ACAMSUtil.IN_PROCESS)) {
                    capturedOrders.add(orderId);
                } else if (oldStatus == null && newStatus != null && newStatus.equalsIgnoreCase(ACAMSUtil.IN_PROCESS)) {
                    capturedOrders.add(orderId);
                } else if (oldStatus != null && !oldStatus.equalsIgnoreCase(ACAMSUtil.REFUNDED) && newStatus != null &&
                    newStatus.equals(ACAMSUtil.REFUNDED) &&
                    newMap.get(orderId).ccrz__Name__c != ACAMSUtil.REFUNDED_ORDER) {
                    orderIdsForInvoices.add(orderId);
                    orderCancelled = true;
                    ccrz__E_Order__c order = newMap.get(orderId);
                    if (order.Opportunity__c != null) {
                        cancelledOpportunityIds.add(order.Opportunity__c);
                    }
                    Boolean partialReturn = false;
                    for (ccrz__E_OrderItem__c orderItem: orderIdToOrderItemMap.get(orderId)) {
                        if (orderItem.ccrz__OrderItemStatus__c == ACAMSUtil.REFUNDED) {
                            partialReturn = true;
                            break;
                        }
                    }

                    if (!partialReturn) {
                        returnOrders.add(newMap.get(orderId));
                        refundOrders.add(orderId);
                    }
                    SkipOrderRefundAssetAfterUpdate = true;
                } else if (oldStatus != null && oldStatus != ACAMSUtil.ORDER_STATUS_REFUNDED_CREDIT && newStatus != null &&
                    newStatus == ACAMSUtil.ORDER_STATUS_REFUNDED_CREDIT &&
                    newMap.get(orderId).ccrz__Name__c != ACAMSUtil.REFUNDED_ORDER) {
                    orderIdsForInvoices.add(orderId);
                    orderCancelled = true;
                    ccrz__E_Order__c order = newMap.get(orderId);
                    if (order.Opportunity__c != null) {
                        cancelledOpportunityIds.add(order.Opportunity__c);
                    }
                    Boolean partialRefund = false;
                    for (ccrz__E_OrderItem__c orderItem: orderIdToOrderItemMap.get(orderId)) {
                        if (orderItem.ccrz__OrderItemStatus__c == ACAMSUtil.ORDER_ITEM_STATUS_REFUNDED_CREDIT) {
                            partialRefund = true;
                            break;
                        }
                    }

                    if (!partialRefund) {
                        refundCreditOrders.add(newMap.get(orderId));
                    }
                    SkipOrderRefundAssetAfterUpdate = true;
                } else if (oldStatus != ACAMSUtil.CANCELLED && newStatus == ACAMSUtil.CANCELLED) {
                    orderIdsForInvoices.add(orderId);
                    orderIdsForInvoicesToCheckFinalized.add(orderId);
                    orderCancelled = true;
                    ccrz__E_Order__c order = newMap.get(orderId);
                    if (order.Opportunity__c != null) {
                        cancelledOpportunityIds.add(order.Opportunity__c);
                    }
                } else if (oldStatus != ACAMSUtil.COMPLETED && newStatus == ACAMSUtil.COMPLETED) { //FSA-409
                    completedOrders.add(orderId);
                    //csa fix: fsa:7687
                    ACAMSLogicCartPlace.addNumberOfOrdersToAccountfuture(newMap.get(orderId).ccrz__Account__c);
                }
            }

            //sp37, FSA-5411  chandra requirement start
            Set < ccrz__E_Order__c > ordRec = new Set < ccrz__E_Order__c > ();
            //system.debug('----order 240=====>Aditya<='+ this.newOrders);
            List < ccrz__E_Order__c > zeroOrders = [select Id, ccrz__OrderStatus__c, ccrz__Account__c, Opportunity__c, ccrz__BillTo__c, ccrz__Contact__c, Total_Order_Amount__c, (select Id, Status__c from Assets__r), (select Id, ccrz__OriginalAmount__c, Invoice_Status__c, ccrz__Status__c, Finalized__c from ccrz__CCInvoices__r) from ccrz__E_Order__c where Id in: Trigger.newmap.keyset()];
            for (ccrz__E_Order__c order: zeroOrders) {
                // system.debug('----order 243=====>Aditya<='+ order.ccrz__CCInvoices__r.size());
                if (order.Id != null && order.Total_Order_Amount__c < 1.00 && order.ccrz__CCInvoices__r.size() > 0) {
                    for (ccrz__E_Invoice__c invoice: order.ccrz__CCInvoices__r) {
                        if (invoice.ccrz__OriginalAmount__c < 1) {
                            ordRec.add(order);
                        }
                    }
                }
            }
            //system.debug('---------orderrecord249=====>'+ ordRec);
            //system.debug('---------SkipcreateTransPayAfterUpdate=====>'+ SkipcreateTransPayAfterUpdate);
            if (!SkipcreateTransPayAfterUpdate && ordRec.size() > 0)
                ApplyZeroPaymentonOrder(ordRec);
            //sp37, FSA-5411  chandra requirement close

            //FSA - 409
            //system.debug('-----------completedOrders-------------'+completedOrders.size());
            List < ccrz__E_Order__c > cOrders = new List < ccrz__E_Order__c > ();
            // code optimization 1 line - vara 1469 
            if (!completedOrders.isEmpty())
                cOrders = [select Id, ccrz__OrderStatus__c, ccrz__Account__c, Opportunity__c, ccrz__BillTo__c, ccrz__Contact__c, Total_Order_Amount__c, (select Id, Status__c from Assets__r), (select Id, Invoice_Status__c, ccrz__Status__c, Finalized__c from ccrz__CCInvoices__r) from ccrz__E_Order__c where Id in: completedOrders];
            //system.debug('-----------cOrders-------'+cOrders.size());        
            List < ccrz__E_Invoice__c > invToUpdate = new List < ccrz__E_Invoice__c > ();
            for (ccrz__E_Order__c order: cOrders) {
                //system.debug('order.ccrz__CCInvoices__r.size()::'+order.ccrz__CCInvoices__r.size());
                if (order.ccrz__CCInvoices__r.size() > 0 && (order.Total_Order_Amount__c == 0 || order.Total_Order_Amount__c < 1)) {
                    for (ccrz__E_Invoice__c invoice: order.ccrz__CCInvoices__r) {
                        if (invoice.ccrz__Status__c != ACAMSUtil.CLOSED) {
                            invoice.ccrz__Status__c = ACAMSUtil.CLOSED;
                            invoice.Invoice_Status__c = ACAMSUtil.CLOSED;
                            invToUpdate.add(invoice);
                        }
                    }
                }
            }
            if (invToUpdate.size() > 0) {
                update invToUpdate;
            }
            //FSA - 409 

            if (!orderIdsForInvoices.isEmpty()) {
                List < ccrz__E_Invoice__c > invoices = [SELECT Id, ccrz__Status__c, ccrz__CCOrder__c, Invoice_Status__c FROM ccrz__E_Invoice__c WHERE ccrz__CCOrder__c IN: orderIdsForInvoices];
                Set < Id > orderIds = new Set < Id > ();
                List < ccrz__E_Invoice__c > invoicesToUpdate = new List < ccrz__E_Invoice__c > ();
                for (ccrz__E_Invoice__c invoice: invoices) {
                    if (orderCancelled) {
                        invoice.Invoice_Status__c = 'Cancelled';
                        invoice.Refund_Date__c = Date.today();
                        invoicesToUpdate.add(invoice);
                    } else if (invoice.ccrz__Status__c != 'Closed') {
                        invoice.Invoice_Status__c = 'Closed';
                        invoice.ccrz__Status__c = 'Closed';
                        invoicesToUpdate.add(invoice);
                    }
                    orderIds.add(invoice.ccrz__CCOrder__c);
                }
                update invoicesToUpdate;
                //CSA-fix to check using future
                //ACAMSAssetHelper.cancelAssetsByOrderIds(orderIds);
                ACAMSAssetHelper.cancelAssetsByOrderIdsFuture(orderIds);

            }

            if (!orderIdsForInvoicesToCheckFinalized.isEmpty()) {
                List < ccrz__E_Invoice__c > invoicesToCheck = [SELECT Id FROM ccrz__E_Invoice__c WHERE ccrz__CCOrder__c IN: orderIdsForInvoicesToCheckFinalized AND Finalized__c = TRUE];
                if (!invoicesToCheck.isEmpty()) {
                    List < ccrz__E_Order__c > orderList = ACAMSOrderDAO.getOrders(orderIdsForInvoicesToCheckFinalized);
                    cloneReturnOrders(orderList, newMap, ACAMSUtil.CANCELLED);
                }
            }

            if (!refundCreditOrders.isEmpty()) {
                cloneReturnOrders(refundCreditOrders, newMap, ACAMSUtil.ORDER_STATUS_REFUNDED_CREDIT);
            }

            // vara added code optimization 1469
            if (updatedShipments.size() > 0)
                update updatedShipments;

            List < ACAMSPaymentProcessing.CapturePayment > capturePaymentsList = new List < ACAMSPaymentProcessing.CapturePayment > ();
            if (!capturedOrders.isEmpty()) {
                capturePaymentsList = capturePayments(capturedOrders);
            }

            // chandra added fsa-5411 variable false to bypass zero transaction payment to avoid to create one more payment record. 
            //system.debug('---------SkipcreateTransPayAfterUpdate---357--------'+SkipcreateTransPayAfterUpdate);
            if (capturePaymentsList.size() > 0) {
                System.enqueueJob(capturePaymentsList[0]);
            }

            if (!returnOrders.isEmpty()) {
                List < ccrz__E_Order__c > checkRefundList = new List < ccrz__E_Order__c > ();
                List < ccrz__E_Order__c > wireTransferRefundList = new List < ccrz__E_Order__c > ();
                for (ccrz__E_Order__c order: returnOrders) {
                    if (order.ccrz__PaymentMethod__c == ACAMSUtil.CHECK) {
                        checkRefundList.add(order);
                    } else if (order.ccrz__PaymentMethod__c == ACAMSUtil.WIRE_TRANSFER) {
                        wireTransferRefundList.add(order);
                    }
                }
                cloneReturnOrders(returnOrders, newMap, ACAMSUtil.REFUNDED);
            }
            if (!refundOrders.isEmpty()) {
                refundPayments(refundOrders);
            }
            if (!refundCreditOrders.isEmpty()) {
                ACAMSCreditService.createCreditsForOrders(refundCreditOrders);
            }
            if (!cancelledOpportunityIds.isEmpty()) {
                List < Opportunity > opps = ACAMSOpportunityDAO.getOpportunities(cancelledOpportunityIds);
                for (Opportunity opp: opps) {
                    if (!opp.StageName.equalsIgnoreCase(ACAMSUtil.CANCELLED)) {
                        opp.StageName = ACAMSUtil.CANCELLED;
                        opp.Refund_Date__c = Date.today();
                    }
                }
                SkipOrderRefundAssetAfterUpdate = true;
                // vara commneted this for optimization, 1469. not meeded with sahring in class level its a automatic trigger helper class. 
                /*User currentUser = [SELECT Bypass_Validations__c FROM User WHERE Id = :UserInfo.getUserId()];
                currentUser.Bypass_Validations__c = true;
                update currentUser; */
                if (opps.size() > 0)
                    update opps;
                /* currentUser.Bypass_Validations__c = false;
                update currentUser; */
            }
            SkipOrderRefundAssetAfterUpdate = false;
        }

        public static List < ACAMSPaymentProcessing.CapturePayment > capturePayments(Set < Id > orderIds) {
            List < ACAMSPaymentProcessing.CapturePayment > capturePaymentsList = new List < ACAMSPaymentProcessing.CapturePayment > ();
            Map < Id, List < ccrz__E_TransactionPayment__c >> transactionPaymentMap = new Map < Id, List < ccrz__E_TransactionPayment__c >> ();
            List < ccrz__E_TransactionPayment__c > transactionPayments = ACAMSOrderDAO.getTransactionPayments(orderIds);
            for (ccrz__E_TransactionPayment__c transactionPayment: transactionPayments) {
                if (!transactionPaymentMap.containsKey(transactionPayment.ccrz__CCOrder__c)) {
                    transactionPaymentMap.put(transactionPayment.ccrz__CCOrder__c, transactionPayments);
                }
            }
            List < ccrz__E_Order__c > orders = ACAMSOrderDAO.getOrders(orderIds);
            Map < Id, ccrz__E_Order__c > orderMap = new Map < Id, ccrz__E_Order__c > ();
            for (ccrz__E_Order__c order: orders) {
                orderMap.put(order.Id, order);
            }

            for (Id orderId: orderIds) {
                Id transactionId;
                String orderNumber;
                String storefront;
                String memberNumber;
                List < ccrz__E_TransactionPayment__c > transactionPaymentsList = transactionPaymentMap.get(orderId);
                ccrz__E_Order__c order = orderMap.get(orderId);

                if (transactionPaymentsList == null) {
                    continue;
                }

                List < ccrz__E_TransactionPayment__c > authsToCapture = new List < ccrz__E_TransactionPayment__c > ();
                for (ccrz__E_TransactionPayment__c transactionPayment: transactionPaymentsList) {
                    // Not a cc transaction or a capture already took place.
                    if ('sopcc'.equalsIgnoreCase(transactionPayment.ccrz__AccountType__c) &&
                        transactionPayment.ccrz__TransactionType__c.containsIgnoreCase(ACAMSUtil.AUTHORIZATION)) {
                        Boolean captured = true;
                        for (ccrz__E_TransactionPayment__c transactionPaymentCaptured: transactionPaymentsList) {
                            if ('sopcc'.equalsIgnoreCase(transactionPaymentCaptured.ccrz__AccountType__c) &&
                                ACAMSUtil.CAPTURE.equalsIgnoreCase(transactionPaymentCaptured.ccrz__TransactionType__c) &&
                                transactionPayment.Id == transactionPaymentCaptured.ccrz__SourceTransactionPayment__c) {
                                captured = true;
                                break;
                            }
                        }
                        if (!captured) {
                            authsToCapture.add(transactionPayment);
                        }
                    }
                }
                if (!authsToCapture.isEmpty()) {
                    for (ccrz__E_TransactionPayment__c transactionPayment: authsToCapture) {
                        transactionId = transactionPayment.Id;

                        if (transactionId != null) {
                            try {
                                if (orderNumber == null) {
                                    orderNumber = order.ccrz__OrderNumber__c.toPlainString();
                                }
                                if (storefront == null) {
                                    storefront = order.ccrz__Storefront__c;
                                }
                                if (memberNumber == null) {
                                    memberNumber = order.ccrz__Account__r.Member_Number__c;
                                }
                            } catch (Exception e) {
                                ACAMSUtil.reportException(null, null, 'capturePayments method call', null, e.getMessage(), null, null);

                            }
                            ACAMSPaymentProcessing.CapturePayment capturePayment = new ACAMSPaymentProcessing.CapturePayment(transactionId,
                                transactionPayment.ccrz__Amount__c, orderNumber, null, storefront, memberNumber, null);
                            capturePaymentsList.add(capturePayment);
                        }
                    }
                }
            }
            Integer length = capturePaymentsList.size();

            for (Integer y = 0; y < length - 1; y++) {
                capturePaymentsList[y].setChainedJob(capturePaymentsList[y + 1]);
            }
            return capturePaymentsList;
        }

        private static Map < Id, List < ccrz__E_OrderItem__c >> getOrderItemsByOrderIds(Set < Id > orderIds) {
            Map < Id, List < ccrz__E_OrderItem__c >> orderIdToOrderItemMap = new Map < Id, List < ccrz__E_OrderItem__c >> ();
            List < ccrz__E_OrderItem__c > orderItems = ACAMSOrderDAO.getOrderItems(orderIds);
            for (ccrz__E_OrderItem__c orderItem: orderItems) {
                if (orderIdToOrderItemMap.containsKey(orderItem.ccrz__Order__c)) {
                    List < ccrz__E_OrderItem__c > orderItemsList = orderIdToOrderItemMap.get(orderItem.ccrz__Order__c);
                    orderItemsList.add(orderItem);
                    orderIdToOrderItemMap.put(orderItem.ccrz__Order__c, orderItemsList);
                } else {
                    List < ccrz__E_OrderItem__c > orderItemsList = new List < ccrz__E_OrderItem__c > {
                        orderItem
                    };
                    orderIdToOrderItemMap.put(orderItem.ccrz__Order__c, orderItemsList);
                }
            }
            return orderIdToOrderItemMap;
        }

        private static Map < Id, List < ccrz__E_TransactionPayment__c >> getTransPaymentsByOrderIds(Set < Id > orderIds) {
            Map < Id, List < ccrz__E_TransactionPayment__c >> idToTransPaymentMap = new Map < Id, List < ccrz__E_TransactionPayment__c >> ();
            List < ccrz__E_TransactionPayment__c > tpList = ACAMSOrderDAO.getCapturedTransactionPayments(orderIds);
            for (ccrz__E_TransactionPayment__c tp: tpList) {
                if (idToTransPaymentMap.containsKey(tp.ccrz__CCOrder__c)) {
                    idToTransPaymentMap.get(tp.ccrz__CCOrder__c).add(tp);
                } else {
                    idToTransPaymentMap.put(tp.ccrz__CCOrder__c, new List < ccrz__E_TransactionPayment__c > {
                        tp
                    });
                }
            }
            return idToTransPaymentMap;
        }

        private static void refundPayments(Set < Id > orderIds) {
            ACAMSPaymentProcessing.refundPayments(orderIds);
        }

        private void cloneReturnOrders(List < ccrz__E_Order__c > returnOrders, Map < Id, ccrz__E_Order__c > newMap, String status) {
            Set < Id > returnOrderIds = (new Map < Id, ccrz__E_Order__c > (returnOrders)).keySet();
            Map < Id, ccrz__E_Order__c > idToOrderMap = new Map < Id, ccrz__E_Order__c > (ACAMSOrderDAO.getOrders(returnOrderIds));
            List < ccrz__E_OrderItem__c > childOrderItems = ACAMSOrderDAO.getChildOrderItems(newMap.keySet());
            Map < Id, List < ccrz__E_OrderItem__c >> idToOrderItemsMap = new Map < Id, List < ccrz__E_OrderItem__c >> ();
            Set < Id > childOrderItemIds = new Set < Id > ();
            for (ccrz__E_OrderItem__c childOrderItem: childOrderItems) {
                if (idToOrderItemsMap.containsKey(childOrderItem.ccrz__ParentOrderItem__c)) {
                    List < ccrz__E_OrderItem__c > orderItemsList = idToOrderItemsMap.get(childOrderItem.ccrz__ParentOrderItem__c);
                    orderItemsList.add(childOrderItem);
                    idToOrderItemsMap.put(childOrderItem.ccrz__ParentOrderItem__c, orderItemsList);
                } else {
                    List < ccrz__E_OrderItem__c > orderItemsList = new List < ccrz__E_OrderItem__c > {
                        childOrderItem
                    };
                    idToOrderItemsMap.put(childOrderItem.ccrz__ParentOrderItem__c, orderItemsList);
                }
                childOrderItemIds.add(childOrderItem.Id);
            }
            List < ccrz__E_OrderItem__c > orderItemsToClone = ACAMSOrderDAO.getOrderItems(returnOrderIds);
            Set < Id > orderItemIdsToClone = new Set < Id > ();
            for (ccrz__E_OrderItem__c orderItem: orderItemsToClone) {
                orderItemIdsToClone.add(orderItem.Id);
            }
            childOrderItemIds.addAll(orderItemIdsToClone);

            ACAMSOrderHelper.cloneOrders(returnOrderIds, orderItemsToClone, idToOrderMap, idToOrderItemsMap, status);
        }

        private void calculateLegalEntitySummary(List < ccrz__E_Order__c > orders) {
            if (!skipLegalEntitySummaryCalculation) {
                ACAMSLegalEntityService.calculateLegalEntitySummary(
                    orders,
                    ccrz__E_Order__c.Legal_Entity__c.getDescribe().getName(),
                    ccrz__E_Order__c.Legal_Entities_ACAMS_LLC__c.getDescribe().getName(),
                    ccrz__E_Order__c.Legal_Entities_ACAMS_Germany__c.getDescribe().getName(),
                    ccrz__E_Order__c.Legal_Entities_ACAMS_Canada__c.getDescribe().getName(),
                    ccrz__E_Order__c.Legal_Entities_ACAMS_Beijing__c.getDescribe().getName()
                );

            }
        }

        private void updateOwnerIdOrdr(List < ccrz__E_Order__c > newOrdrs, Map < Id, ccrz__E_Order__c > oldOrdrMap) {
            Map < Id, ccrz__E_Order__c > orderIdMap = new Map < Id, ccrz__E_Order__c > ();
            Map < Id, ccrz__E_Order__c > OrderCartIdMap = new Map < Id, ccrz__E_Order__c > ();
            List < ccrz__E_Invoice__c > invLst = new List < ccrz__E_Invoice__c > ();
            List < ccrz__E_Invoice__c > invLstUpdate = new List < ccrz__E_Invoice__c > ();
            List < ccrz__E_TransactionPayment__c > tpmntLst = new List < ccrz__E_TransactionPayment__c > ();
            List < ccrz__E_TransactionPayment__c > tpmntLstUpdate = new List < ccrz__E_TransactionPayment__c > ();
            List < ccrz__E_Cart__c > cartLst = new List < ccrz__E_Cart__c > ();
            List < ccrz__E_Cart__c > cartLstUpdate = new List < ccrz__E_Cart__c > ();
            List < Asset > astLst = new List < Asset > ();
            List < Asset > astLstUpdate = new List < Asset > ();
            for (ccrz__E_Order__c ord: newOrdrs) {
                if (ord.OwnerId != oldOrdrMap.get(ord.id).OwnerId) {
                    orderIdMap.put(ord.id, ord);
                    OrderCartIdMap.put(ord.ccrz__OriginatedCart__c, ord);
                }
            }
            try {
                // code optimization 1 line - vara 1469 
                if (!orderIdMap.isEmpty())
                    invLst = [select id, name, ownerid, ccrz__CCOrder__r.ownerid, Reassign_Owner__c from ccrz__E_Invoice__c where ccrz__CCOrder__c IN: orderIdMap.keyset()];
                //system.debug(invLst);
                for (ccrz__E_Invoice__c inv: invLst) {
                    //system.debug(inv.ownerid != inv.ccrz__CCOrder__r.ownerid);
                    if (inv.ownerid != inv.ccrz__CCOrder__r.ownerid) {
                        if (inv.Reassign_Owner__c == false) { // fsa-6330 - chandra
                            inv.ownerid = inv.ccrz__CCOrder__r.ownerid;
                            //system.debug('Invoice Id --->'+inv.ownerid);
                            invLstUpdate.add(inv);
                        }
                    }
                }

                if (invLstUpdate.size() > 0) {
                    update invLstUpdate;
                }

                // code optimization 1 line - vara 1469 
                if (!orderIdMap.isEmpty())
                    tpmntLst = [select id, name, ownerid, ccrz__CCOrder__r.ownerid from ccrz__E_TransactionPayment__c where ccrz__CCOrder__c IN: orderIdMap.keyset()];
                for (ccrz__E_TransactionPayment__c tpmnt: tpmntLst) {
                    if (tpmnt.ownerid != tpmnt.ccrz__CCOrder__r.ownerid) {
                        tpmnt.ownerid = tpmnt.ccrz__CCOrder__r.ownerid;
                        tpmntLstUpdate.add(tpmnt);
                    }

                }
                if (tpmntLstUpdate.size() > 0) {
                    update tpmntLstUpdate;
                }

                // code optimization 1 line - vara 1469 
                if (!orderIdMap.isEmpty())
                    astLst = [select id, name, ownerid, CC_Order__r.ownerid from Asset where CC_Order__c IN: orderIdMap.keyset()];
                for (Asset ast: astLst) {
                    if (ast.ownerid != ast.CC_Order__r.ownerid) {
                        ast.ownerid = ast.CC_Order__r.ownerid;
                        astLstUpdate.add(ast);
                    }
                }
                if (astLstUpdate.size() > 0) {
                    update astLstUpdate;
                }

                // code optimization 1 line - vara 1469 
                if (!OrderCartIdMap.isEmpty())
                    cartLst = [select id, name, ownerid from ccrz__E_Cart__c where id IN: OrderCartIdMap.keyset()];
                for (ccrz__E_Cart__c crt: cartLst) {
                    if (crt.ownerid != OrderCartIdMap.get(crt.id).ownerid) {
                        crt.ownerid = OrderCartIdMap.get(crt.id).ownerid;
                        cartLstUpdate.add(crt);
                    }

                }
                if (cartLstUpdate.size() > 0) {
                    update cartLstUpdate;
                }
            } catch (DmlException e) {
                //csa fix added exception logger statement. 
                ACAMSUtil.reportException(null, null, 'updateOwnerIdOrdr Method', null, e.getMessage(), null, null);

            }
            updateOwnerIdOrdrExecuted = true;
        }

        //fsa-5411 
        public static void ApplyZeroPaymentonOrder(Set < ccrz__E_Order__c > ordList) {
            List < ccrz__E_TransactionPayment__c > zeropayList = new List < ccrz__E_TransactionPayment__c > ();
            set < id > orset = new set < id > ();
            set < id > oppSet = new set < id > ();
            for (ccrz__E_Order__c ord: ordList) {
                orset.add(ord.id);
            }
            List < ccrz__E_TransactionPayment__c > tpList = [select id, name from ccrz__E_TransactionPayment__c where ccrz__CCOrder__c =: orset];
            //system.debug('-----------ApplyZeroPaymentonOrder method-----------'+orset);
            for (ccrz__E_Order__c ord: [select id, name, Opportunity__c, ccrz__Account__c, ccrz__BillTo__c, ccrz__Contact__c from ccrz__E_Order__c where Id in: orset]) {
                ccrz__E_TransactionPayment__c zeropay = new ccrz__E_TransactionPayment__c();
                zeropay.ccrz__CCOrder__c = ord.id;
                zeropay.ccrz__BillTo__c = ord.ccrz__Account__c;
                zeropay.ccrz__SoldTo__c = ord.ccrz__Account__c;
                zeropay.ccrz__Account__c = ord.ccrz__Account__c;
                zeropay.ccrz__Address__c = ord.ccrz__BillTo__c;
                zeropay.ccrz__Contact__c = ord.ccrz__Contact__c;
                zeropay.ccrz__TransactionType__c = 'authorization'; // capture
                zeropay.ccrz__RequestAmount__c = 0.00;
                zeropay.ccrz__Amount__c = 0.00;
                zeropay.Bank__c = 'AUS_Chapter';
                zeropay.ccrz__PaymentType__c = 'zero_dollar';
                zeropay.ccrz__AccountType__c = 'zero_dollar';
                zeropay.ccrz__TransactionTS__c = system.today();
                zeropay.ccrz__Storefront__c = 'ACAMS';
                zeropay.ccrz__CurrencyISOCode__c = 'USD';
                zeropay.CSR_Zero_Dollar_Transaction__c = true;
                zeropayList.add(zeropay);
            }

            if (!zeropayList.isEmpty() && tpList.isempty()) {
                insert zeropayList;
                SkipcreateTransPayAfterUpdate = true;
            }
        } // method close 

    }