@isTest
public class BatchSecondRecertificateCycleTest {
    @isTest
    public static void BatchSecondRecertificateCycle(){
        
        
        // static testmethod void testBatchrun(){
        Contact con = new Contact();
        con.FirstName = 'First';
        con.LastName = 'Last';
        con.Email = 'First.Last@test.com';
        insert con;
        
        //CKYCA
        Recert_Cycle__c recerCycle = new  Recert_Cycle__c();
        recerCycle.Certification_Type__c = 'CKYCA';
        recerCycle.Contact__c = con.id;
        recerCycle.Start_Date__c = system.today()-364;
        recerCycle.End_Date__c = system.today();  
        recerCycle.Name = 'CKYCA'+' '+ recerCycle.End_Date__c.year();
        insert recerCycle;
        
        if(recerCycle.End_Date__c == system.today()){
            // Recert_Cycle__c lstrecCKYCA = [select Name,Certification_Type__c,Contact__c,Start_Date__c,End_Date__c from Recert_Cycle__c where End_Date__c =: recerCycle.End_Date__c limit 1  ];
            
            Recert_Cycle__c recerCycleCkycaUpdate = new  Recert_Cycle__c();
            recerCycleCkycaUpdate.Certification_Type__c = 'CKYCA';
            recerCycleCkycaUpdate.Contact__c = con.id;
            recerCycleCkycaUpdate.Start_Date__c = system.today();
            recerCycleCkycaUpdate.End_Date__c = recerCycle.Start_Date__c.addYears(1);  
            recerCycleCkycaUpdate.Name = 'CKYCA'+' '+ recerCycle.End_Date__c.year();
            insert recerCycleCkycaUpdate;
        }
        
        //CAFCA
        Recert_Cycle__c recerCycleCAFCA = new  Recert_Cycle__c();
        recerCycleCAFCA.Certification_Type__c = 'CAFCA';
        recerCycleCAFCA.Contact__c = con.id;
        recerCycleCAFCA.Start_Date__c = system.today()-364;
        recerCycleCAFCA.End_Date__c = system.today(); 
        recerCycleCAFCA.Name = 'CAFCA'+' '+ recerCycleCAFCA.End_Date__c.year();
        insert recerCycleCAFCA;
        
        if(recerCycleCAFCA.End_Date__c == system.today()){
                        
            Recert_Cycle__c recerCycleCafcaUpdate = new  Recert_Cycle__c();
            recerCycleCafcaUpdate.Certification_Type__c = 'CAFCA';
            recerCycleCafcaUpdate.Contact__c = con.id;
            recerCycleCafcaUpdate.Start_Date__c = system.today();
            recerCycleCafcaUpdate.End_Date__c = recerCycle.Start_Date__c.addYears(1); 
            recerCycleCafcaUpdate.Name = 'CAFCA'+' '+ recerCycleCafcaUpdate.End_Date__c.year();
            insert recerCycleCafcaUpdate;
            
        }        
        //CTMA
        Recert_Cycle__c recerCycleCTMA = new  Recert_Cycle__c();
        recerCycleCTMA.Certification_Type__c = 'CTMA';
        recerCycleCTMA.Contact__c = con.id;
        recerCycleCTMA.Start_Date__c = system.today()-364;
        recerCycleCTMA.End_Date__c = system.today(); 
        recerCycleCTMA.Name = 'CTMA'+' '+ recerCycleCTMA.End_Date__c.year();
        insert recerCycleCTMA;
        
        if(recerCycleCTMA.End_Date__c == system.today()){
                        
            Recert_Cycle__c recerCycleCtmaUpdate = new  Recert_Cycle__c();
            recerCycleCtmaUpdate.Certification_Type__c = 'CTMA';
            recerCycleCtmaUpdate.Contact__c = con.id;
            recerCycleCtmaUpdate.Start_Date__c = system.today();
            recerCycleCtmaUpdate.End_Date__c = recerCycleCtmaUpdate.Start_Date__c.addYears(1);  
            recerCycleCtmaUpdate.Name = 'CTMA'+' '+ recerCycleCtmaUpdate.End_Date__c.year();
            insert recerCycleCtmaUpdate;
        }
        
        //CAMS
        Recert_Cycle__c recerCycleCAMS = new  Recert_Cycle__c();
        recerCycleCAMS.Certification_Type__c = 'CAMS';
        recerCycleCAMS.Contact__c = con.id;
        recerCycleCAMS.Start_Date__c = system.today() -1021;
        recerCycleCAMS.End_Date__c = system.today();  
        recerCycleCAMS.Name = 'CAMS'+' '+ recerCycleCAMS.End_Date__c.year();
        insert recerCycleCAMS;
        
        if (recerCycleCAMS.End_Date__c == system.today()){
            
            Recert_Cycle__c recerCycleCamsUpdate = new  Recert_Cycle__c();
            recerCycleCamsUpdate.Certification_Type__c = 'CAMS';
            recerCycleCamsUpdate.Contact__c = con.id;
            recerCycleCamsUpdate.Start_Date__c = system.today();
            recerCycleCamsUpdate.End_Date__c = Date.newInstance(recerCycleCamsUpdate.Start_Date__c.year() + 3, 12, 15);  
            recerCycleCamsUpdate.Name = 'CAMS'+' '+ recerCycleCamsUpdate.End_Date__c.year();
            insert recerCycleCamsUpdate;
        }
        
        //Advanced CAMS - Audit
        Recert_Cycle__c recerCycleAdvancedCAMSAudit = new  Recert_Cycle__c();
        recerCycleAdvancedCAMSAudit.Certification_Type__c = 'Advanced CAMS - Audit';
        recerCycleAdvancedCAMSAudit.Contact__c = con.id;
        recerCycleAdvancedCAMSAudit.Start_Date__c = system.today() -1021;
        recerCycleAdvancedCAMSAudit.End_Date__c = system.today();  
        recerCycleAdvancedCAMSAudit.Name = 'Advanced CAMS - Audit'+' '+ recerCycleCAMS.End_Date__c.year();
        insert recerCycleAdvancedCAMSAudit; 
        
        if(recerCycleAdvancedCAMSAudit.End_Date__c == system.today()){
            
            Recert_Cycle__c recerCycleAdvancedCAMSAuditUpdate = new  Recert_Cycle__c();
            recerCycleAdvancedCAMSAuditUpdate.Certification_Type__c = 'Advanced CAMS - Audit';
            recerCycleAdvancedCAMSAuditUpdate.Contact__c = con.id;
            recerCycleAdvancedCAMSAuditUpdate.Start_Date__c = system.today();
            recerCycleAdvancedCAMSAuditUpdate.End_Date__c = Date.newInstance(recerCycleAdvancedCAMSAuditUpdate.Start_Date__c.year() + 3, 12, 15);  
            recerCycleAdvancedCAMSAuditUpdate.Name = 'Advanced CAMS - Audit'+' '+ recerCycleAdvancedCAMSAuditUpdate.End_Date__c.year();
            insert recerCycleAdvancedCAMSAuditUpdate; 
        }
        //Advanced CAMS - FCI
        
        Recert_Cycle__c recerCycleAdvancedCAMSFCI = new  Recert_Cycle__c();
        recerCycleAdvancedCAMSFCI.Certification_Type__c = 'Advanced CAMS - FCI';
        recerCycleAdvancedCAMSFCI.Contact__c = con.id;
        recerCycleAdvancedCAMSFCI.Start_Date__c = system.today() - 1021;
        recerCycleAdvancedCAMSFCI.End_Date__c = system.today();  
        recerCycleAdvancedCAMSFCI.Name = 'Advanced CAMS - FCI'+' '+ recerCycleAdvancedCAMSFCI.End_Date__c.year();
        insert recerCycleAdvancedCAMSFCI;
        
        if(recerCycleAdvancedCAMSFCI.End_Date__c == system.today()){
            
            Recert_Cycle__c recerCycleAdvancedCAMSFCIUpdate = new  Recert_Cycle__c();
            recerCycleAdvancedCAMSFCIUpdate.Certification_Type__c = 'Advanced CAMS - FCI';
            recerCycleAdvancedCAMSFCIUpdate.Contact__c = con.id;
            recerCycleAdvancedCAMSFCIUpdate.Start_Date__c = system.today();
            recerCycleAdvancedCAMSFCIUpdate.End_Date__c = Date.newInstance(recerCycleAdvancedCAMSFCIUpdate.Start_Date__c.year() + 3, 12, 15);  
            recerCycleAdvancedCAMSFCIUpdate.Name = 'Advanced CAMS - FCI'+' '+ recerCycleAdvancedCAMSFCIUpdate.End_Date__c.year();
            insert recerCycleAdvancedCAMSFCIUpdate;
            
        }
        
        
        //Advanced CAMS - Risk Management
        Recert_Cycle__c recerCycleAdvancedCAMSRiskManagement = new  Recert_Cycle__c();
        recerCycleAdvancedCAMSRiskManagement.Certification_Type__c = 'Advanced CAMS - Risk Management';
        recerCycleAdvancedCAMSRiskManagement.Contact__c = con.id;
        recerCycleAdvancedCAMSRiskManagement.Start_Date__c = system.today() - 1021;
        recerCycleAdvancedCAMSRiskManagement.End_Date__c =  system.today();  
        recerCycleAdvancedCAMSRiskManagement.Name = 'Advanced CAMS - Risk Management'+' '+ recerCycleAdvancedCAMSRiskManagement.End_Date__c.year();
        insert recerCycleAdvancedCAMSRiskManagement;
        
        if(recerCycleAdvancedCAMSRiskManagement.End_Date__c == system.today()){
            
            Recert_Cycle__c recerCycleAdvancedCAMSRiskManagementUpdate = new  Recert_Cycle__c();
            recerCycleAdvancedCAMSRiskManagementUpdate.Certification_Type__c = 'Advanced CAMS - Risk Management';
            recerCycleAdvancedCAMSRiskManagementUpdate.Contact__c = con.id;
            recerCycleAdvancedCAMSRiskManagementUpdate.Start_Date__c = system.today();
            recerCycleAdvancedCAMSRiskManagementUpdate.End_Date__c = Date.newInstance(recerCycleAdvancedCAMSRiskManagementUpdate.Start_Date__c.year() + 3, 12, 15);  
            recerCycleAdvancedCAMSRiskManagementUpdate.Name = 'Advanced CAMS - Risk Management'+' '+ recerCycleAdvancedCAMSRiskManagementUpdate.End_Date__c.year();
            insert recerCycleAdvancedCAMSRiskManagementUpdate;
        }
        
        
        //CGSS
        Recert_Cycle__c recerCycleCGSS = new  Recert_Cycle__c();
        recerCycleCGSS.Certification_Type__c = 'CGSS';
        recerCycleCGSS.Contact__c = con.id;
        recerCycleCGSS.Start_Date__c = system.today() - 1021;
        recerCycleCGSS.End_Date__c = system.today();  
        recerCycleCGSS.Name = 'CGSS'+' '+ recerCycleCGSS.End_Date__c.year();
        insert recerCycleCGSS;
        
        if(recerCycleCGSS.End_Date__c == system.today()){
            
            Recert_Cycle__c recerCycleCGSSUpdate = new  Recert_Cycle__c();
            recerCycleCGSSUpdate.Certification_Type__c = 'CGSS';
            recerCycleCGSSUpdate.Contact__c = con.id;
            recerCycleCGSSUpdate.Start_Date__c = system.today();
            recerCycleCGSSUpdate.End_Date__c = Date.newInstance(recerCycleCGSSUpdate.Start_Date__c.year() + 3, 12, 15);  
            recerCycleCGSSUpdate.Name = 'CGSS'+' '+ recerCycleCGSSUpdate.End_Date__c.year();
            insert recerCycleCGSSUpdate;
            
        }
        
        
        //CCAS
        Recert_Cycle__c recerCycleCCAS = new  Recert_Cycle__c();
        recerCycleCCAS.Certification_Type__c = 'CCAS';
        recerCycleCCAS.Contact__c = con.id;
        recerCycleCCAS.Start_Date__c = system.today() -1021;
        recerCycleCCAS.End_Date__c = system.today();  
        recerCycleCCAS.Name = 'CCAS'+' '+ recerCycleCCAS.End_Date__c.year();
        insert recerCycleCCAS; 
        
        if(recerCycleCCAS.End_Date__c == system.today()){
            
            Recert_Cycle__c recerCycleCCASUpdate = new  Recert_Cycle__c();
            recerCycleCCASUpdate.Certification_Type__c = 'CCAS';
            recerCycleCCASUpdate.Contact__c = con.id;
            recerCycleCCASUpdate.Start_Date__c = system.today();
            recerCycleCCASUpdate.End_Date__c = Date.newInstance(recerCycleCCASUpdate.Start_Date__c.year() + 3, 12, 15);  
            recerCycleCCASUpdate.Name = 'CCAS'+' '+ recerCycleCCASUpdate.End_Date__c.year();
            insert recerCycleCCASUpdate; 
        }
        
        Test.startTest();
        BatchSecondRecertificateCycle batchable = new BatchSecondRecertificateCycle();
        schBatchSecondRecertificateCycle batch = new schBatchSecondRecertificateCycle();
        Database.executeBatch(batchable,100);
        String sch = '0 0 0 * * ?'; 
        system.schedule('Batch EduCredit Status', sch, batch);
        Test.stopTest();
    }
}