// FSA-1826
public class GlobalAccountManager {
    @future
    public static void UpdateManagerOnAccount(Map<string,id> mgaMap){
        List<Account> listAccUpdate = new List<Account>();
        List<Account> listAcc = [select id, Company_Name_Inactive__c from account where Company_Name_Inactive__c =: mgaMap.keyset()];
          if(!listAcc.isEmpty()){
            for(Account Acc : listAcc){
                 Acc.Global_Account_Manager__c = mgaMap.get(Acc.Company_Name_Inactive__c);
                 listAccUpdate.add(Acc);
            }
        }
        
        if(!listAccUpdate.isEmpty()){
            update listAccUpdate;
        }
    }
}