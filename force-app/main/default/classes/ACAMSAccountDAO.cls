public with sharing class ACAMSAccountDAO {

    public static List<Account> getPersonAccountsFromIds(Set<Id> idSet) {
        List<Account> accounts = [
                SELECT
                        Id,
                        BillingCountry,
                        BillingState,
                        PersonMailingCountry,
                        PersonMailingState,
                        ccrz__CompanyName__pc,
                        ccrz__E_AccountGroup__c,
                        FirstName,
                        Industry,
                        IsPersonAccount,
                        LastName,
                        PersonContactId,
                        PersonEmail,
                        Phone
                FROM
                        Account
                WHERE
                        Id IN :idSet
                AND
                        IsPersonAccount = TRUE
        ];

        return accounts;
    }

    public static Account getAccountFromId(Id id) {
        Account acc = [
                SELECT
                        Id,
                        BillingCountry,
                        BillingState,
                        BillingStateCode,
                        BillingPostalCode,
                        BillingCountryCode,
                        BillingCity,
                        BillingStreet
                FROM
                        Account
                WHERE
                        Id = :id
                        //AND FSA-485
                        //IsPersonAccount = TRUE
        ];

        return acc;
    }

    public static Contact getContact(Id contactId) {
        Contact contact;
        List<Contact> contacts = [
                SELECT
                        Id,
                        FirstName,
                        LastName,
                        AccountId,
                        Email
                FROM
                        Contact
                WHERE
                        Id = :contactId
        ];
        if (!contacts.isEmpty()) {
            contact = contacts.get(0);
        }

        return contact;
    }

    public static List<Account> getAccountsFromIds(Set<Id> ids) {
        List<Account> accounts = [
                SELECT
                        Id,
                        ccrz__E_AccountGroup__c,
                        Enterprise_Account__c,
                        Parent_Account__pc
                FROM
                        Account
                WHERE
                        Id IN :ids
        ];

        return accounts;
    }

    public static List<Lead> queryLeadsByEmails(List<String> emails) {
        List<Lead> leads = [
                SELECT
                        ConvertedAccountId,
                        Email,
                        Id,
                        Name,
                        Status,
                        OwnerId
                FROM
                        Lead
                WHERE
                        Email IN :emails
        ];
        return leads;
    }

    public static List<Contact> getContactsByContactIds(Set<Id> contactIds) {
        List<Contact> contacts = [
                SELECT
                        Chapter_Member_Expire_Date__c,
                        Member_Expire_Date__c,
                        MLDC_Expiration_Date__c,
                        ACAMS_Today_Expiration_Date__c
                FROM
                        Contact
                WHERE
                        Id IN :contactIds
        ];
        return contacts;
    }

    // FSA-773-a - get account group by name
    public static List<ccrz__E_AccountGroup__c> getAccountGroupByName(Set<String> groupNames){
        List<ccrz__E_AccountGroup__c> accountGroup = [
                SELECT
                        Id,
                        Name,
                        Enterprise_Account__c,
                        Entitlement_Tier__c
                FROM 
                        ccrz__E_AccountGroup__c
                WHERE
                        Name IN : groupNames
        ];

        return accountGroup;
    }

    // FSA-773-a - get account by names
    public static List<Account> getAccountsByName(Set<String> accountNames){
        List<Account> accountList = [
                SELECT
                        Id,
                        Name,
                        BillingCountry,
                        BillingState,
                        BillingStateCode,
                        BillingPostalCode,
                        BillingCountryCode,
                        BillingCity,
                        BillingStreet
                FROM 
                        Account
                WHERE
                        Name IN : accountNames
        ];

        return accountList;
    }

    // FSA-773-a - get account with carts
    public static List<Account> getAccoutsWithCarts(Set<Id> acctIds, Set<Id> cartIds){
        List<Account> accountList = [
                SELECT
                        Id,
                        BillingCountry,
                        BillingState,
                        BillingStateCode,
                        BillingPostalCode,
                        BillingCountryCode,
                        BillingCity,
                        BillingStreet,
                        Top_Parent_Account__c,
                        ccrz__E_AccountGroup__c,
                        ccrz__E_AccountGroup__r.Name,
                (SELECT 
                        Id,
                        Name,
                        ccrz__SubtotalAmount__c
                FROM    ccrz__E_Carts__r
                WHERE   Id
                IN:     cartIds) 
                FROM 
                        Account
                WHERE
                        Id
                IN:     acctIds
        ];

        return accountList;
    }
}