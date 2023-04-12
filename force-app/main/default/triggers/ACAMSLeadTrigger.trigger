trigger ACAMSLeadTrigger on Lead (after insert,after update, before update, before insert) {
    if (!String.valueOf(UserInfo.getProfileId()).contains(String.valueOf(System.Label.Data_Migration_Profile_Id))) {
        (new ACAMSLeadTriggerHandler()).run();
    }
}