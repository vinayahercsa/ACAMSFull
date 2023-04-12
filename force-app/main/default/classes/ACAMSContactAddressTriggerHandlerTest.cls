@isTest
public class ACAMSContactAddressTriggerHandlerTest {
  @isTest
    public static void testAfterUpdate() {
        // Create test data
        ccrz__E_ContactAddr__c testContactAddr = new ccrz__E_ContactAddr__c();
        testContactAddr.ccrz__Country__c='India';
        insert testContactAddr;

        ccrz__E_Cart__c testCart = new ccrz__E_Cart__c();
        testCart.ccrz__BillTo__c = testContactAddr.Id;
        testCart.ccrz__ShipTo__c = testContactAddr.Id;
        insert testCart;

        ccrz__E_Order__c testOrder = new ccrz__E_Order__c();
        testOrder.ccrz__BillTo__c = testContactAddr.Id;
        testOrder.ccrz__ShipTo__c = testContactAddr.Id;
        insert testOrder;

        // Set up test context
        Test.startTest();

        // Update the test Contact Address record
        testContactAddr.Vertex_Tax_Area_Id__c = 123456;
        update testContactAddr;
		Vertex_Tax_Calculation_Bypass__c bypassSettings =Vertex_Tax_Calculation_Bypass__c.getInstance();
       bypassSettings.Bypass_Invoice_Tax_Calculation__c=false;
       upsert bypassSettings;
        // Verify that the correct events were published
        List<Vertex.VertexAnyRequest.InvokeAnyRequestStructure> requestList = new List<Vertex.VertexAnyRequest.InvokeAnyRequestStructure>();
Vertex.VertexAnyRequest.InvokeAnyRequestStructure request=new Vertex.VertexAnyRequest.InvokeAnyRequestStructure();
                request.recordId = testCart.Id;
                request.type = 'CC Cart';

        Test.stopTest();
    }
}