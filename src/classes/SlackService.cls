public with sharing class SlackService {

    /**
     * Map of service instances by Slack Team ID
     */
    public static Map<String, SlackService> instanceMap =
            new Map<String, SlackService>();

    private String teamId;

    public SlackService(String teamId) {
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
        Contact userContact = new Contact(
                LastName = userId,
                AccountId = findOrCreateAccount().Id,
                TimeZoneSidKey__c = (String)Contact.TimeZoneSidKey__c.getDescribe().getDefaultValue(),
                SlackUserId__c = userId);

        insert userContact;
        return userContact;
    }

    public Account findOrCreateAccount() {

        // Look for an existing account
        List<Account> teamAccounts = [
            SELECT Id, Name, SlackAccessToken__c
            FROM Account
            WHERE SlackTeamId__c = :this.teamId
        ];

        return teamAccounts.isEmpty() ? createAccount() : teamAccounts[0];
    }

    public Contact findOrCreateContact(String userId) {

        // Look for a existing contact
        List<Contact> userContacts = [
            SELECT Id, SlackUserId__c, TimeZoneSidKey__c
            FROM Contact
            WHERE AccountId = :findOrCreateAccount().Id
                AND SlackUserId__c = :userId
        ];

        return userContacts.isEmpty() ? createContact(userId) : userContacts[0];
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