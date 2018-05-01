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

        // Test setup
        TestService.getInstance().setup();

        // Given
        DateTime commandTime = DateTime.now();
        DateTime startTime = DateTimeUtil.truncate(commandTime);
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

        // Find the contact for the Slack user
        SlackService slacker = SlackService.getInstance(teamId);
        Contact userContact = slacker.findOrCreateContact(userId);

        // When
        Test.startTest();

        SlashclockService.getInstance(userContact).clockIn(commandTime);

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

        // Test setup
        TestService.getInstance().setup();
        
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

        // Find the contact for the Slack user
        SlackService slacker = SlackService.getInstance(teamId);
        Contact userContact = slacker.findOrCreateContact(userId);

        // When
        Test.startTest();

        SlashclockException thrown = null;

        try {
            SlashclockService.getInstance(userContact).clockIn(startTime);
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

    @isTest
    private static void feedbackSuccess() {

        // Test setup
        TestService.getInstance().setup();
        
        // Given
        Date threeDaysFromNow = Date.today().addDays(3);
        String userId = 'flip';
        String teamId = 'board';

        // Find the contact for the Slack user
        SlackService slacker = SlackService.getInstance(teamId);
        Contact userContact = slacker.findOrCreateContact(userId);
        Account teamAccount = [
            SELECT
                OwnerId,
                Id
            FROM Account
            WHERE SlackTeamId__c = :teamId
        ];

        // When
        Test.startTest();

        Id feedbackTaskId =
                SlashclockService.getInstance(
                        userContact).feedback('test okay', threeDaysFromNow);

        // Then
        Test.stopTest();

        Task feedbackTask = [
            SELECT
                ActivityDate,
                Description,
                OwnerId,
                Subject,
                WhoId,
                Id
            FROM Task
            WHERE Id = :feedbackTaskId
        ];

        System.assertEquals(threeDaysFromNow, feedbackTask.ActivityDate,
                Schema.SObjectType.Task.fields.ActivityDate.label);

        System.assertEquals('test okay', feedbackTask.Description,
                Schema.SObjectType.Task.fields.Description.label);

        System.assertEquals(teamAccount.OwnerId, feedbackTask.OwnerId,
                Schema.SObjectType.Task.fields.OwnerId.label);

        System.assertEquals(
                Label.SlashclockFeedbackTaskSubject, feedbackTask.Subject,
                Schema.SObjectType.Task.fields.Subject.label);

        System.assertEquals(userContact.Id, feedbackTask.WhoId,
                Schema.SObjectType.Task.fields.WhoId.label);
    }
}