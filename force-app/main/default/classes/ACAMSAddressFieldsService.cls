public with sharing class ACAMSAddressFieldsService {

    public static void beforeTriggerCall(
            List<SObject> records,
            Map<Id, SObject> oldRecords,
            String countryFieldName,
            String countryCodeFieldName,
            String regionFieldName,
            String continentFieldName,
            String namedTerritoryFieldName,
            String subTerritoryFieldName,
            String vertexCountryFieldName
    ) {
        List<SObject> updatedRecords;
        if (oldRecords == null) {
            updatedRecords = records;
        } else {
            updatedRecords = new List<SObject>();
            for (SObject record : records) {
                if (isRecordUpdated(record, oldRecords, countryFieldName, countryCodeFieldName)) {
                    updatedRecords.add(record);
                }
            }
        }
        updateAddressFieldsFromMetadata(
                updatedRecords,
                countryFieldName,
                countryCodeFieldName,
                regionFieldName,
                continentFieldName,
                namedTerritoryFieldName,
                subTerritoryFieldName,
                vertexCountryFieldName
        );
    }

    public static void updateAddressFieldsFromMetadata(
            List<SObject> records,
            String countryFieldName,
            String countryCodeFieldName,
            String regionFieldName,
            String continentFieldName,
            String namedTerritoryFieldName,
            String subTerritoryFieldName,
            String vertexCountryFieldName
    ) {
        Map<String, CountrySettings__mdt> countrySettingByName = new Map<String, CountrySettings__mdt>();
        Map<String, CountrySettings__mdt> countrySettingByIso3 = new Map<String, CountrySettings__mdt>();
        Map<String, CountrySettings__mdt> countrySettingByIso2 = new Map<String, CountrySettings__mdt>();
        Map<String, CountrySettings__mdt> countrySettingByIso = new Map<String, CountrySettings__mdt>();
        for (CountrySettings__mdt countrySetting : getRelatedCountrySettings(records, countryFieldName, countryCodeFieldName)) {
            countrySettingByName.put(countrySetting.MasterLabel, countrySetting);
            countrySettingByIso3.put(countrySetting.IsoCode_3__c, countrySetting);
            countrySettingByIso2.put(countrySetting.IsoCode_2__c, countrySetting);
            countrySettingByIso.put(countrySetting.Isocode__c, countrySetting);
        }
        for (SObject record : records) {
            String newRegion;
            String newNamedTerritory;
            String newSubTerritory;
            String newContinent;
            String vertexCountry;
            String recordCountry;
            String recordCountryCode;
            if (countryFieldName != null) {
                recordCountry = (String) record.get(countryFieldName);
            }
            if (countryCodeFieldName != null) {
                recordCountryCode = (String) record.get(countryCodeFieldName);
            }
            if (recordCountry != null && countrySettingByName.containsKey(recordCountry)) {
                newRegion = countrySettingByName.get(recordCountry).Region__c;
                newNamedTerritory = countrySettingByName.get(recordCountry).Named_Territory__c;
                newSubTerritory = countrySettingByName.get(recordCountry).SubTerritory__c;
                newContinent = countrySettingByName.get(recordCountry).Continent__c;
                vertexCountry = countrySettingByName.get(recordCountry).MasterLabel;
            } else if (recordCountryCode != null && countrySettingByIso3.containsKey(recordCountryCode)) {
                newRegion = countrySettingByIso3.get(recordCountryCode).Region__c;
                newNamedTerritory = countrySettingByIso3.get(recordCountryCode).Named_Territory__c;
                newSubTerritory = countrySettingByIso3.get(recordCountryCode).SubTerritory__c;
                newContinent = countrySettingByIso3.get(recordCountryCode).Continent__c;
                vertexCountry = countrySettingByIso3.get(recordCountryCode).MasterLabel;
            } else if (recordCountryCode != null && countrySettingByIso2.containsKey(recordCountryCode)) {
                newRegion = countrySettingByIso2.get(recordCountryCode).Region__c;
                newNamedTerritory = countrySettingByIso2.get(recordCountryCode).Named_Territory__c;
                newSubTerritory = countrySettingByIso2.get(recordCountryCode).SubTerritory__c;
                newContinent = countrySettingByIso2.get(recordCountryCode).Continent__c;
                vertexCountry = countrySettingByIso2.get(recordCountryCode).MasterLabel;
            } else if (recordCountryCode != null && countrySettingByIso.containsKey(recordCountryCode)) {
                newRegion = countrySettingByIso.get(recordCountryCode).Region__c;
                newNamedTerritory = countrySettingByIso.get(recordCountryCode).Named_Territory__c;
                newSubTerritory = countrySettingByIso.get(recordCountryCode).SubTerritory__c;
                newContinent = countrySettingByIso.get(recordCountryCode).Continent__c;
                vertexCountry = countrySettingByIso.get(recordCountryCode).MasterLabel;
            } else if (recordCountry != null && countrySettingByIso3.containsKey(recordCountry)) {
                newRegion = countrySettingByIso3.get(recordCountry).Region__c;
                newNamedTerritory = countrySettingByIso3.get(recordCountry).Named_Territory__c;
                newSubTerritory = countrySettingByIso3.get(recordCountry).SubTerritory__c;
                newContinent = countrySettingByIso3.get(recordCountry).Continent__c;
                vertexCountry = countrySettingByIso3.get(recordCountry).MasterLabel;
            } else if (recordCountry != null && countrySettingByIso2.containsKey(recordCountry)) {
                newRegion = countrySettingByIso2.get(recordCountry).Region__c;
                newNamedTerritory = countrySettingByIso2.get(recordCountry).Named_Territory__c;
                newSubTerritory = countrySettingByIso2.get(recordCountry).SubTerritory__c;
                newContinent = countrySettingByIso2.get(recordCountry).Continent__c;
                vertexCountry = countrySettingByIso2.get(recordCountry).MasterLabel;
            } else if (recordCountry != null && countrySettingByIso.containsKey(recordCountry)) {
                newRegion = countrySettingByIso.get(recordCountry).Region__c;
                newNamedTerritory = countrySettingByIso.get(recordCountry).Named_Territory__c;
                newSubTerritory = countrySettingByIso.get(recordCountry).SubTerritory__c;
                newContinent = countrySettingByIso.get(recordCountry).Continent__c;
                vertexCountry = countrySettingByIso.get(recordCountry).MasterLabel;
            }
            if (regionFieldName != null) {
                record.put(regionFieldName, newRegion);
            }
            if (namedTerritoryFieldName != null) {
                record.put(namedTerritoryFieldName, newNamedTerritory);
            }
            if (subTerritoryFieldName != null) {
                record.put(subTerritoryFieldName, newSubTerritory);
            }
            if (continentFieldName != null) {
                record.put(continentFieldName, newContinent);
            }
            if (vertexCountryFieldName != null) {
                // Taiwan, Hong Kong, and Macau are not recognized by Vertex.
                if (vertexCountry != null) {
                    if (vertexCountry.equalsIgnoreCase('Taiwan')) {
                        vertexCountry = 'Taiwan, Republic of China';
                    } else if (vertexCountry.equalsIgnoreCase('Hong Kong SAR')) {
                        vertexCountry = 'hong kong, sar china';
                    } else if (vertexCountry.equalsIgnoreCase('Macau SAR')) {
                        vertexCountry = 'macao, sar china';
                    }
                    else if (vertexCountry.equalsIgnoreCase('Myanmar (Burma)')) {
                        vertexCountry = 'myanmar';
                    }
                    else if (vertexCountry.equalsIgnoreCase('Russia')) {
                        vertexCountry = 'russian federation';
                    }
                    else if (vertexCountry.equalsIgnoreCase('St. Kitts & Nevis')) {
                        vertexCountry = 'saint kitts and nevis';
                    }
                    else if (vertexCountry.equalsIgnoreCase('Trinidad & Tobago')) {
                        vertexCountry = 'trinidad and tobago';
                    }
                    else if (vertexCountry.equalsIgnoreCase('Turks & Caicos Islands')) {
                        vertexCountry = 'turks and caicos islands';
                    }
                    else if (vertexCountry.equalsIgnoreCase('North Macedonia')) {
                        vertexCountry = 'macedonia, republic of';
                    }
                    else if (vertexCountry.equalsIgnoreCase('Antigua & Barbuda')) {
                        vertexCountry = 'antigua and barbuda';
                    }
                    else if (vertexCountry.equalsIgnoreCase('CN')) {
                        vertexCountry = 'china';
                    }
                    else if (vertexCountry.equalsIgnoreCase('Iran')) {
                        vertexCountry = 'iran, islamic republic of';
                    }
                    else if (vertexCountry.equalsIgnoreCase('Tanzania')) {
                        vertexCountry = 'tanzania, united republic of';
                    }
                    else if (vertexCountry.equalsIgnoreCase(Label.VertexCountry_1)) {
                        vertexCountry = Label.VertexCountry_A;
                    }
                    else if (vertexCountry.equalsIgnoreCase(Label.VertexCountry_2)) {
                        vertexCountry = Label.VertexCountry_B;
                    }
                    else if (vertexCountry.equalsIgnoreCase(Label.VertexCountry_3)) {
                        vertexCountry = Label.VertexCountry_C;
                    }
                    else if (vertexCountry.equalsIgnoreCase(Label.VertexCountry_4)) {
                        vertexCountry = Label.VertexCountry_D;
                    }
                    else if (vertexCountry.equalsIgnoreCase(Label.VertexCountry_5)) {
                        vertexCountry = Label.VertexCountry_E;
                    }
                 
                }
                record.put(vertexCountryFieldName, vertexCountry);
            }
        }
    }

    private static Boolean isRecordUpdated(
            SObject record,
            Map<Id, SObject> oldRecords,
            String countryFieldName,
            String countryCodeFieldName
    ) {
        Boolean isChanged = !oldRecords.containsKey(record.Id);
        if (oldRecords.containsKey(record.Id)) {
            SObject oldRecord = oldRecords.get(record.Id);
            isChanged |= countryFieldName != null && ((String) record.get(countryFieldName)) != ((String) oldRecord.get(countryFieldName));
            isChanged |= countryCodeFieldName != null && ((String) record.get(countryCodeFieldName)) != ((String) oldRecord.get(countryCodeFieldName));
        }
        return isChanged;
    }

    private static List<CountrySettings__mdt> getRelatedCountrySettings(
            List<SObject> records,
            String countryFieldName,
            String countryCodeFieldName
    ) {
        Set<String> countriesToSearch = new Set<String>();
        Set<String> countryCodesToSearch = new Set<String>();
        for (SObject record : records) {
            if (countryFieldName != null && record.get(countryFieldName) != null) {
                countriesToSearch.add((String) record.get(countryFieldName));
            }
            if (countryCodeFieldName != null && record.get(countryCodeFieldName) != null) {
                countryCodesToSearch.add((String) record.get(countryCodeFieldName));
            }
        }
        List<CountrySettings__mdt> queriedCountrySettings = new List<CountrySettings__mdt>();
        if (!countriesToSearch.isEmpty()) {
            queriedCountrySettings.addAll(queryCountrySettings(CountrySettings__mdt.MasterLabel.getDescribe().getName(), countriesToSearch, queriedCountrySettings));
            queriedCountrySettings.addAll(queryCountrySettings(CountrySettings__mdt.IsoCode_2__c.getDescribe().getName(), countriesToSearch, queriedCountrySettings));
            queriedCountrySettings.addAll(queryCountrySettings(CountrySettings__mdt.IsoCode_3__c.getDescribe().getName(), countriesToSearch, queriedCountrySettings));
            queriedCountrySettings.addAll(queryCountrySettings(CountrySettings__mdt.IsoCode__c.getDescribe().getName(), countriesToSearch, queriedCountrySettings));
        }
        if (!countryCodesToSearch.isEmpty()) {
            queriedCountrySettings.addAll(queryCountrySettings(CountrySettings__mdt.IsoCode_2__c.getDescribe().getName(), countryCodesToSearch, queriedCountrySettings));
            queriedCountrySettings.addAll(queryCountrySettings(CountrySettings__mdt.IsoCode_3__c.getDescribe().getName(), countryCodesToSearch, queriedCountrySettings));
            queriedCountrySettings.addAll(queryCountrySettings(CountrySettings__mdt.IsoCode__c.getDescribe().getName(), countryCodesToSearch, queriedCountrySettings));
        }
        return queriedCountrySettings;
    }

    private static List<CountrySettings__mdt> queryCountrySettings(
            String searchField,
            Set<String> searchValues,
            List<CountrySettings__mdt> recordsToSkip
    ) {
        final String queryString =
                'SELECT MasterLabel, DeveloperName, IsoCode_3__c, IsoCode_2__c, Isocode__c, Continent__c, Region__c, Named_Territory__c, SubTerritory__c ' +
                        'FROM CountrySettings__mdt ' +
                        'WHERE ' + searchField + ' IN :searchValues';
        final String skipRecordsFilter =
                recordsToSkip != null && !recordsToSkip.isEmpty() ?
                        ' AND Id NOT IN :recordsToSkip' :
                        '';
        return (List<CountrySettings__mdt>) Database.query(queryString + skipRecordsFilter);
    }

}