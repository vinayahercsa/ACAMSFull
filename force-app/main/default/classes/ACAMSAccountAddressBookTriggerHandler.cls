public with sharing class ACAMSAccountAddressBookTriggerHandler extends CCAviTriggerHandler {
    private List<ccrz__E_AccountAddressBook__c> newList = (List<ccrz__E_AccountAddressBook__c>) Trigger.new;

    protected override void beforeInsert() {
        for (ccrz__E_AccountAddressBook__c addrBook : newList) {
            try {
                // Convert 15 character IDs to 18 characters
                addrBook.ccrz__AccountId__c = (Id) addrBook.ccrz__AccountId__c;
            } catch (Exception e) {
                System.debug('ACAMSAccountAddressBookTriggerHandler::beforeInsert - ' + addrBook.ccrz__AccountId__c +
                        ' is not a valid ID');
            }
        }
    }

    protected override void afterInsert() {
        ACAMSAddressHelper.updateAccountAddressInfo(newList);
    }

    protected override void afterUpdate() {
        ACAMSAddressHelper.updateAccountAddressInfo(newList);
    }

}