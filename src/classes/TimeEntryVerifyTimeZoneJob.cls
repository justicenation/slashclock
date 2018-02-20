/**
 * This job takes a list of Contact ID values, and for each contact
 * the job attempts to get the contact's current time zone and verify any
 * unverified time zones in time entries under the contact
 */
global with sharing class TimeEntryVerifyTimeZoneJob implements Requestable {

    private List<Id> contactIds;

    global TimeEntryVerifyTimeZoneJob(List<Id> contactIds) {
        this.contactIds = contactIds;
    }

    global void execute() {
        for (Contact eachContact : this.getContacts()) {

            // Get the time zone from Slack for the user
            String timeZoneSidKey = SlackService.getInstance(
                    eachContact.SlackTeamId__c).getTimeZoneSidKey(eachContact);

            // Verify time entries for the contact
            TimeEntryDataService.getInstance(
                    eachContact.Id).verifyTimeZone(timeZoneSidKey);
        }
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