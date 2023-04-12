public with sharing class ACAMSAssetDAO {

    public static List<Asset> getAssetsByContactIds(Set<Id> contactIds) {
        List<Asset> assetsList = [
                SELECT
                        Id,
                        Name,
                        Assignee__c,
                        CurrentExpirationDate__c,
                        ParentId,
                        Subscription_Term__c
                FROM
                        Asset
                WHERE
                        Assignee__c IN :contactIds
        ];

        return assetsList;
    }

    public static List<Asset> getAssetsByOrderItemIds(Set<Id> orderItemIds) {
        List<Asset> assets = [
                SELECT
                        AccountId,
                        Assignee__c,
                        CC_Order_Item__c,
                        CC_Product__c,
                        CC_Product__r.Days_to_Expire__c,
                        CC_Product__r.Event_Date__c,
                        CC_Product__r.Expiration_Date_Logic__c,
                        CC_Product__r.Level_1__c,
                        Effective_Date__c,
                        CurrentExpirationDate__c,
                        Id,
                        Name,
                        Paid_Cert__c,
                        RecordTypeId,
                        Status__c,
                        Subscription_Term__c
                FROM
                        Asset
                WHERE
                        CC_Order_Item__c IN :orderItemIds
        ];
        return assets;
    }

    public static List<Asset> getInactiveAssetsByOrderItemIds(Set<Id> orderItemIds) {
        List<Asset> assets = [
                SELECT
                        AccountId,
                        Assignee__c,
                        Assignee__r.CAMS_Audit_Expiration_Date__c,
                        Assignee__r.CAMS_Expiration_Date__c,
                        Assignee__r.CAMS_FCI_Expiration_Date__c,
                        Assignee__r.CAMSRM_Expiration_Date__c,
                        Assignee__r.CGSS_Expiration_Date__c,
                        Assignee__r.CKYCA_Expiration_Date__c,
                        Assignee__r.CTMA_Expiration_Date__c,
                        CC_Order_Item__c,
                        CC_Product__c,
                        CC_Product__r.Days_to_Expire__c,
                        CC_Product__r.Event_Date__c,
                        CC_Product__r.Expiration_Date_Logic__c,
                        CC_Product__r.Level_1__c,
                        CC_Product__r.Level_2__c,
                        CC_Product__r.Level_3__c,
                        CC_Product__r.LMS_Course__c,
                        CC_Product__r.Certification_Level__c,
                        CreatedDate,
                        CurrentExpirationDate__c,
                        Effective_Date__c,
                        Exam_Pass_Date__c,
                        Id,
                        LMS_Access_Exp_Date__c,
                        Name,
                        Paid_Cert__c,
                        Payment_Status__c,
                        RecordTypeId,
                        Status__c,
                        Subscription_Term__c,
            			InstallDate
                FROM
                        Asset
                WHERE
                        CC_Order_Item__c IN :orderItemIds
                AND
                        (Status__c = :ACAMSUtil.INACTIVE OR Payment_Status__c = :'Authorized' )
        ];
        return assets;
    }

    public static List<Asset> getAssetsByIds(Set<Id> assetIds) {
        List<Asset> assets = [
                SELECT
                        AccountId,
                        CC_Product__c,
                        CC_Product__r.Event_Date__c,
                        Id,
                        Name,
                        Paid_Cert__c,
                        RecordTypeId,
                        Status__c,
                        Subscription_Term__c
                FROM
                        Asset
                WHERE
                        Id IN :assetIds
        ];
        return assets;
    }

    public static List<Asset> getAssetsByOrderIds(Set<Id> orderIds) {
        List<Asset> assets = [
                SELECT
                        Id,
                        Status__c
                FROM
                        Asset
                WHERE
                        CC_Order__c IN :orderIds
        ];
        return assets;
    }
}
//endtest//