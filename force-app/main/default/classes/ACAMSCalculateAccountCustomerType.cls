global class ACAMSCalculateAccountCustomerType implements Database.Batchable<SObject>,Schedulable {
    
    global void execute(SchedulableContext context) {
        Database.executeBatch(new ACAMSCalculateAccountCustomerType(),200);
    }
   /* Set<Id> AccIds = new Set<Id>{'0014C00000cY7rPQAS','0014C00000cY7rUQAS','0014C00000cY7rUQAS','0014C00000cY85dQAC','0014C00000cY862QAC','0014C00000cY863QAC','0013k00002rPNf8AAG',
        '0014C00000cYH95QAG'};*/
    global Database.QueryLocator start(Database.BatchableContext bc){
       return Database.getQueryLocator([SELECT id,Customer_Type__c,isPersonAccount,personcontactid from account]);
    }
    global void execute(Database.BatchableContext bc, List<Account> lstAccount){
        List<Account> updateCustomerTypeList = new List<Account>();
        List<Account> activeProspectWithNoActivity = new List<Account>();
        set<Id> lstOfAccountIds = new set<Id>();
        set<Id> personContactId = new set<Id>();
        Date last12Months = system.today() - 365;
        Map<Id,ccrz__E_Order__c> accountIdWithOrderMap = new Map<Id,ccrz__E_Order__c>();
        Map<Id,Asset> accountIdWithAssetMap = new Map<Id,Asset>();
        Map<Id,Opportunity> accountIdWithOptyMap = new Map<Id,Opportunity>();
        for(Account account : lstAccount){
            
            if(account.personcontactid != Null){
                personContactId.add(account.personcontactid);
            } 
                lstOfAccountIds.add(account.Id);
                                   
        }
        Map<Id,AggregateResult> results = new Map<id,AggregateResult>(
            [SELECT ccrz__Account__c Id, COUNT(Paid_in_Full_Date__c) paidCount FROM ccrz__E_Order__c 
             WHERE ccrz__Account__c != NULL AND Paid_in_Full_Date__c != Null AND ccrz__OrderStatus__c != 'Cancelled'
             AND ccrz__Account__c IN : lstOfAccountIds AND Paid_in_Full_Date__c >: last12Months 
             GROUP BY ccrz__Account__c]);
        
        Map<Id,AggregateResult> orderRresults = new Map<id,AggregateResult>(
            [SELECT ccrz__Account__c Id, COUNT(ccrz__OrderDate__c) paidCount FROM ccrz__E_Order__c 
             WHERE ccrz__Account__c != NULL AND Paid_in_Full_Date__c = Null AND ccrz__OrderStatus__c != 'Cancelled' 
             AND ccrz__Account__c IN : lstOfAccountIds AND ccrz__OrderDate__c >: last12Months
             GROUP BY ccrz__Account__c]);
        
        Map<Id,AggregateResult> personAccountAsset;
        Map<Id,AggregateResult> businessAccountAsset;
        if(personContactId.size() > 0){
              personAccountAsset = new Map<id,AggregateResult>(
            [SELECT Assignee__c Id, COUNT(Status__c) status FROM Asset WHERE Assignee__c != NULL AND Status__c != Null
             AND Assignee__c IN : personcontactid   AND Status__c ='Active' GROUP BY Assignee__c]);
        }
        if(lstOfAccountIds.size() > 0){
              businessAccountAsset = new Map<id,AggregateResult>(
            [SELECT AccountId Id, COUNT(Status__c) status FROM Asset WHERE Assignee__c != NULL AND Status__c != Null
             AND AccountId IN : lstOfAccountIds   AND Status__c ='Active' GROUP BY AccountId]);
        }
   
        
        Map<Id,AggregateResult> opptyResult = new Map<id,AggregateResult>(
            [SELECT AccountId Id, COUNT(StageName) stage FROM Opportunity WHERE AccountId != NULL 
             AND StageName != Null AND AccountId IN : lstOfAccountIds AND stageName != 'Cancelled' 
             AND stageName != 'Closed Lost' AND CreatedDate = LAST_N_DAYS:365 GROUP BY AccountId]);
        
        List<Account> InactiveProspectLst = [SELECT Id,Customer_Type__c,isPersonAccount,createddate,personcontactid,(SELECT accountid FROM Opportunities limit 1),(SELECT ccrz__Account__c FROM ccrz__E_Orders__r limit 1) FROM account WHERE  Id IN :lstOfAccountIds and createddate = LAST_N_DAYS:365];
        Map<Id,List<Asset>> paRelatedAsset = new Map<Id,List<Asset>>();
        Map<Id,List<Asset>> baRelatedAsset = new Map<Id,List<Asset>>();
        if(lstOfAccountIds.size() > 0){
            for(Asset ast : [SELECT AccountId FROM Asset Where AccountId IN :lstOfAccountIds  AND createddate = LAST_N_DAYS:365]) {
        if(baRelatedAsset.containsKey(ast.AccountId)) {
          List<Asset> astLst = baRelatedAsset.get(ast.AccountId);
          astLst.add(ast);
          baRelatedAsset.put(ast.AccountId, astLst);
                    
        } else {
          baRelatedAsset.put(ast.AccountId, new List<Asset> { ast });
        }
                system.debug('enetr::'+baRelatedAsset.get(ast.AccountId));
      }
        }
        if(personContactId.size() > 0){
            for(Asset ast : [SELECT Assignee__c FROM Asset Where Assignee__c IN :personcontactid  AND createddate = LAST_N_DAYS:365]) {
        if(paRelatedAsset.containsKey(ast.Assignee__c)) {
          List<Asset> astLst = paRelatedAsset.get(ast.Assignee__c);
          astLst.add(ast);
          paRelatedAsset.put(ast.Assignee__c, astLst);
                    
        } else {
          paRelatedAsset.put(ast.Assignee__c, new List<Asset> { ast });
        }
                system.debug('enetr::'+paRelatedAsset.get(ast.Assignee__c));
      }
        }
     
        for(Account account : lstAccount){
            Integer orderCount;
            Integer orderPaidNullCount;
            Integer paStatusCount;
            Integer baStatusCount;
            Integer stageCount;
            Integer invoiceCount;
            if( results.containsKey(account.Id) ){
                AggregateResult agOrder = results.get(account.Id);
                orderCount = (Integer)agOrder.get('paidCount');
            }
            if( orderRresults.containsKey(account.Id) ){
                AggregateResult agOrder = orderRresults.get(account.Id);
                orderPaidNullCount = (Integer)agOrder.get('paidCount');
            }
            if(account.personcontactid != Null){
                if( personAccountAsset.containsKey(account.personcontactid) ){
                AggregateResult agOrder = personAccountAsset.get(account.personcontactid);
                paStatusCount = (Integer)agOrder.get('status');
            }
            }else{
                if( businessAccountAsset.containsKey(account.Id) ){
                AggregateResult agOrder = businessAccountAsset.get(account.Id);
                baStatusCount = (Integer)agOrder.get('status');
                }
            }
            
            if( opptyResult.containsKey(account.Id) ){
                AggregateResult agOrder = opptyResult.get(account.Id);
                stageCount = (Integer)agOrder.get('stage');
            }
            system.debug('orderCount::'+orderCount+'statusCount'+paStatusCount+'baStatusCount'+baStatusCount);
            system.debug('orderPaidNullCount::'+orderPaidNullCount+'stageCount'+stageCount);
            if(orderCount > 0 || paStatusCount > 0 || baStatusCount > 0){
                account.Customer_Type__c = 'Active Customer';
                   updateCustomerTypeList.add(account);
            }else if(orderCount == Null && paStatusCount == Null && baStatusCount == Null && account.Customer_Type__c == 'Active Customer'){
                account.Customer_Type__c = 'Inactive Customer';
                   updateCustomerTypeList.add(account);
            }else if((stageCount > 0 || orderPaidNullCount > 0) && account.Customer_Type__c != 'Active Customer' && account.Customer_Type__c != 'Inactive Customer'){
                account.Customer_Type__c = 'Active Prospect';
                   updateCustomerTypeList.add(account);
            }else if(stageCount == Null  && account.Customer_Type__c == 'Active Prospect' ){
                
                account.Customer_Type__c = 'Inactive Prospect';
                   updateCustomerTypeList.add(account);
            }
            
        }
        
        
        if(InactiveProspectLst.size() > 0 && InactiveProspectLst.size() != Null ){
                
                system.debug('InactiveProspectLst::'+InactiveProspectLst.size());
                for(Account accounts : InactiveProspectLst){
                    system.debug('InactiveProspectLst::'+accounts.Opportunities.size()); 
                    system.debug('InactiveProspectLst::'+accounts.ccrz__E_Orders__r.size()); 
                    system.debug('InactiveProspectLst::'+accounts.assets.size()); 
                    if(accounts.IsPersonAccount){
                         if(accounts.Opportunities.size() == 0 && accounts.ccrz__E_Orders__r.size() == 0 
                       && !paRelatedAsset.containsKey(accounts.PersonContactId) ){
                       
                            accounts.Customer_Type__c = 'Active Prospect';
                         activeProspectWithNoActivity.add(accounts);
                      
                    }
                    }else{
                        if(accounts.Opportunities.size() == 0 && accounts.ccrz__E_Orders__r.size() == 0 
                       && !baRelatedAsset.containsKey(accounts.Id)){
                       
                            accounts.Customer_Type__c = 'Active Prospect';
                         activeProspectWithNoActivity.add(accounts);
                      
                    }
                    }
                    
                     
                    
                }
                
                  
            }
        Map<Id,Account> removeDuplicateAccounts = new Map<Id,Account>();
        removeDuplicateAccounts.putAll(updateCustomerTypeList);
        removeDuplicateAccounts.putAll(activeProspectWithNoActivity);
        if(removeDuplicateAccounts.size() > 0){
            system.debug('enter::'+removeDuplicateAccounts.values());
            update removeDuplicateAccounts.values();
        }
      
        
    }
    global void finish(Database.BatchableContext bc){
        
    }
 
}