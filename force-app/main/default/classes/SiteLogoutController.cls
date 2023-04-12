global without sharing class SiteLogoutController{
    public String redirecturl {get; set;}
    
    global SiteLogoutController(){
    redirecturl = System.currentPageReference().getParameters().get('redirecturl');
      }
    
     global PageReference redirect() {
        PageReference pageRef = new PageReference('/store2/signin'); 
        
        if(redirecturl != null) pageRef = new PageReference(redirecturl);

        pageRef.setRedirect(true);
        return pageRef;
    }
}