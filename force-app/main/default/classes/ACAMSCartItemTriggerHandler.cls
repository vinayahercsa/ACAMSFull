public with sharing class ACAMSCartItemTriggerHandler extends CCAviTriggerHandler {
    private List<ccrz__E_CartItem__c>    newList = (List<ccrz__E_CartItem__c>)    Trigger.new;
    private List<ccrz__E_CartItem__c>    oldList = (List<ccrz__E_CartItem__c>)    Trigger.old;
    private Map<Id, ccrz__E_CartItem__c> newMap  = (Map<Id, ccrz__E_CartItem__c>) Trigger.newMap;
    private Map<Id, ccrz__E_CartItem__c> oldMap  = (Map<Id, ccrz__E_CartItem__c>) Trigger.oldMap;
    
    public static Boolean skipPopulateLegalEntityValueFromFormula = false;
    
    protected override void beforeInsert() {
        system.debug('newlist[0].Tax_Amount__c::'+newlist[0].Tax_Amount__c);
        populateLegalEntityValueFromFormula();
    }
    protected override void beforeUpdate() {
        system.debug('newlist[0].Tax_Amount__c1::'+newlist[0].Tax_Amount__c);
        populateLegalEntityValueFromFormula();
    }
    
    // FSA-773-a
    protected override void afterInsert() {
        if(UserInfo.getName().equals('Drupal Integration')){
            updateMembershipType();
        }
        //FSA-6892 vara added
        rollUpAmountByProductCategory();
    }
    
    protected override void afterUpdate() {
        Set<Id> ciforFutureIDs = new Set<Id>();
        Set<Id> cartItemIds = new Set<Id>();
        for (ccrz__E_CartItem__c cartItem : newList) {
            if (cartItem.ccrz__cartItemType__c.equalsIgnoreCase(ACAMSUtil.MAJOR) &&
                oldMap.get(cartItem.Id).ccrz__Quantity__c != cartItem.ccrz__Quantity__c) {
                    cartItemIds.add(cartItem.Id);
                }
            ciforFutureIDs.add(cartItem.Id);//FSA-360
            System.debug('afterUpdate Shipping_Tax_Area_Id__c  :' +cartItem.Shipping_Tax_Area_Id__c);
        }
        
        List<ccrz__E_CartItem__c> minorCartItems = ACAMSCartDAO.getMinorCartItemsByParent(cartItemIds);
        
        for (ccrz__E_CartItem__c minorCartItem : minorCartItems) {
            minorCartItem.ccrz__Quantity__c = newMap.get(minorCartItem.ccrz__ParentCartItem__c).ccrz__Quantity__c;
        }
        update minorCartItems;
        //FSA-360
        if(!System.isBatch() && !System.isFuture()){
            updateccitems(ciforFutureIDs);
        }
        //FSA-6892
        rollUpAmountByProductCategory();
    }
    
    private void populateLegalEntityValueFromFormula() {
        for (ccrz__E_CartItem__c cartItem : newList) {
            System.debug('populateLegalEntityValueFromFormula Shipping_Tax_Area_Id__c  :' +cartItem.Shipping_Tax_Area_Id__c);
        }
        if (!skipPopulateLegalEntityValueFromFormula) {
            ACAMSLegalEntityService.updateLineItemLegalEntityFromFormula(
                this.newList,
                ccrz__E_CartItem__c.Legal_Entity_Formula__c.getDescribe().getName(),
                ccrz__E_CartItem__c.Legal_Entity__c.getDescribe().getName()
            );
        }
    }
    
    // FSA-773-a
    protected override void afterDelete() {
        if(UserInfo.getName().equals('Drupal Integration')){
            updateMembershipType();
        }
        //FSA-6892 vara added
        rollUpAmountByProductCategory();
    }  
    
    public void rollUpAmountByProductCategory(){
        system.debug('---------rollUpAmountByProductCategory-------------');
        Id oppId;
        List<ccrz__E_CartItem__c> olditemsList = new List<ccrz__E_CartItem__c>();
        Decimal EnterpriseAmount =0.00, MembershipAmount=0.00, CertificationAmount=0.00, RiskAmount=0.00, TrainingAmount=0.00, ConferencesAmount=0.00, PublicationsAmount=0.00, ChapterAmount=0.00, AdvertOtherAmount = 0.00;
        
        if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
            
            if(!Trigger.isDelete){
                for(ccrz__E_CartItem__c cartItem : newList){
                    if(cartItem.Opportunity__c != null && cartItem.Product_Level_1__c != null){
                        oppId = cartItem.Opportunity__c;
                    }
                }
            }
      
            if(Trigger.isAfter && Trigger.isDelete){
                for(ccrz__E_CartItem__c cartItem : oldList){
                    if(cartItem.Opportunity__c != null && cartItem.Product_Level_1__c != null){
                        oppId = cartItem.Opportunity__c;
                    }
                }
            }
            
            if(oppId != null)
                olditemsList = [select id, ccrz__ItemTotal__c, Product_Level_1__c, Opportunity__c from ccrz__E_CartItem__c where Opportunity__c =: oppId and ccrz__ItemTotal__c > 0 and Product_Level_1__c != null];
            
            if(!olditemsList.isEmpty()){
                for(ccrz__E_CartItem__c cartItem : olditemsList){
                    if(cartItem.Opportunity__c != null && cartItem.Product_Level_1__c != null && cartItem.ccrz__ItemTotal__c > 0){
                        if(cartItem.Product_Level_1__c =='Enterprise Bundle'){ 
                            EnterpriseAmount = EnterpriseAmount + cartItem.ccrz__ItemTotal__c;
                        }
                        if(cartItem.Product_Level_1__c =='Membership'){ 
                            MembershipAmount = MembershipAmount + cartItem.ccrz__ItemTotal__c;
                        }
                        if(cartItem.Product_Level_1__c =='Certification'){ 
                            CertificationAmount = CertificationAmount + cartItem.ccrz__ItemTotal__c;
                        }
                        if(cartItem.Product_Level_1__c =='Risk Assessment'){ 
                            RiskAmount = RiskAmount + cartItem.ccrz__ItemTotal__c;
                        }
                        if(cartItem.Product_Level_1__c =='Training'){ 
                            TrainingAmount = TrainingAmount + cartItem.ccrz__ItemTotal__c;
                        }
                        if(cartItem.Product_Level_1__c =='Conferences'){ 
                            ConferencesAmount = ConferencesAmount + cartItem.ccrz__ItemTotal__c;
                        }
                        if(cartItem.Product_Level_1__c =='Publications'){ 
                            PublicationsAmount = PublicationsAmount + cartItem.ccrz__ItemTotal__c;
                        }
                        if(cartItem.Product_Level_1__c =='Chapter'){ 
                            ChapterAmount = ChapterAmount + cartItem.ccrz__ItemTotal__c;
                        }
                        if(cartItem.Product_Level_1__c =='Advertising/Other'){
                            AdvertOtherAmount = AdvertOtherAmount + cartItem.ccrz__ItemTotal__c;
                        }
                    }
                }
            }
        }
        
        List<opportunity> oppList = new List<opportunity>();
        opportunity opp = new opportunity();
        if(oppid != null){
            opp.id = oppid;
            opp.Amount_Enterprise__c = EnterpriseAmount;
            opp.Amount_Membership__c = MembershipAmount;
            opp.Amount_Certification__c = CertificationAmount;
            opp.Amount_Risk_Assessment__c = RiskAmount;
            opp.Amount_Training__c = TrainingAmount;
            opp.Amount_Conferences__c = ConferencesAmount;
            opp.Amount_Publications__c = PublicationsAmount;
            opp.Amount_Chapters__c = ChapterAmount;
            opp.Amount_Advertising__c = AdvertOtherAmount;
            oppList.add(opp);
        }
        
        if(!oppList.isEmpty()){
            update oppList;
        }
    }  
    
    // FSA-773-a - update membership type
    public void updateMembershipType(){
        Set<Id> acctIds = new Set<Id>();
        Set<String> cartIds = new Set<String>();
        Set<String> checkingCartIds = new Set<String>();
        List<ccrz__E_Cart__c> ccCarts = null;
        Set<String> accountGroupNames = new Set<String>();
        List<Sobject> updateAccounts = new List<Sobject>();
        List<ccrz__E_Cart__c> updateCarts = new List<ccrz__E_Cart__c>();
        List<ccrz__E_AccountGroup__c> accoutGroupList = null;
        Map<String, ccrz__E_AccountGroup__c> nameAccout = new Map<String, ccrz__E_AccountGroup__c>();
        Map<Boolean, String> memberCartIds = new Map<Boolean, String>();
        
        if(Trigger.isInsert){
            for(ccrz__E_CartItem__c cartItem : newList){
                if(cartItem.ccrz__Cart__c != null && cartItem.Product_Level_1__c != null){
                    cartIds.add(String.valueOf(cartItem.ccrz__Cart__c));
                }
            }
        }
        
        if(Trigger.isDelete){
            for(ccrz__E_CartItem__c cartItem : oldList){
                if(cartItem.ccrz__Cart__c != null && cartItem.Product_Level_1__c != null){
                    cartIds.add(String.valueOf(cartItem.ccrz__Cart__c));
                }
            }
        }
        
        if(cartIds != null && cartIds.size() > 0){
            ccCarts = ACAMSCartDAO.getCartsByIds(cartIds);
        }
        
        if(cartIds != null && cartIds.size() > 0 && ccCarts != null && ccCarts.size() > 0){
            accountGroupNames.add('Government/Member');
            accountGroupNames.add('Private/Member');
            accountGroupNames.add('Government/Non-Member');
            accountGroupNames.add('Private/Non-Member');
            accountGroupNames.add('Anonymous');
            
            accoutGroupList = ACAMSAccountDAO.getAccountGroupByName(accountGroupNames);
            
            for(ccrz__E_AccountGroup__c acctGroup : accoutGroupList){
                if(String.valueOf(acctGroup.Name).equals('Government/Member')){
                    nameAccout.put('govenment_member', acctGroup);
                }
                else if(String.valueOf(acctGroup.Name).equals('Private/Member')){
                    nameAccout.put('private_member', acctGroup);
                }
                else if(String.valueOf(acctGroup.Name).equals('Government/Non-Member')){
                    nameAccout.put('government_non_member', acctGroup);
                }
                else if(String.valueOf(acctGroup.Name).equals('Private/Non-Member')){
                    nameAccout.put('private_non_member', acctGroup);
                }
                else if(String.valueOf(acctGroup.Name).equals('Anonymous')){
                    nameAccout.put('Anonymous', acctGroup);
                }
            }
            
            for(ccrz__E_Cart__c c : ccCarts){
                if(Trigger.isInsert){
                    if(c.ccrz__Account__c != null && c.ccrz__Account__r.ccrz__E_AccountGroup__c != null && String.valueOf(c.ccrz__Account__r.ccrz__E_AccountGroup__r.Name).equals('Anonymous')){
                        if(isMembershipCart(c)){
                            c.ccrz__Account__r.ccrz__E_AccountGroup__c = nameAccout.get('private_member').Id;
                            updateAccounts.add(c.ccrz__Account__r);
                            if(c.isDrupalCallCompleted__c){
                                c.isDrupalCallCompleted__c = false;
                                updateCarts.add(c);
                            } 
                        }
                    }
                    
                    if(c.ccrz__Account__c != null && c.ccrz__Account__r.ccrz__E_AccountGroup__c != null && (String.valueOf(c.ccrz__Account__r.ccrz__E_AccountGroup__r.Name).contains('Non-Member'))){
                        if(String.valueOf(c.ccrz__Account__r.ccrz__E_AccountGroup__r.Name).contains('Anonymous') && isMembershipCart(c)){
                            c.ccrz__Account__r.ccrz__E_AccountGroup__c = nameAccout.get('private_member').Id;
                            if(c.isDrupalCallCompleted__c){
                                c.isDrupalCallCompleted__c = false;
                                updateCarts.add(c);
                            }  
                        }
                        else if(String.valueOf(c.ccrz__Account__r.ccrz__E_AccountGroup__r.Name).contains('Government/Non-Member') && isMembershipCart(c)){
                            c.ccrz__Account__r.ccrz__E_AccountGroup__c = nameAccout.get('govenment_member').Id;
                        }
                        else if(String.valueOf(c.ccrz__Account__r.ccrz__E_AccountGroup__r.Name).contains('Private/Non-Member') && isMembershipCart(c)){
                            c.ccrz__Account__r.ccrz__E_AccountGroup__c = nameAccout.get('private_member').Id;
                        }
                        updateAccounts.add(c.ccrz__Account__r);
                    }
                }
                
                if(Trigger.isDelete && Trigger.isAfter){
                    if(c.ccrz__Account__c != null && c.ccrz__Account__r.ccrz__E_AccountGroup__c != null && String.valueOf(c.ccrz__Account__r.ccrz__E_AccountGroup__r.Name).equals('Anonymous')){
                        if(isMembershipCart(c)){
                            c.ccrz__Account__r.ccrz__E_AccountGroup__c = nameAccout.get('private_member').Id;
                            updateAccounts.add(c.ccrz__Account__r);
                            if(c.isDrupalCallCompleted__c){
                                c.isDrupalCallCompleted__c = false;
                                updateCarts.add(c);
                            } 
                        }
                    }
                    
                    // FSA-1378
                    if(c.ccrz__Account__c != null && c.ccrz__Account__r.ccrz__E_AccountGroup__c != null && (String.valueOf(c.ccrz__Account__r.ccrz__E_AccountGroup__r.Name).contains('/Member'))){
                        if(!isMembershipCart(c) && String.valueOf(c.ccrz__Account__r.ccrz__E_AccountGroup__r.Name).contains('Private/Member') && c.ccrz__Account__r.Top_Parent_Account__c != null && (String.valueOf(c.ccrz__Account__r.Top_Parent_Account__c).equals('CCAnonymous'))){
                            c.ccrz__Account__r.ccrz__E_AccountGroup__c = nameAccout.get('Anonymous').Id;
                        }
                        else if(!isMembershipCart(c) && String.valueOf(c.ccrz__Account__r.ccrz__E_AccountGroup__r.Name).contains('Government/Member') && !c.ccrz__Account__r.purchasedMembership__c){
                            c.ccrz__Account__r.ccrz__E_AccountGroup__c = nameAccout.get('government_non_member').Id;
                        }
                        else if(!isMembershipCart(c) && String.valueOf(c.ccrz__Account__r.ccrz__E_AccountGroup__r.Name).contains('Private/Member') && !c.ccrz__Account__r.purchasedMembership__c){
                            c.ccrz__Account__r.ccrz__E_AccountGroup__c = nameAccout.get('private_non_member').Id;
                        }
                        updateAccounts.add(c.ccrz__Account__r);
                    }
                }
            }
            
            if(updateAccounts != null && updateAccounts.size() > 0){
                update updateAccounts;
            }
            
            if(updateCarts != null && updateCarts.size() >0){
                update updateCarts;
            }
        }
        
    }
    
    // FSA-773-a - check cart user
    public Boolean isMemberUser(ccrz__E_Cart__c ccCart){
        if(ccCart.ccrz__User__c != null){
            if((ccCart.ccrz__User__r.Membership_Level__c != null && String.valueOf(ccCart.ccrz__User__r.Membership_Level__c).toLowercase().equals('member')) || 
               (ccCart.ccrz__User__r.Membership_Type__c != null && String.valueOf(ccCart.ccrz__User__r.Membership_Type__c).toLowercase().equals('member')) || 
               (ccCart.ccrz__User__r.Membership_Level_Text__c != null && String.valueOf(ccCart.ccrz__User__r.Membership_Level_Text__c).toLowercase().equals('member'))){
                   return true;
               }
        }
        return false;
    }
    
    // FSA-773-a - is membership cart
    public Boolean isMembershipCart(ccrz__E_Cart__c ccCart){
        Boolean isMember = false;
        for(ccrz__E_CartItem__c cartItem : ccCart.ccrz__E_CartItems__r){
            if(cartItem.ccrz__Cart__c != null && cartItem.Product_Level_1__c != null && String.valueOf(cartItem.Product_Level_1__c).equals('Membership')){
                isMember = true;
            }
        }
        return isMember;
    }
    
    /*
    * method: updateccitems 
    * FSA-360 - This is a adhoc fix until the greater Tax (Vertex) design issues are resolved. This future update on 
    * CC Cart Item will make sure there is a Tax Amount calculated via the existing Process builder flows. 
    */
    @future
    private static void updateccitems(Set<ID> itemIds){
        List<ccrz__E_CartItem__c> ciup = [Select ID,Tax_Amount__c from ccrz__E_CartItem__c where ID IN:itemIds];
        List<ccrz__E_CartItem__c> toUpdate = new List<ccrz__E_CartItem__c>();
        for (ccrz__E_CartItem__c cartItem : ciup) {
            if(cartItem.Tax_Amount__c == null){
                cartItem.Tax_Amount__c = 0;
                toUpdate.add(cartItem);
            }
        }
        if(toUpdate.size()>0){
            update toUpdate;
        }
    }
    
}