@IsTest
class ACAMSLogicCartAddToTest {

    @IsTest
    static void fetchCartSkippingActiveCart() {
        CCACAMSTestUtil testUtil = new CCACAMSTestUtil();
        ACAMSContactAddressTriggerHandler.skipAddressValidation = true;
        Map<String, Object> testData = testUtil.initData();
        ACAMSContactAddressTriggerHandler.skipAddressValidation = false;
        Account testAccount = (Account) testData.get(CCAviTestUtil.PN_USER_ACCOUNT);
        ccrz__E_Cart__c testCart = (ccrz__E_Cart__c) testData.get(CCAviTestUtil.PN_CART);
        ccrz__E_ContactAddr__c testAddress = (ccrz__E_ContactAddr__c) testData.get(CCAviTestUtil.PN_CONTACT_ADDRESS);
        User testUser = (User) testData.get(CCAviTestUtil.PN_PORTAL_USER);
        Contact testContact = (Contact) testData.get(CCAviTestUtil.PN_USER_CONTACT);
        testUtil.KEY = String.valueOf(Datetime.now().getTime()+10);
        ccrz__E_Cart__c unactiveCart = testUtil.createCart(
                testAccount,
                testAddress,
                testAddress,
                testUser,
                testContact,
                'Cart',
                testUtil.STOREFRONT
        );
        unactiveCart.ccrz__ActiveCart__c = false;
        unactiveCart.ccrz__EncryptedId__c = 'enc234';
        insert unactiveCart;
        unactiveCart = [
            SELECT Id, ccrz__EncryptedId__c
            FROM ccrz__E_Cart__c
            WHERE Id = :unactiveCart.Id
        ];
        System.debug('testCart ecnID ' + testCart.ccrz__EncryptedId__c + ', id ' + testCart.Id);
        System.debug('unactive ecnID ' + unactiveCart.ccrz__EncryptedId__c + ', id ' + unactiveCart.Id);
        ccrz__E_CartItem__c testItem = (ccrz__E_CartItem__c) testData.get(CCAviTestUtil.PN_CART_ITEM);
        delete testItem;
        ccrz__E_Product__c testProduct = (ccrz__E_Product__c) testData.get(CCAviTestUtil.PN_PRODUCT);
        ACAMSCsrService.initCsrCallContext(testAccount, unactiveCart.ccrz__EncryptedId__c, testContact.Id);
        List<Map<String, Object>> newCartItems = new List<Map<String, Object>>();
        Map<String, Object> newCartItem = new Map<String, Object>();
        newCartItem.put(ccrz.ccApiCart.LINE_DATA_PRODUCT_SFID, testProduct.Id);
        newCartItem.put(ccrz.ccApiCart.LINE_DATA_QUANTITY, 1);
        newCartItems.add(newCartItem);
        Map<String, Object> cartParams = new Map<String, Object>{
            ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
            ACAMSLogicCartAddTo.PARAM_SKIP_CART_ACTIVE_SEARCH_FLOW => true,
            ccrz.ccApiCart.CART_ENCID => unactiveCart.ccrz__EncryptedId__c,
            ccrz.ccApiCart.LINE_DATA => newCartItems
        };
        ACAMSLogicCartAddTo addTo = new ACAMSLogicCartAddTo();
        addTo.fetchCart(cartParams);
        Map<String, Object> response = (Map<String, Object>) cartParams.get(ccrz.ccApiCart.RESPONSE);
        String cartEncId = (String) response.get(ccrz.ccApiCart.CART_ENCID);
        System.assertEquals(unactiveCart.ccrz__EncryptedId__c, cartEncId);
        addTo.addMajorLineItems(cartParams);
    }

}