@IsTest
global class ACAMSAddressValidationServiceMock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
                '<soapenv:Header/><soapenv:Body>' +
                '<VertexEnvelope xmlns="urn:vertexinc:o-series:tps:9:0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
                '<Login><TrustedId>$tr.BcTQ05Ym</TrustedId></Login><FindTaxAreasResponse><TaxAreaLookupResult>' +
                '<TaxAreaResult taxAreaId="50759991" confidenceIndicator="100">' +
                '<Jurisdiction jurisdictionLevel="COUNTRY" effectiveDate="2014-05-01" expirationDate="9999-12-31" jurisdictionId="1">UNITED STATES</Jurisdiction>' +
                '<Jurisdiction jurisdictionLevel="STATE" effectiveDate="2014-05-01" expirationDate="9999-12-31" jurisdictionId="2398">CALIFORNIA</Jurisdiction>' +
                '<Jurisdiction jurisdictionLevel="COUNTY" effectiveDate="2014-05-01" expirationDate="9999-12-31" jurisdictionId="3685">SAN FRANCISCO</Jurisdiction>' +
                '<Jurisdiction jurisdictionLevel="CITY" effectiveDate="2014-05-01" expirationDate="9999-12-31" jurisdictionId="3687">SAN FRANCISCO</Jurisdiction>' +
                '<Jurisdiction jurisdictionLevel="DISTRICT" effectiveDate="2014-05-01" expirationDate="9999-12-31" jurisdictionId="78112">BAY AREA RAPID TRANSIT DISTRICT (BART)</Jurisdiction>' +
                '<Jurisdiction jurisdictionLevel="DISTRICT" effectiveDate="2014-05-01" expirationDate="9999-12-31" jurisdictionId="98738">MOSCONE EXPANSION DISTRICT ZONE 1</Jurisdiction>' +
                '<Jurisdiction jurisdictionLevel="DISTRICT" effectiveDate="2014-05-01" expirationDate="9999-12-31" jurisdictionId="66691">PUBLIC FINANCE AUTHORITY (SFPF)</Jurisdiction>' +
                '<Jurisdiction jurisdictionLevel="DISTRICT" effectiveDate="2014-05-01" expirationDate="9999-12-31" jurisdictionId="98736">SAN FRANCISCO TOURISM IMPROVEMENT DISTRICT ZONE 1</Jurisdiction>' +
                '<Jurisdiction jurisdictionLevel="DISTRICT" effectiveDate="2014-05-01" expirationDate="9999-12-31" jurisdictionId="66690">TRANSPORTATION AUTHORITY (SFTA)</Jurisdiction>' +
                '<PostalAddress><StreetAddress1>415 Mission St</StreetAddress1><City>San Francisco</City><MainDivision>CA</MainDivision>' +
                '<SubDivision>San Francisco</SubDivision><PostalCode>94105-2533</PostalCode><Country>USA</Country>' +
                '</PostalAddress><Status lookupResult="NORMAL"/></TaxAreaResult></TaxAreaLookupResult></FindTaxAreasResponse>' +
                '<ApplicationData><ResponseTimeMS>53.1</ResponseTimeMS></ApplicationData></VertexEnvelope></soapenv:Body></soapenv:Envelope>');
        res.setStatusCode(200);
        return res;
    }

}