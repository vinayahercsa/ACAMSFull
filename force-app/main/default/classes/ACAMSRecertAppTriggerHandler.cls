public with sharing class ACAMSRecertAppTriggerHandler extends CCAviTriggerHandler {

    private List<Recertification_Application__c> newList = (List<Recertification_Application__c>) Trigger.new;
    private List<Recertification_Application__c> oldList = (List<Recertification_Application__c>) Trigger.old;
    private Map<Id, Recertification_Application__c> newMap = (Map<Id, Recertification_Application__c>) Trigger.newMap;
    private Map<Id, Recertification_Application__c> oldMap = (Map<Id, Recertification_Application__c>) Trigger.oldMap;

    private User drupalIntegration = ACAMSUserDAO.getDrupalIntegrationUser();

    protected override void beforeInsert() {
        list<Recertification_Application__c> recertList = new list<Recertification_Application__c>();
        for (Recertification_Application__c recertApp : newList) {
            if (UserInfo.getUserId() == drupalIntegration.Id) {
                recertApp.Asset_Pending_to_Process__c = true;
            }
        }
        if (!ACAMSCertAppHelper.isRecertAssetUpdated) {
            for(Recertification_Application__c recert : newList){        //CSA-fix
                if(recert.Status__c != null){
                    recertList.add(recert);
                }
            }
            if(!recertList.isEmpty()){
                ACAMSCertAppHelper.UpdateAsset(recertList, true);
            }
        }
    }

    protected override void afterInsert() {
        list<Recertification_Application__c> recertList = new list<Recertification_Application__c>();
        if (!ACAMSCertAppHelper.isRecertAssetUpdated) {
            for(Recertification_Application__c recert : newList){      //CSA-fix
                if(recert.Status__c != null){
                    recertList.add(recert);
                }
            }
            if(!recertList.isEmpty()){
                ACAMSCertAppHelper.UpdateAsset(recertList, true);
            }
        }
    }

    protected override void beforeUpdate() {
        list<Recertification_Application__c> recertList = new list<Recertification_Application__c>();
        if (!ACAMSCertAppHelper.isRecertAssetUpdated) {
            for(Recertification_Application__c recert : newList){
                if(oldMap.get(recert.Id).Status__c != newMap.get(recert.Id).Status__c && 
                    newMap.get(recert.Id).Status__c != null){       //CSA-fix
                    recertList.add(recert);
                }
            }
            if(!recertList.isEmpty()){
                ACAMSCertAppHelper.UpdateAsset(recertList, true);
            }
        }
    }

    protected override void afterUpdate() {
        list<Recertification_Application__c> recertList = new list<Recertification_Application__c>();
        if (!ACAMSCertAppHelper.isRecertAssetUpdated) {
            for(Recertification_Application__c recert : newList){
                if(oldMap.get(recert.Id).Status__c != newMap.get(recert.Id).Status__c && 
                    newMap.get(recert.Id).Status__c != null){               //CSA-fix
                    recertList.add(recert);
                }
            }
            if(!recertList.isEmpty()){
                ACAMSCertAppHelper.UpdateAsset(recertList, true);
            }
        }
        if (!ACAMSCertAppHelper.isCaseCreated) {
            ACAMSCertAppHelper.CreateCase_RecertApp(Trigger.newMap.keySet(), newMap, oldMap);
        }
    }
}