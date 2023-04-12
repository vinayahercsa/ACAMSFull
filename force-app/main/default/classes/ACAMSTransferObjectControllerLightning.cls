public with sharing class ACAMSTransferObjectControllerLightning {

    @AuraEnabled
    public static String transferAsset(String recordId) {
        Asset assetToTransfer = Database.query(getObjectQuery('Asset', recordId));
        Id ccOrderId = assetToTransfer.CC_Order__c;
        Id ccOrderItemId = assetToTransfer.CC_Order_Item__c;
        assetToTransfer.CancelDate__c = Date.today();
        if (assetToTransfer.Enterprise_Product_HL__c != null && assetToTransfer.Enterprise_Product_HL__c.contains('ENT')) {
            assetToTransfer.Cancel_Reason__c = 'Removed from Enterprise';
        } else {
            assetToTransfer.Cancel_Reason__c = 'Transferred between Accounts';
        }
        assetToTransfer.CC_Order__c = null;
        assetToTransfer.CC_Order_Item__c = null;
        update assetToTransfer;

        Asset clonedAsset = assetToTransfer.clone(false, true, false, false);
        try {
            clonedAsset.Status__c = assetToTransfer.Status__c;
            clonedAsset.Cancel_Reason__c = '';
            clonedAsset.CancelDate__c = null;
            clonedAsset.Exam_Schedule_Date__c = null;
            clonedAsset.Assignee__c = null;
            clonedAsset.ContactId = null;
            clonedAsset.ParentId = null;
            clonedAsset.Enterprise_Welcome_Email_Source__c = '';
            clonedAsset.Enterprise_Welcome_Email__c = false;
            clonedAsset.Enterprise_Renewal_Email__c = false;
            clonedAsset.Application_Date__c = null;
            clonedAsset.Application_Received__c = false;
            clonedAsset.Certification_Approved_Application__c = false;
            clonedAsset.Certification_Exam_Passed__c = false;
            clonedAsset.ExamResult__c = null;
            clonedAsset.White_Paper_Approved_Date__c = null;
            clonedAsset.White_Paper_Assignment_Approved__c = false;
            clonedAsset.White_Paper_Published__c = false;
            clonedAsset.Paid_Cert__c = false;
            clonedAsset.CC_Order__c = ccOrderId;
            clonedAsset.CC_Order_Item__c = ccOrderItemId;
            insert clonedAsset;

            // FSA-354
            AssetRelationship ar = new AssetRelationship();
            ar.AssetId=clonedAsset.id;
            ar.RelatedAssetId=assetToTransfer.id;
            ar.RelationshipType='Transfer Asset';
            ar.FromDate = assetToTransfer.CreatedDate;
            ar.ToDate = DateTime.now();
            
            insert ar;
            
            return clonedAsset.Id;
            						
        } catch (Exception e) {
            return '';
        }
    }

    public static String getObjectQuery(String objectAPIName, String recordId) {
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        List<String> fieldsList = new List<String>(schemaMap.get(objectAPIName).getDescribe().fields.getMap().keySet());
        String soqlQuery = 'SELECT ' ;
        soqlQuery += String.join(fieldsList, ',');
        soqlQuery += ' FROM ' + objectAPIName + ' WHERE ID = \'' + recordId + '\'' ;
        return soqlQuery;
    }

}