public without sharing class ACAMSOpportunityTriggerHandler extends CCAviTriggerHandler {

    public static Boolean skipCartAssignOnQuoteSync = false;
    public static Boolean skipCartCreationOnInsert = false;    
    private static Boolean updateOwnerIdOppExecuted = false;
    // vara added 
    public static Boolean isRecursiveCheckFlag = true;

    private List<Opportunity> newList;
    private List<Opportunity> oldList;
    private Map<Id, Opportunity> newMap;
    private Map<Id, Opportunity> oldMap;

    public ACAMSOpportunityTriggerHandler() {
        super();
        this.newList = (List<Opportunity>) Trigger.new;
        this.oldList = (List<Opportunity>) Trigger.old;
        this.newMap = (Map<Id, Opportunity>) Trigger.newMap;
        this.oldMap = (Map<Id, Opportunity>) Trigger.oldMap;
    }
    
    //code optimization 1469 , vara added 
    public static boolean isRecursiveCheck(){
        if(isRecursiveCheckFlag){
            isRecursiveCheckFlag =false;
            return true;
        } else {
            return isRecursiveCheckFlag;
        }
    }

    protected override void beforeUpdate() {
        List<ccrz__E_Order__c> orders = ACAMSOpportunityDAO.getOrdersWithOpportunities(newMap.keySet());
        // vara added - code optimization 1469 recordtype schema
        if (!orders.isEmpty()) {
            Map<Id, Boolean> oppHasOrderMap = new Map<Id, Boolean>();
            for (ccrz__E_Order__c order : orders) {
                oppHasOrderMap.put(order.Opportunity__c, true);
            }
            if (!oppHasOrderMap.isEmpty() && Schema.SObjectType.opportunity.getRecordTypeInfosByDeveloperName().get('Read_Only').getRecordTypeId() != null) {
                for (Opportunity opp : newList) {
                    if (oppHasOrderMap.get(opp.Id)) {
                   //     opp.RecordTypeId = Schema.SObjectType.opportunity.getRecordTypeInfosByDeveloperName().get('Read_Only').getRecordTypeId();
                    }
                }
            }
        }
    }
    protected override void beforeInsert(){
        // vara added 1469, code optimization
        if(isRecursiveCheck()){
            updateOpptyChannel();
        }
    }
    protected override void afterInsert() {
        createCartOnInsert();
        syncContact();
        UpdateOrderChannel();
        //csa fix
        //PopulateAccountGlobalManager(newList);
    }

    protected override void afterUpdate() {
        updateCartLookupOnSync();
        syncContact();
        updateCoupons();
        autoCreateOrder();
       UpdateOrderChannel();
        if (!updateOwnerIdOppExecuted) {
            updateOwnerIdOpp(newList, oldMap);
        }

        Set<Id> oppIdsForStatus = new Set<Id>();
        for (Id oppId : oldMap.keySet()) {
            String oldOppStatus = oldMap.get(oppId).StageName;
            String newOppStatus = newMap.get(oppId).StageName;

            if (oldOppStatus != null && !oldOppStatus.equalsIgnoreCase('Closed Lost') && newOppStatus != null && newOppStatus.equalsIgnoreCase('Closed Lost')) {
                oppIdsForStatus.add(oppId);
            } else if (oldOppStatus != null && !oldOppStatus.equalsIgnoreCase(ACAMSUtil.CANCELLED) && newOppStatus != null && newOppStatus.equalsIgnoreCase(ACAMSUtil.CANCELLED)) {
                oppIdsForStatus.add(oppId);
            }
        }

        List<ccrz__E_Order__c> ordersToUpdate = new List<ccrz__E_Order__c>();
        List<ccrz__E_Invoice__c> invoicesToUpdate = new List<ccrz__E_Invoice__c>();
        if (!oppIdsForStatus.isEmpty()) {
            List<ccrz__E_Order__c> orders = [
                    SELECT
                            Id,
                            ccrz__OrderStatus__c
                    FROM
                            ccrz__E_Order__c
                    WHERE
                            Opportunity__c
                                    IN
                                            :oppIdsForStatus
            ];

            for (ccrz__E_Order__c order : orders) {
                if (!order.ccrz__OrderStatus__c.equalsIgnoreCase(ACAMSUtil.CANCELLED) &&
                        !order.ccrz__OrderStatus__c.equalsIgnoreCase(ACAMSUtil.REFUNDED) &&
                        !order.ccrz__OrderStatus__c.equalsIgnoreCase(ACAMSUtil.ORDER_STATUS_REFUNDED_CREDIT)) {
                    order.ccrz__OrderStatus__c = ACAMSUtil.CANCELLED;
                    ordersToUpdate.add(order);
                }
            }

            List<ccrz__E_Invoice__c> invoices = [
                    SELECT
                            Id,
                            Invoice_Status__c
                    FROM
                            ccrz__E_Invoice__c
                    WHERE
                            OpportunityId__c
                                    IN
                                            :oppIdsForStatus
            ];

            for (ccrz__E_Invoice__c invoice : invoices) {
                invoice.Invoice_Status__c = ACAMSUtil.CANCELLED;
                invoice.Refund_Date__c = Date.today();
                invoicesToUpdate.add(invoice);
            }
        }

        update ordersToUpdate;
        update invoicesToUpdate;


    }
    //csa fix
    public static void PopulateAccountGlobalManager(List<Order_Created__e> orderCreatedEvents){
        
        
    } 
    
    private void syncContact() {
            List<Opportunity> opportunities = new List<opportunity>();
            if(!newMap.isEmpty())
                opportunities = [SELECT Id, AccountId, Account.IsPersonAccount, Account.PersonContactId, Contact__c, CC_Cart__c, CC_Cart__r.ccrz__Contact__c, CC_Cart__r.ccrz__Account__c FROM Opportunity WHERE Id IN :newMap.keySet()];
            List<Opportunity> oppsToUpdate = new List<Opportunity>();
            List<ccrz__E_Cart__c> cartsToUpdate = new List<ccrz__E_Cart__c>();
            if(opportunities.size() > 0)
            for (Opportunity opp : opportunities) {
                if (opp.Account.IsPersonAccount && opp.Contact__c == null) {
                    opp.Contact__c = opp.Account.PersonContactId;
                    oppsToUpdate.add(opp);
                    opp.CC_Cart__r.ccrz__Contact__c = opp.Account.PersonContactId;
                    opp.CC_Cart__r.ccrz__Account__c = opp.AccountId;
                    cartsToUpdate.add(opp.CC_Cart__r);
                }
            }
            if(oppsToUpdate.size() > 0){
                try{
                    update oppsToUpdate;
                }catch(Exception ex){
                    ACAMSUtil.reportException(null, null,'syncContact Method', null, ex.getMessage(), null, null);
                }
            }
                
            if(cartsToUpdate.size() > 0){
                try{
                    update cartsToUpdate;
                }catch(Exception ex){
                    ACAMSUtil.reportException(null, null,'syncContact Method', null, ex.getMessage(), null, null);
                } 
            }
                
    }

    private void updateCoupons() {
        for (Opportunity opportunity : newList) {
            if (opportunity.SyncedQuoteId == null && oldMap.get(opportunity.Id).Coupon_Code__c != opportunity.Coupon_Code__c) {
                Savepoint sp = Database.setSavepoint();
                try {
                    Map<String, Object> cartParams = new Map<String, Object>{
                            ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                            ACAMSLogicCartAddTo.PARAM_SKIP_CART_ACTIVE_SEARCH_FLOW => true,
                            ccrz.ccApiCart.CART_ID => opportunity.CC_Cart__c,
                            ccrz.ccApiCart.COUPON_CODE => opportunity.Coupon_Code__c
                    };
                    if (opportunity.Coupon_Code__c != null) {
                        Map<String, Object> response = ccrz.ccApiCart.addTo(cartParams);
                        Boolean isSuccess = (Boolean) response.get(ccrz.ccApi.SUCCESS);
                        if (!isSuccess) {
                            opportunity.addError('The coupon code "' + opportunity.Coupon_Code__c + '" could not be added because its invalid or the cart does not meet the requirements.');
                            Database.rollback(sp);
                        }
                    } else {
                        if (oldMap.get(opportunity.Id).Coupon_Code__c != null) {
                            cartParams.put(ccrz.ccApiCart.COUPON_CODE, oldMap.get(opportunity.Id).Coupon_Code__c);
                            Map<String, Object> response = ccrz.ccApiCart.removeFrom(cartParams);
                            Boolean isSuccess = (Boolean) response.get(ccrz.ccApi.SUCCESS);
                            if (!isSuccess) {
                                opportunity.addError('The coupon code "' + opportunity.Coupon_Code__c + '" could not be removed.');
                                Database.rollback(sp);
                            }
                        }
                    }
                } catch (Exception e) {
                                   //csa fix added exception logger statement. 
                    ACAMSUtil.reportException(null, null,'updateCoupons Method', null, e.getMessage(), null, null);
                }
            }
        }
    }

    private void updateCartLookupOnSync() {
        if (!skipCartAssignOnQuoteSync) {

            Opportunity opportunityToCheckSync = this.newList[0];
            Opportunity oldOpportunityToCheckSync = this.oldMap.get(opportunityToCheckSync.Id);
            Boolean wasSuccessful = true;

            if (opportunityStartedSync(opportunityToCheckSync, oldOpportunityToCheckSync)) {
                wasSuccessful = ACAMSOpportunityService.replaceOpportunityCartWithQuoteCart(
                        opportunityToCheckSync,
                        opportunityToCheckSync.SyncedQuoteCartId__c
                );
            } else if (opportunityFinishedSync(opportunityToCheckSync, oldOpportunityToCheckSync)) {
                wasSuccessful = ACAMSOpportunityService.cloneCartToOpportunity(
                        opportunityToCheckSync,
                        opportunityToCheckSync.CC_Cart__c
                );
            }
            if (!wasSuccessful) {
                opportunityToCheckSync.addError(Label.QuoteSync_ErrorMessage);
            }
        }
    }

    private void createCartOnInsert() {
        if (!skipCartCreationOnInsert) {
            for (Opportunity opportunityToCreateCart : this.newList) {
                Savepoint sp = Database.setSavepoint();
                Boolean wasSuccessful = ACAMSOpportunityService.createNewCartForOpportunity(opportunityToCreateCart);
                if (!wasSuccessful) {
                    Database.rollback(sp);
                    opportunityToCreateCart.addError(Label.Opportunity_OpportunityCreationError);
                    break;
                }
            }
        }
    }

    private Boolean opportunityStartedSync(Opportunity currentOpportunity, Opportunity oldOpportunity) {
        return oldOpportunity.SyncedQuoteId == null && currentOpportunity.SyncedQuoteId != null;
    }

    private Boolean opportunityFinishedSync(Opportunity currentOpportunity, Opportunity oldOpportunity) {
        return oldOpportunity.SyncedQuoteId != null && currentOpportunity.SyncedQuoteId == null;
    }

    private void autoCreateOrder() {
        for (Opportunity opp : newList) {
            if (opp.Auto_Create_Order__c == true && oldMap.get(opp.Id).Auto_Create_Order__c == false) {
                ApexPages.StandardController opportunityController = new ApexPages.StandardController(opp);
                ACAMSOpportunityCreateOrderController controller = new ACAMSOpportunityCreateOrderController(
                        opportunityController
                );
                controller.createOrder();
            }
        }
    }

    private void updateOwnerIdOpp(List<Opportunity> newOpps, Map<Id, Opportunity> oldOppMap) {
        Map<Id, opportunity> oppIdMap = new Map<Id, opportunity>();
        List<ccrz__E_Order__c> orderLst = new List<ccrz__E_Order__c>();
        List<ccrz__E_Order__c> orderLstUpdate = new List<ccrz__E_Order__c>();
        List<ccrz__E_Cart__c> cartLst = new List<ccrz__E_Cart__c>();
        List<ccrz__E_Cart__c> cartLstUpdate = new List<ccrz__E_Cart__c>();
        Set<ID> ordIdSet = new Set<ID>();
        List<ccrz__E_Invoice__c> invLst = new List<ccrz__E_Invoice__c>();
        List<ccrz__E_Invoice__c> invLstUpdate = new List<ccrz__E_Invoice__c>();
        for (Opportunity opp : newOpps) {
            if (opp.OwnerId != oldOppMap.get(opp.id).OwnerId) {
                oppIdMap.put(opp.id, opp);
            }
        }
        Try {
            orderLst = [select id, ownerid, Reassign_Owner__c, opportunity__r.ownerid from ccrz__E_Order__c where opportunity__c IN:oppIdMap.keyset()];
            for (ccrz__E_Order__c ord : orderLst) {
                 ordIdSet.add(ord.id);
                if (ord.ownerid != ord.opportunity__r.ownerid) {
                      if(ord.Reassign_Owner__c == false){ // fsa-6330 - chandra
                    ord.ownerid = ord.opportunity__r.ownerid;
                    orderLstUpdate.add(ord);
                      }
                   
                }
            }
            if (orderLstUpdate.size() > 0) {
                try{
                    update orderLstUpdate;
                }catch(Exception ex){
                    ACAMSUtil.reportException(null, null,'updateOwnerIdOpp Method', null, ex.getMessage(), null, null);
                } 
            }
            invLst = [select id, ownerid, ccrz__CCOrder__r.ownerid, Reassign_Owner__c from ccrz__E_Invoice__c where ccrz__CCOrder__c IN:ordIdSet];
            for (ccrz__E_Invoice__c inv : invLst) {
                if (inv.ownerid != inv.ccrz__CCOrder__r.ownerid) {
                       if(inv.Reassign_Owner__c == false){ // fsa-6330 - chandra
                    inv.ownerid = inv.ccrz__CCOrder__r.ownerid;
                    invLstUpdate.add(inv);
                       }
                   
                }

            }
            if (invLstUpdate.size() > 0) {
                try{
                    update invLstUpdate;
                }catch(Exception ex){
                    ACAMSUtil.reportException(null, null,'updateOwnerIdOpp Method', null, ex.getMessage(), null, null);
                } 
            }
            // vara added code optimization 
            if(!oppIdMap.isEmpty())
            cartLst = [select id, name, ownerid, Opportunity__r.ownerid from ccrz__E_Cart__c where Opportunity__c IN:oppIdMap.keyset()];
            for (ccrz__E_Cart__c crt : cartLst) {
                if (crt.ownerid != crt.opportunity__r.ownerid) {
                    crt.ownerid = crt.opportunity__r.ownerid;
                    cartLstUpdate.add(crt);
                }

            }
            if (cartLstUpdate.size() > 0) {
                try{
                    update cartLstUpdate;
                }catch(Exception ex){
                    ACAMSUtil.reportException(null, null,'updateOwnerIdOpp Method', null, ex.getMessage(), null, null);
                }
            }
        } catch (DmlException e) {
                           //csa fix added exception logger statement. 
			ACAMSUtil.reportException(null, null,'updateOwnerIdOpp Method', null, e.getMessage(), null, null);
        }
        updateOwnerIdOppExecuted = true;

    }
    public void updateOpptyChannel(){
        List<string> lstOfProfileNames = New List<String>();
        for(User u : [SELECT Id,profile.name FROM User where Id =: UserInfo.getUserId()]){
          if((u.profile.name == 'ACAMS - Sales' || u.profile.name == 'ACAMS - Sales Operations' )|| (u.profile.name == 'ACAMS - Customer Service' || u.profile.name == 'ACAMS - Operations') ){ //Fsa-5537 realed profils added 
                   
            lstOfProfileNames.add(u.profile.name);
            }
        }
        for(Opportunity op : newlist){
           if(lstOfProfileNames.contains('ACAMS - Sales') || lstOfProfileNames.contains('ACAMS - Sales Operations')  ){ // Fsa-5537
                    op.Channel__c = 'Sales';
                }
                    else if(lstOfProfileNames.contains('ACAMS - Customer Service') || lstOfProfileNames.contains('ACAMS - Operations')){// Fsa-5537
                    op.Channel__c = 'Customer Service';
                }
                else{
                    op.Channel__c = 'Other';//Fsa-5537
                }
           // }
            
        }
    } 
    
    public void UpdateOrderChannel (){
            set<id> opptyId = new set<id>();
            for(opportunity op : newlist){
                opptyId.add(op.id);               
            }
            list<ccrz__E_Order__c> ccorderlst = new list<ccrz__E_Order__c>();
            list<ccrz__E_Order__c> ccorderslst = new list<ccrz__E_Order__c>();
            // vara added code optimization 1469  
            if(!opptyId.isEmpty())
                ccorderslst = [SELECT Id, Name, Channel__c, Opportunity__c,Opportunity__r.Channel__c FROM ccrz__E_Order__c  WHERE Opportunity__r.Id IN : opptyId];
            if(ccorderslst.size() > 0)
            for(ccrz__E_Order__c ccorder : ccorderslst){        
                if(ccorder.Opportunity__r.Channel__c == 'Sales'){
                    ccorder.Channel__c = 'Sales';
                    
                }
                else if(ccorder.Opportunity__r.Channel__c  == 'Customer Service'){
                ccorder.Channel__c = 'Customer Service';
                }
                else if (ccorder.Opportunity__c == null && ccorder.ccrz__BuyerEmail__c != null &&
                        (!ccorder.ccrz__BuyerEmail__c.equals(ccorder.Purchaser_Email__c))) {
                    ccorder.Channel__c = 'Web Assisted';
                        }
                else if(ccorder.Opportunity__r.Channel__c == Null || ccorder.Opportunity__c == null){
                ccorder.Channel__c = 'Web Order';
                }
            else if(ccorder.Opportunity__r.Channel__c  == 'Other'){
                    ccorder.Channel__c = 'Other'; //Fsa-5537
                }
                
                ccorderlst.add(ccorder); 
            }  
            if(!ccorderlst.isEmpty()){
                try{
                    update ccorderlst;
                }catch(Exception ex){
                    ACAMSUtil.reportException(null, null,'UpdateOrderChannel Method', null, ex.getMessage(), null, null);
                }
            }
    } 
}