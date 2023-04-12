@isTest
public class wsPearsonvueComRtiCddSchemaTest {

    @isTest
    static void cddResponseType_test() {
        wsPearsonvueComRtiCddSchema.cddResponseType cd = new wsPearsonvueComRtiCddSchema.cddResponseType();
        cd.status = 'Success';
        cd.candidateID = 12345;
        cd.clientCandidateID = 'a2f3222';
        cd.date_x = '09/16/2019';
        cd.message = 'Success';
    }

    @isTest
    static void phoneType_test() {
        wsPearsonvueComRtiCddSchema.phoneType ph = new wsPearsonvueComRtiCddSchema.phoneType();
        ph.extension = '204';
        ph.phoneCountryCode = '1';
        ph.phoneNumber = '1232342345';
    }

    @isTest
    static void webAccountInfoType_test() {
        wsPearsonvueComRtiCddSchema.webAccountInfoType wa = new wsPearsonvueComRtiCddSchema.webAccountInfoType();
        wa.email = 'test@test.com';
        wa.password = 'tester';
        wa.userName = 'test@test.com';
    }

    @isTest
    static void candidatePrefsType_test() {
        wsPearsonvueComRtiCddSchema.candidatePrefsType cdp = new wsPearsonvueComRtiCddSchema.candidatePrefsType();
    }
    @isTest
    static void clientQuestionType_test() {
        wsPearsonvueComRtiCddSchema.clientQuestionType cqt = new wsPearsonvueComRtiCddSchema.clientQuestionType();
    }

    @isTest
    static void nativePrimaryAddressType_test() {
        wsPearsonvueComRtiCddSchema.nativePrimaryAddressType npa = new wsPearsonvueComRtiCddSchema.nativePrimaryAddressType();
    }

    @isTest
    static void cddRequestType_test() {
        wsPearsonvueComRtiCddSchema.cddRequestType crt = new wsPearsonvueComRtiCddSchema.cddRequestType();
    }

    @isTest
    static void candidateNameType_test() {
        wsPearsonvueComRtiCddSchema.candidateNameType cnt = new wsPearsonvueComRtiCddSchema.candidateNameType();
    }

    @isTest
    static void mobileType_test() {
        wsPearsonvueComRtiCddSchema.mobileType mt = new wsPearsonvueComRtiCddSchema.mobileType();
    }

    @isTest
    static void alternateAddressType_test() {
        wsPearsonvueComRtiCddSchema.alternateAddressType adt = new wsPearsonvueComRtiCddSchema.alternateAddressType();
    }

    @isTest
    static void primaryAddressType_test() {
        wsPearsonvueComRtiCddSchema.primaryAddressType pat = new wsPearsonvueComRtiCddSchema.primaryAddressType();
    }

    @isTest
    static void extendedFieldsType_test() {
        wsPearsonvueComRtiCddSchema.extendedFieldsType eft = new wsPearsonvueComRtiCddSchema.extendedFieldsType();
    }

    @isTest
    static void faxType_test() {
        wsPearsonvueComRtiCddSchema.faxType ft = new wsPearsonvueComRtiCddSchema.faxType();
    }

    @isTest
    static void customFieldsType_test() {
        wsPearsonvueComRtiCddSchema.customFieldsType cft = new wsPearsonvueComRtiCddSchema.customFieldsType();
    }

    @isTest
    static void candidatePrefType_test() {
        wsPearsonvueComRtiCddSchema.candidatePrefType cdpt = new wsPearsonvueComRtiCddSchema.candidatePrefType();
    }

    @isTest
    static void nativeAlternateAddressType_test() {
        wsPearsonvueComRtiCddSchema.nativeAlternateAddressType nat = new wsPearsonvueComRtiCddSchema.nativeAlternateAddressType();
    }

    @isTest
    static void fieldType_test() {
        wsPearsonvueComRtiCddSchema.fieldType ft = new wsPearsonvueComRtiCddSchema.fieldType();
    }

}