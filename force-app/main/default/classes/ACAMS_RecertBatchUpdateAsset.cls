global class ACAMS_RecertBatchUpdateAsset implements Database.Batchable<sObject> {
  global final String Query = 'select id, name, Contact__c,Application_Approval_Date__c, status__c  from Recertification_Application__c where Asset_Pending_to_Process__c = true';

   global Database.QueryLocator start(Database.BatchableContext BC){
   system.debug('******** in start method');
      return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC,  List<sObject> scope){
       
       system.debug('******** in execute method');
        set<id> contactIds = new set <ID>();
        map<Recertification_Application__c,Id> certAppConIDMap = new map<Recertification_Application__c,ID>();
        map<id,list<Asset>> conAssetsMap = new map<id,list<Asset>>();
        List<Asset> astLstUpdt = new List<Asset>();
        List<Recertification_Application__c> certAppLstUpdt = new List<Recertification_Application__c>();
        System.debug('scope: '+scope);
        if(!scope.isEmpty())    {
            for(Sobject s : scope)  {
                Recertification_Application__c certApp = (Recertification_Application__c)s;
                contactIds.add(certApp.Contact__c);
                certAppConIDMap.put(certApp,certApp.Contact__c);
            }
        }
        System.debug('contactIds: '+contactIds);
        System.debug('certAppConIDMap: '+certAppConIDMap);
        if(!contactIds.isEmpty())    {
            for(Asset ast : [select id, Assignee__c from Asset where Assignee__c in : contactIds and Paid_Cert1__c = true and Status__c = 'Active' and Name =: 'Recertifications' and Certification_Approved_Application__c =: false ORDER BY CreatedDate desc ])    {
                for(id conId : contactIds)  {
                    if(ast.Assignee__c == conId)    {
                        if(conAssetsMap.containsKey(conId)) {
                            conAssetsMap.get(conId).add(ast);
                        }
                        else    {
                            conAssetsMap.put(conId,new List<Asset>{ast});
                        }
                    }
                }
                
            }
        }
        System.debug('conAssetsMap: '+conAssetsMap);
        if(!conAssetsMap.isEmpty() && !certAppConIDMap.isEmpty()){
            for(Recertification_Application__c certApp : certAppConIDMap.keySet())    {
                if(conAssetsMap.containsKey(certApp.Contact__c) && conAssetsMap.get(certApp.Contact__c).size()>0)   {
                    System.debug('conAssetsMap.get(certApp.Contact__c) : '+conAssetsMap.get(certApp.Contact__c));
                    System.debug('certApp : '+certApp);
                    if(certApp.status__c == 'Under Review') {
                        for(Asset ast : conAssetsMap.get(certApp.Contact__c))   {
                            ast.Application_Received__c = true;
                            astLstUpdt.add(ast);
                        }
                    }
                    if(certApp.status__c == 'Approved') {
                        for(Asset ast : conAssetsMap.get(certApp.Contact__c))   {
                            ast.Application_Received__c = true;
                            ast.Certification_Approved_Application__c = true;
                            ast.Application_Date__c = certApp.Application_Approval_Date__c.date();
                            astLstUpdt.add(ast);
                        }
                    }
                    certApp.Asset_Pending_to_Process__c = false;
                    certAppLstUpdt.add(certApp);
                }
            }
        }
        System.debug('astLstUpdt: '+astLstUpdt);
        System.debug('certAppLstUpdt: '+certAppLstUpdt);
        
        if(!astLstUpdt.isEmpty())    {
            update astLstUpdt;
        }
        if(!certAppLstUpdt.isEmpty())    {
            update certAppLstUpdt;
        }
        
        System.debug('after astLstUpdt: '+astLstUpdt);
        System.debug('after certAppLstUpdt: '+certAppLstUpdt);
        
   }

   global void finish(Database.BatchableContext BC){

   }
}