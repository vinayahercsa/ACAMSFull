/**
 *      @author Kumar Ganadurai
 *      @date   6/5/2017 - Initial Version
        @description    Helper class for ManageAttachments trigger on Attachment 
        
 */

public without sharing class AttachmentHelper {
    public static void EvaluateCreditOnCerttification(List<attachment> newAttLst)   {
        Set<ID> memCertIds = new Set<ID>();
        Set<ID> memCertApplIds = new Set<ID>();
        List<Certification_Application__c> memCertApplLst = new List<Certification_Application__c>();
        List<Certification_Application__c> memCertAppUpdlLst = new List<Certification_Application__c>();
        map<id,List<Memberships_and_Certifications__c>> applTrainMemMap = new map<id,List<Memberships_and_Certifications__c>>();
        Set<ID> trainCertIds = new Set<ID>();
        Set<ID> trainCertApplIds = new Set<ID>();
        List<Certification_Application__c> trainCertApplLst = new List<Certification_Application__c>();
        List<Certification_Application__c> trainCertAppUpdlLst = new List<Certification_Application__c>();
        map<id,List<Training__c>> applTrainMap = new map<id,List<Training__c>>();
        Set<ID> educationIds = new Set<ID>();
        List<Education__c> educationUpdLst = new List<Education__c>();
        List<Memberships_and_Certifications__c> memCertUpdLst = new List<Memberships_and_Certifications__c>();
        List<Training__c> extCertUpdLst = new List<Training__c>();
        for(Attachment att : newAttLst){
             if(att.ParentId.getSobjectType() == Memberships_and_Certifications__c.SobjectType){
                  memCertIds.add(att.ParentId);
             }
             if(att.ParentId.getSobjectType() == Training__c.SobjectType){
                  trainCertIds.add(att.ParentId);
             }
             if(att.ParentId.getSobjectType() == Education__c.SobjectType){
                  educationIds.add(att.ParentId);
             }
        }
        if(!educationIds.IsEmpty()) {
            for(Education__c edu : [select id,Has_Proof__c,Education_credits_Incomplete__c  from Education__c where id in : educationIds])   {
                edu.Has_Proof__c = true;
                edu.Education_credits_Incomplete__c = 0;
                educationUpdLst.add(edu);
            }
        }
        if(!educationUpdLst.IsEmpty())  {
            update educationUpdLst;
        }
        if(!memCertIds.IsEmpty()) {
            for(Memberships_and_Certifications__c train : [select id,Has_Proof__c,Training_Credits_Incomplete__c from Memberships_and_Certifications__c where id in : memCertIds])   {
                train.Has_Proof__c = true;
                train.Training_Credits_Incomplete__c = 0;
                memCertUpdLst.add(train);
            }
        }
        if(!memCertUpdLst.IsEmpty())  {
            update memCertUpdLst;
        }
        if(!trainCertIds.IsEmpty()) {
            for(Training__c train : [select id,Credit_hours__c,Has_Proof__c,InComplete_Ext_Training_Credits__c,Complete_Ext_Training_Credits__c,Certification_Application__c from  Training__c where id in :trainCertIds])   {
                train.Has_Proof__c = true;
                train.InComplete_Ext_Training_Credits__c = 0;
                extCertUpdLst.add(train);
            }
        }
        if(!extCertUpdLst.IsEmpty())  {
            update extCertUpdLst;
        }
    }
}