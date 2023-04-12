public with sharing class ACAMSEcomLeadTriggerHandler extends CCAviTriggerHandler {

    private List<Lead> newList;
    private List<Lead> oldList;
    private Map<Id, Lead> newMap;
    private Map<Id, Lead> oldMap;

    public ACAMSEcomLeadTriggerHandler() {
        this.oldList = Trigger.old;
        this.newList = Trigger.new;
        this.oldMap = (Map<Id, Lead>) Trigger.oldMap;
    }

    public override void beforeInsert() {
        for (Lead lead : newList) {
               // Start FSA-3533
                if(userinfo.getName() =='Eloqua Marketing'){
                if(lead.Billing_Country__c == null && !String.isBlank(lead.Country)){
                    lead.Billing_Country__c = ACAMS_RegistrationPageController.getCountryfullname(lead.Country);
                }
                if(lead.Billing_State__c == null && !String.isBlank(lead.Country) && !String.isBlank(lead.State)){
                    if(getStatefullnamelead(lead.State, lead.Country) != null){
                    lead.Billing_State__c = getStatefullnamelead(lead.State, lead.Country);
                    }
                }
               }
                 // End FSA-3533
            if (lead.Billing_Country__c != null && lead.Billing_Country__c.length() > 2) {
                String isoCode = ACAMSUtil.getIsoCodeFromCountryName(lead.Billing_Country__c);
                lead.Country = isoCode;
                lead.CountryCode = isoCode;
            }

            if (lead.Billing_State__c != null) {
                List<String> metadata = ACAMSUtil.getMetadataFromStateName(lead.Billing_State__c, lead.Billing_Country__c);
                lead.State = metadata.get(1) != null ? metadata.get(1) : metadata.get(0);
                lead.StateCode = metadata.get(0);
            }
        }

        this.setRegionFieldByCountry(this.newList);
    }

    public override void beforeUpdate() {
        for (Lead lead : newList) {
            if (lead.Billing_Country__c != oldMap.get(lead.Id).Billing_Country__c && lead.Billing_Country__c != null &&
                    lead.Billing_Country__c.length() > 2) {
                String isoCode = ACAMSUtil.getIsoCodeFromCountryName(lead.Billing_Country__c);
                lead.Country = isoCode;
                lead.CountryCode = isoCode;
            }

            if (lead.Billing_State__c != oldMap.get(lead.Id).Billing_State__c && lead.Billing_State__c != null) {
                List<String> metadata = ACAMSUtil.getMetadataFromStateName(lead.Billing_State__c, lead.Billing_Country__c);
                lead.State = metadata.get(1) != null ? metadata.get(1) : metadata.get(0);
                lead.StateCode = metadata.get(0);
            }
        }

        this.setRegionFieldByCountry(
                this.getLeadsWithCountriesOrStatesChanged(this.newList, this.oldMap)
        );
    }

    private List<Lead> getLeadsWithCountriesOrStatesChanged(List<Lead> currentLeads, Map<Id, Lead> oldLeads) {
        List<Lead> leadsWithCountriesChanged = new List<Lead>();
        for (Lead currentLead : currentLeads) {
            Lead oldLead = oldLeads.get(currentLead.Id);
            if (oldLead.CountryCode != currentLead.CountryCode) {
                leadsWithCountriesChanged.add(currentLead);
            } else if (oldLead.StateCode != currentLead.StateCode) {
                leadsWithCountriesChanged.add(currentLead);
            }
        }
        return leadsWithCountriesChanged;
    }


    private void setRegionFieldByCountry(List<Lead> leads) {
        Set<String> countryCodes = new Set<String>();
        Set<String> stateCodes = new Set<String>();
        Map<String, String> regionByCountryCode = new Map<String, String>();
        for (Lead leadToUpdate : leads) {
            if (!String.isBlank(leadToUpdate.CountryCode)) {
                countryCodes.add(leadToUpdate.CountryCode);
            }
            if (!String.isBlank(leadToUpdate.StateCode)) {
                stateCodes.add(leadToUpdate.StateCode);
            }
        }
        for (CountrySettings__mdt countrySetting : [
                SELECT DeveloperName, Region__c, SubTerritory__c, Named_Territory__c, Isocode__c, Label
                FROM CountrySettings__mdt
                WHERE DeveloperName IN :countryCodes
        ]) {
            regionByCountryCode.put(countrySetting.DeveloperName, countrySetting.Region__c);
            regionByCountryCode.put('namedTerritory' + countrySetting.DeveloperName, countrySetting.Named_Territory__c);
            regionByCountryCode.put('subTerritory' + countrySetting.DeveloperName, countrySetting.SubTerritory__c);
            regionByCountryCode.put('country' + countrySetting.DeveloperName, countrySetting.Label);
        }
        for (StateSettings__mdt stateSetting : [
                SELECT Label, Country__r.DeveloperName, Isocode__c
                FROM StateSettings__mdt
                WHERE Isocode__c IN :stateCodes
        ]) {
            regionByCountryCode.put(
                    'state' + stateSetting.Country__r.DeveloperName + '-' + stateSetting.Isocode__c,
                    stateSetting.Label
            );
        }
        for (Lead leadToUpdate : leads) {
            if (regionByCountryCode.containsKey(leadToUpdate.CountryCode)) {
                leadToUpdate.AddressRegion__c = regionByCountryCode.get(leadToUpdate.CountryCode);
            } else if (String.isBlank(leadToUpdate.CountryCode)) {
                leadToUpdate.AddressRegion__c = '';
            }
            leadToUpdate.AddressNamed_Territory__c = regionByCountryCode.get('namedTerritory' + leadToUpdate.CountryCode);
            leadToUpdate.AddressSubTerritory__c = regionByCountryCode.get('subTerritory' + leadToUpdate.CountryCode);
            leadToUpdate.Billing_Country__c = regionByCountryCode.get('country' + leadToUpdate.CountryCode);
            leadToUpdate.Billing_State__c = regionByCountryCode.get(
                    'state' + leadToUpdate.CountryCode + '-' + leadToUpdate.StateCode
            );
        }
    }
   // Start FSA-3533
    public static String getStatefullnamelead(String statecode, String countrycode) {
        List<StateSettings__mdt> metaData = [
            SELECT
            Id,
            MasterLabel
            FROM
            StateSettings__mdt
            WHERE
            Integration_Value__c = : statecode
            AND
            (Country__r.MasterLabel = :countrycode
             OR
             Country__r.Isocode__c = :countrycode)
            LIMIT 1
        ];
        if(metaData.size() > 0){
            return metaData.get(0).MasterLabel;
        }
        else{
            List<StateSettings__mdt> metaDataIso = [
                SELECT
                Id,
                MasterLabel
                FROM
                StateSettings__mdt
                WHERE
                Isocode__c = : statecode
                AND
                (Country__r.MasterLabel = :countrycode
                 OR
                 Country__r.Isocode__c = :countrycode)
                LIMIT 1
            ];
            if(metaDataIso.size() > 0){
                return metaDataIso.get(0).MasterLabel;
            }
            else{
                return null;
            }
        }
    }
    // End FSA-3533
}