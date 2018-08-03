public class TimeEntryUtil {

    public static TimeEntry__c verifyEndTimeZone(
            TimeEntry__c record, String timeZoneSidKey) {
        return record.HasVerifiedEndTimeZone__c || record.EndTime__c == null
                ? record
                : verifyTimeZone(record, timeZoneSidKey,
                        TimeEntry__c.EndTime__c,
                        TimeEntry__c.EndTimeZoneSidKey__c,
                        TimeEntry__c.HasVerifiedEndTimeZone__c);
    }

    public static TimeEntry__c verifyStartTimeZone(
            TimeEntry__c record, String timeZoneSidKey) {
        return record.HasVerifiedStartTimeZone__c || record.StartTime__c == null
                ? record
                : verifyTimeZone(record, timeZoneSidKey,
                        TimeEntry__c.StartTime__c,
                        TimeEntry__c.StartTimeZoneSidKey__c,
                        TimeEntry__c.HasVerifiedStartTimeZone__c);
    }

    public static List<TimeEntry__c> verifyTimeZone(
            List<TimeEntry__c> records, String timeZoneSidKey) {

        // Initialize the list of verified records
        List<TimeEntry__c> verified = new List<TimeEntry__c>();

        // Verify any unverified time zones
        for (TimeEntry__c eachRecord : records) {

            // Start Time Zone
            eachRecord = verifyStartTimeZone(eachRecord, timeZoneSidKey);

            // End Time Zone
            eachRecord = verifyEndTimeZone(eachRecord, timeZoneSidKey); 

            // Add the record to the list of verified records
            verified.add(eachRecord);
        }

        // Return the updated records
        return verified;
    }

    public static TimeEntry__c verifyTimeZone(
            TimeEntry__c record,
            String timeZoneSidKey,
            Schema.SObjectField timeField,
            Schema.SObjectField timeZoneField,
            Schema.SObjectField verifiedField) {

        // Update the time and time zone if the assumed time zone differs
        // from the real, given time zone
        if (!timeZoneSidKey.equals(record.get(timeZoneField))) {

            // Calculate the new time that is expected to be correct
            // based on the given time zone
            TimeZone oldTimeZone =
                    TimeZone.getTimeZone((String)record.get(timeZoneField));
            
            TimeZone newTimeZone =
                    TimeZone.getTimeZone(timeZoneSidKey);
            
            Datetime oldTime = (Datetime)record.get(timeField);
            
            Datetime newTime =
                    DatetimeUtil.adjust(oldTime, newTimeZone, oldTimeZone);

            // Update the record with the new time and time zone
            record.put(timeField, newTime);
            record.put(timeZoneField, timeZoneSidKey);
        }

        // Mark the time as verified
        record.put(verifiedField, true);

        // Return the verified record
        return record;
    }
}