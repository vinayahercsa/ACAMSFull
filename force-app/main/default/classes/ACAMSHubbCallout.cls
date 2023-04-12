public class ACAMSHubbCallout {
  public static List<Object> assetList{get;set;}
  public static List<Object> displayList{get;set;}
  public HubbUser u {get;set;}
  public static String hubbUserId {get;set;}
  public static Integer recordSize {get;set;}
  public static String propertyValues {get;set;}
  private static String globalHubbToken = getBearerToken();
  //FSA-142
  public static Boolean isAssetUpdated = false;
  public static Integer MAX_LIST_SIZE {get;set;}
  public static Boolean isHubbDeleted = false;
  public static String eventCode = '5431';
  public static String  userEndPointURL = 'https://ngapi.hubb.me/api/v1/'+ACAMSHubbCallout.eventCode+'/Users';
  public static String  metadataEndPointURL = 'https://ngapi.hubb.me/api/v1/'+ACAMSHubbCallout.eventCode+'/PropertyMetadata/?$filter=Type%20eq%20%27User%27';
  public static String  propertyValueEndPointURL = 'https://ngapi.hubb.me/api/v1/'+ACAMSHubbCallout.eventCode+'/PropertyValues';

  public static String userRecords {get;set;}

  public ACAMSHubbCallout() {
    // FSA-142, fix the SF 1000 record size limitation for a list
    MAX_LIST_SIZE = 100;
    u = new HubbUser();
  }

  private static String getBearerToken(){
      try{
          String body = '';
          HttpRequest req = new HttpRequest();
          req.setHeader('Content-Encoding', 'UTF-8');
          req.setHeader('Content-type', 'application/x-www-form-urlencoded');
          body = 'client_id=B123429E-D1A4-4E50-AF1C-9F7C65BE7824&client_secret=wTKQTDZG5QBKhFrN&scope=779E88D5-DE1C-4DEB-88B7-045E089A1147&grant_type=client_credentials';
          req.setBody(body);
          req.setMethod('POST');
          req.setTimeout(12000);
          req.setEndpoint('https://ngapi.hubb.me/auth/token');

          Http http = new Http();
          HTTPResponse res = http.send(req);

          System.debug('*****HubbCallout.getBody(): ' + res.getBody());
          // parse token here
          String responseJson = res.getBody();
          Map<String,Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseJson);
          System.debug('------>>>'+responseMap.get('access_token'));

          // FSA-142
          Integer statusCode = res.getStatusCode();

          System.debug('*****HubbCallout.getStatus(): ' + res.getStatus());
          if(statusCode == 200 || statusCode == 204){
            return (String)responseMap.get('access_token');
          }
          else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Get Hubb Token Callout Failed.'+res.getStatus()+' Error:'+res.getBody()));
            return null;
          }
      
      }
      catch(Exception ex){
          return null;
      }
  }

  public PageReference RESTInsertAUser(){
      try{
        String body = '';
        //String hubbToken = getBearerToken();
        String hubbToken = globalHubbToken;
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'bearer '+hubbToken);
        req.setHeader('Content-Type', 'application/json');
        body = '';
        req.setMethod('POST');
        req.setTimeout(12000);
        //req.setEndpoint('https://ngapi.hubb.me/api/v1/5336/Users');
        // FSA-142
        req.setEndpoint(userEndPointURL);
    
        System.debug('---insert--userJsonBody--->'+generateJsonBody(u));
        req.setBody(generateJsonBody(u));
        Http http = new Http();
        HTTPResponse res = http.send(req);

        System.debug('+++++++++HubbCallout.getBody(): ' + res.getBody());
        Map<String,Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        Integer uId = (Integer)responseMap.get('Id');
        System.debug('+++insertuserId--->'+uId);
        RESTInsertUserCustomFields(uId,null,null);
        System.debug('+++++++++HubbCallout.getStatus(): ' + res.getStatus());
        System.debug('+++++++++HubbCallout.getStatusCode(): ' + res.getStatusCode());
    }

    catch(Exception ex){
        
    }
    PageReference pf = new PageReference('/apex/ACAMSHubbUserInsert');
    pf.setRedirect(true);
    return pf;
  }

  // FSA-142
  public static void RESTInsertUserCustomFields(Integer userId, HubbUser customFieldValues, Asset updateAsset){
      Set<Integer> pIds = PropertyMetadataCall();
      Map<Integer,String> fieldValMap = new Map<Integer,String>();
      System.debug('-----memberType->>>>>'+customFieldValues.MembershipType);
      fieldValMap.put(72963,customFieldValues.MembershipType);
      fieldValMap.put(72964,customFieldValues.Designation);
      fieldValMap.put(72965,customFieldValues.AttendeeType);
      fieldValMap.put(72966,customFieldValues.YearsOfExperience);
      fieldValMap.put(74614,customFieldValues.OrganizationType);

      System.debug('customFieldValues.YearsOfExperience-->'+customFieldValues.YearsOfExperience);
      System.debug('customFieldValues.AttendeeType-->'+customFieldValues.AttendeeType);
      System.debug('customFieldValues.OrganizationType-->'+customFieldValues.OrganizationType);
      System.debug('customFieldValues.Designation-->'+customFieldValues.Designation);

      try{
        String body = '';
        //String hubbToken = getBearerToken();
        String hubbToken = globalHubbToken;
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'bearer '+hubbToken);
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('POST');
        req.setTimeout(12000);
        //req.setEndpoint('https://ngapi.hubb.me/api/v1/5336/PropertyValues');
        // FSA-142
        req.setEndpoint(propertyValueEndPointURL);

        for(Integer pId : pIds){
        System.debug('---pid->'+pIds);
        //body = '{"PropertyMetadataId": 72926,"Value": "string","UserId": '+userId+'}';
        body = '';
        body = '{"PropertyMetadataId": '+pId+',"Value": "'+fieldValMap.get(pId)+'","UserId": '+userId+'}';
  
        req.setBody(body);
        Http http = new Http();
        HTTPResponse res = http.send(req);

        System.debug('+++++++++HubbCallout.Inserted Hubb Custom Field Id:'+pId+'(): ' + res.getBody());
        System.debug('+++++++++HubbCallout.Inserted Hubb Custom Field Status: ' + res.getStatus());
        // FSA-142
        if(res.getStatusCode() == 200 || res.getStatusCode() == 204){
          if((String.isBlank(updateAsset.Hubb_Id__c) ||  String.valueOf(updateAsset.Hubb_Id__c).contains('(DEL)'))&& !isAssetUpdated){
            updateAsset.Hubb_Id__c = String.valueOf(userId);
            updateAsset.Hubb_Status__c = 'Passed';
            update updateAsset;
            isAssetUpdated = true;
          }
          else{
            continue;
          }
        }
        else{
          Integer statusCode = res.getStatusCode();
          
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Hubb Insert Property Values Callout Failed.'+res.getStatus()+' Error:'+res.getBody()));
          return;
          
        }

        }
    }

    catch(Exception ex){
        
    }
  }

  public static Set<Integer> PropertyMetadataCall(){
      Set<Integer> hubbCustomFieldsIds = new Set<Integer>();
      List<Map<String, Object>> hubbFieldsMaps = new List<Map<String, Object>>();

      try{
        String body = '';
        //String hubbToken = getBearerToken();
        String hubbToken = globalHubbToken;
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'bearer '+hubbToken);
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('GET');
        req.setTimeout(12000);
        //req.setEndpoint('https://ngapi.hubb.me/api/v1/5336/PropertyMetadata/?$filter=Type%20eq%20%27User%27');
        // FSA-142
        req.setEndpoint(metadataEndPointURL);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String jsonResponse = res.getBody();
        
        //jsonResponse = jsonResponse.substring(1, jsonResponse.length()-1);
        System.debug('jsonString1111:::'+jsonResponse);
        //System.debug('+++++++++propertyMetadataCall.getBody(): ' + res.getBody());
        jsonResponse = '{ "hubbFields":'+jsonResponse+'}';
        System.debug('jsonString2222::'+jsonResponse);
        Map<String,Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        
        if(responseMap != null && responseMap.get('hubbFields') != null){
          System.debug('response_Map==>'+responseMap.get('hubbFields'));
          List<Object> myMapObjects = (List<Object>) responseMap.get('hubbFields');
          for (Object obj : myMapObjects) {
              hubbFieldsMaps.add((Map<String, Object>)obj);
          }
        }

        for(Map<String, Object> ele : hubbFieldsMaps){
          System.debug('-----manyId-->'+ele.get('Id'));
          hubbCustomFieldsIds.add((Integer)ele.get('Id'));
        }
        //pId = (Integer)responseMap.get('Id');
        //System.debug('xxxx-->'+pId);
        System.debug('+++++++++HubbCallout.getStatus(): ' + res.getStatus());
        System.debug('+++++++++HubbCallout.getStatusCode(): ' + res.getStatusCode());

        // FSA-142
        Integer statusCode = res.getStatusCode();
        if(statusCode != 200 && statusCode != 204){
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Hubb Insert Metadata Callout Failed.'+res.getStatus()+' Error:'+res.getBody()));
          return null;
        }

        
        else{
          return hubbCustomFieldsIds;
        }

    }
    catch(Exception ex){
        
    }
    return hubbCustomFieldsIds;
  }
  
  @Future(Callout=true)
  public static void RESTInsertRecords(Set<Id> accountIds, Id assetId){
    List<Account> accountUpdateList = new List<Account>();
    List<HubbUser> hubUserList = new List<HubbUser>();
    // FSA-142c
    String eventCode = '5336';
    
    // FSA-142
    List<Asset> assetList = [SELECT Id, Name,Years_of_Experience__c,Event_Registration_Type__c,Hubb_Id__c,Event_Code__c,Membership_Type__c  FROM ASSET WHERE Id =: assetId];
    List<Account> acctList = [SELECT Id,Membership_Type__c, FirstName, LastName,Company_Name__c, Job_Title__pc,Designation_Formula__pc, PersonEmail,PersonTitle, Membership_Type__pc, Designation__pc, Industry FROM Account WHERE Id IN: accountIds LIMIT 1];
    System.debug('asset-event-code::'+assetList.get(0).Event_Code__c);
    if(assetList != null && assetList.get(0).Event_Code__c != null){
      // FSA-142
      eventCode = String.valueOf(assetList.get(0).Event_Code__c).trim();
    }
    // FSA-142c
    String  userEndPointURL = 'https://ngapi.hubb.me/api/v1/'+eventCode+'/Users';
    String  metadataEndPointURL = 'https://ngapi.hubb.me/api/v1/'+eventCode+'/PropertyMetadata/?$filter=Type%20eq%20%27User%27';
    String  propertyValueEndPointURL = 'https://ngapi.hubb.me/api/v1/'+eventCode+'/PropertyValues';

    for(Account a : acctList){
            HubbUser hubUser = new HubbUser();
            hubUser.firstName = a.FirstName;
            hubUser.attendeeId = a.Id;
            hubUser.lastName = a.LastName;
            hubUser.personalTitle = a.Job_Title__pc;
            hubUser.personalEmail = a.PersonEmail;
            hubUser.roles = 'Attendee';
            hubUser.profileMetadata = '';
            hubUser.Biography = '';
            hubUser.company = a.Company_Name__c;
            hubUser.Id = 123;
            hubUser.IsOptedOut = true;
            hubUser.CalendarFeedId = '';
            hubUser.MembershipType = assetList.get(0).Membership_Type__c;
            System.debug('test Memship id----->'+assetList.get(0).Membership_Type__c);
            hubuser.Designation = a.Designation_Formula__pc;
            hubuser.YearsOfExperience = assetList.get(0).Years_of_Experience__c;
            hubuser.AttendeeType = assetList.get(0).Event_Registration_Type__c;
            hubUser.OrganizationType = a.Industry;
            // FSA-142
            hubUser.Industry = a.Industry;
            hubUser.faceBook = '';
            hubUser.webSite = '';
            hubUser.linkedIn = 'string';
            hubUser.twitter = '';
            hubUser.photoLink = '';
            hubUser.Interests = '';
            hubUserList.add(hubUser);
      }

      try{
          String body = '';
          //String hubbToken = getBearerToken();
          String hubbToken = globalHubbToken;
          HttpRequest req = new HttpRequest();
          req.setHeader('Authorization', 'bearer '+hubbToken);
          req.setHeader('Content-Type', 'application/json');
          body = '';
          System.debug('hubb token----->'+hubbToken);
          //List<Account> acctList = [SELECT FirstName, LastName, PersonTitle, PersonEmail FROM Account WHERE PersonEmail = 'test@acams1.com' OR PersonEmail = 'test@acams2.com'];

          req.setMethod('POST');
          req.setTimeout(12000);
          //req.setEndpoint('https://ngapi.hubb.me/api/v1/5336/Users');
          // FSA-142
          System.debug('---userEndPointURL-->'+userEndPointURL);
          req.setEndpoint(userEndPointURL);

          HubbUser acct = hubUserList.get(0);
            System.debug('---insertUserCall--->'+generateJsonBody(acct));
            req.setBody(generateJsonBody(acct));
            Http http = new Http();
            HTTPResponse res = http.send(req);
  
            System.debug('+++++++++HubbCallout.getBody(): ' + res.getBody());
            Map<String,Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            Integer uId = (Integer)responseMap.get('Id');
          
            System.debug('+++uid--->'+uId);
            hubbUserId = String.valueOf(uId).trim();
            RESTInsertUserCustomFields(uId,acct,assetList.get(0));

            Integer statusCode = res.getStatusCode();

            if(statusCode != 200 && statusCode != 204){
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Hubb Insert User Callout Failed.'+res.getStatus()+' Error:'+res.getBody()));
            }

            System.debug('+++++++++HubbCalloutbulkInsert.getBody(): ' + res.getBody());
            System.debug('+++++++++HubbCallout.getStatus(): ' + res.getStatus());
            System.debug('+++++++++HubbCallout.getStatusCode(): ' + res.getStatusCode()); 
      }

      catch(Exception ex){
          
      }
  }

  public static void RESTGetRecords(){
    displayList = new List<Object>();
      try{
          String body = '';
          //String hubbToken = getBearerToken();
          String hubbToken = globalHubbToken;
          HttpRequest req = new HttpRequest();
          req.setHeader('Authorization', 'bearer '+hubbToken);
          req.setHeader('Content-Type', 'application/json');
      
          //req.setBody(body);
          req.setMethod('GET');
          req.setTimeout(12000);
          //req.setEndpoint('https://ngapi.hubb.me/api/v1/5336/Users');
          // FSA-142a
          req.setEndpoint(userEndPointURL);
          Http http = new Http();
          HTTPResponse res = http.send(req);

          System.debug('+++++++++HubbCallout.getBody(): ');
          userRecords = + res.getBody();
          assetList = (List<Object>)JSON.deserializeUntyped(res.getBody().trim());
          if(assetList != null && assetList.size() > MAX_LIST_SIZE){
            for(Integer i=0; i < MAX_LIST_SIZE; i++){
              displayList.add(assetList.get(assetList.size()-1-i));
            }
          }
          else{
            displayList.addAll(assetList);
          }
          System.debug('----+>'+assetList);
          System.debug('+++++++++HubbCallout.getStatus(): ' + res.getStatus());
          System.debug('+++++++++HubbCallout.getStatusCode(): ' + res.getStatusCode());
          recordSize = assetList.size();
      }

      catch(Exception ex){
          
      }
  }

  public static void getPropertyValues(){
      try{
        String body = '';
        //String hubbToken = getBearerToken();
        String hubbToken = globalHubbToken;
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'bearer '+hubbToken);
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('GET');
        req.setTimeout(12000);
        // FSA-142a
        //req.setEndpoint('https://ngapi.hubb.me/api/v1/5336/PropertyValues');
        req.setEndpoint(propertyValueEndPointURL);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        propertyValues = res.getBody();
        System.debug('+++++++++HubbCallout.GetProperty' + res.getBody());
        System.debug('+++++++++HubbCallout.Inserted Hubb Custom Field Status: ' + res.getStatus());
        System.debug('+++++++++getStatusCode(): ' + res.getStatusCode());
        }
    
        catch(Exception ex){
            
        }
  }

  // FSA-142
  @Future(Callout=true)
  public static void RESTFutureDeleteRecords(Set<Id> assetId){
    Asset deleteHubbUserAsset = [SELECT Id, Name,Years_of_Experience__c,Event_Registration_Type__c,Hubb_Id__c,Event_Code__c,Membership_Type__c  FROM ASSET WHERE Id =: assetId LIMIT 1];
    String userId;

    // FSA-142c
    String eventCode = '5336';
    if(deleteHubbUserAsset != null && deleteHubbUserAsset.Event_Code__c != null){
      // FSA-142
      eventCode = String.valueOf(deleteHubbUserAsset.Event_Code__c).trim();
    }

    String  userEndPointURL = 'https://ngapi.hubb.me/api/v1/'+eventCode+'/Users';
    String  metadataEndPointURL = 'https://ngapi.hubb.me/api/v1/'+eventCode+'/PropertyMetadata/?$filter=Type%20eq%20%27User%27';
    String  propertyValueEndPointURL = 'https://ngapi.hubb.me/api/v1/'+eventCode+'/PropertyValues';

    if(deleteHubbUserAsset != null && deleteHubbUserAsset.Hubb_Id__c != null){
      userId = String.valueOf(deleteHubbUserAsset.Hubb_Id__c).trim();
    }

    else{
      //delete most recently insert one
      userId = hubbUserId.trim();
    }
    try{
        String body = '';
        //String hubbToken = getBearerToken();
        String hubbToken = globalHubbToken;
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'bearer '+hubbToken);
        req.setHeader('Content-Type', 'application/json');

        body = '{}';

        req.setBody(body);
        req.setMethod('DELETE');
        req.setTimeout(12000);
        //req.setEndpoint('https://ngapi.hubb.me/api/v1/5336/Users/'+userId);
        req.setEndpoint(userEndPointURL+'/'+userId);
        System.debug('---del user--->'+(userEndPointURL+userId));
        Http http = new Http();
        HTTPResponse res = http.send(req);

        if((res.getStatusCode() == 200 || res.getStatusCode() == 204) && !isHubbDeleted){
          deleteHubbUserAsset.Hubb_Id__c += ' (DEL)';
          update deleteHubbUserAsset;
          ACAMSHubbCallout.isHubbDeleted = true;
        }
        System.debug('+++++++++HubbCallout.getBody(): ' + res.getBody());
        System.debug('+++++++++HubbCallout.getStatus(): ' + res.getStatus());
        System.debug('+++++++++HubbCallout.getStatusCode(): ' + res.getStatusCode());
    }

    catch(Exception ex){
        
    }
    
}

  public static PageReference RESTDeleteRecords(){
      String userId = hubbUserId.trim();
      try{
          String body = '';
          //String hubbToken = getBearerToken();
          String hubbToken = globalHubbToken;
          HttpRequest req = new HttpRequest();
          req.setHeader('Authorization', 'bearer '+hubbToken);
          req.setHeader('Content-Type', 'application/json');

          body = '{}';

          req.setBody(body);
          req.setMethod('DELETE');
          req.setTimeout(12000);
          //req.setEndpoint('https://ngapi.hubb.me/api/v1/5336/Users/'+userId);
          req.setEndpoint(userEndPointURL+'/'+userId);
          System.debug('---del user--->'+(userEndPointURL+userId));
          Http http = new Http();
          HTTPResponse res = http.send(req);

          System.debug('+++++++++HubbCallout.getBody(): ' + res.getBody());
          System.debug('+++++++++HubbCallout.getStatus(): ' + res.getStatus());
          System.debug('+++++++++HubbCallout.getStatusCode(): ' + res.getStatusCode());
      }

      catch(Exception ex){
          
      }
      
      PageReference pf = new PageReference('/apex/ACAMSHubbUserInsert');
      pf.setRedirect(true);
      return pf;
  }

  private static String generateJsonBody(HubbUser acct) {
      String profileMetaData = '<?xml version=\\"1.0\\" encoding=\\"utf-16\\"?> <ProfileMetadata xmlns:xsi=\\"http://www.w3.org/2001/XMLSchema-instance\\" xmlns:xsd=\\"http://www.w3.org/2001/XMLSchema\\"> <CompanyIsPrivate>false</CompanyIsPrivate> <IndustryIsPrivate>false</IndustryIsPrivate> <BiographyIsPrivate>false</BiographyIsPrivate> <EmailIsPrivate>true</EmailIsPrivate> <TitleIsPrivate>false</TitleIsPrivate> <FirstNameIsPrivate>false</FirstNameIsPrivate> <LastNameIsPrivate>false</LastNameIsPrivate> <InterestIsPrivate>false</InterestIsPrivate> <ProfileIsPublic>true</ProfileIsPublic> <WebsiteIsPrivate>false</WebsiteIsPrivate> <TwitterIsPrivate>false</TwitterIsPrivate> <FacebookIsPrivate>false</FacebookIsPrivate> <BlogIsPrivate>false</BlogIsPrivate> <LinkedInIsPrivate>false</LinkedInIsPrivate> <AvailableforMeeting>true</AvailableforMeeting> </ProfileMetadata>';
      System.debug('lllinkedINaccount--->'+acct.linkedIn);
      return 
      '{"FirstName": "' + acct.firstName 
      + '","AttendeeID": "' + acct.attendeeId 
      + '","ProfileMetadata": "' + profileMetaData
      + '","LastName": "' + acct.lastName 
      + '","Title": "' + acct.personalTitle  
      + '","EmailAddress": "' + acct.personalEmail 
      + '","Company": "' + acct.company 
      + '","Industry": "' + acct.Industry 
      + '","Interests": "' + acct.MembershipType 
      //+ '","Roles": "' + 'Attendee' 
      + '","Roles": "' + acct.roles  
      + '","Biography": "' + acct.Biography
      + '","DateFirstLoggedIn": "' + '2020-09-10T20:44:01.323Z' 
      + '","Facebook": "' + acct.faceBook 
      + '","Website": "' + acct.webSite 
      + '","Id": ' +  
      + ',"IsOptedOut": ' + true 
      + ',"CalendarFeedId": "' + acct.CalendarFeedId 
      // FSA-142, unable to populate linkedIn and twitter fields
      //+ ',"LinkedIn": "' + null
      //+ ',"Twitter": "' + acct.twitter
      //+ ',"PhotoLink": "' + acct.photoLink 
      
      //+ ',"Interests": "' + acct.Interests  
      + '"}';  
  }

  // hubb user class
  public class HubbUser {
    public String firstName {get;set;}
    public String attendeeId {get;set;}
    public String lastName {get;set;}
    public String personalTitle {get;set;}
    public String personalEmail {get;set;}
    public String roles {get;set;}
    public String profileMetadata {get;set;}
    public String Biography {get;set;}
    public String DateFirstLoggedIn {get;set;}
    public String Industry {get;set;}
    public String company {get;set;}
    public Integer Id {get;set;}
    public Boolean IsOptedOut {get;set;}
    public String CalendarFeedId {get;set;}
    public String YearsOfExperience{get;set;}
    public String MembershipType {get;set;}
    public String OrganizationType {get;set;}
    public String Designation {get;set;}
    public String assetId{get;set;}
    public String AttendeeType {get;set;}

    // FSA-142
    public String faceBook {get;set;}
    public String webSite {get; set;}
    public String linkedIn {get;set;}
    public String twitter {get;set;}
    public String photoLink {get;set;}
    public String interests {get;set;}
  }

  
}