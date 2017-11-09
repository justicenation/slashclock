public with sharing class SlashclockService {

    public static final String ALREADY_CLOCKED_IN_ERROR =
            'Uh, you already clocked in earlier...';

    public static final String CLOCKED_IN_SUCCESS =
            'You have clocked in.';

    public static final String CLOCKED_OUT_SUCCESS =
            'You have clocked out.';

    public static final String NOT_CLOCKED_IN_ERROR =
            'You must clock in first!';

    private Weekday firstDayOfWeek;

    /**
     * Slack Team ID
     */
    private String teamId;

    private String timeZoneSidKey;
    
    /**
     * Slack User ID
     */
    private String userId;

    public SlashclockService(String userId, String teamId) {
        this.userId = userId;
        this.teamId = teamId;

        // TODO: Make dynamic based on Slack user preference
        this.timeZoneSidKey = 'America/New_York';
        this.firstDayOfWeek = Weekday.MONDAY;
    }

    /**
     * @param startTime
     *            The time at which the user clocked in
     *
     * @return newly created, open time entry
     */
    public TimeEntry__c clockIn(DateTime startTime) {

        // Look for existing open entries
        if (this.getOpenTimeEntries().size() > 0) {
            throw new SlashclockException(ALREADY_CLOCKED_IN_ERROR);
        }

        // Construct the time entry
        TimeEntry__c entry = new TimeEntry__c(
                StartTime__c = startTime,
                SlackUserId__c = this.userId,
                SlackTeamId__c = this.teamId);

        // Insert and return the time entry
        insert entry;
        return entry;
    }

    /**
     * @param endTime
     *            The time at which the user clocked out
     *
     * @return updated time entry
     */
    public TimeEntry__c clockOut(DateTime endTime) {

        // Look for existing open entries
        List<TimeEntry__c> openTimeEntries = this.getOpenTimeEntries();
        if (openTimeEntries.isEmpty()) {
            throw new SlashclockException(NOT_CLOCKED_IN_ERROR);
        }

        // Update and return the open time entry.
        // TODO: Handle edge case where multiple open entries exist.
        TimeEntry__c entry =
                openTimeEntries.get(openTimeEntries.size() - 1);
        entry.EndTime__c = endTime;

        update entry;
        return entry;
    }

    public Time2 getClockedDuration(DateTime startTime, DateTime endTime) {
        Time2 duration = Time2.newInstance();

        for (TimeEntry__c eachEntry : this.getTimeEntries(startTime, endTime)) {

            // Use the range start time if the entry's start time is earlier
            if (eachEntry.StartTime__c < startTime) {
                eachEntry.StartTime__c = startTime;
            }

            // Use the range end time if no end time specified
            if (eachEntry.EndTime__c == null) {
                eachEntry.EndTime__c = DateTime.now();
            }

            // Use the range end time if the effective end time is later
            if (eachEntry.EndTime__c > endTime) {
                eachEntry.EndTime__c = endTime;
            }

            // Add the duration
            duration = duration.add(
                    eachEntry.EndTime__c.getTime()
                            - eachEntry.StartTime__c.getTime());
        }

        return duration;
    }

    /**
     * @return all open time entries for the user in context
     */
    public List<TimeEntry__c> getOpenTimeEntries() {
        return [
            SELECT Id
            FROM TimeEntry__c
            WHERE SlackUserId__c = :this.userId
                AND SlackTeamId__c = :this.teamId
                AND EndTime__c = NULL
        ];
    }

    public static SlashclockService getInstance(SlashclockService.Key serviceKey) {
        return getInstance(serviceKey.userId, serviceKey.teamId);
    }

    public static SlashclockService getInstance(String userId, String teamId) {
        return new SlashclockService(userId, teamId);
    }

    public TimeEntry__c getLastTimeEntry() {
        return [
            SELECT Id
            FROM TimeEntry__c
            WHERE SlackUserId__c = :this.userId
                AND SlackTeamId__c = :this.teamId
            ORDER BY StartTime__c DESC
            LIMIT 1
        ];
    }

    public DateTime getStartOfWeek(DateTime value) {
        return DateTimeUtil.startOfWeek(
                value, this.timeZoneSidKey, this.firstDayOfWeek);
    }

    public List<TimeEntry__c> getTimeEntries(DateTime startTime, DateTime endTime) {
        return [
            SELECT Id, StartTime__c, EndTime__c,
                (SELECT Id, NumberOfMinutes__c, Tag__c FROM TimeSlices__r)
            FROM TimeEntry__c
            WHERE SlackUserId__c = :this.userId
                AND SlackTeamId__c = :this.teamId
                AND StartTime__c < :endTime
                AND (EndTime__c >= :startTime OR EndTime__c = NULL)
            ORDER BY StartTime__c ASC
        ];
    }

    public SlashclockReport report(DateTime endTime) {

        // Figure out the start of the week for the given end time
        DateTime startOfWeek = this.getStartOfWeek(endTime);

        // Initialize the report
        SlashclockReport report = new SlashclockReport();

        // Go through every day for which we need to aggregate data
        for (SlashclockReportItem eachItem
                : SlashclockUtil.newDailyReportItems(
                        startOfWeek, endTime, this.timeZoneSidKey,
                        this.getTimeEntries(startOfWeek, endTime), 7)) {
            report.addItem(eachItem);
        }

        // Return the compiled report
        return report;
    }

    public TimeSlice__c slice(Decimal numberOfMinutes, String tag) {
        TimeSlice__c slice = new TimeSlice__c(
                TimeEntry__c = this.getLastTimeEntry().Id,
                NumberOfMinutes__c = numberOfMinutes,
                Tag__c = tag);

        insert slice;
        return slice;
    }

    public class Key {
        public String teamId { get; set; }
        public String userId { get; set; }

        public Key(String userId, String teamId) {
            this.userId = userId;
            this.teamId = teamId;
        }
    }
}