public class BillToAddress {

    public String country;
    public String address3;
    public String address2;
    public String city;
    public String address1;
    public String postalCode;
    public String industry;
    public String areaCode;
    public String phone;
    public String geography;
    public String contact;
    public String custId;
    public String company;
    public String state;
    public String fax;
    
    public BillToAddress(String count, String add3, String add2, String c, String add1, String pC, String ind, 
                         String aC, String ph, String geo, String con, String cId, String comp, String st, String f){
        
        country = count;
    	address3 = add3;
    	address2 = add2;
    	city = c;
    	address1 = add1;
    	postalCode = pC;
    	industry = ind;
    	areaCode = aC;
    	phone = ph;
    	geography = geo;
    	contact = con;
    	custId = cId;
    	company = comp;
    	state = st;
    	fax = f;
    }
}