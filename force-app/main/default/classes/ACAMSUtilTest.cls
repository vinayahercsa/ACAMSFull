@IsTest
private class ACAMSUtilTest {

    @IsTest
    static void getISO2DigitStateTest() {
        List<SObject> acctList = new List<SObject>();
        List<SObject> firstUpdateList = new List<SObject>();
        List<SObject> secondUpdateList = new List<SObject>();
        System.assert(ACAMSUtil.getISO2DigitState('Illinois') == 'IL');
        System.assert(ACAMSUtil.getISO2DigitState('IL') == 'IL');
        System.assert(ACAMSUtil.getISO3Country('CN') == 'CHN');
        System.assert(ACAMSUtil.getPhonecode('CN') == '86');
        System.assert(ACAMSUtil.getIsoCodeFromCountryName('China') == 'CN');
        ACAMSUtil.getMetadataFromStateName('IL','US');
        ACAMSUtil.reportException('successful',200,'testType','{[body]}','exception','001xxxxx','001yyyyy');
        ACAMSUtil.getLanguageByCode('en_US');
        ACAMSUtil.getLanguageByCode('de');
        ACAMSUtil.getLanguageByCode('zh_CN');
        ACAMSUtil.getLanguageByCode('zh_TW');
        ACAMSUtil.getLanguageByCode('fr');
        ACAMSUtil.getLanguageByCode('ja');
        ACAMSUtil.getLanguageByCode('pl');
        ACAMSUtil.getLanguageByCode('pt_BR');
        ACAMSUtil.getLanguageByCode('es');
        ACAMSUtil.getLanguageByCode('ru');

        ACAMSUtil.getPhoneFormattingPattern();

        ACAMSUtil.InsertObject insertOPT = new ACAMSUtil.InsertObject(acctList);
        ACAMSUtil.UpdateObject updateOPT = new ACAMSUtil.UpdateObject(acctList);

        ACAMSUtil.UpdateObjectChainJob chainJob = new ACAMSUtil.UpdateObjectChainJob(firstUpdateList,secondUpdateList);
    }
}