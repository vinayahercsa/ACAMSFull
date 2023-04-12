public class CreateOpportunityTaiwan {
	@InvocableMethod
    public static void CreateOpportunity(List<Id> ordIds){
        if(!ordIds.isEmpty()){
            ccrz__E_Order__c ord = [SELECT Id, OwnerId, ccrz__OrderNumber__c, Opportunity__c, ccrz__Account__c, ccrz__Account__r.Name, ccrz__Account__r.PersonEmail, ccrz__TaxAmount__c, BillTo_Region__c, BillTo_CountryISOCode__c, Billing_Country__c,
            						(Select ID FROM Opportunity_Taiwan_e_GUI__r) 
            						FROM ccrz__E_Order__c where Id =: ordIds[0]];
        	//list<ccrz__E_Order__c> ord = new list<ccrz__E_Order__c>();
        	System.debug('ord :: '+ord.Opportunity_Taiwan_e_GUI__r);
        	//FSA-392 AND the Process Builder Create Opportunity -Taiwan e-GUI for Orders will accept on creation and edit of Taiwan Orders.
        	if(ord.Opportunity_Taiwan_e_GUI__r == null || ord.Opportunity_Taiwan_e_GUI__r.size()==0){
	        	Opportunity_Taiwan_e_GUI__c oppTaiwan = new Opportunity_Taiwan_e_GUI__c();
	            oppTaiwan.Opportunity__c = ord.Opportunity__c;
	            oppTaiwan.CCOrder__c = ord.Id;
	            oppTaiwan.OwnerId = ord.OwnerId;
	            oppTaiwan.Invoice_Total_Tax_Amount__c = String.valueOf(ord.ccrz__TaxAmount__c);
	            oppTaiwan.Carrier_Type__c = '5G0001';
	            oppTaiwan.Carrier_ID_1__c = ord.ccrz__Account__r.PersonEmail;
	            oppTaiwan.Carrier_ID_2__c = ord.ccrz__Account__r.PersonEmail;
	            oppTaiwan.Whether_donate_the_invoice__c = 'N';
	            insert oppTaiwan;
        	}
    	}
    }
}