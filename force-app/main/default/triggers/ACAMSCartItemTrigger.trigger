trigger ACAMSCartItemTrigger on ccrz__E_CartItem__c (before insert, before update, after update, after insert, after delete) {
    // FSA-773-a - fire condition changed
    if (!String.valueOf(UserInfo.getProfileId()).contains(String.valueOf(System.Label.Data_Migration_Profile_Id))) {
        (new ACAMSCartItemTriggerHandler()).run();
    }
}