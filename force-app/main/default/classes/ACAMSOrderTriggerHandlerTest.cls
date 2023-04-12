@IsTest
public class ACAMSOrderTriggerHandlerTest {

    static CCAviTestUtil util = new CCAviTestUtil();
/*
    @IsTest
    public static void testReturnOrderCreated() {
        Map<String, Object> testData = util.initData();

        ccrz__E_Order__c order = (ccrz__E_Order__c) testData.get(CCAviTestUtil.PN_ORDER);
        ccrz__E_TransactionPayment__c tp =
                (ccrz__E_TransactionPayment__c) testData.get(CCAviTestUtil.PN_TRANSACTION_PAYMENT_AUTH);
        ccrz__E_TransactionPayment__c tp2 =
                (ccrz__E_TransactionPayment__c) testData.get(CCAviTestUtil.PN_TRANSACTION_PAYMENT_CAPTURE);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new refundCalloutMockImpl());
        order.ccrz__OrderStatus__c = ACAMSUtil.COMPLETED;
        update order;
        order.ccrz__OrderStatus__c = ACAMSUtil.REFUNDED;
        update order;
        Test.stopTest();
        List<ccrz__E_Order__c> cloneOrder = [
                SELECT
                        Id,
                        ccrz__Name__c
                FROM
                        ccrz__E_Order__c
                WHERE
                        ccrz__Name__c = :ACAMSUtil.REFUNDED_ORDER AND ccrz__Order__c = :order.Id
                LIMIT 1
        ];
        System.assert(cloneOrder[0] != null);
        System.assert(cloneOrder[0].ccrz__Name__c == ACAMSUtil.REFUNDED_ORDER);
        List <ccrz__E_TransactionPayment__c> transactionPayments = [
                SELECT
                        Id,
                        ccrz__TransactionCode__c,
                        ccrz__TransactionPaymentId__c,
                        ccrz__TransactionSubcode__c,
                        ccrz__TransactionType__c
                FROM
                        ccrz__E_TransactionPayment__c
                WHERE
                        ccrz__TransactionSubcode__c = '100'
                LIMIT 1
        ];
        ccrz__E_TransactionPayment__c transactionPayment = transactionPayments.get(0);
        System.assert(!transactionPayments.isEmpty());
        System.assert(transactionPayment.ccrz__TransactionCode__c == 'ACCEPT');
        System.assert(transactionPayment.ccrz__TransactionPaymentId__c == '9057101982752034820293');
        System.assert(transactionPayment.ccrz__TransactionSubcode__c == '100');
        System.assert(transactionPayment.ccrz__TransactionType__c == 'CREDIT');
    }
    */

    class refundCalloutMockImpl implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setHeader('Content-Type', 'application/xml');
            XmlWriter xmlWriter = new XmlWriter();
            response.setBody(xmlWriter.getXml());

