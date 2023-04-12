public without sharing class ACAMSCartDAO {

    public static List<ccrz__E_CartItem__c> getCartItemsByCartId(String cartId) {
        List<ccrz__E_CartItem__c> cartItems = [
                SELECT
                        Name,
                        ccrz__ExtName__c,
                        ccrz__ExtSKU__c,
                        ccrz__ItemStatus__c,
                        ccrz__cartItemType__c,
                        ccrz__ParentCartItem__c,
                        ccrz__Is_Subscription_Selected__c,
                        ccrz__OriginalItemPrice__c,
                        ccrz__Price__c,
                        ccrz__ProductType__c,
                        ccrz__Product__c,
                        ccrz__StoreID__c,
                        ccrz__PricingType__c,
                        ccrz__PrimaryAttr__c,
                        ccrz__Product__r.Name,
                        ccrz__Product__r.ccrz__ProductStatus__c,
                        ccrz__Product__r.ccrz__StartDate__c,
                        ccrz__Product__r.ccrz__EndDate__c,
                        ccrz__Product__r.ccrz__SKU__c,
                        ccrz__Product__r.ccrz__TaxRateId__c,
                        ccrz__Product__r.ccrz__ProductType__c,
                        ccrz__SecondaryAttr__c,
                        ccrz__Seller__c,
                        ccrz__SubProdTerm__c,
                        ccrz__TertiaryAttr__c,
                        ccrz__OriginalQuantity__c,
                        ccrz__Quantity__c,
                        ccrz__UnitOfMeasure__c,
                        ccrz__SubAmount__c,
                        ccrz__ItemTotal__c,
                        ccrz__RequestDate__c,
                        ccrz__Cart__c,
                        ccrz__Cart__r.ccrz__EncryptedId__c,
                        ccrz__Cart__r.Name,
                        Auto_Renew_Subscription__c,
                        CC_Account_Group__c,
                        List_Price__c,
                        Line_Description__c
                FROM
                        ccrz__E_CartItem__c
                WHERE
                        ccrz__Cart__c = :cartId
                OR
                        ccrz__Cart__r.ccrz__EncryptedId__c = :cartId
        ];

        return cartItems;
    }

    // FSA-773-a - update added new field ccrz__Account__r.ccrz__E_AccountGroup__c
    public static List<ccrz__E_Cart__c> getCartsByIds(Set<String> cartIds) {
        List<ccrz__E_Cart__c> carts = [
                SELECT
                        OwnerId,
                        Name,
                        ccrz__EncryptedId__c,
                        ccrz__ActiveCart__c,
                        ccrz__CartStatus__c,
                        ccrz__CartType__c,
                        ccrz__SubtotalAmount__c,
                        ccrz__Name__c,
                        ccrz__TaxExemptFlag__c,
                        ccrz__TotalAmount__c,
                        ccrz__CurrencyISOCode__c,
                        ccrz__TaxSubTotalAmount__c,
                        ccrz__TotalQuantity__c,
                        ccrz__Account__c,
                        isDrupalCallCompleted__c,
                        ccrz__Account__r.Top_Parent_Account__c,
                        ccrz__Account__r.purchasedMembership__c, // FSA-1378
                        ccrz__Account__r.ccrz__E_AccountGroup__c,
                        ccrz__Account__r.ccrz__E_AccountGroup__r.Name,
                        ccrz__AnonymousId__c,
                        ccrz__RepricedDate__c,
                        ccrz__ShipComplete__c,
                        ccrz__Storefront__c,
                        ccrz__User__c,
                        ccrz__User__r.Membership_Level__c,
                        ccrz__User__r.Membership_Type__c,
                        ccrz__User__r.Membership_Level_Text__c,
                        ccrz__ValidationStatus__c,
                        LastModifiedDate,
                (SELECT 
                        Product_Level_1__c,
                        ccrz__Cart__c 
                FROM    ccrz__E_CartItems__r) 
                FROM    ccrz__E_Cart__c
                WHERE
                        Id IN :cartIds
                OR
                        ccrz__EncryptedId__c IN :cartIds
        ];

        return carts;
    }

    public static ccrz__E_Cart__c getCartById(String cartId) {

        ccrz__E_Cart__c cart = null;

        List<ccrz__E_Cart__c> cartList = [
                SELECT
                        Id,
                        Name,
                        Cart_Items_Taxes__c,
                        ccrz__Name__c,
                        ccrz__Account__c,
                        ccrz__Account__r.ccrz__TaxExemptAccount__c,
                        ccrz__ActiveCart__c,
                        ccrz__CartStatus__c,
                        ccrz__CartType__c,
                        ccrz__CurrencyISOCode__c,
                        ccrz__BillTo__c,
                        ccrz__BillTo__r.ccrz__CountryISOCode__c,
                        ccrz__BillTo__r.ccrz__City__c,
                        ccrz__BillTo__r.ccrz__PostalCode__c,
                        ccrz__BillTo__r.ccrz__StateISOCode__c,
                        ccrz__BillTo__r.ccrz__AddressFirstline__c,
                        ccrz__ShipTo__r.ccrz__FirstName__c,
                        ccrz__ShipTo__r.ccrz__MiddleName__c,
                        ccrz__ShipTo__r.ccrz__LastName__c,
                        ccrz__ShipTo__r.ccrz__AddressFirstline__c,
                        ccrz__ShipTo__r.ccrz__AddressSecondline__c,
                        ccrz__ShipTo__r.ccrz__AddressThirdline__c,
                        ccrz__ShipTo__r.ccrz__City__c,
                        ccrz__ShipTo__r.ccrz__State__c,
                        ccrz__ShipTo__r.ccrz__StateISOCode__c,
                        ccrz__ShipTo__r.ccrz__Country__c,
                        ccrz__ShipTo__r.ccrz__CountryISOCode__c,
                        ccrz__ShipTo__r.ccrz__PostalCode__c,
                        ccrz__ShipTo__r.ccrz__DaytimePhone__c,
                        ccrz__ShipTo__r.ccrz__HomePhone__c,
                        ccrz__ShipTo__r.ccrz__Email__c,
                        ccrz__ShipTo__r.OwnerId,
                        ccrz__ShipTo__r.ccrz__Partner_Id__c,
                        ccrz__ShipTo__r.ccrz__AddrReadOnly__c,
                        ccrz__ShipTo__r.ccrz__CompanyName__c,
                        ccrz__ShipTo__r.ccrz__MailStop__c,
                        ccrz__ShipTo__r.ccrz__ShippingComments__c,
                        ccrz__TaxAmount__c,
                        ccrz__ShipTo__r.CreatedById,
                        ccrz__ShipAmount__c,
                        ccrz__SubtotalAmount__c,
                (SELECT
                        ccrz__Product__c,
                        ccrz__Product__r.Name,
                        ccrz__Product__r.ccrz__SKU__c,
                        ccrz__Product__r.ccrz__ShippingWeight__c,
                        ccrz__Product__r.ccrz__TaxRateId__c,
                        ccrz__Product__r.ccrz__ProductType__c,
                        ccrz__Price__c,
                        ccrz__Quantity__c,
                        ccrz__ItemTotal__c,
                        ccrz__ProductType__c,
                        ccrz__SubAmount__c
                FROM
                        ccrz__E_CartItems__r),

                (SELECT
                        ccrz__CartCouponId__c,
                        ccrz__Coupon__c,
                        ccrz__Coupon__r.ccrz__CouponType__c,
                        ccrz__Coupon__r.ccrz__CurrencyISOCode__c,
                        ccrz__Coupon__r.ccrz__DiscountAmount__c,
                        ccrz__Coupon__r.ccrz__DiscountType__c,
                        ccrz__Coupon__r.ccrz__RuleType__c,
                        ccrz__Coupon__r.ccrz__Rule__c
                FROM
                        ccrz__E_CartCoupons__r)
                FROM
                        ccrz__E_Cart__c
                WHERE
                        Id  = :cartId
        ];

        if (!cartList.isEmpty()) {
            cart = cartList[0];
        }

        return cart;
    }

    public static List<ccrz__E_CartItem__c> getMinorCartItemsByParent(Set<Id> parentCartItemIds) {
        List<ccrz__E_CartItem__c> cartItems = [
                SELECT
                        Id,
                        ccrz__Quantity__c,
                        ccrz__ParentCartItem__c
                FROM
                        ccrz__E_CartItem__c
                WHERE
                        ccrz__ParentCartItem__c IN :parentCartItemIds
        ];
        return cartItems;
    }
}