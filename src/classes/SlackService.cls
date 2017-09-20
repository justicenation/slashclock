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
                SlackUserId__c = userId);

        insert userContact;
        return userContact;
    }

    public Account findOrCreateAccount() {

        // Look for an existing account
        List<Account> teamAccounts = [
            SELECT Id, Name
            FROM Account
            WHERE SlackTeamId__c = :this.teamId
        ];

        return teamAccounts.isEmpty() ? createAccount() : teamAccounts[0];
    }

    public Contact findOrCreateContact(String userId) {

        // Look for a existing contact
        List<Contact> userContacts = [
            SELECT Id, TimeZoneSidKey__c
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
}