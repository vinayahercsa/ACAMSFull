@IsTest
public class ACAMSCeregoDTOTest {

    static testMethod void testParse() {
        String json = '{'+
                '    \"data\": ['+
                '        {'+
                '            \"id\": \"7746324\",'+
                '            \"type\": \"oauth2-access-tokens\",'+
                '            \"attributes\": {'+
                '                \"token\": \"jHywUXlUr0CO4xWbY1pF9rtaLaSfwpUhWiLc8EMnenL8gm3Wu53v6P/Nk9WkmCdb\",'+
                '                \"expires-at\": \"2020-07-11T10:27:08.000Z\",'+
                '                \"expires-in\": 15777867'+
                '            }'+
                '        }'+
                '    ],'+
                '    \"links\": {},'+
                '    \"meta\": {'+
                '        \"total-pages\": 1,'+
                '        \"total-count\": 1'+
                '    }'+
                '}';
        ACAMSCeregoDTO r = ACAMSCeregoDTO.parse(json);
        System.assert(r != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        ACAMSCeregoDTO objACAMSCeregoDTO = new ACAMSCeregoDTO(System.JSON.createParser(json));
        System.assert(objACAMSCeregoDTO != null);
        System.assert(objACAMSCeregoDTO.data == null);
        System.assert(objACAMSCeregoDTO.links == null);
        System.assert(objACAMSCeregoDTO.meta == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        ACAMSCeregoDTO.Meta objMeta = new ACAMSCeregoDTO.Meta(System.JSON.createParser(json));
        System.assert(objMeta != null);
        System.assert(objMeta.totalPages == null);
        System.assert(objMeta.totalCount == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        ACAMSCeregoDTO.Attributes objAttributes = new ACAMSCeregoDTO.Attributes(System.JSON.createParser(json));
        System.assert(objAttributes != null);
        System.assert(objAttributes.token == null);
        System.assert(objAttributes.expiresAt == null);
        System.assert(objAttributes.expiresIn == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        ACAMSCeregoDTO.Links objLinks = new ACAMSCeregoDTO.Links(System.JSON.createParser(json));
        System.assert(objLinks != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        ACAMSCeregoDTO.Data objData = new ACAMSCeregoDTO.Data(System.JSON.createParser(json));
        System.assert(objData != null);
        System.assert(objData.id == null);
        System.assert(objData.type_Z == null);
        System.assert(objData.attributes == null);
    }
}