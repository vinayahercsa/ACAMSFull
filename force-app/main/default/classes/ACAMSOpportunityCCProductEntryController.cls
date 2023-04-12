public with sharing class ACAMSOpportunityCCProductEntryController {

    private static final Integer PRODUCT_SELECTION_VIEW_ID = 1;
    private static final Integer PRODUCT_PRICE_QUANTITY_VIEW_ID = 2;

    private static final String PRODUCT_TYPE_PRODUCT = 'Product';
    private static final String PRODUCT_TYPE_BUNDLE = 'Bundle';
    private static final String PRODUCT_TYPE_KIT = 'Kit';

    private static final Set<String> AVAILABLE_PRODUCT_TYPES = new Set<String>{
            PRODUCT_TYPE_PRODUCT,
            PRODUCT_TYPE_BUNDLE,
            PRODUCT_TYPE_KIT
    };

    public class CCProductWrapper {
        public Boolean selected { get; set; }

        public Boolean isExternal { get; set; }
        public Boolean isSubItem { get; set; }
        public Boolean renderPrice { get; set; }
        public Decimal quantity { get; set; }

        public CCProductWrapper parentProduct { get; set; }
        public CCProductWrapper[] childProducts { get; set; }

        public ccrz__E_Product__c product { get; set; }
        public ccrz__E_PriceListItem__c priceListItem { get; set; }

        public ccrz__E_CartItem__c cartItem { get; set; }

        public Id subProdTermId { get; set; }

        public List<SelectOption> subProdTermsOptions { get; set; }

        public CCProductWrapper() {
            this.renderPrice = true;
            this.isSubItem = false;
        }
    }

    public class PageException extends Exception {
    }

    // resources

    public Integer currentViewId { get; set; }

    public ACAMS_CSR_Settings__mdt settings { get; set; }
    public Boolean isError { get; set; }

    public ccrz__E_Cart__c targetCart { get; set; }
    public Opportunity targetOpportunity { get; set; }
    public Quote targetQuote { get; set; }

    public ApexPages.StandardSetController availableProductList { get; set; }
    public Map<Id, CCProductWrapper> selectedProducts = new Map<Id, CCProductWrapper>();

    public String getPageTitle() {
        String title = '';
        if (this.targetQuote != null) {
            title = Label.OpportunityCCProduct_TitleQuote;
        } else {
            title = Label.OpportunityCCProduct_TitleOpportunity;
        }
        return String.format(
                title,
                new String[]{
                        this.targetOpportunity.Name, this.targetQuote.Name
                }
        );
    }
    public String getPageSubtitle() {
        if (this.targetCart != null &&
                this.targetCart.ccrz__Account__r != null &&
                this.targetCart.ccrz__Account__r.ccrz__E_AccountGroup__r != null) {
            return String.format(
                    Label.OpportunityCCProduct_Subtitle,
                    new String[]{
                            this.targetCart.ccrz__Account__r.ccrz__E_AccountGroup__r.Name
                    }
            );
        } else {
            return '';
        }
    }

    public Boolean getIsProductSelectionView() {
        return this.currentViewId == PRODUCT_SELECTION_VIEW_ID;
    }

    public Boolean getIsProductPriceQuantityView() {
        return this.currentViewId == PRODUCT_PRICE_QUANTITY_VIEW_ID;
    }

    public String searchTerm { get; set; }
    public CCProductWrapper[] productSelectionPageItems { get; set; }
    public CCProductWrapper[] productPriceQuantityPageItems { get; set; }
    public String index { get; set; }

    // constructors

    public ACAMSOpportunityCCProductEntryController(ApexPages.StandardController ccCartController) {
        this.isError = false;
        this.searchTerm = '';
        try {
            initCcCart(ccCartController.getId());
            this.currentViewId = PRODUCT_SELECTION_VIEW_ID;
            initSettings();
            initAvailableProductList();
            initProductSelectionPageItems();
        } catch (PageException e) {
            this.isError = true;
            showError(e.getMessage());
        }
    }

    @TestVisible
    private static ACAMS_CSR_Settings__mdt[] testSettings =
            new ACAMS_CSR_Settings__mdt[]{
            };

    public void initSettings() {
        ACAMS_CSR_Settings__mdt[] settingsAvailable;
        if (Test.isRunningTest()) {
            settingsAvailable = testSettings;
        } else {
            settingsAvailable = [
                    SELECT Opportunity_Add_Products_Page_Size__c
                    FROM ACAMS_CSR_Settings__mdt
                    LIMIT 1
            ];
        }
        if (settingsAvailable.isEmpty()) {
            throw new PageException(Label.OpportunityCCProduct_SettingsNotFoundError);
        } else {
            this.settings = settingsAvailable[0];
        }
    }

    private void initCcCart(Id cartId) {
        try {
            this.targetCart = [
                    SELECT
                            Id, Name, ccrz__ActiveCart__c, ccrz__EncryptedId__c,
                            ccrz__Account__r.ccrz__E_AccountGroup__r.Name, (
                            SELECT Id, Name, AccountId, Account.Name
                            FROM Opportunities__r
                            LIMIT 1
                    ), (
                            SELECT
                                    Id, Name, OpportunityId, Opportunity.Name,
                                    Opportunity.AccountId, Opportunity.Account.Name
                            FROM Quotes__r
                            LIMIT 1
                    )
                    FROM ccrz__E_Cart__c
                    WHERE Id = :cartId
            ];
        } catch (QueryException e) {
            throw new PageException(e.getMessage());
        }
        if (this.targetCart.Opportunities__r.isEmpty() && this.targetCart.Quotes__r.isEmpty()) {
            throw new PageException(Label.OpportunityCCProduct_UnexpectedError);
        }
        if (!this.targetCart.Quotes__r.isEmpty()) {
            this.targetQuote = this.targetCart.Quotes__r[0];
            this.targetOpportunity = this.targetQuote.Opportunity;
        } else if (!this.targetCart.Opportunities__r.isEmpty()) {
            this.targetOpportunity = this.targetCart.Opportunities__r[0];
        }
    }

    private void initAvailableProductList() {
        ACAMSCsrService.initCsrCallContext(this.targetOpportunity.Account, this.targetCart.ccrz__EncryptedId__c, null);
        Map<Id, ccrz__E_Product__c> productMap = ACAMSOpportunityCCProductEntryDAO.getProducts(
                AVAILABLE_PRODUCT_TYPES,
                this.searchTerm
        );
        availableProductList = new ApexPages.StandardSetController(productMap.values());
        availableProductList.setPageSize(this.settings.Opportunity_Add_Products_Page_Size__c.intValue());
    }

    private void initProductSelectionPageItems() {
        this.productSelectionPageItems = new CCProductWrapper[]{
        };
        ccrz__E_Product__c[] currentPageProducts = (ccrz__E_Product__c[]) this.availableProductList.getRecords();
        for (ccrz__E_Product__c currentPageProduct : currentPageProducts) {
            addProductSelectionPageItem(currentPageProduct, this.productSelectionPageItems, this.selectedProducts);
        }
        // FSA-590
        this.productSelectionPageItems = deDuplicateProdWrapper(this.productSelectionPageItems);
    }

    private void addProductSelectionPageItem(
            ccrz__E_Product__c currentPageProduct,
            CCProductWrapper[] targetList,
            Map<Id, CCProductWrapper> selectedProducts
    ) {
        if (isListNotEmpty(currentPageProduct.ccrz__E_PriceListItems__r)) {
            CCProductWrapper currentPageItemWrapper = new CCProductWrapper();
            currentPageItemWrapper.product = currentPageProduct;
            currentPageItemWrapper.priceListItem = currentPageProduct.ccrz__E_PriceListItems__r[0];
            currentPageItemWrapper.selected = selectedProducts.containsKey(currentPageProduct.Id);
            //ACR - 3054 The product kit value needs to be revised and this function needs to changed
            currentPageItemWrapper.renderPrice = true; //!isProductKit(currentPageProduct);
            if (!currentPageProduct.ccrz__SubProdTerms__r.isEmpty()) {
                currentPageItemWrapper.subProdTermsOptions = new List<SelectOption>();
                for (ccrz__E_SubProdTerm__c subProdTerm : currentPageProduct.ccrz__SubProdTerms__r) {
                    if (subProdTerm.ccrz__CCSubProdTerm__c == null) {
                        currentPageItemWrapper.subProdTermsOptions.add(new SelectOption(subProdTerm.Id, subProdTerm.Name));
                    }
                }
            }
            
            targetList.add(currentPageItemWrapper);
            addMinorProductSelectionPageItems(currentPageItemWrapper, targetList);
            
        }
    }

    // FSA-590 untility method, overriden contains method
    private CCProductWrapper[] deDuplicateProdWrapper(CCProductWrapper[] productList){
        if(productList == null || productList.size() <= 0){
            return null;
        }
        else{
            for(Integer i=0; i < productList.size(); i++){
                for(Integer j=i+1; j < productList.size(); j++){
                    if(productList[i]?.product?.ccrz__SKU__c != null && productList[j]?.product?.ccrz__SKU__c != null &&  productList[i]?.product?.ccrz__SKU__c == productList[j]?.product?.ccrz__SKU__c){
                        productList.remove(j);
                    }
                }
            }
            return productList;
        }
    }

    private void addMinorProductSelectionPageItems(
            CCProductWrapper currentPageItemWrapper,
            CCProductWrapper[] targetList
    ) {
        if (isListNotEmpty(currentPageItemWrapper.product.ccrz__CompositeProducts__r)) {
            currentPageItemWrapper.childProducts = new CCProductWrapper[]{
            };
            for (ccrz__E_CompositeProduct__c composite : currentPageItemWrapper.product.ccrz__CompositeProducts__r) {
                if (isListNotEmpty(composite.ccrz__Component__r.ccrz__E_PriceListItems__r)) {
                    CCProductWrapper childProductWrapper = new CCProductWrapper();
                    //ACR - 3054: This is the main reason for the product to not be carted.
                    //childProductWrapper.isSubItem = true;
                    childProductWrapper.parentProduct = currentPageItemWrapper;
                    childProductWrapper.product = composite.ccrz__Component__r;
                    childProductWrapper.quantity = composite.ccrz__Quantity__c;
                    childProductWrapper.priceListItem = composite.ccrz__Component__r.ccrz__E_PriceListItems__r[0];
                    //ACR - 3054: This method process needs to be revised.
                    childProductWrapper.renderPrice = true; //!isProductBundle(currentPageItemWrapper.product);
                    currentPageItemWrapper.childProducts.add(childProductWrapper);
                    targetList.add(childProductWrapper);
                }
            }
        }
    }

    private void initProductPriceQuantityPageItems() {
        if (this.productPriceQuantityPageItems == null) {
            this.productPriceQuantityPageItems = new CCProductWrapper[]{
            };
        }
        Map<Id, CCProductWrapper> productPriceQuantityPageMap = new Map<Id, CCProductWrapper>();
        for (CCProductWrapper productPriceQuantityPageItem : this.productPriceQuantityPageItems) {
            if (!productPriceQuantityPageItem.isSubItem) {
                productPriceQuantityPageMap.put(productPriceQuantityPageItem.product.Id, productPriceQuantityPageItem);
            }
        }
        for (CCProductWrapper currentPageItem : this.selectedProducts.values()) {
            if (!productPriceQuantityPageMap.containsKey(currentPageItem.product.Id)) {
                currentPageItem.cartItem = new ccrz__E_CartItem__c(
                        ccrz__Price__c = currentPageItem.priceListItem.ccrz__Price__c,
                        ccrz__OriginalItemPrice__c = currentPageItem.priceListItem.ccrz__Price__c,
                        ccrz__Quantity__c = 1,
                        ccrz__ExtName__c = '',
                        ccrz__SubProdTerm__c = currentPageItem.subProdTermId
                );
                productPriceQuantityPageMap.put(currentPageItem.product.Id, currentPageItem);
            }
        }
        for (Id priceQuantityPageItemId : productPriceQuantityPageMap.keySet()) {
            if (!this.selectedProducts.containsKey(priceQuantityPageItemId)) {
                productPriceQuantityPageMap.remove(priceQuantityPageItemId);
            }
        }
        this.productPriceQuantityPageItems = new CCProductWrapper[]{
        };
        for (CCProductWrapper selectedProduct : productPriceQuantityPageMap.values()) {
            this.productPriceQuantityPageItems.add(selectedProduct);
            if (selectedProduct.childProducts != null && !selectedProduct.childProducts.isEmpty()) {
                this.productPriceQuantityPageItems.addAll(selectedProduct.childProducts);
            }
        }
    }

    // actions

    public void nextPage() {
        applySelectionChange();
        this.availableProductList.next();
        initProductSelectionPageItems();
    }

    public void previousPage() {
        applySelectionChange();
        this.availableProductList.previous();
        initProductSelectionPageItems();
    }

    public void applySearch() {
        applySelectionChange();
        initAvailableProductList();
        initProductSelectionPageItems();
    }

    public Integer getSelectedItemsAmount() {
        return this.selectedProducts.size();
    }

    public void proceedToPriceQuantityPage() {
        applySelectionChange();
        this.productSelectionPageItems = null;
        this.currentViewId = PRODUCT_PRICE_QUANTITY_VIEW_ID;
        initProductPriceQuantityPageItems();
    }

    public void returnToSelection() {
        this.currentViewId = PRODUCT_SELECTION_VIEW_ID;
        this.availableProductList.setPageNumber(1);
        initProductSelectionPageItems();
    }

    public PageReference returnToOpportunityPage() {
        PageReference opportunityLink;
        if (this.targetOpportunity != null) {
            opportunityLink = new PageReference('/' + this.targetOpportunity.Id);
            opportunityLink.setRedirect(true);
        }
        return opportunityLink;
    }

    public PageReference returnToQuotePage() {
        PageReference quoteLink;
        if (this.targetQuote != null) {
            quoteLink = new PageReference('/' + this.targetQuote.Id);
            quoteLink.setRedirect(true);
        }
        return quoteLink;
    }

    public PageReference saveOpportunityProducts() {
        List<Map<String, Object>> newCartItems = new List<Map<String, Object>>();
        for (CCProductWrapper newProductItem : this.productPriceQuantityPageItems) {
            if (!newProductItem.isSubItem) {
                Map<String, Object> newCartItem = new Map<String, Object>();
                newCartItem.put(ccrz.ccApiCart.LINE_DATA_PRODUCT_SFID, newProductItem.product.Id);
                newCartItem.put(ccrz.ccApiCart.LINE_DATA_QUANTITY, newProductItem.cartItem.ccrz__Quantity__c);
                newProductItem.isExternal = false;
                if (newProductItem.cartItem.ccrz__OriginalItemPrice__c != newProductItem.cartItem.ccrz__Price__c) {
                    newProductItem.isExternal = true;
                }
                newCartItem.put(ccrz.ccApiCart.LINE_DATA_SUBPRODTERM_SFID, newProductItem.cartItem.ccrz__SubProdTerm__c);
                Decimal itemsTotalPrice = newProductItem.cartItem.ccrz__Price__c;
                if (newProductItem.product.ccrz__ProductType__c == PRODUCT_TYPE_KIT) {
                    itemsTotalPrice = 0;
                    for (CCProductWrapper subItem : newProductItem.childProducts) {
                        itemsTotalPrice = itemsTotalPrice + subItem.priceListItem.ccrz__Price__c;
                    }
                }
                if (newProductItem.isExternal) {
                    newCartItem.put(ccrz.ccApiCart.LINE_DATA_PRICE, itemsTotalPrice);
                    newCartItem.put(ccrz.ccApiCart.LINE_DATA_EXT_NAME, newProductItem.product.Name);
                    newCartItem.put(ccrz.ccApiCart.LINE_DATA_EXT_SKU, newProductItem.product.ccrz__SKU__c);
                }
                newCartItem.put('listPrice', newProductItem.cartItem.ccrz__OriginalItemPrice__c);
                newCartItem.put('lineDescription', newProductItem.cartItem.Line_Description__c);
                newCartItems.add(newCartItem);
            }
        }
        if (!this.targetCart.ccrz__ActiveCart__c) {
            this.targetCart.ccrz__ActiveCart__c = true;
            update this.targetCart;
        }
        Map<String, Object> cartParams = new Map<String, Object>{
                ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                ACAMSLogicCartAddTo.PARAM_SKIP_CART_ACTIVE_SEARCH_FLOW => true,
                ccrz.ccApiCart.CART_ENCID => this.targetCart.ccrz__EncryptedId__c,
                ccrz.ccApiCart.LINE_DATA => newCartItems
        };
        System.Savepoint sp = Database.setSavepoint();
        try {
            Account effectiveAccount = null;
            if (this.targetOpportunity != null) {
                effectiveAccount = this.targetOpportunity.Account;
            }
            ACAMSCsrService.initCsrCallContext(effectiveAccount, this.targetCart.ccrz__EncryptedId__c, null);
            Map<String, Object> createResults = ccrz.ccApiCart.addTo(cartParams);
            this.isError = !(Boolean) createResults.get(ccrz.ccApi.SUCCESS);
            if (this.isError) {
                System.debug(LoggingLevel.ERROR, JSON.serialize(createResults));
                throw new PageException(Label.OpportunityCCProduct_UnexpectedError);
            }
        } catch (Exception e) {
            this.isError = true;
            Database.rollback(sp);
            showError(e.getMessage());
            showError(e.getStackTraceString());
        }
        if (!this.isError) {
            if (this.targetQuote != null) {
                return returnToQuotePage();
            } else {
                return returnToOpportunityPage();
            }
        } else {
            return null;
        }
    }

    public void updateSubPrice() {
        ACAMSCsrService.initCsrCallContext(this.targetOpportunity.Account, this.targetCart.ccrz__EncryptedId__c, null);
        Account account = [
                SELECT Id, ccrz__E_AccountGroup__c FROM Account WHERE Id = :ccrz.cc_CallContext.currAccountId
        ];
        ccrz__E_AccountGroup__c accountGroup = [
                SELECT Id, (SELECT Id, ccrz__PriceList__c FROM ccrz__E_AccountGroupPriceLists__r)
                FROM ccrz__E_AccountGroup__c
                WHERE Id = :account.ccrz__E_AccountGroup__c
        ];
        Set<Id> priceListIds = new Set<Id>();
        for (ccrz__E_AccountGroupPriceList__c accountGroupPriceList : accountGroup.ccrz__E_AccountGroupPriceLists__r) {
            priceListIds.add(accountGroupPriceList.ccrz__PriceList__c);
        }
        CCProductWrapper productWrapper = this.productPriceQuantityPageItems.get(Integer.valueOf(this.index));
        ccrz__E_Product__c product = [
                SELECT Id, (
                    SELECT Id, ccrz__Price__c
                    FROM ccrz__E_PriceListItems__r
                    WHERE ccrz__SubProdTerm__c = :productWrapper.cartItem.ccrz__SubProdTerm__c
                    AND ccrz__PriceList__c IN :priceListIds
                    ORDER BY ccrz__Price__c
                    LIMIT 1
                    )
                FROM ccrz__E_Product__c
                WHERE Id = :productWrapper.product.Id
        ];
        if (!product.ccrz__E_PriceListItems__r.isEmpty()) {
            productWrapper.priceListItem.ccrz__Price__c = product.ccrz__E_PriceListItems__r[0].ccrz__Price__c;
            productWrapper.cartItem.ccrz__Price__c = product.ccrz__E_PriceListItems__r[0].ccrz__Price__c;
            productWrapper.cartItem.ccrz__OriginalItemPrice__c = product.ccrz__E_PriceListItems__r[0].ccrz__Price__c;
        }
    }

    // util methods

    private void applySelectionChange() {
        for (CCProductWrapper currentPageItem : this.productSelectionPageItems) {
            if (!currentPageItem.isSubItem) {
                if (currentPageItem != null && currentPageItem.selected != null && currentPageItem.selected) {
                    this.selectedProducts.put(currentPageItem.product.Id, currentPageItem);
                } else {
                    this.selectedProducts.remove(currentPageItem.product.Id);
                }
            }
        }
    }

    private Boolean isListNotEmpty(List<Object> listToCheck) {
        return (listToCheck != null && !listToCheck.isEmpty());
    }

    private Boolean isProductBundle(ccrz__E_Product__c product) {
        return product.ccrz__ProductType__c == PRODUCT_TYPE_BUNDLE;
    }

    private Boolean isProductKit(ccrz__E_Product__c product) {
        return product.ccrz__ProductType__c == PRODUCT_TYPE_KIT;
    }

    private void showError(String errorMessage) {
        if (errorMessage == null) {
            errorMessage = Label.OpportunityCCProduct_UnexpectedError;
        }
        ApexPages.addMessage(
                new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage)
        );
    }
}