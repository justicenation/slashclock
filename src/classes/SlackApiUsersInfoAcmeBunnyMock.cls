public with sharing class SlackApiUsersInfoAcmeBunnyMock implements SmartMock {
    public Boolean handles(HttpRequest req) {
        
        // Assume the request cannot be handled
        Boolean canHandle = false;

        // Examine the request, looking for the presence of the expected
        // access token and and the user ID
        if (req.getEndpoint().equals('https://slack.com/api/users.info')
                && req.getBody() != null) {
            Map<String, String> parameters =
                    HttpUtil.deserializeQuery(req.getBody());

            canHandle = parameters.get('user') == 'bunny';
        }

        // Return the verdict
        return canHandle;
    }

    public HttpResponse respond(HttpRequest req) {

        // Initialize the response
        HttpResponse res = new HttpResponse();

        res.setBody(SmartMockService.getInstance(
                SlackApiUsersInfoAcmeBunnyMock.class).getResponseBody());

        return res;
    }
}