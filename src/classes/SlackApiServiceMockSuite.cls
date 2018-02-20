@isTest
public class SlackApiServiceMockSuite extends SmartHttpCalloutMockSuite {


    public override List<Type> getMockTypes() {
        return new List<Type> {
            UsersInfoBugs.class,
            UsersInfoEm.class,
            UsersInfoKick.class
        };
    }

    public static Boolean isPostUsersInfo(HttpRequest req) {
        return req.getMethod() == 'POST' &&
                req.getEndpoint().startsWith('https://slack.com/api/users.info');
    }

    public class UsersInfoBugs implements SmartHttpCalloutMock {
        public Boolean handles(HttpRequest req) {
            return isPostUsersInfo(req) &&
                    req.getBody().contains('user=bugs');
        }

        public HttpResponse respond(HttpRequest req) {
            
            // Construct the response
            HttpResponse res = new HttpResponse();

            // Set the response body
            SlackApi.UsersInfoResponse content =
                    new SlackApi.UsersInfoResponse();

            content.ok = true;
            content.user = new SlackApi.User();
            content.user.id = 'BUGSUSERID';
            content.user.team_id = 'ACMETEAMID';
            content.user.tz = 'America/New_York';

            res.setBody(JSON.serialize(content));

            // Return the response
            return res;
        }
    }

    public class UsersInfoEm implements SmartHttpCalloutMock {
        public Boolean handles(HttpRequest req) {
            return isPostUsersInfo(req) &&
                    req.getBody().contains('user=em');
        }

        public HttpResponse respond(HttpRequest req) {
            
            // Construct the response
            HttpResponse res = new HttpResponse();

            // Set the response body
            SlackApi.UsersInfoResponse content =
                    new SlackApi.UsersInfoResponse();

            content.ok = true;
            content.user = new SlackApi.User();
            content.user.id = 'EMUSERID';
            content.user.team_id = 'CEETEAMID';
            content.user.tz = 'America/New_York';

            res.setBody(JSON.serialize(content));

            // Return the response
            return res;
        }
    }

    public class UsersInfoKick implements SmartHttpCalloutMock {
        public Boolean handles(HttpRequest req) {
            return isPostUsersInfo(req) &&
                    req.getBody().contains('user=kick');
        }

        public HttpResponse respond(HttpRequest req) {
            
            // Construct the response
            HttpResponse res = new HttpResponse();

            // Set the response body
            SlackApi.UsersInfoResponse content =
                    new SlackApi.UsersInfoResponse();

            content.ok = true;
            content.user = new SlackApi.User();
            content.user.id = 'KICKUSERID';
            content.user.team_id = 'BOARDTEAMID';
            content.user.tz = 'America/New_York';

            res.setBody(JSON.serialize(content));

            // Return the response
            return res;
        }
    }
}