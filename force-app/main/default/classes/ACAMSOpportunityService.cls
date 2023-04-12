public without sharing class ACAMSOpportunityService {

    public static Boolean replaceOpportunityCartWithQuoteCart(
        Opportunity targetOpportunity,
        Id newOpportunityCartId
    ) {
        initCsrCallContext(targetOpportunity.Id);
        Boolean removalSuccessful = false;
        Id cartToRemoveId = targetOpportunity.CC_Cart__c;
        if (cartToRemoveId != null) {
            cleanCartAddressLookups(cartToRemoveId);
            Map<String, Object> inputData = new Map<String,Object>{
                ccrz.ccApiCart.CART_ID => cartToRemoveId,
                ccrz.ccApi.API_VERSION => 9
            };
            Map<String, Object> outputData = ccrz.ccAPICart.removeCart(inputData);
            removalSuccessful = (Boolean) outputData.get(ccrz.ccApi.SUCCESS);
        } else {
            removalSuccessful = true;
        }
        updateOpportunityCartById(targetOpportunity.Id, newOpportunityCartId);
        return removalSuccessful;
    }

    public static Boolean cloneCartToOpportunity(Opportunity targetOpportunity, Id cartId) {
        initCsrCallContext(targetOpportunity.Id);
        Boolean wasSuccessful = false;
        Map<String, Object> inputData = new Map<String,Object> {
            ccrz.ccApiCart.CART_ID => cartId,
            ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
            ccrz.ccApi.SIZING => new Map<String, Object>{
                ccrz.ccApiCart.ENTITYNAME => new Map<String, Object>{
                    ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_XL
                },
                ccrz.ccApiCart.CLI_ENTITYNAME => new Map<String, Object>{
                    ccrz.ccApi.SZ_DATA => ccrz.ccApi.SZ_XL
                }
            }
        };
        Map<String, Object> outputData = ccrz.ccApiCart.cloneCart(inputData);
        wasSuccessful = (Boolean)outputData.get(ccrz.ccApi.SUCCESS);
        if (wasSuccessful) {
            wasSuccessful = (Boolean)outputData.get(ccrz.ccApi.SUCCESS);
            Id newCartId = (Id) outputData.get(ccrz.ccApiCart.CART_ID);
            updateOpportunityCartById(targetOpportunity.Id, newCartId);
        }
        return wasSuccessful;
    }

    public static Boolean createNewCartForOpportunity(Opportunity targetOpportunity) {
        initCsrCallContext(targetOpportunity.AccountId, null, null, targetOpportunity.Contact__c);
        Boolean wasSuccessful = false;
        Map<String,Object> createResults = ccrz.ccApiCart.create(new Map<String,Object>{
            ccrz.ccApi.API_VERSION => 9
        });
        wasSuccessful = (Boolean)createResults.get(ccrz.ccApi.SUCCESS);
        if (wasSuccessful) {
            String newCartId = (String)createResults.get(ccrz.ccApiCart.CART_ENCID);
            ccrz__E_Cart__c[] newCarts = [
                SELECT Id
                FROM ccrz__E_Cart__c
                WHERE ccrz__EncryptedId__c = :newCartId
                LIMIT 1
            ];

            if (!newCarts.isEmpty()) {
                updateOpportunityCartById(targetOpportunity.Id, newCarts[0].Id);
                updateBillingAddressOnCart(targetOpportunity.AccountId, newCarts[0].Id);
            }
        }
        return wasSuccessful;
    }

    private static void cleanCartAddressLookups(Id cartId) {
        ccrz__E_Cart__c cartToClean = new ccrz__E_Cart__c (
            Id = cartId,
            ccrz__BillTo__c = null,
            ccrz__ShipTo__c = null
        );
        update cartToClean;
    }

    private static void updateOpportunityCartById(Id opportunityId, Id cartId) {
        Opportunity opportunityToUpdate = new Opportunity(
            Id = opportunityId,
            CC_Cart__c = cartId
        );
        update opportunityToUpdate;

        ccrz__E_Cart__c cartToUpdate = new ccrz__E_Cart__c(
                Id = cartId,
                Opportunity__c = opportunityId
        );
        update cartToUpdate;
    }

    private static void updateBillingAddressOnCart(Id accountId, Id cartId) {
        Account linkedAccount = [
                SELECT
                        Id,
                        BillingStreet,
                        BillingState,
                        BillingStateCode,
                        BillingCountry,
                        BillingCountryCode,
                        BillingCity,
                        BillingPostalCode,
            			ShippingStreet,
                        ShippingState,
                        ShippingStateCode,
                        ShippingCountry,
                        ShippingCountryCode,
                        ShippingCity,
                        ShippingPostalCode,
                        Name,
                        FirstName,
            			LastName
                FROM
                        Account
                WHERE
                        Id = :accountId

        ];

        ccrz__E_ContactAddr__c contactAddr = new ccrz__E_ContactAddr__c();
        List<String> splitList = linkedAccount.BillingStreet != null ? linkedAccount.BillingStreet.split('\n') :
                new List<String>();

        switch on splitList.size() {
            when 1 {
                contactAddr.ccrz__AddressFirstline__c = splitList.get(0);
            }
            when 2 {
                contactAddr.ccrz__AddressFirstline__c = splitList.get(0);
                contactAddr.ccrz__AddressSecondline__c = splitList.get(1);
            }
            when 3 {
                contactAddr.ccrz__AddressFirstline__c = splitList.get(0);
                contactAddr.ccrz__AddressSecondline__c = splitList.get(1);
                contactAddr.ccrz__AddressThirdline__c = splitList.get(2);
            }
            when else {
                System.debug('No Billing Street present on account');
            }
        }
        contactAddr.ccrz__City__c = linkedAccount.BillingCity;
        contactAddr.ccrz__Country__c = linkedAccount.BillingCountry;
        contactAddr.ccrz__CountryISOCode__c = linkedAccount.BillingCountryCode;
        contactAddr.ccrz__State__c = linkedAccount.BillingState;
        contactAddr.ccrz__StateISOCode__c = linkedAccount.BillingStateCode;
        contactAddr.ccrz__PostalCode__c = linkedAccount.BillingPostalCode;
        contactAddr.ccrz__FirstName__c = linkedAccount.FirstName != null ? linkedAccount.FirstName : linkedAccount.Name;
        contactAddr.ccrz__LastName__c = linkedAccount.LastName != null ? linkedAccount.LastName : 'Account';
        // CreatingcontactforShippingaddress-FSA-4622
		ccrz__E_ContactAddr__c contactAddr1 = new ccrz__E_ContactAddr__c();
        List<String> splitList1 = linkedAccount.ShippingStreet != null ? linkedAccount.ShippingStreet.split('\n') :
                new List<String>();

        switch on splitList1.size() {
            when 1 {
                contactAddr1.ccrz__AddressFirstline__c = splitList1.get(0);
            }
            when 2 {
                contactAddr1.ccrz__AddressFirstline__c = splitList1.get(0);
                contactAddr1.ccrz__AddressSecondline__c = splitList1.get(1);
            }
            when 3 {
                contactAddr1.ccrz__AddressFirstline__c = splitList1.get(0);
                contactAddr1.ccrz__AddressSecondline__c = splitList1.get(1);
                contactAddr1.ccrz__AddressThirdline__c = splitList1.get(2);
            }
            when else {
                System.debug('No Shipping Street present on account');
            }
        }
        contactAddr1.ccrz__City__c = linkedAccount.ShippingCity;
        contactAddr1.ccrz__Country__c = linkedAccount.ShippingCountry;
        contactAddr1.ccrz__CountryISOCode__c = linkedAccount.ShippingCountryCode;
        contactAddr1.ccrz__State__c = linkedAccount.ShippingState;
        contactAddr1.ccrz__StateISOCode__c = linkedAccount.ShippingStateCode;
        contactAddr1.ccrz__PostalCode__c = linkedAccount.ShippingPostalCode;
        contactAddr1.ccrz__FirstName__c = linkedAccount.FirstName != null ? linkedAccount.FirstName : linkedAccount.Name;
        contactAddr1.ccrz__LastName__c = linkedAccount.LastName != null ? linkedAccount.LastName : 'Account';
        
        List<ccrz__E_ContactAddr__c> contactAddresslistToInsert = new List<ccrz__E_ContactAddr__c>();
        if (contactAddr.ccrz__AddressFirstline__c != null && (contactAddr.ccrz__CountryISOCode__c != null ||
                contactAddr.ccrz__Country__c != null)) {
             contactAddresslistToInsert.add(contactAddr);
        }
        if (contactAddr1.ccrz__AddressFirstline__c != null && (contactAddr1.ccrz__CountryISOCode__c != null ||
                contactAddr1.ccrz__Country__c != null)) {
             contactAddresslistToInsert.add(contactAddr1);
        }
        if(contactAddresslistToInsert.size() > 0 && !contactAddresslistToInsert.isEmpty()){
            insert contactAddresslistToInsert; 
         ccrz__E_Cart__c cartToUpdate = new ccrz__E_Cart__c(Id = cartId);
            if(contactAddr.Id != null){
              cartToUpdate.ccrz__BillTo__c = contactAddr.Id;
            }
             if(contactAddr1.Id != null){
              cartToUpdate.ccrz__ShipTo__c = contactAddr1.Id;
            }
            
            update cartToUpdate;
            
        }
        
         }

    private static void initCsrCallContext(Id accountId, String accountName, String cartEncryptedId, Id contact) {
        Account effectiveAccount = new Account(
            Id = accountId,
            Name = accountName
        );
        ACAMSCsrService.initCsrCallContext(effectiveAccount, cartEncryptedId, contact);
    }

    private static void initCsrCallContext(Id OpportunityId) {
        Opportunity effectiveOpportunity = [
            SELECT Id, Account.Name, AccountId, CC_Cart__r.ccrz__EncryptedId__c, Contact__c
            FROM Opportunity
            WHERE Id = :OpportunityId
        ];
        initCsrCallContext(
            effectiveOpportunity.AccountId,
            effectiveOpportunity.Account.Id,
            effectiveOpportunity.CC_Cart__r.ccrz__EncryptedId__c,
            effectiveOpportunity.Contact__c
        );
    }
}