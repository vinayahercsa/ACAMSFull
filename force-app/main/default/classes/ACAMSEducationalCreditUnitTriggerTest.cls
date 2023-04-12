@isTest
public class ACAMSEducationalCreditUnitTriggerTest {
    public static testmethod void ACAMSEducationalCreditUnit() {
        Test.startTest();
        Contact con = new Contact();
        con.FirstName = 'First';
        con.LastName = 'Last';
        con.Email = 'First.Last@test.com';
        insert con;
        
        Map<Id,Educational_Credit_Unit_Legacy__c>  newMap = new Map<Id,Educational_Credit_Unit_Legacy__c>();
        list<Educational_Credit_Unit_Legacy__c> lstEcu = new list<Educational_Credit_Unit_Legacy__c>();
        Educational_Credit_Unit_Legacy__c eduCreditUnit = new Educational_Credit_Unit_Legacy__c();
        eduCreditUnit.Credit_End_Date__c = Date.Today().addDays(-1);
        eduCreditUnit.Status__c = 'Active';
        eduCreditUnit.Contact__c = con.id;
        eduCreditUnit.Cancel_Date__c = Null;
        eduCreditUnit.Credit_Value__c = 2;
        eduCreditUnit.Earned_Date__c = system.today()+10;
        eduCreditUnit.Rolled_Up__c= false;
        lstEcu.add(eduCreditUnit);
        database.insert(lstEcu); 
        
        eduCreditUnit.Rolled_Up__c = true;
        update eduCreditUnit;
        
        newMap.put(eduCreditUnit.id,eduCreditUnit);
        
        list<Recert_Cycle__c> lstRecert = new list<Recert_Cycle__c>();
        
        Recert_Cycle__c recerCycle = new  Recert_Cycle__c();
        recerCycle.Certification_Type__c = 'CKYCA';
        recerCycle.Contact__c = con.id;
        recerCycle.Start_Date__c = system.today();
        recerCycle.End_Date__c = system.today()+ 364;  
        recerCycle.Name = 'CKYCA'+' '+ recerCycle.End_Date__c.year();
        lstRecert.add(recerCycle);
        database.insert(lstRecert);
        
        if( recerCycle.Contact__c == eduCreditUnit.Contact__c &&  (recerCycle.Start_Date__c < eduCreditUnit.Earned_Date__c &&  eduCreditUnit.Earned_Date__c  <= recerCycle.End_Date__c)){
            
            Recert_Cycle_ECU__c recEcu = new Recert_Cycle_ECU__c();
            
            recEcu.Recert_Cycle__c = recerCycle.id;
            recEcu.Educational_Credit_Unit__c = eduCreditUnit.id;
            insert recEcu;
            
        }   
        
        ACAMSEducationalCreditUnitTriggerHandler.insertRecertCycleECU(lstEcu,lstEcu);
        ACAMSEducationalCreditUnitTriggerHandler.insertRecertCycleECUUpdate(lstEcu,lstEcu);
        ACAMSEducationalCreditUnitTriggerHandler.totalEcuOnRecertCycle(lstRecert);
        ACAMSEducationalCreditUnitTriggerHandler.totalEcuOnRecertCycleUpdate(lstRecert,lstEcu);
        
        Test.stopTest();
    }
}