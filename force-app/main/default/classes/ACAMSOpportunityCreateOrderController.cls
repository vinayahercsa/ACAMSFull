public with sharing class ACAMSOpportunityCreateOrderController {

    private static final String CART_STATUS_OPEN = 'Open';

    @TestVisible private static Id testOrderId;

    public Opportunity targetOpportunity { get; set; }
    public Id newOrderId { get; set; }
    public Boolean successful { get; set; }
    public Boolean renderOrdBtn { get; set; }

    public class ControllerException extends Exception {}

    public ACAMSOpportunityCreateOrderController(ApexPages.StandardController opportunityController) {
        renderOrdBtn = true;
        this.targetOpportunity = [
                SELECT
                        Id, Account.Name, ContactId, CC_Cart__c,
                        CC_Cart__r.ccrz__EncryptedId__c, CC_Cart__r.ccrz__CartStatus__c, CC_Cart__r.ccrz__TotalAmount__c,
                        CC_Cart__r.Id,CC_Cart__r.ccrz__BillTo__r.Vertex_Tax_Area_Id__c //FSA-496
                FROM Opportunity
                WHERE Id = :opportunityController.getId()
        ];
    }

    public PageReference createOrder() {
        ACAMSCsrService.initCsrCallContext(
                this.targetOpportunity.Account,
                this.targetOpportunity.CC_Cart__r.ccrz__EncryptedId__c,
                this.targetOpportunity.ContactId
        );
        Savepoint cartCloneSavepoint = Database.setSavepoint();
        this.successful = false;
        try {
            List<ccrz__E_Order__c> oppOrders = ACAMSOpportunityDAO.getOrdersWithOpportunities(new Set<Id>{
                    this.targetOpportunity.Id
            });
            List<ccrz__E_CartItem__c> cartItems = ACAMSCartDAO.getCartItemsByCartId(String.valueOf(this.targetOpportunity.CC_Cart__r.Id)); //FSA-496
            if (oppOrders.size() > 0) {
                showError('An order already exists for this Opportunity');
            } else if(this.targetOpportunity.CC_Cart__r.ccrz__BillTo__r.Vertex_Tax_Area_Id__c == null) { //FSA-496
              showError('Please validate the CC Contact Address and try again');  
            } else if(cartItems.size() == 0 || cartItems.isEmpty()) {
              showError('Please add CC Product before creating the Order');
            } //FSA-496
            else {
                if(cartItems.size() == 1){
                if(cartItems[0].ccrz__Quantity__c < 99){
                placeCart();
              }
                      else{
                  placeCartFuture(this.targetOpportunity.CC_Cart__r.id); 
               }
            }
                else if(cartItems.size() > 1){
                if(cartItems[0].ccrz__Quantity__c < 99 || cartItems[1].ccrz__Quantity__c < 99){
                placeCart();
              }
                      else{
                  placeCartFuture(this.targetOpportunity.CC_Cart__r.id); 
               }
            }
     
             
                this.successful = true;
            }
        } catch (Exception e) {
            Database.rollback(cartCloneSavepoint);
            showError(e.getMessage());
            showError(e.getStackTraceString());
        }
        return null;
    }

    public PageReference goToOpportunityPage() {
        return goToRecordPage(this.targetOpportunity.Id);
    }

    public PageReference goToOrderPage() {
        system.debug(this.newOrderId);
        if(this.newOrderId != null){
        return goToRecordPage(this.newOrderId);
        }
        else{
            renderOrdBtn = false;
            showWarning('As the number of products are greater than 99 please return to opportunity and wait 1-2 minutes for the order to be created and 2-3 minutes for the assets to be generated.');
            return null;
        }
    }


    private PageReference goToRecordPage(Id recordId) {
        PageReference recordLink = new PageReference('/' + recordId);
        recordLink.setRedirect(true);
        return recordLink;
    }

    private void showError(String errorMessage) {
        ApexPages.addMessage(
                new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage)
        );
    }
        private void showWarning(String errorMessage) {
        ApexPages.addMessage(
                new ApexPages.Message(ApexPages.Severity.WARNING, errorMessage)
        );
    }

    private static void updateOrderOpportunityLookup(Id orderId, Id opportunityId) {
        update new ccrz__E_Order__c (
                Id = orderId,
                Opportunity__c = opportunityId
        );
    }

    private static void updateOpportunity(Id opportunityId) {
        update new Opportunity(
                Id = opportunityId,
                Invoice_Date__c = Date.today()
        );
    }
