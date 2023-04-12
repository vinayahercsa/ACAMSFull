//global class BatchSecondRecertificateCycle implements Schedulable,Database.batchable<sObject>{ 
global class BatchSecondRecertificateCycle implements Database.batchable<sObject>{ 
  public class customException extends Exception {}
    
   /* global void execute(SchedulableContext SC) {
        BatchSecondRecertificateCycle b = new BatchSecondRecertificateCycle(); //ur batch class
        database.executebatch(b);
    } */
        
   global Database.querylocator start(Database.BatchableContext info){ 
       Date todayDate = System.Today();
        return Database.getQueryLocator([select Name,Certification_Type__c,Contact__c,Start_Date__c,End_Date__c from Recert_Cycle__c where End_Date__c =: todayDate ORDER BY CreatedDate DESC]);
   }     
   global void execute(Database.BatchableContext info, List<Recert_Cycle__c> lstRecerCycle){
       list<Recert_Cycle__c> lstRecertificate= new list<Recert_Cycle__c>();
      
       for(Recert_Cycle__c rc : lstRecerCycle){
           If(rc.Certification_Type__c == 'CKYCA'){
                 Recert_Cycle__c recerCycle = new  Recert_Cycle__c();
                    // System.Debug('CKYCA Name-->'+ recerCycle.Name );
                    recerCycle.Certification_Type__c = 'CKYCA';
                    System.Debug('CKYCA Type-->'+ recerCycle.Certification_Type__c );
                    recerCycle.Contact__c = rc.Contact__c;
                    System.Debug('CKYCA Contact-->'+ recerCycle.Contact__c );
                    recerCycle.Start_Date__c = system.today();
                    System.Debug('CKYCA Start Date-->'+ recerCycle.Start_Date__c);
                    recerCycle.End_Date__c = recerCycle.Start_Date__c.addYears(1); //need to Add 1 Year 
                    System.Debug('CKYCA End Date-->'+ recerCycle.End_Date__c);
                    recerCycle.Name = 'CKYCA'+' '+ recerCycle.End_Date__c.year();
                    System.Debug('CKYCA Name-->'+ recerCycle.Name );
                    lstRecertificate.add(recerCycle);
                    System.debug('lstRecertificate list for CKYCA--->'+lstRecertificate);   
               
                }
           
                If(rc.Certification_Type__c == 'CAFCA'){
                     Recert_Cycle__c recerCycle = new  Recert_Cycle__c();
                    // System.Debug('CAFCA Name-->'+ rc.Name );
                    recerCycle.Certification_Type__c = 'CAFCA';
                    System.Debug('CAFCA Type-->'+ recerCycle.Certification_Type__c );
                    recerCycle.Contact__c = rc.Contact__c;
                    System.Debug('CAFCA Contact-->'+ recerCycle.Contact__c );
                    recerCycle.Start_Date__c = system.today();
                    System.Debug('CAFCA Start Date-->'+ recerCycle.Start_Date__c);
                    recerCycle.End_Date__c = recerCycle.Start_Date__c.addYears(1); //need to Add 1 Year 
                    System.Debug('CAFCA End Date-->'+ recerCycle.End_Date__c);
                    recerCycle.Name = 'CAFCA'+' '+ recerCycle.End_Date__c.year();
                    System.Debug('CAFCA Name-->'+ recerCycle.Name );
                    lstRecertificate.add(recerCycle);
                    System.debug('lstRecertificate list for CKYCA--->'+lstRecertificate);        
                }
                
                If(rc.Certification_Type__c == 'CTMA'){
                    Recert_Cycle__c recerCycle = new  Recert_Cycle__c();
                    recerCycle.Certification_Type__c = 'CTMA';
                    recerCycle.Contact__c = rc.Contact__c;
                    recerCycle.Start_Date__c = system.today();
                    recerCycle.End_Date__c = recerCycle.Start_Date__c.addYears(1); //need to Add 1 Year 
                    recerCycle.Name = 'CTMA'+' '+ recerCycle.End_Date__c.year();
                    lstRecertificate.add(recerCycle);        
                }
                
                //If(rc.Certification_Type__c == 'CAMS' || rc.Certification_Type__c == 'CAMSFebraban'){ 
                If(rc.Certification_Type__c == 'CAMS'){ 
                    Recert_Cycle__c recerCycle = new  Recert_Cycle__c();
                    recerCycle.Certification_Type__c = 'CAMS';
                    recerCycle.Contact__c = rc.Contact__c;
                    recerCycle.Start_Date__c = system.today();
                    recerCycle.End_Date__c = Date.newInstance(recerCycle.Start_Date__c.year() + 3, 12, 15); 
                    recerCycle.Name = 'CAMS'+' '+ recerCycle.End_Date__c.year();
                    lstRecertificate.add(recerCycle);        
                }
                            
                If(rc.Certification_Type__c == 'Advanced CAMS - Audit'){
                    Recert_Cycle__c recerCycle = new  Recert_Cycle__c();
                    recerCycle.Certification_Type__c = 'Advanced CAMS - Audit';
                    recerCycle.Contact__c = rc.Contact__c;
                    recerCycle.Start_Date__c = system.today();
                    recerCycle.End_Date__c = Date.newInstance(recerCycle.Start_Date__c.year() + 3, 12, 15); 
                    recerCycle.Name = 'Advanced CAMS - Audit'+' '+ recerCycle.End_Date__c.year();
                    lstRecertificate.add(recerCycle);        
                }
                
                If(rc.Certification_Type__c == 'Advanced CAMS - FCI'){  
                    Recert_Cycle__c recerCycle = new  Recert_Cycle__c();
                    recerCycle.Certification_Type__c = 'Advanced CAMS - FCI';
                    recerCycle.Contact__c = rc.Contact__c;
                    recerCycle.Start_Date__c = system.today();
                    recerCycle.End_Date__c = Date.newInstance(recerCycle.Start_Date__c.year() + 3, 12, 15); 
                    recerCycle.Name = 'Advanced CAMS - FCI'+' '+ recerCycle.End_Date__c.year();
                    lstRecertificate.add(recerCycle);        
                }
                
                If(rc.Certification_Type__c == 'Advanced CAMS - Risk Management'){  
                    Recert_Cycle__c recerCycle = new  Recert_Cycle__c();
                    recerCycle.Certification_Type__c = 'Advanced CAMS - Risk Management';
                    recerCycle.Contact__c = rc.Contact__c;
                    recerCycle.Start_Date__c = system.today();
                    recerCycle.End_Date__c = Date.newInstance(recerCycle.Start_Date__c.year() + 3, 12, 15); 
                    recerCycle.Name = 'Advanced CAMS - Risk Management'+' '+ recerCycle.End_Date__c.year();
                    lstRecertificate.add(recerCycle);        
                }
                
                If(rc.Certification_Type__c == 'CGSS'){ 
                    Recert_Cycle__c recerCycle = new  Recert_Cycle__c();
                    recerCycle.Certification_Type__c = 'CGSS';
                    recerCycle.Contact__c = rc.Contact__c;
                    recerCycle.Start_Date__c = system.today();
                    recerCycle.End_Date__c = Date.newInstance(recerCycle.Start_Date__c.year() + 3, 12, 15); 
                    recerCycle.Name = 'CGSS'+' '+ recerCycle.End_Date__c.year();
                    lstRecertificate.add(recerCycle);        
                }
                
                If(rc.Certification_Type__c == 'CCAS'){  
                    Recert_Cycle__c recerCycle = new  Recert_Cycle__c();
                    recerCycle.Certification_Type__c = 'CCAS';
                    recerCycle.Contact__c = rc.Contact__c;
                    recerCycle.Start_Date__c = system.today();
                    recerCycle.End_Date__c = Date.newInstance(recerCycle.Start_Date__c.year() + 3, 12, 15); 
                    recerCycle.Name = 'CCAS'+' '+ recerCycle.End_Date__c.year();
                    lstRecertificate.add(recerCycle);        
                }       
       }
       
      database.insert(lstRecertificate);
         
     System.debug('*****BatchSecondRecertificateCycle.execute.lstRecerCycle: ' + lstRecertificate);
        if (lstRecertificate != NULL && lstRecertificate.size() > 0){
            Database.SaveResult [] urList = Database.insert(lstRecertificate, false);
            for (Database.SaveResult ur : urList) {
                if (ur.isSuccess()) {
                    System.debug('*****BatchSecondRecertificateCycle.execute - Successfully Inserted Record: ' + ur.getId());
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