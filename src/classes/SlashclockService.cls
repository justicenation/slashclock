public with sharing class SlashclockService {

    public static final String ALREADY_CLOCKED_IN_ERROR =
            'Uh, you already clocked in earlier.';

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
     * @return all open time entries for the user in context
     */
    public List<TimeEntry__c> getOpenTimeEntries() {
        return [
            SELECT Id
            FROM TimeEntry__c
            WHERE SlackUserId__c = :this.userId
                AND SlackTeamId__c = :this.teamId
        ];
    }

    public static SlashclockService getInstance(String userId, String teamId) {
        return new SlashclockService(userId, teamId);
    }
}