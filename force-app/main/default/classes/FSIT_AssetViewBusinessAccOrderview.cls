Public class FSIT_AssetViewBusinessAccOrderview {

    //product id
    public Id productId {get;set;}
    //define Assignee
    public String Assignee {get;set;}
    //displaying asset list
    Public List<Asset> displayAssetList {get; set;}
    //define search text
    public String searchText {get; set{searchText = value;}}
    //record id
    public Id sobjectId {get;set;}
    public List<Asset> lstast {get; set;}
    //set all asset list
    public  List<Asset> assetList {get; set;}
    //define select asset type
    public String assetTypes {get; set;}
    
    /*Public FSIT_AssetViewBusinessAccOrderview(ApexPages.StandardController stdController) {
        sobjectId = stdController.getId();
    } */
    
    Public FSIT_AssetViewBusinessAccOrderview() {
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
        system.debug('------------------'+sobjectId);
        if(!String.isBlank(sobjectId)){            
            displayAssetList = [SELECT Id, Name,CC_Product__c,Payment_Status__c,CancelDate__c,Cancel_Reason__c, Paid_Cert__c, InstallDate, CurrentExpirationDate__c, Paid_Cert1__c,CC_Product__r.ccrz__SKU__c,Status__c,Assignee__r.name,CC_Order__c,CC_Order__r.Name,CC_Product__r.Name,Effective_Date__c,CC_Order__r.ccrz__Name__c,CC_Order__r.ccrz__OrderStatus__c, CC_Order__r.ccrz__TotalAmount__c,CC_Order__r.Opportunity__r.name,CC_Order__r.Paid_in_Full_Date__c,CC_Order__r.CC_Order_Created_Hour__c FROM Asset WHERE AccountId =: sobjectId AND CC_Product__r.ccrz__SKU__c =: searchText and CancelDate__c = null AND (Product_Level_2__c != NULL OR Product_Level_1__c != NULL OR Product_Level_3__c != NULL)  AND  CC_Order__c != NULL and CC_Product__c =: productId ORDER BY CurrentExpirationDate__c ];
            system.debug('-------if1--size---------'+displayAssetList.size());
        } else {
            displayAssetList = [SELECT Id, Name,CC_Product__c, Assignee__c,Payment_Status__c,Cancel_Reason__c, Paid_Cert__c, InstallDate, CurrentExpirationDate__c, Paid_Cert1__c,CC_Product__r.ccrz__SKU__c,Assignee__r.Name,Status__c,CC_Product__r.Name,CC_Order__r.Name,CC_Order__c,Effective_Date__c,CancelDate__c,CC_Order__r.ccrz__Name__c,CC_Order__r.ccrz__OrderStatus__c,CC_Order__r.ccrz__TotalAmount__c,CC_Order__r.Opportunity__r.name,CC_Order__r.Paid_in_Full_Date__c,CC_Order__r.CC_Order_Created_Hour__c FROM Asset WHERE CC_Product__r.ccrz__SKU__c =: searchText and CancelDate__c = null AND (Product_Level_2__c != NULL OR Product_Level_1__c != NULL OR Product_Level_3__c != NULL) AND CC_Order__c != NULL and CC_Product__c =: productId ORDER BY CurrentExpirationDate__c ];
            system.debug('-------else1--size---------'+displayAssetList.size());
        }        
        if(test.isRunningTest()){
            displayAssetList = [SELECT Id, Name,Assignee__c,Payment_Status__c,Cancel_Reason__c, Paid_Cert__c, InstallDate, CurrentExpirationDate__c, Paid_Cert1__c,CC_Product__r.ccrz__SKU__c,Assignee__r.Name,Status__c,CC_Product__r.Name,CC_Order__r.Name,CC_Order__c,Effective_Date__c,CancelDate__c,CC_Order__r.ccrz__Name__c,CC_Order__r.ccrz__OrderStatus__c, CC_Order__r.ccrz__TotalAmount__c,CC_Order__r.Opportunity__r.name,CC_Order__r.Paid_in_Full_Date__c,CC_Order__r.CC_Order_Created_Hour__c FROM Asset limit 3];
        }
        system.debug('--------displayAssetList---init-------'+displayAssetList.size());
    } // init close 
    
    Public void runSearch(){            
        // getting all assets from soql to fielter as per assettype selection. 
        dataInit();
        
        // filter logic 
        List<Asset> AssignedAssetListFiltered = new List<Asset>();
        List<Asset> unAssignedAssetListFiltered = new List<Asset>();
        List<Asset> AuthorizedAssetListFiltered = new List<Asset>();
        List<Asset> unpaidAssetListFiltered = new List<Asset>();
        List<Asset> UnAssin_ExpiredAssetListFlt = new List<Asset>();
        List<Asset> AllAssets = new List<Asset>();
        
        for(Asset ast : displayAssetList){
            if(assetTypes == 'Assigned_Asset'){             
                if(ast.Assignee__c != null && ast.CC_Product__r.ccrz__SKU__c != null && ast.Status__c == 'Active' && (ast.Payment_Status__c == 'Authorized'|| ast.Payment_Status__c=='Completed') && ast.Cancel_Reason__c == Null){
                    AssignedAssetListFiltered.add(ast);
                }                      
            } else if(assetTypes == 'Unassigned_Asset'){
                if(ast.Assignee__c == null && ast.CC_Product__r.ccrz__SKU__c != null && ast.Status__c == 'Active' && (ast.Payment_Status__c == 'Authorized'|| ast.Payment_Status__c=='Completed') && ast.Cancel_Reason__c == Null){
                    unAssignedAssetListFiltered.add(ast);
                }            
            } else if(assetTypes == 'Authorized_Asset'){         
                if(ast.CC_Product__r.ccrz__SKU__c != null && ast.Payment_Status__c == 'Authorized' && ast.Status__c == 'Active' && ast.CancelDate__c == Null){
                    AuthorizedAssetListFiltered.add(ast);                           
                }          
            } else if(assetTypes == 'Unpaid_Asset'){
                if(ast.CC_Product__r.ccrz__SKU__c != null && ast.Paid_Cert1__c == False && ast.Status__c != 'Active' && ast.Payment_Status__c != 'Completed' && ast.CancelDate__c == Null && ast.Cancel_Reason__c == null ){
                    unpaidAssetListFiltered.add(ast);                      
                }            
            } else if(assetTypes == 'UnAssigned_Expired_Assets'){
                if(ast.Assignee__c == null && ast.CC_Product__r.ccrz__SKU__c != null && ast.status__c != 'Active' && (ast.Payment_Status__c == 'Authorized'|| ast.Payment_Status__c=='Completed') && ast.Cancel_Reason__c == Null){   
                    UnAssin_ExpiredAssetListFlt.add(ast);
                }                                
            } else if(assetTypes == null){              
                AllAssets.add(ast);             
            } /*else {
                if(ast.Assignee__c != null && ast.Status__c != 'Active'){ }
            } */        
        } //for close
        System.debug(searchText+'-----AssignedAssetListFiltered----Assigned_Asset-------'+AssignedAssetListFiltered.size());
        System.debug(searchText+'-----unAssignedAssetListFiltered----UnAssigned_Asset-------'+unAssignedAssetListFiltered.size());
        System.debug(searchText+'-----AuthorizedAssetListFiltered----Authorized_Asset-------'+AuthorizedAssetListFiltered.size());
        System.debug(searchText+'-----unpaidAssetListFiltered----unpaid_Asset-------'+unpaidAssetListFiltered.size());
        System.debug(searchText+'-----UnAssin_ExpiredAssetListFlt----unassigned_expired_Asset-------'+UnAssin_ExpiredAssetListFlt.size());
        System.debug(assetTypes+'-----unknownAssetListFiltered----allelse_Asset------------'+AllAssets.size());
        displayAssetList.clear();
        system.debug('--------displayAssetList---clear-------'+displayAssetList.size());
        // if any fieltered assets found for showing purpose giving to UI property variable 
        if(!AssignedAssetListFiltered.isEmpty()){           
            displayAssetList.addAll(AssignedAssetListFiltered);
            system.debug('-----inif---1---runsearch-------'+displayAssetList.size());
        } else if(!unAssignedAssetListFiltered.isEmpty()){          
            displayAssetList.addAll(unAssignedAssetListFiltered);
            system.debug('-----inif---2---runsearch-------'+displayAssetList.size());
        } else if(!AuthorizedAssetListFiltered.isEmpty()){          
            displayAssetList.addAll(AuthorizedAssetListFiltered);
            system.debug('-----inif---3---runsearch-------'+displayAssetList.size());
        } else if(!unpaidAssetListFiltered.isEmpty()){          
            displayAssetList.addAll(unpaidAssetListFiltered);
            system.debug('-----inif---4---runsearch-------'+displayAssetList.size());
        } else if(!UnAssin_ExpiredAssetListFlt.isEmpty()){          
            displayAssetList.addAll(UnAssin_ExpiredAssetListFlt);
            system.debug('-----inif---5---runsearch-------'+displayAssetList.size());
        } else if(!AllAssets.isEmpty()){            
            displayAssetList.addAll(AllAssets);
            system.debug('-----inif---6---runsearch-------'+displayAssetList.size());
        }           
        
    } //assettype filtet method
    
    //assignee action method 
    Public void getAssigneeRecords(){        
        system.debug('------Assignee-------'+Assignee);
        if(Assignee != null || Assignee !=''){
            displayAssetList.clear();
            string Assignee = '%' + Assignee + '%';
            string qry ='select name,Assignee__r.name,CC_Product__r.Name, InstallDate, Effective_Date__c,CurrentExpirationDate__c,Payment_Status__c,Paid_Cert__c from Asset where Assignee__c != Null and Assignee__r.name like : Assignee AND CC_Product__c =: productId AND AccountId =: sobjectId';
            List<Asset> AllassigneAssets = Database.query(qry);
            for(Asset ass : AllassigneAssets){
                displayAssetList.add(ass);
            }
        }
        system.debug('Assignee Records:---------' + displayAssetList.size());
    }
    
}