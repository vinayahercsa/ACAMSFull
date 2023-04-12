public class CSOJSON_SAPIntegration {

    public String orderId;
    public List<UnitType> businessUnits;
    
    public CSOJSON_SAPIntegration(String oId, String bUnits){
        
        orderId = oId;
        businessUnits = new List<UnitType>();
        businessUnits.add(new UnitType(bUnits));
    }
}