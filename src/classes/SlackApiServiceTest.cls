@isTest
private class SlackApiServiceTest {

    @isTest
    private static void oauthAccess() {

        // Given
        Connection__c connection = new Connection__c(
                ClientId__c = 'test-id',
                ClientSecret__c = 'test-secret');

        String code = 'test-code';

        // When
        Test.setMock(HttpCalloutMock.class, new OauthAccessMock());
        Test.startTest();

        SlackApi.OauthAccessResponse oauthAccess =
                new SlackApiService().oauthAccess(connection, code);

        // Then
        Test.stopTest();

        System.assertEquals(
                'xoxp-23984754863-2348975623103',
                oauthAccess.access_token,
                'OauthAccessResponse.access_token');

        System.assertEquals(
                'read',
                oauthAccess.scope,
                'OauthAccessResponse.scope');
    }

    private class OauthAccessMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {

            // Construct the response
            HttpResponse res = new HttpResponse();

            res.setBody([
                SELECT Body
                FROM StaticResource
                WHERE Name = 'SlackApiOauthAccessMock'
            ].Body.toString());

            // Return the response
            return res;
        }
    }
}