@isTest
public class wsPearsonvueComRtiCddWsdl_Test {

    class wsPearsonvueComRtiCddWsdlMock implements WebServiceMock {
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
            if (request instanceof wsPearsonvueComRtiCddSchema.cddRequestType) {
                response.put('response_x', new wsPearsonvueComRtiCddSchema.cddResponseType());
            }
            return;

        }
    }
    @IsTest static void coverWsPearsonvueComRtiCddWsdl() {
        wsPearsonvueComRtiCddWsdl.CDDSOAPPort cd = new wsPearsonvueComRtiCddWsdl.CDDSOAPPort();
        wsPearsonvueComRtiCddSchema.alternateAddressType aatype = new wsPearsonvueComRtiCddSchema.alternateAddressType();
        wsPearsonvueComRtiCddSchema.extendedFieldsType eetype = new wsPearsonvueComRtiCddSchema.extendedFieldsType();
        wsPearsonvueComRtiCddSchema.clientQuestionType cctype = new wsPearsonvueComRtiCddSchema.clientQuestionType();
        wsPearsonvueComRtiCddSchema.candidatePrefType cddtype = new wsPearsonvueComRtiCddSchema.candidatePrefType();
        wsPearsonvueComRtiCddSchema.customFieldsType custype = new wsPearsonvueComRtiCddSchema.customFieldsType();
        wsPearsonvueComRtiCddSchema.candidateNameType cdtype = new wsPearsonvueComRtiCddSchema.candidateNameType();
        wsPearsonvueComRtiCddSchema.webAccountInfoType watype = new wsPearsonvueComRtiCddSchema.webAccountInfoType();
        wsPearsonvueComRtiCddSchema.primaryAddressType patype = new wsPearsonvueComRtiCddSchema.primaryAddressType();
        wsPearsonvueComRtiCddSchema.nativePrimaryAddressType npatype = new wsPearsonvueComRtiCddSchema.nativePrimaryAddressType();
        wsPearsonvueComRtiCddSchema.phoneType phonetype = new wsPearsonvueComRtiCddSchema.phoneType();
        wsPearsonvueComRtiCddWsdl.CDDSOAPPort partner = new wsPearsonvueComRtiCddWsdl.CDDSOAPPort();
        wsPearsonvueComRtiCddSchema.cddResponseType Result = new wsPearsonvueComRtiCddSchema.cddResponseType();
        wsPearsonvueComRtiCddSchema.candidatePrefsType cddstype = new wsPearsonvueComRtiCddSchema.candidatePrefsType();

        List<wsPearsonvueComRtiCddSchema.alternateAddressType> aatypeList = new List<wsPearsonvueComRtiCddSchema.alternateAddressType>();
        List<wsPearsonvueComRtiCddSchema.cddResponseType> ResponseList = new List<wsPearsonvueComRtiCddSchema.cddResponseType>();
        List<wsPearsonvueComRtiCddSchema.candidatePrefType> cddtypeList = new List<wsPearsonvueComRtiCddSchema.candidatePrefType>();
        List<wsPearsonvueComRtiCddSchema.candidatePrefsType> cddstypeList = new List<wsPearsonvueComRtiCddSchema.candidatePrefsType>();
        Map<Id, wsPearsonvueComRtiCddSchema.cddResponseType> ResultcntMap = new Map<Id, wsPearsonvueComRtiCddSchema.cddResponseType>();
        Datetime LastUpdatedDateTime;
        String LastUpdatedDateTimeformatedDt;
        String clientCandidateID;
        String clientID;
        List<String> prefOptn = new List<String>();

        clientID = '1234';
        //LastUpdatedDateTime = ;
        LastUpdatedDateTimeformatedDt = '2007/06/18 09:35:18 GMT';
        clientCandidateID = '0033B00000THYBp';
        cdtype.firstName = 'testfirst';
        cdtype.lastName = 'testlast';
        cdtype.middleName = 'testmiddle';
        cdtype.salutation = 'Mr';
        cddtype.prefType = 'LocalePreference';

        prefOptn.add('es-US');
        cddtype.prefOption = prefOptn;
        cddtypeList.add(cddtype);
        cddstype.candidatePref = cddtypeList;
        cddstypeList.add(cddstype);

        watype.email = 'test@testcom';
        //watype.userName=c.Email;
        //watype.password=c.Member_Number__c;
        patype.address1 = '5791 sw st';
        patype.city = 'miami';
        patype.companyName = 'test';

        patype.country = 'USA';
        phonetype.phoneCountryCode = '1';

        patype.postalCode = '33130';

        patype.state = 'FL';
        patype.addressType = 'Home';
        phonetype.phoneNumber = '5155058769';

        patype.phone = phonetype;
        aatypeList.add(aatype);
        npatype.language = 'UKN';
        npatype.potentialMismatch = true;
        npatype.firstName = 'test';
        npatype.lastName = 'test';
        npatype.address1 = '5839 sw st';
        npatype.city = 'miami';
        patype.nativeAddress = npatype;
        System.debug(cdtype);
        System.debug(watype);
        System.debug(LastUpdatedDateTimeformatedDt);
        System.debug(patype);
        System.debug(aatypeList);
        System.debug(eetype);
        System.debug(cctype);
        System.debug(cddstypeList);
        System.debug(custype);
        System.debug(clientCandidateID);
        Test.setMock(WebServiceMock.class, new wsPearsonvueComRtiCddWsdlMock());
        Result = partner.importCandidateDemographics(cdtype, watype, LastUpdatedDateTimeformatedDt, patype, aatypeList, eetype, cctype, cddstypeList, custype, clientCandidateID, clientID);

    }

}