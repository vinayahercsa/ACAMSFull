@RestResource(UrlMapping='/api/cart/addto')
global with sharing class ACAMSCartAddTo {
    private static Integer API_VERSION = 8;
    @HttpPost
    global static CartResponse addTo(String CCRZCONTEXT, String ID, List<ccrz.ccApiCart.LineData> LINEITEMS) {
        CartResponse cartResponse = new CartResponse();
        ccrz.ccContext ctx = new ccrz.ccContext();
        String ctxStr = EncodingUtil.base64Decode(CCRZCONTEXT).toString();
        Map<String, Object> ctxMap = (Map<String, Object>) JSON.deserializeUntyped(ctxStr);
        for (String key : ctxMap.keyset()) {
            if (key.equals('portalUserId')) {
                ctx.portalUserId = (String) ctxMap.get(key);
            } else if (key.equals('storefront')) {
                ctx.storefront = (String) ctxMap.get(key);
            }
        }
        ccrz.cc_CallContext.initContext(ctx);
        Map<String, Object> request = new Map<String, Object>{
                ccrz.ccApi.API_VERSION => API_VERSION,
                'CCRZCONTEXT' => CCRZCONTEXT,
                ccrz.ccApiCart.CART_ID => ID,
                ccrz.ccApiCart.LINE_DATA => LINEITEMS,
                ccrz.ccApi.SIZING => new Map<String, Object>{
                        'cart_item' => new Map<String, Object>{
                                ccrz.ccApi.SZ_REFETCH => true
                        },
                        'product' => new Map<String, Object>{
                                ccrz.ccApi.SZ_REFETCH => true
                        },
                        'cartItem' => new Map<String, Object>{
                                ccrz.ccApi.SZ_REFETCH => true
                        }
                }
        };

        Map<String, Object> response = null;

        try {
            response = ccrz.ccAPICart.addTo(request);
            Boolean isSuccess = (Boolean) response.get(ccrz.ccAPI.SUCCESS);
            cartResponse.success = isSuccess;
            cartResponse.infoMsg = (String) response.get('infoMsg');
        } catch (Exception e) {
            System.debug(System.LoggingLevel.ERROR, e);
        }
        return cartResponse;
    }

    global class CartResponse {
        public Boolean success { get; set; }
        public String infoMsg { get; set; }
    }
}