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
        Test.setMock(HttpCalloutMock.class, new TestService.OauthAccessMock());
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

    @isTest
    private static void teamInfo() {

        // Given
        String accessToken = 'xoxp-23984754863-2348975623103';

        // When
        Test.setMock(HttpCalloutMock.class, new TestService.TeamInfoMock());
        Test.startTest();

        SlackApi.TeamInfoResponse teamInfo =
                new SlackApiService(accessToken).teamInfo();

        // Then
        Test.stopTest();

        System.assertEquals(
                true,
                teamInfo.ok,
                'TeamInfoResponse.ok');

        System.assertEquals(
                'T12345',
                teamInfo.team.id,
                'TeamInfoResponse.team.id');

        System.assertEquals(
                'My Team',
                teamInfo.team.name,
                'TeamInfoResponse.team.name');

        System.assertEquals(
                'example',
                teamInfo.team.domain,
                'TeamInfoResponse.team.domain');

        System.assertEquals(
                'example.com',
                teamInfo.team.email_domain,
                'TeamInfoResponse.team.email_domain');

        System.assertEquals(
                'https://...',
                teamInfo.team.icon.image_34,
                'TeamInfoResponse.team.icon.image_34');

        System.assertEquals(
                'https://...',
                teamInfo.team.icon.image_44,
                'TeamInfoResponse.team.icon.image_44');

        System.assertEquals(
                'https://...',
                teamInfo.team.icon.image_68,
                'TeamInfoResponse.team.icon.image_68');

        System.assertEquals(
                'https://...',
                teamInfo.team.icon.image_88,
                'TeamInfoResponse.team.icon.image_88');

        System.assertEquals(
                'https://...',
                teamInfo.team.icon.image_102,
                'TeamInfoResponse.team.icon.image_102');

        System.assertEquals(
                'https://...',
                teamInfo.team.icon.image_132,
                'TeamInfoResponse.team.icon.image_132');

        System.assertEquals(
                true,
                teamInfo.team.icon.image_default,
                'TeamInfoResponse.team.icon.image_default');

        System.assertEquals(
                'E1234A12AB',
                teamInfo.team.enterprise_id,
                'TeamInfoResponse.team.enterprise_id');

        System.assertEquals(
                'Umbrella Corporation',
                teamInfo.team.enterprise_name,
                'TeamInfoResponse.team.enterprise_name');
    }

    @isTest
    private static void usersInfo() {

        // Given
        String accessToken = 'xoxp-23984754863-2348975623103';

        // When
        Test.setMock(HttpCalloutMock.class, new TestService.UsersInfoAcmeBunnyMock());
        Test.startTest();

        SlackApi.UsersInfoResponse usersInfo =
                new SlackApiService(accessToken).usersInfo('bunny');

        // Then
        Test.stopTest();

        System.assertEquals(
                'bunny',
                usersInfo.user.id,
                'UsersInfo.user.id');

        System.assertEquals(
                'acme',
                usersInfo.user.team_id,
                'UsersInfo.user.team_id');

        System.assertEquals(
                'America/New_York',
                usersInfo.user.tz,
                'UsersInfo.user.tz');
    }
}