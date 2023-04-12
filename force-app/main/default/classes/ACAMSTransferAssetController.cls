public with sharing class ACAMSTransferAssetController {

    public Asset assetToTransfer { get; set; }

    public ACAMSTransferAssetController() {}


    public ACAMSTransferAssetController(ApexPages.StandardController transferAssetController) {
        this.assetToTransfer = [
                SELECT
                        Id, CancelDate__c, Cancel_Reason__c, ContactId, AccountId, Enterprise_Product_HL__c,
                        CC_Order__c, CC_Order_Item__c
                FROM
                        Asset
                WHERE
                        Id = :transferAssetController.getId()
        ];
    }


    public PageReference redirect() {
        assetToTransfer.CancelDate__c = Date.today();
        Id ccOrderId = assetToTransfer.CC_Order__c;
        Id ccOrderItemId = assetToTransfer.CC_Order_Item__c;
        if (assetToTransfer.Enterprise_Product_HL__c != null && assetToTransfer.Enterprise_Product_HL__c.contains('ENT')) {
            assetToTransfer.Cancel_Reason__c = 'Removed from Enterprise';
        } else {
            assetToTransfer.Cancel_Reason__c = 'Transferred between Accounts';
        }
        assetToTransfer.CC_Order__c = null;
        assetToTransfer.CC_Order_Item__c = null;
        update assetToTransfer;

        String url = '/' + assetToTransfer.Id + '/e?clone=1';
        List<EntityDefinition> getFieldIDs = [
                SELECT
                        QualifiedApiName,
                (
                        SELECT
                                DeveloperName,
                                DurableId
                        FROM
                                Fields
                )
                FROM
                        EntityDefinition
                WHERE
                        QualifiedApiName = 'Asset'
        ];

        for (EntityDefinition entityDefinition : getFieldIDs) {
            for (FieldDefinition field : entityDefinition.Fields) {
                if (field.DeveloperName == 'Status' && field.DurableId != 'Asset.Status') {
                    List<String> res = field.DurableId.split('\\.');
                    url += '&' + res[1] + '=Active';
                } else if (field.DeveloperName == 'Cancel_Reason') {
                    List<String> res = field.DurableId.split('\\.');
                    url += '&' + res[1] + '=';
                } else if (field.DeveloperName == 'CancelDate') {
                    List<String> res = field.DurableId.split('\\.');
                    url += '&' + res[1] + '=';
                } else if (field.DeveloperName == 'Exam_Schedule_Date') {
                    List<String> res = field.DurableId.split('\\.');
                    url += '&' + res[1] + '=';
                } else if (field.DeveloperName == 'Assignee') {
                    List<String> res = field.DurableId.split('\\.');
                    url += '&CF' + res[1] + '=';
                } else if (field.DeveloperName == 'ContactId') {
                    List<String> res = field.DurableId.split('\\.');
                    url += '&CF' + res[1] + '=';
                } else if (field.DeveloperName == 'ParentId') {
                    List<String> res = field.DurableId.split('\\.');
                    url += '&CF' + res[1] + '=';
                } else if (field.DeveloperName == 'Enterprise_Welcome_Email_Source') {
                    List<String> res = field.DurableId.split('\\.');
                    url += '&' + res[1] + '=';
                } else if (field.DeveloperName == 'Enterprise_Welcome_Email') {
                    List<String> res = field.DurableId.split('\\.');
                    url += '&' + res[1] + '=';
                } else if (field.DeveloperName == 'Enterprise_Renewal_Email') {
                    List<String> res = field.DurableId.split('\\.');
                    url += '&' + res[1] + '=';
                } else if (field.DeveloperName == 'Application_Date') {
                    List<String> res = field.DurableId.split('\\.');
                    url += '&' + res[1] + '=';
                } else if (field.DeveloperName == 'Application_Received') {
                    List<String> res = field.DurableId.split('\\.');
                    url += '&' + res[1] + '=';
                } else if (field.DeveloperName == 'Certification_Approved_Application') {
                    List<String> res = field.DurableId.split('\\.');
                    url += '&' + res[1] + '=';
                } else if (field.DeveloperName == 'Certification_Exam_Passed') {
                    List<String> res = field.DurableId.split('\\.');
                    url += '&' + res[1] + '=';
                } else if (field.DeveloperName == 'ExamResult') {
                    List<String> res = field.DurableId.split('\\.');
                    url += '&CF' + res[1] + '=';
                } else if (field.DeveloperName == 'White_Paper_Approved_Date') {
                    List<String> res = field.DurableId.split('\\.');
                    url += '&' + res[1] + '=';
                } else if (field.DeveloperName == 'White_Paper_Assignment_Approved') {
                    List<String> res = field.DurableId.split('\\.');
                    url += '&' + res[1] + '=';
                } else if (field.DeveloperName == 'White_Paper_Published') {
                    List<String> res = field.DurableId.split('\\.');
                    url += '&' + res[1] + '=';
                } else if (field.DeveloperName == 'Paid_Cert') {
                    List<String> res = field.DurableId.split('\\.');
                    url += '&' + res[1] + '=';
                } else if (field.DeveloperName == 'CC_Order') {
                    List<String> res = field.DurableId.split('\\.');
                    url += '&' + res[1] + '=' + ccOrderId;
                } else if (field.DeveloperName == 'CC_Order_Item') {
                    List<String> res = field.DurableId.split('\\.');
                    url += '&' + res[1] + '=' + ccOrderItemId;
                }
            }
        }

        final PageReference target = new PageReference(Site.getBaseSecureUrl() + url);
        target.setRedirect(true);
        return target;
    }

}