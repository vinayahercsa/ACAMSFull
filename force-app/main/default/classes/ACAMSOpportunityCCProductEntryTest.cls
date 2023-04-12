@IsTest
class ACAMSOpportunityCCProductEntryTest {

    @TestSetup
    static void initData() {
        CCACAMSTestUtil testUtil = new CCACAMSTestUtil();
        ACAMSContactAddressTriggerHandler.skipAddressValidation = true;
        Map<String, Object> testData = testUtil.initData();
        ACAMSContactAddressTriggerHandler.skipAddressValidation = false;
        Account testAccount = (Account) testData.get(CCAviTestUtil.PN_USER_ACCOUNT);
        ccrz__E_Cart__c testCart = (ccrz__E_Cart__c) testData.get(CCAviTestUtil.PN_CART);
        ccrz__E_CartItem__c testCartItem = (ccrz__E_CartItem__c) testData.get(CCAviTestUtil.PN_CART_ITEM);
        ccrz__E_PriceList__c testPriceList = (ccrz__E_PriceList__c) testData.get(CCAviTestUtil.PN_PRICE_LIST);
        ccrz__E_Product__c testProduct = (ccrz__E_Product__c) testData.get(CCAviTestUtil.PN_PRODUCT);
        testProduct.ccrz__ProductType__c = 'Product';
        update testProduct;
        ccrz__E_Product__c testBundle = testUtil.createProduct('Test Bundle', 'BUNDLETEST', 'Bundle', 'acams', 'Membership');
        delete testCartItem;
        insert testBundle;
        insert new ccrz__E_CompositeProduct__c(
                ccrz__Composite__c = testBundle.Id,
                ccrz__Component__c = testProduct.Id
        );
        insert testUtil.createPriceListItems(new ccrz__E_Product__c[]{testBundle}, testPriceList);
        ACAMSOpportunityTriggerHandler.skipCartCreationOnInsert = true;
        insert new Opportunity(
                AccountId = testAccount.Id,
                CC_Cart__c = testCart.Id,
                Name = 'Test Opportunity',
                StageName = Opportunity.StageName.getDescribe().getPicklistValues()[0].getValue(),
                CloseDate = Date.today().addDays(10)
        );
        ACAMSOpportunityTriggerHandler.skipCartCreationOnInsert = false;
    }

    @IsTest
    static void initCartController() {
        ccrz__E_Cart__c cart = [
                SELECT Id, ccrz__CartId__c, (
                        SELECT Id
                        FROM Opportunities__r
                )
                FROM ccrz__E_Cart__c
                LIMIT 1
        ];
        ApexPages.StandardController cartStandardController = new ApexPages.StandardController(cart);
        ACAMSOpportunityCCProductEntryController.testSettings.add(new ACAMS_CSR_Settings__mdt(
                Opportunity_Add_Products_Page_Size__c = 5
        ));
        Test.startTest();
        ACAMSOpportunityCCProductEntryController controller = new ACAMSOpportunityCCProductEntryController(
                cartStandardController
        );
        Test.stopTest();
        System.assert(!controller.isError);
        System.assertEquals(1, controller.currentViewId);
        System.assertEquals(5, controller.availableProductList.getPageSize());
        System.assertEquals(2, controller.availableProductList.getRecords().size());
        System.assertEquals(2, controller.productSelectionPageItems.size());
        System.assert(!String.isBlank(controller.getPageTitle()));
        System.assert(!String.isBlank(controller.getPageSubtitle()));
        System.assert(controller.returnToOpportunityPage().getUrl().contains((String) cart.Opportunities__r[0].Id));
    }

    @IsTest
    static void initCartControllerError() {
        ccrz__E_Cart__c cart = [
                SELECT Id, ccrz__CartId__c
                FROM ccrz__E_Cart__c
                LIMIT 1
        ];
        ApexPages.StandardController cartStandardController = new ApexPages.StandardController(cart);
        Test.setCurrentPage(Page.ACAMSOpportunityCCProductEntry);
        Test.startTest();
        ACAMSOpportunityCCProductEntryController controller = new ACAMSOpportunityCCProductEntryController(
                cartStandardController
        );
        System.assert(controller.isError);
        System.assertEquals(1, ApexPages.getMessages().size());
    }

