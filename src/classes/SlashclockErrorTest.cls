/**
 * Provide functional validation and code coverage for handling unknown errors
 * and other edge cases
 */
@isTest
public with sharing class SlashclockErrorTest {

    @isTest
    private static void clockInXyz() {
        Test.setMock(HttpCalloutMock.class, new SlackApiServiceMockSuite());
        
        // Given
        TestService.getInstance().setup();
        
        String slackUserId = 'em';
        String slackTeamId = 'cee';

        // Find the contact for the Slack user
        SlackService slacker = SlackService.getInstance(slackTeamId);
        Contact userContact = slacker.findOrCreateContact(slackUserId);

        SlashclockService slashclock =
                SlashclockService.getInstance(userContact);

        List<TimeEntry__c> openEntries = slashclock.getOpenTimeEntries();

        System.assertEquals(0, openEntries.size(), 'openEntries.size()');

        Datetime clockInTime = DatetimeUtil.newDatetime(
                Date.today(),
                Time.newInstance(8, 30, 0, 0),
                slashclock.getTimeZoneSidKey());

        SlashCommand__c slashCommand = new SlashCommand__c(
                SlackUserId__c = slackUserId,
                SlackTeamId__c = slackTeamId,
                Command__c = '/clock',
                Text__c = 'in xyz');

        SlashclockInCommand command = new SlashclockInCommand();

        System.assert(command.matches(slashCommand),
                'must match slash command');

        // When
        Test.startTest();

        Slashclock.CommandResult result = slashclock.execute(slashCommand);

        // Then
        Test.stopTest();

        System.assertEquals(false, result.isSuccess(), 'result.isSuccess()');

        System.assertEquals(
                'Bad command: /clock in xyz',
                result.getMessage(),
                'result.getMessage()');
    }
}