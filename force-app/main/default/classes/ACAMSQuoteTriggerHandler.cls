public without sharing class ACAMSQuoteTriggerHandler extends CCAviTriggerHandler {

    private List<Quote> newList;
    private List<Quote> oldList;
    private Map<Id, Quote> newMap;
    private Map<Id, Quote> oldMap;
    private List<Quote> quotes = new List<Quote>();

    public static Boolean skipCartCloneOnCreate = false;

    public ACAMSQuoteTriggerHandler() {
        super();
        this.newList = (List<Quote>) Trigger.new;
        this.oldList = (List<Quote>) Trigger.old;
        this.newMap = (Map<Id, Quote>) Trigger.newMap;
        this.oldMap = (Map<Id, Quote>) Trigger.oldMap;
    }

    protected override void beforeUpdate() {
    }

    protected override void afterInsert() {
        createCartOnCreate();
    }

    protected override void afterUpdate() {
        ACAMSQuoteService.updateNewCartItemsQuoteLookup(newList, oldMap);

        quotes = [SELECT Id, Version__c, CC_Cart__c, OpportunityId, Coupon_Code__c FROM Quote WHERE Id IN :newMap.keySet()];
        List<QuoteDocument> quoteDocs = [SELECT Id, QuoteId FROM QuoteDocument WHERE QuoteId IN :newMap.keySet()];
        updateQuotes(quoteDocs, quotes);
        updateCoupons(newList);
    }

    private void createCartOnCreate() {
        Quote quoteToCloneCart = this.newList[0];
        Id cartToCloneId = (Id) quoteToCloneCart.OpportunityCartId__c;
        if (!skipCartCloneOnCreate && cartToCloneId != null) {
            ACAMSQuoteService.cloneCartToQuote(quoteToCloneCart, (Id) quoteToCloneCart.OpportunityCartId__c);
        }
    }

    private void updateQuotes(List<QuoteDocument> quoteDocs, List<Quote> quotes) {
        Map<String, Integer> quoteDocMap = new Map<String, Integer>();
        for (Quote q : newList) {
            Integer count = 0;
            for (QuoteDocument qd : quoteDocs) {
                if (q.Id == qd.QuoteId) {
                    count++;
                }
            }
            quoteDocMap.put(q.Id, count);
        }

        Boolean updateBool = false;
        for (Quote quote : quotes) {
            if (quote.Version__c != quoteDocMap.get(quote.Id) + 1) {
                quote.Version__c = quoteDocMap.get(quote.Id) + 1;
                updateBool = true;
            }
        }

        if (updateBool) {
            update quotes;
        }
    }

    private void updateCoupons(List<Quote> quotes) {
        List<Id> oppIdsFromQuotes = new List<Id>();
        for (Quote q : quotes) {
            oppIdsFromQuotes.add(q.OpportunityId);
        }

        List<Opportunity> opps = [SELECT Id, Coupon_Code__c FROM Opportunity WHERE Id IN :oppIdsFromQuotes AND SyncedQuoteId != NULL];
        Map<String, Opportunity> idToOppMap = new Map<String, Opportunity>();

        for (Opportunity opp : opps) {
            idToOppMap.put(opp.Id, opp);
        }

        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        for (Quote q : quotes) {
            Opportunity opp = idToOppMap.get(q.OpportunityId);
            if (opp != null && q.Coupon_Code__c != opp.Coupon_Code__c) {
                opp.Coupon_Code__c = q.Coupon_Code__c;
                oppsToUpdate.add(opp);
            }
            if (oldMap.get(q.Id).Coupon_Code__c != q.Coupon_Code__c) {
                Savepoint sp = Database.setSavepoint();
                try {
                    Map<String, Object> cartParams = new Map<String, Object>{
                            ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                            ACAMSLogicCartAddTo.PARAM_SKIP_CART_ACTIVE_SEARCH_FLOW => true,
                            ccrz.ccApiCart.CART_ID => q.CC_Cart__c,
                            ccrz.ccApiCart.COUPON_CODE => q.Coupon_Code__c
                    };
                    if (q.Coupon_Code__c != null) {
                        Map<String, Object> response = ccrz.ccApiCart.addTo(cartParams);
                        Boolean isSuccess = (Boolean) response.get(ccrz.ccApi.SUCCESS);
                        if (!isSuccess) {
                            q.addError('The coupon code "' + q.Coupon_Code__c + '" could not be added because its invalid or the cart does not meet the requirements.');
                            Database.rollback(sp);
                        }
                    } else {
                        if (oldMap.get(q.Id).Coupon_Code__c != null) {
                            cartParams.put(ccrz.ccApiCart.COUPON_CODE, oldMap.get(q.Id).Coupon_Code__c);
                            ccrz.ccApiCart.removeFrom(cartParams);
                        }
                    }
                } catch (Exception e) {
                    System.debug('Error in ACAMSQuoteTriggerHandler: ' + e.getMessage());
                }
            }
        }
        if (!oppsToUpdate.isEmpty()) {
            update oppsToUpdate;
        }


    }

}