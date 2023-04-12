trigger ACAMSAccountAddressBookTrigger on ccrz__E_AccountAddressBook__c (before insert, after insert, after update) {
    if (!String.valueOf(UserInfo.getProfileId()).contains(String.valueOf(System.Label.Data_Migration_Profile_Id))) {
        new ACAMSAccountAddressBookTriggerHandler().run();
    }
}