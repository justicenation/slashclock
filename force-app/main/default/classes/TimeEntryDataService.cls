public with sharing class TimeEntryDataService {

    /**
     * The Contact ID for the contact serviced by this instance
     */
    private Id contactId;

    /**
     * Map of cached service instances by Contact ID
     */
    private static Map<Id, TimeEntryDataService> instanceMap =
            new Map<Id, TimeEntryDataService>();

    public TimeEntryDataService(Id contactId) {
        this.contactId = contactId;
    }

    public static TimeEntryDataService getInstance(Id contactId) {

        // Add a new instance to the map
        if (!instanceMap.containsKey(contactId)) {
            instanceMap.put(contactId, new TimeEntryDataService(contactId));
        }

        // Return the instance
        return instanceMap.get(contactId);
    }

    public List<TimeEntry__c> getUnverifiedTimeEntries() {
        return [
            SELECT
                EndTime__c,
                EndTimeZoneSidKey__c,
                HasVerifiedEndTimeZone__c,
                HasVerifiedStartTimeZone__c,
                StartTime__c,
                StartTimeZoneSidKey__c,
                Id
            FROM TimeEntry__c
            WHERE
                (
                    HasVerifiedStartTimeZone__c = FALSE OR
                    HasVerifiedEndTimeZone__c = FALSE
                ) AND
                Contact__c = :this.contactId
        ];
    }

    public void verifyTimeZone(String timeZoneSidKey) {
        update TimeEntryUtil.verifyTimeZone(
                this.getUnverifiedTimeEntries(), timeZoneSidKey);
    }
}