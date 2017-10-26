@isTest
private class ClockResourceTest {
    
    /**
     * - Given a Slack user who is not clocked in;
     * - When the Slack user types /clock in;
     * - Then a new Time Entry record should be created for the user,
     *   and a confirmation message sent to user saying, "You're clocked in."
     */
    @isTest
    private static void clockInSuccess() {

        // Given
        String userId = 'foo';
        String teamId = 'bar';

        List<TimeEntry__c> openEntries = [
            SELECT Id, StartTime__c
            FROM TimeEntry__c
            WHERE SlackUserId__c = :userId
                AND SlackTeamId__c = :teamId
                AND EndTime__c = NULL
        ];

        System.assertEquals(0, openEntries.size(),
                'no existing time entries expected');

        // When
        Test.setMock(HttpCalloutMock.class, new SlashclockMockSuite());
        Test.startTest();

        RestRequest restReq = new RestRequest();
        restReq.params.put(SlashCommandUtil.USER_ID_PARAM, userId);
        restReq.params.put(SlashCommandUtil.TEAM_ID_PARAM, teamId);
        restReq.params.put(SlashCommandUtil.COMMAND_PARAM, '/clock');
        restReq.params.put(SlashCommandUtil.TEXT_PARAM, 'in');

        RestContext.request = restReq;
        RestContext.response = new RestResponse();

        Slack.SlashCommandResponse commandRes = ClockResource.post();

        // Then
        Test.stopTest();

        openEntries = [
            SELECT Id, StartTime__c
            FROM TimeEntry__c
            WHERE SlackUserId__c = :userId
                AND SlackTeamId__c = :teamId
                AND EndTime__c = NULL
        ];

        System.assertEquals(1, openEntries.size(),
                'one open time entry expected');

        System.assertEquals(SlashclockService.CLOCKED_IN_SUCCESS, commandRes.text,
                'SlashCommandResponse.text');
    }

    /**
     * - Given a Slack user who has already clocked in;
     * - When the Slack user types /clock in;
     * - Then the user should get an error message saying,
     *   "Uh, you already clocked in earlier."
     */
    @isTest
    private static void clockInError() {

        // Given
        DateTime startTime = DateTime.now();
        String userId = 'flip';
        String teamId = 'board';

        List<TimeEntry__c> existingOpenEntries = [
            SELECT Id, StartTime__c
            FROM TimeEntry__c
            WHERE SlackUserId__c = :userId
                AND SlackTeamId__c = :teamId
                AND EndTime__c = NULL
        ];

        System.assertEquals(1, existingOpenEntries.size(),
                'one existing time entry expected');

        // When
        Test.setMock(HttpCalloutMock.class, new SlashclockMockSuite());
        Test.startTest();

        RestRequest restReq = new RestRequest();
        restReq.params.put(SlashCommandUtil.USER_ID_PARAM, userId);
        restReq.params.put(SlashCommandUtil.TEAM_ID_PARAM, teamId);
        restReq.params.put(SlashCommandUtil.COMMAND_PARAM, '/clock');
        restReq.params.put(SlashCommandUtil.TEXT_PARAM, 'in');

        RestContext.request = restReq;
        RestContext.response = new RestResponse();

        Slack.SlashCommandResponse commandRes = ClockResource.post();

        // Then
        Test.stopTest();

        List<TimeEntry__c> finalOpenEntries = [
            SELECT Id, StartTime__c
            FROM TimeEntry__c
            WHERE SlackUserId__c = :userId
                AND SlackTeamId__c = :teamId
                AND EndTime__c = NULL
        ];

        System.assertEquals(1, finalOpenEntries.size(),
                'one open time entry expected');
        System.assertEquals(existingOpenEntries[0].Id, finalOpenEntries[0].Id,
                'existing open entry expected');

        System.assertEquals(SlashclockService.ALREADY_CLOCKED_IN_ERROR, commandRes.text,
                'SlashCommandResponse.text');
    }
    
    /**
     * - Given a Slack user who is clocked in;
     * - When the Slack user types /clock out;
     * - Then the open Time Entry record should be updated for the user,
     *   and a confirmation message sent to user saying, "You have clocked out."
     */
    @isTest
    private static void clockOutSuccess() {

        // Given
        String userId = 'flip';
        String teamId = 'board';

        List<TimeEntry__c> openEntries = [
            SELECT Id, StartTime__c
            FROM TimeEntry__c
            WHERE SlackUserId__c = :userId
                AND SlackTeamId__c = :teamId
                AND EndTime__c = NULL
        ];

        System.assertEquals(1, openEntries.size(),
                'existing time entry expected');

        // When
        Test.setMock(HttpCalloutMock.class, new SlashclockMockSuite());
        Test.startTest();

        RestRequest restReq = new RestRequest();
        restReq.params.put(SlashCommandUtil.USER_ID_PARAM, userId);
        restReq.params.put(SlashCommandUtil.TEAM_ID_PARAM, teamId);
        restReq.params.put(SlashCommandUtil.COMMAND_PARAM, '/clock');
        restReq.params.put(SlashCommandUtil.TEXT_PARAM, 'out');

        RestContext.request = restReq;
        RestContext.response = new RestResponse();

        Slack.SlashCommandResponse commandRes = ClockResource.post();

        // Then
        Test.stopTest();

        TimeEntry__c closedEntry = [
            SELECT Id, StartTime__c, EndTime__c
            FROM TimeEntry__c
            WHERE Id = :openEntries[0].Id
        ];

        System.assert(closedEntry.EndTime__c >= closedEntry.StartTime__c,
                'entry end time should be after start time');

        System.assertEquals(SlashclockService.CLOCKED_OUT_SUCCESS, commandRes.text,
                'SlashCommandResponse.text');
    }
    
