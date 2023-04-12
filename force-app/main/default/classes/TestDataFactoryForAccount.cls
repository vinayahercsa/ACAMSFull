public class TestDataFactoryForAccount {
    public static List<Account> insertPersonAccount(Integer numberOfAccounts,Boolean isInsert){
        CCACAMSTestUtil testUtil = new CCACAMSTestUtil();
        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        List<Account> pAccountList = new List<Account>();
        for(integer i=0; i<=numberOfAccounts; i++){
            Account acc= new Account(
                RecordTypeID=recordTypeId ,
                FirstName='Test FName',
                LastName='Test LName'+numberOfAccounts,
                Work_Email__pc = 'test@yahoo.com',
                PersonMailingStreet='test@yahoo.com',
                PersonMailingPostalCode='12345',
                PersonMailingCity='SFO',
                PersonEmail='test@yahoo.com'
            );
            pAccountList.add(acc);
        }
        
        if(isInsert){
            insert pAccountList;
        }
        return pAccountList;
        
    }
    public static ccrz__E_Order__c insertOrder(){
        ccrz__E_Order__c order = new ccrz__E_Order__c(
            Paid_in_Full_Date__c = system.today() - 15
        );
        return order;
    }
    public static Asset insertAsset(){
        Asset asset = new Asset(
            Name = 'test1'
        );
            return asset;
    }
    public static Opportunity insertOppty(){
        Opportunity oppty = new Opportunity(
            Name = 'test1'
        );
            return oppty;
    }
    
}