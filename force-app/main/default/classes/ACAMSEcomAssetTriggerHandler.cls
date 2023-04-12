public with sharing class ACAMSEcomAssetTriggerHandler extends CCAviTriggerHandler {

    private List<Asset> newList;
    private List<Asset> oldList;
    private Map<Id, Asset> newMap;
    private Map<Id, Asset> oldMap;
    Boolean isUpdatePersonAccStatus = false;

    public ACAMSEcomAssetTriggerHandler() {
        this.newList = (List<Asset>) Trigger.new;
        this.oldList = (List<Asset>) Trigger.old;
        this.newMap = (Map<Id, Asset>) Trigger.newMap;
        this.oldMap = (Map<Id, Asset>) Trigger.oldMap;
    }

    public override void beforeInsert() {
        // Commented out due to ACR-2546
        // createMasterAssets();
        populateContactFromAssignee();
    }

    public override void afterInsert() {
        //CSA-fix
        for(Asset asst : this.newList){
            if(asst.CurrentExpirationDate__c != null || asst.InstallDate != null || asst.Paid_Cert__c == true){
                isUpdatePersonAccStatus = true;
            }
        }
        if(isUpdatePersonAccStatus){
            updatePersonAccountStatuses();
        }
        if (!ACAMSCertAppHelper.isAssetUpdated) {
            updateCertApp();
        }
        if (!ACAMSCertAppHelper.isRecertAssetUpdated) {
            updateRecertApp();
        }
        updateSubscription();
    }

    public override void beforeUpdate() {
        // Commented out due to ACR-2546
        // createMasterAssets();
        populateContactFromAssignee();
    }
    public override void afterUpdate() {
        //CSA-fix
        for(Asset asst : this.newList){
            if(this.oldMap.get(asst.Id).CurrentExpirationDate__c != this.newMap.get(asst.Id).CurrentExpirationDate__c && this.newMap.get(asst.Id).CurrentExpirationDate__c != null ||
                this.oldMap.get(asst.Id).InstallDate != this.newMap.get(asst.Id).InstallDate && this.newMap.get(asst.Id).InstallDate != null || 
                this.oldMap.get(asst.Id).Paid_Cert__c != this.newMap.get(asst.Id).Paid_Cert__c && this.newMap.get(asst.Id).Paid_Cert__c == true || 
                this.oldMap.get(asst.Id).CancelDate__c != this.newMap.get(asst.Id).CancelDate__c && this.newMap.get(asst.Id).CancelDate__c != null || 
                this.oldMap.get(asst.Id).Status__c != this.newMap.get(asst.Id).Status__c && this.newMap.get(asst.Id).Status__c != null ||
                this.oldMap.get(asst.Id).Payment_Status__c != this.newMap.get(asst.Id).Payment_Status__c && this.newMap.get(asst.Id).Payment_Status__c != null ||
                this.oldMap.get(asst.Id).Effective_Date__c != this.newMap.get(asst.Id).Effective_Date__c && this.newMap.get(asst.Id).Effective_Date__c != null ||
                this.oldMap.get(asst.Id).Assignee__c != this.newMap.get(asst.Id).Assignee__c && this.newMap.get(asst.Id).Assignee__c != null ||
                this.oldMap.get(asst.Id).AccountId != this.newMap.get(asst.Id).AccountId && this.newMap.get(asst.Id).AccountId != null ||
                this.oldMap.get(asst.Id).ContactId != this.newMap.get(asst.Id).ContactId && this.newMap.get(asst.Id).ContactId != null){
                isUpdatePersonAccStatus = true;
            }
        }
        if(isUpdatePersonAccStatus){
            updatePersonAccountStatuses();
        }
        //updatePersonAccountStatuses();
        if (!ACAMSCertAppHelper.isAssetUpdated) {
            updateCertApp();
        }
        if (!ACAMSCertAppHelper.isRecertAssetUpdated) {
            updateRecertApp();
        }
        updateSubscription();
    }

    // Commented out due to ACR-2546
    /*private void createMasterAssets() {
        Set<Id> contactIds = new Set<Id>();
        for (Asset asset : newList) {
            if (asset.Assignee__c != null && (oldMap == null ||
                    (oldMap.get(asset.Id).Assignee__c != asset.Assignee__c)) && !isMasterAsset(asset)) {
                contactIds.add(asset.Assignee__c);
            }
        }
        if (!contactIds.isEmpty()) {
            List<Contact> contacts = [
                    SELECT Id, AccountId
                    FROM Contact
                    WHERE Id IN :contactIds
            ];
            Map<Id, Id> contactToAccountIdsMap = new Map<Id, Id>();
            for (Contact contact : contacts) {
                contactToAccountIdsMap.put(contact.Id, contact.AccountId);
            }
            List<Asset> masterAssets = [
                    SELECT Id, Name, Assignee__c
                    FROM Asset
                    WHERE Assignee__c IN :contactIds
                    AND ParentId = NULL
                    AND Status__c = NULL
            ];
            Map<Id, List<Asset>> assigneeToMasterAssetsMap = new Map<Id, List<Asset>>();
            for (Asset asset : masterAssets) {
                if (asset.Assignee__c != null) {
                    if (assigneeToMasterAssetsMap.containsKey(asset.Assignee__c)) {
                        assigneeToMasterAssetsMap.get(asset.Assignee__c).add(asset);
                    } else {
                        assigneeToMasterAssetsMap.put(asset.Assignee__c, new List<Asset>{asset});
                    }
                }
            }
            List<Asset> masterAssetsToInsert = new List<Asset>();
            for (Asset asset : newList) {
                String assetName = asset.Name;
                if (asset.Product_Level_1__c == ACAMSUtil.CERTIFICATION && String.isNotBlank(Asset.Product_Level_3__c)) {
                    assetName = assetName.removeEnd(' - ' + Asset.Product_Level_3__c);
                }
                if (!assigneeToMasterAssetsMap.containsKey(asset.Assignee__c)) {
                    Asset masterAsset = new Asset(
                            Name = assetName,
                            Assignee__c = asset.Assignee__c,
                            AccountId = asset.AccountId,
                            ContactId = asset.Assignee__c,
                            Status__c = null
                    );
                    masterAssetsToInsert.add(masterAsset);
                } else {
                    Boolean masterFound = false;
                    for (Asset masterAsset : assigneeToMasterAssetsMap.get(asset.Assignee__c)) {
                        if (assetName == masterAsset.Name) {
                            masterFound = true;
                            break;
                        }
                    }
                    if (!masterFound) {
                        Asset masterAsset = new Asset(
                                Name = assetName,
                                Assignee__c = asset.Assignee__c,
                                AccountId = contactToAccountIdsMap.get(asset.Assignee__c),
                                ContactId = asset.Assignee__c,
                                Status__c = null
                        );
                        masterAssetsToInsert.add(masterAsset);
                    }
                }
            }
            insert masterAssetsToInsert;
            for (Asset asset : masterAssetsToInsert) {
                if (asset.Assignee__c != null) {
                    if (assigneeToMasterAssetsMap.containsKey(asset.Assignee__c)) {
                        assigneeToMasterAssetsMap.get(asset.Assignee__c).add(asset);
                    } else {
                        assigneeToMasterAssetsMap.put(asset.Assignee__c, new List<Asset>{asset});
                    }
                }
            }
            for (Asset asset : newList) {
                if (assigneeToMasterAssetsMap.containsKey(asset.Assignee__c)) {
                    for (Asset masterAsset : assigneeToMasterAssetsMap.get(asset.Assignee__c)) {
                        String assetName = asset.Name;
                        if (asset.Product_Level_1__c == ACAMSUtil.CERTIFICATION && String.isNotBlank(Asset.Product_Level_3__c)) {
                            assetName = assetName.removeEnd(' - ' + Asset.Product_Level_3__c);
                        }
                        if (assetName == masterAsset.Name) {
                            if (asset.ParentId != masterAsset.Id) {
                                asset.ParentId = masterAsset.Id;
                            }
                        }
                    }
                }
            }
        }
    }*/

    private Boolean isMasterAsset(Asset asset) {
        if (asset.ParentId == null && asset.Status__c == null && asset.Assignee__c != null &&
                asset.CC_Product__c == null) {
            return true;
        }
        return false;
    }

    private void updatePersonAccountStatuses() {
      
      //FSA-1165
      ACAMSMembershipAndCertificationsStatuses.updateMemsAndCertsStatuses(newList);
    }

    private void populateContactFromAssignee() {
        for (Asset asset : newList) {
            if (oldList == null || oldMap.get(asset.Id).Assignee__c != asset.Assignee__c) {
                asset.ContactId = asset.Assignee__c;
            }
        }
    }

    private void updateCertApp() {
        Set<Id> contactIds = new Set<Id>();
        Set<Id> assetIds = new Set<Id>();
        List<Asset> astLst = new List<Asset>();
        for (Asset asset : this.newList) {
            if (asset.Assignee__c != null) {
                contactIds.add(asset.Assignee__c);
                astLst.add(asset);
                assetIds.add(asset.id);
            }
        }
        List<Certification_Application__c> certAppsToUpdate = new List<Certification_Application__c>();
        if(contactIds.size() > 0)
        certAppsToUpdate = [
                SELECT  Id, Asset_Pending_to_Process__c, Contact__c, CGSS_Check__c, Status__c, Asset__c,
                        Application_Approval_Date__c, Application_Type__c
                FROM Certification_Application__c
                WHERE Asset_Pending_to_Process__c = TRUE AND Asset__c = NULL AND Contact__c IN :contactIds
        ];
        List<Certification_Application__c> certAppsCheck = new List<Certification_Application__c>();
        if(contactIds.size() > 0)
        certAppsCheck = [
                SELECT  Id, Asset_Pending_to_Process__c, Contact__c, CGSS_Check__c, Status__c, Asset__c,
                        Application_Approval_Date__c, Application_Type__c
                FROM Certification_Application__c
                WHERE   Asset__c IN :assetIds AND Contact__c IN :contactIds
        ];
        system.debug('certAppsToUpdate -'+certAppsToUpdate);
        if(certAppsToUpdate.size()>0){
            ACAMSCertAppHelper.UpdateAsset(certAppsToUpdate, false);
        }
        else{
            if(certAppsCheck.size() == 0){
            
            List<Certification_Application__c> certAppLst = New List<Certification_Application__c>();
            system.debug('astLst -'+astLst);
            for(Asset ast : astLst){
                Certification_Application__c certApp = new Certification_Application__c();
                if(ast.Application_Received__c == false){
                if(ast.Name == 'CAMS Certification - New'){
                    certApp.Application_Type__c='CAMS';
                    certApp.Status__c='Started';
                    certApp.Contact__c = ast.Assignee__c;
                    certApp.Asset__c = ast.id;
                    certApp.Asset_Pending_to_Process__c = true;
                    certAppLst.add(certApp);
                }
                else if(ast.Name == 'CGSS Certification - New'){
                    certApp.Application_Type__c='CGSS';
                    certApp.Status__c='Started';
                    certApp.Contact__c = ast.Assignee__c;
                    certApp.Asset__c = ast.id;
                    certApp.Asset_Pending_to_Process__c = true;
                    certAppLst.add(certApp);
                }
                else if(ast.Name == 'CKYCA Certification - New'){
                    certApp.Application_Type__c='CKYCA';
                    certApp.Status__c='Started';
                    certApp.Contact__c = ast.Assignee__c;
                    certApp.Asset__c = ast.id;
                    certApp.Asset_Pending_to_Process__c = true;
                    certAppLst.add(certApp);
                }
                 else if(ast.Name == 'CTMA Certification - New'){
                    certApp.Application_Type__c='CTMA';
                    certApp.Status__c='Started';
                    certApp.Contact__c = ast.Assignee__c;
                    certApp.Asset__c = ast.id;
                     certApp.Asset_Pending_to_Process__c = true;
                    certAppLst.add(certApp);
                }
                  else if(ast.Name == 'Advanced CAMS - Audit Certification - New'){
                    certApp.Application_Type__c='Advanced CAMS - Audit';
                    certApp.Status__c='Started';
                    certApp.Contact__c = ast.Assignee__c;
                    certApp.Asset__c = ast.id;
                      certApp.Asset_Pending_to_Process__c = true;
                    certAppLst.add(certApp);
                }
                else if(ast.Name == 'Advanced CAMS - FCI Certification - New'){
                    certApp.Application_Type__c='Advanced CAMS - FCI';
                    certApp.Status__c='Started';
                    certApp.Contact__c = ast.Assignee__c;
                    certApp.Asset__c = ast.id;
                    certApp.Asset_Pending_to_Process__c = true;
                    certAppLst.add(certApp);
                }
                 else if(ast.Name == 'Advanced CAMS - Risk Management Certification - New'){
                    certApp.Application_Type__c='Advanced CAMS - Risk Management';
                    certApp.Status__c='Started';
                    certApp.Contact__c = ast.Assignee__c;
                    certApp.Asset__c = ast.id;
                     certApp.Asset_Pending_to_Process__c = true;
                    certAppLst.add(certApp);
                }
                //FSA-961/962
                else if(ast.Name == 'CAFCA Certification - New') {
                  certApp.Application_Type__c='CAFCA';
                    certApp.Status__c='Started';
                    certApp.Contact__c = ast.Assignee__c;
                    certApp.Asset__c = ast.id;
                    certApp.Asset_Pending_to_Process__c = true;
                    certAppLst.add(certApp);
                }
                //FSA-4720
                //Chandra Added for FSA-4721
                 else if(ast.Name == 'CCAS Certification - New') {
                  certApp.Application_Type__c='CCAS';
                    certApp.Status__c='Started';
                    certApp.Contact__c = ast.Assignee__c;
                    certApp.Asset__c = ast.id;
                    certApp.Asset_Pending_to_Process__c = true;
                    certAppLst.add(certApp);
                } //FSA-4721
             } 
            } 
            system.debug('certAppLst -'+certAppLst);
            if(certAppLst.size() > 0){
                try{
                    insert certAppLst;
                }
              catch(DmlException e) {
               System.debug('The following exception has occurred: ' + e.getMessage());
          } 
            }
        }
        }
    }

    private void updateRecertApp() {
        Set<Id> contactIds = new Set<Id>();
        Set<Id> assetIds = new Set<Id>();
        List<Asset> astLst = new List<Asset>();
        for (Asset asset : this.newList) {
            if (asset.Assignee__c != null) {
                contactIds.add(asset.Assignee__c);
                astLst.add(asset);
                 assetIds.add(asset.id);
            }
        }
        List<Recertification_Application__c> recertAppsToUpdate = new List<Recertification_Application__c>();
        if(contactIds.size() > 0)
            recertAppsToUpdate = [ SELECT  Id, Asset_Pending_to_Process__c, Contact__c, Status__c, Asset__c, Application_Approval_Date__c,
            Application_Type__c FROM Recertification_Application__c WHERE Asset_Pending_to_Process__c = TRUE AND Asset__c = NULL AND Contact__c IN :contactIds];
        // vara added 1469 code optimization 
        List<Recertification_Application__c> recertAppsCheck = new List<Recertification_Application__c>();
        if(assetIds.size() > 0 && contactIds.size() > 0)
        recertAppsCheck = [SELECT  Id, Asset_Pending_to_Process__c, Contact__c,  Status__c, Asset__c
                FROM Recertification_Application__c WHERE   Asset__c IN :assetIds AND Contact__c IN :contactIds ];
        system.debug('recertAppsToUpdate -'+recertAppsToUpdate);
        if(recertAppsToUpdate.size()>0){
            ACAMSCertAppHelper.UpdateAsset(recertAppsToUpdate, false);
        } else {
                         if(recertAppsCheck.size() == 0){
           
            system.debug('astLst -'+astLst);
            for(Asset ast : astLst){
                 Recertification_Application__c recertApp = new Recertification_Application__c();
            List<Recertification_Application__c> recertAppLst = New List<Recertification_Application__c>();
                if(ast.Application_Received__c == false){
                if(ast.Name == 'CAMS Certification - Recertification'){
                    recertApp.Application_Type__c='CAMS';
                    recertApp.Status__c='Started';
                    recertApp.Contact__c = ast.Assignee__c;
                    recertApp.Asset__c = ast.id;
                    recertApp.Asset_Pending_to_Process__c = true;
                    recertAppLst.add(recertApp);
                }
                else if(ast.Name == 'CGSS Certification - Recertification'){
                    recertApp.Application_Type__c='CGSS';
                    recertApp.Status__c='Started';
                    recertApp.Contact__c = ast.Assignee__c;
                    recertApp.Asset__c = ast.id;
                    recertApp.Asset_Pending_to_Process__c = true;
                    recertAppLst.add(recertApp);
                }
                else if(ast.Name == 'CKYCA Certification - Recertification'){
                    recertApp.Application_Type__c='CKYCA';
                    recertApp.Status__c='Started';
                    recertApp.Contact__c = ast.Assignee__c;
                    recertApp.Asset__c = ast.id;
                    recertApp.Asset_Pending_to_Process__c = true;
                    recertAppLst.add(recertApp);
                }
                 else if(ast.Name == 'CTMA Certification - Recertification'){
                    recertApp.Application_Type__c='CTMA';
                    recertApp.Status__c='Started';
                    recertApp.Contact__c = ast.Assignee__c;
                    recertApp.Asset__c = ast.id;
                     recertApp.Asset_Pending_to_Process__c = true;
                    recertAppLst.add(recertApp);
                }
                  else if(ast.Name == 'Advanced CAMS - Audit Certification - Recertification'){
                    recertApp.Application_Type__c='Advanced CAMS - Audit';
                    recertApp.Status__c='Started';
                    recertApp.Contact__c = ast.Assignee__c;
                    recertApp.Asset__c = ast.id;
                      recertApp.Asset_Pending_to_Process__c = true;
                    recertAppLst.add(recertApp);
                }
                else if(ast.Name == 'Advanced CAMS - FCI Certification - Recertification'){
                    recertApp.Application_Type__c='Advanced CAMS - FCI';
                    recertApp.Status__c='Started';
                    recertApp.Contact__c = ast.Assignee__c;
                    recertApp.Asset__c = ast.id;
                    recertApp.Asset_Pending_to_Process__c = true;
                    recertAppLst.add(recertApp);
                }
                 else if(ast.Name == 'Advanced CAMS - Risk Management Certification - Recertification'){
                    recertApp.Application_Type__c='Advanced CAMS - Risk Management';
                    recertApp.Status__c='Started';
                    recertApp.Contact__c = ast.Assignee__c;
                    recertApp.Asset__c = ast.id;
                     recertApp.Asset_Pending_to_Process__c = true;
                    recertAppLst.add(recertApp);
                }
                //FSA-961/962
                else if(ast.Name == 'CAFCA Certification - Recertification'){
                    recertApp.Application_Type__c='CAFCA';
                    recertApp.Status__c='Started';
                    recertApp.Contact__c = ast.Assignee__c;
                    recertApp.Asset__c = ast.id;
                    recertApp.Asset_Pending_to_Process__c = true;
                    recertAppLst.add(recertApp);
                }//FSA-961/962
                // FSA-4721 chandra added 
                else if(ast.Name == 'CCAS Certification - Recertification'){
                    recertApp.Application_Type__c='CCAS';
                    recertApp.Status__c='Started';
                    recertApp.Contact__c = ast.Assignee__c;
                    recertApp.Asset__c = ast.id;
                    recertApp.Asset_Pending_to_Process__c = true;
                    recertAppLst.add(recertApp);
                } // FSA-4721 chandra added close
            } 
            system.debug('recertAppLst -'+recertAppLst);
            if(recertAppLst.size() > 0){
                try{
                    insert recertAppLst;
                }
              catch(DmlException e) {
               System.debug('The following exception has occurred: ' + e.getMessage());
          } 
            }
            }
        }
                   }
    }

    private void updateSubscription() {
        Set<Id> orderItemIds = new Set<Id>();
        Map<Id, Asset> orderItemIdToAssetMap = new Map<Id, Asset>();
        for (Asset asset : this.newList) {
            if (asset.CC_Order_Item__c != null) {
                orderItemIds.add(asset.CC_Order_Item__c);
                orderItemIdToAssetMap.put(asset.CC_Order_Item__c, asset);
            }
        }
        List<ccrz__E_Subscription__c> subsToUpdate = new List<ccrz__E_Subscription__c>();
        List<ccrz__E_Subscription__c> subList = new List<ccrz__E_Subscription__c>();
        //1469 vara added - code optimization
        if(orderItemIds.size() > 0)
        subList = [ SELECT  Id, ccrz__CCOrderItem__c, ccrz__ParentSubscription__c, ccrz__SubscriptionStartDate__c,
                        ccrz__InstallmentNextDate__c, ccrz__InstallmentLastDate__c, ccrz__OrderNextDate__c,
                        ccrz__OrderLastDate__c, ccrz__SubscriptionStatus__c, ccrz__OrderStatus__c,
                        ccrz__SPTInstallmentFrequencyUOM__c, ccrz__SPTInstallmentCount__c,
                        ccrz__InstallmentCountRemaining__c FROM ccrz__E_Subscription__c
                        WHERE ccrz__CCOrderItem__c IN :orderItemIds AND ccrz__Quantity__c = 1 ];
        for (ccrz__E_Subscription__c sub : subList) {
            if (orderItemIdToAssetMap.get(sub.ccrz__CCOrderItem__c).Effective_Date__c != null) {
                Date effectiveDate = orderItemIdToAssetMap.get(sub.ccrz__CCOrderItem__c).Effective_Date__c;
                Integer month = effectiveDate.month();
                Integer day = effectiveDate.day();
                Integer year = effectiveDate.year();
                sub.ccrz__SubscriptionStartDate__c = Datetime.newInstance(year, month, day, 0, 0, 0);
            }
            Integer offset = 1;
            if (sub.ccrz__SPTInstallmentCount__c != null && sub.ccrz__InstallmentCountRemaining__c != null) {
                offset = 1 +
                        ((Integer) (sub.ccrz__SPTInstallmentCount__c - sub.ccrz__InstallmentCountRemaining__c));
            }
            if (sub.ccrz__ParentSubscription__c == null) {
                if (orderItemIdToAssetMap.get(sub.ccrz__CCOrderItem__c).CurrentExpirationDate__c != null) {
                    Date expirationDate = orderItemIdToAssetMap.get(sub.ccrz__CCOrderItem__c).CurrentExpirationDate__c;
                    Integer month = expirationDate.month();
                    Integer day = expirationDate.day();
                    Integer year = expirationDate.year();
                    sub.ccrz__InstallmentLastDate__c = Datetime.newInstance(year, month, day, 0, 0, 0);
                    if (sub.ccrz__SPTInstallmentFrequencyUOM__c == 'Yearly' &&
                            sub.ccrz__InstallmentCountRemaining__c > 0) {
                        sub.ccrz__InstallmentNextDate__c = sub.ccrz__SubscriptionStartDate__c.addYears(offset);
                    } else if (sub.ccrz__SPTInstallmentFrequencyUOM__c == 'Monthly' &&
                            sub.ccrz__InstallmentCountRemaining__c > 0) {
                        sub.ccrz__InstallmentNextDate__c = sub.ccrz__SubscriptionStartDate__c.addMonths(offset);
                    }
                } else {
                    sub.ccrz__InstallmentLastDate__c = null;
                    sub.ccrz__InstallmentNextDate__c = null;
                }

                if (orderItemIdToAssetMap.get(sub.ccrz__CCOrderItem__c).CancelDate__c <= Date.today()
                        && orderItemIdToAssetMap.get(sub.ccrz__CCOrderItem__c).Status__c.equalsIgnoreCase('Inactive')) {
                    sub.ccrz__SubscriptionStatus__c = 'Expired';
                    sub.ccrz__OrderStatus__c = 'Expired';
                    sub.ccrz__InstallmentLastDate__c = orderItemIdToAssetMap.get(sub.ccrz__CCOrderItem__c).CancelDate__c;
                }
            } else {
                if (orderItemIdToAssetMap.get(sub.ccrz__CCOrderItem__c).CurrentExpirationDate__c != null) {
                    if (sub.ccrz__SPTInstallmentFrequencyUOM__c == 'Yearly') {
                        sub.ccrz__InstallmentLastDate__c = sub.ccrz__SubscriptionStartDate__c
                                .addYears((Integer) sub.ccrz__SPTInstallmentCount__c);
                        if (sub.ccrz__InstallmentCountRemaining__c > 0) {
                            sub.ccrz__InstallmentNextDate__c = sub.ccrz__SubscriptionStartDate__c.addYears(offset);
                        }
                    } else if (sub.ccrz__SPTInstallmentFrequencyUOM__c == 'Monthly') {
                        sub.ccrz__InstallmentLastDate__c = sub.ccrz__SubscriptionStartDate__c
                                .addMonths((Integer) sub.ccrz__SPTInstallmentCount__c);
                        if (sub.ccrz__InstallmentCountRemaining__c > 0) {
                            sub.ccrz__InstallmentNextDate__c = sub.ccrz__SubscriptionStartDate__c.addMonths(offset);
                        }
                    }
                    if (orderItemIdToAssetMap.get(sub.ccrz__CCOrderItem__c).CancelDate__c <= Date.today()
                            && orderItemIdToAssetMap.get(sub.ccrz__CCOrderItem__c).Status__c.equalsIgnoreCase('Inactive')) {
                        sub.ccrz__SubscriptionStatus__c = 'Expired';
                        sub.ccrz__OrderStatus__c = 'Expired';
                        sub.ccrz__InstallmentLastDate__c = orderItemIdToAssetMap.get(sub.ccrz__CCOrderItem__c).CancelDate__c;
                    }
                } else {
                    sub.ccrz__InstallmentLastDate__c = null;
                    sub.ccrz__InstallmentNextDate__c = null;
                }
            }
            sub.ccrz__OrderLastDate__c = sub.ccrz__InstallmentLastDate__c;
            sub.ccrz__OrderNextDate__c = sub.ccrz__InstallmentNextDate__c;

            if (sub.ccrz__InstallmentLastDate__c == null) {
                sub.ccrz__SubscriptionStatus__c = 'Pending';
                sub.ccrz__OrderStatus__c = 'Pending';
            } else {
                if (sub.ccrz__InstallmentLastDate__c != null && sub.ccrz__InstallmentLastDate__c > Date.today()) {
                    sub.ccrz__SubscriptionStatus__c = 'Active';
                    sub.ccrz__OrderStatus__c = 'Active';
                } else {
                    sub.ccrz__SubscriptionStatus__c = 'Expired';
                    sub.ccrz__OrderStatus__c = 'Expired';
                }
            }
            subsToUpdate.add(sub);
        }
        update subsToUpdate;
    }

}
//End//