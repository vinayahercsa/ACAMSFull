/**
 * @ Descritpion: display asset view when user navigate to the business account detail page
 * @ source: E2E new feature - asset functionality row 27
 * @ Date: July 12, 2020 Rui
 */
public class FSIT_AssetViewBusinessAccountCtr {

    // define assign asset map, order id, asset list
    public Map<String, List<Asset>> assignedAssetMap {get; set;} 

    // define unassign asset mpa, <order id, asset list>
    public Map<String, List<Asset>> unassignedAssetMap {get; set;}
    // define Authorized asset Map, <order id,asset list>
    public Map<string, List<Asset>> AuthorizedAssetMap {get;set;}
    // define Unpaid Asset Map, <order id,asset list>
    public Map<string,list<asset>> UnpaidAssetMap {get;set;}

    // define sku asset map, <sku,asset list>
    public Map<String, List<Asset>> allAssetMap {get; set;} 

    // define search text
    public String searchText {get; set{searchText = value;}}
    // define Assignee
    public String Assignee {get;set;}
    public List<Asset> lstast {get; set;}
    public Boolean showAssetSection {get;set;}

    // define select asset type
    public String assetTypes {get; set;}

    // record id
    public Id sobjectId {get;set;}

    // product id
    public Id productId {get;set;}

    // set all asset list
    public List<Asset> assetList {get; set;}

    // set sku name list
    public Set<String> skuSet {get; set;}

    // set product Id set
    public Map<Id,List<Asset>> productIdAssetsMap {get; set;}

    // sku - product id mapping
    public Map<String, Id> skuProductIdMap {get; set;}

    // order Id, Asset list mapping - for filter by order in business account order detail page
    public Map<String, List<Asset>> orderAssetListMap {get; set;}

    // order Id, Name mapping
    public Map<String,String> orderIdNameMap {get; set;}
    public Map<String,String> orderStatusMap {get; set;}
    public Map<String,String> orderDateMap {get; set;}
    public Map<String,Decimal> orderAmountMap {get;set;}
    public Map<String,Decimal> orderAssetSize {get; set;}
    public Map<string,string> OpportunityNameMap {get;set;}
    public Map<string,string> OrderPaidofMap {get;set;}

    // cc order id list
    public Set<String> ccOrderIdSet {get; set;}

    // set  size maps
    public Map<String, Decimal> allAssetSize {get; set;}
    public Map<String, String> productNameSize {get; set;}
    public Map<String, Decimal> assignedAssetSize {get; set;}
    public Map<String, Decimal> unassignedAssetSize {get; set;}
    public Map<string, Decimal> AuthorizedAssetSize {get;set;}
    public Map<string, Decimal> UnpaidAssetSize {get;set;}

    // set val for total asset #
    public Decimal totalAssets {get; set;}

    // displaying asset list
    public List<Asset> displayAssetList {get; set;}

    public FSIT_AssetViewBusinessAccountCtr(ApexPages.StandardController stdController) {
        sobjectId = stdController.getId();
    }

    public FSIT_AssetViewBusinessAccountCtr() {
        lstast = new List<Asset>();
        showAssetSection = false;
        
        if(String.isBlank(sobjectId) && !String.isBlank(ApexPages.currentPage().getParameters().get('recordId'))){
            sobjectId = ApexPages.currentPage().getParameters().get('recordId');
        }
        
        if(String.isBlank(productId) && !String.isBlank(ApexPages.currentPage().getParameters().get('pdId'))){
            productId = ApexPages.currentPage().getParameters().get('pdId');
        }

        if(String.isBlank(searchText) && !String.isBlank(ApexPages.currentPage().getParameters().get('searchText'))){
            searchText = ApexPages.currentPage().getParameters().get('searchText');
        }
    }

