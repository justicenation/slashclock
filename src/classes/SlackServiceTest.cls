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

        // Stub the SlackApiService instance
        SlackApiServiceStubProvier slackApiStubProvider =
                new SlackApiServiceStubProvier();

        SlackApiService slackApi =
                (SlackApiService)Test.createStub(
                        SlackApiService.class, slackApiStubProvider);

        // When
        Test.startTest();

        SlackService slack = new SlackService(null, slackApi);

        SlackApi.TeamInfoResponse teamInfo = slack.activateTeam('test');

        // then
        Test.stopTest();

        List<Account> thenAccounts = [
            SELECT
                SlackAccessToken__c,
                SlackTeamId__c,
                Id
            FROM Account
        ];

        System.assertEquals(1, thenAccounts.size(),
                'one account should have been created');

        System.assertEquals(
                'test-access-token',
                thenAccounts[0].SlackAccessToken__c,
                Schema.SObjectType.Account.fields.SlackAccessToken__c.label);

        System.assertEquals(
                'test-team-id',
                thenAccounts[0].SlackTeamId__c,
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
        SlackApiServiceStubProvier slackApiStubProvider =
                new SlackApiServiceStubProvier();

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

    private class SlackApiServiceStubProvier implements StubProvider {

        public Object handleMethodCall(
                Object stubbedObject,
                String stubbedMethodName,
                Type returnType,
                List<Type> listOfParamTypes,
                List<String> listOfParamNames,
                List<Object> listOfArgs) {
            
            // Initialize the return value
            Object returnValue = null;

            if ('oauthAccess'.equals(stubbedMethodName)) {
                returnValue = this.oauthAccess(
                        (Connection__c)listOfArgs[0], (String)listOfArgs[1]);
            }
            else if ('teamInfo'.equals(stubbedMethodName)) {
                returnValue = this.teamInfo((String)listOfArgs[0]);
            }
            else if ('usersInfo'.equals(stubbedMethodName)) {
                returnValue = this.usersInfo((String)listOfArgs[0]);
            }

            // Return a value
            return returnValue;            
        }

        /**
         * @see `getTimeZoneSidKey` test
         */
        public SlackApi.UsersInfoResponse usersInfo(String userId) {

            // Construct the response
            SlackApi.UsersInfoResponse res =
                    new SlackApi.UsersInfoResponse();

            res.user = new SlackApi.User();
            res.user.tz = 'America/Los_Angeles';

            // Return the response
            return res;
        }

        public SlackApi.OauthAccessResponse oauthAccess(
                Connection__c conn, String authCode) {

            // Construct the reponse
            SlackApi.OauthAccessResponse res =
                    new SlackApi.OauthAccessResponse();

            res.access_token = 'test-access-token';

            // Return the response
            return res;
        }

        public SlackApi.TeamInfoResponse teamInfo(String accessToken) {

            // Construct the response
            SlackApi.TeamInfoResponse res =
                    new SlackApi.TeamInfoResponse();

            res.team = new SlackApi.Team();
            res.team.id = 'test-team-id';

            // Return the response
            return res;
        }
    }
}