public class MasterAssetsController{
   public List<Asset> Assets{get;set;} 
    Public String url{get;set;}
    public id a =ApexPages.currentPage().getParameters().get('id');
    
    
     public MasterAssetsController(ApexPages.StandardController controller) {
       url = System.URL.getSalesforceBaseUrl().toExternalForm();
    runQuery();
  }
    
     public void runQuery() {

           try {
 
         Assets = [SELECT Id, Name, Product_level_1__c, Product_level_2__c, (Select CurrentExpirationDate__c,Product_level_1__c,Product_level_2__c from ChildAssets where CancelDate__c =: null order by CurrentExpirationDate__c ASC limit 1) from Asset WHERE Assignee__r.Accountid =: a and Parentid =: null];
         
    
    } 
         catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ooops!'));
    }

 

 

 

  }

 

 

 

  
 
}