public with sharing class SlackService {

    public static final String DEFAULT_TIME_ZONE_SID_KEY = 'America/New_York';

    /**
     * Cache of found or created contacts, keyed on the Slack User ID
     */
    private Map<String, Contact> contactMap;

    /**
     * Map of service instances by Slack Team ID
     */
    public static Map<String, SlackService> instanceMap =
            new Map<String, SlackService>();

    private String teamId;

    public SlackService(String teamId) {
        this.contactMap = new Map<String, Contact>();
        this.teamId = teamId;
    }

    public Account createAccount() {
        Account teamAccount = new Account(
                Name = this.teamId,
                SlackTeamId__c = this.teamId);

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

        // Look for an existing account
        List<Account> teamAccounts = [
            SELECT
                Name,
                SlackAccessToken__c,
                SlackTeamId__c,
                Id
            FROM Account
            WHERE SlackTeamId__c = :this.teamId
        ];

        return teamAccounts.isEmpty() ? createAccount() : teamAccounts[0];
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

    public Account storeAccessToken(String accessToken) {

        Account teamAccount = this.findOrCreateAccount();
        teamAccount.SlackAccessToken__c = accessToken;
        update teamAccount;
        return teamAccount;
    }
}