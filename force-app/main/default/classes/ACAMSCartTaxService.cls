@RestResource(UrlMapping='/api/cart/tax')
global with sharing class ACAMSCartTaxService {

    @HttpPost
    global static TaxResponse checkTax(String cartId) {
        try {
            ACAMSCartTaxRecalculationController.recalculateTaxes(cartId);
        } catch (Exception e) {
            System.debug('Unable to recalculate taxes for cart id: ' + cartId + '. Exception: ' + e.getMessage());
        }

        TaxResponse taxResponse = new TaxResponse();
        taxResponse.tax = 0;
        Integer count = 0;
        // Forced delay to make sure tax amount is returned
        while (count++ < 30) {
            ccrz__E_Cart__c cart = ACAMSCartDAO.getCartById(cartId);
            if (cart.ccrz__BillTo__c == null || cart.ccrz__TaxAmount__c == null) {
                taxResponse.tax = 0;
            } else {
                taxResponse.tax = cart.ccrz__TaxAmount__c;
            }
        }

        return taxResponse;
    }

    global class TaxResponse {
        public Decimal tax { get; set; }
    }
}