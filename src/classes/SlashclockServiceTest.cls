@isTest
private class SlashclockServiceTest {

    /**
     * - Given a Slack user who is not clocked in;
     * - When the Slack user types /clock in;
     * - Then a new Time Entry record should be created for the user,
     *   and a confirmation message sent to user saying, "You're clocked in."
     */
    @isTest
    private static void clockInSuccess() {

        // Given
        DateTime startTime = DateTime.now();
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
        Test.startTest();

        SlashclockService.getInstance(userId, teamId).clockIn(startTime);

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
        System.assertEquals(startTime, openEntries[0].StartTime__c,
                Schema.SObjectType.TimeEntry__c.fields.StartTime__c.label);
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
        Test.startTest();

        SlashclockException thrown = null;

        try {
            SlashclockService.getInstance(userId, teamId).clockIn(startTime);
        }
        catch (SlashclockException caught) {
            thrown = caught;
        }

        // Then
        Test.stopTest();

        System.assert(thrown != null, 'thrown exception expected');
        System.assertEquals(SlashclockService.ALREADY_CLOCKED_IN_ERROR,
                thrown.getMessage(), 'thrown exception message');

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
    }

    @testSetup
    private static void setup() {
        TestService.getInstance().setup();
    }
}