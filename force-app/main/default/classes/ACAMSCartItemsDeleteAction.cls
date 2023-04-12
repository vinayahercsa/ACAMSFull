public with sharing class ACAMSCartItemsDeleteAction {
	public static final List<String> OPPORTUNITY_VALID_STAGES_TO_DELETE_ITEMS = new List<String>{'Discovery','Proposal','Negotiation'}; 

    @AuraEnabled
    public static String getCartItemsToDelete(String recordId) {
        system.debug('apex action called');
        List<String> deleteProfileIds = String.valueOf(System.Label.Delete_Cart_Items_Profile_Ids).split(';');
        if(deleteProfileIds==null || deleteProfileIds.size()==0){
        	return 'No profiles defined in Custom Label Delete_Cart_Items_Profile_Ids for Deletion of CC Cart Items. Contact your system admin';
        }else if (deleteProfileIds.contains(String.valueOf(UserInfo.getProfileId()))) {
            ccrz__E_CartItem__c ccCartItem = [Select ID, ccrz__Cart__c FROM ccrz__E_CartItem__c Where id=:recordId];
            List<ccrz__E_Order__c> ccOrder = [Select ID FROM ccrz__E_Order__c where ccrz__OriginatedCart__c=:ccCartItem.ccrz__Cart__c];
            
            if(ccOrder!=null && ccOrder.size()>0){
            	return 'Cannot delete cart items on Opportunity with an Order on it';
            } else {
                delete ccCartItem;
                return 'Selected CC Cart Item is deleted';
            }      
        }
        else {
            return 'Your Profile does not have access to delete cc cart items';
        }
    }
}