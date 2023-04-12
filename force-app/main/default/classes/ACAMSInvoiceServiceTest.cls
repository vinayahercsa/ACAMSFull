@IsTest
class ACAMSInvoiceServiceTest {

    @TestSetup
    static void initData() {
        CCACAMSTestUtil testUtil = new CCACAMSTestUtil();
        Map<String, Object> testData = testUtil.initData();
        ccrz__E_ContactAddr__c testAddress = (ccrz__E_ContactAddr__c) testData.get(CCAviTestUtil.PN_CONTACT_ADDRESS);
        testAddress.Vertex_Tax_Area_Id__c = 4354;
        update testAddress;
        User u = [SELECT Id FROM user WHERE profile.name='System Administrator' AND isActive = true limit 1];
        ccrz__E_Order__c testOrder = (ccrz__E_Order__c) testData.get(CCAviTestUtil.PN_ORDER);
        testOrder.OwnerId=u.id;
        update testOrder;
        ccrz__E_Product__c testProduct = (ccrz__E_Product__c) testData.get(CCAviTestUtil.PN_PRODUCT);
        List<ccrz__E_OrderItem__c> testOrderItems = (List<ccrz__E_OrderItem__c>) testData.get(CCAviTestUtil.PN_ORDER_ITEMS);
        Account testAccount = (Account) testData.get(CCAviTestUtil.PN_USER_ACCOUNT);
        User testUser = (User) testData.get(CCAviTestUtil.PN_PORTAL_USER);
        testProduct.Level_1__c = 'Conferences';
        testProduct.Event_Address_Country__c = 'DE';
        update testProduct;
        ccrz__E_Invoice__c testInvoice = new ccrz__E_Invoice__c(
                ccrz__CCOrder__c = testOrder.Id,
                ccrz__BillAddress__c = testAddress.Id,
                ccrz__SoldAddress__c = testAddress.Id,
                ccrz__BillTo__c = testAccount.Id,
                ccrz__SoldTo__c = testAccount.Id,
                ccrz__CurrencyCode__c = testOrder.ccrz__CurrencyISOCode__c,
                ccrz__User__c = testUser.Id
                
        );
        insert testInvoice;
        ccrz__E_InvoiceItem__c item1 = new ccrz__E_InvoiceItem__c(
                ccrz__CCOrderItem__c = testOrderItems[0].Id,
                ccrz__Invoice__c = testInvoice.Id
        );
        ccrz__E_InvoiceItem__c item2 = new ccrz__E_InvoiceItem__c(
                ccrz__CCOrderItem__c = testOrderItems[1].Id,
                ccrz__Invoice__c = testInvoice.Id
        );
        insert new List<ccrz__E_InvoiceItem__c>{
                item1, item2
        };
    }

    @IsTest
    static void splitOrdersInvoice() {
        ccrz__E_Order__c testOrder = [
                SELECT Id
                FROM ccrz__E_Order__c
                LIMIT 1
        ];
        Test.startTest();
        ACAMSInvoiceService.splitOrderInvoice(testOrder.Id);
        Test.stopTest();
        List<ccrz__E_Invoice__c> childInvoices = [
                SELECT Id
                FROM ccrz__E_Invoice__c
                WHERE ccrz__ParentInvoice__r.ccrz__CCOrder__c = :testOrder.Id
        ];
        System.assertEquals(0, childInvoices.size());
    }

    @IsTest
    static void updateItemsByVertexLogData() {
        List<String> lineItems = new List<String>();
        List<ccrz__E_InvoiceItem__c> testItems = [
                SELECT Id, ccrz__Invoice__c
                FROM ccrz__E_InvoiceItem__c
        ];
        Set<Id> invoiceIds = new Set<Id>();
        for (ccrz__E_InvoiceItem__c invoiceItem : testItems) {
            invoiceIds.add(invoiceItem.ccrz__Invoice__c);
        }
        for (Integer i = 0; i < testItems.size(); i++) {
            lineItems.add(createXmlLineItem(testItems[i].Id, i, 'seller' + i, 'TAX'));
        }
        String xmlResponse = createXmlResponse(testItems[0].ccrz__Invoice__c, lineItems);
        System.debug('---response------>'+xmlResponse);
        Test.startTest();
        insert new Vertex__VertexLog__c(Vertex__Response__c = xmlResponse);
        Test.stopTest();
        for (ccrz__E_InvoiceItem__c testItem : [
                SELECT Id, Seller_Tax_Registration_ID__c, Imposition_Type__c, Destination_Country__c
                FROM ccrz__E_InvoiceItem__c
                WHERE Id IN :testItems
        ]) {
            System.assert(!String.isBlank(testItem.Seller_Tax_Registration_ID__c));
            System.assert(!String.isBlank(testItem.Imposition_Type__c));
        }
        for (ccrz__E_Invoice__c invoice : [
                SELECT
                        Id, Seller_Tax_Registration_ID__c,Finalized__c, Sent_to_Vertex__c
                FROM
                        ccrz__E_Invoice__c
                WHERE
                        Id IN :invoiceIds
        ]) {
          system.debug('invoice in ::'+invoice+':Id:'+invoice.Seller_Tax_Registration_ID__c);
          system.debug('invoice.Finalized__c'+invoice.Finalized__c+':sent:'+invoice.Sent_to_Vertex__c);
            System.assert(String.isBlank(invoice.Seller_Tax_Registration_ID__c)); //FSA-537
            //System.assert(!invoice.Seller_Tax_Registration_ID__c.contains('65-1154961')); //FSA-537
        }
    }

    static String createXmlLineItem(String lineId, Integer itemNumber, String sellerId, String impositionType) {
        return String.format('<LineItem lineItemId="{0}" lineItemNumber="{1}">' +
                '<Taxes taxResult="TAXABLE" taxType="SELLER_USE" situs="DESTINATION" taxCollectedFromParty="BUYER" taxStructure="SINGLE_RATE">' +
                '<Jurisdiction jurisdictionLevel="STATE" jurisdictionId="4849">CONNECTICUT</Jurisdiction>' +
                '<CalculatedTax>31.43</CalculatedTax>' +
                '<EffectiveRate>0.0635</EffectiveRate>' +
                '<Taxable>495.0</Taxable>' +
                '<Imposition impositionId="1">Sales and Use Tax</Imposition>' +
                '<ImpositionType impositionTypeId="1">General Sales and Use Tax</ImpositionType>' +
                '<TaxRuleId>373219</TaxRuleId>' +
                '</Taxes>' +
                '<FlexibleFields><FlexibleCodeField fieldId="24">{2}' +
                '</FlexibleCodeField><FlexibleCodeField fieldId="25">{3}</FlexibleCodeField></FlexibleFields></LineItem>',
                new List<Object>{
                        lineId, itemNumber, sellerId, impositionType
                });
    }

    static String createXmlResponse(String invoiceId, List<String> lineItems) {
        return String.format(
                '<?xml version="1.0" encoding="UTF-8" ?> <soapenv:Envelope ' +
                        'xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header /><soapenv:Body> ' +
                        '<VertexEnvelope xmlns="urn:vertexinc:o-series:tps:7:0" ' +
                        'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"> ' +
                        '><InvoiceResponse documentNumber="{0}" documentDate="2020-04-22" transactionId="{0}" ' +
                        'transactionType="SALE">{1}</InvoiceResponse></VertexEnvelope></soapenv:Body></soapenv:Envelope>',
                new List<Object>{
                        invoiceId,
                        String.join(lineItems, '')
                }
        );
    }

}