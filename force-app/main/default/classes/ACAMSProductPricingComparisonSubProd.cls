@RestResource(UrlMapping='/api/product/pricing/comparisonsubprod')
global with sharing class ACAMSProductPricingComparisonSubProd {

    @HttpPost
    global static ProductPricingComparisonResponse getProductPricingComparison(List<String> subprodIds, String currencyCode) {
        Map<String, Map<String, Decimal>> priceMap = new Map<String, Map<String, Decimal>>();
        String privateNonMemberPriceList = '%' + ACAMSUtil.PRICELIST_PRIVATE_NON_MEMBER + '%';
        String publicNonMemberPriceList = '%' + ACAMSUtil.PRICELIST_PUBLIC_NON_MEMBER + '%';

        List<ccrz__E_PriceList__c> privatePriceListList = [
                SELECT
                        Id,
                        Name
                FROM
                        ccrz__E_PriceList__c
                WHERE
                        ccrz__CurrencyISOCode__c = :currencyCode
                AND
                        Name LIKE :privateNonMemberPriceList
        ];

        List<ccrz__E_PriceList__c> publicPriceListList = [
                SELECT
                        Id,
                        Name
                FROM
                        ccrz__E_PriceList__c
                WHERE
                        ccrz__CurrencyISOCode__c = :currencyCode
                AND
                        Name LIKE :publicNonMemberPriceList
        ];

        List<Id> privatePriceListIds = new List<Id>();
        for (ccrz__E_PriceList__c priceList : privatePriceListList) {
            privatePriceListIds.add(priceList.Id);
        }

        List<Id> publicPriceListIds = new List<Id>();
        for (ccrz__E_PriceList__c priceList : publicPriceListList) {
            publicPriceListIds.add(priceList.Id);
        }

         List<ccrz__E_PricelistItem__c> privatePriceListItemList;
        if(subprodIds != null){
       privatePriceListItemList = [
                SELECT
                        Id,
                        ccrz__Pricelist__r.Name,
                        ccrz__Price__c,Avoid_from_Price_List__c,
                        ccrz__Product__c,ccrz__SubProdTerm__c
                FROM
                        ccrz__E_PricelistItem__c
                WHERE
                        ccrz__StartDate__c <= :Date.today()
                AND
                        ccrz__EndDate__c >= :Date.today()
           
                AND
                        ccrz__Pricelist__c IN :privatePriceListIds
            	AND
            			Avoid_from_Price_List__c=false
            AND ccrz__SubProdTerm__r.id IN:subprodIds
        ];
        }
        else{
            privatePriceListItemList = [
                SELECT
                        Id,
                        ccrz__Pricelist__r.Name,
                        ccrz__Price__c,Avoid_from_Price_List__c,
                        ccrz__Product__c,ccrz__SubProdTerm__c
                FROM
                        ccrz__E_PricelistItem__c
                WHERE
                        ccrz__StartDate__c <= :Date.today()
                AND
                        ccrz__EndDate__c >= :Date.today()
           
                AND
                        ccrz__Pricelist__c IN :privatePriceListIds
            	AND
            			Avoid_from_Price_List__c=false
           
        ];
        }
		system.debug(privatePriceListItemList);
List<ccrz__E_PricelistItem__c> publicPriceListItemList;
 if(subprodIds != null){
         publicPriceListItemList = [
                SELECT
                        Id,
                        ccrz__Pricelist__r.Name,
                        ccrz__Price__c,Avoid_from_Price_List__c,
                        ccrz__Product__c,ccrz__SubProdTerm__c
                FROM
                        ccrz__E_PricelistItem__c
                WHERE
                        ccrz__StartDate__c <= :Date.today()
                AND
                        ccrz__EndDate__c >= :Date.today()
                AND
 
                        ccrz__Pricelist__c IN :publicPriceListIds
            	AND
            			Avoid_from_Price_List__c=false
  AND ccrz__SubProdTerm__r.id IN:subprodIds
        ];
 }
        else{
                    publicPriceListItemList = [
                SELECT
                        Id,
                        ccrz__Pricelist__r.Name,
                        ccrz__Price__c,Avoid_from_Price_List__c,
                        ccrz__Product__c,ccrz__SubProdTerm__c
                FROM
                        ccrz__E_PricelistItem__c
                WHERE
                        ccrz__StartDate__c <= :Date.today()
                AND
                        ccrz__EndDate__c >= :Date.today()
                AND
          
                        ccrz__Pricelist__c IN :publicPriceListIds
            	AND
            			Avoid_from_Price_List__c=false
 ];
        }
		system.debug(publicPriceListItemList);
        Map<Id, List<ccrz__E_PricelistItem__c>> privateProductToPriceListItemsMap =
                new Map<Id, List<ccrz__E_PricelistItem__c>>();
        for (ccrz__E_PricelistItem__c priceListItem : privatePriceListItemList) {
            if (privateProductToPriceListItemsMap.containsKey(priceListItem.ccrz__SubProdTerm__c)) {
                privateProductToPriceListItemsMap.get(priceListItem.ccrz__SubProdTerm__c).add(priceListItem);
                system.debug(privateProductToPriceListItemsMap);
            } else {
                privateProductToPriceListItemsMap.put(priceListItem.ccrz__SubProdTerm__c, new List<ccrz__E_PricelistItem__c>{
                        priceListItem
                });
system.debug(privateProductToPriceListItemsMap);
            }
        }
        system.debug(privateProductToPriceListItemsMap.keySet());
        for (String productId : privateProductToPriceListItemsMap.keySet()) {
            Decimal price = null;
            for (ccrz__E_PricelistItem__c priceListItem : privateProductToPriceListItemsMap.get(productId)) {
                if (price == null || priceListItem.ccrz__Price__c < price) {
                    price = priceListItem.ccrz__Price__c;
                }
            }
            priceMap.put(productId, new Map<String, Decimal>{'private' => price, 'public' => null});
        }
		system.debug(priceMap);
        Map<Id, List<ccrz__E_PricelistItem__c>> publicProductToPriceListItemsMap =
                new Map<Id, List<ccrz__E_PricelistItem__c>>();
        for (ccrz__E_PricelistItem__c priceListItem : publicPriceListItemList) {
            if (publicProductToPriceListItemsMap.containsKey(priceListItem.ccrz__SubProdTerm__c)) {
                publicProductToPriceListItemsMap.get(priceListItem.ccrz__SubProdTerm__c).add(priceListItem);
            } else {
                publicProductToPriceListItemsMap.put(priceListItem.ccrz__SubProdTerm__c, new List<ccrz__E_PricelistItem__c>{
                        priceListItem
                });
            }
        }
        system.debug(publicProductToPriceListItemsMap.keySet());
        for (String productId : publicProductToPriceListItemsMap.keySet()) {
            Decimal price = null;
            for (ccrz__E_PricelistItem__c priceListItem : publicProductToPriceListItemsMap.get(productId)) {
                if (price == null || priceListItem.ccrz__Price__c < price) {
                    price = priceListItem.ccrz__Price__c;
                }
            }
            if (priceMap.containsKey(productId)) {
                priceMap.get(productId).put('public', price);
            } else {
                priceMap.put(productId, new Map<String, Decimal>{'private' => null, 'public' => price});
            }
        }
		system.debug(priceMap);
        ProductPricingComparisonResponse response = new ProductPricingComparisonResponse(priceMap);
        return response;
    }

    global class ProductPricingComparisonResponse {
        public Map<String, Map<String, Decimal>> priceMap { get; set; }

        public ProductPricingComparisonResponse(Map<String, Map<String, Decimal>> priceMap) {
            this.priceMap = priceMap;
        }
    }
}