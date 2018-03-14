public with sharing class SlackService {

    public static final String DEFAULT_TIME_ZONE_SID_KEY = 'America/New_York';

    /**
     * Cache of found or created contacts, keyed on the Slack User ID
     */
    private Map<String, Contact> contactMap;

    @testVisible
    private static SlackService instance = new SlackService();

    /**
     * Map of service instances by Slack Team ID
     */
    public static Map<String, SlackService> instanceMap =
            new Map<String, SlackService>();

    private String teamId;

    private SlackApiService slackApi;

    public SlackService() {
        this(null);
    }

    public SlackService(String teamId) {
        this(teamId, SlackApiService.getInstance());
    }

    public SlackService(String teamId, SlackApiService slackApi) {
        this.contactMap = new Map<String, Contact>();
        this.teamId = teamId;
        this.slackApi = slackApi;
    }

    /**
     * Given an OAuth 2.0 authorization code, call the Slack API to get
     * an access token and create or update the account in Salesforce
     * for the team.
     *
     * @param code The OAuth2.0 authorization code
     *
     * @return The `SlackApi.TeamInfoResponse` object that would be obtained
     *         upon successful exchange fo the authorization code
     *         and subsequent call to get details on the team
     */ 
    public SlackApi.TeamInfoResponse activateTeam(String code) {

        // Get the access token
        SlackApi.OauthAccessResponse oauthAccess =
                this.slackApi.oauthAccess(
                        Connection__c.getInstance('Slack'), code);

        // Determine the appropriate next page for the team
        SlackApi.TeamInfoResponse teamInfo =
                this.slackApi.teamInfo(oauthAccess.access_token);

        // Store the access token
        this.storeAccessToken(oauthAccess.access_token, teamInfo.team.id);

        // Return the team information
        return teamInfo;
    }

    public Account createAccount(String teamId) {
        Account teamAccount = new Account(
                Name = teamId,
                SlackTeamId__c = teamId);

        insert teamAccount;
        return teamAccount;
    }

    public Contact createContact(String userId) {
        
        // Find or create the team account
        Account teamAccount = this.findOrCreateAccount();

        // Create the user contact
        Contact userContact = new Contact(
                LastName = userId,
                AccountId = teamAccount.Id,
                TimeZoneSidKey__c = DEFAULT_TIME_ZONE_SID_KEY,
                SlackUserId__c = userId);

        insert userContact;

        // Set the reference object for convenient reference
        userContact.Account = teamAccount;

        // Return the user contact
        return userContact;
    }

    public Account findOrCreateAccount() {
        return this.findOrCreateAccount(teamId);
    }

    public Account findOrCreateAccount(String teamId) {

        // Look for an existing account
        List<Account> teamAccounts = [
            SELECT
                Name,
                SlackAccessToken__c,
                SlackTeamId__c,
                Id
            FROM Account
            WHERE SlackTeamId__c = :teamId
        ];

        return teamAccounts.isEmpty() ? createAccount(teamId) : teamAccounts[0];
    }

    /**
     * @param userId The **Slack User ID**
     *
     * @return A Contact object including the parent Account object in the
     *         `Contact.Account` field. This contact would be newly created
     *         if one did not already exist at the time the method was called.
     */
    public Contact findOrCreateContact(String userId) {

        // Assume we'll get a hit in the cache
        Contact userContact = this.contactMap.get(userId);

        // If we didn't get a hit in the cache, query the system.
        // for an existing contact.
        if (userContact == null) {

            List<Contact> userContacts = [
                SELECT
                    Account.Name,
                    Account.SlackTeamId__c,
                    Account.SlackAccessToken__c,
                    AccountId,
                    SlackTeamId__c,
                    SlackUserId__c,
                    TimeZoneSidKey__c,
                    Id
                FROM Contact
                WHERE AccountId = :findOrCreateAccount().Id
                    AND SlackUserId__c = :userId
            ];

            userContact = userContacts.isEmpty()
                    ? createContact(userId)
                    : userContacts[0];

            // Cache the found or created contact
            this.contactMap.put(userId, userContact);
        }

        return userContact;
    }

    public static SlackService getInstance() {
        return instance;
    }

    public static SlackService getInstance(String teamId) {
        if (!instanceMap.containsKey(teamId)) {
            instanceMap.put(teamId, new SlackService(teamId));
        }

        return instanceMap.get(teamId);
    }

    /**
     * Get the time zone for a given Slack user, preferably from Slack if
     * possible but if not then whatever is on file for the user.
     * If the time zone obtained from Slack is different than what's on file
     * for the user, the information in Salesforce should be updated
     * to match the user's Slack configuration.
     *
     * @param userId The **Slack User ID**
     *
     * @return the time zone SID key (e.g., "America/New_York")
     */
    public String getTimeZoneSidKey(String userId) {

        // Get the time zone from Slack
        SlackApiService teamSlackApi = SlackApiService.getInstance(
                this.findOrCreateAccount().SlackAccessToken__c);

        SlackApi.UsersInfoResponse usersInfo = teamSlackApi.usersInfo(userId);

        // Return the user's time zone
        return usersInfo.user.tz;
    }

    /**
     * Get the time zone for a given Slack user, preferably from Slack if
     * possible but if not then whatever is on file for the user.
     * If the time zone obtained from Slack is different than what's on file
     * for the user, the information in Salesforce should be updated
     * to match the user's Slack configuration.
     *
     * @return the time zone SID key (e.g., "America/New_York")
     */
    public String getTimeZoneSidKey(Contact userContact) {

        // Get the time zone from Slack
        SlackApiService teamSlackApi = SlackApiService.getInstance(
                this.findOrCreateAccount().SlackAccessToken__c);

        SlackApi.UsersInfoResponse usersInfo =
                teamSlackApi.usersInfo(userContact.SlackUserId__c);

        // Update the contact's time zone if the user's current time
        // zone is different
        if (usersInfo.user.tz != userContact.TimeZoneSidKey__c) {
            userContact.TimeZoneSidKey__c = usersInfo.user.tz;
            DatabaseUtil.updateLater(userContact);
        }

        // Return the user's time zone
        return userContact.TimeZoneSidKey__c;
    }

    public Account storeAccessToken(String accessToken, String teamId) {
        Account teamAccount = this.findOrCreateAccount(teamId);
        teamAccount.SlackAccessToken__c = accessToken;
        update teamAccount;
        return teamAccount;
    }
}