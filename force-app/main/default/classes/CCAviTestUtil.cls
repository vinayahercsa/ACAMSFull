/*
 * This class provides utility methods used by test classes.  Each storefront should have
 * its own extension for this class.  The constructor should not be overridden unless
 * the overriding class calls the super constructor.  Extending classes must implement the
 * configureSettings() method.
 *
 * The following is an example for a fictitious storefront
 * named "CloudBurst". Note the abbrevation for "CloudBurst" used here is "CB" in the class
 * name.
 *
 * public without sharing class CCCBTestUtil extends CCAviTestUtil {
 *   public override void configureSettings() {
 *      STOREFRONT = 'DefaultStore';
 *      COMMUNITY_PROFILE = 'CloudCraze Customer Community User';
 *      GUEST_USER_PROFILE = 'CloudBurst Customer Community Profile';
 *      DEFAULT_PRICE_METHOD = CCAviTestUtilSettings.PRICE_METHOD_BEST;
 *      COMMUNITY_NAME = 'CloudBurst Customer Community';
 *   }
 * }
 *
*/
public virtual without sharing class CCAviTestUtil {

    /*
    * Properties for the map entries
    */
    public static final String PN_STOREFRONT_SETTINGS = 'storefrontSettings';
    public static final String PN_USER_PROFILE = 'userProfile';
    public static final String PN_USER_ACCOUNT_GROUP = 'userAccountGroup';
    public static final String PN_USER_ACCOUNT = 'userAccount';
    public static final String PN_USER_CONTACT = 'userContact';
    public static final String PN_PORTAL_USER = 'portalUser';
    public static final String PN_CONTACT_ADDRESS = 'contactAddress';
    public static final String PN_ACCOUNT_ADDRESS_BOOKS = 'accountAddressBooks';
    public static final String PN_PRODUCT = 'product';
    public static final String PN_SUBPRODUCT = 'subprodterm';
    public static final String PN_PARENT_PRODUCT = 'parentProduct';
    public static final String PN_PRODUCT_LIST = 'productList';
    public static final String PN_SPEC = 'spec';
    public static final String PN_PRODUCT_SPECS = 'productSpecs';
    public static final String PN_CATEGORY = 'category';
    public static final String PN_PRODUCT_CATEGORY = 'productCategory';
    public static final String PN_PRICE_LIST = 'priceList';
    public static final String PN_ACCOUNT_GROUP_PRICE_LIST = 'accountGroupPriceList';
    public static final String PN_PRICE_LIST_ITEMS = 'priceListItems';
    public static final String PN_CART = 'cart';
    public static final String PN_CART_ITEM = 'cartItem';
    public static final String PN_ORDER = 'order';
    public static final String PN_ORDER_ITEMS = 'orderItems';
    public static final String PN_SHIPPING_ADDRESS_BOOK = 'shippingAddressBook';
    public static final String PN_BILLING_ADDRESS_BOOK = 'billingAddressBook';
    public static final String PN_SHIPPING_CONTACT_ADDRESS = 'shippingContactAddress';
    public static final String PN_BILLING_CONTRACT_ADDRESS = 'billingContactAddress';
    public static final String PN_TRANSACTION_PAYMENT_AUTH = 'transactionPaymentAuth';
    public static final String PN_TRANSACTION_PAYMENT_CAPTURE = 'transactionPaymentCapture';

    /*
    *   These settings must be set by the extending class.
    */
    // The CloudCraze Storefront name. Case-sensitive
    public String STOREFRONT { get; set; }

    // The Profile name for the authenticated user
    public String COMMUNITY_PROFILE { get; set; }

    // The Profile name for the anonymous user.
    public String GUEST_USER_PROFILE { get; set; }

    // The name of the Community
    public String COMMUNITY_NAME { get; set; }

    // The username of the site guest user. This is in email format.
    public String GUEST_USERNAME { get; set; }

    // The default pricing method to use
    public String DEFAULT_PRICE_METHOD { get; set; }

    // A unique key used to build external ids
    public String KEY { get; set; }

    public CCAviTestUtil() {
        System.assert(Test.isRunningTest(), 'CCAviTestUtil may only be used by test classes.');

        configureSettings();

        GUEST_USERNAME = getGuestUsername();
    }

    public virtual void configureSettings() {
        // These settings are configured in CCAviTestUtilSettings, or in extensions for this class
        COMMUNITY_PROFILE = CCAviTestUtilSettings.DEFAULT_COMMUNITY_PROFILE;
        GUEST_USER_PROFILE = CCAviTestUtilSettings.DEFAULT_GUEST_USER_PROFILE;
        COMMUNITY_NAME = CCAviTestUtilSettings.DEFAULT_COMMUNITY_NAME;
        STOREFRONT = CCAviTestUtilSettings.DEFAULT_STOREFRONT;
        DEFAULT_PRICE_METHOD = CCAviTestUtilSettings.DEFAULT_PRICE_METHOD;
        KEY = String.valueOf(Datetime.now().getTime());
    }

    // This method must return the Name field of the Site Guest User
    // for the community. If the
    public String getGuestUsername() {
        User u = [
                SELECT
                        Username
                FROM
                        User
                WHERE
                        Name = :COMMUNITY_NAME + ' Site Guest User'
                LIMIT
                        1
        ];
        return u.Username;
    }

    public virtual CCAviStorefrontSettings__c createStorefrontSettings() {
        CCAviStorefrontSettings__c settings = new CCAviStorefrontSettings__c(
                Name = STOREFRONT
        );
        return settings;
    }

    public void initCallContext() {
        User portalUser = getPortalUser();
        Account userAccount = getAccount();
        Contact userContact = getContact();
        ccrz__E_Cart__c cart = getCart();
        ccrz.cc_RemoteActionContext rac = new ccrz.cc_RemoteActionContext();
        rac.storefront = STOREFRONT;
        rac.effAccountId = userAccount.Id;
        rac.portalUserId = portalUser.Id;
        rac.currentCartId = cart.ccrz__EncryptedId__c;
        ccrz.cc_CallContext.initRemoteContext(rac);
        ccrz.ccContext ctx = new ccrz.ccContext();
        ctx.portalUserId = portalUser.Id;
        ctx.storefront = STOREFRONT;
        ccrz.cc_CallContext.initContext(ctx);
        /*ccrz.cc_CallContext.storefront = STOREFRONT;
        ccrz.cc_CallContext.currAccount = userAccount;
        ccrz.cc_CallContext.currAccountId = userAccount.Id;
        ccrz.cc_CallContext.currUserId = portalUser.Id;
        ccrz.cc_CallContext.currUser = portalUser;
        ccrz.cc_CallContext.currContact = userContact;
        ccrz.cc_CallContext.currCartId = cart.ccrz__EncryptedId__c;*/
    }

    public Profile getCustomerCommunityProfile() {
        Profile p;
        try {
            p = [
                    SELECT
                            Id
                            ,Name
                    FROM
                            Profile
                    WHERE
                            Name = :COMMUNITY_PROFILE
                    LIMIT
                            1
            ];
        } catch (Exception e) {
            System.assertNotEquals(null, p, 'You must create a profile named ' + COMMUNITY_PROFILE + ' or modify this test case.');
        }
        return p;
    }

    public virtual ccrz__E_AccountGroup__c createAccountGroup(String groupName, String priceMethod) {
        if (priceMethod == null) {
            priceMethod = DEFAULT_PRICE_METHOD;
        }

        ccrz__E_AccountGroup__c actGrp = new ccrz__E_AccountGroup__c(
                Name = groupName,
                ccrz__PriceListSelectionMethod__c = priceMethod
        );
        return actGrp;
    }

    public virtual Account createAccount(ccrz__E_AccountGroup__c accountGroup) {
        Account a1 = new Account (Name = 'Test Account');
        a1.BillingState = 'IL';
        a1.BillingCountry = 'US';
        if (accountGroup != null) {
            a1.ccrz__E_AccountGroup__c = accountGroup.Id;
        }
        return a1;
    }

    public virtual ccrz__E_PriceList__c createPriceList(String plName, String storefront) {
        ccrz__E_PriceList__c pl = new ccrz__E_PriceList__c(
                Name = plName,
                ccrz__CurrencyISOCode__c = 'USD',
                ccrz__Enabled__c = true,
                ccrz__StartDate__c = Date.today(),
                ccrz__EndDate__c = Date.today().addDays(30),
                ccrz__Storefront__c = storefront
        );
        return pl;
    }

    public virtual ccrz__E_AccountGroupPriceList__c createAccountGroupPriceList(ccrz__E_AccountGroup__c accountGroup, ccrz__E_PriceList__c priceList) {
        ccrz__E_AccountGroupPriceList__c agpl = new ccrz__E_AccountGroupPriceList__c (
                ccrz__AccountGroup__c = accountGroup.Id,
                ccrz__Pricelist__c = priceList.Id,
                ccrz__Sequence__c = 100,
                ccrz__Enable__c = true,
                ccrz__StartDate__c = Date.today(),
                ccrz__EndDate__c = Date.today().addDays(30)
        );
        return agpl;
    }

    public virtual List<ccrz__E_PriceListItem__c> createPriceListItems(List<ccrz__E_Product__c> products, ccrz__E_PriceList__c priceList) {
        List<ccrz__E_PriceListItem__c> pliList = new List<ccrz__E_PriceListItem__c>();
        for (ccrz__E_Product__c prod : products) {
            ccrz__E_PriceListItem__c item = new ccrz__E_PriceListItem__c(
                    ccrz__EndDate__c = Date.today().addDays(30),
                    ccrz__Price__c = 10,
                    ccrz__Pricelist__c = priceList.Id,
                    ccrz__Product__c = prod.Id,
                    ccrz__StartDate__c = Date.today(),
                    ccrz__UnitOfMeasure__c = 'Each'
            );
            pliList.add(item);
        }
        return pliList;
    }

    public virtual Contact createContact(Account a, String emailAddress) {
        Contact con = new Contact(
                FirstName = 'Test',
                LastName = 'User',
                AccountId = a.Id,
                Email = emailAddress
        );
        return con;
    }

    public virtual User createUser(Profile p, Contact c, String username, String emailAddress, String firstName, String lastName, String alias) {
        User u = new User(
                FirstName = firstName,
                LastName = lastName,
                Email = emailAddress,
                Alias = alias,
                Username = username,
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'GMT',
                ProfileId = p.Id,
                LanguageLocaleKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ContactId = c.Id
        );
        return u;
    }

    public virtual ccrz__E_Product__c createProduct(String name, String sku, String productType, String storefront, String level) {
        if (productType == null) {
            productType = 'Product';
        }
        // Create Product
        ccrz__E_Product__c prod = new ccrz__E_Product__c();
        prod.Name = name;
        prod.ccrz__SKU__c = sku;
        prod.ccrz__ProductType__c = productType;
        prod.ccrz__ProductStatus__c = 'Released';
        prod.ccrz__Storefront__c = storefront;
        prod.Level_1__c = level;
        return prod;
    }

    public virtual ccrz__E_Product__c createProduct(String name, String sku, String storefront, String level) {
        return createProduct(name, sku, 'Product', storefront, level);
    }

    public virtual ccrz__E_Product__c createProduct(String name, String sku, String level) {
        return createProduct(name, sku, STOREFRONT, level);
    }

    public virtual ccrz__E_Spec__c createSpec(String name, String description, String displayName, Integer sequence, String specGroup, Boolean isVisible) {
        ccrz__E_Spec__c spec = new ccrz__E_Spec__c();
        spec.Name = name;
        spec.ccrz__Desc__c = description;
        spec.ccrz__DisplayName__c = displayName;
        spec.ccrz__IsVisibleInCatalog__c = isVisible;
        spec.ccrz__Sequence__c = sequence;
        spec.ccrz__SpecGroup__c = specGroup;
        return spec;
    }

    public virtual List<ccrz__E_ProductSpec__c> createProductSpecs(ccrz__E_Product__c product, Map<ccrz__E_Spec__c, String> specToValueMap) {
        List<ccrz__E_ProductSpec__c> prodSpecList = new List<ccrz__E_ProductSpec__c>();
        ccrz__E_ProductSpec__c newProdSpec;
        for (ccrz__E_Spec__c theSpec : specToValueMap.keySet()) {
            newProdSpec = new ccrz__E_ProductSpec__c(
                    ccrz__Product__c = product.Id,
                    ccrz__Spec__c = theSpec.Id,
                    ccrz__SpecValue__c = specToValueMap.get(theSpec)
            );
            prodSpecList.add(newProdSpec);
        }
        return prodSpecList;
    }

    public virtual ccrz__E_SubProdTerm__c createSubProdTerm(ccrz__E_Product__c product) {
		ccrz__E_SubProdTerm__c subProdterm = new ccrz__E_SubProdTerm__c();
        subProdterm.Name = 'year';
        subProdterm.ccrz__CCProduct__c = product.id;
        subProdterm.ccrz__EffectiveStart__c =system.now();
        subProdterm.ccrz__EffectiveEnd__c = system.now() +1;

        return subProdterm;
    }

    // Create contact address - owner is the portal user or guest (Site Guest User)
    // cart and order link to CC Contact Address for billto/shipto.
    public virtual ccrz__E_ContactAddr__c createContactAddress(User portalUser, String line1, String line2, String line3, String city, String state, String country, String postalCode) {
        ccrz__E_ContactAddr__c addr = new ccrz__E_ContactAddr__c(
                OwnerId = portalUser.Id,
                ccrz__AddressFirstline__c = line1,
                ccrz__AddressSecondline__c = line2,
                ccrz__AddressThirdline__c = line3,
                ccrz__City__c = city,
                ccrz__State__c = state,
                ccrz__Country__c = country,
                ccrz__CountryISOCode__c = 'US',
                ccrz__PostalCode__c = postalCode
        );
        return addr;
    }

    public enum ADDRESS_TYPE {
        BILLING, SHIPPING
    }
    public static final Map<ADDRESS_TYPE, String> ADDRESS_TYPE_MAP = new Map<ADDRESS_TYPE, String>{
            ADDRESS_TYPE.BILLING => 'Billing',
            ADDRESS_TYPE.SHIPPING => 'Shipping'
    };

    public virtual ccrz__E_AccountAddressBook__c createAccountAddressBook(Account acct, ADDRESS_TYPE addrType, ccrz__E_ContactAddr__c contactAddr, User portalUser, Boolean isDefault) {
        String addressType = ADDRESS_TYPE_MAP.get(addrType);

        ccrz__E_AccountAddressBook__c addrBook = new ccrz__E_AccountAddressBook__c(
                ccrz__Account__c = acct.Id,
                ccrz__AccountId__c = acct.Id,
                ccrz__AddressType__c = addressType, // Billing/Shipping
                ccrz__E_ContactAddress__c = contactAddr.Id,
                ccrz__Default__c = isDefault,
                ccrz__Owner__c = portalUser.Id
        );
        return addrBook;
    }

    // Type = Cart/Wishlist
    public virtual ccrz__E_Cart__c createCart(Account acct, ccrz__E_ContactAddr__c billToAddr, ccrz__E_ContactAddr__c shipToAddr, User portalUser, Contact portalContact, String cartType, String storefront) {
        String cartName = 'Shopping Cart';

        ccrz__E_Cart__c cart = new ccrz__E_Cart__c(
                ccrz__Account__c = acct.Id,
                ccrz__ActiveCart__c = true,
                ccrz__BillTo__c = billToAddr.Id,
                ccrz__CartStatus__c = 'Open',
                ccrz__CartType__c = cartType,
                ccrz__Contact__c = portalContact.Id,
                ccrz__BuyerFirstName__c = portalContact.FirstName,
                ccrz__BuyerLastName__c = portalContact.LastName,
                ccrz__Name__c = cartName,
                ccrz__ShipTo__c = shipToAddr.Id,
                ccrz__Storefront__c = storefront,
                ccrz__CurrencyISOCode__c = 'USD',
                ccrz__User__c = portalUser.Id,
                ccrz__CartId__c = 'Cart' + KEY,
                ccrz__EncryptedId__c = 'enc123'
        );

        return cart;
    }

    public virtual ccrz__E_CartItem__c createCartItem(ccrz__E_Cart__c cart, Decimal price, Decimal quantity, ccrz__E_Product__c product, ccrz__E_CartItem__c parentCartItem) {
        ccrz__E_CartItem__c cartItem = new ccrz__E_CartItem__c(
                ccrz__Cart__c = cart.Id,
                ccrz__Price__c = price,
                ccrz__Quantity__c = quantity,
                ccrz__SubAmount__c = price * quantity,
                ccrz__cartItemType__c = product.ccrz__ProductType__c, // Major/Minor/Coupon
                ccrz__ProductType__c = product.ccrz__ProductType__c, // Major/Minor/Coupon
                ccrz__Product__c = product.Id,
                ccrz__UnitOfMeasure__c = 'Each',
                ccrz__ItemStatus__c = 'Available',
                ccrz__CartItemId__c = 'CartItem' + KEY
        );
        if (parentCartItem != null) {
            cartItem.ccrz__ParentCartItem__c = parentCartItem.Id;
        }
        return cartItem;
    }

    public virtual ccrz__E_Category__c createCategory(String categoryId) {
        ccrz__E_Category__c category = new ccrz__E_Category__c(
                ccrz__CategoryID__c = categoryId
        );
        return category;
    }

    public virtual ccrz__E_ProductCategory__c createProductCategory(ccrz__E_Product__c product, String productCategoryId, ccrz__E_Category__c category) {
        ccrz__E_ProductCategory__c productCategory = new ccrz__E_ProductCategory__c (
                ccrz__Category__c = category.Id,
                ccrz__Product__c = product.Id,
                ccrz__ProductCategoryId__c = productCategoryId
        );
        return productCategory;
    }


    public virtual ccrz__E_Order__c createOrder(Id cartId, Id accountId, Id contactId, Id ownerId, Id shipToId, Id billToId) {
        ccrz__E_Order__c theOrder = new ccrz__E_Order__c();
        theOrder.ccrz__OriginatedCart__c = cartId;
        theOrder.ccrz__Account__c = accountId;
        theOrder.ccrz__Contact__c = contactId;
        theOrder.OwnerId = ownerId;
        theOrder.ccrz__ShipTo__c = shipToId;
        theOrder.ccrz__BillTo__c = billToId;
        theOrder.ccrz__EncryptedId__c = 'encOrder123';
        theOrder.ccrz__Storefront__c = STOREFRONT;
        //Assumes CC sets the orderdate to the date of order.....
        theOrder.ccrz__OrderDate__c = Date.today();
        theOrder.ccrz__OrderStatus__c = 'In Process';
        theOrder.ccrz__OrderNumber__c = 12345;
        return theOrder;

    }

    public static ccrz__E_OrderItem__c createOrderItem(Id orderId, String orderItemId, String lineType, Id productId, Id parentOrderItemId, Id parentProductId, Decimal price, Decimal quantity, Decimal subAmount) {
        ccrz__E_OrderItem__c oi = new ccrz__E_OrderItem__c();
        oi.ccrz__Order__c = orderId;
        oi.ccrz__OrderItemId__c = orderItemId;
        oi.ccrz__OrderLineType__c = lineType;
        oi.ccrz__Product__c = productId;
        oi.ccrz__ParentOrderItem__c = parentOrderItemId;
        oi.ccrz__ParentProduct__c = parentProductId;
        oi.ccrz__Price__c = price;
        oi.ccrz__Quantity__c = quantity;
        oi.ccrz__SubAmount__c = subAmount;
        oi.ccrz__OrderItemStatus__c = '';
        oi.Total_Item_Taxes__c = 0;
        oi.ccrz__OriginalItemPrice__c = 0;
        return oi;
    }

    public virtual ccrz__E_TransactionPayment__c createTransactionPaymentAuth(Id orderId, String uid) {
        ccrz__E_TransactionPayment__c tp = new ccrz__E_TransactionPayment__c();
        tp.ccrz__CCOrder__c = orderId;
        tp.ccrz__TransactionPaymentId__c = uid;
        tp.ccrz__Amount__c = 1.0;
        tp.ccrz__AccountNumber__c = 'abc';
        tp.ccrz__AccountType__c = 'sopcc';
        tp.ccrz__TransactionCode__c = 'tcode';
        tp.ccrz__ExpirationMonth__c = 12;
        tp.ccrz__ExpirationYear__c = 2016;
        tp.ccrz__TransactionType__c = 'authorization,create_payment_token';

        return tp;
    }

    public virtual ccrz__E_TransactionPayment__c createTransactionPaymentCapture(Id orderId, String uid) {
        ccrz__E_TransactionPayment__c tp = new ccrz__E_TransactionPayment__c();
        tp.ccrz__CCOrder__c = orderId;
        tp.ccrz__TransactionPaymentId__c = uid;
        tp.ccrz__Amount__c = 1.0;
        tp.ccrz__AccountNumber__c = 'abc';
        tp.ccrz__AccountType__c = 'sopcc';
        tp.ccrz__TransactionCode__c = 'tcode';
        tp.ccrz__ExpirationMonth__c = 12;
        tp.ccrz__ExpirationYear__c = 2016;
        tp.ccrz__TransactionType__c = 'capture';

        return tp;
    }

    /**
    * Initialize test data and return a map of objects created. In general, do not override this method
    * if you can override the create*() methods instead.
    *
    * @return Map of objects inserted
    */
    public virtual Map<String, Object> initData() {
        //--- for the user / user set callouts to mulesoft in the triggers.....
        //Test.setMock(HttpCalloutMock.class, new CCCSATestUtil.DummyMock(200, 'OK', ''));

        CCAviStorefrontSettings__c settings = createStorefrontSettings();
        insert settings;

        Profile userProfile = getCustomerCommunityProfile();

        /*
        * Account Group
        */
        ccrz__E_AccountGroup__c userAccountGroup = createAccountGroup('accountGroup', null);
        insert userAccountGroup;

        ccrz__E_AccountGroup__c pnmAccountGroup = createAccountGroup(ACAMSUtil.PORTAL_ACCOUNT, null);
        insert pnmAccountGroup;

        ccrz__E_AccountGroup__c pmAccountGroup = createAccountGroup(ACAMSUtil.PORTAL_ACCOUNT_MEMBER, null);
        insert pmAccountGroup;

        ccrz__E_AccountGroup__c gnmAccountGroup = createAccountGroup(ACAMSUtil.PORTAL_ACCOUNT_GOV, null);
        insert gnmAccountGroup;

        ccrz__E_AccountGroup__c gmAccountGroup = createAccountGroup(ACAMSUtil.PORTAL_ACCOUNT_GOV_MEMBER, null);
        insert gmAccountGroup;

        ccrz__E_AccountGroup__c cmAccountGroup = createAccountGroup(ACAMSUtil.PORTAL_ACCOUNT_CHAPTER_MEMBER, null);
        insert cmAccountGroup;

        ccrz__E_AccountGroup__c gcmAccountGroup = createAccountGroup(ACAMSUtil.PORTAL_ACCOUNT_GOV_CHAPTER_MEMBER, null);
        insert gcmAccountGroup;

        /*
        * Account
        */
        Account userAccount = createAccount(userAccountGroup);
        insert userAccount;

        /*
        * Contact
        */
        Contact userContact = createContact(userAccount, 'contact@email.com');
        insert userContact;

        /*
        * Portal User
        */
        Id curUserId = UserInfo.getUserId();
        User curUser = [SELECT Id FROM User WHERE Id = :curUserId LIMIT 1];
        User portalUser;
        System.runAs(curUser){
            portalUser = createUser(userProfile, userContact, 'username@email.com', 'contact@email.com', 'firstName', 'lastName', 'alias');
            insert portalUser;
        }

        /*
        * Contact Address
        */
        ccrz__E_ContactAddr__c address = createContactAddress(
                portalUser,
                'line1',
                'line2',
                'line3',
                'city',
                'IL',
                'US',
                '11111'
        );
        insert address;

        /*
        * Account Address Book
        */
        List<ccrz__E_AccountAddressBook__c> addrBookList = new List<ccrz__E_AccountAddressBook__c>();
        ccrz__E_AccountAddressBook__c shippingAddressBook = createAccountAddressBook(userAccount,ADDRESS_TYPE.SHIPPING, address, portalUser, true);
        ccrz__E_AccountAddressBook__c billingAddressBook = createAccountAddressBook(userAccount,ADDRESS_TYPE.BILLING, address, portalUser, true);
        addrBookList.add(shippingAddressBook);
        addrBookList.add(billingAddressBook);
        insert addrBookList;

        /*
        * CCRZ Call Context
        */
        /*ccrz.cc_CallContext.currAccount = userAccount;
        ccrz.cc_CallContext.currAccountId = userAccount.Id;
        ccrz.cc_CallContext.currAccountGroup = userAccountGroup;
        ccrz.cc_CallContext.currUserId = portalUser.id;
        ccrz.cc_CallContext.currUser = portalUser;
        ccrz.cc_CallContext.storefront = STOREFRONT;*/

        /*
        * Product
        */
        ccrz__E_Product__c product = createProduct('Product 1', 'product-01', 'Major', STOREFRONT, 'Membership');
        insert product;

        /*
        * Parent Product
        */
        ccrz__E_Product__c parentProduct = createProduct('Parent Product', 'product-02', 'Membership');
        insert parentProduct;

        /*
         * Shipping Cost Product
         */
        ccrz__E_Product__c shpCstProduct = createProduct('Shipping Cost', ACAMSUtil.SHIPPING_PRODUCT_SKU, 'Advertising/Other');
        insert shpCstProduct;

        List<ccrz__E_Product__c> productList = new List<ccrz__E_Product__c>();
        productList.add(product);

        /*
        * Spec
        */
        ccrz__E_Spec__c spec = createSpec('ColorRed', 'The color red', 'Red', 10,  'Color', true);
        insert spec;


        Map<ccrz__E_Spec__c, String> specToValueMap = new Map<ccrz__E_Spec__c, String>{
                spec => 'Red'
        };
        List<ccrz__E_ProductSpec__c> productSpecs = createProductSpecs(product, specToValueMap);
        insert productSpecs;

        /*
        * Category
        */
        ccrz__E_Category__c category = createCategory('300000');
        insert category;

        /*
        * Product Category
        */
        ccrz__E_ProductCategory__c productCategory = createProductCategory(product, '1001', category);
        insert productCategory;
	   /*
 	   * SUbProdTerm
 	   */
 	    ccrz__E_SubProdTerm__c subProdTerm=createSubProdTerm(product);
        insert subProdTerm;
        /*
        * Related Product Group
        */
        /*
        ccrz__E_RelatedProductGroup__c relatedProductGroup = createRelatedProductGroup('group 1', '2001');
        insert relatedProductGroup;
        */

        /*
        * Price List
        */
        ccrz__E_PriceList__c priceList = createPriceList('General', STOREFRONT);
        insert priceList;

        ccrz__E_PriceList__c privatePriceList = createPriceList('Private/Non-Member', STOREFRONT);
        insert privatePriceList;

        ccrz__E_PriceList__c publicPriceList = createPriceList('Government/Non-Member', STOREFRONT);
        insert publicPriceList;

        ccrz__E_PriceList__c privateMemberPriceList = createPriceList('Private/Member', STOREFRONT);
        insert privateMemberPriceList;

        ccrz__E_AccountGroupPriceList__c agrpPriceList =  createAccountGroupPriceList(userAccountGroup, priceList);
        insert agrpPriceList;


        /*
        * Product Media
        */
        /*
        ccrz__E_ProductMedia__c productMedia = createProductMedia(product,'Product Image Thumbnail');
        insert productMedia;
        */

        /*
        * Attachment
        */
        /*
        Attachment attachment = createAttachment('Product Image', productMedia);
        insert attachment;
        */

        /*
        * Price List Item
        */
        List<ccrz__E_PriceListItem__c> priceListItems = createPriceListItems(productList, priceList);
        insert priceListItems;

        List<ccrz__E_PriceListItem__c> privatePriceListItems = createPriceListItems(productList, privatePriceList);
        insert privatePriceListItems;

        List<ccrz__E_PriceListItem__c> publicPriceListItems = createPriceListItems(productList, publicPriceList);
        insert publicPriceListItems;

        List<ccrz__E_PriceListItem__c> privateMemberPriceListItems = createPriceListItems(productList, privateMemberPriceList);
        insert privateMemberPriceListItems;

        /*
        * Composite Products
        */
//        List<ccrz__E_CompositeProduct__c> compositeProducts = createCompositeProducts(productList, parentProduct, relatedProductGroup);
//        insert compositeProducts;

        /*
        * Cart
        */
        ccrz__E_Cart__c cart = createCart(userAccount, address, address, portalUser, userContact, 'Cart', STOREFRONT);
        insert cart;

        /*
        * Cart Item
        * - Normal Cart
        */
        ccrz__E_CartItem__c cartItem = createCartItem(cart, 9.99, 1, product, null);
        insert cartItem;

        /*
        * Order
        *
        */
        ccrz__E_Order__c theOrder = createOrder(cart.Id, userAccount.Id, userContact.Id, portalUser.Id, address.Id, address.Id);
        insert theOrder;

        /*
        * Order Item
        *
        */
        ccrz__E_OrderItem__c parentOrderItem = createOrderItem(theOrder.Id, 'oi1', 'Major', parentProduct.Id, null, null, 1.00, 1, 1.00);
        insert parentOrderItem;
        ccrz__E_OrderItem__c childOrderItem = createOrderItem(theOrder.Id, 'oi2', 'Minor', product.Id, parentOrderItem.Id, parentProduct.Id, 1.00, 1, 1.00);
        insert childOrderItem;
        List<ccrz__E_OrderItem__c> orderItems = new List<ccrz__E_OrderItem__c>();
        orderItems.add(parentOrderItem);
        orderItems.add(childOrderItem);


        ccrz__E_TransactionPayment__c tp = createTransactionPaymentAuth(theOrder.Id, 'uid');
        insert tp;

        ccrz__E_TransactionPayment__c tp2 = createTransactionPaymentCapture(theOrder.Id, 'uid2');
        insert tp2;

        Map<String,Object> resultMap = new Map<String,Object>();
        //resultMap.put('order', theOrder);
        resultMap.put(PN_STOREFRONT_SETTINGS, settings);
        resultMap.put(PN_USER_PROFILE, userProfile);
        resultMap.put(PN_USER_ACCOUNT_GROUP, userAccountGroup);
        resultMap.put(PN_USER_ACCOUNT, userAccount);
        resultMap.put(PN_USER_CONTACT, userContact);
        resultMap.put(PN_PORTAL_USER, portalUser);
        resultMap.put(PN_CONTACT_ADDRESS, address);
        resultMap.put(PN_ACCOUNT_ADDRESS_BOOKS, addrBookList);
        resultMap.put(PN_PRODUCT, product);
        resultMap.put(PN_PARENT_PRODUCT, parentProduct);
        resultMap.put(PN_PRODUCT_LIST, productList);
        resultMap.put(PN_SPEC, spec);
        resultMap.put(PN_PRODUCT_SPECS, productSpecs);
        resultMap.put(PN_CATEGORY, category);
        resultMap.put(PN_PRODUCT_CATEGORY, productCategory);
        resultMap.put(PN_SUBPRODUCT, subprodterm);
        resultMap.put(PN_PRICE_LIST, priceList);
        resultMap.put(PN_ACCOUNT_GROUP_PRICE_LIST, agrpPriceList);
        resultMap.put(PN_PRICE_LIST_ITEMS, priceListItems);
        resultMap.put(PN_CART, cart);
        resultMap.put(PN_CART_ITEM, cartItem);
        resultMap.put(PN_ORDER, theOrder);
        resultMap.put(PN_ORDER_ITEMS, orderItems);
        resultMap.put(PN_SHIPPING_ADDRESS_BOOK, shippingAddressBook);
        resultMap.put(PN_BILLING_ADDRESS_BOOK, billingAddressBook);
        resultMap.put(PN_SHIPPING_CONTACT_ADDRESS, address);
        resultMap.put(PN_BILLING_CONTRACT_ADDRESS, address);
        resultMap.put(PN_TRANSACTION_PAYMENT_AUTH, tp);
        resultMap.put(PN_TRANSACTION_PAYMENT_CAPTURE, tp2);

        return resultMap;
    }

    public virtual ccrz__E_Cart__c getCart() {
        String key = 'Cart' + KEY;

        return [
                SELECT
                        Id,
                        ccrz__EncryptedId__c,
                        ccrz__Account__c,
                        ccrz__ActiveCart__c,
                        ccrz__BillTo__c,
                        ccrz__CartStatus__c,
                        ccrz__CartType__c,
                        ccrz__Contact__c,
                        ccrz__BuyerFirstName__c,
                        ccrz__BuyerLastName__c,
                        ccrz__Name__c,
                        ccrz__ShipTo__c,
                        ccrz__Storefront__c,
                        ccrz__CurrencyISOCode__c,
                        ccrz__User__c
                FROM
                        ccrz__E_Cart__c
                WHERE
                        ccrz__CartId__c = :key
        ];
    }

    public virtual ccrz__E_CartItem__c getCartItem() {
        String key = 'CartItem' + KEY;
        return [
                SELECT
                        Id,
                        ccrz__Cart__c,
                        ccrz__Price__c,
                        ccrz__Quantity__c,
                        ccrz__SubAmount__c,
                        ccrz__cartItemType__c,
                        ccrz__ProductType__c,
                        ccrz__Product__c,
                        ccrz__UnitOfMeasure__c,
                        ccrz__ItemStatus__c
                FROM
                        ccrz__E_CartItem__c
                WHERE
                        ccrz__CartItemId__c = :key
        ];
    }

    public virtual Account getAccount() {
        return [SELECT Id, Name FROM Account WHERE Name = 'Test Account'];
    }

    public virtual Contact getContact() {
        return [SELECT Id, Name FROM Contact WHERE Email = 'contact@email.com'];
    }

    public virtual User getPortalUser() {
        return [SELECT Id, Name, FirstName, LastName, Email, Username, ContactId FROM User WHERE Username = 'username@email.com'];
    }

    public virtual ccrz__E_Order__c getOrder() {
        return [SELECT Id, Name, ccrz__EncryptedId__c FROM ccrz__E_Order__c WHERE ccrz__EncryptedId__c = 'encOrder123'];
    }

    public virtual ccrz__E_Product__c getProduct() {
        return [SELECT Id, Name, ccrz__SKU__c FROM ccrz__E_Product__c WHERE Name = 'Product 1'];
    }
}