public with sharing class ACAMSCsrService {
    public static final String STOREFRONT_NAME_ACAMS = 'acams';

    @TestVisible
    private static final String NON_MEMBER_PRICELIST_NAME = 'nonmembertest';

    private static ACAMS_CSR_Settings__mdt csrSettings;
    private static ccrz__E_PriceList__c nonMemberPricelist;

    public static void initCsrCallContext(Account effectiveAccount, String cartEncryptedId, Id contactId) {
        ccrz.cc_CallContext.storefront = STOREFRONT_NAME_ACAMS;
        ccrz.cc_CallContext.currAccount = effectiveAccount;
        ccrz.cc_CallContext.currAccountId = effectiveAccount.Id;
        ccrz.cc_CallContext.currUserId = UserInfo.getUserId();
        ccrz.cc_CallContext.currUser = new User(
                Id = UserInfo.getUserId(),
                FirstName = UserInfo.getFirstName(),
                LastName = UserInfo.getLastName(),
                Username = UserInfo.getUserName(),
                Email = UserInfo.getUserName()
        );
        ccrz.cc_CallContext.currCartId = cartEncryptedId;
        if (contactId != null) {
            ccrz.cc_CallContext.currContact = ACAMSAccountDAO.getContact(contactId);
        }
    }

    public static ACAMS_CSR_Settings__mdt getSettings() {
        if (ACAMSCsrService.csrSettings == null) {
            ACAMS_CSR_Settings__mdt[] settingsList = [
                    SELECT Private_Pricelist_Name__c
                    FROM ACAMS_CSR_Settings__mdt
                    LIMIT 1
            ];
            if (!settingsList.isEmpty()) {
                ACAMSCsrService.csrSettings = settingsList[0];
            } else if (Test.isRunningTest()) {
                ACAMSCsrService.csrSettings = new ACAMS_CSR_Settings__mdt(
                        Private_Pricelist_Name__c = NON_MEMBER_PRICELIST_NAME
                );
            }
        }
        return ACAMSCsrService.csrSettings;
    }

    public static ccrz__E_PriceList__c getNonMemberPricelist() {
        ACAMS_CSR_Settings__mdt csrSettings = ACAMSCsrService.getSettings();
        if (ACAMSCsrService.nonMemberPricelist == null && !String.isBlank(csrSettings.Private_Pricelist_Name__c)) {
            ccrz__E_PriceList__c[] nonMemberPricelists = [
                    SELECT
                            Name, ccrz__CurrencyISOCode__c, ccrz__CustomerTypeCode__c, ccrz__DataId__c, ccrz__Desc__c,
                            ccrz__Enabled__c, ccrz__PricelistId__c, ccrz__Seller__c, ccrz__SupplierKey__c
                    FROM ccrz__E_PriceList__c
                    WHERE Name = :csrSettings.Private_Pricelist_Name__c
            ];
            if (!nonMemberPricelists.isEmpty()) {
                ACAMSCsrService.nonMemberPricelist = nonMemberPricelists[0];
            }
        }
        return ACAMSCsrService.nonMemberPricelist;
    }
}