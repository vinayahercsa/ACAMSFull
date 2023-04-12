public with sharing class ACAMSCartTriggerHandler extends CCAviTriggerHandler {

    private List<ccrz__E_Cart__c> newList = (List<ccrz__E_Cart__c>) Trigger.new;
    private List<ccrz__E_Cart__c> oldList = (List<ccrz__E_Cart__c>) Trigger.old;
    private Map<Id, ccrz__E_Cart__c> newMap = (Map<Id, ccrz__E_Cart__c>) Trigger.newMap;
    private Map<Id, ccrz__E_Cart__c> oldMap = (Map<Id, ccrz__E_Cart__c>) Trigger.oldMap;

    public static Boolean skipLegalEntitySummaryCalculation = false;

    protected override void beforeUpdate() {
        calculateLegalEntitySummary();
        for (ccrz__E_Cart__c cart : newList) {
            if (oldMap.get(cart.Id).Cart_Items_Taxes__c != newMap.get(cart.Id).Cart_Items_Taxes__c) {
                cart.ccrz__TaxAmount__c = cart.Cart_Items_Taxes__c;
            }
        }
    }

    // FSA-773-a , update anoymous accout back
    protected override void afterUpdate() {
        if(UserInfo.getName().equals('Drupal Integration')){
            updateToAnoAccountGroup();
        }
    }

    public void updateToAnoAccountGroup(){
        Set<Id> acctIds = new Set<Id>();
        Set<Id> cartIds = new Set<Id>();
        Set<String> accountGroupNames = new Set<String>();
        List<Account> acctList = null;
        List<ccrz__E_AccountGroup__c> accoutGroupList = null;
        List<Account> updateAccts = new List<Account>();

        for(ccrz__E_Cart__c cart: newList){
            if(cart.isDrupalCallCompleted__c && cart.isDrupalCallCompleted__c != oldMap.get(cart.Id).isDrupalCallCompleted__c){
                cartIds.add(cart.Id);
                acctIds.add(cart.ccrz__Account__c);
            }
        }

        if(acctIds.size() > 0 && cartIds.size() > 0){
            acctList = ACAMSAccountDAO.getAccoutsWithCarts(acctIds,cartIds);
        }

        if(acctList != null){
            accountGroupNames.add('Anonymous');
            accoutGroupList = ACAMSAccountDAO.getAccountGroupByName(accountGroupNames);

            for(Account a : acctList){
                if(a.ccrz__E_AccountGroup__c != null && String.valueOf(a.ccrz__E_AccountGroup__r.Name).equals('Private/Member') && a.Top_Parent_Account__c != null && String.valueOf(a.Top_Parent_Account__c).equals('CCAnonymous')){
                    a.ccrz__E_AccountGroup__c = accoutGroupList[0].Id;
                    updateAccts.add(a);
                }
            }
        }

        if(updateAccts != null && updateAccts.size() > 0){
            update updateAccts;
        }
    }

    private void calculateLegalEntitySummary() {
        if (!skipLegalEntitySummaryCalculation) {
            ACAMSLegalEntityService.calculateLegalEntitySummary(
                this.newList,
                ccrz__E_Cart__c.Legal_Entity__c.getDescribe().getName(),
                ccrz__E_Cart__c.Legal_Entities_ACAMS_LLC__c.getDescribe().getName(),
                ccrz__E_Cart__c.Legal_Entities_ACAMS_Germany__c.getDescribe().getName(),
                ccrz__E_Cart__c.Legal_Entities_ACAMS_Canada__c.getDescribe().getName(),
                ccrz__E_Cart__c.Legal_Entities_ACAMS_Beijing__c.getDescribe().getName()
            );
        }
    }
}