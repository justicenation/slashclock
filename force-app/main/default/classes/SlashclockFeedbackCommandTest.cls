@isTest
private class SlashclockFeedbackCommandTest {

    @isTest
    private static void matchesFeedback() {

        // Given
        Map<String, Boolean> expectedMap = new Map<String, Boolean> {
            'feedback' => true,
            'feed' => false,
            'feedback ' => true,
            'feedback test' => true
        };

        // When
        Test.startTest();

        Map<String, Boolean> actualMap = new Map<String, Boolean>();

        for (String eachKey : expectedMap.keySet()) {

            // Construct the slash command
            SlashCommand__c slash = new SlashCommand__c(
                    Command__c = '/clock',
                    Text__c = eachKey);

            // Check the match
            actualMap.put(
                    eachKey,
                    new SlashclockFeedbackCommand().matches(slash));
        }

        // Then
        Test.stopTest();

        for (String eachKey : expectedMap.keySet()) {
            Boolean expected = expectedMap.get(eachKey);
            Boolean actual = actualMap.get(eachKey);

            System.assertEquals(expected, actual, eachKey);
        }
    }

    @isTest
    private static void throwNoMessageException() {

        // Given
        SlashCommand__c slash = new SlashCommand__c(
                Command__c = '/clock',
                SlackTeamId__c = 'ateam',
                SlackUserId__c = 'auser',
                Text__c = 'feedback');

        // When
        Test.startTest();

        SlashclockException caught = null;

        try {
            new SlashclockFeedbackCommand().load(slash);
        }
        catch (SlashclockException thrown) {
            caught = thrown;
        }

        // Then
        Test.stopTest();

        System.assertEquals(
                Label.SlashclockFeedbackNoMessage,
                caught.getMessage(),
                SlashclockException.class.getName());
    }

    @isTest
    private static void execute() {

        // Given
        SlashCommand__c slash = new SlashCommand__c(
                Command__c = '/clock',
                SlackTeamId__c = 'ateam',
                SlackUserId__c = 'auser',
                Text__c = 'feedback :thumbsup:');

        // When
        Test.startTest();

        Slashclock.CommandResult result =
                new SlashclockFeedbackCommand().load(slash).execute();

        // Then
        Test.stopTest();

        System.assertEquals(
                Label.SlashclockFeedbackSuccess,
                result.getMessage(),
                'result message');

        System.assertEquals(
                true,
                result.isSuccess(),
                'result success');
    }
}