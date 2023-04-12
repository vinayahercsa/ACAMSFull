public with sharing class ACAMSCertAppTriggerHandler extends CCAviTriggerHandler {

    private List<Certification_Application__c> newList = (List<Certification_Application__c>) Trigger.new;
    private List<Certification_Application__c> oldList = (List<Certification_Application__c>) Trigger.old;
    private Map<Id, Certification_Application__c> newMap = (Map<Id, Certification_Application__c>) Trigger.newMap;
    private Map<Id, Certification_Application__c> oldMap = (Map<Id, Certification_Application__c>) Trigger.oldMap;
    public static boolean isTriggerExecuted = true;
    //private User drupalIntegration = ACAMSUserDAO.getDrupalIntegrationUser();
    
    protected override void beforeInsert() {
        if(isTriggerExecuted){
        User drupalIntegration = ACAMSUserDAO.getDrupalIntegrationUser();
        Set<Id> accountIds = new Set<Id>();
        for (Certification_Application__c certApp : newList) {
            if (certApp.Application_Type__c == ACAMSUtil.CGSS) {
                certApp.CGSS_Check__c = true;
            }
            if (UserInfo.getUserId() == drupalIntegration.Id) {
                certApp.Asset_Pending_to_Process__c = true;
            }
            accountIds.add(certApp.AccountId__c);
        }

        ACAMSCertAppHelper.setLanguage(accountIds, newList);

        if (!ACAMSCertAppHelper.isAssetUpdated) {
            ACAMSCertAppHelper.UpdateAsset(newList, true);
        }
    }
        isTriggerExecuted = false;
    }
    protected override void afterInsert() {
        if (!ACAMSCertAppHelper.isAssetUpdated) {
            ACAMSCertAppHelper.UpdateAsset(newList, true);
        }
        if (!ACAMSCertAppHelper.isLocaleUpdated) {
            ACAMSCertAppHelper.UpdateLocaleOnContact(Trigger.new);
        }
    }

    protected override void beforeUpdate() {
        Set<Id> accountIds = new Set<Id>();
        for (Certification_Application__c certApp : newMap.values()) {
            if (certApp.Application_Type__c == ACAMSUtil.CGSS) {
                certApp.CGSS_Check__c = true;
            } else {
                certApp.CGSS_Check__c = false;
            }
            accountIds.add(certApp.AccountId__c);
        }

        ACAMSCertAppHelper.setLanguage(accountIds, newList);

        if (!ACAMSCertAppHelper.isAssetUpdated) {
            ACAMSCertAppHelper.UpdateAsset(newList, true);
        }
    }

    protected override void afterUpdate() {
        if (!ACAMSCertAppHelper.isLocaleUpdated) {
            ACAMSCertAppHelper.UpdateLocaleOnContact(Trigger.new);
        }
        if (!ACAMSCertAppHelper.isCaseCreated) {
            ACAMSCertAppHelper.CreateCase_CertApp(Trigger.newMap.keySet(), newMap, oldMap);
        }
    }
}