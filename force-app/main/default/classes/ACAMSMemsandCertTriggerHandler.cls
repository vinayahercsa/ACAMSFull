public class ACAMSMemsandCertTriggerHandler  extends CCAviTriggerHandler {
    private List<Memberships_and_Certifications__c> newList;
    private List<Memberships_and_Certifications__c> oldList;
    private Map<Id, Memberships_and_Certifications__c> newMap;
    private Map<Id, Memberships_and_Certifications__c> oldMap;
    
   
      public ACAMSMemsandCertTriggerHandler() {
        super();
        this.newList = (List<Memberships_and_Certifications__c>) Trigger.new;
        this.oldList = (List<Memberships_and_Certifications__c>) Trigger.old;
        this.newMap = (Map<Id, Memberships_and_Certifications__c>) Trigger.newMap;
        this.oldMap = (Map<Id, Memberships_and_Certifications__c>) Trigger.oldMap;
    }
    public override void afterInsert() {
        CalculateCreditScoreCertMem(this.oldMap,this.newList,false);
    }
    public override void afterUpdate() {
       CalculateCreditScoreCertMem(this.oldMap,this.newList,true);
    }
    
     public static void CalculateCreditScoreCertMem (map<id,Memberships_and_Certifications__c> oldTrainMemMap, list<Memberships_and_Certifications__c> newTrainMemLst,boolean isUpdt)    {
        set<id> certApplIds = new Set<id>();
        map<id,List<Memberships_and_Certifications__c>> applTrainMemMap = new map<id,List<Memberships_and_Certifications__c>>();
        list<Certification_Application__c> certApplLst = new list<Certification_Application__c>();
        list<Certification_Application__c> certAppUpdlLst = new list<Certification_Application__c>();
        for(Memberships_and_Certifications__c trainMem : newTrainMemLst) {
            if(trainMem.Approved__c) {
                if(!isUpdt) {
                    certApplIds.add(trainMem.Certification_Application__c);
                }
                else    {
                    if(trainMem.Certification_or_Membership__c != oldTrainMemMap.get(trainMem.ID).Certification_or_Membership__c)  {
                        certApplIds.add(trainMem.Certification_Application__c);
                    }
                }
            }
        }
        if(!certApplIds.IsEmpty())  {
            for(Memberships_and_Certifications__c trainMem : [select id,Certification_or_Membership__c,Certification_Application__c from  Memberships_and_Certifications__c where Certification_Application__c in :certApplIds ])  {
                if(!applTrainMemMap.containskey(trainMem.Certification_Application__c)) {
                    applTrainMemMap.put(trainMem.Certification_Application__c,new List<Memberships_and_Certifications__c>{trainMem});
                }
                else    {
                    applTrainMemMap.get(trainMem.Certification_Application__c).add(trainMem);
                }
            }
            certApplLst = [select id, Certifictaions_and__c from Certification_Application__c where id in : certApplIds];
        }
        if(!applTrainMemMap.IsEmpty())   {
            integer trainMemCred = 0;
            integer trainCnt = 0;
            for(Certification_Application__c certAppl : certApplLst)    {
                if(applTrainMemMap.containskey(certAppl.ID))   {
                    for(Memberships_and_Certifications__c curMem : applTrainMemMap.get(certAppl.ID))    {
                        if(curMem.Certification_or_Membership__c == null)   {
                            trainCnt = trainCnt - 1;
                        }
                        else if(curMem.Certification_or_Membership__c == 'ACCA Membership') {
                            trainCnt = trainCnt + 3;
                        }
                        else    {
                            if(oldTrainMemMap.get(curMem.ID).Certification_or_Membership__c != null)    {
                                trainCnt = trainCnt + 1;
                            }
                        }
                    }
                    if(trainCnt >= 4)   {
                        trainMemCred = 4 * 10;
                    }
                    else{
                        trainMemCred = trainCnt * 10;
                    }
                    certAppUpdlLst.add(certAppl);
                }
            }
        }
        if(!certAppUpdlLst.IsEmpty())   {
            update certAppUpdlLst;
        }
    }

}