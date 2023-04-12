public class SAPSalesforceIntegrationScheduler implements Schedulable {

    public void execute(SchedulableContext ctx){
        
        Database.executeBatch(new SAPSalesforceIntegrationDemoBatch());
    }
}