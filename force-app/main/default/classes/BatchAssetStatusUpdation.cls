global class BatchAssetStatusUpdation implements Database.batchable<sObject>{ 
  public class customException extends Exception {}
     
	
        
   global Database.querylocator start(Database.BatchableContext info){ 
       Date todayDate = System.Today();
        return Database.getQueryLocator([Select Id,name,CurrentExpirationDate__c,Status__c from Asset where Status__c =: 'Active' AND CurrentExpirationDate__c < : todayDate ORDER BY CreatedDate DESC]);
   }     
   global void execute(Database.BatchableContext info, List<Asset> lstAsset){
       for(Asset objAsset : lstAsset){
         objAsset.Status__c = 'Inactive';
       }
         
      System.debug('*****BatchAssetStatusUpdation.execute.lstAsset: ' + lstAsset);
        if (lstAsset != NULL && lstAsset.size() > 0){
            Database.SaveResult [] urList = Database.update(lstAsset, false);
            for (Database.SaveResult ur : urList) {
                if (ur.isSuccess()) {
                    System.debug('*****BatchAssetStatusUpdation.execute - Successfully Update objects: ' + ur.getId());
                }
                else {
                    for(Database.Error err : ur.getErrors()) {
                        System.debug('*****BatchAssetStatusUpdation.execute - The following error has occurred: ' + err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('*****BatchAssetStatusUpdation.execute. - SObject fields that affected this error: ' + err.getFields());
                        customException ex = new customException('DML Error: ' + err.getStatusCode() + ': ' + err.getMessage());
                        //Utils.LogException(ex);
                    }
                }
            }
        }   
   }     
   global void finish(Database.BatchableContext info){     
   } 
}