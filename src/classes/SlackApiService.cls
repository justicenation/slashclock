public with sharing class SlackApiService {

    private String accessToken;

    public SlackApiService() {
        this(null);
    }

    public SlackApiService(String accessToken) {
        this.accessToken = accessToken;
    }

    public String getBaseUrl() {
        return 'https://slack.com/api';
    }

    public static SlackApiService getInstance() {
        return new SlackApiService();
    }

    public static SlackApiService getInstance(String accessToken) {
        return new SlackApiService(accessToken);
    }

    public SlackApi.OauthAccessResponse oauthAccess(
            Connection__c conn, String authCode) {
        return this.oauthAccess(
                conn.ClientId__c, conn.ClientSecret__c, authCode);
    }

    public SlackApi.OauthAccessResponse oauthAccess(
            String clientId, String clientSecret, String authCode) {

        // Initialize the request
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');

        // Construct the endpoint
        Map<String, String> parameterMap = new Map<String, String> {
            'client_id' => clientId,
            'client_secret' => clientSecret,
            'code' => authCode
        };

        req.setEndpoint(String.join(new List<String> {
            this.getBaseUrl(),
            '/oauth.access&',
            HttpUtil.serializeQuery(parameterMap)
        }, ''));

        // Parse and return the response
        HttpResponse res = new Http().send(req);

        return (SlackApi.OauthAccessResponse)JSON.deserialize(
                res.getBody(), SlackApi.OauthAccessResponse.class);
    }

    public SlackApi.TeamInfoResponse teamInfo() {

        // Initialize the request
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(this.getBaseUrl() + '/team.info');

        // Construct the request body
        Map<String, String> parameterMap = new Map<String, String> {
            'token' => this.accessToken
        };

        req.setBody(HttpUtil.serializeQuery(parameterMap));

        // Parse and return the response
        HttpResponse res = new Http().send(req);

        return (SlackApi.TeamInfoResponse)JSON.deserialize(
                res.getBody(), SlackApi.TeamInfoResponse.class);
    }
}