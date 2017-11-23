public with sharing class SlashclockStrikeCommand implements Slashclock.Command {

    private DateTime currentTime;
    
    /**
     * The index, starting at 1 (not 0), pointing to the time entry as shown
     * in `/clock entries`, identifying the entry to strike or delete.
     */
    private Integer entryIndex;

    private String teamId;
    private String userId;

    public SlashclockStrikeCommand() {
        this.userId = null;
        this.teamId = null;

        this.currentTime = DateTime.now();
        this.entryIndex = 1;  // by default strike the last time entry
    }

    public Slashclock.CommandResult execute() {

        // Initialize the result
        Slashclock.CommandResult result = new Slashclock.CommandResult();

        // Clock in via service
        try {
            SlashclockService slashclock =
                    SlashclockService.getInstance(this.userId, this.teamId);

            TimeEntry__c struck = slashclock.getTimeEntriesSince(
                    this.currentTime.addDays(-1 * 7)).get(this.entryIndex - 1);

            delete struck;

            result.setSuccess(true);
            result.setMessage(Label.SlashclockStrikeSuccess.replace(
                    '{0}', slashclock.formatEntry(struck, this.entryIndex)));
        }
        catch (SlashclockException caught) {
            result.setMessage(caught.getMessage());
        }

        // Return the result
        return result;
    }

    public static String getCommandRegex() {
        return 'strike(\\s+(\\d+))?';
    }

    public static Pattern getPattern() {
        return Pattern.compile(getCommandRegex());
    }

    public Slashclock.Command load(SlashCommand__c command) {

        // Remember the Slack User ID and Team ID,
        // then locate the contact and the time zone
        this.userId = command.SlackUserId__c;
        this.teamId = command.SlackTeamId__c;
        
        // Store a matcher for the command
        Matcher matcher = getPattern().matcher(command.Text__c);

        // Load the specific time if it exists
        if (matcher.matches() && !String.isEmpty(matcher.group(2))) {
            this.entryIndex = Integer.valueOf(matcher.group(2));
        }
        
        // Return the fully loaded SlashClock command!
        return this;
    }

    public Boolean matches(SlashCommand__c command) {
        
        // Return whether we found a match
        return command.Text__c.startsWith('strike');
    }
}