public with sharing class SlashclockInCommand implements Slashclock.Command {



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

    public static String getCommandRegex() {
        return 'in(\\s+.*)?';
    }

    public static Pattern getPattern() {
        return Pattern.compile(getCommandRegex());
    }

    public DateTime getStartTime() {
        return this.startTime;
    }

    public Slashclock.Command load(SlashCommand__c command) {

        // Remember the Slack User ID and Team ID,
        // then locate the contact and the time zone
        this.userId = command.SlackUserId__c;
        this.teamId = command.SlackTeamId__c;

        Contact userContact = SlackService.getInstance(
                this.teamId).findOrCreateContact(this.userId);

        this.timeZoneSidKey = userContact.TimeZoneSidKey__c;

        // Store a matcher for the command
        Matcher matcher = getPattern().matcher(command.Text__c);

        // Load the specific time if it exists
        if (matcher.matches() && !String.isEmpty(matcher.group(1))) {
            this.startTime =
                    DateTimeUtil.newDateTime(
                            DateTimeUtil.getDate(this.startTime, this.timeZoneSidKey),
                            TimeUtil.parseTime(matcher.group(1).trim()),
                            TimeZone.getTimeZone(this.timeZoneSidKey));
        }
        
        // Return the fully loaded SlashClock command!
        return this;
    }

    public Boolean matches(SlashCommand__c command) {
        
        // Return whether we found a match
        return getPattern().matcher(command.Text__c).matches();
    }
}