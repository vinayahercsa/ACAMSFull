global class ACAMSOrderToUpdateBatchRun implements Schedulable, Database.Batchable<SObject> {
    public static final String ACCOUNT_RECORD_TYPE_BUSINESS = 'Business_Account';
    public static final String REFUNDED_ORDER = 'Refunded Order';
    public static final String SALES_PROFILE = 'ACAMS - Sales';
    public static final String CSR_PROFILE = 'ACAMS - Customer Service';
    public static final String ACCOUNT_RECORD_TYPE_PERSON = 'PersonAccount';
    
     global void execute(SchedulableContext context) {
        Database.executeBatch(new ACAMSOrderToUpdateBatchRun(),1);
    }
    
    global Database.QueryLocator start(Database.BatchableContext context) {
         return Database.getQueryLocator([
                SELECT
                        Id,
                        Name,
                        BillTo_City__c,
                        BillTo_AddressFirstLine__c,
                        BillTo_StateISOCode__c,
                        BillTo_PostalCode__c,
                        BillTo_CountryISOCode__c,
                        BillTo_Named_Territory__c,
                        BillTo_Region__c,
                        BillTo_SubTerritory__c,
                        Enterprise_Account__c,
                        Industry__c,
                        Account_Owner__c,
                        ccrz__BuyerCompanyName__c,
                        Retry_Count__c,
                        ccrz__Account__c,
                        ccrz__Account__r.ccrz__CompanyName__pc,
                        ccrz__Account__r.ccrz__E_AccountGroup__c,
                        ccrz__Account__r.CommunityUser__c,
                        ccrz__Account__r.Industry,
                        ccrz__Account__r.Name,
                        ccrz__Account__r.Number_of_Orders__c,
                        ccrz__Account__r.OwnerId,
                        ccrz__Account__r.RecordType.DeveloperName,
                        ccrz__BillTo__r.ccrz__Country__c,
                        ccrz__BillTo__r.ccrz__CountryISOCode__c,
                        ccrz__BillTo__r.ccrz__City__c,
                        ccrz__BillTo__r.ccrz__PostalCode__c,
                        ccrz__BillTo__r.ccrz__State__c,
                        ccrz__BillTo__r.ccrz__StateISOCode__c,
                        ccrz__BillTo__r.ccrz__AddressFirstline__c,
                        ccrz__BillTo__r.ccrz__AddressSecondLine__c,
                        ccrz__BillTo__r.ccrz__AddressThirdLine__c,
                        ccrz__BillTo__r.Named_Territory__c,
                        ccrz__BillTo__r.SubTerritory__c,
                        ccrz__BillTo__r.Region__c,
                        ccrz__BuyerEmail__c,
                        ccrz__BuyerFirstName__c,
                        ccrz__BuyerLastName__c,
                        ccrz__BuyerPhone__c,
                        ccrz__Contact__c,
                        ccrz__Contact__r.FirstName,
                        ccrz__Contact__r.LastName,
                        ccrz__Contact__r.Email,
                        ccrz__OriginatedCart__c,
                        ccrz__OrderDate__c,
                        ccrz__OrderNumber__c,
                        ccrz__OrderStatus__c,
                        ccrz__PaymentMethod__c,
                        ccrz__ShipAmount__c,
                        ccrz__ShipMethod__c,
                        ccrz__ShipTo__r.ccrz__FirstName__c,
                        ccrz__ShipTo__r.ccrz__MiddleName__c,
                        ccrz__ShipTo__r.ccrz__LastName__c,
                        ccrz__ShipTo__r.ccrz__AddressFirstline__c,
                        ccrz__ShipTo__r.ccrz__AddressSecondline__c,
                        ccrz__ShipTo__r.ccrz__AddressThirdline__c,
                        ccrz__ShipTo__r.ccrz__City__c,
                        ccrz__ShipTo__r.ccrz__State__c,
                        ccrz__ShipTo__r.ccrz__StateISOCode__c,
                        ccrz__ShipTo__r.ccrz__Country__c,
                        ccrz__ShipTo__r.ccrz__CountryISOCode__c,
                        ccrz__ShipTo__r.ccrz__PostalCode__c,
                        ccrz__ShipTo__r.ccrz__DaytimePhone__c,
                        ccrz__ShipTo__r.ccrz__HomePhone__c,
                        ccrz__ShipTo__r.ccrz__Email__c,
                        ccrz__ShipTo__r.OwnerId,
                        ccrz__ShipTo__r.ccrz__Partner_Id__c,
                        ccrz__ShipTo__r.ccrz__AddrReadOnly__c,
                        ccrz__ShipTo__r.ccrz__CompanyName__c,
                        ccrz__ShipTo__r.ccrz__MailStop__c,
                        ccrz__ShipTo__r.ccrz__ShippingComments__c,
                        ccrz__ShipTo__r.CreatedById,
                        ccrz__TaxAmount__c,
                        ccrz__TotalAmount__c,
                        Paid_in_Full_Date__c,
                        ccrz__User__c,
                       // Channel__c,
                        Account_Group__r.Enterprise_Account__c,
                        Enterprise_Upgrade__c,
                        Number_of_B2B_Order_Items__c,
                        Opportunity__c,
                        Opportunity__r.OwnerId,
                        Opportunity__r.Account_Owner__c,
                        Opportunity__r.Company_Name__c,
                        Opportunity__r.Enterprise_Account__c,
                        Opportunity__r.Industry__c,
                        Opportunity__r.BillTo_AddressFirstLine__c,
                        Opportunity__r.BillTo_City__c,
                        Opportunity__r.AddressRegion__c,
                        Opportunity__r.AddressNamed_Territory__c,
                        Opportunity__r.AddressSubTerritory__c,
                        Opportunity__r.BillTo_PostalCode__c,
                        Opportunity__r.BillTo_CountryISOCode__c,
                        Opportunity__r.New_or_Existing__c,
                       // Opportunity__r.Channel__c,
                        OwnerId,
                  CreatedBy.Name ,LastModifiedBy.Name,Vertex_Tax_Area_Confidence__c,
                  Vertex_Tax_Area_Id__c,
                        Purchaser_Email__c,
                        Tax_Transaction_Code__c
             		
                FROM
                        ccrz__E_Order__c
                WHERE (Type__c = NULL 
                OR BillTo_Region__c = NULL
                OR ccrz__BuyerCompanyName__c = NULL
                OR BillTo_Named_Territory__c = NULL
                OR BillTo_SubTerritory__c    = NULL
                OR BillTo_City__c            = NULL
                OR Industry__c               = NULL
                OR BillTo_AddressFirstLine__c= NULL
              //  OR Channel__c                = NULL
                OR BillTo_PostalCode__c      = NULL
                OR Enterprise_Account__c     = NULL
                OR Legal_Entity__c           = NULL
                OR New_or_Existing__c        = NULL)
                
                AND (Retry_Count__c = NULL OR Retry_Count__c < 2)
                AND createdDate = TODAY            
        ]);
        
    }

    global void execute(Database.BatchableContext context, List<ccrz__E_Order__c> ccOrders) {
        List<Opportunity> FinalOppListToupdate = new List<Opportunity>();
        List<ccrz__E_Order__c> FinalCCOrdersToUpdate = new List<ccrz__E_Order__c>();
        
        for (ccrz__E_Order__c orderToUpdate : ccOrders) {
        system.debug('orderToUpdate before::'+orderToUpdate);
        system.debug('Order Id:'+orderToUpdate.Id);
        //orderToUpdate = ACAMSOrderDAO.getOrder(orderToUpdate.Id);
        if (orderToUpdate.ccrz__Account__r.RecordType.DeveloperName == ACCOUNT_RECORD_TYPE_BUSINESS) {
            orderToUpdate.ccrz__BuyerCompanyName__c = orderToUpdate.ccrz__Account__r.Name;
            orderToUpdate.Account_Owner__c = orderToUpdate.ccrz__Account__r.OwnerId;
        } else {
            orderToUpdate.ccrz__BuyerCompanyName__c = orderToUpdate.ccrz__Account__r.ccrz__CompanyName__pc;
            orderToUpdate.Account_Owner__c = orderToUpdate.ccrz__Account__r.CommunityUser__c;
        }
        if (orderToUpdate.Opportunity__c != null) {
            orderToUpdate.Opportunity_Owner__c = orderToUpdate.Opportunity__r.OwnerId;
        }
        if(orderToUpdate.BillTo_City__c == null){
       	  orderToUpdate.BillTo_City__c = orderToUpdate.ccrz__BillTo__r.ccrz__City__c;
        }
        if(orderToUpdate.BillTo_AddressFirstLine__c == null){
          orderToUpdate.BillTo_AddressFirstLine__c = orderToUpdate.ccrz__BillTo__r.ccrz__AddressFirstline__c;
        }
        if(orderToUpdate.BillTo_StateISOCode__c == null){
          orderToUpdate.BillTo_StateISOCode__c = orderToUpdate.ccrz__BillTo__r.ccrz__State__c;
        }
        if(orderToUpdate.BillTo_PostalCode__c == null){
          orderToUpdate.BillTo_PostalCode__c = orderToUpdate.ccrz__BillTo__r.ccrz__PostalCode__c;
        }
        if(orderToUpdate.BillTo_CountryISOCode__c == null){
          orderToUpdate.BillTo_CountryISOCode__c = orderToUpdate.ccrz__BillTo__r.ccrz__CountryISOCode__c;
        }
         if(orderToUpdate.BillTo_Named_Territory__c == null){
          orderToUpdate.BillTo_Named_Territory__c = orderToUpdate.ccrz__BillTo__r.Named_Territory__c;
        }
         if(orderToUpdate.BillTo_Region__c == null){
          orderToUpdate.BillTo_Region__c = orderToUpdate.ccrz__BillTo__r.Region__c;
        }
          if(orderToUpdate.BillTo_SubTerritory__c == null){
          orderToUpdate.BillTo_SubTerritory__c = orderToUpdate.ccrz__BillTo__r.SubTerritory__c;
        }
          if(orderToUpdate.Enterprise_Account__c == null){
          orderToUpdate.Enterprise_Account__c = orderToUpdate.Account_Group__r.Enterprise_Account__c;
        }
            if(orderToUpdate.Industry__c == null){
            orderToUpdate.Industry__c = orderToUpdate.ccrz__Account__r.Industry;
        }
        
        if(orderToUpdate.Account_Owner__c == NULL){
            orderToUpdate.Account_Owner__c = orderToUpdate.Opportunity__r.Account_Owner__c;
        }
        if(orderToUpdate.ccrz__BuyerCompanyName__c == NULL){
            orderToUpdate.ccrz__BuyerCompanyName__c = orderToUpdate.Opportunity__r.Company_Name__c;
        }
        
        if(orderToUpdate.Enterprise_Account__c == NULL){
            orderToUpdate.Enterprise_Account__c = orderToUpdate.Opportunity__r.Enterprise_Account__c;
        }
        
        if(orderToUpdate.Industry__c == NULL){
            orderToUpdate.Industry__c = orderToUpdate.Opportunity__r.Industry__c;
        }
        
        if(orderToUpdate.BillTo_AddressFirstLine__c == NULL){
            orderToUpdate.BillTo_AddressFirstLine__c = orderToUpdate.Opportunity__r.BillTo_AddressFirstLine__c;
        }
        
        if(orderToUpdate.BillTo_City__c == NULL){
            orderToUpdate.BillTo_City__c = orderToUpdate.Opportunity__r.BillTo_City__c;
        }
        
        if(orderToUpdate.BillTo_Region__c == NULL){
            orderToUpdate.BillTo_Region__c = orderToUpdate.Opportunity__r.AddressRegion__c;
        }
        
        if(orderToUpdate.BillTo_Named_Territory__c == NULL){
            orderToUpdate.BillTo_Named_Territory__c = orderToUpdate.Opportunity__r.AddressNamed_Territory__c;
        }
        
        if(orderToUpdate.BillTo_SubTerritory__c == NULL){
            orderToUpdate.BillTo_SubTerritory__c = orderToUpdate.Opportunity__r.AddressSubTerritory__c;
        }
        
        if(orderToUpdate.BillTo_PostalCode__c == NULL){
            orderToUpdate.BillTo_PostalCode__c = orderToUpdate.Opportunity__r.BillTo_PostalCode__c;
        }
        
        if(orderToUpdate.BillTo_CountryISOCode__c == NULL){
            orderToUpdate.BillTo_CountryISOCode__c = orderToUpdate.Opportunity__r.BillTo_CountryISOCode__c;
        }
        
        List<ccrz__E_Order__c> orderList = [
                SELECT
                        Id
                FROM
                        ccrz__E_Order__c
                WHERE
                        ccrz__Account__c = :orderToUpdate.ccrz__Account__c
                AND
                        ccrz__Name__c != :REFUNDED_ORDER
        ];

        if (orderList.size() > 1) {
            orderToUpdate.New_or_Existing__c = 'Existing';
        } else {
            orderToUpdate.New_or_Existing__c = 'New';
        }
        
        if(orderToUpdate.New_or_Existing__c == NULL){
            orderToUpdate.New_or_Existing__c = orderToUpdate.Opportunity__r.New_or_Existing__c;
        }

        Map<String, Profile> profileMap = ACAMSUserDAO.getProfilesMap(new Set<String>{
                SALES_PROFILE, CSR_PROFILE
        });
        Profile salesProfile = profileMap.containsKey(SALES_PROFILE) ? profileMap.get(SALES_PROFILE) : null;
        Profile customerServiceProfile = profileMap.containsKey(CSR_PROFILE) ? profileMap.get(CSR_PROFILE) : null;
        User userFromOrder = [
                SELECT
                        Id, ProfileId
                FROM
                        User
                WHERE
                        Id = :orderToUpdate.OwnerId
        ];
       /* if (salesProfile != null && userFromOrder.ProfileId == salesProfile.Id) {
            orderToUpdate.Channel__c = 'Sales';
        } else if (orderToUpdate.Opportunity__c == null && orderToUpdate.ccrz__BuyerEmail__c != null &&
                (!orderToUpdate.ccrz__BuyerEmail__c.equals(orderToUpdate.Purchaser_Email__c))) {
            orderToUpdate.Channel__c = 'Web Assisted';
        } else if (orderToUpdate.Opportunity__c == null) {
            orderToUpdate.Channel__c = 'Web Order';
        } else if (customerServiceProfile != null && userFromOrder.ProfileId == customerServiceProfile.Id) {
            orderToUpdate.Channel__c = 'Customer Service';
        } */

        if (orderToUpdate.Opportunity__c == null) {
            if (orderToUpdate.Number_of_B2B_Order_Items__c > 0) {
                orderToUpdate.Type__c = 'B2B';
            } else if (orderToUpdate.Number_of_B2B_Order_Items__c == 0) {
                orderToUpdate.Type__c = 'B2C';
            }
        } else if (orderToUpdate.Opportunity__c != null) {
            if (orderToUpdate.ccrz__Account__r.RecordType.DeveloperName == ACCOUNT_RECORD_TYPE_PERSON) {
                orderToUpdate.Type__c = 'B2C';
            } else {
                orderToUpdate.Type__c = 'B2B';
            }
        }
        
       /* if(orderToUpdate.Channel__c == NULL){
            orderToUpdate.Channel__c = orderToUpdate.Opportunity__r.Channel__c;
        }*/

        if (orderToUpdate.Opportunity__c != null) {
            Opportunity oppToUpdate = ACAMSOpportunityDAO.getOpportunity(orderToUpdate.Opportunity__c);
            orderToUpdate.Enterprise_Upgrade__c = oppToUpdate.Enterprise_Upgrade__c;

            // Opportunities
            if (oppToUpdate.Account.RecordType.DeveloperName == ACCOUNT_RECORD_TYPE_BUSINESS) {
                oppToUpdate.Company_Name__c = oppToUpdate.Account.Name;
                oppToUpdate.Account_Owner__c = oppToUpdate.Account.OwnerId;
            } else {
                oppToUpdate.Company_Name__c = oppToUpdate.Account.ccrz__CompanyName__pc;
                oppToUpdate.Account_Owner__c = oppToUpdate.Account.CommunityUser__c;
            }
            if(oppToUpdate.BillTo_City__c == null){
            oppToUpdate.BillTo_City__c = oppToUpdate.CC_Cart__r.ccrz__BillTo__r.ccrz__City__c;
            }
            if(oppToUpdate.BillTo_AddressFirstLine__c == null){
            oppToUpdate.BillTo_AddressFirstLine__c = oppToUpdate.CC_Cart__r.ccrz__BillTo__r.ccrz__AddressFirstline__c;
            }
            if(oppToUpdate.BillTo_State__c == null){
            oppToUpdate.BillTo_State__c = oppToUpdate.CC_Cart__r.ccrz__BillTo__r.ccrz__State__c;
            }
            if(oppToUpdate.BillTo_PostalCode__c == null){
            oppToUpdate.BillTo_PostalCode__c = oppToUpdate.CC_Cart__r.ccrz__BillTo__r.ccrz__PostalCode__c;
            }
            if(oppToUpdate.BillTo_CountryISOCode__c == null){
            oppToUpdate.BillTo_CountryISOCode__c = oppToUpdate.CC_Cart__r.ccrz__BillTo__r.ccrz__CountryISOCode__c;
            }
            if(oppToUpdate.Enterprise_Account__c == null){
            oppToUpdate.Enterprise_Account__c = oppToUpdate.Account.ccrz__E_AccountGroup__r.Enterprise_Account__c;
            }
            if(oppToUpdate.Industry__c == null){
            oppToUpdate.Industry__c = oppToUpdate.Account.Industry;
            }

            if (oppToUpdate.Account.Number_of_Orders__c > 0) {
                oppToUpdate.New_or_Existing__c = 'Existing';
            } else {
                oppToUpdate.New_or_Existing__c = 'New';
            }

            User oppOwner = [
                    SELECT
                            Id, ProfileId
                    FROM
                            User
                    WHERE
                            Id = :oppToUpdate.OwnerId
            ];

           /* if (salesProfile != null && oppOwner.ProfileId == salesProfile.Id) {
                oppToUpdate.Channel__c = 'Sales';
            } else if (customerServiceProfile != null && oppOwner.ProfileId == customerServiceProfile.Id) {
                oppToUpdate.Channel__c = 'Customer Service';
            } */

            if (oppToUpdate.Account.RecordType.DeveloperName == ACCOUNT_RECORD_TYPE_PERSON) {
                oppToUpdate.Type = 'B2C';
            } else {
                oppToUpdate.Type = 'B2B';
            }
		//	orderToUpdate.Retry_Count__c = orderToUpdate.Retry_Count__c == NULL?1:orderToUpdate.Retry_Count__c+1;
            FinalOppListToupdate.add(oppToUpdate);
        }
            system.debug('orderToUpdate.Retry_Count__c1' + orderToUpdate.Retry_Count__c);
            orderToUpdate.Retry_Count__c = orderToUpdate.Retry_Count__c == NULL?1:orderToUpdate.Retry_Count__c+1;
            system.debug('orderToUpdate.Retry_Count__c2' + orderToUpdate.Retry_Count__c);
		FinalCCOrdersToUpdate.add(orderToUpdate); 
                
        }
        if(FinalCCOrdersToUpdate.size() > 0){
        	update FinalCCOrdersToUpdate;
    	}
    	if(FinalOppListToupdate.size() > 0){
        	update FinalOppListToupdate;
    	}
     
    }
        

    global void finish(Database.BatchableContext context) {

    } 
}