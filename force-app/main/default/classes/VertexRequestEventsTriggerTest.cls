@isTest
private class VertexRequestEventsTriggerTest {

  
    @isTest
    static void testVertexRequestEventsTrigger() {
        Account testAccount = new Account(
                Name = 'test',
                Assets_Assigned__c = 2
        );
        insert testAccount;
        
         Contact testContact = new Contact(
                LastName = 'Test',
                AccountId = testAccount.Id,
                Member_Expire_Date__c = (Date.today()+20)
        );
        insert testContact;
        
        LMSCourse__c lmsc = new LMSCourse__c();
        lmsc.Name= 'Test Course';
        lmsc.Description__c = 'Test Course Description';
        lmsc.Credits__c = 10;
        insert lmsc;
        
        ACAMSContactAddressTriggerHandler.skipAddressValidation = true;
        Map<String, Object> initialData = new CCACAMSTestUtil().initData();
        ACAMSContactAddressTriggerHandler.skipAddressValidation = false;
        ccrz__E_Order__c testOrder = (ccrz__E_Order__c) initialData.get(CCAviTestUtil.PN_ORDER);
        testOrder.ccrz__CurrencyISOCode__c = 'USD';
        update testOrder;
        
        List<ccrz__E_Product__c> products = new List<ccrz__E_Product__c>();
        ccrz__E_Product__c compd = new ccrz__E_Product__c();
        compd.HigherLogic_Group__c = 'HL Community';
        compd.Level_1__c = 'Certification';
        compd.Level_2__c = 'CKYCA';
       // compd.Level_3__c = 'Recertification';
       	compd.Certification_Level__c = 'Associate';
        compd.ProductCategory__c = 'Memberships';
        compd.ccrz__SKU__c= '1234';
        compd.Days_to_Expire__c = 200;
        compd.LMS_Course__c = lmsc.Id;
        compd.Expiration_Date_Logic__c = 'Payment';
        
        products.add(compd);
        insert products;
        
        List<Asset> testAssets = new List<Asset>{
                new Asset(
                        Name = 'Membership',
                        AccountId = testAccount.Id,
                        status__c='Active',
                        Assignee__c = testContact.Id,
                        CC_Product__c = products[0].Id,
                        CC_Order__c = testOrder.Id,
                        Paid_Cert__c = false,
                        Payment_Status__c = 'Pending',
                        Certification_Approved_Application__c = false
                      
                )
                    
        };
        insert testAssets;
        
        List<Vertex.VertexAnyRequest.InvokeAnyRequestStructure> requestList = new List<Vertex.VertexAnyRequest.InvokeAnyRequestStructure>();
		Vertex.VertexAnyRequest.InvokeAnyRequestStructure request=new Vertex.VertexAnyRequest.InvokeAnyRequestStructure();
        request.recordId = testOrder.Id;
        //request.type = 'CC Order';
        requestList.add(request);
        List<Vertex_Request_PE__e> vertexReqPlatformEvents = new List<Vertex_Request_PE__e>();
            for(Vertex.VertexAnyRequest.InvokeAnyRequestStructure req : requestList){
                vertexReqPlatformEvents.add(new Vertex_Request_PE__e(RecordId__c=req.recordId,Type__c = ''));
                
            }
			
        
        // Insert events
        Test.startTest();
        List<Database.SaveResult> results = EventBus.publish(vertexReqPlatformEvents);
        Test.stopTest();       
    }
}