    public void dataInit(){
        // init map
        skuProductIdMap = new Map<String, Id>();
        assignedAssetMap = new Map<String, List<Asset>>();
        system.debug('enter::'+assignedAssetMap);
        assignedAssetSize = new Map<String, Decimal>();
        unassignedAssetMap = new Map<String, List<Asset>>();
        AuthorizedAssetMap = new Map<String, List<Asset>>();
        UnpaidAssetMap = new Map<string, List<Asset>>();

        allAssetMap = new Map<String, List<Asset>>();
        allAssetSize = new Map<String, Decimal>();
        productNameSize = new Map<String,String>();
        assignedAssetSize = new Map<String, Decimal>();
        unassignedAssetSize = new Map<String, Decimal>();
        AuthorizedAssetSize = new Map<String, Decimal>();
        UnpaidAssetSize = new Map<string, Decimal>();
        

        skuSet = new Set<String>();
        totalAssets = 0;
        displayAssetList = new List<Asset>();

        productIdAssetsMap = new Map<Id,List<Asset>>();

        // order Asset mapping
        orderAssetListMap = new Map<String,List<Asset>>();
        orderIdNameMap = new Map<String,String>();
        ccOrderIdSet = new Set<String>();
        orderStatusMap = new Map<String,String>();
        orderDateMap = new Map<String,String>();
        orderAmountMap = new Map<String,Decimal>();
        orderAssetSize = new Map<String,Decimal>();
        OpportunityNameMap = new Map<string,string>();
        OrderPaidofMap = new Map<string,string>();
        if(!String.isBlank(sobjectId)){
            assetList = [
                SELECT Id, Name,CC_Product__c,Payment_Status__c,CancelDate__c,Cancel_Reason__c,Paid_Cert1__c,Paid_Cert__c,CC_Product__r.ccrz__SKU__c,AccountId,Status__c,Assignee__r.name,CC_Order__c,CC_Order__r.Name,CC_Product__r.Name,Product_Level_1__c,
                Product_Level_2__c,Product_Level_3__c,CurrentExpirationDate__c,Effective_Date__c,InstallDate,CC_Order__r.ccrz__Name__c,CC_Order__r.ccrz__OrderStatus__c,CC_Order__r.ccrz__OrderDate__c,
                CC_Order__r.ccrz__TotalAmount__c,CC_Order__r.Opportunity__c,CC_Order__r.Opportunity__r.name,Contact.Name,CC_Order__r.Paid_in_Full_Date__c,CC_Order__r.CC_Order_Created_Hour__c
                FROM Asset 
                WHERE AccountId =: sobjectId AND CancelDate__c = null AND  CC_Order__c != NULL AND (Product_Level_2__c != NULL OR Product_Level_1__c != NULL OR Product_Level_3__c != NULL) ORDER BY CurrentExpirationDate__c
                
                ];
            // comment by koti FSA-5809 --LIMIT 1000
        }
        else{
            assetList = [SELECT Id, Name,Assignee__c,Payment_Status__c,Cancel_Reason__c,Paid_Cert1__c,Paid_Cert__c,CC_Product__r.ccrz__SKU__c,InstallDate,Assignee__r.Name,Status__c,CC_Product__r.Name,CC_Order__r.Name,CC_Order__c,Product_Level_1__c,
                        Product_Level_2__c,Product_Level_3__c,CurrentExpirationDate__c,Effective_Date__c,CancelDate__c,CC_Order__r.ccrz__Name__c,CC_Order__r.ccrz__OrderStatus__c,CC_Order__r.ccrz__OrderDate__c,
                        CC_Order__r.ccrz__TotalAmount__c,CC_Order__r.Opportunity__c,CC_Order__r.Opportunity__r.name,Contact.Name,CC_Order__r.Paid_in_Full_Date__c,CC_Order__r.CC_Order_Created_Hour__c
                        FROM Asset
                        WHERE CancelDate__c = null AND CC_Order__c != NULL AND (Product_Level_2__c != NULL OR Product_Level_1__c != NULL OR Product_Level_3__c != NULL) ORDER BY CurrentExpirationDate__c
                        
                        ];
            // comment by koti FSA-5809  LIMIT 1000
                        
        }

        for(Asset ast : assetList){
            if(ast.CC_Product__c != null && ast.CC_Product__r.ccrz__SKU__c != null){
                if(!skuSet.contains(String.valueOf(ast.CC_Product__r.ccrz__SKU__c))){
                    skuSet.add(String.valueOf(ast.CC_Product__r.ccrz__SKU__c));
                } 
            }
        }

        if(assetList != null && assetList.size() > 0){
            // init all asset mapping
            for(String s : skuSet){
                allAssetMap.put(s, new List<Asset>());
                assignedAssetMap.put(s, new List<Asset>());
                unassignedAssetMap.put(s, new List<Asset>());
                AuthorizedAssetMap.put(s, new List<Asset>());
                UnpaidAssetMap.put(s, new List<Asset>());
                System.debug('Enetr::'+assignedAssetMap.get(s));
            }

            for(Asset ast : assetList){
                if(ast.CC_Product__c != null && ast.CC_Product__r.ccrz__SKU__c != null && allAssetMap.keySet() != null && allAssetMap.keySet().contains(String.valueOf(ast.CC_Product__r.ccrz__SKU__c))){
                    allAssetMap.get(String.valueOf(ast.CC_Product__r.ccrz__SKU__c)).add(ast);
                }
                if(ast.CC_Product__c != null && ast.CC_Product__r.ccrz__SKU__c != null){
                    skuProductIdMap.put(ast.CC_Product__r.ccrz__SKU__c,ast.CC_Product__c);
                }
            }

            

            //init assigned asset map
            for(Asset ast : assetList){
                if(ast.Assignee__c != null){
                    system.debug('Assignee:'+ ast.Assignee__c);
                    if(ast.CC_Product__c != null && ast.CC_Product__r.ccrz__SKU__c != null && assignedAssetMap.keySet() != null  && assignedAssetMap.keySet().contains(ast.CC_Product__r.ccrz__SKU__c) && ast.Cancel_Reason__c == Null
                      && ast.Status__c == 'Active' && (ast.Payment_Status__c == 'Authorized'|| ast.Payment_Status__c=='Completed') ){
                         // ast.Status__c == 'Active' && (ast.Payment_Status__c == 'Authorized'|| ast.Payment_Status__c=='Completed') 
                        assignedAssetMap.get(String.valueOf(ast.CC_Product__r.ccrz__SKU__c)).add(ast);
                          system.debug('Enetr::'+assignedAssetMap);
                    }
                }
            }

            if(assignedAssetMap != null && assignedAssetMap.size() > 0){
                for(String s : assignedAssetMap.keySet()){
                    assignedAssetSize.put(s, assignedAssetMap.get(s).size());
                    system.debug('AssignedAssetsize:'+ assignedAssetSize);
                }
            }

            //init unassigned asset map
            for(Asset ast : assetList){
                if(ast.Assignee__c == null && ast.CC_Product__c != null){
                    //system.debug('Assignee'+ast.Assignee__c);
                    if(ast.CC_Product__c != null && ast.CC_Product__r.ccrz__SKU__c != null && unassignedAssetMap.keySet() != null  && unassignedAssetMap.keySet().contains(ast.CC_Product__r.ccrz__SKU__c) 
                       && ast.Status__c == 'Active' && (ast.Payment_Status__c == 'Authorized'|| ast.Payment_Status__c=='Completed') && ast.Cancel_Reason__c == Null){
 
                      unassignedAssetMap.get(String.valueOf(ast.CC_Product__r.ccrz__SKU__c)).add(ast);
                        //ast.Status__c == 'Active' && (ast.Payment_Status__c == 'Authorized'|| ast.Payment_Status__c=='Completed') && ast.Cancel_Reason__c == Null
                      system.debug('UnassignedAssetmap'+unassignedAssetMap);
                    }
                }
            }
            
           
           
            if(unassignedAssetMap != null && unassignedAssetMap.size() > 0){
                for(String s : unassignedAssetMap.keySet()){
                    if(unassignedAssetMap.get(s) != null){
                        unassignedAssetSize.put(s, unassignedAssetMap.get(s).size());
                        system.debug('UnassignedAssetSize'+unassignedAssetSize);
                    }
                    
                    
                   
            }
            }
            
             if(allAssetMap != null && allAssetMap.size() > 0){
                for(String s : allAssetMap.keySet()){
                    if(allAssetMap.get(s) != null){
                        allAssetSize.put(s,assignedAssetMap.get(s).size()+unassignedAssetMap.get(s).size());
                        productNameSize.put(s,allAssetMap.get(s)[0].CC_Product__r.Name);
                         //totalAssets += allAssetMap.get(s).size();
                         totalAssets += assignedAssetMap.get(s).size()+unassignedAssetMap.get(s).size();
                    }
                }
            }

           // totalAssets= assignedAssetMap.get(s).size()+unassignedAssetMap.get(s).size()
            // Init Authorized asset Map
            for(Asset ast : assetList){
                if(ast.CC_Product__c != null){
                    if(ast.CC_Product__c != null && ast.CC_Product__r.ccrz__SKU__c != null && AuthorizedAssetMap.keySet() != null && AuthorizedAssetMap.keySet().contains(ast.CC_Product__r.ccrz__SKU__c) && 
                      ast.Payment_Status__c == 'Authorized' && ast.Status__c == 'Active' && ast.CancelDate__c == Null){
                          authorizedAssetmap.get(string.valueOf(ast.CC_Product__r.ccrz__SKU__c)).add(ast);
                        
                    }
                }
            }
            if(authorizedAssetmap != null && authorizedAssetmap.size() > 0){
                for(String s : authorizedAssetmap.keySet()){
                    if(authorizedAssetmap.get(s) != null){
                        AuthorizedAssetSize.put(s, authorizedAssetmap.get(s).size());
                    }
                }
            }
            // Init Unpaid Asset Map
            for(Asset ast : assetList){ //FSA-2906 - yousef suggested to add payment status not completed for inpaid assets 
                if(ast.CC_Product__c != null){
                    if(ast.CC_Product__c != null && ast.CC_Product__r.ccrz__SKU__c != null && UnpaidAssetMap.keySet() != null && UnpaidAssetMap.keySet().contains(ast.CC_Product__r.ccrz__SKU__c) && ast.Paid_Cert1__c == False && ast.Status__c != 'Active' && ast.Payment_Status__c != 'Completed' && ast.CancelDate__c == Null && ast.Cancel_Reason__c == null){
                        UnpaidAssetMap.get(string.valueOf(ast.CC_Product__r.ccrz__SKU__c)).add(ast);
                        
                    }
                }
            }
            if(UnpaidAssetMap != null && UnpaidAssetMap.size() > 0){
                for(String s : UnpaidAssetMap.keySet()){
                    if(UnpaidAssetMap.get(s) != null){
                        UnpaidAssetSize.put(s, UnpaidAssetMap.get(s).size());
                    }
                }
            }

            if(sobjectId != null && !String.isBlank(productId)){
                displayAssetList = [
                    SELECT Id, Name,CC_Product__c,Effective_Date__c,Payment_Status__c,Paid_Cert1__c,Paid_Cert__c,CC_Product__r.ccrz__SKU__c,Status__c,Assignee__r.name,AccountId,CC_Order__c,CC_Product__r.Name,CreatedDate,Product_Level_1__c,Product_Level_2__c,
                    Product_Level_3__c,CurrentExpirationDate__c,InstallDate,CC_Order__r.ccrz__Name__c,CC_Order__r.ccrz__OrderStatus__c,CC_Order__r.ccrz__OrderDate__c,
                    CC_Order__r.ccrz__TotalAmount__c,Cancel_Reason__c,CC_Order__r.Opportunity__c,CC_Order__r.Opportunity__r.name,Contact.Name,CC_Order__r.Paid_in_Full_Date__c,CC_Order__r.CC_Order_Created_Hour__c
                    FROM Asset 
                    WHERE AccountId =: sobjectId AND CC_Product__c =:productId AND CancelDate__c = null AND (Product_Level_2__c != NULL OR Product_Level_1__c != NULL OR Product_Level_3__c != NULL)  AND CC_Order__c != NULL  
                    ORDER BY CurrentExpirationDate__c 
                     LIMIT 1000
                ];
            }

            else if(!String.isBlank(productId)){
                displayAssetList = [
                    SELECT Id,AccountId, Name,Effective_Date__c,Payment_Status__c,Paid_Cert1__c,Paid_Cert__c,CC_Product__c,CC_Product__r.ccrz__SKU__c,Status__c,Assignee__r.name,CC_Order__c,CC_Product__r.Name,CreatedDate,Product_Level_1__c,Product_Level_2__c,
                    Product_Level_3__c,CurrentExpirationDate__c,InstallDate,CC_Order__r.ccrz__Name__c,CC_Order__r.ccrz__OrderStatus__c,CC_Order__r.ccrz__OrderDate__c,
                    CC_Order__r.ccrz__TotalAmount__c,Cancel_Reason__c,CC_Order__r.Opportunity__c,CC_Order__r.Opportunity__r.name,Contact.Name,CC_Order__r.Paid_in_Full_Date__c,CC_Order__r.CC_Order_Created_Hour__c
                    FROM Asset 
                    WHERE AccountId =: sobjectId AND CC_Product__c =:productId AND CancelDate__c = null AND (Product_Level_2__c != NULL OR Product_Level_1__c != NULL OR Product_Level_3__c != NULL)  AND CC_Order__c != NULL  AND CC_Product__c =: productId 
                    ORDER BY CurrentExpirationDate__c 
                    LIMIT 1000
                ];
            }
            
            this.buildProductOrderAssetList();
        }

        
    }

