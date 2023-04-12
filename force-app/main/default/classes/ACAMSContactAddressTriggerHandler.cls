public with sharing class ACAMSContactAddressTriggerHandler extends CCAviTriggerHandler {
    private List<ccrz__E_ContactAddr__c> newList = (List<ccrz__E_ContactAddr__c>) Trigger.new;
    private List<ccrz__E_ContactAddr__c> oldList = (List<ccrz__E_ContactAddr__c>) Trigger.old;
    private Map<Id, ccrz__E_ContactAddr__c> newMap = (Map<Id, ccrz__E_ContactAddr__c>) Trigger.newMap;
    private Map<Id, ccrz__E_ContactAddr__c> oldMap = (Map<Id, ccrz__E_ContactAddr__c>) Trigger.oldMap;

    public static Boolean skipAddressValidation = false;
    public static Boolean skipCountryFieldsCalculation = false;

    protected override void beforeInsert() {
        validatePhoneNumbers();
        updateStateValues();
        this.updateRegionField();
        updateCityField();
    }

    protected override void beforeUpdate() {
        validatePhoneNumbers();
        updateStateValues();
        this.updateRegionField();
        updateCityField();
    }

    protected override void afterInsert() {
        if (!skipAddressValidation) {
            ACAMSAddressValidationService.getContactAddressValidationService()
                    .identifyAddressTaxAreaIdAsync(this.newList);
        }
    }

    protected override void afterUpdate() {
        updateDefaultAccountAddressInfo();
        if (!skipAddressValidation) {
            updateAddressesTaxAreaIds();
        }
        Set<Id> contactAddrIds = new Set<Id>();
        for (ccrz__E_ContactAddr__c contactAddr : this.newList) {
            Decimal oldTaxAreaId = oldMap.get(contactAddr.Id).Vertex_Tax_Area_Id__c;
            Decimal newTaxAreaId = contactAddr.Vertex_Tax_Area_Id__c;
            if (oldTaxAreaId != newTaxAreaId) {
                contactAddrIds.add(contactAddr.Id);
            }
        }
        /*csa-fixed-removed method calling from for loop
        for (ccrz__E_Cart__c cart : [
                SELECT Id
                FROM ccrz__E_Cart__c
                WHERE (ccrz__BillTo__c IN :contactAddrIds
                OR ccrz__ShipTo__c IN :contactAddrIds)
                AND Destination_Country__c != 'China'
        ]) {
            Vertex.VertexAnyRequest.InvokeAnyRequestStructure request =
                    new Vertex.VertexAnyRequest.InvokeAnyRequestStructure();
            request.recordId = cart.Id;
            request.type = 'CC Cart';
            Vertex_Tax_Calculation_Bypass__c bypassSettings = Vertex_Tax_Calculation_Bypass__c.getInstance();
            if (!bypassSettings.Bypass_Cart_Tax_Calculation__c) {
                Vertex.VertexAnyRequest.InvokeAllRequests(
                        new List<Vertex.VertexAnyRequest.InvokeAnyRequestStructure>{
                                request
                        }
                );
            }
        }
        for (ccrz__E_Order__c order : [
                SELECT Id
                FROM ccrz__E_Order__c
                WHERE (ccrz__BillTo__c IN :contactAddrIds
                OR ccrz__ShipTo__c IN :contactAddrIds)
                AND Destination_Country__c != 'China'
        ]) {
            Vertex.VertexAnyRequest.InvokeAnyRequestStructure request =
                    new Vertex.VertexAnyRequest.InvokeAnyRequestStructure();
            request.recordId = order.Id;
            request.type = 'CC Order';
            Vertex_Tax_Calculation_Bypass__c bypassSettings = Vertex_Tax_Calculation_Bypass__c.getInstance();
            if (!bypassSettings.Bypass_Cart_Tax_Calculation__c) {
                Vertex.VertexAnyRequest.InvokeAllRequests(
                        new List<Vertex.VertexAnyRequest.InvokeAnyRequestStructure>{
                                request
                        }
                );
            }
        }*/
List<Vertex.VertexAnyRequest.InvokeAnyRequestStructure> requestList = new List<Vertex.VertexAnyRequest.InvokeAnyRequestStructure>();
Vertex.VertexAnyRequest.InvokeAnyRequestStructure request=new Vertex.VertexAnyRequest.InvokeAnyRequestStructure();

for (ccrz__E_Cart__c cart : [
        SELECT Id
        FROM ccrz__E_Cart__c
        WHERE (ccrz__BillTo__c IN :contactAddrIds
        OR ccrz__ShipTo__c IN :contactAddrIds)
        AND Destination_Country__c != 'China'
]) {
    request.recordId = cart.Id;
    request.type = 'CC Cart';
    Vertex_Tax_Calculation_Bypass__c bypassSettings = Vertex_Tax_Calculation_Bypass__c.getInstance();
    if (!bypassSettings.Bypass_Cart_Tax_Calculation__c) {
        requestList.add(request);
    }
}

for (ccrz__E_Order__c order : [
        SELECT Id
        FROM ccrz__E_Order__c
        WHERE (ccrz__BillTo__c IN :contactAddrIds
        OR ccrz__ShipTo__c IN :contactAddrIds)
        AND Destination_Country__c != 'China'
]) {
    request.recordId = order.Id;
    request.type = 'CC Order';
    Vertex_Tax_Calculation_Bypass__c bypassSettings = Vertex_Tax_Calculation_Bypass__c.getInstance();
    if (!bypassSettings.Bypass_Cart_Tax_Calculation__c) {
        requestList.add(request);
    }
}
if (requestList.size() > 0) {
    //CSA-fix - Created platform event to solve the issue
    List<Vertex_Request_PE__e> vertexRequestPlatformEvents = new List<Vertex_Request_PE__e>();
    for(Vertex.VertexAnyRequest.InvokeAnyRequestStructure req : requestList){
        vertexRequestPlatformEvents.add(new Vertex_Request_PE__e(RecordId__c=req.recordId,Type__c = req.type));
    
    }
    List<Database.SaveResult> results = EventBus.publish(vertexRequestPlatformEvents);

    // Inspect publishing result for each event
    for (Database.SaveResult sr : results) {
        if (sr.isSuccess()) {
            System.debug('Successfully published event.');
        } else {
            for(Database.Error err : sr.getErrors()) {
                System.debug('Error returned: ' +
                                err.getStatusCode() +
                                ' - ' +
                                err.getMessage());
            }
        }       
    }
    //Vertex.VertexAnyRequest.InvokeAllRequests(requestList);
}

       
    }

    private void updateAddressesTaxAreaIds() {
        List<ccrz__E_ContactAddr__c> addressesToUpdateTaxAreaId = new List<ccrz__E_ContactAddr__c>();
        for (ccrz__E_ContactAddr__c currentAddress : this.newList) {
            if (isAddressDataUpdated(currentAddress)) {
                addressesToUpdateTaxAreaId.add(currentAddress);
            }
        }
        if (!addressesToUpdateTaxAreaId.isEmpty()) {
            ACAMSAddressValidationService.getContactAddressValidationService()
                    .identifyAddressTaxAreaIdAsync(addressesToUpdateTaxAreaId);
        }
    }

    private void updateRegionField() {
        if (!skipCountryFieldsCalculation) {
            ACAMSAddressFieldsService.beforeTriggerCall(
                    this.newList,
                    this.oldMap,
                    ccrz__E_ContactAddr__c.ccrz__Country__c.getDescribe().getName(),
                    ccrz__E_ContactAddr__c.ccrz__CountryISOCode__c.getDescribe().getName(),
                    ccrz__E_ContactAddr__c.Region__c.getDescribe().getName(),
                    ccrz__E_ContactAddr__c.Continent__c.getDescribe().getName(),
                    ccrz__E_ContactAddr__c.Named_Territory__c.getDescribe().getName(),
                    ccrz__E_ContactAddr__c.SubTerritory__c.getDescribe().getName(),
                    ccrz__E_ContactAddr__c.Vertex_Country__c.getDescribe().getName()
            );
        }
    }

    private Boolean isAddressDataUpdated(ccrz__E_ContactAddr__c address) {
        ccrz__E_ContactAddr__c previousAddress = this.oldMap.get(address.Id);
        return (
                previousAddress != null && (
                        previousAddress.ccrz__AddressFirstline__c != address.ccrz__AddressFirstline__c ||
                                previousAddress.ccrz__AddressSecondline__c != address.ccrz__AddressSecondline__c ||
                                previousAddress.ccrz__City__c != address.ccrz__City__c ||
                                previousAddress.ccrz__StateISOCode__c != address.ccrz__StateISOCode__c ||
                                previousAddress.ccrz__State__c != address.ccrz__State__c ||
                                previousAddress.ccrz__PostalCode__c != address.ccrz__PostalCode__c ||
                                previousAddress.ccrz__CountryISOCode__c != address.ccrz__CountryISOCode__c ||
                                previousAddress.ccrz__Country__c != address.ccrz__Country__c
                )
        );
    }

    private void updateCityField() {
        for (ccrz__E_ContactAddr__c contactAddr : this.newList) {
            if (contactAddr.ccrz__CountryISOCode__c == 'SG' && String.isBlank(contactAddr.ccrz__City__c)) {
                contactAddr.ccrz__City__c = 'Singapore';
            }
        }
    }

    private void validatePhoneNumbers() {
        for (ccrz__E_ContactAddr__c contactAddr : newList) {
            Pattern phonePattern = ACAMSUtil.getPhoneFormattingPattern();
            String homePhone = contactAddr.ccrz__HomePhone__c;
            String daytimePhone = contactAddr.ccrz__DaytimePhone__c;
            if (homePhone != null && !phonePattern.matcher(homePhone).matches()) {
                contactAddr.ccrz__HomePhone__c.addError(ACAMSUtil.PHONE_NUMBER_FORMAT_ERROR);
            }
            if (daytimePhone != null && !phonePattern.matcher(daytimePhone).matches()) {
                contactAddr.ccrz__DaytimePhone__c.addError(ACAMSUtil.PHONE_NUMBER_FORMAT_ERROR);
            }
        }
    }

    private void updateDefaultAccountAddressInfo() {
        Set<Id> changedContactAddrs = new Set<Id>();
        for (ccrz__E_ContactAddr__c contactAddr : newList) {
            if (isAddressDataUpdated(contactAddr)) {
                changedContactAddrs.add(contactAddr.Id);
            }
        }

        List<ccrz__E_AccountAddressBook__c> accountAddressBooks = [
                SELECT
                        Id,
                        ccrz__AccountId__c,
                        ccrz__E_ContactAddress__c,
                        ccrz__Account__c,
                        ccrz__Default__c,
                        ccrz__AddressType__c
                FROM
                        ccrz__E_AccountAddressBook__c
                WHERE
                        ccrz__E_ContactAddress__c
                IN
                        :changedContactAddrs
                AND
                        ccrz__Default__c = TRUE
        ];

        ACAMSAddressHelper.updateAccountAddressInfo(accountAddressBooks);
    }

    /**
     * Fixes Vertex issues with sending Drupal state values from China and Vietnam
     */
    private void updateStateValues() {
        for (ccrz__E_ContactAddr__c contactAddr : newList) {
            String countryCode = contactAddr.ccrz__CountryISOCode__c;
            String state = contactAddr.ccrz__State__c;
            if (state != null && (countryCode == 'CN' || countryCode == 'VN')) {
                if (state.endsWith(' Sheng')) {
                    contactAddr.ccrz__State__c = state.replace(' Sheng', '');
                } else if (state.endsWith(' Shi')) {
                    contactAddr.ccrz__State__c = state.replace(' Shi', '');
                } else if (state.endsWith(' Province')) {
                    contactAddr.ccrz__State__c = state.replace(' Province', '');
                }
            }
        }
    }

}