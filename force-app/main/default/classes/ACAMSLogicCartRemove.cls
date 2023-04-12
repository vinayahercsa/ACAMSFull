global with sharing class ACAMSLogicCartRemove extends ccrz.ccLogicCartRemove {

    global override Map<String, Object> removeItems(Map<String, Object> inputData) {
        String cartId = (String) inputData.get(ccrz.ccAPICart.CART_ID);
        if (cartId == null) {
            cartId = (String) inputData.get(ccrz.ccAPICart.CART_ENCID);
        }
        List<ccrz__E_CartItem__c> cartItems = ACAMSCartDAO.getCartItemsByCartId(cartId);

        List<ccrz.ccApiCart.LineData> newLineData = (List<ccrz.ccApiCart.LineData>) inputData.get(ccrz.ccAPICart.LINE_DATA);

        if (newLineData != null) {
            Set<Id> cartItemsToRemove = new Set<Id>();
            for (ccrz.ccApiCart.LineData lineData : newLineData) {
                cartItemsToRemove.add(lineData.sfid);
            }
            Set<Id> productsBeingRemoved = new Set<Id>();
            Map<Id, ccrz__E_CartItem__c> productToCartItemMap = new Map<Id, ccrz__E_CartItem__c>();
            Set<Id> bundleProducts = new Set<Id>();
            for (ccrz__E_CartItem__c cartItem : cartItems) {
                if (cartItemsToRemove.contains(cartItem.Id)) {
                    productsBeingRemoved.add(cartItem.ccrz__Product__c);
                }
                if (cartItem.ccrz__Product__r.ccrz__ProductType__c == ACAMSUtil.BUNDLE) {
                    bundleProducts.add(cartItem.ccrz__Product__c);
                }
                productToCartItemMap.put(cartItem.ccrz__Product__c, cartItem);
            }
            List<ccrz__E_CompositeProduct__c> compositeProducts = ACAMSProductDAO.getChildProducts(bundleProducts);
            for (ccrz__E_CompositeProduct__c compositeProduct : compositeProducts) {
                ccrz__E_CartItem__c cartItem = productToCartItemMap.get(compositeProduct.ccrz__Composite__c);
                if (cartItem != null) {
                    productToCartItemMap.put(compositeProduct.ccrz__Component__c, cartItem);
                    productsBeingRemoved.add(compositeProduct.ccrz__Component__c);
                }
            }
            List<ccrz__E_RelatedProduct__c> prerequisiteRelatedProducts = ACAMSProductDAO.getPrerequisiteProducts(productsBeingRemoved);
            for (ccrz__E_RelatedProduct__c relatedProduct : prerequisiteRelatedProducts) {
                if (productToCartItemMap.containsKey(relatedProduct.ccrz__RelatedProduct__c)) {
                    ccrz.ccApiCart.LineData lineData = new ccrz.ccApiCart.LineData(productToCartItemMap.get(relatedProduct.ccrz__RelatedProduct__c).Id);
                    lineData.quantity = 1.00;
                    newLineData.add(lineData);
                }
            }
        }
        inputData.put(ccrz.ccAPICart.LINE_DATA, newLineData);
        Map<String, Object> outputData = super.removeItems(inputData);
        ccrz.ccApiCart.price(new Map<String,Object>{
                ccrz.ccApi.API_VERSION => 9,
                ccrz.ccApiCart.CART_ID => (String) inputData.get(ccrz.ccAPICart.CART_ENCID)
        });
        return outputData;
    }

}