@TestVisible //added chinna 954
    private void placeCart() {
        ccrz__E_Cart__c cart = this.targetOpportunity.CC_Cart__r;
        reopenCartIfRequired(cart);
        Map<String, Object> cartPlaceInputData = new Map<String, Object>{
                ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                ccrz.ccApiCart.CART_ENCID => cart.ccrz__EncryptedId__c,
                ccrz.ccApiCart.CARTSTATUS => cart.ccrz__CartStatus__c,
                ccrz.ccApiCart.SKIP_VALID_CHECK => true
        };
        Map<String, Object> outputData = new Map<String, Object>();
        if (Test.isRunningTest()) {
            outputData = new Map<String, Object>{
                    ccrz.ccApi.SUCCESS => true,
                    ccrz.ccApiCart.ORDER_ID => ACAMSOpportunityCreateOrderController.testOrderId
            };
        } else {
            outputData = ccrz.ccApiCart.place(cartPlaceInputData);
        }
        Boolean success = (Boolean) outputData.get(ccrz.ccApi.SUCCESS);
        if (success) {
            String orderId = (String) outputData.get(ccrz.ccApiCart.ORDER_ID);
            this.newOrderId = Id.valueOf(orderId);
            Id profileId = UserInfo.getProfileId();
            String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
             system.debug('=>Aditya<=' +this.newOrderId);
            ccrz__E_Order__c ord = [SELECT Id,ccrz__PaymentMethod__c,Paid_in_Full_Date__c,ccrz__Account__c,ccrz__User__c,Account_Owner__c,ccrz__Contact__c,LastModifiedBy.name,ccrz__OrderDate__c,ccrz__TotalAmount__c,CreatedBy.name,ccrz__OrderStatus__c FROM ccrz__E_Order__c Where Id =: this.newOrderId];
            if(ord.ccrz__TotalAmount__c < 1){
                //ord.createdBy.Name != 'Drupal Integration' && ord.LastModifiedBy.name != 'Drupal Integration' && (&& (profileName  == 'ACAMS - Customer Service' || profileName  == 'ACAMS - Operations' || profileName  == 'System Administrator' || profileName  == 'ACAMS - Sales' )
                //above condition Commented by Chandra for FSA-5411
                ord.ccrz__PaymentMethod__c = 'Zero Dollar';
                ord.Paid_in_Full_Date__c = ord.ccrz__OrderDate__c;
                ord.ccrz__OrderStatus__c = 'Completed';
                update ord;
                ccrz__E_TransactionPayment__c ccrPayment = new ccrz__E_TransactionPayment__c();
                ccrPayment.ccrz__AccountType__c = 'zero_dollar';
                ccrPayment.ccrz__Amount__c = ord.ccrz__TotalAmount__c;
                ccrPayment.ccrz__RequestAmount__c = ord.ccrz__TotalAmount__c;
                ccrPayment.ccrz__CurrencyISOCode__c = 'USD';
                ccrPayment.ccrz__TransactionType__c = 'capture';
                ccrPayment.ccrz__PaymentType__c = 'zero_dollar';
                ccrPayment.ccrz__Storefront__c = 'acams';
                ccrPayment.ccrz__SoldTo__c = ord.ccrz__Account__c;
                ccrPayment.ccrz__BillTo__c = ord.ccrz__Account__c;
                ccrPayment.ccrz__Account__c = ord.ccrz__Account__c;
                ccrPayment.ccrz__Contact__c = ord.ccrz__Contact__c;
                ccrPayment.ccrz__User__c = ord.ccrz__User__c;
                //ccrPayment.ccrz__CCOrder__c = ord.Id;
                //ccrPayment.ccrz__TransactionTS__c =ord.Paid_in_Full_Date__c;
                if(test.isRunningTest()){// chandra commented FSA-5411 insert causing duplicate payment record
                insert ccrPayment; 
                }
                ACAMSZeroDollarTransaction.updateCCTransactionPayments(ccrPayment.Id, ord.Id);
                
            }

            updateOrderOpportunityLookup(this.newOrderId, this.targetOpportunity.Id);
            updateOpportunity(this.targetOpportunity.Id);
        } else {
            throw new ControllerException(Label.Opportunity_OrderCreationError);
        }
    }
    //added chinna-fsa 954
@TestVisible 
    private void reopenCartIfRequired(ccrz__E_Cart__c cart) {
        if (cart.ccrz__CartStatus__c == null || cart.ccrz__CartStatus__c != CART_STATUS_OPEN) {
            ccrz__E_Cart__c cartToUpdate = new ccrz__E_Cart__c (
                    Id = cart.Id,
                    ccrz__CartStatus__c = CART_STATUS_OPEN
            );
            update cartToUpdate;
        }
    }
    
    @future
    public static void placeCartFuture(ID cartid) {
        ccrz__E_Cart__c cart = [select ccrz__EncryptedId__c, Opportunity__c ,ccrz__CartStatus__c from ccrz__E_Cart__c where id=:cartid];
        Map<String, Object> cartPlaceInputData = new Map<String, Object>{
                ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                ccrz.ccApiCart.CART_ENCID => cart.ccrz__EncryptedId__c,
                ccrz.ccApiCart.CARTSTATUS => cart.ccrz__CartStatus__c,
                ccrz.ccApiCart.SKIP_VALID_CHECK => true
        };
        Map<String, Object> outputData = new Map<String, Object>();
        if (Test.isRunningTest()) {
            outputData = new Map<String, Object>{
                    ccrz.ccApi.SUCCESS => true,
                    ccrz.ccApiCart.ORDER_ID => ACAMSOpportunityCreateOrderController.testOrderId
            };
        } else {
            outputData = ccrz.ccApiCart.place(cartPlaceInputData);
        }
            String orderId = (String) outputData.get(ccrz.ccApiCart.ORDER_ID);
            ID newOrderId = Id.valueOf(orderId);
            updateOrderOpportunityLookup(newOrderId, cart.Opportunity__c);
            updateOpportunity(cart.Opportunity__c);
    }
}