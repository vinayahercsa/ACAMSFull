public with sharing class ACAMSProductDAO {
    public static List<ccrz__E_RelatedProduct__c> getUpsellItems() {
        List<ccrz__E_RelatedProduct__c> upsellItems = [
                SELECT
                        Id,
                        ccrz__RelatedProduct__r.Id,
                        ccrz__RelatedProduct__r.ccrz__SKU__c,
                        ccrz__Product__r.Id,
                        ccrz__Product__r.ccrz__SKU__c,
                        ccrz__RelatedProductType__c,
                        ccrz__Enabled__c,
                        ccrz__StartDate__c,
                        ccrz__EndDate__c
                FROM
                        ccrz__E_RelatedProduct__c
                WHERE
                ccrz__RelatedProductType__c = 'UpSell'
                AND
                ccrz__Enabled__c = TRUE
                AND
                (ccrz__StartDate__c = NULL OR ccrz__StartDate__c <= TODAY)
                AND
                (ccrz__EndDate__c = NULL OR ccrz__EndDate__c >= TODAY)
        ];

        return upsellItems;
    }

    public static List<ccrz__E_RelatedProduct__c> getAllReplacementOrUpgradeProducts() {
        List<ccrz__E_RelatedProduct__c> replacementItems = [
                SELECT
                        Id,
                        ccrz__RelatedProduct__c,
                        ccrz__RelatedProduct__r.ccrz__SKU__c,
                        ccrz__Product__c,
                        ccrz__Product__r.ccrz__SKU__c,
                        ccrz__RelatedProductType__c,
                        ccrz__Enabled__c,
                        ccrz__StartDate__c,
                        ccrz__EndDate__c
                FROM
                        ccrz__E_RelatedProduct__c
                WHERE
                (ccrz__RelatedProductType__c = 'Replacement' OR ccrz__RelatedProductType__c = 'Upgrade')
                AND
                ccrz__Enabled__c = TRUE
                AND
                (ccrz__StartDate__c = NULL OR ccrz__StartDate__c <= TODAY)
                AND
                (ccrz__EndDate__c = NULL OR ccrz__EndDate__c >= TODAY)
        ];

        return replacementItems;
    }

    public static List<ccrz__E_RelatedProduct__c> getAllPrerequisiteProducts() {
        List<ccrz__E_RelatedProduct__c> replacementItems = [
                SELECT
                        Id,
                        ccrz__RelatedProduct__c,
                        ccrz__RelatedProduct__r.ccrz__SKU__c,
                        ccrz__Product__c,
                        ccrz__Product__r.ccrz__SKU__c,
                        ccrz__RelatedProductType__c,
                        ccrz__Enabled__c,
                        ccrz__StartDate__c,
                        ccrz__EndDate__c
                FROM
                        ccrz__E_RelatedProduct__c
                WHERE
                ccrz__RelatedProductType__c = 'Prerequisite'
                AND
                ccrz__Enabled__c = TRUE
                AND
                (ccrz__StartDate__c = NULL OR ccrz__StartDate__c <= TODAY)
                AND
                (ccrz__EndDate__c = NULL OR ccrz__EndDate__c >= TODAY)
        ];

        return replacementItems;
    }

    public static List<ccrz__E_RelatedProduct__c> getReplacementOrUpgradeProducts(Set<Id> productIds) {
        List<ccrz__E_RelatedProduct__c> replacementItems = [
                SELECT
                        Id,
                        ccrz__RelatedProduct__c,
                        ccrz__RelatedProduct__r.ccrz__SKU__c,
                        ccrz__Product__c,
                        ccrz__Product__r.ccrz__SKU__c,
                        ccrz__RelatedProductType__c,
                        ccrz__Enabled__c,
                        ccrz__StartDate__c,
                        ccrz__EndDate__c
                FROM
                        ccrz__E_RelatedProduct__c
                WHERE
                ccrz__Product__r.Id IN :productIds
                AND
                (ccrz__RelatedProductType__c = 'Replacement' OR ccrz__RelatedProductType__c = 'Upgrade')
                AND
                ccrz__Enabled__c = TRUE
                AND
                (ccrz__StartDate__c = NULL OR ccrz__StartDate__c <= TODAY)
                AND
                (ccrz__EndDate__c = NULL OR ccrz__EndDate__c >= TODAY)
        ];

        return replacementItems;
    }

    public static List<ccrz__E_RelatedProduct__c> getPrerequisiteProducts(Set<Id> productIds) {
        List<ccrz__E_RelatedProduct__c> prerequisiteItems = [
                SELECT
                        Id,
                        ccrz__RelatedProduct__c,
                        ccrz__RelatedProduct__r.ccrz__SKU__c,
                        ccrz__Product__c,
                        ccrz__Product__r.ccrz__SKU__c,
                        ccrz__RelatedProductType__c,
                        ccrz__Enabled__c,
                        ccrz__StartDate__c,
                        ccrz__EndDate__c
                FROM
                        ccrz__E_RelatedProduct__c
                WHERE
                ccrz__Product__r.Id IN :productIds
                AND
                ccrz__RelatedProductType__c = 'Prerequisite'
                AND
                ccrz__Enabled__c = TRUE
                AND
                (ccrz__StartDate__c = NULL OR ccrz__StartDate__c <= TODAY)
                AND
                (ccrz__EndDate__c = NULL OR ccrz__EndDate__c >= TODAY)
        ];

        return prerequisiteItems;
    }

    public static List<ccrz__E_Product__c> getProductsBySkus(Set<String> skus) {
        List<ccrz__E_Product__c> pList = [
                SELECT
                        Id,
                        ccrz__SKU__c
                FROM
                        ccrz__E_Product__c
                WHERE
                        ccrz__SKU__c IN :skus
        ];
        return pList;
    }

    public static List<ccrz__E_CompositeProduct__c> getChildProducts(Set<Id> productIds) {
        List<ccrz__E_CompositeProduct__c> childBundles = [
                SELECT
                        ccrz__Composite__c,
                        ccrz__Component__c
                FROM
                        ccrz__E_CompositeProduct__c
                WHERE
                        ccrz__Composite__c IN :productIds
        ];
        return childBundles;
    }

    public static List<ccrz__E_CompositeProduct__c> getChildBundles(List<String> compositeProductIds) {
        List<ccrz__E_CompositeProduct__c> childBundles = [
                SELECT
                        ccrz__Composite__c,
                        ccrz__Component__c
                FROM
                        ccrz__E_CompositeProduct__c
                WHERE
                ccrz__Composite__c IN :compositeProductIds
                AND
                ccrz__Component__r.ccrz__ProductType__c = 'Bundle'
        ];
        return childBundles;
    }

    public static Id getShippingProductId() {
        List<ccrz__E_Product__c> pList = [
                SELECT
                        ccrz__SKU__c
                FROM
                        ccrz__E_Product__c
                WHERE
                        ccrz__SKU__c = :ACAMSUtil.SHIPPING_PRODUCT_SKU
        ];

        if (!pList.isEmpty()) {
            return pList[0].Id;
        }
        return null;
    }

}