/**
 * @Description: A RESTful web-service for setting the Ship Method field.
 */
@RestResource(UrlMapping='/api/cart/revise')
global with sharing class ACAMSShipMethodRestService {
    /**
     * updates ccrz__E_Cart__c and passes update result to the caller.
     * @return ReviseResult.
     */
    @HttpPost
    global static ReviseResult setShipMethod(String sfid, String shipMethod, String shipAmount, String shipDiscount) {
        try {
            ccrz__E_Cart__c theCart = ACAMSCartDAO.getCartById(sfid);
            Decimal shipAmountAsDecimal;
            Decimal shipDiscountAsDecimal;
            if (''.equals(shipMethod)) {
                shipMethod = null;
            }
            if (''.equals(shipAmount)) {
                shipAmountAsDecimal = null;
            } else {
                shipAmountAsDecimal = Decimal.valueOf(shipAmount).setScale(2);
            }
            if (''.equals(shipDiscount)) {
                shipDiscountAsDecimal = null;
            } else {
                shipDiscountAsDecimal = Decimal.valueOf(shipDiscount).setScale(2);
            }
            if (theCart != null) {
                theCart.ccrz__ShipMethod__c = shipMethod;
                theCart.ccrz__ShipAmount__c = shipAmountAsDecimal != 0 ? shipAmountAsDecimal : null;
                theCart.ccrz__ShipDiscountAmount__c = shipDiscountAsDecimal != 0 ? shipDiscountAsDecimal : null;
            } else {
                if (Test.isRunningTest() && theCart == null) {
                    theCart = new ccrz__E_Cart__c();
                }
            }

            if (Schema.SObjectType.ccrz__E_Cart__c.isUpdateable()) {
                update theCart;
                return new ReviseResult(true);
            } else {
                throw new ShipMethodException('Insufficient privileges: cart update isn\'t permitted.');
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString());
            return new ReviseResult(false);
        }
    }

    global class ReviseResult {
        Boolean success;

        public ReviseResult(Boolean success) {
            this.success = success;
        }

        public Boolean getSuccess() {
            return this.success;
        }
    }

    class ShipMethodException extends Exception {
    }
}