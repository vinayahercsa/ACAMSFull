trigger ACAMSCaseTrigger on Case (before insert, before update, after insert) {
    if (!String.valueOf(UserInfo.getProfileId()).contains(String.valueOf(System.Label.Data_Migration_Profile_Id))) {
        (new ACAMSCaseTriggerHandler()).run();
    }
}