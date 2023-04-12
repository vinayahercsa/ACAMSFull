/**
 *  Fsa-262 test class for ACAMSRecertCycleTriggerHandler
 *  Dec 13, 2020
 */
@IsTest
public class BatchInsertAssetOnRecertCycleTest {
  //  public static testmethod void insertAssetOnRecertCycle() {
      public List<Asset> newListAsset;
      public Map<Id, Recert_Cycle__c> oldMap;
      public List<Recert_Cycle__c> newList;
    
    public static testmethod void  BatchInsertAssetOnRecertCycle(){
   Test.startTest();
        
        Account ac = new Account();
        ac.Name ='Test User';
        insert ac;
    
       Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'User';
        con.Email = 'Test.User@gmail.com';
        con.Member_Expire_Date__c = system.today() + 150;
        con.AccountId = ac.id;
        insert con;
        
        ccrz__E_Product__c ccProd = new ccrz__E_Product__c();
        ccProd.Name = 'CKYCA Recertification Fee 2023';
        ccProd.Level_1__c = 'Certification';
        ccProd.Level_2__c = 'CKYCA';
        ccProd.ccrz__SKU__c = '  RECECKYCA23';
        insert ccProd;   
        
         ccrz__E_Product__c ccProd1 = new ccrz__E_Product__c();
        ccProd1.Name = 'CAFCA Recertification Fee 2023';
        ccProd1.Level_1__c = 'Certification';
        ccProd1.Level_2__c = 'CAFCA';
        ccProd1.ccrz__SKU__c = 'RECECAFCA23';
        insert ccProd1;
        
        ccrz__E_Product__c ccProd2 = new ccrz__E_Product__c();
        ccProd2.Name = 'CTMA Recertification Fee 2023';
        ccProd2.Level_1__c = 'Certification';
        ccProd2.Level_2__c = 'CTMA';
        ccProd2.ccrz__SKU__c = 'RECECTMA23';
        insert ccProd2;
     
        
       Date dt = system.today();
               
        Exam_Results__c exam = new Exam_Results__c();
        exam.Contact__c = con.Id;
        exam.Exam_Type__c = 'CAMS-FCI';
        exam.Test_Date__c = dt;
        insert exam;
        
        exam.Test_Date__c = dt.addDays(1);
        exam.Result__c = 'pass';
        update exam;
    
       
        list<Recert_Cycle__c> lstRecert = new list<Recert_Cycle__c>();
     Recert_Cycle__c recerCycle = new  Recert_Cycle__c();
         //string MultiSelectPickList ='Meet Membership;Meet ECU';
        recerCycle.Certification_Type__c = 'CKYCA';
        recerCycle.Contact__c = con.Id;
        recerCycle.Start_Date__c = system.today() - 364;
        recerCycle.End_Date__c = system.today() - 1;  
        recerCycle.Name = 'CKYCA'+' '+ recerCycle.End_Date__c.year();
        recerCycle.Total_ECU__c = 8;
       // recerCycle.Asset_Present__c = true;
       // recerCycle.Eligible__c = MultiSelectPickList;
        lstRecert.add(recerCycle);
         insert lstRecert;
        
        recerCycle.End_Date__c =system.today();
        
        update lstRecert;
        
          list<Recert_Cycle__c> lstRecert1 = new list<Recert_Cycle__c>();
     Recert_Cycle__c recerCycle1 = new  Recert_Cycle__c();
         //string MultiSelectPickList ='Meet Membership;Meet ECU';
        recerCycle1.Certification_Type__c = 'CAFCA';
        recerCycle1.Contact__c = con.Id;
        recerCycle1.Start_Date__c = system.today() - 364;
        recerCycle1.End_Date__c = system.today() - 1;  
        recerCycle1.Name = 'CAFCA'+' '+ recerCycle1.End_Date__c.year();
        recerCycle1.Total_ECU__c = 8;
       // recerCycle.Asset_Present__c = true;
       // recerCycle.Eligible__c = MultiSelectPickList;
        lstRecert1.add(recerCycle1);
         insert lstRecert1; 
        recerCycle1.End_Date__c =system.today();
        update lstRecert1;
        
               list<Recert_Cycle__c> lstRecert2 = new list<Recert_Cycle__c>();
     Recert_Cycle__c recerCycle2 = new  Recert_Cycle__c();
         //string MultiSelectPickList ='Meet Membership;Meet ECU';
        recerCycle2.Certification_Type__c = 'CTMA';
        recerCycle2.Contact__c = con.Id;
        recerCycle2.Start_Date__c = system.today() - 364;
        recerCycle2.End_Date__c = system.today() - 1;  
        recerCycle2.Name = 'CTMA'+' '+ recerCycle2.End_Date__c.year();
        recerCycle2.Total_ECU__c = 8;
       // recerCycle.Asset_Present__c = true;
       // recerCycle.Eligible__c = MultiSelectPickList;
        lstRecert2.add(recerCycle2);
         insert lstRecert2;
        
        recerCycle2.End_Date__c =system.today();
        
        update lstRecert2;
        
 Test.stopTest();
      
          BatchInsertAssetOnRecertCycle batchable = new BatchInsertAssetOnRecertCycle();
         schBatchInsertAssetOnRecertCycle batch = new schBatchInsertAssetOnRecertCycle();
        Database.executeBatch(batchable,100);
        String sch = '0 0 0 * * ?'; 
        system.schedule('Batch Insert Asset Status', sch, batch);

    }
}