// FSA-1826
trigger GlobalAccountManagerUpdate on Account_Global_Manager__c (After Insert, After Update) {
    
    Map<String,id> gmaMap = new Map<String,id>();
    
    if(Trigger.isAfter && Trigger.isUpdate){
        for(Account_Global_Manager__c gma : Trigger.new){
            
            system.debug('-------------'+Trigger.newMap.get(gma.id).Global_Account_Manager__c);
            system.debug('-------------'+Trigger.oldMap.get(gma.id).Global_Account_Manager__c);
            if(Trigger.newMap.get(gma.id).Global_Account_Manager__c != Trigger.oldMap.get(gma.id).Global_Account_Manager__c){
                
                gmaMap.put(gma.Name, gma.Global_Account_Manager__c);
            }
        } 
        
        system.debug('-------------'+gmaMap);
        if(!gmaMap.isEmpty()){
            GlobalAccountManager.UpdateManagerOnAccount(gmaMap);
        }
    }
}