public class NumberObject {

    public Decimal value;
    public UnitType unitType;
    
    public NumberObject(Decimal val, String uType){
        
        value = val;
        unitType = new UnitType(uType);
    }
}