@IsTest
public class ACAMSCeregoServiceTest {

    static CCAviTestUtil util = new CCAviTestUtil();

    @IsTest
    public static void testCeregoCalloutCaseCreation() {
        Map<String, Object> testData = util.initData();
        ccrz__E_Order__c order = (ccrz__E_Order__c) testData.get(CCAviTestUtil.PN_ORDER);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CeregoCalloutMockImpl());
        List<Case> caseList = new List<Case>();
        HttpResponse res = ACAMSCeregoService.performCeregoProductCallout('test1', 'testUser1', 'testemail@test.com', order.Id, caseList);
        Test.stopTest();
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = res.getBody();
        String expectedValue = '{"example":"test"}';
        System.assertEquals(actualValue, expectedValue);
        System.assertNotEquals(200, res.getStatusCode());
        System.assert(!caseList.isEmpty());
    }


    class CeregoCalloutMockImpl implements HttpCalloutMock {
          public HttpResponse respond(HttpRequest req) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(400);
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"example":"test"}');
            return response;
        }
    }
}