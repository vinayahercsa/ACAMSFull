trigger ACAMSQuoteTrigger on Quote (after insert, before update, after update) {
    if (!String.valueOf(UserInfo.getProfileId()).contains(String.valueOf(System.Label.Data_Migration_Profile_Id))) {
        (new ACAMSQuoteTriggerHandler()).run();
    }
}