    /**
     * - Given a Slack user who is clocked in;
     * - When the Slack user types "/clock out" twice;
     * - Then the open Time Entry record should be closed for the user,
     *   but the second message sent to user should say,
     *   "You must first clock in!"
     */
    // TODO: Fix error causing test failure
    //       System.CalloutException: You have uncommitted work pending.
    //       Please commit or rollback before calling out
    // @isTest
    private static void clockOutTwiceError() {

        // Given
        String userId = 'flip';
        String teamId = 'board';

        List<TimeEntry__c> openEntries = [
            SELECT Id, StartTime__c
            FROM TimeEntry__c
            WHERE SlackUserId__c = :userId
                AND SlackTeamId__c = :teamId
                AND EndTime__c = NULL
        ];

        System.assertEquals(1, openEntries.size(),
                'existing time entry expected');

        // When
        Test.setMock(HttpCalloutMock.class, new SlashclockMockSuite());
        Test.startTest();

        RestRequest restReq = new RestRequest();
        restReq.params.put(SlashCommandUtil.USER_ID_PARAM, userId);
        restReq.params.put(SlashCommandUtil.TEAM_ID_PARAM, teamId);
        restReq.params.put(SlashCommandUtil.COMMAND_PARAM, '/clock');
        restReq.params.put(SlashCommandUtil.TEXT_PARAM, 'out');

        RestContext.request = restReq;
        RestContext.response = new RestResponse();

        Slack.SlashCommandResponse firstCommandRes = ClockResource.post();
        Slack.SlashCommandResponse secondCommandRes = ClockResource.post();

        // Then
        Test.stopTest();

        TimeEntry__c closedEntry = [
            SELECT Id, StartTime__c, EndTime__c
            FROM TimeEntry__c
            WHERE Id = :openEntries[0].Id
        ];

        System.assert(closedEntry.EndTime__c >= closedEntry.StartTime__c,
                'entry end time should be after start time');

        System.assertEquals(SlashclockService.CLOCKED_OUT_SUCCESS, firstCommandRes.text,
                'SlashCommandResponse.text');
        System.assertEquals(SlashclockService.NOT_CLOCKED_IN_ERROR, secondCommandRes.text,
                'SlashCommandResponse.text');
    }

    /**
     * - Given a Slack user who is not clocked in;
     * - When the Slack user types /clock out;
     * - Then the user should get an error message saying,
     *   "You must clock in first!"
     */
    @isTest
    private static void clockOutError() {

        // Given
        DateTime startTime = DateTime.now();
        String userId = 'foo';
        String teamId = 'bar';

        List<TimeEntry__c> existingOpenEntries = [
            SELECT Id, StartTime__c
            FROM TimeEntry__c
            WHERE SlackUserId__c = :userId
                AND SlackTeamId__c = :teamId
                AND EndTime__c = NULL
        ];

        System.assertEquals(0, existingOpenEntries.size(),
                'no existing time entries expected');

        // When
        Test.setMock(HttpCalloutMock.class, new SlashclockMockSuite());
        Test.startTest();

        RestRequest restReq = new RestRequest();
        restReq.params.put(SlashCommandUtil.USER_ID_PARAM, userId);
        restReq.params.put(SlashCommandUtil.TEAM_ID_PARAM, teamId);
        restReq.params.put(SlashCommandUtil.COMMAND_PARAM, '/clock');
        restReq.params.put(SlashCommandUtil.TEXT_PARAM, 'out');

        RestContext.request = restReq;
        RestContext.response = new RestResponse();

        Slack.SlashCommandResponse commandRes = ClockResource.post();

        // Then
        Test.stopTest();

        List<TimeEntry__c> finalOpenEntries = [
            SELECT Id, StartTime__c
            FROM TimeEntry__c
            WHERE SlackUserId__c = :userId
                AND SlackTeamId__c = :teamId
                AND EndTime__c = NULL
        ];

        System.assertEquals(0, finalOpenEntries.size(),
                'no open time entries expected');

        System.assertEquals(SlashclockService.NOT_CLOCKED_IN_ERROR, commandRes.text,
                'SlashCommandResponse.text');
    }

    @testSetup
    private static void setup() {
        TestService.getInstance().setup();
    }
}