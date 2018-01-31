@isTest
private class SlashclockEntriesCommandTest {

    @testSetup
    private static void setup() {
        RelativeTestService.getInstance(
                Datetime.now(), 'Europe/London').setup();
    }

    @isTest
    private static void clockEntriesAfterSlice30Minutes() {

        // Given
        Contact skate = [
            SELECT
                Account.SlackTeamId__c,
                AccountId,
                SlackUserId__c,
                TimeZoneSidKey__c,
                Id
            FROM Contact
            WHERE LastName = 'Skate (TEST)'
        ];

        Slashclock.Command givenCommand = new SlashclockEntriesCommand();
        
        givenCommand.load(
                new SlashCommand__c(
                        SlackUserId__c = skate.SlackUserId__c,
                        SlackTeamId__c = skate.Account.SlackTeamId__c,
                        Text__c = 'entries',
                        Command__c = '/clock'));

        Slashclock.CommandResult givenResult = givenCommand.execute();

        List<String> givenMessageParts = givenResult.getMessage().split('\n');

        System.assertEquals(
                'Here\'s what you\'ve clocked over the last seven days.',
                givenMessageParts.get(0),
                'givenMessageParts.get(0)');

        System.assert(
                givenMessageParts.get(1).endsWith('10:15am - 5:45pm'),
                givenMessageParts.get(1) + ' should end with ' + '10:15am - 5:45pm');

        System.assert(
                givenMessageParts.get(2).endsWith('9:15am - 9:45am'),
                givenMessageParts.get(2) + ' should end with ' + '9:15am - 9:45am');
    }
}