    @IsTest
    static void switchControllerProductSelectionPages() {
        ccrz__E_Cart__c cart = [
                SELECT Id, ccrz__CartId__c
                FROM ccrz__E_Cart__c
                LIMIT 1
        ];
        ApexPages.StandardController cartStandardController = new ApexPages.StandardController(cart);
        ACAMSOpportunityCCProductEntryController.testSettings.add(new ACAMS_CSR_Settings__mdt(
                Opportunity_Add_Products_Page_Size__c = 1
        ));
        Test.startTest();
        ACAMSOpportunityCCProductEntryController controller = new ACAMSOpportunityCCProductEntryController(
                cartStandardController
        );
        System.assertEquals(2, controller.availableProductList.getResultSize());
        Integer firstPageSize = controller.productSelectionPageItems.size();

        controller.productSelectionPageItems[0].selected = true;
        Boolean hasNextPage = controller.availableProductList.getHasNext();
        controller.nextPage();
        Integer secondPageSize = controller.productSelectionPageItems.size();
        Integer selectedSize = controller.selectedProducts.size();
        controller.productSelectionPageItems[0].selected = true;
        Boolean hasPreviousPage = controller.availableProductList.getHasPrevious();
        controller.previousPage();
        Integer allSelectedSize = controller.selectedProducts.size();
        controller.productSelectionPageItems[0].selected = false;
        controller.nextPage();
        controller.productSelectionPageItems[0].selected = false;
        controller.previousPage();
        Integer allDeselectedSize = controller.selectedProducts.size();
        Test.stopTest();
        System.assertEquals(1, firstPageSize);
        System.assertEquals(2, secondPageSize);
        System.assert(hasNextPage);
        System.assert(hasPreviousPage);
        System.assertEquals(1, selectedSize);
        //System.assertEquals(2, allSelectedSize);
        System.assertEquals(0, allDeselectedSize);
    }

    @IsTest
    static void productPriceQuantitySwitch() {
        ccrz__E_Cart__c cart = [
                SELECT Id, ccrz__CartId__c
                FROM ccrz__E_Cart__c
                LIMIT 1
        ];
        ApexPages.StandardController cartStandardController = new ApexPages.StandardController(cart);
        ACAMSOpportunityCCProductEntryController.testSettings.add(new ACAMS_CSR_Settings__mdt(
                Opportunity_Add_Products_Page_Size__c = 5
        ));
        Test.startTest();
        ACAMSOpportunityCCProductEntryController controller = new ACAMSOpportunityCCProductEntryController(
                cartStandardController
        );
        for (
                ACAMSOpportunityCCProductEntryController.CCProductWrapper product : controller.productSelectionPageItems
        ) {
            if (product.product.ccrz__ProductType__c == 'Bundle') {
                product.selected = true;
            }
        }
        controller.proceedToPriceQuantityPage();
        controller.returnToSelection();
        controller.proceedToPriceQuantityPage();
        Integer selectedProductsQuantity = controller.productPriceQuantityPageItems.size();
        controller.productPriceQuantityPageItems[0].cartItem.ccrz__Quantity__c = 1;
        controller.productPriceQuantityPageItems[0].cartItem.ccrz__Price__c = 15;
        Decimal bundlePrice = controller.productPriceQuantityPageItems[0].cartItem.ccrz__Price__c;
        controller.saveOpportunityProducts();
        // FSA-590
        controller.index = '0';
        controller.updateSubPrice();
        Test.stopTest();
        /*
        ccrz__E_CartItem__c bundleCartItem = [
                SELECT ccrz__SubAmount__c, ccrz__ExtSKU__c
                FROM ccrz__E_CartItem__c
                WHERE
                ccrz__Cart__c = :cart.Id
                AND
                ccrz__ParentCartItem__c = NULl
        ];
        System.assertEquals(15, bundleCartItem.ccrz__SubAmount__c);
        System.assert(!String.isBlank(bundleCartItem.ccrz__ExtSKU__c));
        */
    }
}