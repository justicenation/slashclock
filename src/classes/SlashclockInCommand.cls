public with sharing class SlashclockInCommand implements Slashclock.Command {

    public static final String COMMAND_REGEX =
            'in( +(\\d{1,2}:\\d{2}{am|pm}))?';

    private DateTime startTime;
    private String teamId;
    private String timeZoneSidKey;
    private String userId;

	public SlashclockInCommand() {
		this.userId = null;
        this.teamId = null;
        this.timeZoneSidKey = DateTimeUtil.GMT_TIME_ZONE_SID_KEY;
        this.startTime = DateTime.now();
	}

    public Slashclock.CommandResult execute() {

        // Initialize the result
        Slashclock.CommandResult result = new Slashclock.CommandResult();

        // Clock in via service
        try {
            SlashclockService slashclock =
                    SlashclockService.getInstance(this.userId, this.teamId);
            slashclock.clockIn(this.startTime);
            result.setMessage(SlashclockService.CLOCKED_IN_SUCCESS);
            result.setSuccess(true);
        }
        catch (SlashclockException caught) {
            result.setMessage(caught.getMessage());
        }

        // Return the result
        return result;
    }

    public DateTime getStartTime() {
        return this.startTime;
    }

    public Slashclock.Command load(SlashCommand__c command) {

        // Remember the Slack User ID and Team ID
        this.userId = command.SlackUserId__c;
        this.teamId = command.SlackTeamId__c;

        // Locate the contact
        Contact userContact = SlackService.getInstance(
                this.teamId).findOrCreateContact(this.userId);

        this.timeZoneSidKey = userContact.TimeZoneSidKey__c;
        
        // Return the fully loaded SlashClock command!
        return this;
    }

    public Boolean matches(SlashCommand__c command) {
        
        // Determine whether the command matches our pattern
        Boolean matches = command.Text__c.startsWith('in');

        // If a match is found, load parmeters from the Slack command
        if (matches) {
            this.load(command);
        }

        // Return whether we found a match
        return matches;
    }
}