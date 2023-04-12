public with sharing class ACAMSOpportunityCCProductEntryDAO {
    // this method requires cc_CallContext to be filled
    public static Map<Id, ccrz__E_Product__c> getProducts(Set<String> productTypes, String searchParam) {

        Map<Id, ccrz__E_Product__c> products = new Map<Id, ccrz__E_Product__c>();
        Map<Id, Decimal> productPriceById = new Map<Id, Decimal>();

        Map<String, Object> inputData = ACAMSOpportunityCCProductEntryDAO.getFetchInputData(productTypes);
        try {
            Map<String, Object> outputData = ccrz.ccAPIProduct.fetch(inputData);
            Object productData = outputData.get(ccrz.ccAPIProduct.PRODUCTLIST);
            if (productData != null) {
                for (Map<String, Object> productRecord : (List<Map<String, Object>>) productData) {
                    ACAMSOpportunityCCProductEntryDAO.storeProductPrice(productRecord, productPriceById);
                }
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            return products;
        }
        products = ACAMSOpportunityCCProductEntryDAO.getProductData(
                productPriceById.keySet(),
                productTypes,
                searchParam
        );
        for (ccrz__E_Product__c product : products.values()) {
            ACAMSOpportunityCCProductEntryDAO.setProductPrice(product, productPriceById);
        }
        ACAMSOpportunityCCProductEntryDAO.addCompositeProductsChildren(products);
        //FSA-562 Commented removeAddedCartItems method.
        //ACAMSOpportunityCCProductEntryDAO.removeAddedCartItems(products);
        return products;
    }

    /**
     * Returns input settings for ccrz.ccAPIProduct.fetch
     */
    private static Map<String, Object> getFetchInputData(Set<String> productTypes) {
        return new Map<String, Object>{
                ccrz.ccApi.API_VERSION => 9,
                ccrz.ccAPIProduct.PRODUCTSTOREFRONT => ccrz.cc_CallContext.storefront,
                ccrz.ccAPIProduct.PARAM_INCLUDE_PRICING => true,
                ccrz.ccAPIProduct.TYPES => productTypes
        };
    }

    /**
     * Finds a price from productRecord and if it exists - stores it in productPriceById map
     */
    private static void storeProductPrice(Map<String, Object> productRecord, Map<Id, Decimal> productPriceById) {
        Id productId = (Id) productRecord.get('sfid');
        Decimal productPrice = (Decimal) productRecord.get('price');
        if (productPrice == null) {
            List<Map<String, Object>> subProdTerms = (List<Map<String, Object>>) productRecord.get('subProdTerms');
            if (subProdTerms != null) {
                for (Map<String, Object> subProdTerm : subProdTerms) {
                    if (productPrice == null || productPrice > (Decimal) subProdTerm.get('productPrice')) {
                        productPrice = (Decimal) subProdTerm.get('productPrice');
                    }
                }
            }
        }
        Decimal productPreviousPrice = productPriceById.get(productId);
        Decimal priceToStore = productPrice != null ? productPrice : productPreviousPrice;
        Boolean hasComponents = productRecord.containsKey('compositeProductsS');
        Object components = productRecord.get('compositeProductsS');
        if (priceToStore != null) {
            productPriceById.put(productId, priceToStore);
            if (hasComponents) {
                for (Map<String, Object> productComponent : (List<Map<String, Object>>) components) {
                    Id componentId = (Id) productComponent.get('component');
                    productPriceById.put(componentId, productPriceById.get(componentId));
                }
            }
        }
    }

    /**
     * Fetches the data for products and their component filtered by set of Product Ids and set of Product types
     */
    private static Map<Id, ccrz__E_Product__c> getProductData(Set<Id> productIds, Set<String> productTypes, String searchParam) {
        String searchParamSanitized =
                '%' + String.escapeSingleQuotes(searchParam).replaceAll('%', '\\%').replaceAll('_', '\\_') + '%';
        //FSA-683 Added Product status filter in where clause.        
        return new Map<Id, ccrz__E_Product__c>([
                SELECT
                        Id, Name, ccrz__SKU__c,
                        ccrz__ShortDesc__c, ccrz__ProductType__c, (
                        SELECT ccrz__Quantity__c, ccrz__Component__c, ccrz__Component__r.Id
                        FROM ccrz__CompositeProducts__r
                        WHERE ccrz__Component__c IN :productIds
                ), (
                        SELECT Id, ccrz__Price__c
                        FROM ccrz__E_PriceListItems__r
                         WHERE (ccrz__Price__c != 0 OR ccrz__SubProdTerm__c != NULL) OR (ccrz__SubProdTerm__c = NULL) //FSA-1029/834/1490
                        ORDER BY ccrz__Price__c
                        LIMIT 1
                ), (
                        SELECT Id, Name, ccrz__CCSubProdTerm__c
                        FROM ccrz__SubProdTerms__r
                        ORDER BY ccrz__Sequence__c
                )
                FROM ccrz__E_Product__c
                WHERE Id IN :productIds
                AND ccrz__ProductType__c IN :productTypes
                AND (Name LIKE :searchParamSanitized OR ccrz__SKU__c LIKE :searchParamSanitized)
                AND ccrz__ProductStatus__c =: ACAMSUtil.RELEASED
                ORDER BY Name
                LIMIT 10000
        ]);
    }

    /**
     * Adds PriceListItem to the product record ccrz__E_PriceListItems__r list
     */
    private static void setProductPrice(ccrz__E_Product__c targetProduct, Map<Id, Decimal> productPriceById) {
        Decimal productPrice = productPriceById.get(targetProduct.Id);
        if (productPrice == null) {
            productPrice = 0;
        }
        targetProduct.ccrz__E_PriceListItems__r[0].ccrz__Price__c = productPrice;
    }

    /**
     * For composite products, searches and adds the components from the same list
     */
    private static void addCompositeProductsChildren(Map<Id, ccrz__E_Product__c> products) {
        for (ccrz__E_Product__c product : products.values()) {
            if (!product.ccrz__CompositeProducts__r.isEmpty()) {
                for (ccrz__E_CompositeProduct__c composite : product.ccrz__CompositeProducts__r) {
                    if (products.containsKey(composite.ccrz__Component__c)) {
                        composite.ccrz__Component__r = products.get(composite.ccrz__Component__c);
                    }
                }
            }
        }
    }

    /**
     * Removes the products that are already added to the cart in call context
     */
    private static void removeAddedCartItems(Map<Id, ccrz__E_Product__c> availableProducts) {
        List<ccrz__E_CartItem__c> cartItemsAlreadyAdded = [
                SELECT ccrz__Product__c
                FROM ccrz__E_CartItem__c
                WHERE ccrz__ParentCartItem__c = NULL
                AND ccrz__Cart__r.ccrz__EncryptedId__c = :ccrz.cc_CallContext.currCartId
                AND ccrz__SubProdTerm__c = NULL
        ];
        if (!cartItemsAlreadyAdded.isEmpty()) {
            for (ccrz__E_CartItem__c cartItemAlreadyAdded : cartItemsAlreadyAdded) {
                availableProducts.remove(cartItemAlreadyAdded.ccrz__Product__c);
            }
        }
    }
}