trigger TimeEntryTrigger on TimeEntry__c (before insert, before update) {

    // Truncate all times down to the minute level
    for (TimeEntry__c eachEntry : Trigger.new) {
        if (eachEntry.StartTime__c != null) {
            eachEntry.StartTime__c =
                    DateTimeUtil.truncate(eachEntry.StartTime__c);
        }

        if (eachEntry.EndTime__c != null) {
            eachEntry.EndTime__c =
                    DateTimeUtil.truncate(eachEntry.EndTime__c);
        }
    }
}