            return response;
        }
    }

    class XmlWriter {
        public String getXml() {
            Dom.Document doc = new Dom.Document();

            Dom.XmlNode root = doc.createRootElement('root', null, null);
            Dom.XmlNode body = root.addChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/', null);
            Dom.XmlNode replyMessage = body.addChildElement('replyMessage',
                    'urn:schemas-cybersource-com:transaction-data-1.155', null);
            replyMessage.addChildElement('requestID', 'urn:schemas-cybersource-com:transaction-data-1.155', null)
                    .addTextNode('9057101982752034820293');
            replyMessage.addChildElement('decision', 'urn:schemas-cybersource-com:transaction-data-1.155', null)
                    .addTextNode('ACCEPT');
            replyMessage.addChildElement('reasonCode', 'urn:schemas-cybersource-com:transaction-data-1.155', null)
                    .addTextNode('100');
            Dom.XmlNode ccCreditReplyNode = replyMessage.addChildElement('ccCreditReply',
                    'urn:schemas-cybersource-com:transaction-data-1.155', null);
            ccCreditReplyNode.addChildElement('requestDateTime',
                    'urn:schemas-cybersource-com:transaction-data-1.155', null)
                    .addTextNode('2020-05-30T09:00:00');
            ccCreditReplyNode.addChildElement('amount', 'urn:schemas-cybersource-com:transaction-data-1.155', null)
                    .addTextNode('1');
            return doc.toXmlString();
        }
    }
   @IsTest 
   public static  void testHandler1() {
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
                OwnerId = UserInfo.getUserId()
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
        thirdpd.Certification_Level__c = 'Regime Exam';
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
                 Opportunity__c = testOpportunity.Id,
                OwnerId = UserInfo.getUserId()
        );
        insert ccOrder;
        ccrz__E_Order__c cOrders1 = [select Id,ccrz__OrderStatus__c, Total_Order_Amount__c,(select Id,Status__c from Assets__r),
                                          (select Id,Invoice_Status__c,Finalized__c from ccrz__CCInvoices__r where Finalized__c=true) 
                                          from ccrz__E_Order__c where Id =:ccOrder.Id];
        system.debug('cOrders1.ccrz__OrderStatus__c::'+cOrders1.ccrz__OrderStatus__c);
        system.debug('cOrders1.ccrz__CCInvoices__r::'+cOrders1.ccrz__CCInvoices__r);
        system.debug('cOrders1.Assets__r::'+cOrders1.Assets__r);
        Asset testAssets = 
                new Asset(
                        Name = 'Membership',
                        AccountId = account.Id,
                        ContactId = contact.Id,
                        Assignee__c = contact.Id,
                        CC_Product__c = thirdpd.Id,
                        status__c='InActive',
                        CC_Order__c = ccOrder.Id,
                        Certification_Approved_Application__c = false
                );
        insert testAssets;
        ccrz__E_Invoice__c invoice = new ccrz__E_Invoice__c(
                ccrz__CCOrder__c  = ccOrder.Id,
                ccrz__Type__c = 'String',
                ccrz__BillAddress__c = adr.Id,
                ccrz__Status__c = 'Open',
                ccrz__CurrencyCode__c = 'USD',
                ccrz__BillTo__c = account.Id,
                ccrz__SoldAddress__c = adr.Id,
              Finalized__c = true,
              Invoice_Status__c = 'Open',
              ccrz__RemainingAmount__c = 0.00,
              ccrz__OriginalAmount__c = 0.00,
              ccrz__ParentInvoice__c = null
        );
        insert invoice;
        List<ccrz__E_Invoice__c> testrec1 = [select Id,Invoice_Status__c,Finalized__c from ccrz__E_Invoice__c where Finalized__c=true and ccrz__CCOrder__c  =: ccOrder.Id];
        system.debug('testrec1::'+testrec1);
        
        ccrz__E_Order__c cOrders = [select Id,ccrz__OrderStatus__c, Total_Order_Amount__c,(select Id,Status__c from Assets__r),
                                          (select Id,Invoice_Status__c,Finalized__c from ccrz__CCInvoices__r where Finalized__c=true) 
                                          from ccrz__E_Order__c where Id =:ccOrder.Id];
        system.debug('cOrders.ccrz__OrderStatus__c::'+cOrders.ccrz__OrderStatus__c);
        system.debug('cOrders.ccrz__CCInvoices__r::'+cOrders.ccrz__CCInvoices__r);
        system.debug('cOrders.Assets__r::'+cOrders.Assets__r);
        ccOrder.ccrz__OrderStatus__c = 'Completed';
        update ccOrder;
        Test.stoptest();
        System.assertEquals('Completed', ccOrder.ccrz__OrderStatus__c);
        for(ccrz__E_Invoice__c inv : cOrders.ccrz__CCInvoices__r ) {
          System.assertEquals('Open', inv.Invoice_Status__c);
        }
       
    }

}