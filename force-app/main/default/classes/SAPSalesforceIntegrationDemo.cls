public class SAPSalesforceIntegrationDemo {

    public static void sendRequest(List<ccrz__E_InvoiceItem__c> invoiceItemList){
        
        if(system.label.SAP_Integration_Run == 'yes'){

			String username = system.label.SAP_Integration_Username;
			String password = system.label.SAP_Integration_Password;
        	String endpoint1 = system.label.SAP_Integration_Endpoint1;
			String endpoint2 = system.label.SAP_Integration_Endpoint2;
        
        	Blob headerValue = Blob.valueOf(username + ':' + password);
			String authorizationHeader = 'Basic ' +EncodingUtil.base64Encode(headerValue);
        
        	//List<ccrz__E_InvoiceItem__c> invoiceItemList = fetchRecords();
        	String requestBody1 = getCSORequestBody(invoiceItemList);
        	String requestBody2 = getCSTRequestBody(invoiceItemList);
        
            try{
                
                HttpRequest req1 = new HttpRequest();
				req1.setEndpoint(endpoint1);
				req1.setMethod('POST');
				req1.setHeader('Content-Type','application/json');
        		req1.setHeader('Accept','application/json');
				req1.setHeader('Authorization', authorizationHeader);
        		req1.setBody(requestBody1);
 
				Http http1 = new Http();
				HTTPResponse res1 = http1.send(req1);
				System.debug(res1.getBody());
        
        
        		HttpRequest req2 = new HttpRequest();
				req2.setEndpoint(endpoint2);
				req2.setMethod('POST');
				req2.setHeader('Content-Type','application/json');
        		req2.setHeader('Accept','application/json');
				req2.setHeader('Authorization', authorizationHeader);
        		req2.setBody(requestBody2);
 
				Http http2 = new Http();
				HTTPResponse res2 = http2.send(req2);
				System.debug(res2.getBody());
                
            }catch(Exception e){
                
                system.debug(e);
            }
    	}
    }
    
    /*@TestVisible
    public static List<ccrz__E_InvoiceItem__c> fetchRecords(){
        
        List<ccrz__E_InvoiceItem__c> invoiceItemList;
        String paidOffMonth = system.label.SAP_Integration_PaidOffMonth;
        
        if(paidOffMonth == 'THIS_MONTH'){
            
            invoiceItemList = [Select Invoice_Item_ID_18_Character__c, Product_SKU__c, Item_Total__c, ItemQuantity__c, Price__c, 
			Product_Term__c, Product_Level_1__c, Product_Level_2__c, Product_Level_3__c, ccrz__CCOrder__r.Name,
			ccrz__CCOrder__r.Account_ID_18_Character__c, ccrz__CCOrder__r.ccrz__Contact__r.Name, 
			ccrz__CCOrder__r.ccrz__BuyerCompanyName__c, ccrz__CCOrder__r.Billing_Country__c, 
			ccrz__CCOrder__r.Company_Name_Standardized_text__c, ccrz__CCOrder__r.ccrz__OrderStatus__c, 
			ccrz__CCOrder__r.Global_Account_Manager__r.Name, ccrz__CCOrder__r.RA_Referral__c, 
			ccrz__CCOrder__r.ccrz__Account__r.Name, ccrz__Invoice__r.Name, ccrz__Invoice__r.Paid_in_Full_Date__c,
			ccrz__Invoice__r.Owner.Name, ccrz__Invoice__r.AddressRegion__c, ccrz__Invoice__r.AddressNamed_Territory__c, 
			ccrz__Invoice__r.AddressSubTerritory__c, ccrz__Invoice__r.Division__c, ccrz__Invoice__r.Functional_Area__c, 
			CreatedDate from ccrz__E_InvoiceItem__c
        
        	WHERE (ccrz__Invoice__r.ccrz__Status__c != 'Closed' OR ccrz__Invoice__r.ccrz__Status__c != 'Cancelled') AND 
			(NOT((ccrz__CCOrder__r.ccrz__BuyerCompanyName__c LIKE '%ACAMS%') OR 
			(ccrz__CCOrder__r.ccrz__BuyerCompanyName__c LIKE '%Adtalem%') OR 
			(ccrz__CCOrder__r.ccrz__BuyerCompanyName__c LIKE '%Test%') OR 
			(ccrz__CCOrder__r.ccrz__BuyerCompanyName__c LIKE '%TEST%'))) AND (Item_Total__c != 0) AND 
			(ccrz__Invoice__r.Has_Child_Invoices__c = false) AND (Product_Level_2__c != 'Event') AND 
			(ccrz__Invoice__r.Owner.Name != 'Hue Dang') AND (ccrz__Invoice__r.Paid_in_Full_Date__c = THIS_MONTH) LIMIT 1];
            
        }else{
            
            invoiceItemList = [Select Invoice_Item_ID_18_Character__c, Product_SKU__c, Item_Total__c, ItemQuantity__c, Price__c, 
			Product_Term__c, Product_Level_1__c, Product_Level_2__c, Product_Level_3__c, ccrz__CCOrder__r.Name,
			ccrz__CCOrder__r.Account_ID_18_Character__c, ccrz__CCOrder__r.ccrz__Contact__r.Name, 
			ccrz__CCOrder__r.ccrz__BuyerCompanyName__c, ccrz__CCOrder__r.Billing_Country__c, 
			ccrz__CCOrder__r.Company_Name_Standardized_text__c, ccrz__CCOrder__r.ccrz__OrderStatus__c, 
			ccrz__CCOrder__r.Global_Account_Manager__r.Name, ccrz__CCOrder__r.RA_Referral__c, 
			ccrz__CCOrder__r.ccrz__Account__r.Name, ccrz__Invoice__r.Name, ccrz__Invoice__r.Paid_in_Full_Date__c,
			ccrz__Invoice__r.Owner.Name, ccrz__Invoice__r.AddressRegion__c, ccrz__Invoice__r.AddressNamed_Territory__c, 
			ccrz__Invoice__r.AddressSubTerritory__c, ccrz__Invoice__r.Division__c, ccrz__Invoice__r.Functional_Area__c, 
			CreatedDate from ccrz__E_InvoiceItem__c
        
        	WHERE (ccrz__Invoice__r.ccrz__Status__c != 'Closed' OR ccrz__Invoice__r.ccrz__Status__c != 'Cancelled') AND 
			(NOT((ccrz__CCOrder__r.ccrz__BuyerCompanyName__c LIKE '%ACAMS%') OR 
			(ccrz__CCOrder__r.ccrz__BuyerCompanyName__c LIKE '%Adtalem%') OR 
			(ccrz__CCOrder__r.ccrz__BuyerCompanyName__c LIKE '%Test%') OR 
			(ccrz__CCOrder__r.ccrz__BuyerCompanyName__c LIKE '%TEST%'))) AND (Item_Total__c != 0) AND 
			(ccrz__Invoice__r.Has_Child_Invoices__c = false) AND (Product_Level_2__c != 'Event') AND 
			(ccrz__Invoice__r.Owner.Name != 'Hue Dang') AND (ccrz__Invoice__r.Paid_in_Full_Date__c = LAST_MONTH) LIMIT 1];
        }
        	
        
        return invoiceItemList;
    }*/
    
    public static String getCSTRequestBody(List<ccrz__E_InvoiceItem__c> invoiceItemList){
        
        String requestBody = '';
        
        List<CSTJSON_SAPIntegration> jsonObjects = new List<CSTJSON_SAPIntegration>();
        
        String salesOrder;
    	NumberObject lineNumber;
    	NumberObject subLineNumber;
    	String eventType;
    	String compensationDate;
    	String accountingDate;
    	String productId;
    	NumberObject unitValue;
    	NumberObject value;
    	NumberObject numberOfUnits;
    	String businessUnits;
    	String paymentTerms;
    	String alternateOrderNumber;
    	BillToAddress billToAddress;
    	String genericAttribute1;
    	String genericAttribute2;
    	String genericAttribute3;
    	String genericAttribute4;
    	String genericAttribute5;
    	String genericAttribute6;
    	String genericAttribute7;
    	String genericAttribute8;
    	String genericAttribute9;
    	String genericAttribute10;
    	String genericAttribute11;
    	String genericAttribute12;
    	String genericAttribute13;
    	String genericAttribute14;
    	String genericAttribute15;
    	String genericAttribute16;
    	String genericDate1;
        String originTypeId;
        
        for(ccrz__E_InvoiceItem__c invoiceItem : invoiceItemList){
            
            salesOrder = invoiceItem.Invoice_Item_ID_18_Character__c;
            
            Integer lineNumberValue = Integer.valueOf(invoiceItem.ccrz__Invoice__r.Name.substring(6));
            lineNumber = new NumberObject(lineNumberValue, 'integer');
            
            subLineNumber = new NumberObject(1, 'integer');
            
            eventType = 'Invoice';
            
            Date paidOffDate = invoiceItem.ccrz__Invoice__r.Paid_in_Full_Date__c;
            compensationDate = String.valueOf(paidOffDate.year()) + '-' + String.valueOf(paidOffDate.month()) + '-' + String.valueOf(paidOffDate.day());
            accountingDate = String.valueOf(paidOffDate.year()) + '-' + String.valueOf(paidOffDate.month()) + '-' + String.valueOf(paidOffDate.day());
            
            productId = invoiceItem.Product_SKU__c;
            
            unitValue = new NumberObject((Decimal)invoiceItem.Price__c, 'USD');
            value = new NumberObject((Decimal)invoiceItem.Item_Total__c, 'USD');
            numberOfUnits = new NumberObject((Decimal)invoiceItem.ItemQuantity__c, 'quantity');
            businessUnits = 'ACAMS';
            paymentTerms = String.valueOf(invoiceItem.Product_Term__c);
            alternateOrderNumber = invoiceItem.ccrz__CCOrder__r.Name;
            billToAddress = new BillToAddress(invoiceItem.ccrz__CCOrder__r.Billing_Country__c, '', '', '', '', '', invoiceItem.ccrz__CCOrder__r.Company_Name_Standardized_text__c, '', '', '', invoiceItem.ccrz__CCOrder__r.ccrz__Contact__r.Name, invoiceItem.ccrz__CCOrder__r.Account_ID_18_Character__c, invoiceItem.ccrz__CCOrder__r.ccrz__BuyerCompanyName__c, '', '');
            genericAttribute1 = 'USD';
            genericAttribute2 = invoiceItem.ccrz__CCOrder__r.ccrz__OrderStatus__c;
            genericAttribute3 = invoiceItem.ccrz__Invoice__r.Owner.Name;
            genericAttribute4 = invoiceItem.ccrz__CCOrder__r.Global_Account_Manager__r.Name;
            genericAttribute5 = invoiceItem.ccrz__Invoice__r.AddressRegion__c;
            genericAttribute6 = invoiceItem.ccrz__Invoice__r.AddressNamed_Territory__c;
            genericAttribute7 = invoiceItem.ccrz__Invoice__r.AddressSubTerritory__c;
            genericAttribute8 = invoiceItem.ccrz__Invoice__r.Division__c;
            genericAttribute9 = invoiceItem.ccrz__Invoice__r.Functional_Area__c;
            
            if(invoiceItem.Product_Term__c > 0){
                genericAttribute10 = String.valueOf(invoiceItem.Item_Total__c);
            }else{
                genericAttribute10 = '';
            }
            
            genericAttribute11 = invoiceItem.Product_Level_1__c;
            genericAttribute12 = invoiceItem.Product_Level_2__c;
            genericAttribute13 = invoiceItem.Product_Level_3__c;
            genericAttribute14 = invoiceItem.ccrz__CCOrder__r.RA_Referral__c;
            genericAttribute15 = invoiceItem.ccrz__Invoice__r.Name;
            genericAttribute16 = invoiceItem.ccrz__CCOrder__r.ccrz__Account__r.Name;
            
            Date dateIssued = invoiceItem.CreatedDate.Date();
            genericDate1 = String.valueOf(dateIssued.year()) + '-' + String.valueOf(dateIssued.month()) + '-' + String.valueOf(dateIssued.day());
            originTypeId = 'imported';
            
            CSTJSON_SAPIntegration jsonObject = new CSTJSON_SAPIntegration(salesOrder, lineNumber, subLineNumber, eventType, compensationDate, accountingDate, productId, unitValue, value, numberOfUnits, businessUnits, paymentTerms, alternateOrderNumber, billToAddress, genericAttribute1, genericAttribute2, genericAttribute3, genericAttribute4, genericAttribute5, genericAttribute6, genericAttribute7, genericAttribute8, genericAttribute9, genericAttribute10, genericAttribute11, genericAttribute12, genericAttribute13, genericAttribute14, genericAttribute15, genericAttribute16, genericDate1, originTypeId);
            jsonObjects.add(jsonObject);
        }
        
        requestBody = JSON.serialize(jsonObjects);
        return requestBody;
    }
    
    public static String getCSORequestBody(List<ccrz__E_InvoiceItem__c> invoiceItemList){
        
        String requestBody = '';
        
        List<CSOJSON_SAPIntegration> jsonObjects = new List<CSOJSON_SAPIntegration>();
        
        String salesOrder;
    	String businessUnits;
        
        for(ccrz__E_InvoiceItem__c invoiceItem : invoiceItemList){
            
            salesOrder = invoiceItem.Invoice_Item_ID_18_Character__c;
            businessUnits = 'ACAMS';
            
            CSOJSON_SAPIntegration jsonObject = new CSOJSON_SAPIntegration(salesOrder, businessUnits);
            jsonObjects.add(jsonObject);
        }
        
        requestBody = JSON.serialize(jsonObjects);
        return requestBody;
    }
    
    /*public static void testing(){
        
        try{
        List<ccrz__E_InvoiceItem__c> invoiceItemList = 
        [Select Invoice_Item_ID_18_Character__c, Product_SKU__c, Item_Total__c, ItemQuantity__c, Price__c, 
		Product_Term__c, Product_Level_1__c, Product_Level_2__c, Product_Level_3__c, ccrz__CCOrder__r.Name,
		ccrz__CCOrder__r.Account_ID_18_Character__c, ccrz__CCOrder__r.ccrz__Contact__r.Name, 
		ccrz__CCOrder__r.ccrz__BuyerCompanyName__c, ccrz__CCOrder__r.Billing_Country__c, 
		ccrz__CCOrder__r.Company_Name_Standardized_text__c, ccrz__CCOrder__r.ccrz__OrderStatus__c, 
		ccrz__CCOrder__r.Global_Account_Manager__r.Name, ccrz__CCOrder__r.RA_Referral__c, 
		ccrz__CCOrder__r.ccrz__Account__r.Name, ccrz__Invoice__r.Name, ccrz__Invoice__r.Paid_in_Full_Date__c,
		ccrz__Invoice__r.Owner.Name, ccrz__Invoice__r.AddressRegion__c, ccrz__Invoice__r.AddressNamed_Territory__c, 
		ccrz__Invoice__r.AddressSubTerritory__c, ccrz__Invoice__r.Division__c, ccrz__Invoice__r.Functional_Area__c, 
		CreatedDate from ccrz__E_InvoiceItem__c
        
        WHERE (ccrz__Invoice__r.ccrz__Status__c != 'Closed' OR ccrz__Invoice__r.ccrz__Status__c != 'Cancelled') AND 
		(NOT((ccrz__CCOrder__r.ccrz__BuyerCompanyName__c LIKE '%ACAMS%') OR 
		(ccrz__CCOrder__r.ccrz__BuyerCompanyName__c LIKE '%Adtalem%') OR 
		(ccrz__CCOrder__r.ccrz__BuyerCompanyName__c LIKE '%Test%') OR 
		(ccrz__CCOrder__r.ccrz__BuyerCompanyName__c LIKE '%TEST%'))) AND (Item_Total__c != 0) AND 
		(ccrz__Invoice__r.Has_Child_Invoices__c = false) AND (Product_Level_2__c != 'Event') AND 
		(ccrz__Invoice__r.Owner.Name != 'Hue Dang') AND (ccrz__Invoice__r.Paid_in_Full_Date__c = THIS_MONTH) LIMIT 1];
        
            
            system.debug(getCSTRequestBody(invoiceItemList));
        	system.debug(getCSORequestBody(invoiceItemList));
        }
        catch(Exception e){
            system.debug(e);
        }
    }*/
}