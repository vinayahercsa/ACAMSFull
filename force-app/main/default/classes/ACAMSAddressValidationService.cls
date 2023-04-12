@RestResource(UrlMapping='/api/address/validate')
global with sharing class ACAMSAddressValidationService {

    /* Static data to create a callout and parse the response */

    private static final String REQUEST_BODY = '' +
        '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:vertexinc:o-series:tps:9:0">' +
        '<soapenv:Header/> <soapenv:Body> <urn:VertexEnvelope> <urn:Login>' +
        '<urn:UserName>{0}</urn:UserName> <urn:Password>{1}</urn:Password> <urn:TrustedId>{2}</urn:TrustedId>' +
        '</urn:Login> <urn:FindTaxAreasRequest> <urn:TaxAreaLookup> <urn:PostalAddress>' +
        '<urn:StreetAddress1>{3}</urn:StreetAddress1> <urn:StreetAddress2>{4}</urn:StreetAddress2>' +
        '<urn:City>{5}</urn:City> <urn:MainDivision>{6}</urn:MainDivision> <urn:PostalCode>{7}</urn:PostalCode>' +
        '<urn:Country>{8}</urn:Country> </urn:PostalAddress> </urn:TaxAreaLookup> </urn:FindTaxAreasRequest>' +
        '</urn:VertexEnvelope> </soapenv:Body> </soapenv:Envelope>';

    private static final String HTTP_METHOD = 'POST';
    private static final String HTTP_CONTENT_TYPE_HEADER_NAME = 'Content-Type';
    private static final String HTTP_CONTENT_TYPE_HEADER_VALUE = 'text/xml';
    private static final String HTTP_ENDPOINT = 'callout:Vertex_Ondemand_Adtalem';
    private static final Integer HTTP_STATUS_CODE_OK = 200;

    private static final String SOAP_NS_VERTEX = 'urn:vertexinc:o-series:tps:9:0';
    private static final String SOAP_NS_ENVELOPE = 'http://schemas.xmlsoap.org/soap/envelope/';
    private static final String SOAP_BODY = 'Body';
    private static final String VERTEX_ENVELOPE = 'VertexEnvelope';
    private static final String VERTEX_RESPONSE = 'FindTaxAreasResponse';
    private static final String VERTEX_TAX_AREA_LOOKUP_RESULT = 'TaxAreaLookupResult';
    private static final String VERTEX_TAX_AREA_RESULT = 'TaxAreaResult';
    private static final String ATTRIBUTE_AREA_ID = 'taxAreaId';
    private static final String ATTRIBUTE_CONFIDENCE_INDICATOR = 'confidenceIndicator';

    private static final String VERTEX_POSTAL_ADDRESS = 'PostalAddress';
    private static final String VERTEX_POSTAL_ADDRESS_LINE_1 = 'StreetAddress1';
    private static final String VERTEX_POSTAL_ADDRESS_LINE_2 = 'StreetAddress2';
    private static final String VERTEX_POSTAL_ADDRESS_CITY = 'City';
    private static final String VERTEX_POSTAL_ADDRESS_STATE_CODE = 'MainDivision';
    private static final String VERTEX_POSTAL_ADDRESS_POSTAL_CODE = 'PostalCode';
    private static final String VERTEX_POSTAL_ADDRESS_COUNTRY_CODE = 'Country';

    private static final String VERTEX_LOOKUP_EXCEPTION = 'LookupException';
    private static final String VERTEX_ROOT_CAUSE = 'RootCause';
    private static final String EXCEPTION_SETTINGS_INVALID = 'Custom Setting "Vertex Settings" is invalid';

    /* Custom Setting Vertex Settings */

    private static VertexSettings__c vertexSettings = VertexSettings__c.getInstance();

    /* Field names for work with different SObject types */

    private final String addressLine1FieldName;
    private final String addressLine2FieldName;
    private final String cityFieldName;
    private final String stateCodeFieldName;
    private final String countryCodeFieldName;
    private final String postalCodeFieldName;
    private final String taxAreaIdFieldName;
    private final String taxAreaConfidenceFieldName;

    public ACAMSAddressValidationService(
        String addressLine1FieldName,
        String addressLine2FieldName,
        String cityFieldName,
        String stateCodeFieldName,
        String countryCodeFieldName,
        String postalCodeFieldName,
        String taxAreaIdFieldName,
        String taxAreaConfidenceFieldName
    ) {
        this.addressLine1FieldName = addressLine1FieldName;
        this.addressLine2FieldName = addressLine2FieldName;
        this.cityFieldName = cityFieldName;
        this.stateCodeFieldName = stateCodeFieldName;
        this.countryCodeFieldName = countryCodeFieldName;
        this.postalCodeFieldName = postalCodeFieldName;
        this.taxAreaIdFieldName = taxAreaIdFieldName;
        this.taxAreaConfidenceFieldName = taxAreaConfidenceFieldName;
    }

    /* Pre-defined services */

    public static ACAMSAddressValidationService getContactAddressValidationService() {
        return new ACAMSAddressValidationService(
            ccrz__E_ContactAddr__c.ccrz__AddressFirstline__c.getDescribe().getName(),
            ccrz__E_ContactAddr__c.ccrz__AddressSecondline__c.getDescribe().getName(),
            ccrz__E_ContactAddr__c.ccrz__City__c.getDescribe().getName(),
            ccrz__E_ContactAddr__c.ccrz__State__c.getDescribe().getName(),
            ccrz__E_ContactAddr__c.ccrz__CountryISOCode__c.getDescribe().getName(),
            ccrz__E_ContactAddr__c.ccrz__PostalCode__c.getDescribe().getName(),
            ccrz__E_ContactAddr__c.Vertex_Tax_Area_Id__c.getDescribe().getName(),
            ccrz__E_ContactAddr__c.Vertex_Tax_Area_Confidence__c.getDescribe().getName()
        );
    }

    public static ACAMSAddressValidationService getProductValidationService() {
        return new ACAMSAddressValidationService(
            ccrz__E_Product__c.Event_Address_Street_1__c.getDescribe().getName(),
            ccrz__E_Product__c.Event_Address_Street_2__c.getDescribe().getName(),
            ccrz__E_Product__c.Event_Address_City__c.getDescribe().getName(),
            ccrz__E_Product__c.Event_Address_State__c.getDescribe().getName(),
            ccrz__E_Product__c.Event_Address_Country__c.getDescribe().getName(),
            ccrz__E_Product__c.Event_Address_Zip__c.getDescribe().getName(),
            ccrz__E_Product__c.Event_Tax_Area_Id__c.getDescribe().getName(),
            null
        );
    }

    /* Public methods */

    public void identifyAddressTaxAreaIdAsync(List<SObject> addresses) {
        if(!system.isFuture()){
        AddressValidationRequestInvocation invocation = new AddressValidationRequestInvocation(addresses, this);
        System.enqueueJob(invocation);
        }
    }

    public List<TaxAreaValidationResult> getAddressTaxAreaId(List<SObject> addresses) {
        List<TaxAreaValidationResult> results = new List<TaxAreaValidationResult>();
        for (SObject address : addresses) {
            results.add(getAddressTaxAreaId(address));
        }
        return results;
    }

    public TaxAreaValidationResult getAddressTaxAreaId(SObject address) {
        TaxAreaValidationResult validationResult = new TaxAreaValidationResult();
        if (isSettingsValid()) {
            String requestBody = getRequestBody(address);
            HttpResponse response = sendVertexApiRequest(requestBody);
            if (isRequestOk(response)) {
                validationResult = parseResponse(response);
            }
        } else {
            validationResult.isSuccess = false;
            validationResult.exceptionDetails = EXCEPTION_SETTINGS_INVALID;
        }
        return validationResult;
    }

    /* Inner classes for async Callout Invocation */

    private class AddressValidationRequestInvocation implements Queueable, Database.AllowsCallouts {
        private List<SObject> addresses;
        private ACAMSAddressValidationService validationService;
        public AddressValidationRequestInvocation(
            List<SObject> addresses,
            ACAMSAddressValidationService validationService
        ) {
            this.addresses = addresses;
            this.validationService = validationService;
        }
        public void execute(QueueableContext context) {
            List<SObject> currentInvocationAddresses = new List<SObject>();
            List<SObject> chainedInvocationAddresses = new List<SObject>();
            this.splitAddressListToChained(currentInvocationAddresses, chainedInvocationAddresses);
            if (!currentInvocationAddresses.isEmpty()) {
                List<TaxAreaValidationResult> results = this.validationService.getAddressTaxAreaId(
                    currentInvocationAddresses
                );
                this.validationService.updateAddressesWithTaxAreaIds(currentInvocationAddresses, results);
            }
            if (!chainedInvocationAddresses.isEmpty()) {
                AddressValidationRequestInvocation chainedInvocation =
                    new AddressValidationRequestInvocation(chainedInvocationAddresses, this.validationService);
                System.enqueueJob(chainedInvocation);
            }
        }

        private void splitAddressListToChained(
            List<SObject> currentInvocationAddresses,
            List<SObject> chainedInvocationAddresses
        ) {
            if (this.addresses.size() > Limits.getLimitCallouts()) {
                Integer i = 0;
                for (; i < Limits.getLimitCallouts(); i++) {
                    currentInvocationAddresses.add(this.addresses.get(i));
                }
                for (; i < this.addresses.size(); i++) {
                    chainedInvocationAddresses.add(this.addresses.get(i));
                }
            } else {
                currentInvocationAddresses.addAll(this.addresses);
            }
        }
    }

    /* Response data class */

    global class TaxAreaValidationResult {
        public Boolean isSuccess           { get; set; }
        public Decimal taxAreaId           { get; set; }
        public Decimal confidenceIndicator { get; set; }
        public String  exceptionDetails    { get; set; }

        public Boolean addressFilled       { get; set; }
        public String  addressLine1        { get; set; }
        public String  addressLine2        { get; set; }
        public String  city                { get; set; }
        public String  stateCode           { get; set; }
        public String  countryCode         { get; set; }
        public String  postalCode          { get; set; }
        public Boolean addressChanged      { get; set; }

        public TaxAreaValidationResult() {
            this.isSuccess           = false;
            this.taxAreaId           = -1;
            this.confidenceIndicator = 0;
            this.exceptionDetails    = '';
            this.addressFilled       = false;
            this.addressLine1        = '';
            this.addressLine2        = '';
            this.City                = '';
            this.StateCode           = '';
            this.CountryCode         = '';
            this.PostalCode          = '';
            this.addressChanged      = false;
        }
    }

    /* private methods */

    private Boolean fieldNamesAreFilled() {
        return (
            !String.isBlank(this.addressLine1FieldName) ||
            !String.isBlank(this.addressLine2FieldName) ||
            !String.isBlank(this.cityFieldName)         ||
            !String.isBlank(this.stateCodeFieldName)    ||
            !String.isBlank(this.countryCodeFieldName)  ||
            !String.isBlank(this.postalCodeFieldName)   ||
            !String.isBlank(this.taxAreaIdFieldName)    ||
            !String.isBlank(this.taxAreaConfidenceFieldName)
        );
    }

    private Boolean isSettingsValid() {
        return (
            vertexSettings.Successful_Confidence_Threshold__c != null &&
            vertexSettings.Successful_Confidence_Threshold__c > -1 &&
            (
                !String.isBlank(vertexSettings.TrustedId__c) ||
                (
                    !String.isBlank(vertexSettings.Username__c) &&
                    !String.isBlank(vertexSettings.Password__c)
                )
            )
        );
    }

    private String getRequestBody(SObject address) {
        List<String> requestBodyParams = new List<String> {
            escapeNullString(vertexSettings.Username__c),
            escapeNullString(vertexSettings.Password__c),
            escapeNullString(vertexSettings.TrustedId__c),
            getIfFieldNameExists(address, this.addressLine1FieldName),
            getIfFieldNameExists(address, this.addressLine2FieldName),
            getIfFieldNameExists(address, this.cityFieldName),
            getIfFieldNameExists(address, this.stateCodeFieldName),
            getIfFieldNameExists(address, this.postalCodeFieldName),
            getIfFieldNameExists(address, this.countryCodeFieldName)
        };
        return String.format(REQUEST_BODY, requestBodyParams);
    }

    private HttpResponse sendVertexApiRequest(String requestBody) {
        HttpRequest request = new HttpRequest();
        request.setMethod(HTTP_METHOD);
        request.setEndpoint(HTTP_ENDPOINT);
        request.setHeader(HTTP_CONTENT_TYPE_HEADER_NAME, HTTP_CONTENT_TYPE_HEADER_VALUE);
        request.setBodyAsBlob(Blob.valueOf(requestBody));

        Http httpService = new Http();
        HttpResponse response = httpService.send(request);
        return response;
    }

    private TaxAreaValidationResult parseResponse(HttpResponse response) {
        TaxAreaValidationResult result = new TaxAreaValidationResult();
        DOM.Document document = response.getBodyDocument();
        Boolean exceptionReceived = false;
        try {
            List<Dom.XmlNode> informativeNodes =
                document
                    .getRootElement()
                    .getChildElement(SOAP_BODY, SOAP_NS_ENVELOPE)
                    .getChildElement(VERTEX_ENVELOPE, SOAP_NS_VERTEX)
                    .getChildElement(VERTEX_RESPONSE, SOAP_NS_VERTEX)
                    .getChildElement(VERTEX_TAX_AREA_LOOKUP_RESULT, SOAP_NS_VERTEX)
                    .getChildElements();
            Dom.XmlNode bestResponseNode = null;
            for (Dom.XmlNode informativeNode : informativeNodes) {
                if (informativeNode.getName() == VERTEX_TAX_AREA_RESULT) {
                    Decimal confidenceIndicator = Decimal.valueOf(
                        informativeNode.getAttribute(ATTRIBUTE_CONFIDENCE_INDICATOR, null)
                    );
                    Decimal taxAreaId = Decimal.valueOf(
                        informativeNode.getAttribute(ATTRIBUTE_AREA_ID, null)
                    );
                    if (confidenceIndicator > result.confidenceIndicator) {
                        result.confidenceIndicator = confidenceIndicator;
                        result.taxAreaId = taxAreaId;
                        bestResponseNode = informativeNode;
                    }
                } else if (informativeNode.getName() == VERTEX_LOOKUP_EXCEPTION) {
                    result.exceptionDetails = getChildElementText(informativeNode, VERTEX_ROOT_CAUSE);
                    exceptionReceived = true;
                }
            }
            if (bestResponseNode != null) {
                fillAddressLines(bestResponseNode, result);
            }
        } catch (Exception e) {
            exceptionReceived = true;
            result.exceptionDetails = e.getMessage();
        }
        result.isSuccess = isResultSuccessful(result, exceptionReceived);
        return result;
    }

    private void updateAddressesWithTaxAreaIds(
        List<SObject> addresses,
        List<TaxAreaValidationResult> validationResults
    ) {
        List<SObject> addressesToUpdate = new List<SObject>();
        if (
            addresses == null ||
            validationResults == null ||
            addresses.size() != validationResults.size() ||
            addresses.isEmpty() ||
            !this.fieldNamesAreFilled()
        ) {
            return;
        }
        for (Integer i = 0; i < addresses.size(); i++) {
            Id addressId = addresses.get(i).Id;
            TaxAreaValidationResult result = validationResults.get(i);
            if (!String.isBlank(addressId) && result.isSuccess) {
                SObject addressToUpdate = addressId.getSobjectType().newSObject(addressId);
                putIfFieldNameExists(addressToUpdate, this.taxAreaIdFieldName, result.taxAreaId);
                putIfFieldNameExists(addressToUpdate, this.taxAreaConfidenceFieldName, result.confidenceIndicator);
                if (result.addressFilled) {
                    putIfFieldNameExists(addressToUpdate, this.addressLine1FieldName, result.addressLine1);
                    putIfFieldNameExists(addressToUpdate, this.cityFieldName, result.city);
                    putIfFieldNameExists(addressToUpdate, this.stateCodeFieldName, result.stateCode);
                    putIfFieldNameExists(addressToUpdate, this.countryCodeFieldName, result.countryCode == 'USA' ? 'US' : result.countryCode);
                    putIfFieldNameExists(addressToUpdate, this.postalCodeFieldName, result.postalCode);
                }
                addressesToUpdate.add(addressToUpdate);
            }
        }
        if (!addressesToUpdate.isEmpty()) {
            Boolean initialSkipAddressValidationValue = ACAMSContactAddressTriggerHandler.skipAddressValidation;
            ACAMSContactAddressTriggerHandler.skipAddressValidation = true;
            List<Database.SaveResult> saveResults = Database.update(addressesToUpdate, false);
            ACAMSContactAddressTriggerHandler.skipAddressValidation = initialSkipAddressValidationValue;
        }
    }

    private String escapeNullString(String targetString) {
        return targetString == null ? '' : targetString;
    }

    private String getIfFieldNameExists(SObject record, String fieldName) {
        return String.isBlank(fieldName) ? '' : this.escapeNullString((String) record.get(fieldName)).escapeXml();
    }

    private void putIfFieldNameExists(SObject record, String fieldName, Object value) {
        if (!String.isBlank(fieldName)) {
            record.put(fieldName, value);
        }
    }

    private Boolean isRequestOk(HttpResponse response) {
        return response.getStatusCode() == HTTP_STATUS_CODE_OK;
    }

    private Boolean isResultSuccessful(TaxAreaValidationResult result, Boolean exceptionReceived) {
        return (
            !exceptionReceived &&
            result.taxAreaId > -1 &&
            result.confidenceIndicator > vertexSettings.Successful_Confidence_Threshold__c
        );
    }

    private void fillAddressLines(Dom.XmlNode sourceNode, TaxAreaValidationResult result) {
        try {
            Dom.XmlNode addressNode = sourceNode.getChildElement(VERTEX_POSTAL_ADDRESS, SOAP_NS_VERTEX);
            result.addressFilled = (addressNode != null);
            if (result.addressFilled) {
                result.addressLine1  = getChildElementText(addressNode, VERTEX_POSTAL_ADDRESS_LINE_1);
                result.addressLine2  = getChildElementText(addressNode, VERTEX_POSTAL_ADDRESS_LINE_2);
                result.city          = getChildElementText(addressNode, VERTEX_POSTAL_ADDRESS_CITY);
                result.stateCode     = getChildElementText(addressNode, VERTEX_POSTAL_ADDRESS_STATE_CODE);
                result.countryCode   = getChildElementText(addressNode, VERTEX_POSTAL_ADDRESS_COUNTRY_CODE);
                result.postalCode    = getChildElementText(addressNode, VERTEX_POSTAL_ADDRESS_POSTAL_CODE);
            }
        } catch (Exception e) {
            result.addressFilled = false;
        }
    }

    private String getChildElementText(Dom.XmlNode parentNode, String childNodeName) {
        if (parentNode.getChildElement(childNodeName, SOAP_NS_VERTEX) != null) {
            return parentNode.getChildElement(childNodeName, SOAP_NS_VERTEX).getText();
        }
        return null;
    }

    /* HTTP endpoint */

    @HttpPost
    global static TaxAreaValidationResult validateAddress(String addressFirstLine, String addressSecondLine, String city, String state, String country, String postalCode) {
        ACAMSAddressValidationService.TaxAreaValidationResult validationResult =
                new ACAMSAddressValidationService.TaxAreaValidationResult();
        Boolean requiredFieldsMissing = false;
        if (String.isBlank(addressFirstLine)) {
            requiredFieldsMissing = true;
            validationResult.exceptionDetails = Label.ACAMSAddressValidation_AddressEmpty;
        }
        if (String.isBlank(city)) {
            requiredFieldsMissing = true;
            validationResult.exceptionDetails = Label.ACAMSAddressValidation_CityEmpty;
        }
        if (String.isBlank(country)) {
            requiredFieldsMissing = true;
            validationResult.exceptionDetails = Label.ACAMSAddressValidation_CountryEmpty;
        }
        if (!requiredFieldsMissing) {
            ccrz__E_ContactAddr__c contactAddr = new ccrz__E_ContactAddr__c();
            contactAddr.ccrz__AddressFirstline__c  = addressFirstLine;
            contactAddr.ccrz__AddressSecondline__c = addressSecondLine;
            contactAddr.ccrz__City__c              = city;
            contactAddr.ccrz__State__c             = state;
            contactAddr.ccrz__StateISOCode__c      = country == 'USA' || country == 'CA' ? state : null;
            contactAddr.ccrz__CountryISOCode__c    = country == 'USA' ? 'US' : country;
            contactAddr.ccrz__PostalCode__c        = postalCode;
            validationResult = ACAMSAddressValidationService.getContactAddressValidationService().getAddressTaxAreaId(contactAddr);
            validationResult.countryCode = validationResult.countryCode == 'USA' ? 'US' : validationResult.countryCode;
            if (validationResult.addressFilled) {
                String newAddressLine2 = String.isNotBlank(validationResult.addressLine2) ?
                        validationResult.addressLine2 : '';
                String oldAddressSecondLine = String.isNotBlank(addressSecondLine) ? addressSecondLine : '';

                if (validationResult.addressLine1 == addressFirstLine &&
                        newAddressLine2 == oldAddressSecondLine &&
                        validationResult.city == city &&
                        validationResult.stateCode == state &&
                        validationResult.countryCode == country &&
                        validationResult.postalCode == postalCode) {
                    validationResult.addressChanged = false;
                } else {
                    validationResult.addressChanged = true;
                }
            }
        }
        return validationResult;
    }
}