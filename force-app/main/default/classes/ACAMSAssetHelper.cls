public with sharing class ACAMSAssetHelper {
    
    @Future
    public static void generateAssetsFuture(Id orderId) {
        generateAssets(orderId);
    }
    
    public static void generateAssets(Id orderId) {
       
        ccrz__E_Order__c order = ACAMSOrderDAO.getOrderForUpdate(orderId);//FSA-875
        
       
        //ACR-3106       
        RecordType assetRegistrantRecordType = [SELECT Id
                                                FROM RecordType
                                                WHERE Name = 'Registrant'
                                                AND SobjectType = 'Asset'];
        // Commented out due to ACR-2546
        /*List<Asset> existingAssets = new List<Asset>();
        if (order.ccrz__Contact__c != null) {
        existingAssets = ACAMSAssetDAO.getAssetsByContactIds(new Set<Id>{
        order.ccrz__Contact__c
        });
        }
        Set<String> existingAssetNames = new Set<String>();
        if (!existingAssets.isEmpty()) {
        for (Asset asset : existingAssets) {
        if (asset.ParentId == null) {
        existingAssetNames.add(asset.Name);
        }
        }
        }*/
        
        Map<Id, Decimal> orderItemsMap = new Map<Id, Decimal>();
        List<Asset> assetListToInsert = new List<Asset>();
        for (ccrz__E_OrderItem__c orderItem : order.ccrz__E_OrderItems__r) {
            orderItemsMap.put(orderItem.Id, orderItem.ccrz__Quantity__c);
            if (orderItem.ccrz__Product__r.ccrz__SKU__c == ACAMSUtil.SHIPPING_PRODUCT_SKU
                || orderItem.ccrz__Product__r.ccrz__ProductType__c == ACAMSUtil.BUNDLE
                || orderItem.ccrz__Product__r.ccrz__ProductType__c == ACAMSUtil.KIT
                || orderItem.ccrz__Product__r.ccrz__ProductType__c == ACAMSUtil.DYNAMIC_KIT
                || orderItem.ccrz__Product__r.ccrz__ProductType__c == ACAMSUtil.AGGREGATED) {
                    continue;
                }
            String level1 = orderItem.ccrz__Product__r.Level_1__c;
            String level2 = orderItem.ccrz__Product__r.Level_2__c;
            String level3 = orderItem.ccrz__Product__r.Level_3__c;
            String sku = orderItem.ccrz__Product__r.ccrz__SKU__c;
            
            String assetName = level1;
            Boolean isRegistrant = false;
            
            if (level1 == ACAMSUtil.ENTERPRISE_BUNDLE) {
                assetName = ACAMSUtil.MEMBERSHIP;
            } else if (level1 == ACAMSUtil.CERTIFICATION) {
                if (String.isNotBlank(level2)) {
                    if (level2 == ACAMSUtil.ADVANCED + ' ' + ACAMSUtil.CERTIFICATION) {
                        if (sku.contains('CAMSRM')) {
                            assetName = 'CAMSRM';
                        } else if (sku.contains('ADV1') || sku.contains('ADVCERT1')) {
                            assetName = 'CAMS Audit';
                        } else if (sku.contains('ADV2') || sku.contains('ADVCERT2')) {
                            assetName = 'CAMS FCI';
                        }
                    } else {
                        if (level2 == ACAMSUtil.REGIME_EXAM) {
                            assetName = level2;
                        } else {
                            assetName = level2 + ' ' + assetName;
                        }
                    }
                }
            } else if ((level1 == ACAMSUtil.CHAPTER && level2 == ACAMSUtil.MEMBERSHIP)) {
                assetName += ' ' + level2;
            } else if (level1 == ACAMSUtil.PUBLICATIONS) {
                if (level2 == ACAMSUtil.MONEYLAUNDERINGDOTCOM) {
                    assetName = ACAMSUtil.MONEYLAUNDERINGDOTCOM;
                } else if (level2 == ACAMSUtil.ACAMS_TODAY) {
                    assetName = ACAMSUtil.ACAMS_TODAY + ' ' + ACAMSUtil.PRINTED_SUBSCRIPTION;
                }
            } else if (level1 == ACAMSUtil.TRAINING && level2 == ACAMSUtil.CERTIFICATES) {
                assetName = ACAMSUtil.CERTIFICATE_COURSES;
            } else if (level1 == ACAMSUtil.CONFERENCES) {
                isRegistrant = true;
            } else if (level1 == ACAMSUtil.TRAINING && level2 == ACAMSUtil.SEMINARS) {
                isRegistrant = true;
                assetName = ACAMSUtil.SEMINARS;
            } else if (level1 == ACAMSUtil.TRAINING && level2 == ACAMSUtil.WEBINARS) {
                isRegistrant = true;
                assetName = ACAMSUtil.WEBINARS;
            } else if (level1 == ACAMSUtil.CHAPTER && level2 == ACAMSUtil.EVENT) {
                isRegistrant = true;
                assetName = ACAMSUtil.CHAPTER + ' ' + ACAMSUtil.EVENTS;
            } else if (level1 == ACAMSUtil.TRAINING && level2 == ACAMSUtil.CUSTOM_TRAINING) {
                isRegistrant = true;
                assetName = level2;
            } else if (level1 == ACAMSUtil.TRAINING && level2 == ACAMSUtil.PARTNERSHIPS) {
                isRegistrant = true;
                assetName = level2;
            } else if (level1 == ACAMSUtil.TRAINING && level2 == ACAMSUtil.EXAM_PREP) {
                isRegistrant = true;
                assetName = level2;
            }
            
            // Commented out due to ACR-2546
            /*if (existingAssetNames.contains(assetName)) {
            for (Asset asset : existingAssets) {
            if (asset.ParentId == null && asset.Name == assetName) {
            if (level1 == ACAMSUtil.CERTIFICATION && String.isNotBlank(level3)) {
            assetName += ' - ' + level3;
            }
            assetListToInsert.addAll(createAssets(assetName, order, orderItem, isRegistrant, asset));
            break;
            }
            }
            } else {*/
            if (level1 == ACAMSUtil.CERTIFICATION && String.isNotBlank(level3)) {
                assetName += ' - ' + level3;
            }
            assetListToInsert.addAll(createAssets(assetName, order, orderItem, isRegistrant,assetRegistrantRecordType,orderId));
            // Commented out due to ACR-2546
            //}
        }
        
        try {
            System.debug('assetListToInsert ::'+assetListToInsert.size());
            //FSA-875
            if(ACAMSUtil.canAddQueueableJob() && (System.isFuture() || System.isBatch())) {
                
                ID jobID = System.enqueueJob(new ACAMSUtil.InsertObject(assetListToInsert));//insert assetListToInsert;ACR-3106
                
            } else{
                
               insert assetListToInsert;   
            }
            
        } catch (DmlException e) {
            System.debug('DmlException in ACAMSAssetHelper: ' + e.getMessage() + ' ' + e.getStackTraceString()+e);
            
            if(ACAMSUtil.canAddQueueableJob() && (System.isFuture() || System.isBatch())){
                
                ID jobID = System.enqueueJob(new ACAMSUtil.InsertObject(assetListToInsert));//insert assetListToInsert;ACR-3106
            } else {
                insert assetListToInsert;    
            }
            
            
        }
        
        
        Set<Id> assetIds = new Set<Id>();
        for (Asset asset : assetListToInsert) {
            assetIds.add(asset.Id);
        }
        if (order.ccrz__PaymentMethod__c == ACAMSUtil.CC && order.Opportunity__c == null && order.ccrz__OrderStatus__c !='In Process') {
            if(System.isFuture() || System.isBatch()){//FSA-875
                activateAssets(orderItemsMap);
            }else{
                activateAssetsFuture(orderItemsMap);
            }
        }
    }
    
    private static List<Asset> createAssets(String assetName, ccrz__E_Order__c order, ccrz__E_OrderItem__c orderItem,
                                            Boolean isRegistrant,RecordType assetRegistrantRecordType, Id orderId) {
                                                return createAssets(assetName, order, orderItem, isRegistrant, null,assetRegistrantRecordType,orderId);
                                            }
    
    private static List<Asset> createAssets(String assetName, ccrz__E_Order__c order, ccrz__E_OrderItem__c orderItem,
                                            Boolean isRegistrant, Asset parentAsset, RecordType assetRegistrantRecordType, Id orderId) {
                                                
                                                ccrz__E_Order__c orderop = ACAMSOrderDAO.getOrderForUpdate(orderId);
                                                List<Asset> assets = new List<Asset>();
                                                System.debug('assetName : '+assetName+' order : '+order+' orderItem  : '+orderItem);
                                                /* RecordType assetRegistrantRecordType = [
SELECT Id
FROM RecordType
WHERE Name = 'Registrant'
AND SobjectType = 'Asset'
];*/ //ACR-3106 recordtype bulkified and will be passed as a parameter 
                                                for (Integer i = 0; i < orderItem.ccrz__Quantity__c; i++) {
                                                    System.debug('new asset');
                                                    Asset asset = new Asset();
                                                    if (isRegistrant) {
                                                        asset.RecordTypeId = assetRegistrantRecordType.Id;
                                                    }
                                                    //  if (i == 0) {
                                                    asset.ContactId = order.ccrz__Contact__c;
                                                    asset.Assignee__c = order.ccrz__Contact__c;
                                                    // } FSA-440 create contact and assignee for all Assets
                                                    asset.CC_Order__c = order.Id;
                                                    asset.CC_Order_Item__c = orderItem.Id;
                                                    asset.AccountId = order.ccrz__Account__c;
                                                    asset.CC_Product__c = orderItem.ccrz__Product__c;
                                                    asset.Status__c = ACAMSUtil.INACTIVE;
                                                    asset.Name = assetName;
                                                    
                                                    if (orderItem.ccrz__SubProdTerm__c != null) {
                                                        Decimal term = 12;
                                                        if (orderItem.ccrz__SubProdTerm__r.ccrz__InstallmentFrequencyUOM__c == 'Yearly') {
                                                            term = 12 * orderItem.ccrz__SubProdTerm__r.ccrz__InstallmentCount__c;
                                                        } else if (orderItem.ccrz__SubProdTerm__r.ccrz__InstallmentFrequencyUOM__c == 'Monthly') {
                                                            term = orderItem.ccrz__SubProdTerm__r.ccrz__InstallmentCount__c;
                                                        }
                                                        asset.Subscription_Term__c = term;
                                                    }
                                                    // Commented out due to ACR-2546
                                                    /*if (parentAsset != null) {
asset.ParentId = parentAsset.Id;
}*/
                                                    System.debug('asset : '+asset);
                                                    // if(orderop.Opportunity__r.No_Assets__c != false)
                                                    system.debug('No assets...'+ order.Opportunity__r.No_Assets__c);
                                                    assets.add(asset);
                                                    
                                                }
                                                return assets;
                                            }
    
    @Future
    public static void activateAssetsFuture(Map<Id, Decimal> orderItemsMap) {
        activateAssets(orderItemsMap);
    }
    
    public static void activateAssets(Map<Id, Decimal> orderItemsMap) {
        List<Asset> assets = ACAMSAssetDAO.getInactiveAssetsByOrderItemIds(orderItemsMap.keySet());
        Set<Id> contactIds = new Set<Id>();
        for (Asset asset : assets) {
            if (asset.Assignee__c != null) {
                contactIds.add(asset.Assignee__c);
            }
        }
        Map<Id, Contact> idToContactMap = new Map<Id, Contact>(ACAMSAccountDAO.getContactsByContactIds(contactIds));
        for (Asset asset : assets) {
            Decimal quantity = orderItemsMap.get(asset.CC_Order_Item__c);
            orderItemsMap.put(asset.CC_Order_Item__c, quantity - 1);
            if (asset.Effective_Date__c != null && asset.CurrentExpirationDate__c != null &&
                asset.Payment_Status__c != 'Authorized') {
                    continue;
                }
            if (orderItemsMap.get(asset.CC_Order_Item__c) < 0) {
                continue;
            }
            asset.Paid_Cert__c = true;
            asset.Status__c = 'Active';
            if(asset.InstallDate == null){
            asset.InstallDate = Date.today();
            }
            asset.Payment_Status__c = 'Completed';
            if (asset.Effective_Date__c == null && asset.CurrentExpirationDate__c == null) {
                Integer term = asset.Subscription_Term__c != null ? Integer.valueOf(asset.Subscription_Term__c) : 12;
                if (asset.Name == ACAMSUtil.MEMBERSHIP) {
                    if (idToContactMap.get(asset.Assignee__c) != null &&
                        idToContactMap.get(asset.Assignee__c).Member_Expire_Date__c != NULL &&
                        idToContactMap.get(asset.Assignee__c).Member_Expire_Date__c >= Date.today()) {
                            if( asset.Effective_Date__c == null){
                            asset.Effective_Date__c = idToContactMap.get(asset.Assignee__c).Member_Expire_Date__c;
                            }
                             if(asset.CurrentExpirationDate__c == null){
                            asset.CurrentExpirationDate__c =
                                idToContactMap.get(asset.Assignee__c).Member_Expire_Date__c.addMonths(term);
                             }
                               if(asset.CC_Product__r.LMS_Course__c != null && asset.LMS_Access_Exp_Date__c == null){
                               asset.LMS_Access_Exp_Date__c =  idToContactMap.get(asset.Assignee__c).Member_Expire_Date__c.addMonths(term);
                            }
                        } else {
                            if( asset.Effective_Date__c == null){
                            asset.Effective_Date__c = Date.today();
                            }
                             if(asset.CurrentExpirationDate__c == null){
                            asset.CurrentExpirationDate__c = Date.today().addMonths(term);
                             }
                               if(asset.CC_Product__r.LMS_Course__c != null && asset.LMS_Access_Exp_Date__c == null){
                               asset.LMS_Access_Exp_Date__c = Date.today().addMonths(term);
                            }
                        }
                } else if (asset.Name == ACAMSUtil.CHAPTER + ' ' + ACAMSUtil.MEMBERSHIP) {
                    if (idToContactMap.get(asset.Assignee__c) != NULL &&
                        idToContactMap.get(asset.Assignee__c).Chapter_Member_Expire_Date__c != NULL &&
                        idToContactMap.get(asset.Assignee__c).Chapter_Member_Expire_Date__c >= Date.today()) {
                            if( asset.Effective_Date__c == null){
                            asset.Effective_Date__c = idToContactMap.get(asset.Assignee__c).Chapter_Member_Expire_Date__c;
                            }
                             if(asset.CurrentExpirationDate__c == null){
                            asset.CurrentExpirationDate__c =
                                idToContactMap.get(asset.Assignee__c).Chapter_Member_Expire_Date__c.addMonths(term);
                             }
                             if(asset.CC_Product__r.LMS_Course__c != null && asset.LMS_Access_Exp_Date__c == null){
                               asset.LMS_Access_Exp_Date__c =   idToContactMap.get(asset.Assignee__c).Chapter_Member_Expire_Date__c.addMonths(term);
                            }
                        } else {
                            if( asset.Effective_Date__c == null){
                            asset.Effective_Date__c = Date.today();
                            }
                             if(asset.CurrentExpirationDate__c == null){
                            asset.CurrentExpirationDate__c = Date.today().addMonths(term);
                             }
                              if(asset.CC_Product__r.LMS_Course__c != null && asset.LMS_Access_Exp_Date__c == null){
                               asset.LMS_Access_Exp_Date__c = Date.today().addMonths(term);
                            }
                        }
                } else if (asset.Name == ACAMSUtil.MONEYLAUNDERINGDOTCOM) {
                    if (idToContactMap.get(asset.Assignee__c) != NULL &&
                        idToContactMap.get(asset.Assignee__c).MLDC_Expiration_Date__c != NULL &&
                        idToContactMap.get(asset.Assignee__c).MLDC_Expiration_Date__c >= Date.today()) {
                            if( asset.Effective_Date__c == null){
                            asset.Effective_Date__c = idToContactMap.get(asset.Assignee__c).MLDC_Expiration_Date__c;
                            }
                             if(asset.CurrentExpirationDate__c == null){
                            asset.CurrentExpirationDate__c =
                                idToContactMap.get(asset.Assignee__c).MLDC_Expiration_Date__c.addMonths(term);
                             }
                             if(asset.CC_Product__r.LMS_Course__c != null && asset.LMS_Access_Exp_Date__c == null){
                               asset.LMS_Access_Exp_Date__c = idToContactMap.get(asset.Assignee__c).MLDC_Expiration_Date__c.addMonths(term);
                            }
                        } else {
                            if( asset.Effective_Date__c == null){
                            asset.Effective_Date__c = Date.today();
                            }
                             if(asset.CurrentExpirationDate__c == null){
                            asset.CurrentExpirationDate__c = Date.today().addMonths(term);
                             }
                             if(asset.CC_Product__r.LMS_Course__c != null && asset.LMS_Access_Exp_Date__c == null){
                               asset.LMS_Access_Exp_Date__c = Date.today().addMonths(term);
                            }
                        }
                } else if (asset.Name == ACAMSUtil.ACAMS_TODAY + ' ' + ACAMSUtil.PRINTED_SUBSCRIPTION) {
                    if (idToContactMap.get(asset.Assignee__c) != NULL &&
                        idToContactMap.get(asset.Assignee__c).ACAMS_Today_Expiration_Date__c != NULL &&
                        idToContactMap.get(asset.Assignee__c).ACAMS_Today_Expiration_Date__c >= Date.today()) {
                            if( asset.Effective_Date__c == null){
                            asset.Effective_Date__c = idToContactMap.get(asset.Assignee__c).ACAMS_Today_Expiration_Date__c;
                            }
                             if(asset.CurrentExpirationDate__c == null){
                            asset.CurrentExpirationDate__c =
                                idToContactMap.get(asset.Assignee__c).ACAMS_Today_Expiration_Date__c.addMonths(term);
                             }
                              if(asset.CC_Product__r.LMS_Course__c != null && asset.LMS_Access_Exp_Date__c == null){
                               asset.LMS_Access_Exp_Date__c = idToContactMap.get(asset.Assignee__c).ACAMS_Today_Expiration_Date__c.addMonths(term);
                            }
                        } else {
                            if( asset.Effective_Date__c == null){
                            asset.Effective_Date__c = Date.today();
                            }
                             if(asset.CurrentExpirationDate__c == null){
                            asset.CurrentExpirationDate__c = Date.today().addMonths(term);
                             }
                              if(asset.CC_Product__r.LMS_Course__c != null && asset.LMS_Access_Exp_Date__c == null){
                               asset.LMS_Access_Exp_Date__c = Date.today().addMonths(term);
                            }
                        }
                } else {
                   if (asset.CC_Product__r.Level_1__c != ACAMSUtil.CERTIFICATION) {
                       if(asset.Effective_Date__c == null){
                        asset.Effective_Date__c = Date.today();
                       }
                        Integer daysToExpire = asset.CC_Product__r.Days_to_Expire__c != null ?
                            Integer.valueOf(asset.CC_Product__r.Days_to_Expire__c) : 5;
                         Integer monthsToExpire = (daysToExpire == 5 && asset.Subscription_Term__c != null)? Integer.valueOf(asset.Subscription_Term__c) : 0;
                        if (asset.CC_Product__r.Expiration_Date_Logic__c != null &&
                            asset.CC_Product__r.Expiration_Date_Logic__c == ACAMSUtil.PAYMENT) {
                                if(monthsToExpire != 0){
                                    if(asset.CurrentExpirationDate__c == null){
                                     asset.CurrentExpirationDate__c = Date.today().addMonths(monthsToExpire);
                                    }
                                   if(asset.CC_Product__r.LMS_Course__c != null && asset.LMS_Access_Exp_Date__c == null){
                               asset.LMS_Access_Exp_Date__c =  Date.today().addMonths(monthsToExpire);
                                
                                   }
                                }
                                else{
                                     if(asset.CurrentExpirationDate__c == null){
                                asset.CurrentExpirationDate__c = Date.today().addDays(daysToExpire);
                                     }
                                   if(asset.CC_Product__r.LMS_Course__c != null && asset.LMS_Access_Exp_Date__c == null){
                               asset.LMS_Access_Exp_Date__c =  Date.today().addDays(daysToExpire);
                            }
                                
                                }
                            } else {
                                Date eventDate = asset.CC_Product__r.Event_Date__c != null &&
                                    asset.CC_Product__r.Event_Date__c >= Date.today() ? asset.CC_Product__r.Event_Date__c :
                                Date.today();
                                if(monthsToExpire != 0){
                                     if(asset.CurrentExpirationDate__c == null){
                                      asset.CurrentExpirationDate__c = eventDate.addMonths(monthsToExpire);
                                     }
                                   if(asset.CC_Product__r.LMS_Course__c != null && asset.LMS_Access_Exp_Date__c == null){
                               asset.LMS_Access_Exp_Date__c = eventDate.addMonths(monthsToExpire);
                                   }
                                }
                                else{
                                     if(asset.CurrentExpirationDate__c == null){
                                asset.CurrentExpirationDate__c = eventDate.addDays(daysToExpire);
                                     }
                                   if(asset.CC_Product__r.LMS_Course__c != null && asset.LMS_Access_Exp_Date__c == null){
                               asset.LMS_Access_Exp_Date__c = eventDate.addDays(daysToExpire);
                                   }
                            }
                            }
                    }
                    
                    if(asset.CC_Product__r.Level_1__c == ACAMSUtil.CERTIFICATION && asset.CC_Product__r.Level_3__c == 'Retake/Extension' ){
                         if(asset.Effective_Date__c == null){
                        asset.Effective_Date__c = Date.today();
                         }
                    }
                    
                }
            }
        }
        update assets;
    }
    
    public static void cancelAssetsByOrderIds(Set<Id> orderIds) {
        List<Asset> assetsToUpdate = new List<Asset>();
        for (Asset asset : ACAMSAssetDAO.getAssetsByOrderIds(orderIds)) {
            asset.Status__c = ACAMSUtil.INACTIVE;
            asset.CancelDate__c = Date.today();
            assetsToUpdate.add(asset);
        }
        update assetsToUpdate;
    }
//csa fix added method to fix soql 101
    @future
    public static void cancelAssetsByOrderIdsFuture(Set<Id> orderIds) {
        List<Asset> assetsToUpdate = new List<Asset>();
        for (Asset asset : ACAMSAssetDAO.getAssetsByOrderIds(orderIds)) {
            asset.Status__c = ACAMSUtil.INACTIVE;
            asset.CancelDate__c = Date.today();
            assetsToUpdate.add(asset);
        }
        update assetsToUpdate;
    }
    
    public static void cancelAssetsByOrderItemIds(Set<Id> orderItemIds) {
        List<Asset> assetsToUpdate = new List<Asset>();
        for (Asset asset : ACAMSAssetDAO.getAssetsByOrderItemIds(orderItemIds)) {
            asset.Status__c = ACAMSUtil.INACTIVE;
            asset.CancelDate__c = Date.today();
            assetsToUpdate.add(asset);
        }
        update assetsToUpdate;
    }
}