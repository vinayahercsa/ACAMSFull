global without sharing class ACAMSLogicCartClone extends ccrz.ccLogicCartClone {

    private static final String CART_ITEMS_BY_CART_ID = 'cartItemsByCartId';
    private static final String CART_ITEM_TYPE_MAJOR = 'Major';
    private static final String CART_ITEM_PRICING_TYPE_EXT = 'external';

    global override Map<String, Object> processData (Map<String, Object> inputData) {
        Map<String, Object> resultData = super.processData(inputData);
        copyExternalPriceInCartItems(resultData);
        return resultData;
    }

    /**
     * @description for cart items with external pricing - copies price from source cart items
     */
    private void copyExternalPriceInCartItems(Map<String, Object> processedData) {
        // contains pairs newItem.ccrz__CartItemId__c => oldItem
        Map<String, ccrz__E_CartItem__c> oldCartItemByNewItemUUID = new Map<String, ccrz__E_CartItem__c>();

        Map<String, String> newCartItemUUIDByOldId =
            (Map<String, String>) processedData.get(ccrz.ccLogicCartClone.OLD_ITEM);

        List<ccrz__E_CartItem__c> newCartItems =
            (List<ccrz__E_CartItem__c>) processedData.get(ccrz.ccLogicCartClone.CARTITEMS_TO_INSERT);

        ccrz__E_Cart__c oldCart = (ccrz__E_Cart__c) processedData.get(ccrz.ccLogicCartClone.OLD_CART);

        Map<String, List<ccrz__E_CartItem__c>> oldCartItemsByCartId =
            (Map<String, List<ccrz__E_CartItem__c>>) processedData.get(CART_ITEMS_BY_CART_ID);

        Map<Id, ccrz__E_CartItem__c> oldCartItemById =
            new Map<Id, ccrz__E_CartItem__c>(oldCartItemsByCartId.get(oldCart.Id));

        for (String oldCartItemId: newCartItemUUIDByOldId.keySet()) {
            oldCartItemByNewItemUUID.put(
                newCartItemUUIDByOldId.get(oldCartItemId),
                oldCartItemById.get(Id.valueOf(oldCartItemId))
            );
        }
        for (ccrz__E_CartItem__c newCartItem : newCartItems) {
            ccrz__E_CartItem__c oldCartItem =
                oldCartItemByNewItemUUID.get(newCartItem.ccrz__CartItemId__c);
            copyCartItemData(oldCartItem, newCartItem);
        }
        processedData.put(ccrz.ccLogicCartClone.CARTITEMS_TO_INSERT, newCartItems);
    }

    private void copyCartItemData(ccrz__E_CartItem__c oldCartItem, ccrz__E_CartItem__c newCartItem) {
        if (
            newCartItem.ccrz__cartItemType__c == CART_ITEM_TYPE_MAJOR &&
            newCartItem.ccrz__PricingType__c == CART_ITEM_PRICING_TYPE_EXT
        ) {
            newCartItem.ccrz__Price__c = oldCartItem.ccrz__Price__c;
            newCartItem.ccrz__SubAmount__c = oldCartItem.ccrz__SubAmount__c;
            newCartItem.ccrz__ExtName__c = oldCartItem.ccrz__ExtName__c;
            newCartItem.ccrz__ExtSKU__c = oldCartItem.ccrz__ExtSKU__c;
        }
    }
}