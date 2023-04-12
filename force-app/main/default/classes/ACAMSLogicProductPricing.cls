global with sharing class ACAMSLogicProductPricing extends ccrz.ccLogicProductPricing {

    /**
     * CloudCraze has a bug where it returns the price based on the autonumber. This reorders the priceListItems in
     * ascending order by price so that the lowest price available to the user is returned.
     */
    global virtual override Map<String, Object> evaluateSubProdTermPricing(Map<String, Object> inputData) {
        List<Map<String, Object>> priceListItems = (List<Map<String, Object>>) inputData.get('priceListItems');
        List<Map<String, Object>> newPriceListItems = new List<Map<String, Object>>();
        Map<String, Decimal> priceMap = new Map<String, Decimal>();
        Map<String, Map<String, Object>> priceListItemsMap = new Map<String, Map<String, Object>>();
        system.debug('priceListItems::'+priceListItems);
        system.debug('priceListItems[0]::'+priceListItems[0]);
        for (Map<String, Object> priceListItem : priceListItems) {
            String sfid = (String) priceListItem.get('sfid');
            priceMap.put(sfid, (Decimal) priceListItem.get('price'));
            priceListItemsMap.put(sfid, priceListItem);
        }
        List<Decimal> prices = priceMap.values();
        prices.sort();
        List<String> capturedIds = new List<String>();
    //FSA-1029/834/1490
    Map<String, Boolean> priceListItemsBysubProd = new Map<String, Boolean>();
    for(ccrz__E_PriceListItem__c plt : ACAMSPriceListDAO.getPriceListItemsForSubProdId(priceMap.keySet())) {
      priceListItemsBysubProd.put((String) plt.Id, plt.ccrz__SubProdTerm__r.Avoid_from_Price_List__c);
    }
    system.debug('priceListItemsBysubProd::'+priceListItemsBysubProd);
    //FSA-1029/834/1490
        for (Decimal price : prices) {
            for (String sfid : priceMap.keySet()) {
                if (!capturedIds.contains(sfid)) {
                    Decimal mapPrice = priceMap.get(sfid);
                    if (price == mapPrice /*&& price != 0*/) { //FSA-1029/834/1490
                      //FSA-1029/834/1490
                      system.debug('priceListItemsBysubProd.get(sfid)::'+priceListItemsBysubProd.get(sfid)+'price::'+price);
                      if(priceListItemsBysubProd.get(sfid) != null && priceListItemsBysubProd.get(sfid) ){
                        system.debug('In');
                      } 
                      else{ //FSA-1029/834/1490
                        newPriceListItems.add(priceListItemsMap.get(sfid));
                        capturedIds.add(sfid);
                      }
                    }
                }
            }
        }
        inputData.put('priceListItems', newPriceListItems);
        Map<String, Object> outputData = super.evaluateSubProdTermPricing(inputData);
        return outputData;
    }
}