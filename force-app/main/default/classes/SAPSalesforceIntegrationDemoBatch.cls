public class SAPSalesforceIntegrationDemoBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        String query = '';
        
        if(Test.isRunningTest()){
            
            query = 'Select Invoice_Item_ID_18_Character__c, Product_SKU__c, Item_Total__c, ItemQuantity__c, Price__c, Product_Term__c, Product_Level_1__c, Product_Level_2__c, Product_Level_3__c, ccrz__CCOrder__r.Name, ccrz__CCOrder__r.Account_ID_18_Character__c, ccrz__CCOrder__r.ccrz__Contact__r.Name, ccrz__CCOrder__r.ccrz__BuyerCompanyName__c, ccrz__CCOrder__r.Billing_Country__c, ccrz__CCOrder__r.Company_Name_Standardized_text__c, ccrz__CCOrder__r.ccrz__OrderStatus__c, ccrz__CCOrder__r.Global_Account_Manager__r.Name, ccrz__CCOrder__r.RA_Referral__c, ccrz__CCOrder__r.ccrz__Account__r.Name, ccrz__Invoice__r.Name, ccrz__Invoice__r.Paid_in_Full_Date__c, ccrz__Invoice__r.Owner.Name, ccrz__Invoice__r.AddressRegion__c, ccrz__Invoice__r.AddressNamed_Territory__c, ccrz__Invoice__r.AddressSubTerritory__c, ccrz__Invoice__r.Division__c, ccrz__Invoice__r.Functional_Area__c, CreatedDate from ccrz__E_InvoiceItem__c WHERE (ccrz__Invoice__r.ccrz__Status__c != \'Closed\' OR ccrz__Invoice__r.ccrz__Status__c != \'Cancelled\') AND (NOT((ccrz__CCOrder__r.ccrz__BuyerCompanyName__c LIKE \'%ACAMS%\') OR (ccrz__CCOrder__r.ccrz__BuyerCompanyName__c LIKE \'%Adtalem%\') OR (ccrz__CCOrder__r.ccrz__BuyerCompanyName__c LIKE \'%Test%\') OR (ccrz__CCOrder__r.ccrz__BuyerCompanyName__c LIKE \'%TEST%\'))) AND (Item_Total__c != 0) AND (ccrz__Invoice__r.Has_Child_Invoices__c = false) AND (Product_Level_2__c != \'Event\') AND (ccrz__Invoice__r.Owner.Name != \'Hue Dang\') AND (ccrz__Invoice__r.Paid_in_Full_Date__c = THIS_MONTH) LIMIT 100';
            
        }else{
            
            if(system.label.SAP_Integration_PaidOffMonth == 'THIS_MONTH'){
            
            	query = 'Select Invoice_Item_ID_18_Character__c, Product_SKU__c, Item_Total__c, ItemQuantity__c, Price__c, Product_Term__c, Product_Level_1__c, Product_Level_2__c, Product_Level_3__c, ccrz__CCOrder__r.Name, ccrz__CCOrder__r.Account_ID_18_Character__c, ccrz__CCOrder__r.ccrz__Contact__r.Name, ccrz__CCOrder__r.ccrz__BuyerCompanyName__c, ccrz__CCOrder__r.Billing_Country__c, ccrz__CCOrder__r.Company_Name_Standardized_text__c, ccrz__CCOrder__r.ccrz__OrderStatus__c, ccrz__CCOrder__r.Global_Account_Manager__r.Name, ccrz__CCOrder__r.RA_Referral__c, ccrz__CCOrder__r.ccrz__Account__r.Name, ccrz__Invoice__r.Name, ccrz__Invoice__r.Paid_in_Full_Date__c, ccrz__Invoice__r.Owner.Name, ccrz__Invoice__r.AddressRegion__c, ccrz__Invoice__r.AddressNamed_Territory__c, ccrz__Invoice__r.AddressSubTerritory__c, ccrz__Invoice__r.Division__c, ccrz__Invoice__r.Functional_Area__c, CreatedDate from ccrz__E_InvoiceItem__c WHERE (ccrz__Invoice__r.ccrz__Status__c != \'Closed\' OR ccrz__Invoice__r.ccrz__Status__c != \'Cancelled\') AND (NOT((ccrz__CCOrder__r.ccrz__BuyerCompanyName__c LIKE \'%ACAMS%\') OR (ccrz__CCOrder__r.ccrz__BuyerCompanyName__c LIKE \'%Adtalem%\') OR (ccrz__CCOrder__r.ccrz__BuyerCompanyName__c LIKE \'%Test%\') OR (ccrz__CCOrder__r.ccrz__BuyerCompanyName__c LIKE \'%TEST%\'))) AND (Item_Total__c != 0) AND (ccrz__Invoice__r.Has_Child_Invoices__c = false) AND (Product_Level_2__c != \'Event\') AND (ccrz__Invoice__r.Owner.Name != \'Hue Dang\') AND (ccrz__Invoice__r.Paid_in_Full_Date__c = THIS_MONTH)';
            
        	}else{
            
            	query = 'Select Invoice_Item_ID_18_Character__c, Product_SKU__c, Item_Total__c, ItemQuantity__c, Price__c, Product_Term__c, Product_Level_1__c, Product_Level_2__c, Product_Level_3__c, ccrz__CCOrder__r.Name, ccrz__CCOrder__r.Account_ID_18_Character__c, ccrz__CCOrder__r.ccrz__Contact__r.Name, ccrz__CCOrder__r.ccrz__BuyerCompanyName__c, ccrz__CCOrder__r.Billing_Country__c, ccrz__CCOrder__r.Company_Name_Standardized_text__c, ccrz__CCOrder__r.ccrz__OrderStatus__c, ccrz__CCOrder__r.Global_Account_Manager__r.Name, ccrz__CCOrder__r.RA_Referral__c, ccrz__CCOrder__r.ccrz__Account__r.Name, ccrz__Invoice__r.Name, ccrz__Invoice__r.Paid_in_Full_Date__c, ccrz__Invoice__r.Owner.Name, ccrz__Invoice__r.AddressRegion__c, ccrz__Invoice__r.AddressNamed_Territory__c, ccrz__Invoice__r.AddressSubTerritory__c, ccrz__Invoice__r.Division__c, ccrz__Invoice__r.Functional_Area__c, CreatedDate from ccrz__E_InvoiceItem__c WHERE (ccrz__Invoice__r.ccrz__Status__c != \'Closed\' OR ccrz__Invoice__r.ccrz__Status__c != \'Cancelled\') AND (NOT((ccrz__CCOrder__r.ccrz__BuyerCompanyName__c LIKE \'%ACAMS%\') OR (ccrz__CCOrder__r.ccrz__BuyerCompanyName__c LIKE \'%Adtalem%\') OR (ccrz__CCOrder__r.ccrz__BuyerCompanyName__c LIKE \'%Test%\') OR (ccrz__CCOrder__r.ccrz__BuyerCompanyName__c LIKE \'%TEST%\'))) AND (Item_Total__c != 0) AND (ccrz__Invoice__r.Has_Child_Invoices__c = false) AND (Product_Level_2__c != \'Event\') AND (ccrz__Invoice__r.Owner.Name != \'Hue Dang\') AND (ccrz__Invoice__r.Paid_in_Full_Date__c = LAST_MONTH)';
        	}
        }
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<ccrz__E_InvoiceItem__c> records){
        
        SAPSalesforceIntegrationDemo.sendRequest(records);
        system.debug(records.size());
    }
    
    public void finish(Database.BatchableContext bc){}
}