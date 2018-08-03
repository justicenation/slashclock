public with sharing class SlashclockStrikeCommand implements Slashclock.Command {

    private DateTime currentTime;
    
    /**
     * The index, starting at 1 (not 0), pointing to the time entry as shown
     * in `/clock entries`, identifying the entry to strike or delete.
     */
    private Integer entryIndex;

    private Contact userContact;

    public SlashclockStrikeCommand() {
        this.currentTime = DateTime.now();
        this.entryIndex = 1;  // by default strike the last time entry
        this.userContact = null;
    }

    public Slashclock.CommandResult execute() {

        // Initialize the result
        Slashclock.CommandResult result = new Slashclock.CommandResult();

        // Clock in via service
        try {
            SlashclockService slashclock =
                    SlashclockService.getInstance(this.userContact);

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

        // Find the contact for the Slack user
        SlackService slacker = SlackService.getInstance(command.SlackTeamId__c);
        this.userContact = slacker.findOrCreateContact(command.SlackUserId__c);
        
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