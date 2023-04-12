global with sharing class ACAMSLogicCartAddTo extends ccrz.ccLogicCartAddTo {
    private static final Integer API_VERSION = 8;

    public static final String PARAM_SKIP_CART_ACTIVE_SEARCH_FLOW = 'ACAMS_skipCartActiveSearchFlow';

    private static final String PARAM_CART_HEADER = 'cartHeader';

    global override Map<String, Object> fetchCart(Map<String, Object> inputData) {
        System.debug(JSON.serialize(inputData));
        Boolean hasId = ccrz.ccUtil.isTrue(inputData, ccrz.ccApiCart.HAS_ID);
        String cartId    = (String) ccrz.ccUtil.defv(inputData, ccrz.ccApiCart.CART_ID, null);
        String cartEncId = (String) ccrz.ccUtil.defv(inputData, ccrz.ccApiCart.CART_ENCID, null);
        Boolean isSkipGetCartActiveSearchFlow = ccrz.ccUtil.isTrue(inputData, PARAM_SKIP_CART_ACTIVE_SEARCH_FLOW);
        if ((cartId != null || cartEncId != null || hasId) && isSkipGetCartActiveSearchFlow) {
            fetchCurrentCartData(inputData);
        } else {
            inputData = super.fetchCart(inputData);
        }
        return inputData;
    }

    @TestVisible
    private void fetchCurrentCartData(Map<String, Object> inputData) {
        String cartId;
        if (ccrz.ccUtil.isKeyValued(inputData, ccrz.ccApiCart.CART_ID)) {
            cartId = (String) ccrz.ccUtil.defv(inputData, ccrz.ccApiCart.CART_ID, null);
        } else {
            cartId = (String) ccrz.ccUtil.defv(inputData, ccrz.ccApiCart.CART_ENCID, null);
        }
        if (cartId != null) {
            List<ccrz__E_Cart__c> carts = ACAMSCartDAO.getCartsByIds(new Set<String>{
                    cartId
            });
            if (carts != null && !carts.isEmpty()) {
                ccrz__E_Cart__c currentCart = carts[0];
                List<ccrz__E_CartItem__c> cartItems = ACAMSCartDAO.getCartItemsByCartId(cartId);

                inputData.put(ccrz.ccApiCart.CART_ID, currentCart.Id);
                inputData.put(ccrz.ccApiCart.CART_ENCID, currentCart.ccrz__EncryptedId__c);
                inputData.put(PARAM_CART_HEADER, currentCart);

                Map<String, Object> responseData = (Map<String, Object>) ccrz.ccUtil.defv(
                        inputData,
                        ccrz.ccApiCart.RESPONSE,
                        new Map<String, Object>()
                );
                responseData.put(ccrz.ccApiCart.CART_ENCID, currentCart.ccrz__EncryptedId__c);
                inputData.put(ccrz.ccApiCart.RESPONSE, responseData);

                Map<String, List<ccrz__E_CartItem__c>> cartItemsData =
                        (Map<String, List<ccrz__E_CartItem__c>>) ccrz.ccUtil.defv(
                                inputData,
                                ccrz.ccApiCart.CARTITEMSBYID,
                                new Map<String, List<ccrz__E_CartItem__c>>()
                        );
                cartItemsData.put(currentCart.Id, cartItems);
                inputData.put(ccrz.ccApiCart.CARTITEMSBYID, cartItemsData);
            }
        }
    }

    global override Map<String, Object> addMajorLineItems(Map<String, Object> inputData) {
        ccrz__E_Cart__c cart = (ccrz__E_Cart__c) inputData.get('cartHeader');
        String infoMsg = null;
        if (cart != null) {
            List<ccrz__E_CartItem__c> cartItems = ACAMSCartDAO.getCartItemsByCartId(cart.Id);
            List<Object> lineData = (List<Object>) inputData.get('lineData');
            if (lineData != null) {
                List<Object> newLineData = new List<Object>();
                Set<String> lineItemSkus = new Set<String>();
                Map<String, Object> lineItemSkusMap = new Map<String, Object>();
                Set<Id> lineItemIds = new Set<Id>();
                Map<String, Object> lineItemMap = new Map<String, Object>();

                Map<Id, ccrz__E_CartItem__c> cartItemMap = new Map<Id, ccrz__E_CartItem__c>();
                Set<Id> cartItemProductIds = new Set<Id>();
                for (ccrz__E_CartItem__c cartItem : cartItems) {
                    cartItemMap.put(cartItem.ccrz__Product__c, cartItem);
                    cartItemProductIds.add(cartItem.ccrz__Product__c);
                }

                List<ccrz__E_RelatedProduct__c> upsellItems = ACAMSProductDAO.getUpsellItems();
                Map<String, String> upsellMap = new Map<String, String>();
                Map<String, String> downsellMap = new Map<String, String>();
                for (ccrz__E_RelatedProduct__c relatedProduct : upsellItems) {
                    upsellMap.put(relatedProduct.ccrz__RelatedProduct__c, relatedProduct.ccrz__Product__c);
                    downsellMap.put(relatedProduct.ccrz__Product__c, relatedProduct.ccrz__RelatedProduct__c);
                }

                User currentUser = ACAMSUserDAO.queryUserById(ccrz.cc_CallContext.currUserId);
                List<ccrz__E_RelatedProduct__c> allRelatedProducts = ACAMSProductDAO.getAllReplacementOrUpgradeProducts();
                List<ccrz__E_RelatedProduct__c> allPrerequisiteProducts = ACAMSProductDAO.getAllPrerequisiteProducts();
                Map<Id, ccrz__E_RelatedProduct__c> allRelatedProductsMap = new Map<Id, ccrz__E_RelatedProduct__c>();
                Map<Id, ccrz__E_RelatedProduct__c> allPrerequisiteProductsMap = new Map<Id, ccrz__E_RelatedProduct__c>();
                if (currentUser.ContactId != null) {
                    for (ccrz__E_RelatedProduct__c relatedProduct : allRelatedProducts) {
                        allRelatedProductsMap.put(relatedProduct.ccrz__RelatedProduct__c, relatedProduct);
                    }

                    for (ccrz__E_RelatedProduct__c relatedProduct : allPrerequisiteProducts) {
                        allPrerequisiteProductsMap.put(relatedProduct.ccrz__RelatedProduct__c, relatedProduct);
                    }

                    List<ccrz__E_Order__c> userOrders = ACAMSOrderDAO.getOrdersByContactId(currentUser.ContactId);
                    Set<Id> orderIds = new Set<Id>();
                    for (ccrz__E_Order__c order : userOrders) {
                        orderIds.add(order.Id);
                    }
                    List<ccrz__E_OrderItem__c> orderItems = ACAMSOrderDAO.getOrderItems(orderIds);
                    Set<Id> productIds = new Set<Id>();

                    for (ccrz__E_OrderItem__c orderItem : orderItems) {
                        if (orderItem.ccrz__Product__c != null) {
                            productIds.add(orderItem.ccrz__Product__c);
                        }
                    }
                    List<ccrz__E_RelatedProduct__c> userRelatedProducts = ACAMSProductDAO.getReplacementOrUpgradeProducts(productIds);
                    for (ccrz__E_RelatedProduct__c relatedProduct : userRelatedProducts) {
                        allRelatedProductsMap.remove(relatedProduct.ccrz__RelatedProduct__c);
                    }

                    List<ccrz__E_RelatedProduct__c> prerequisiteProducts = ACAMSProductDAO.getPrerequisiteProducts(productIds);
                    for (ccrz__E_RelatedProduct__c relatedProduct : prerequisiteProducts) {
                        allPrerequisiteProductsMap.remove(relatedProduct.ccrz__RelatedProduct__c);
                    }
                }
                List<ccrz__E_RelatedProduct__c> cartPrerequisiteProducts = ACAMSProductDAO.getPrerequisiteProducts(cartItemProductIds);
                Map<Id, ccrz__E_RelatedProduct__c> cartPrerequisiteProductsMap = new Map<Id, ccrz__E_RelatedProduct__c>();
                for (ccrz__E_RelatedProduct__c relatedProduct : cartPrerequisiteProducts) {
                    cartPrerequisiteProductsMap.put(relatedProduct.ccrz__RelatedProduct__c, relatedProduct);
                }

                Boolean upgrade = false;
                Boolean downgrade = false;
                Boolean replacement = false;
                Boolean prerequisite = false;
                for (Object lineItemObject : lineData) {
                    Map<String, Object> lineItem = (Map<String, Object>) lineItemObject;
                    String productId = String.valueOf(lineItem.get('productId'));
                    if (String.isEmpty(productId)) {
                        String sku = String.valueOf(lineItem.get('sku'));
                        lineItemSkus.add(sku);
                        lineItemSkusMap.put(sku, lineItemObject);
                    } else {
                        lineItemIds.add(productId);
                        lineItemMap.put(productId, lineItemObject);
                    }
                }

                if (!lineItemSkus.isEmpty()) {
                    List<ccrz__E_Product__c> products = ACAMSProductDAO.getProductsBySkus(lineItemSkus);
                    for (ccrz__E_Product__c product : products) {
                        lineItemIds.add(product.Id);
                        lineItemMap.put(product.Id, lineItemSkusMap.get(product.ccrz__SKU__c));
                    }
                }
                List<ccrz__E_CompositeProduct__c> compositeProducts = ACAMSProductDAO.getChildProducts(lineItemIds);
                Map<Id, Set<Id>> childProductsMap = new Map<Id, Set<Id>>();
                for (ccrz__E_CompositeProduct__c compositeProduct : compositeProducts) {
                    if (childProductsMap.containsKey(compositeProduct.ccrz__Composite__c)) {
                        Set<Id> childProductIds = childProductsMap.get(compositeProduct.ccrz__Composite__c);
                        childProductIds.add(compositeProduct.ccrz__Component__c);
                        childProductsMap.put(compositeProduct.ccrz__Composite__c, childProductIds);
                    } else {
                        childProductsMap.put(compositeProduct.ccrz__Composite__c, new Set<Id>{
                                compositeProduct.ccrz__Component__c
                        });
                    }
                }
                for (Id productId : lineItemIds) {
                    if (cartItems.isEmpty()) {
                        if (allPrerequisiteProductsMap.containsKey(productId)) {
                            prerequisite = true;
                        } else if (childProductsMap.containsKey(productId)) {
                            Set<Id> comboSet = new Set<Id>();
                            comboSet.addAll(allPrerequisiteProductsMap.keySet());
                            comboSet.retainAll(childProductsMap.get(productId));
                            if (!comboSet.isEmpty()) {
                                for (Id childProductId : comboSet) {
                                    if (allPrerequisiteProductsMap.containsKey(childProductId)) {
                                        if (!childProductsMap.get(productId).contains(allPrerequisiteProductsMap.get(childProductId).ccrz__Product__c)) {
                                            prerequisite = true;
                                            break;
                                        }
                                    }
                                    prerequisite = false;
                                }
                            }
                        } else {
                            newLineData.add(lineItemMap.get(productId));
                        }
                    } else if (upsellMap.containsKey(productId) || downsellMap.containsKey(productId)) {
                        if (upsellMap.containsKey(productId)) {
                            Id tempId = productId;
                            while (upsellMap.containsKey(tempId)) {
                                tempId = upsellMap.get(tempId);
                                if (cartItemMap.containsKey(tempId)) {
                                    Boolean success = removeFromCart(cart.Id, new Set<Id>{
                                            cartItemMap.get(tempId).Id
                                    });
                                    upgrade = success;
                                }
                            }
                        }
                        if (downsellMap.containsKey(productId)) {
                            Id tempId = productId;
                            while (downsellMap.containsKey(tempId)) {
                                tempId = downsellMap.get(tempId);
                                if (cartItemMap.containsKey(tempId)) {
                                    Boolean success = removeFromCart(cart.Id, new Set<Id>{
                                            cartItemMap.get(tempId).Id
                                    });
                                    downgrade = success;
                                }
                            }
                        }
                        if (upgrade || downgrade) {
                            newLineData.add(lineItemMap.get(productId));
                        }
                    } else {
                        if (childProductsMap.containsKey(productId)) {
                            Set<Id> comboSet = new Set<Id>();
                            comboSet.addAll(allPrerequisiteProductsMap.keySet());
                            comboSet.retainAll(childProductsMap.get(productId));
                            if (!comboSet.isEmpty()) {
                                for (Id childProductId : comboSet) {
                                    if (!cartPrerequisiteProductsMap.containsKey(childProductId)) {
                                        prerequisite = true;
                                        break;
                                    }
                                    prerequisite = false;
                                }
                            }
                        }
                    }
                    if (allRelatedProductsMap.containsKey(productId)) {
                        replacement = true;
                    }
                    if (allPrerequisiteProductsMap.containsKey(productId) && !cartPrerequisiteProductsMap.containsKey(productId)) {
                        prerequisite = true;
                    }

                    if (upgrade || downgrade || replacement || prerequisite) {
                        inputData.put('lineData', newLineData);
                        if (upgrade || downgrade) {
                            infoMsg = ACAMSUtil.REPLACE_PRODUCT_MSG;
                        } else if (replacement) {
                            infoMsg = ACAMSUtil.NO_UPGRADE_MSG;
                        } else if (prerequisite) {
                            infoMsg = ACAMSUtil.PREREQUISITE_MSG;
                        }
                    }
                    upgrade = false;
                    downgrade = false;
                    replacement = false;
                    prerequisite = false;
                }
            }
        }

        Map<String, Object> outputData = super.addMajorLineItems(inputData);
        outputData.put('infoMsg', infoMsg);
        return outputData;
    }

    public static Boolean removeFromCart(Id cartId, Set<Id> items) {
        List<ccrz.ccApiCart.LineData> removedLines = new List<ccrz.ccApiCart.LineData>();
        for (String i : items) {
            ccrz.ccApiCart.LineData removeLine = new ccrz.ccApiCart.LineData();
            removeLine.sfid = i;
            removedLines.add(removeLine);
        }

        Map<String, Object> request = new Map<String, Object>{
                ccrz.ccApi.API_VERSION => API_VERSION,
                ccrz.ccApiCart.CART_ID => cartId,
                ccrz.ccApiCart.LINE_DATA => removedLines
        };

        Map<String, Object> response = null;

        try {
            response = ccrz.ccApiCart.removeFrom(request);
            Boolean isSuccess = (Boolean) response.get(ccrz.ccApi.SUCCESS);
            return isSuccess;
        } catch (Exception e) {
            System.debug(System.LoggingLevel.ERROR, e.getMessage());
        }

        return false;
    }

    global override Map<String, Object> setCartItemFields(Map<String, Object> inputData) {
        Map<String, Object> currLineData = (Map<String, Object>) inputData.get(ccrz.ccApiCart.CURR_LINE_DATA);
        if (currLineData != null) {
            Decimal listPrice = (Decimal) currLineData.get('price');
            if (currLineData.containsKey('listPrice')) {
                listPrice = (Decimal) currLineData.get('listPrice');
            }
            String lineDescription = null;
            if (currLineData.containsKey('lineDescription')) {
                lineDescription = (String) currLineData.get('lineDescription');
            }
            ((ccrz__E_CartItem__c) inputData.get(ccrz.ccApiCart.CURR_CARTITEM)).List_Price__c = listPrice;
            ((ccrz__E_CartItem__c) inputData.get(ccrz.ccApiCart.CURR_CARTITEM)).Line_Description__c = lineDescription;
            ccrz__E_Cart__c cartHeader = (ccrz__E_Cart__c) inputData.get('cartHeader');
            if (cartHeader.ccrz__Account__c != null) {
                List<Account> accounts = ACAMSAccountDAO.getAccountsFromIds(new Set<Id>{
                        cartHeader.ccrz__Account__c
                });
                if (!accounts.isEmpty()) {
                    ((ccrz__E_CartItem__c) inputData.get(ccrz.ccApiCart.CURR_CARTITEM)).CC_Account_Group__c =
                            accounts.get(0).ccrz__E_AccountGroup__c;
                }
            }
        }
        Map<String, Object> outputData = super.setCartItemFields(inputData);
        return outputData;
    }

    global override Map<String, Object> concludeAddTo(Map<String, Object> inputData) {
        // Reprice the Cart after every addition
        inputData.put(ccrz.ccApiCart.ISREPRICE, true);
        Map<String, Object> outputData = super.concludeAddTo(inputData);
        Map<String, Object> responseData = (Map<String, Object>) outputData.get('responseData');
        responseData.put('infoMsg', (String) outputData.get('infoMsg'));
        return outputData;
    }
}