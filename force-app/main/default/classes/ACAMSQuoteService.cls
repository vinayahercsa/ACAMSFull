public without sharing class ACAMSQuoteService {

    public static Boolean cloneCartToQuote(Quote targetQuote, Id cartId) {
        Savepoint cartCloneSavepoint = Database.setSavepoint();
        Boolean wasSuccessful = false;
        try{
            Map<String, Object> inputData = new Map<String,Object> {
                ccrz.ccApiCart.CART_ID => cartId,
                ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                ccrz.ccAPI.SIZING => new Map<String, Object>{
                    ccrz.ccAPICart.ENTITYNAME => new Map<String, Object>{
                        ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_XL
                    },
                    ccrz.ccAPICart.CLI_ENTITYNAME => new Map<String, Object>{
                        ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_XL
                    }
                }
            };
            Map<String, Object> outputData = ccrz.ccAPICart.cloneCart(inputData);
            wasSuccessful = (Boolean)outputData.get(ccrz.ccApi.SUCCESS);
            if (wasSuccessful) {
                Id newCartId = (Id) outputData.get(ccrz.ccApiCart.CART_ID);
                Map<String, Object> outputPricingData = ccrz.ccAPICart.price(new Map<String, Object> {
                    ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                    ccrz.ccApiCart.CART_ID => newCartId
                });
                wasSuccessful = (Boolean) outputPricingData.get(ccrz.ccApi.SUCCESS);
                if (!wasSuccessful) {
                    System.debug(LoggingLevel.ERROR, outputPricingData);
                }
                Quote updatedQuote = new Quote();
                updatedQuote.CC_Cart__c = newCartId;
                updatedQuote.Id = targetQuote.Id;
                update updatedQuote;
            }
        } catch (Exception e) {
            Database.rollback(cartCloneSavepoint);
            return false;
        }
        return wasSuccessful;
    }

    public static void updateNewCartItemsQuoteLookup(List<Quote> newList, Map<Id, Quote> oldMap) {
        QuoteCartLookupData quoteData = getQuoteCartLookupData(newList, oldMap);
        List<ccrz__E_CartItem__c> cartItemsToCheck = queryCartItemsByCartIds(quoteData);
        List<ccrz__E_CartItem__c> cartItemsToUpdate = setQuoteLookup(cartItemsToCheck, quoteData);
        if (!cartItemsToUpdate.isEmpty()) {
            update cartItemsToUpdate;
        }
    }

    private class QuoteCartLookupData {
        public Map<Id, Id> quoteIdByNewCartId;
        public Map<Id, Id> quoteIdByOldCartId;
        public Set<Id> quotesWithEmptyCart;
        public QuoteCartLookupData() {
            this.quoteIdByNewCartId = new Map<Id, Id>();
            this.quoteIdByOldCartId = new Map<Id, Id>();
            this.quotesWithEmptyCart = new Set<Id>();
        }
    }

    private static QuoteCartLookupData getQuoteCartLookupData(List<Quote> newList, Map<Id, Quote> oldMap) {
        QuoteCartLookupData data = new QuoteCartLookupData();
        for (Quote currentQuote : newList) {
            Quote oldQuote = oldMap.get(currentQuote.Id);
            if (quoteCartLookupChanged(currentQuote, oldQuote)) {
                data.quoteIdByNewCartId.put(currentQuote.CC_Cart__c, currentQuote.Id);
                data.quoteIdByOldCartId.put(oldQuote.CC_Cart__c, currentQuote.Id);
            }
        }
        return data;
    }

    private static Boolean quoteCartLookupChanged(Quote currentQuote, Quote oldQuote) {
        return currentQuote.CC_Cart__c != oldQuote.CC_Cart__c;
    }

    private static List<ccrz__E_CartItem__c> queryCartItemsByCartIds(QuoteCartLookupData quoteCartData) {
        List<ccrz__E_CartItem__c> cartItems = [
            SELECT ccrz__Cart__c, Quote__c
            FROM ccrz__E_CartItem__c
            WHERE
                ccrz__ParentCartItem__c = NULL AND
                (
                    ccrz__Cart__c IN :quoteCartData.quoteIdByNewCartId.keySet() OR
                    ccrz__Cart__c IN :quoteCartData.quoteIdByOldCartId.keySet()
                )
        ];
        return cartItems;
    }

    private static List<ccrz__E_CartItem__c> setQuoteLookup(
        List<ccrz__E_CartItem__c> cartItemsToCheck,
        QuoteCartLookupData quoteData
    ) {
        List<ccrz__E_CartItem__c> cartItemsToUpdate = new List<ccrz__E_CartItem__c>();
        for (ccrz__E_CartItem__c cartItemToCheck : cartItemsToCheck) {
            Id newQuoteId = quoteData.quoteIdByNewCartId.get(cartItemToCheck.ccrz__Cart__c);
            if (cartItemToCheck.Quote__c != newQuoteId) {
                cartItemToCheck.Quote__c = newQuoteId;
                cartItemsToUpdate.add(cartItemToCheck);
            }
        }
        return cartItemsToUpdate;
    }

}