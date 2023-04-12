public class ACAMSRecertCycleTriggerHandler extends CCAviTriggerHandler {
    
    private List<Recert_Cycle__c> newList;
    private List<Recert_Cycle__c> oldList;
    private Map<Id, Recert_Cycle__c> newMap;
    private Map<Id, Recert_Cycle__c> oldMap;
     Public static boolean examResultPass = false; //fsa-831
    private List<Asset> newListAsset;
    private Map<Id, Asset> oldMapAsset;
       
    public ACAMSRecertCycleTriggerHandler() {
        super();
        this.newList = (List<Recert_Cycle__c>) Trigger.new;
        this.oldList = (List<Recert_Cycle__c>) Trigger.old;
        this.newMap = (Map<Id, Recert_Cycle__c>) Trigger.newMap;
        this.oldMap = (Map<Id, Recert_Cycle__c>) Trigger.oldMap;
        
    }
  /*   public override void beforeUpdate(){
        // if()
       insertAssetOnRecertCycle(this.newList,this.oldMap);
        system.debug('inside after update insertAssetOnRecertCycle--->');
    } */
    
   public override void afterUpdate(){
     //  insertAssetOnRecertCycle(this.newList,this.oldMap);
    // recertCycleEligibility(this.newList,this.oldMap); 
      //  system.debug('inside after update insertAssetOnRecertCycle--->');
    } 
     public override void beforeUpdate(){
       insertAssetOnRecertCycle(this.newList,this.oldMap);
        recertCycleEligibility(this.newList);
      // ACAMSAssetTriggerHandler.recertExpDate(newListAsset,oldMapAsset);//fsa-262
        system.debug('inside after update insertAssetOnRecertCycle--->');
    }
    
    public static void recertCycleEligibility(list<Recert_Cycle__c> newList) {
        list<Recert_Cycle__c> lstrec =new list<Recert_Cycle__c>();
        for (Recert_Cycle__c recEligible: newList){
            if(recEligible.Asset_Present__c == true){
            string MultiSelectPickList ='Meet Membership;Meet ECU';
               recEligible.Eligible__c = MultiSelectPickList;
                lstrec.add(recEligible);
                }            
        }
        
    }
    
    
    public static void insertAssetOnRecertCycle(list<Recert_Cycle__c> newList,Map<Id, Recert_Cycle__c> oldMap) {
        system.debug('inside method insertAssetOnRecertCycle---->');
         Map<Id, Contact> mapCon = new Map<Id, Contact>();
         set<Id> conId= new set<Id>();
        for(Recert_Cycle__c rec: newList){
          conId.add(rec.Contact__c);
        } 
        system.debug('conId--->'+conId);
        for(Contact c: [select Id ,Member_Expire_Date__c,AccountId from Contact where Id IN: conId]){
       mapCon.put(c.id,c);
          } 
        
        map<String,ccrz__E_Product__c> mapCCProduct = new map<String,ccrz__E_Product__c>();
        set<Id> ccProdcutId = new set<Id>();      
        list<string> lstSku =new list<string>();
        
        for(Recert_Cycle__c r: newList){
            String recertCycleName = String.valueOf(r.Name);
               
               String myString = recertCycleName.right(2);
               system.debug('myString--->'+myString);
              string  productSku = 'RECE'+r.Certification_Type__c+myString;
            lstSku.add(productSku);
            
        }
        
        for(ccrz__E_Product__c ccProduct:[select id,Name,ccrz__SKU__c  from ccrz__E_Product__c where ccrz__SKU__c In:lstSku]){
            system.debug('ccProduct--->'+ccProduct);
         mapCCProduct.put(ccProduct.ccrz__SKU__c,ccProduct);        
        }   
        system.debug('mapCCProduct--->'+mapCCProduct);
        system.debug('mapCCProduct.keset()------>'+mapCCProduct.keySet());
         RecordType assetMasterRecordType = [SELECT Id
                                                FROM RecordType
                                                WHERE Name = 'Master'
                                                AND SobjectType = 'Asset'];
    
        set<Id> recertId =new set<Id>();
        list<Asset> lstAsset = new list<Asset>();    
        
        for(Recert_Cycle__c r: newList){
            system.debug('Inside forEach Loop-->');
            
            if(r.Asset_Present__c == false){
          //  if(r.End_Date__c == system.today() && r.End_Date__c != oldMap.get(r.id).End_Date__c && mapCon.get(r.Contact__c).Member_Expire_Date__c>= r.End_Date__c &&  r.Total_ECU__c >= 2){
        //  if(r.End_Date__c == system.today() &&  mapCon.get(r.Contact__c).Member_Expire_Date__c>= r.End_Date__c &&  r.Total_ECU__c >= 2 && r.Asset_Present__c== false){ 
          if(r.End_Date__c == system.today() &&  mapCon.get(r.Contact__c).Member_Expire_Date__c>= r.End_Date__c &&  r.Total_ECU__c >= 2){   
            system.debug('inside if condition logic--->');
                
                String recertCycleName = String.valueOf(r.Name);
               
               String myString = recertCycleName.right(2);
               system.debug('myString--->'+myString);
              string  productSku = 'RECE'+r.Certification_Type__c+myString;
               system.debug('productSku--->'+productSku);
              // r.Asset_Present__c = true;  

                if(r.Certification_Type__c == 'CKYCA' ){
                             Asset a = new Asset(); 
              a.Name = 'CKYCA Certification - Recertification';
                    system.debug('a.Name------>'+a.Name);
              a.RecordTypeId = assetMasterRecordType.Id;
                    system.debug('a.RecordTypeId------>'+a.RecordTypeId);
              a.AccountId = mapCon.get(r.Contact__c).AccountId;
                     system.debug('a.AccountId------>'+a.AccountId);
              a.Assignee__c = r.Contact__c;
                    system.debug('a.Assignee__c------>'+a.Assignee__c);
            //  a.CC_Product__c ='CKYCA Recertification Fee'+' '+r.End_Date__c.year();                
              a.CC_Product__c = mapCCProduct.get(productSku).id;
              system.debug(' mapCCProduct.get(productSku).id2-->'+ mapCCProduct.get(productSku).id);
                    
              a.Payment_Status__c = 'Completed';
              a.Status__c = 'Active';
              a.Paid_Cert__c = True;
              a.InstallDate =system.today();
              lstAsset.add(a);
             }
                if(r.Certification_Type__c == 'CAFCA'){
                    Asset a = new Asset(); 
              a.Name = 'CAFCA Certification - Recertification';
              a.RecordTypeId = assetMasterRecordType.Id;
              a.AccountId = mapCon.get(r.Contact__c).AccountId;
              a.Assignee__c = r.Contact__c;
              a.CC_Product__c = mapCCProduct.get(productSku).id;
              a.Payment_Status__c = 'Completed';
              a.Status__c = 'Active';
              a.Paid_Cert__c = True;
              a.InstallDate =system.today();
              lstAsset.add(a);
             }
                if(r.Certification_Type__c == 'CTMA'){
                Asset a = new Asset();
              a.Name = 'CTMA Certification - Recertification';
              a.RecordTypeId = assetMasterRecordType.Id;
              a.AccountId = mapCon.get(r.Contact__c).AccountId;
              a.Assignee__c = r.Contact__c;
              a.CC_Product__c = mapCCProduct.get(productSku).id;
              a.Payment_Status__c = 'Completed';
              a.Status__c = 'Active';
              a.Paid_Cert__c = True;
              a.InstallDate =system.today();
              lstAsset.add(a);
             }   
               r.Asset_Present__c = true;
            //  string MultiSelectPickList ='Meet Membership,Meet ECU';
            //   r.Eligible__c = MultiSelectPickList;
           //   database.update(r);
        }   
            //    r.Asset_Present__c = true;
            }//Checkbox false end
    }    
        if(!examResultPass){
        database.insert(lstAsset);
            examResultPass = true;
            }
              }
}