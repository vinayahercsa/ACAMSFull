public with sharing class ACAMSAddressHelper {

    public static void updateAccountAddressInfo(List<ccrz__E_AccountAddressBook__c> addressBookList) {
        Map<String, Account> accountIdToAccountObjectMap = new Map<String, Account>();
        Set<Id> accountAddressBookAccountIdSet = new Set<Id>();
        Set<Id> accountAddressBookIdSet = new Set<Id>();
        Map<Id, Account> accountAddressBookIdToAccountMap = new Map<Id, Account>();
        Map<Id, ccrz__E_ContactAddr__c> accountAddressBookToContactAddressMap = new Map<Id, ccrz__E_ContactAddr__c>();
        for (ccrz__E_AccountAddressBook__c accountAddressBook : addressBookList) {
            accountAddressBookAccountIdSet.add(accountAddressBook.ccrz__AccountId__c);
            accountAddressBookIdSet.add(accountAddressBook.ccrz__E_ContactAddress__c);
        }
        List<Account> accountsFromAddressBooks =
                ACAMSAccountDAO.getAccountsFromIds(accountAddressBookAccountIdSet);
        for (ccrz__E_AccountAddressBook__c accountAddressBook : addressBookList) {
            for (Account account : accountsFromAddressBooks) {
                if (accountAddressBook.ccrz__Account__c == account.Id) {
                    accountAddressBookIdToAccountMap.put(accountAddressBook.Id, account);
                    break;
                }
            }
        }
        List<ccrz__E_ContactAddr__c> contactAddrs =
                ACAMSContactAddressDAO.getContactAddrsByIds(accountAddressBookIdSet);
        for (ccrz__E_AccountAddressBook__c accountAddressBook : addressBookList) {
            for (ccrz__E_ContactAddr__c contactAddr : contactAddrs) {
                if (accountAddressBook.ccrz__E_ContactAddress__c == contactAddr.Id) {
                    accountAddressBookToContactAddressMap.put(accountAddressBook.Id, contactAddr);
                    break;
                }
            }
        }
        try {
            for (ccrz__E_AccountAddressBook__c accountAddressBook : addressBookList) {
                if (accountAddressBook.ccrz__Default__c == true) {
                    Account associatedAccount = accountAddressBookIdToAccountMap.get(accountAddressBook.Id);
                    ccrz__E_ContactAddr__c contactAddr =
                            accountAddressBookToContactAddressMap.get(accountAddressBook.Id);
                    if (accountAddressBook.ccrz__AddressType__c == 'Billing' || String.isEmpty(accountAddressBook.ccrz__AddressType__c)) {
                        associatedAccount.BillingCity = contactAddr.ccrz__City__c;
                        associatedAccount.BillingCountry = contactAddr.ccrz__Country__c != null ?
                                contactAddr.ccrz__Country__c : contactAddr.ccrz__CountryISOCode__c;
                        associatedAccount.BillingCountryCode = contactAddr.ccrz__CountryISOCode__c;
                        associatedAccount.BillingState = contactAddr.ccrz__State__c;
                        associatedAccount.BillingPostalCode = contactAddr.ccrz__PostalCode__c;
                        associatedAccount.BillingStateCode = contactAddr.ccrz__StateISOCode__c;
                        String billingStreet = contactAddr.ccrz__AddressFirstline__c;
                        if (String.isNotBlank(contactAddr.ccrz__AddressSecondline__c)) {
                            billingStreet = billingStreet + '\n' + contactAddr.ccrz__AddressSecondline__c;
                        }
                        if (String.isNotBlank(contactAddr.ccrz__AddressThirdline__c)) {
                            billingStreet = billingStreet + '\n' + contactAddr.ccrz__AddressThirdline__c;
                        }
                        associatedAccount.BillingStreet = billingStreet;
                    } else if (accountAddressBook.ccrz__AddressType__c == 'Shipping') {
                        associatedAccount.ShippingCity = contactAddr.ccrz__City__c;
                        associatedAccount.ShippingCountry = contactAddr.ccrz__Country__c != null ?
                                contactAddr.ccrz__Country__c : contactAddr.ccrz__CountryISOCode__c;
                        associatedAccount.ShippingCountryCode = contactAddr.ccrz__CountryISOCode__c;
                        associatedAccount.ShippingState = contactAddr.ccrz__State__c;
                        associatedAccount.ShippingPostalCode = contactAddr.ccrz__PostalCode__c;
                        associatedAccount.ShippingStateCode = contactAddr.ccrz__StateISOCode__c;
                        String shippingStreet = contactAddr.ccrz__AddressFirstline__c;
                        if (String.isNotBlank(contactAddr.ccrz__AddressSecondline__c)) {
                            shippingStreet = shippingStreet + '\n' + contactAddr.ccrz__AddressSecondline__c;
                        }
                        if (String.isNotBlank(contactAddr.ccrz__AddressThirdline__c)) {
                            shippingStreet = shippingStreet + '\n' + contactAddr.ccrz__AddressThirdline__c;
                        }
                        associatedAccount.ShippingStreet = shippingStreet;
                    }
                    accountIdToAccountObjectMap.put(accountAddressBook.ccrz__AccountId__c, associatedAccount);
                }
            }
            update accountIdToAccountObjectMap.values();
        } catch (Exception e) {
            System.debug('ERROR: ' + e.getMessage());
        }
    }

}