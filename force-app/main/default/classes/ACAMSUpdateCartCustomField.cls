@RestResource(UrlMapping='/api/cart/updatecartfield')
global with sharing class ACAMSUpdateCartCustomField {
     @HttpPatch
    global static CartResponse updateCustomField(String ID) {
         CartResponse cartResponse = new CartResponse();
        ccrz__E_Cart__c cartObj = new ccrz__E_Cart__c();
     
       try {
        cartObj =[select id,isDrupalCallCompleted__c from ccrz__E_Cart__c where id=:ID];
        cartObj.isDrupalCallCompleted__c = true;
        Update cartObj;

            cartResponse.success = true;
            cartResponse.infoMsg = 'success';
        } catch (Exception e) {
            System.debug(System.LoggingLevel.ERROR, e);
        }
        return cartResponse;
      	
    }
   
  global class CartResponse {
        public Boolean success { get; set; }
        public String infoMsg { get; set; }
    }
}

// FSA-773-a