@isTest
private class SlackServiceTest {

    /**
     * Given the Slack User ID and Slack Team ID for a user and team
     * not already in the system, `SlackService.findOrCreateContact` should
     * return the Contact ID for a contact having `Contact.AccountId`
     * pointing to a newly created account for the Slack team.
     */
    @isTest
    private static void findOrCreateContactForNewUserNewTeam() {

        // Given
        String slackUserId = 'doesnot';
        String slackTeamId = 'exist';

        List<Account> givenTeamAccounts = getAccounts(slackTeamId);

        System.assertEquals(0, givenTeamAccounts.size(),
                'should be no existing team accounts');

        List<Contact> givenUserContacts = getContacts(slackUserId);

        System.assertEquals(0, givenUserContacts.size(),
                'should be no existing user contacts');

        // When
        Test.startTest();

        Contact userContact = SlackService.getInstance(
                slackTeamId).findOrCreateContact(slackUserId);

        // Then
        Test.stopTest();

        List<Account> thenTeamAccounts = getAccounts(slackTeamId);

        System.assertEquals(1, thenTeamAccounts.size(),
                'new team accounts should have been created');

        List<Contact> thenUserContacts = getContacts(slackUserId);

        System.assertEquals(1, thenUserContacts.size(),
                'new user contact should have been created');

        System.assertEquals(
                thenTeamAccounts[0].Id,
                thenUserContacts[0].AccountId,
                Schema.SObjectType.Contact.fields.AccountId.label);
    }

    @isTest
    private static void getInstance() {

        // When
        Test.startTest();

        SlackService slack = SlackService.getInstance();

        // Then
        Test.stopTest();

        System.assertNotEquals(null, slack);
    }

    private static List<Account> getAccounts(String slackTeamId) {
        return [
            SELECT
                Name,
                SlackTeamId__c,
                Id
            FROM Account
            WHERE SlackTeamId__c = :slackTeamId
        ];
    }

    private static List<Contact> getContacts(String slackUserId) {
        return [
            SELECT
                AccountId,
                Name,
                SlackUserId__c,
                Id
            FROM Contact
            WHERE SlackUserId__c = :slackUserId
        ];
    }
}