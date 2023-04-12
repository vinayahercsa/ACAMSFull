@IsTest
public class DMLUtilityTest {
    @IsTest
        public static void createAccount(){
    
        List<Account> acList = new List<Account>{
            new Account(FirstName='initialFirstName', LastName='LastName',Work_Email__pc =String.valueOf(Date.today())+'@test.com')
        };
        insert acList;
        

        for(Account a : acList){
            acList[0].FirstName = 'changedFirstName';
        }
        update acList;
        
        System.assertEquals('changedFirstName', acList[0].FirstName);
   
            
        for(Account a : acList){
            acList[0].FirstName = 'changed_again_FirstName';
        }
        update acList;
        
        System.assertEquals('changed_again_FirstName', acList[0].FirstName);
            
        DMLUtility.InsertSObjects(acList);
        DMLUtility.UpdateSObjects(acList);
        DMLUtility.UpserSObjects(acList);
        
    }
}