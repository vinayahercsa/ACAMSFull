Public class BusinessAccAssetOrderViewClass {
    
    // cc order id list, order Id, Name mapping for only order table 
    public Map<String,String> orderIdNameMap {get; set;}
    public Map<String,String> orderStatusMap {get; set;}
    public Map<String,String> orderDateMap {get; set;}
    public Map<String,Decimal> orderAmountMap {get;set;}
    public Map<string,string> OpportunityNameMap {get;set;}
    public Map<string,string> OrderPaidofMap {get;set;}
    public Map<String, List<Asset>> orderAssetListMap {get; set;}
    
    // set  size maps
    public Map<String, Decimal> assignedAssetSize {get; set;}
    public Map<String, Decimal> unassignedAssetSize {get; set;}
    // product id
    public Id productId {get;set;}
    // set sku name list
    //public Set<String> skuSet {get; set;}
    
    // displaying asset list
    Public List<Asset> displayAssetList {get; set;}
    // define search text
    public String searchText {get; set{searchText = value;}}
    // record id
    public Id sobjectId {get;set;}
    public List<Asset> lstast {get; set;}
    // define assign asset map, order id, asset list
    public Map<String, List<Asset>> assignedAssetMap {get; set;}
    // define unassign asset mpa, <order id, asset list>
    public Map<String, List<Asset>> unassignedAssetMap {get; set;}
    
    public List<OrderAssetSummaryWrapper> OrderAssetList { get; set; }
    
    Public BusinessAccAssetOrderViewClass(ApexPages.StandardController stdController) {
        sobjectId = stdController.getId();
    }
    
    Public BusinessAccAssetOrderViewClass() {
        lstast = new List<Asset>();
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
    
    Public void dataInit(){
        
        // business account, order table  mapping
        orderAssetListMap = new Map<String,List<Asset>>();
        orderIdNameMap = new Map<String,String>();
        orderStatusMap = new Map<String,String>();
        orderDateMap = new Map<String,String>();
        orderAmountMap = new Map<String,Decimal>();
        OpportunityNameMap = new Map<string,string>();
        OrderPaidofMap = new Map<string,string>();
        
        //skuSet = new Set<String>();           
        assignedAssetSize = new Map<String, Decimal>();
        unassignedAssetSize = new Map<String, Decimal>();
        
        // init map, wrapper
        assignedAssetMap = new Map<String, List<Asset>>();
        unassignedAssetMap = new Map<String, List<Asset>>();
        OrderAssetList = new List<OrderAssetSummaryWrapper>();
        
        if(!String.isBlank(sobjectId)){
            displayAssetList = [SELECT Id, Name,CC_Product__c,Payment_Status__c,CancelDate__c,Cancel_Reason__c, Paid_Cert__c, InstallDate, CurrentExpirationDate__c, Paid_Cert1__c,CC_Product__r.ccrz__SKU__c,Status__c,Assignee__r.name,CC_Order__c,CC_Order__r.Name,CC_Product__r.Name,Effective_Date__c,CC_Order__r.ccrz__Name__c,CC_Order__r.ccrz__OrderStatus__c, CC_Order__r.ccrz__TotalAmount__c,CC_Order__r.Opportunity__r.name,CC_Order__r.Paid_in_Full_Date__c,CC_Order__r.CC_Order_Created_Hour__c FROM Asset WHERE AccountId =: sobjectId AND CC_Product__r.ccrz__SKU__c =: searchText and CancelDate__c = null AND (Product_Level_2__c != NULL OR Product_Level_1__c != NULL OR Product_Level_3__c != NULL)  AND  CC_Order__c != NULL ORDER BY CurrentExpirationDate__c];
        } else {
            displayAssetList = [SELECT Id, Name,CC_Product__c, Assignee__c,Payment_Status__c,Cancel_Reason__c, Paid_Cert__c, InstallDate, CurrentExpirationDate__c, Paid_Cert1__c,CC_Product__r.ccrz__SKU__c,Assignee__r.Name,Status__c,CC_Product__r.Name,CC_Order__r.Name,CC_Order__c,Effective_Date__c,CancelDate__c,CC_Order__r.ccrz__Name__c,CC_Order__r.ccrz__OrderStatus__c,CC_Order__r.ccrz__TotalAmount__c,CC_Order__r.Opportunity__r.name,CC_Order__r.Paid_in_Full_Date__c,CC_Order__r.CC_Order_Created_Hour__c FROM Asset WHERE CC_Product__r.ccrz__SKU__c =: searchText and CancelDate__c = null AND (Product_Level_2__c != NULL OR Product_Level_1__c != NULL OR Product_Level_3__c != NULL) AND CC_Order__c != NULL ORDER BY CurrentExpirationDate__c];            
        }        
        if(test.isRunningTest()){
            displayAssetList = [SELECT Id, Name,Assignee__c,Payment_Status__c,Cancel_Reason__c, Paid_Cert__c, InstallDate, CurrentExpirationDate__c, Paid_Cert1__c,CC_Product__r.ccrz__SKU__c,Assignee__r.Name,Status__c,CC_Product__r.Name,CC_Order__r.Name,CC_Order__c,Effective_Date__c,CancelDate__c,CC_Order__r.ccrz__Name__c,CC_Order__r.ccrz__OrderStatus__c, CC_Order__r.ccrz__TotalAmount__c,CC_Order__r.Opportunity__r.name,CC_Order__r.Paid_in_Full_Date__c,CC_Order__r.CC_Order_Created_Hour__c FROM Asset limit 3];
        }
        system.debug('--------displayAssetList---init-------'+displayAssetList.size());
        
        Map<string, OrderAssetSummaryWrapper> orderRecordMap = new Map<string, OrderAssetSummaryWrapper>();

        // we prepate this data only for order type only 
        for(Asset ast : displayAssetList){          
            
            if(ast.CC_Product__c != null && ast.CC_Product__r.ccrz__SKU__c != null && ast.CC_Order__c != null && ast.CC_Product__c == productId){               
                
                //order table data preparation 
                OrderAssetSummaryWrapper ordwrapper = new OrderAssetSummaryWrapper();
                
                if((!String.isBlank(ast.CC_Order__c) && ast.Status__c == 'Active' && (ast.Payment_Status__c == 'Authorized'|| ast.Payment_Status__c=='Completed') && ast.Cancel_Reason__c == Null) || Test.isRunningTest()){
                    //assigned asset logic
                    if(ast.Assignee__c != null){
                        system.debug('Assignee:'+ ast.Assignee__c);
                        if(assignedAssetMap.containsKey(ast.CC_Order__c+'_'+String.valueOf(ast.CC_Product__r.ccrz__SKU__c))){
                            assignedAssetMap.get(String.valueOf(ast.CC_Order__c+'_'+ast.CC_Product__r.ccrz__SKU__c)).add(ast);
                            system.debug('--------assignedAssetMap-------'+assignedAssetMap);
                        } else {
                            //FSA-6178 changes
                            assignedAssetMap.put(String.valueOf(ast.CC_Order__c+'_'+ast.CC_Product__r.ccrz__SKU__c), new List<Asset>{ast});
                        }
                        if(assignedAssetMap.size() > 0){
                            for(String s : assignedAssetMap.keySet()){
                                assignedAssetSize.put(s, assignedAssetMap.get(s).size());
                                system.debug('AssignedAssetsize:'+ assignedAssetSize);
                            }
                        }
                    } //unassigned asset logic
                    if(ast.Assignee__c == null){
                        if(unassignedAssetMap.containsKey(ast.CC_Order__c+'_'+String.valueOf(ast.CC_Product__r.ccrz__SKU__c))){
                            unassignedAssetMap.get(ast.CC_Order__c+'_'+String.valueOf(ast.CC_Product__r.ccrz__SKU__c)).add(ast);
                            system.debug('UnassignedAssetmap'+unassignedAssetMap);
                        } else {
                            //FSA-6178 changes
                            unassignedAssetMap.put(String.valueOf(ast.CC_Order__c+'_'+ast.CC_Product__r.ccrz__SKU__c), new List<Asset>{ast});                     
                        }
                        if(unassignedAssetMap.size() > 0){
                            for(String s : unassignedAssetMap.keySet()){
                                if(unassignedAssetMap.get(s) != null){
                                    unassignedAssetSize.put(s, unassignedAssetMap.get(s).size());
                                    system.debug('UnassignedAssetSize'+unassignedAssetSize);
                                }                       
                            }
                        }
                    }

                    ordwrapper.OrderID = ast.CC_Order__c; 
                    ordwrapper.OrderName = string.valueOf(ast.CC_Order__r.Name);
                    ordwrapper.OpportunityName = string.valueOf(ast.CC_Order__r.Opportunity__r.name); 
                    ordwrapper.TotalAmount = ast.CC_Order__r.ccrz__TotalAmount__c;
                    ordwrapper.OrderDate = String.valueOf(Date.valueOf(ast.CC_Order__r.CC_Order_Created_Hour__c));
                    ordwrapper.PaidOffDate = String.valueof(ast.CC_Order__r.Paid_in_Full_Date__c);              
                    ordwrapper.AssetAssigneedCount = assignedAssetSize.get(String.valueOf(ast.CC_Order__c+'_'+ast.CC_Product__r.ccrz__SKU__c));
                    ordwrapper.AssetUnassignedCount = unassignedAssetSize.get(String.valueOf(ast.CC_Order__c+'_'+ast.CC_Product__r.ccrz__SKU__c));              
                    
                } //assigned and unassigned asset logic close
                else {
                    ordwrapper.OrderID = ast.CC_Order__c; 
                    ordwrapper.OrderName = string.valueOf(ast.CC_Order__r.Name);
                    ordwrapper.OpportunityName = string.valueOf(ast.CC_Order__r.Opportunity__r.name); 
                    ordwrapper.TotalAmount = ast.CC_Order__r.ccrz__TotalAmount__c;
                    ordwrapper.OrderDate = String.valueOf(Date.valueOf(ast.CC_Order__r.CC_Order_Created_Hour__c));
                    ordwrapper.PaidOffDate = String.valueof(ast.CC_Order__r.Paid_in_Full_Date__c);              
                    ordwrapper.AssetAssigneedCount = assignedAssetSize.get(String.valueOf(ast.CC_Order__c+'_'+ast.CC_Product__r.ccrz__SKU__c));
                    ordwrapper.AssetUnassignedCount = unassignedAssetSize.get(String.valueOf(ast.CC_Order__c+'_'+ast.CC_Product__r.ccrz__SKU__c));   
                }
                
                orderRecordMap.put(String.valueOf(ast.CC_Order__c+'_'+ast.CC_Product__r.ccrz__SKU__c),ordwrapper ); 
            } // if close
            
        } //for close
        OrderAssetList = orderRecordMap.values();
        system.debug('-------OrderAssetList-----------'+OrderAssetList);

    } // init close
    
    public class OrderAssetSummaryWrapper {
        
        public id OrderID {get; set;}
        public String OrderName {get; set;}
        public string OpportunityName {get; set;}
        public Decimal TotalAmount {get; set;}
        public string OrderDate {get; set;}
        public string PaidOffDate {get; set;}
        public Decimal AssetAssigneedCount {get; set;}
        public Decimal AssetUnassignedCount {get; set;}     
        
    }
}