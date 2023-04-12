trigger ACAMSAccountTrigger on Account (before insert, after insert, before update, after update, after delete) {
    
    if (!String.valueOf(UserInfo.getProfileId()).contains(String.valueOf(System.Label.Data_Migration_Profile_Id))) {
        
        if(!ACAMSOrderTriggerHandler.SkipOrderRefundAssetAfterUpdate){
            (new ACAMSAccountTriggerHandler()).run();
        } else if(ACAMSOrderTriggerHandler.SkipOrderRefundAssetAfterUpdate){
            UpdateAccountAfterOrderRufund.UpdateAccountAfterOrderRufundMethod(Trigger.newMap.keyset());
        }
    }
}