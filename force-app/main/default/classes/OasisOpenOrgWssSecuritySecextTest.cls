@isTest
public class OasisOpenOrgWssSecuritySecextTest {

    @isTest
    static void UsernameToken_test() {
        String Username;
        String Password;
        Username = 'testusr';
        Password = 'testpswd';
        OasisOpenOrgWssSecuritySecext.UsernameToken oa = new OasisOpenOrgWssSecuritySecext.UsernameToken(Username, Password);
    }
    @isTest
    static void SecurityHeaderType_test() {
        String Username;
        String Password;
        Username = 'testusr';
        Password = 'testpswd';
        OasisOpenOrgWssSecuritySecext.SecurityHeaderType oa = new OasisOpenOrgWssSecuritySecext.SecurityHeaderType(Username, Password);
    }

}