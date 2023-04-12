public with sharing class DeleteCartItemsListbuttonExtension {
	public List<ccrz__E_CartItem__c> selected { get;  set; }
	public String result{ get; private set; }
    public DeleteCartItemsListbuttonExtension(ApexPages.StandardSetController controller)
    {
        selected = controller.getSelected();
    }

    public PageReference getAndDeleteSelectedCartItems() {
    	String retUrl = apexpages.currentpage().getParameters().get('vfRetURLInSFX');  
        system.debug('retUrl::'+retUrl);
        // get the return url if it's in classic view
        if(String.isBlank(retUrl))
        retUrl = apexpages.currentpage().getParameters().get('retURL'); 
        system.debug('retUrl1::'+retUrl);
  		doJob();
        PageReference returnPage = new PageReference(retUrl);
		returnPage.setRedirect(true);
		return returnPage;
    }  
    
    private void doJob(){
      system.debug('apex action called');
        
        List<String> deleteProfileIds = String.valueOf(System.Label.Delete_Cart_Items_Profile_Ids).split(';');
        if(deleteProfileIds==null || deleteProfileIds.size()==0){
        	result= 'No profiles defined in Custom Label Delete_Cart_Items_Profile_Ids for Deletion of CC Cart Items. Contact your system admin';
        	return;
        }else if (deleteProfileIds.contains(String.valueOf(UserInfo.getProfileId()))) {
            system.debug('selected::'+selected);
        	if(selected==null || selected.size()==0){
        		result= 'No CC Cart Items selected to delete. Select items before performing this operation'; 
        		return;
        	}
        	
            List<ccrz__E_CartItem__c> ccCartItems = [Select ID, ccrz__Cart__c FROM ccrz__E_CartItem__c Where id IN:selected];
            
            List<ccrz__E_Order__c> ccOrder = [Select ID, ccrz__OriginatedCart__c FROM ccrz__E_Order__c where ccrz__OriginatedCart__c=:ccCartItems[0].ccrz__Cart__c];
            
            if(ccOrder!=null && ccOrder.size()>0){
            	result= 'Cannot delete cart items on Opportunity with an Order on it';
            	return;
            } else {
                delete ccCartItems;
                result= 'Selected CC Cart Item is deleted';
                return;
            }      
        }
        else {
            result= 'Your Profile does not have access to delete cc cart items';
        }    	
    }      
}