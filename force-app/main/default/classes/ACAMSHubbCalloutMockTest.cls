global class ACAMSHubbCalloutMockTest implements HttpCalloutMock{
    public ACAMSHubbCalloutMockTest() {

    }

    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{access_token:"testtoken","Id": 714018,"Title": "Welcome Keynote with Q&A","Description": "Welcome Remarks/Keynote Address with Q&A","Mandatory": false,"Enabled": true,"CanBeEvaluated": true,"VideoLink": null,"Code": "KEY1","TrackId": 30646,"TimeSlotId": 162402,"RoomId": null,"DeckLink": null,"IsFeatured": false,"SessionTypeId": 23988,"VisibleToAnonymousUsers": false,"VisibleInSessionListing": true,"Status": "Accepted","SessionOwners": [],"AllowedCustomRoles": [],"Room": null,"SessionRequests": [],"SessionGroup": null,"ChatRooms": []},');
        res.setStatusCode(200);
        return res;
    }
}