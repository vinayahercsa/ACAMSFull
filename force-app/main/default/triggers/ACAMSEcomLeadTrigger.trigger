trigger ACAMSEcomLeadTrigger on Lead (before insert, before update) {
    if (!String.valueOf(UserInfo.getProfileId()).contains(String.valueOf(System.Label.Data_Migration_Profile_Id))) {
        new ACAMSEcomLeadTriggerHandler().run();
    }
}