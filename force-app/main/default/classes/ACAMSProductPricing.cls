@RestResource(UrlMapping='/api/product/pricing/membership')
global with sharing class ACAMSProductPricing {

    @HttpPost
    global static ProductPricingResponse getProductPricing(List<String> productIds, String currencyCode) {
        Map<String, Decimal> memberPriceMap = new Map<String, Decimal>();
        String memberPriceList = '%' + ACAMSUtil.PRICELIST_PRIVATE_MEMBER + '%';

        List<ccrz__E_PriceList__c> priceListList = [
                SELECT
                        Id,
                        Name
                FROM
                        ccrz__E_PriceList__c
                WHERE
                        ccrz__CurrencyISOCode__c = :currencyCode
                AND
                        Name LIKE :memberPriceList
        ];

        List<Id> priceListIds = new List<Id>();
        for (ccrz__E_PriceList__c priceList : priceListList) {
            priceListIds.add(priceList.Id);
        }

        List<ccrz__E_PriceListItem__c> priceListItemList = [
                SELECT
                        Id,
                        ccrz__Pricelist__r.Name,
                        ccrz__Price__c,
                        ccrz__Product__c
                FROM
                        ccrz__E_PriceListItem__c
                WHERE
                        ccrz__StartDate__c <= :Date.today()
                AND
                        ccrz__EndDate__c >= :Date.today()
                AND
                        ccrz__Product__c IN :productIds
                AND
                        ccrz__Pricelist__c IN :priceListIds
        ];

        Map<Id, List<ccrz__E_PriceListItem__c>> productToPriceListItemsMap =
                new Map<Id, List<ccrz__E_PriceListItem__c>>();
        for (ccrz__E_PriceListItem__c priceListItem : priceListItemList) {
            if (productToPriceListItemsMap.containsKey(priceListItem.ccrz__Product__c)) {
                productToPriceListItemsMap.get(priceListItem.ccrz__Product__c).add(priceListItem);
            } else {
                productToPriceListItemsMap.put(priceListItem.ccrz__Product__c, new List<ccrz__E_PriceListItem__c>{
                        priceListItem
                });
            }
        }
        for (String productId : productToPriceListItemsMap.keySet()) {
            Decimal memberPrice = null;
            for (ccrz__E_PriceListItem__c priceListItem : productToPriceListItemsMap.get(productId)) {
                if (memberPrice == null || priceListItem.ccrz__Price__c < memberPrice) {
                    memberPrice = priceListItem.ccrz__Price__c;
                }
            }
            memberPriceMap.put(productId, memberPrice);
        }

        ProductPricingResponse response = new ProductPricingResponse(memberPriceMap);
        return response;
    }

    global class ProductPricingResponse {
        public Map<String, Decimal> memberPriceMap { get; set; }

        public ProductPricingResponse(Map<String, Decimal> memberPriceMap) {
            this.memberPriceMap = memberPriceMap;
        }
    }
}