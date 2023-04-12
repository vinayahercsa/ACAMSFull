@IsTest
public with sharing class CCACAMSTestUtil extends CCAviTestUtil {

    public CCACAMSTestUtil() {
        super();
    }

    public static ACAMS_OpportunityCCProduct_Settings__mdt opportunityCCProductSettings {
        get {
            if (opportunityCCProductSettings == null) {
                opportunityCCProductSettings = new ACAMS_OpportunityCCProduct_Settings__mdt ();
                opportunityCCProductSettings.Opportunity_Add_Products_Page_Size__c = 10;
                opportunityCCProductSettings.Opportunity_Standard_CCPriceList_Name__c = 'General';
            }
            return opportunityCCProductSettings;
        }
        private set;
    }

    public virtual Vertex_Tax_Calculation_Bypass__c createVertexTaxCalculationBypassSettings() {
        return new Vertex_Tax_Calculation_Bypass__c(
                Bypass_Cart_Tax_Calculation__c = true,
                Bypass_Invoice_Tax_Calculation__c = true,
                Bypass_Order_Tax_Calculation__c = true
        );
    }

    public override virtual Map<String, Object> initData() {
        ccrz.cc_util_Reflection.createStorefrontSetting(super.STOREFRONT);
        Map<String, Map<String, Object>> testData = new Map<String, Map<String, Object>>{
                ccrz.ccApiTestData.SERVICE_SETTINGS => new Map<String, Object>{
                        super.STOREFRONT => new Map<String, Object>{
                        }
                },
                ccrz.ccApiTestData.LOGIC_SETTINGS => new Map<String, Object>{
                        super.STOREFRONT => new Map<String, Object>{
                                'ccLogicCartAddTo' => 'c.ACAMSLogicCartAddTo',
                                'ccLogicCartClone' => 'c.ACAMSLogicCartClone',
                                'ccLogicCartPlace' => 'c.ACAMSLogicCartPlace',
                                'ccLogicCartRemove' => 'c.ACAMSLogicCartRemove'
                        }
                }
        };
        ccrz.ccApiTestData.setupData(testData);

        insert this.createVertexTaxCalculationBypassSettings();
        return super.initData();
    }
}