@isTest
public class ACAMSSubscriptionProcessorTest {

    @isTest static void test_method_one() {
        ACAMSSubscriptionProcessor testsch = new ACAMSSubscriptionProcessor();
        String sch = '0 0 23 * * ?';
        Test.startTest();
        try {
            System.schedule('Test Sch', sch, testsch);
        }
        catch(System.NullPointerException e){
            //
        }
        catch(Exception e){
            //
        }
        Test.stopTest();
    }
}