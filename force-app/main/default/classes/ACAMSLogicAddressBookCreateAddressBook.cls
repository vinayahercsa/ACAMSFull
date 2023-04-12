global with sharing class ACAMSLogicAddressBookCreateAddressBook extends ccrz.ccLogicAddressBookCreateAddressBook {
    /**
     * This method sets the ccrz__Account__c field to the value of the ccrz__AccountId__c field so that Accounts can be
     * properly linked on the ccrz__E_AccountAddressBook__c objects.
     *
     * @param inputData
     *
     * @return The created ccrz__E_AccountAddressBook__c object
     */
    public override Map<String, Object> createAddressBook(Map<String, Object> inputData) {
        List<ccrz__E_AccountAddressBook__c> abToInsert = (List<ccrz__E_AccountAddressBook__c>) inputData.get(ccrz.ccAPIAddressBook.AB_TO_INSERT);
        for (ccrz__E_AccountAddressBook__c ab : abToInsert) {
            ab.ccrz__Account__c = ab.ccrz__AccountId__c;
        }
        inputData.put(ccrz.ccAPIAddressBook.AB_TO_INSERT, abToInsert);
        Map<String, Object> outputData = super.createAddressBook(inputData);
        return outputData;
    }
}