public with sharing class ACAMSInvoiceTriggerHandler extends CCAviTriggerHandler {

    private List<ccrz__E_Invoice__c> newList = (List<ccrz__E_Invoice__c>) Trigger.new;
    private List<ccrz__E_Invoice__c> oldList = (List<ccrz__E_Invoice__c>) Trigger.old;
    private Map<Id, ccrz__E_Invoice__c> newMap = (Map<Id, ccrz__E_Invoice__c>) Trigger.newMap;
    private Map<Id, ccrz__E_Invoice__c> oldMap = (Map<Id, ccrz__E_Invoice__c>) Trigger.oldMap;
    
    // FSA-1093, validate CC Invoice Original Amount == to CC Order Sub total
    private Map<Id, ccrz__E_Invoice__c> invoiceOrderMap = new Map<Id, ccrz__E_Invoice__c>();

    public static Boolean skipLegalEntitySummaryCalculation = false;
//csa fix:added method for querying   
private Map<Id, ccrz__E_Invoice__c> getNewInvoices(Set<Id> recordIds) {
    return new Map<Id, ccrz__E_Invoice__c>([
        SELECT Id, Sold_To_Tax_Area_Id__c, ccrz__OriginalAmount__c,ccrz__CCOrder__c,ccrz__CCOrder__r.ccrz__OrderStatus__c,
        (SELECT Id FROM ccrz__ChildInvoices__r),
        (SELECT Id, ccrz__CCOrderItem__c, Quantity__c, ItemQuantity__c, Total_Amount__c FROM ccrz__InvoiceItems__r)
        FROM ccrz__E_Invoice__c
        WHERE Id IN :recordIds
    ]);
}
    protected override void beforeInsert() {
        List<Vertex.VertexAnyRequest.InvokeAnyRequestStructure> requestList = new List<Vertex.VertexAnyRequest.InvokeAnyRequestStructure>();
        for (ccrz__E_Invoice__c invoice : newList) {
            // Close invoice if original and remaining amount are zero and parent invoice is null
            // (Closed invoice for Zero Dollar payment method).
            if (invoice.ccrz__OriginalAmount__c == 0.00 && invoice.ccrz__RemainingAmount__c == 0.00 && invoice.ccrz__ParentInvoice__c == null) {
             //FSA-5411 Added by Chandra
              invoice.Paid_in_Full_Date__c=system.today(); 
                invoice.Finalized__c=true;
                invoice.Sent_to_Vertex__c=true;
            //    invoice.ccrz__Status__c = ACAMSUtil.CLOSED;
              //  invoice.Invoice_Status__c = ACAMSUtil.CLOSED;
            } else {
                invoice.ccrz__Status__c = invoice.Invoice_Status__c;
            }
            //csa fix:deactivated Set CC Invoice Enterprise Account field workflow and implemented that logic here.
            String profileId = System.Label.ACAMSInvoiceTriggerHandler_ProfileId;
            if(invoice.ccrz__BillTo__r.Enterprise_Account__c == true && UserInfo.getProfileId() != profileId) {
                invoice.Is_Enterprise_Account__c = true;
            }
            if(invoice.Finalized__c==true && invoice.Sent_to_Vertex__c==false && invoice.Destination_Country__c <> 'China'){
                invoice.Sent_to_Vertex__c = true;
                Vertex.VertexAnyRequest.InvokeAnyRequestStructure request=new Vertex.VertexAnyRequest.InvokeAnyRequestStructure();
                request.recordId = invoice.Id;
                request.type = 'CC Invoice';
                
                Vertex_Tax_Calculation_Bypass__c bypassSettings = Vertex_Tax_Calculation_Bypass__c.getInstance();
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

    protected override void beforeUpdate() {
        List<Vertex.VertexAnyRequest.InvokeAnyRequestStructure> requestList = new List<Vertex.VertexAnyRequest.InvokeAnyRequestStructure>();
        this.calculateLegalEntitySummary();
        /*Map<Id, ccrz__E_Invoice__c> newInvoices = new Map<Id, ccrz__E_Invoice__c>([
                SELECT Id, Sold_To_Tax_Area_Id__c, ccrz__OriginalAmount__c, ccrz__CCOrder__r.ccrz__OrderStatus__c,
                (SELECT Id FROM ccrz__ChildInvoices__r),
                (SELECT Total_Amount__c FROM ccrz__InvoiceItems__r)
                FROM ccrz__E_Invoice__c
                WHERE Id IN :newMap.keySet()
        ]);*/
//csa fix:calling method instead of querying.
            Map<Id, ccrz__E_Invoice__c> newInvoices = getNewInvoices(newMap.keySet());

//csa fixed:method calling removed from for
         Map<String, Profile> profileMap = ACAMSUserDAO.getProfilesMap(new Set<String>{
                    'ACAMS - Operations', 'System Administrator', 'System Administrator (Restricted)', 'Data Migration'
            });
        Set<Id> invoiceIdsToFinalize = new Set<Id>();
        for (Id invoiceId : newMap.keySet()) {
            Boolean oldFinalized = oldMap.get(invoiceId).Finalized__c;
            Boolean newFinalized = newMap.get(invoiceId).Finalized__c;
            String oldStatus = oldMap.get(invoiceId).Invoice_Status__c;
            String newStatus = newMap.get(invoiceId).Invoice_Status__c;
            Date oldPaidInFull = oldMap.get(invoiceId).Paid_in_Full_Date__c;
            Date newPaidInFull = newMap.get(invoiceId).Paid_in_Full_Date__c;
            
             
            newMap.get(invoiceId).ccrz__Status__c = newStatus;
            if (oldStatus != newStatus && newStatus == 'Closed') {
                if (newInvoices.get(invoiceId).Sold_To_Tax_Area_Id__c != null &&
                        newInvoices.get(invoiceId).ccrz__ChildInvoices__r.size() == 0 &&
                        newInvoices.get(invoiceId).ccrz__CCOrder__r.ccrz__OrderStatus__c != ACAMSUtil.CANCELLED &&
            newInvoices.get(invoiceId).ccrz__OriginalAmount__c != 0) {
                    newMap.get(invoiceId).Finalized__c = true;
                    newFinalized = true;
                }
               
            }
            if (!oldFinalized && newFinalized) {
                invoiceIdsToFinalize.add(invoiceId);
                if (newInvoices.get(invoiceId).ccrz__ChildInvoices__r.size() > 0) {
                    newMap.get(invoiceId).addError('This is a parent invoice and cannot be finalized. ' +
                            'Please finalize or remove the child invoices attached to this record.');
                }
            }

            if (oldPaidInFull != newPaidInFull && newStatus == 'Closed' && oldStatus == 'Closed' ) {
                newMap.get(invoiceId).Paid_in_Full_Date__c.addError('Cannot update Paid Date when Invoice Status is Closed');
            }

            ccrz__E_Invoice__c oldInvoice = oldMap.get(invoiceId);
            ccrz__E_Invoice__c newInvoice = newMap.get(invoiceId);
            
            /* csa fixed:method calling which contains query removed from for loop
             Map<String, Profile> profileMap = ACAMSUserDAO.getProfilesMap(new Set<String>{
              //      'ACAMS - Operations', 'System Administrator', 'System Administrator (Restricted)', 'Data Migration'
            });*/
            Profile opsProfile = profileMap.containsKey('ACAMS - Operations') ?
                    profileMap.get('ACAMS - Operations') : null;
            Profile systemAdminProfile = profileMap.containsKey('System Administrator') ?
                    profileMap.get('System Administrator') : null;
            Profile systemAdminRestrictedProfile = profileMap.containsKey('System Administrator (Restricted)') ?
                    profileMap.get('System Administrator (Restricted)') : null;
            Profile dataMigrationProfile = profileMap.containsKey('Data Migration') ?
                    profileMap.get('Data Migration') : null;
            Boolean excludedProfile = false;
            if ((opsProfile != null && UserInfo.getProfileId() == opsProfile.Id) || (systemAdminProfile != null &&
                    UserInfo.getProfileId() == systemAdminProfile.Id) || (systemAdminRestrictedProfile != null &&
                    UserInfo.getProfileId() == systemAdminRestrictedProfile.Id) || (dataMigrationProfile != null &&
                    UserInfo.getProfileId() == dataMigrationProfile.Id)) {
                excludedProfile = true;
            }

            if (!excludedProfile && (newInvoice.Destination_Country__c != 'China' && newInvoice.Finalized__c &&
                    newInvoice.Sent_to_Vertex__c && oldInvoice.Sent_to_Vertex__c &&
                    oldInvoice.Paid_in_Full_Date__c == newInvoice.Paid_in_Full_Date__c &&
                    oldInvoice.ccrz__RemainingAmount__c == newInvoice.ccrz__RemainingAmount__c &&
                    newInvoice.ccrz__OriginalAmount__c > 0 && updatedVertexFields(oldInvoice, newInvoice))) {
                newInvoice.addError('Cannot modify an invoice when Destination Country is not China, the invoice is ' +
                        'finalized and has been sent to Vertex.');
            }

            Decimal totalAmount = 0;
           // FSA-1093
            if (newInvoice.Sent_to_Vertex__c == true && oldInvoice.Sent_to_Vertex__c == false) {
               validateInvoiceOriginalAmount();
            }
      // vara uncommneted start 
      /*if (newInvoice.Sent_to_Vertex__c == true && oldInvoice.Sent_to_Vertex__c == false) {
                for (ccrz__E_InvoiceItem__c invoiceItem : newInvoices.get(invoiceId).ccrz__InvoiceItems__r) {
                  system.debug('invoiceItem.Total_Amount__c::'+invoiceItem.Total_Amount__c);
                    totalAmount += invoiceItem.Total_Amount__c;
                    system.debug('totalAmount::'+totalAmount);
                }
                if (newMap.get(invoiceId).ccrz__OriginalAmount__c == newMap.get(invoiceId).ccrz__RemainingAmount__c) {
                    newMap.get(invoiceId).ccrz__RemainingAmount__c = totalAmount;
                }
                newMap.get(invoiceId).ccrz__OriginalAmount__c = totalAmount;
                system.debug('newMap.get(invoiceId).ccrz__OriginalAmount__c2::'+ newMap.get(invoiceId).ccrz__OriginalAmount__c );
            } */
      // vara uncommented end
            if (newInvoice.Destination_Country__c != oldInvoice.Destination_Country__c && newInvoice.Destination_Country__c !='China' && 
                newInvoice.Finalized__c != oldInvoice.Finalized__c && newInvoice.Finalized__c == true && 
                newInvoice.Sent_to_Vertex__c != oldInvoice.Sent_to_Vertex__c && newInvoice.Sent_to_Vertex__c == false) {
                    newInvoice.Sent_to_Vertex__c = true;
                    Vertex.VertexAnyRequest.InvokeAnyRequestStructure request=new Vertex.VertexAnyRequest.InvokeAnyRequestStructure();
                    request.recordId = newInvoice.Id;
                    request.type = 'CC Invoice';
                    Vertex_Tax_Calculation_Bypass__c bypassSettings = Vertex_Tax_Calculation_Bypass__c.getInstance();
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
        for (Id invoiceId : invoiceIdsToFinalize) {
            if (newInvoices.get(invoiceId).Sold_To_Tax_Area_Id__c == null) {
                newMap.get(invoiceId).addError('Please review the address(es) on this Invoice. They were not ' +
                        'validated through Vertex.');
            }
        }

    }

    protected override void afterInsert() {
        this.updateParentInvoiceIfChildInvoice(this.newList, null);

 
    }

    protected override void afterUpdate() {
            //System.debug('Trigger starting...');

       /* Map<Id, ccrz__E_Invoice__c> newInvoices = new Map<Id, ccrz__E_Invoice__c>([
                SELECT Id, Sold_To_Tax_Area_Id__c, ccrz__OriginalAmount__c, ccrz__CCOrder__c, ccrz__CCOrder__r.ccrz__OrderStatus__c,
                (SELECT Id, ccrz__CCOrderItem__c, Quantity__c, ItemQuantity__c FROM ccrz__InvoiceItems__r)
                FROM ccrz__E_Invoice__c
                WHERE Id IN :newMap.keySet()
        ]);*/
        //csa fix:calling method instead of querying.           
        Map<Id, ccrz__E_Invoice__c> newInvoices = getNewInvoices(newMap.keySet());

        Map<Id, Decimal> orderItemsMap = new Map<Id, Decimal>();
        for (Id invoiceId : newMap.keySet()) {
            String oldStatus = oldMap.get(invoiceId).Invoice_Status__c;
            String newStatus = newMap.get(invoiceId).Invoice_Status__c;
            if (oldStatus != newStatus && newStatus == 'Closed' &&
                    newMap.get(invoiceId).ccrz__CCOrder__r.ccrz__OrderStatus__c != ACAMSUtil.CANCELLED &&
                    newMap.get(invoiceId).ccrz__CCOrder__r.ccrz__OrderStatus__c != ACAMSUtil.REFUNDED &&
                    newMap.get(invoiceId).ccrz__CCOrder__r.ccrz__OrderStatus__c != ACAMSUtil.ORDER_STATUS_REFUNDED_CREDIT) {
                for (ccrz__E_InvoiceItem__c invoiceItem : newInvoices.get(invoiceId).ccrz__InvoiceItems__r) {
                    Decimal quantity = invoiceItem.Quantity__c != null ?
                            invoiceItem.Quantity__c : invoiceItem.ItemQuantity__c;
                    if (invoiceItem.ccrz__CCOrderItem__c != null) {
                        orderItemsMap.put(invoiceItem.ccrz__CCOrderItem__c, quantity);
                    }
                }
                if(System.isFuture() || System.isBatch()){//FSA-875
              ACAMSAssetHelper.activateAssets(orderItemsMap);
            }else{
                ACAMSAssetHelper.activateAssetsFuture(orderItemsMap);
            }
                //ACAMSAssetHelper.activateAssets(orderItemsMap);
            }
        }
        this.updateParentInvoiceIfChildInvoice(this.newList, this.oldMap);
    }

    private void calculateLegalEntitySummary() {
        if (!skipLegalEntitySummaryCalculation) {
            ACAMSLegalEntityService.calculateLegalEntitySummary(
                    this.newList,
                    ccrz__E_Invoice__c.Legal_Entity__c.getDescribe().getName(),
                    ccrz__E_Invoice__c.Legal_Entities_ACAMS_LLC__c.getDescribe().getName(),
                    ccrz__E_Invoice__c.Legal_Entities_ACAMS_Germany__c.getDescribe().getName(),
                    ccrz__E_Invoice__c.Legal_Entities_ACAMS_Canada__c.getDescribe().getName(),
                    ccrz__E_Invoice__c.Legal_Entities_ACAMS_Beijing__c.getDescribe().getName()
            );
        }
    }

    private void updateParentInvoiceIfChildInvoice(List<ccrz__E_Invoice__c> newInvoices,
            Map<Id, ccrz__E_Invoice__c> oldMap) {
        Set<Id> invoiceIds = new Set<Id>();
        List<ccrz__E_Invoice__c> parentInvoiceLst = new List<ccrz__E_Invoice__c>();
        List<ccrz__E_Invoice__c> parentInvoiceUpdateLst = new List<ccrz__E_Invoice__c>();
        for (ccrz__E_Invoice__c inv : newInvoices) {
            if (inv.ccrz__ParentInvoice__c != null && oldMap == null) {
                invoiceIds.add(inv.ccrz__ParentInvoice__c);
            } else if (oldMap != null) {
                if (inv.ccrz__ParentInvoice__c != null && inv.ccrz__ParentInvoice__c !=
                        oldMap.get(inv.Id).ccrz__ParentInvoice__c) {
                    invoiceIds.add(inv.ccrz__ParentInvoice__c);
                }
            }
        }
        parentInvoiceLst = [
                SELECT Id, Has_Child_Invoices__c
                FROM ccrz__E_Invoice__c
                WHERE Id IN:invoiceIds
                AND Has_Child_Invoices__c = FALSE
        ];
        if (parentInvoiceLst.size() > 0) {
            for (ccrz__E_Invoice__c pInv : parentInvoiceLst) {
                pInv.Has_Child_Invoices__c = true;
                parentInvoiceUpdateLst.add(pInv);
            }
        }
        try {
            if (parentInvoiceUpdateLst.size() > 0) {
                update parentInvoiceUpdateLst;
            }
        } catch (DmlException e) {
             //csa fix added exception logger statement. 
ACAMSUtil.reportException(null, null,'updateParentInvoiceIfChildInvoice Method', null, e.getMessage(), null, null);
        }
    }

    private Boolean updatedVertexFields(ccrz__E_Invoice__c oldInvoice, ccrz__E_Invoice__c newInvoice) {
        if (oldInvoice.ccrz__BillTo__c != newInvoice.ccrz__BillTo__c ||
                oldInvoice.ccrz__BillAddress__c != newInvoice.ccrz__BillAddress__c ||
                oldInvoice.ccrz__SoldAddress__c != newInvoice.ccrz__SoldAddress__c ||
                oldInvoice.Legal_Entity__c != newInvoice.Legal_Entity__c ||
             //   oldInvoice.Seller_Tax_Registration_ID__c != newInvoice.Seller_Tax_Registration_ID__c || //FSA-537 Mike suggested that CSR/Sales profile should be able to update this field
                oldInvoice.ccrz__DateIssued__c != newInvoice.ccrz__DateIssued__c ||
                oldInvoice.ccrz__OriginalAmount__c != newInvoice.ccrz__OriginalAmount__c) {
            return true;
        }
        return false;
    }

    // FSA-1093
    private void validateInvoiceOriginalAmount(){
        
        for (ccrz__E_Invoice__c invoice : newList) {
            if(invoice.ccrz__CCOrder__c != null){
                invoiceOrderMap.put(invoice.ccrz__CCOrder__c,invoice);//orderid, invoice 
            }
        }

        //build map for accessing CC Order
        List<ccrz__E_Order__c> orderList = ACAMSOrderDAO.getOrders(invoiceOrderMap.keySet());
        Map<Id,ccrz__E_Order__c> idOrderMap = new Map<Id,ccrz__E_Order__c>();

        for(ccrz__E_Order__c o : orderList){
            idOrderMap.put(o.Id, o);
        }

        if(invoiceOrderMap != null && invoiceOrderMap.size() > 0){
            for(Id orderId : invoiceOrderMap.keySet()){
                // get invoice by order Id
                // if invoice original amount is different than order ccrz__TotalAmount__c, copy
                if(invoiceOrderMap.get(orderId) != null && idOrderMap.get(orderId) != null && invoiceOrderMap.get(orderId).ccrz__OriginalAmount__c != idOrderMap.get(orderId).ccrz__TotalAmount__c && invoiceOrderMap.get(orderId).Finalized__c == false){
                    // get tax, product price value from CC Order
                    invoiceOrderMap.get(orderId).ccrz__OriginalAmount__c = idOrderMap.get(orderId).ccrz__TotalAmount__c;
                    invoiceOrderMap.get(orderId).ccrz__RemainingAmount__c = idOrderMap.get(orderId).ccrz__TotalAmount__c;
                          }
            }
        }        
    }
       private static void handleInvoiceUpdate(List<ccrz__E_Invoice__c	> invoices) {
        List<ccrz__E_Invoice__c	> invoicesToUpdate = new List<ccrz__E_Invoice__c	>();
        
        for(ccrz__E_Invoice__c	 invoice : invoices) {
            //system.debug('inside handleInvoiceUpdate'+invoice.ccrz__CCOrder__r.OwnerId);
            // Check if the Invoice needs to be updated
            if(invoice.ccrz__CCOrder__c != null && invoice.OwnerId != invoice.ccrz__CCOrder__r.OwnerId && invoice.Reassign_Owner__c == false) {
                invoice.OwnerId = invoice.ccrz__CCOrder__r.OwnerId;
               // invoicesToUpdate.add(invoice);
            }
        }
        
        
    }
}