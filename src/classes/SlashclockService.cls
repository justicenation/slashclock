public with sharing class SlashclockService {

    public static final String ALREADY_CLOCKED_IN_ERROR =
            'Uh, you already clocked in earlier...';

    public static final String CLOCKED_IN_SUCCESS =
            'You have clocked in.';

    public static final String CLOCKED_OUT_SUCCESS =
            'You have clocked out.';

    public static final String NOT_CLOCKED_IN_ERROR =
            'You must clock in first!';

    /**
     * Slack Team ID
     */
    private String teamId;
    
    /**
     * Slack User ID
     */
    private String userId;

    public SlashclockService(String userId, String teamId) {
        this.userId = userId;
        this.teamId = teamId;        
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

    public Time getClockedDuration(DateTime startTime, DateTime endTime) {
        return Time.newInstance(8, 30, 0, 0);
    }

    public DateTime getDateStartTime(DateTime ref) {
        return ref;
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

    public SlashclockReport report(DateTime endTime) {

        // Initialize the report
        SlashclockReport report = new SlashclockReport();

        // Initialize the list of days for which we need to aggregate data
        DateTime lastDayStartTime = this.getDateStartTime(endTime);
        List<DateTime> reportDays = new List<DateTime> { lastDayStartTime };
        while (reportDays.size() < 7) {
            reportDays.add(0, reportDays.get(0).addDays(-1));
        }

        // Go through every day for which we need to aggregate data
        for (DateTime eachDay : reportDays) {
            report.addItem(
                    eachDay,
                    this.getClockedDuration(eachDay, eachDay.addDays(1)));
        }

        // Return the compiled report
        return report;
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