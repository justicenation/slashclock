@isTest
public class SlackApiUsersInfoSurferSilverMock implements SmartHttpCalloutMock {

    public Boolean handles(HttpRequest req) {
        
        // Assume the request cannot be handled
        Boolean handles = false;

        // Examine the request, looking for the presence of the expected
        // access token and and the user ID
        if (req.getEndpoint().equals('https://slack.com/api/users.info')
                && req.getBody() != null) {
            Map<String, String> parameters =
                    HttpUtil.deserializeQuery(req.getBody());

            handles = parameters.get('user') == 'silver';
        }

        // Return the verdict
        return handles;
    }

    public HttpResponse respond(HttpRequest req) {

        // Initialize the response
        HttpResponse res = new HttpResponse();

        res.setBody(SmartMockService.getInstance(
                SlackApiUsersInfoSurferSilverMock.class).getResponseBody());

        return res;
    }
}