    /**
     * @Description: build map cc order Id set,<-> cc order name, build map order id set <-> asset list
     * @ source: E2E new feature - asset functionality row 27.
     * @ Date: July 16, 2020 - Rui
     */
    public void buildProductOrderAssetList(){
        
        if(!String.isBlank(productId)){
            for(Asset ast : assetList){
                if(ast.CC_Product__c != null && ast.CC_Product__c == productId && !String.isBlank(ast.CC_Order__c)){
                   if(!orderAssetListMap.containsKey(ast.CC_Order__c)){
                        orderAssetListMap.put(ast.CC_Order__c, new List<Asset>{ast});
                   }
                   else{
                       List<Asset> astList = orderAssetListMap.get(ast.CC_Order__c);
                       astList.add(ast);
                       orderAssetListMap.put(ast.CC_Order__c,astList);
                   }
                    system.debug('Enetr::'+assignedAssetMap);
                    system.debug('Enetr::'+ast.CC_Order__c);
                    system.debug('Paid Off Date::'+ast.CC_Order__r.Paid_in_Full_Date__c);
                    if(ast.CC_Order__r.ccrz__Name__c != Null){
                   orderIdNameMap.put(ast.CC_Order__c, ast.CC_Order__r.Name);
                    }else{
                         orderIdNameMap.put(ast.CC_Order__c, ' ');
                    }
                    if(ast.CC_Order__r.Opportunity__r.name != Null){
                   OpportunityNameMap.put(ast.CC_Order__c, ast.CC_Order__r.Opportunity__r.name);
                    }
                    else{
                       OpportunityNameMap.put(ast.CC_Order__c, ' '); 
                    }
                    if(ast.CC_Order__r.ccrz__OrderStatus__c != Null){
                   orderStatusMap.put(ast.CC_Order__c, ast.CC_Order__r.ccrz__OrderStatus__c);
                    }
                    else{
                       orderStatusMap.put(ast.CC_Order__c, ' '); 
                    }
                   orderAmountMap.put(ast.CC_Order__c, ast.CC_Order__r.ccrz__TotalAmount__c);
                    if(ast.CC_Order__r.CC_Order_Created_Hour__c != Null){
                        orderDateMap.put(ast.CC_Order__c, String.valueOf(ast.CC_Order__r.CC_Order_Created_Hour__c));
                    }else{
                        orderDateMap.put(ast.CC_Order__c, ' ');
                    }
                    if(ast.CC_Order__r.Paid_in_Full_Date__c != Null){
                        OrderPaidofMap.put(ast.CC_Order__c, String.valueof(ast.CC_Order__r.Paid_in_Full_Date__c));
                    }else{
                        OrderPaidofMap.put(ast.CC_Order__c, ' ');
                    }
                   
                   orderAssetSize.put(ast.CC_Order__c,orderAssetListMap.get(ast.CC_Order__c).size());
                   assignedAssetSize.put(ast.CC_Order__c, assignedAssetMap.get(ast.CC_Product__r.ccrz__SKU__c).size());
                   unassignedAssetSize.put(ast.CC_Order__c, unassignedAssetMap.get(ast.CC_Product__r.ccrz__SKU__c).size()); 
                }
            }
            
            
            ccOrderIdSet = orderAssetListMap.keySet();
        }
    }

