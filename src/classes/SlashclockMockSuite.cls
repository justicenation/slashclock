@isTest
public class SlashclockMockSuite implements HttpCalloutMock {
    public List<SmartMock> getMocks() {
        return new List<SmartMock> {
            new SlackApiUsersInfoAcmeBunnyMock(),
            new SlackApiUsersInfoBarFooMock(),
            new SlackApiUsersInfoBoardFlipMock()
        };
    }

    public HttpResponse respond(HttpRequest req) {
        
        // By default, return a useless null
        HttpResponse res = null;

        // Hope that one of the mocks in the suite can handle the request
        for (SmartMock eachMock : this.getMocks()) {
            if (eachMock.handles(req)) {
                res = eachMock.respond(req);
                break;
            }
        }

        // Return the response
        return res;
    }
}