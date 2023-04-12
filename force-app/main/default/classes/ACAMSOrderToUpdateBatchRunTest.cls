@isTest()
public class ACAMSOrderToUpdateBatchRunTest {
  @isTest
  public static void TestHandler1() {
    insert new CCACAMSTestUtil().createVertexTaxCalculationBypassSettings();
        Account account = new Account(
                Name = 'Facebook'
        );
        Test.startTest();
        insert account;
        Contact contact = new Contact(
                AccountId = account.Id,
                LastName = 'Karl'
        );
        insert contact;
        ccrz__E_ContactAddr__c adr = new ccrz__E_ContactAddr__c(
                OwnerId = UserInfo.getUserId(),
                ccrz__City__c = 'TestCity'
        );
        insert adr;
        Opportunity testOpportunity;
        testOpportunity = new Opportunity(
                AccountId = account.Id,
                Name = 'Test Opportunity',
                StageName = Opportunity.StageName.getDescribe().getPicklistValues()[0].getValue(),
                CloseDate = Date.today().addDays(10)
        );
        insert testOpportunity;
       
       ccrz__E_Product__c thirdpd = new ccrz__E_Product__c();
        thirdpd.Level_1__c = 'Certification';
        thirdpd.Level_2__c = 'CGSS';
        thirdpd.Level_3__c = 'Recertification';
        thirdpd.Certification_Level__c='Specialist';
        thirdpd.ProductCategory__c = 'Memberships';
        thirdpd.Event_Address_Country__c = 'CAN';
        thirdpd.ccrz__SKU__c= 'SG-AML-Regime';
        thirdpd.Days_to_Expire__c = 205;
        insert thirdpd;
       
        ccrz__E_Order__c ccOrder = new ccrz__E_Order__c (
                ccrz__Account__c = account.Id,
                ccrz__BillTo__c = adr.Id,
                ccrz__Contact__c = contact.Id,
                ccrz__EncryptedId__c = '4a0644e2-8ac5-48b1-b83e-54254e37e67e',
                ccrz__Name__c = 'New Chart',
                ccrz__OrderNumber__c = 1050011,
              ccrz__OrderStatus__c = 'Order Submitted',
              Retry_Count__c = 1,
                 Opportunity__c = testOpportunity.Id,
                OwnerId = UserInfo.getUserId()
        );
        insert ccOrder;
        
        
        ACAMSOrderToUpdateBatchRun abc = new ACAMSOrderToUpdateBatchRun();
        //abc.start();
        
        List<ccrz__E_Order__c> cOrders1 = [SELECT
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
                        Channel__c,
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
                        Opportunity__r.Channel__c,
                        OwnerId,
                  CreatedBy.Name ,LastModifiedBy.Name,Vertex_Tax_Area_Confidence__c,
                  Vertex_Tax_Area_Id__c,
                        Purchaser_Email__c,
                        Tax_Transaction_Code__c
                 
                FROM
                        ccrz__E_Order__c where Id =:ccOrder.Id];
                        
           abc.execute(null,cOrders1);
           
           ccrz__E_Order__c updatedOrder = [select Id, Name, Retry_Count__c, BillTo_City__c from ccrz__E_Order__c where Id =:ccOrder.Id];
           system.debug('Retry_Count__c in Test::'+updatedOrder.Retry_Count__c);
           system.debug('BillTo_City__c in Test::'+updatedOrder.BillTo_City__c);
           system.assertEquals(2,updatedOrder.Retry_Count__c);
           //system.assertNotEquals(null,updatedOrder.BillTo_City__c);
           Test.stopTest(); 
                                          
          
  }   
}