    public void runSearch(){
        /*
        displayAssetList = [
                SELECT Id, Name,CC_Product__c,CC_Product__r.ccrz__SKU__c,Status__c,Assignee__c,CC_Order__c,CC_Product__r.Name,CreatedDate  
                FROM Asset 
                WHERE CC_Product__c =: skuProductIdMap.get(searchText) AND CC_Order__c =: sobjectId 
                ORDER BY CreatedDate
            ];
            */
            
           
            if(assetTypes == 'Assigned_Asset'){
                displayAssetList = assignedAssetMap.get(searchText);
                System.debug(searchText+'sssssssssize11111:'+displayAssetList.size());
            }

            else if(assetTypes == 'Unassigned_Asset'){
                displayAssetList = unassignedAssetMap.get(searchText);
                System.debug('lllllllllllllllll:'+displayAssetList.size());
            }
        else if(assetTypes == 'Authorized_Asset'){
                displayAssetList = authorizedAssetmap.get(searchText);
                System.debug('lllllllllllllllll:'+displayAssetList.size());
            }
        else if(assetTypes == 'Unpaid_Asset'){
                displayAssetList = UnpaidAssetMap.get(searchText);
                System.debug('lllllllllllllllll:'+displayAssetList.size());
            }

            else if(String.isBlank(assetTypes) && !String.isBlank(productId)){
                displayAssetList = [
                    SELECT Id, Name,Effective_Date__c,Payment_Status__c,Paid_Cert1__c,Paid_Cert__c,CC_Product__c,CC_Product__r.ccrz__SKU__c,Status__c,Assignee__c,AccountId,CC_Order__c,CC_Product__r.Name,CreatedDate,Product_Level_1__c,Product_Level_2__c,
                    Product_Level_3__c,CurrentExpirationDate__c,Assignee__r.Name,Cancel_Reason__c,InstallDate,CC_Order__r.ccrz__Name__c,Contact.Name,CC_Order__r.ccrz__OrderStatus__c,CC_Order__r.ccrz__OrderDate__c,
                    CC_Order__r.ccrz__TotalAmount__c 
                    FROM Asset 
                    WHERE AccountId =: sobjectId AND CC_Product__c =:productId AND CancelDate__c = null AND (Product_Level_2__c != NULL OR Product_Level_1__c != NULL OR Product_Level_3__c != NULL)  AND CC_Order__c != NULL  
                    ORDER BY CurrentExpirationDate__c 
                    LIMIT 1000
                ];
            }
  
    }
    Public void getAssigneeRecords(){
        showAssetSection = true;
        lstast=[select name,Assignee__r.name,CC_Product__r.Name,Effective_Date__c,CurrentExpirationDate__c,Payment_Status__c,Paid_Cert__c
                         from Asset where Assignee__c != Null AND Assignee__r.name =: Assignee AND CC_Product__c =:productId AND AccountId =: sobjectId limit 1000];
        system.debug('Assignee Records:' + lstast);
    }
    

    
}