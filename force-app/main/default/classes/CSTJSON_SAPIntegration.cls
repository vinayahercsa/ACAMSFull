public class CSTJSON_SAPIntegration {

    public SalesOrder salesOrder;
    public NumberObject lineNumber;
    public NumberObject subLineNumber;
    public EventType eventType;
    public String compensationDate;
    public String accountingDate;
    public String productId;
    public NumberObject unitValue;
    public NumberObject value;
    public NumberObject numberOfUnits;
    public List<UnitType> businessUnits;
    public String paymentTerms;
    public String alternateOrderNumber;
    public BillToAddress billToAddress;
    public String genericAttribute1;
    public String genericAttribute2;
    public String genericAttribute3;
    public String genericAttribute4;
    public String genericAttribute5;
    public String genericAttribute6;
    public String genericAttribute7;
    public String genericAttribute8;
    public String genericAttribute9;
    public String genericAttribute10;
    public String genericAttribute11;
    public String genericAttribute12;
    public String genericAttribute13;
    public String genericAttribute14;
    public String genericAttribute15;
    public String genericAttribute16;
    public String genericDate1;
    public String originTypeId;
    
    public CSTJSON_SAPIntegration(String sOrder, NumberObject lNumber, NumberObject subLNumber, String eventTypeId, String compDate, String accDate, String prodId, NumberObject unitVal, NumberObject val, NumberObject nou, String bUnits, String pTerms, String aoNumber, BillToAddress bta, String ga1, String ga2, String ga3, String ga4, String ga5, String ga6, String ga7, String ga8, String ga9, String ga10, String ga11, String ga12, String ga13, String ga14, String ga15, String ga16, String gd1, String oTypeId){

        salesOrder = new SalesOrder(sOrder);
        lineNumber = lNumber;
        subLineNumber = subLNumber;
        eventType = new EventType(eventTypeId);
        compensationDate = compDate;
        accountingDate = accDate;
        productId = prodId;
        unitValue = unitVal;
        value = val;
        numberOfUnits = nou;
        businessUnits = new List<UnitType>();
        businessUnits.add(new UnitType(bUnits));
        paymentTerms = pTerms;
        alternateOrderNumber = aoNumber;
        billToAddress = bta;
        genericAttribute1 = ga1;
        genericAttribute2 = ga2;
        genericAttribute3 = ga3;
        genericAttribute4 = ga4;
        genericAttribute5 = ga5;
        genericAttribute6 = ga6;
        genericAttribute7 = ga7;
        genericAttribute8 = ga8;
        genericAttribute9 = ga9;
        genericAttribute10 = ga10;
        genericAttribute11 = ga11;
        genericAttribute12 = ga12;
        genericAttribute13 = ga13;
        genericAttribute14 = ga14;
        genericAttribute15 = ga15;
        genericAttribute16 = ga16;
        genericDate1 = gd1;
        originTypeId = oTypeId;
    }
}