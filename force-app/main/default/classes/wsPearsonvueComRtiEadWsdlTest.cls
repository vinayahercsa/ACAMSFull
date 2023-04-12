@isTest
public class wsPearsonvueComRtiEadWsdlTest {

    class wsPearsonvueComRtiEadWsdlMock implements WebServiceMock {
        public void doInvoke(
                Object stub,
                Object request,
                Map<String, Object> response,
                String endpoint,
                String soapAction,
                String requestName,
                String responseNS,
                String responseName,
                String responseType

        ) {
            if (request instanceof wsPearsonvueComRtiEadSchema.eadRequestType) {
                response.put('response_x', new wsPearsonvueComRtiEadSchema.eadResponseType());
            }
            return;

        }
    }
    @IsTest static void coverWsPearsonvueComRtiEadWsdl() {
        wsPearsonvueComRtiEadSchema.clientAccommodationsType catype = new wsPearsonvueComRtiEadSchema.clientAccommodationsType();

        String LastUpdatedDateTimeformatedDt;
        String clientCandidateID;
        String clientID;
        Integer authCount;
        String examSeriesCode;
        String eligibilityApptDateFirst;
        String eligibilityApptDateLast;
        String authorizationTransactionType;
        String clientAuthorizationID;
        clientAuthorizationID = 'edw908344';
        clientCandidateID = 'aaa443232';
        clientID = '1234';
        authCount = 1;
        authorizationTransactionType = 'Add';
        examSeriesCode = 'CAMS6_ENU';
        eligibilityApptDateFirst = '2019/09/17 12:00:00';
        eligibilityApptDateLast = '2019/12/17 12:00:00';
        LastUpdatedDateTimeformatedDt = '2007/06/18 09:35:18 GMT';

        wsPearsonvueComRtiEadWsdl.EADSOAPPort partner = new wsPearsonvueComRtiEadWsdl.EADSOAPPort();

        Test.setMock(WebServiceMock.class, new wsPearsonvueComRtiEadWsdlMock());
        partner.importExamAuthorization(clientCandidateID, authCount, examSeriesCode, eligibilityApptDateFirst, eligibilityApptDateLast, LastUpdatedDateTimeformatedDt, catype, authorizationTransactionType, clientAuthorizationID, clientID);

    }
}