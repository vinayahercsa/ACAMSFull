@IsTest
private class ACAMSLogicAddressBookCreateAddressBkTest {
    static CCAviTestUtil util = new CCAviTestUtil();

    @IsTest
    static void testAddressBookCreate() {
        Map<String, Object> testData = util.initData();
        Account account = (Account) testData.get(CCAviTestUtil.PN_USER_ACCOUNT);
        ccrz__E_ContactAddr__c contactAddr = (ccrz__E_ContactAddr__c) testData.get(CCAviTestUtil.PN_CONTACT_ADDRESS);
        User user = (User) testData.get(CCAviTestUtil.PN_PORTAL_USER);

        System.runAs(user) {
            Map<String, Object> addressBookToInsert = new Map<String, Object>{
                    'EContactAddress' => contactAddr.Id,
                    'accountId' => account.Id
            };
            List<ccrz__E_AccountAddressBook__c> accountAddressBooks = new List<ccrz__E_AccountAddressBook__c>();
            ccrz__E_AccountAddressBook__c accountAddressBook = new ccrz__E_AccountAddressBook__c(
                    ccrz__AccountId__c = account.Id,
                    ccrz__E_ContactAddress__c = contactAddr.Id,
                    ccrz__Owner__c = user.Id
            );
            accountAddressBooks.add(accountAddressBook);

            Map<String, Object> inputData = (new Map<String, Object>{
                    ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                    ccrz.ccAPIAddressBook.ADDRESSBOOKS => new List<Map<String, Object>>{
                            addressBookToInsert
                    },
                    ccrz.ccAPIAddressBook.AB_TO_INSERT => accountAddressBooks
            });


            ACAMSLogicAddressBookCreateAddressBook acamsLogicAddressBookCreateAddressBook = new ACAMSLogicAddressBookCreateAddressBook();
            Map<String, Object> outputData = acamsLogicAddressBookCreateAddressBook.createAddressBook(inputData);
            if (outputData.get(ccrz.ccAPIAddressBook.AB_TO_INSERT) != null) {
                List<ccrz__E_AccountAddressBook__c> addressBookList = (List<ccrz__E_AccountAddressBook__c>) outputData.get(ccrz.ccAPIAddressBook.AB_TO_INSERT);
                ccrz__E_AccountAddressBook__c addressBook = addressBookList.get(0);
                String accountId = (String) addressBook.ccrz__Account__c;
                System.assertEquals(accountId, account.Id);
            }
        }
    }
}