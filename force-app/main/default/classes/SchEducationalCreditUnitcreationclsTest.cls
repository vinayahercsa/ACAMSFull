@isTest
public class SchEducationalCreditUnitcreationclsTest {
    public SchEducationalCreditUnitcreationclsTest() {

    }

    @isTest
    public static void testScheduleJob(){
        SchEducationalCreditUnitcreationcls scheJob = new SchEducationalCreditUnitcreationcls();
        SchedulableContext testSC = null;
        scheJob.execute(testSC);
    }
}