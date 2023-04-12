public class ACAMSEducationalCreditUnitTriggerHandler extends CCAviTriggerHandler {
    
    private List<Educational_Credit_Unit_Legacy__c> newList;
    private List<Educational_Credit_Unit_Legacy__c> oldList;
    private Map<Id, Educational_Credit_Unit_Legacy__c> newMap;
    private Map<Id, Educational_Credit_Unit_Legacy__c> oldMap;
    
    public ACAMSEducationalCreditUnitTriggerHandler() {
        super();
        this.newList = (List<Educational_Credit_Unit_Legacy__c>) Trigger.new;
        this.oldList = (List<Educational_Credit_Unit_Legacy__c>) Trigger.old;
        this.newMap = (Map<Id, Educational_Credit_Unit_Legacy__c>) Trigger.newMap;
        this.oldMap = (Map<Id, Educational_Credit_Unit_Legacy__c>) Trigger.oldMap;
        
    }
    
    public override void afterInsert(){
        insertRecertCycleECU(this.newList,this.oldList);
    }  
    
    public override void beforeInsert(){
        ecuUpdate(this.newList);
    }  
    
    public override void beforeUpdate(){
        insertRecertCycleECUUpdate(this.newList,this.oldList);  
    }
    
    
    public static void ecuUpdate(list<Educational_Credit_Unit_Legacy__c> newList){
        system.debug('Inside ecuUpdate--->');
        set<Id> conId =new set<Id>();
        list<Educational_Credit_Unit_Legacy__c> lstEcuUpdate = new list<Educational_Credit_Unit_Legacy__c>();
        for(Educational_Credit_Unit_Legacy__c ecu: newList){
            If (ecu.Status__c == 'Active'  &&  ecu.Cancel_Date__c == Null &&  ecu.Credit_Value__c > 0  ){
                conId.add(ecu.Contact__c);
                ecu.Rolled_Up__c = true;
            }       
        }
        
    }
    
    public static void insertRecertCycleECU(list<Educational_Credit_Unit_Legacy__c> newList,list<Educational_Credit_Unit_Legacy__c> oldList) {
        system.debug('Inside insertRecertCycleECU--->');
        set<Id> conId =new set<Id>();
        list<Educational_Credit_Unit_Legacy__c> lstEcu = new list<Educational_Credit_Unit_Legacy__c>();
        //list<Recert_Cycle__c> lstRecert =new list<Recert_Cycle__c>();
        list<Recert_Cycle_ECU__c> lstRecrCycleEcu = new list<Recert_Cycle_ECU__c>();
        
        for(Educational_Credit_Unit_Legacy__c e: newList){
            If (e.Status__c == 'Active'  &&  e.Cancel_Date__c == Null &&  e.Credit_Value__c > 0 ){  // Fsa-6051 Rolled_Up__c field added
                conId.add(e.Contact__c);
                // e.Rolled_Up__c =true;
                lstEcu.add(e);
            }  
        }
        List<Recert_Cycle__c> lstRecrCycle =[Select Id,Contact__c,Start_Date__c,End_Date__c,Total_ECU__c,Name from Recert_Cycle__c where Contact__c In: conId];
        for(Educational_Credit_Unit_Legacy__c ecu: lstEcu){
            system.debug('ecu.Rolled_Up__c on After Insert--->'+ecu.Rolled_Up__c );
            for(Recert_Cycle__c rc: lstRecrCycle){
                
                if( rc.Contact__c == ecu.Contact__c &&  (rc.Start_Date__c < ecu.Earned_Date__c &&  ecu.Earned_Date__c  <= rc.End_Date__c)){
                    Recert_Cycle_ECU__c recEcu = new Recert_Cycle_ECU__c();
                    
                    // recEcu.Name = 'R-00000' + 1;
                    recEcu.Recert_Cycle__c = rc.id; //CKYCA 2023 
                    recEcu.Educational_Credit_Unit__c = ecu.id;
                    // recEcu.Credit_Value__c = ecu.Credit_Value__c;
                    // recEcu.Earned_Date__c = ecu.Earned_Date__c;
                    // recEcu.ECU__c = ecu.Credit_Value__c;
                    lstRecrCycleEcu.add(recEcu);
                    
                }       
            }
        }
        
        database.insert(lstRecrCycleEcu);   
        totalEcuOnRecertCycle(lstRecrCycle);
        system.debug('lstRecert1 --->'+lstRecrCycle);
    }
    
    public static void totalEcuOnRecertCycle(list<Recert_Cycle__c> lstRecert){
        system.debug('Inside totalEcuOnRecertCycle---> ');
        list<Recert_Cycle__c> lstRecertToUpdate = new  list<Recert_Cycle__c>();
        If(lstRecert !=null && !lstRecert.isempty()){
            system.debug('Inside if Condition--->');
            List<Recert_Cycle__c> lstRecrCycle =[Select Id,Contact__c,Total_ECU__c,(Select id,Credit_Value__c from Recert_Cycle_ECU__r) from Recert_Cycle__c where Id In:lstRecert];
            // List<Recert_Cycle__c> lstRecrCycle =[Select Id,Contact__c,Total_ECU__c,(Select id,ECU__c from Recert_Cycle_ECU__r) from Recert_Cycle__c];
            System.debug('lstRecrCycle--->'+lstRecrCycle);
            for(Recert_Cycle__c r :lstRecrCycle){
                Decimal ecuCount = 0;
                for (Recert_Cycle_ECU__c e: r.Recert_Cycle_ECU__r){
                    ecuCount += e.Credit_Value__c;
                }
                r.Total_ECU__c = ecuCount;
                System.debug('Total ECU Count --->'+ r.Total_ECU__c);
                lstRecertToUpdate.add(r);
                System.debug('Total ECU Count --->'+ r);
            }
            database.update(lstRecertToUpdate);
            system.debug('lstRecertToUpdate--->'+lstRecertToUpdate);
        }
    }    
    
    public static void insertRecertCycleECUUpdate(list<Educational_Credit_Unit_Legacy__c> newList,list<Educational_Credit_Unit_Legacy__c> oldList) {
        system.debug('inside insertRecertCycleECUUpdate--->12');      
        set<Id> conId =new set<Id>();
        map<id,Educational_Credit_Unit_Legacy__c> mapEcu =new map<id,Educational_Credit_Unit_Legacy__c>();
        list<Educational_Credit_Unit_Legacy__c> lstEcu = new list<Educational_Credit_Unit_Legacy__c>();
        //list<Recert_Cycle__c> lstRecert =new list<Recert_Cycle__c>();
        list<Recert_Cycle_ECU__c> lstRecrCycleEcu = new list<Recert_Cycle_ECU__c>();
        
        for(Educational_Credit_Unit_Legacy__c e: newList){
            If (e.Status__c == 'Active'  &&  e.Cancel_Date__c == Null &&  e.Credit_Value__c > 0 ){  // Fsa-6051 Rolled_Up__c field added
                conId.add(e.Contact__c);
                lstEcu.add(e);
            }  
        }
        List<Recert_Cycle__c> lstRecrCycle =[Select Id,Contact__c,Start_Date__c,End_Date__c,Total_ECU__c,Name from Recert_Cycle__c where Contact__c In: conId];
        for(Educational_Credit_Unit_Legacy__c ecu: lstEcu){
            if(ecu.Rolled_Up__c == false  ){ //fsa-6051 
                for(Recert_Cycle__c rc: lstRecrCycle){
                    if( rc.Contact__c == ecu.Contact__c &&  (rc.Start_Date__c < ecu.Earned_Date__c &&  ecu.Earned_Date__c  <= rc.End_Date__c)){ 
                        Recert_Cycle_ECU__c recEcu = new Recert_Cycle_ECU__c();
                        recEcu.Recert_Cycle__c = rc.id; //CKYCA 2023 
                        recEcu.Educational_Credit_Unit__c = ecu.id;
                        lstRecrCycleEcu.add(recEcu);
                    }                    
                }
                totalEcuOnRecertCycleUpdate(lstRecrCycle,newList);
            }//fsa-6051      
            ecu.Rolled_Up__c = true;//fsa-6051    
        }
    } 
    //FSA-6051 Changes Start
    public static void totalEcuOnRecertCycleUpdate(list<Recert_Cycle__c> lstRecert,list<Educational_Credit_Unit_Legacy__c> newList){
        system.debug('Inside totalEcuOnRecertCycle--->1 ');
        Map<Id,Educational_Credit_Unit_Legacy__c>  newMap = new Map<Id,Educational_Credit_Unit_Legacy__c>();
        set<Id> ConId = new set<Id>();
        set<Id> ecuRec = new set<Id>();
        // list<Recert_Cycle_ECU__c> lstRecrCycleEcuUpdate = new list<Recert_Cycle_ECU__c>();
        list<Recert_Cycle__c> lstRecertToUpdate = new  list<Recert_Cycle__c>();
        
        for(Educational_Credit_Unit_Legacy__c ecu:newList){
            If (ecu.Status__c == 'Active'  &&  ecu.Cancel_Date__c == Null &&  ecu.Credit_Value__c > 0 && ecu.Rolled_Up__c == false ){
                conId.add(ecu.Contact__c);
                ecuRec.add(ecu.id);
                newMap.put(ecu.id,ecu);
                List<Recert_Cycle__c> lstRecrCycle =[Select Id,Contact__c,Start_Date__c,End_Date__c,Total_ECU__c,Name,(Select id,Credit_Value__c from Recert_Cycle_ECU__r) from Recert_Cycle__c where Contact__c In: ConId];
                for(Recert_Cycle__c rec:lstRecrCycle){
                    Decimal ecuCount = 0;
                    for (Recert_Cycle_ECU__c e: rec.Recert_Cycle_ECU__r){ 
                        // ecuCount += e.Credit_Value__c; 
                        ecuCount +=   newMap.get(ecu.id).Credit_Value__c;
                        system.debug('mapvalue--->123'+newMap.get(ecu.id).Credit_Value__c);
                    }
                    rec.Total_ECU__c = ecuCount;
                    lstRecertToUpdate.add(rec);
                }
                database.update(lstRecertToUpdate);
                
            }
        }
    }
    //FSA-6051 Changes end         
}