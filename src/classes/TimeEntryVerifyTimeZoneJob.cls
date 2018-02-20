/**
 * This job takes a list of Contact ID values, and for each contact
 * the job attempts to get the contact's current time zone and verify any
 * unverified time zones in time entries under the contact.
 *
 * This job is also responsible for updating the contact's time zone
 * if the contact's time zone changed based on the API response from Slack.
 */
global with sharing class TimeEntryVerifyTimeZoneJob implements Requestable {

    private List<Id> contactIds;

    global TimeEntryVerifyTimeZoneJob(List<Id> contactIds) {
        this.contactIds = contactIds;
    }

    global void execute() {

        // Initialize a list of the contacts whose time zones changed
        List<Contact> newContacts = new List<Contact>();

        for (Contact eachContact : this.getContacts()) {

            // Get the time zone from Slack for the user
            String timeZoneSidKey = SlackService.getInstance(
                    eachContact.SlackTeamId__c).getTimeZoneSidKey(eachContact);

            // Verify time entries for the contact
            TimeEntryDataService.getInstance(
                    eachContact.Id).verifyTimeZone(timeZoneSidKey);

            // If the contact time zone changed, make sure to update it
            if (!timeZoneSidKey.equals(eachContact.TimeZoneSidKey__c)) {
                eachContact.TimeZoneSidKey__c = timeZoneSidKey;
                newContacts.add(eachContact);
            }
        }

        // Update the contacts whose time zones changed
        update newContacts;
    }

    global void execute(Database.BatchableContext context) {
        this.execute();
    }

    global List<Contact> getContacts() {
        return [
            SELECT
                SlackTeamId__c,
                SlackUserId__c,
                TimeZoneSidKey__c,
                Id
            FROM Contact
            WHERE Id IN :this.contactIds
        ];
    }
}