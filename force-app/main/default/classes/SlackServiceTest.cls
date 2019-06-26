@isTest
private class SlackServiceTest {

    /**
     * - Given no existing accounts in Salesforce;
     * - When `activateTeam` is called with a valid, new authorization code;
     * - Then an account should be created for the team holding an access token
     */
    @isTest
    private static void activateTeam() {

        // Given
        List<Account> givenAccounts = [
            SELECT Id
            FROM Account
        ];

        System.assertEquals(0, givenAccounts.size(),
                'no existing accounts expected');

        DatabaseJockey jockey = DatabaseJockeyMock.newInstance();

        // Stub the SlackApiService instance
        TestService.SlackApiServiceStubProvier slackApiStubProvider =
                new TestService.SlackApiServiceStubProvier();

        SlackApiService slackApi =
                (SlackApiService)Test.createStub(
                        SlackApiService.class, slackApiStubProvider);

        // When
        Test.startTest();

        SlackService slack = new SlackService(null, slackApi, jockey);

        SlackApi.TeamInfoResponse teamInfo = slack.activateTeam('test');

        // then
        Test.stopTest();
        
        Account insertedAccount =
                (Account)SimpleStubProvider.calls.get(0).args.get(0);

        System.assertEquals(
                'test-access-token',
                insertedAccount.SlackAccessToken__c,
                Schema.SObjectType.Account.fields.SlackAccessToken__c.label);

        System.assertEquals(
                'test-team-id',
                insertedAccount.SlackTeamId__c,
                Schema.SObjectType.Account.fields.SlackTeamId__c.label);
    }

    /**
     * Given the Slack User ID and Slack Team ID for a user and team
     * not already in the system, `SlackService.findOrCreateContact` should
     * return the Contact ID for a contact having `Contact.AccountId`
     * pointing to a newly created account for the Slack team.
     */
    @isTest
    private static void findOrCreateContactForNewUserNewTeam() {

        // Given
        TestService thisTest = TestService.getInstance();
        
        String slackUserId = 'doesnot';
        String slackTeamId = 'exist';

        List<Account> givenTeamAccounts = thisTest.getAccountsBySlackTeamId(slackTeamId);

        System.assertEquals(0, givenTeamAccounts.size(),
                'should be no existing team accounts');

        List<Contact> givenUserContacts = thisTest.getContactsBySlackUserId(slackUserId);

        System.assertEquals(0, givenUserContacts.size(),
                'should be no existing user contacts');

        // When
        Test.startTest();

        Contact userContact = SlackService.getInstance(
                slackTeamId).findOrCreateContact(slackUserId);

        // Then
        Test.stopTest();

        List<Account> thenTeamAccounts = thisTest.getAccountsBySlackTeamId(slackTeamId);

        System.assertEquals(1, thenTeamAccounts.size(),
                'new team accounts should have been created');

        List<Contact> thenUserContacts = thisTest.getContactsBySlackUserId(slackUserId);

        System.assertEquals(1, thenUserContacts.size(),
                'new user contact should have been created');

        System.assertEquals(
                thenTeamAccounts[0].Id,
                thenUserContacts[0].AccountId,
                Schema.SObjectType.Contact.fields.AccountId.label);
    }

    /**
     * - Given a user contact with Time Zone "America/New_York";
     * - When `SlackService.getTimeZoneSidKey` is called with the contact,
     *   and the response from the Slack API is expected to indicate the
     *   contact's current time zone is actually "America/Los_Angeles";
     * - Then "America/Los_Angeles" should be returned by the method
     */
    @isTest
    private static void getTimeZoneSidKey() {

        // Given
        Contact userContact = new Contact(
                FirstName = 'Bugs',
                LastName = 'Bunny (TEST)',
                TimeZoneSidKey__c = 'America/New_York');

        insert userContact;

        // Stub SlackApiService
        TestService.SlackApiServiceStubProvier slackApiStubProvider =
                new TestService.SlackApiServiceStubProvier();

        SlackApiService slackApiStub =
                (SlackApiService)Test.createStub(
                        SlackApiService.class, slackApiStubProvider);

        // When
        Test.startTest();

        SlackService slack = new SlackService(null, slackApiStub);

        String tz = slack.getTimeZoneSidKey(userContact);

        // Then
        Test.stopTest();

        System.assertEquals('America/Los_Angeles', tz);
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
}