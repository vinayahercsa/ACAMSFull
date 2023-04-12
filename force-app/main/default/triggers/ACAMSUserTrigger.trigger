trigger ACAMSUserTrigger on User (after insert, before update, after update) {
    if (!String.valueOf(UserInfo.getProfileId()).contains(String.valueOf(System.Label.Data_Migration_Profile_Id))) {
         if(!ACAMSOrderTriggerHandler.SkipOrderRefundAssetAfterUpdate){
        new ACAMSUserTriggerHandler().run();
         }
    }
}