@RestResource(UrlMapping='/api/product/pricing/tiers')
global with sharing class ACAMSProductPricingTiers {

    @HttpPost
    global static ProductPricingTiersResponse getProductPricingTiers(String accountId, String productId, String currencyCode) {
        if (accountId == null) {
            accountId = [SELECT Id FROM Account WHERE Name = 'CCAnonymous' LIMIT 1].Id;
        }

        List<Account> accounts = ACAMSAccountDAO.getAccountsFromIds(new Set<Id>{
                accountId
        });
        Set<Id> accountGroupIds = new Set<Id>();
        for (Account account : accounts) {
            if (account.ccrz__E_AccountGroup__c != null) {
                accountGroupIds.add(account.ccrz__E_AccountGroup__c);
            }
        }

        List<ccrz__E_AccountGroupPriceList__c> accountGroupPriceLists = [
                SELECT
                        Id,
                        ccrz__Pricelist__c
                FROM
                        ccrz__E_AccountGroupPriceList__c
                WHERE
                        ccrz__AccountGroup__c IN :accountGroupIds
                AND
                        ccrz__StartDate__c <= TODAY
                AND
                        ccrz__EndDate__c >= TODAY
                AND
                        ccrz__Enable__c = TRUE
        ];

        Set<Id> priceListIds = new Set<Id>();
        for (ccrz__E_AccountGroupPriceList__c accountGroupPriceList : accountGroupPriceLists) {
            priceListIds.add(accountGroupPriceList.ccrz__Pricelist__c);
        }

        List<ccrz__E_PriceList__c> priceLists = [
                SELECT
                        Id, (
                        SELECT
                                Id,
                                ccrz__EndDate__c,
                                ccrz__Price__c,
                                Display_Description__c,
                                Display_Name__c
                        FROM
                                ccrz__E_PriceListItems1__r
                        WHERE
                                ccrz__Product__c =: productId
                        AND
                                Display_Name__c != NULL
                )
                FROM
                        ccrz__E_PriceList__c
                WHERE
                        Id IN :priceListIds
                AND
                        ccrz__StartDate__c <= TODAY
                AND
                        ccrz__EndDate__c >= TODAY
                AND
                        ccrz__Storefront__c = 'acams'
                AND
                        ccrz__CurrencyISOCode__c =: currencyCode
        ];

        Map<Date, ccrz__E_PriceListItem__c> priceMap = new Map<Date, ccrz__E_PriceListItem__c>();
        for (ccrz__E_PriceList__c priceList : priceLists) {
            for (ccrz__E_PriceListItem__c priceListItem : priceList.ccrz__E_PriceListItems1__r) {
                if (priceMap.containsKey(priceListItem.ccrz__EndDate__c)) {
                    if (priceMap.get(priceListItem.ccrz__EndDate__c).ccrz__Price__c > priceListItem.ccrz__Price__c) {
                        priceMap.put(priceListItem.ccrz__EndDate__c, priceListItem);
                    }
                } else {
                    priceMap.put(priceListItem.ccrz__EndDate__c, priceListItem);
                }
            }
        }

        List<Date> dates = new List<Date>(priceMap.keySet());
        dates.sort();
        List<Map<String, Object>> tierPriceList = new List<Map<String, Object>>();
        for (Date pricelistDate : dates) {
            Map<String, Object> pricelistItemMap = new Map<String, Object>();
            ccrz__E_PricelistItem__c priceListItem = priceMap.get(pricelistDate);
            priceListItemMap.put('displayName', priceListItem.Display_Name__c);
            priceListItemMap.put('displayDescription', priceListItem.Display_Description__c);
            priceListItemMap.put('price', priceListItem.ccrz__Price__c);
            tierPriceList.add(priceListItemMap);
        }

        ProductPricingTiersResponse response = new ProductPricingTiersResponse(tierPriceList);

        return response;
    }

    global class ProductPricingTiersResponse {
        public String pricelistItems = '';

        public ProductPricingTiersResponse(List<Map<String, Object>> tierPriceList) {
            pricelistItems = JSON.serialize(tierPriceList);
        }
    }
}