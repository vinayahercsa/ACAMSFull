@IsTest
class ACAMSAccountAddressBookTriggerHdlerTest {

    @IsTest
    static void testUSAddresses() {
        Account account1 = new Account();
        account1.Name = 'testAccount1';
        insert account1;
        ccrz__E_ContactAddr__c contactAddr = new ccrz__E_ContactAddr__c();
        contactAddr.ccrz__AddressFirstline__c = '776 Brockton Ave';
        contactAddr.ccrz__City__c = 'Abington';
        contactAddr.ccrz__State__c = 'MA';
        contactAddr.ccrz__PostalCode__c = '02351';
        contactAddr.ccrz__CountryISOCode__c = 'US';
        insert contactAddr;
        ccrz__E_AccountAddressBook__c accountAddressBook = new ccrz__E_AccountAddressBook__c();
        accountAddressBook.ccrz__AccountId__c = account1.Id;
        accountAddressBook.ccrz__Account__c = account1.Id;
        accountAddressBook.ccrz__E_ContactAddress__c = contactAddr.Id;
        accountAddressBook.ccrz__Default__c = true;
        insert accountAddressBook;

        Account testAccount = [
                SELECT
                        Id,
                        BillingAddress
                FROM
                        Account
                WHERE
                        Name = 'testAccount1'
       ];

        System.assertEquals('776 Brockton Ave', testAccount.BillingAddress.getStreet());
        System.assertEquals('US', testAccount.BillingAddress.getCountry());
        System.assertEquals('MA', testAccount.BillingAddress.getState());
        System.assertEquals('Abington', testAccount.BillingAddress.getCity());
        System.assertEquals('02351', testAccount.BillingAddress.getPostalCode());
        System.assertEquals('US', testAccount.BillingAddress.getCountryCode());
        System.assertEquals('MA', testAccount.BillingAddress.getStateCode());

        Account account2 = new Account();
        account2.Name = 'testAccount2';
        insert account2;
        ccrz__E_ContactAddr__c contactAddr2 = new ccrz__E_ContactAddr__c();
        contactAddr2.ccrz__AddressFirstline__c = '33 N LaSalle St';
        contactAddr2.ccrz__City__c = 'Chicago';
        contactAddr2.ccrz__State__c = 'IL';
        contactAddr2.ccrz__PostalCode__c = '60602';
        contactAddr2.ccrz__CountryISOCode__c = 'US';
        insert contactAddr2;
        ccrz__E_AccountAddressBook__c accountAddressBook2 = new ccrz__E_AccountAddressBook__c();
        accountAddressBook2.ccrz__AccountId__c = account2.Id;
        accountAddressBook2.ccrz__Account__c = account2.Id;
        accountAddressBook2.ccrz__E_ContactAddress__c = contactAddr2.Id;
        accountAddressBook2.ccrz__Default__c = true;
        insert accountAddressBook2;

        Account testAccount2 = [
                SELECT
                        Id,
                        BillingAddress
                FROM
                        Account
                WHERE
                        Name = 'testAccount2'
        ];

        System.assertEquals('33 N LaSalle St', testAccount2.BillingAddress.getStreet());
        System.assertEquals('US', testAccount2.BillingAddress.getCountry());
        System.assertEquals('IL',testAccount2.BillingAddress.getState());
        System.assertEquals('Chicago', testAccount2.BillingAddress.getCity());
        System.assertEquals('60602', testAccount2.BillingAddress.getPostalCode());
        System.assertEquals('US', testAccount2.BillingAddress.getCountryCode());
        System.assertEquals('IL', testAccount2.BillingAddress.getStateCode());
    }

    @IsTest
    static void testInternationalAddresses() {
        Account account3 = new Account();
        account3.Name = 'testAccount3';
        insert account3;
        ccrz__E_ContactAddr__c contactAddr3 = new ccrz__E_ContactAddr__c();
        contactAddr3.ccrz__AddressFirstline__c = '83 Upper St';
        contactAddr3.ccrz__City__c = 'London';
        contactAddr3.ccrz__PostalCode__c = 'N1 0NU';
        contactAddr3.ccrz__CountryISOCode__c = 'GB';
        insert contactAddr3;
        ccrz__E_AccountAddressBook__c accountAddressBook3 = new ccrz__E_AccountAddressBook__c();
        accountAddressBook3.ccrz__AccountId__c = account3.Id;
        accountAddressBook3.ccrz__Account__c = account3.Id;
        accountAddressBook3.ccrz__E_ContactAddress__c = contactAddr3.Id;
        accountAddressBook3.ccrz__Default__c = true;
        insert accountAddressBook3;

        Account testAccount3 = [
                SELECT
                        Id,
                        BillingAddress
                FROM
                        Account
                WHERE
                        Name = 'testAccount3'
        ];

        System.assertEquals('83 Upper St', testAccount3.BillingAddress.getStreet());
        System.assertEquals('GB', testAccount3.BillingAddress.getCountry());
        System.assertEquals('London', testAccount3.BillingAddress.getCity());
        System.assertEquals('N1 0NU', testAccount3.BillingAddress.getPostalCode());
        System.assertEquals('GB', testAccount3.BillingAddress.getCountryCode());
        System.assertEquals(null, testAccount3.BillingAddress.getStateCode());
        System.assertEquals(null, testAccount3.BillingAddress.getState());

        Account account4 = new Account();
        account4.Name = 'testAccount4';
        insert account4;
        ccrz__E_ContactAddr__c contactAddr4 = new ccrz__E_ContactAddr__c();
        contactAddr4.ccrz__AddressFirstline__c = 'Al Azaritah WA Ash Shatebi, Qism Bab Sharqi';
        contactAddr4.ccrz__City__c = 'Alexandria';
        contactAddr4.ccrz__State__c = 'Alexandria Governorate';
        contactAddr4.ccrz__PostalCode__c = '21526';
        contactAddr4.ccrz__CountryISOCode__c = 'EG';
        insert contactAddr4;
        ccrz__E_AccountAddressBook__c accountAddressBook4 = new ccrz__E_AccountAddressBook__c();
        accountAddressBook4.ccrz__AccountId__c = account4.Id;
        accountAddressBook4.ccrz__Account__c = account4.Id;
        accountAddressBook4.ccrz__E_ContactAddress__c = contactAddr4.Id;
        accountAddressBook4.ccrz__Default__c = true;
        insert accountAddressBook4;

        Account testAccount4 = [
                SELECT
                        Id,
                        BillingAddress
                FROM
                        Account
                WHERE
                        Name = 'testAccount4'
        ];
        System.assertEquals('Al Azaritah WA Ash Shatebi, Qism Bab Sharqi', testAccount4.BillingAddress.getStreet());
        System.assertEquals('EG', testAccount4.BillingAddress.getCountry());
        System.assertEquals('Alexandria', testAccount4.BillingAddress.getCity());
        System.assertEquals('Alexandria Governorate', testAccount4.BillingAddress.getState());
        System.assertEquals('ALX', testAccount4.BillingAddress.getStateCode());
        System.assertEquals('21526', testAccount4.BillingAddress.getPostalCode());
        System.assertEquals('EG', testAccount4.BillingAddress.getCountryCode());
    }

}