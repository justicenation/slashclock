public with sharing class SlashclockOutCommand implements Slashclock.Command {

    private DateTime endTime;
    private String teamId;
    private String timeZoneSidKey;
    private String userId;

    public SlashclockOutCommand() {
        this.userId = null;
        this.teamId = null;
        this.timeZoneSidKey = null;
        this.endTime = DateTime.now();
    }

    public Slashclock.CommandResult execute() {

        // Initialize the result
        Slashclock.CommandResult result = new Slashclock.CommandResult();

        // Clock in via service
        try {
            SlashclockService slashclock =
                    SlashclockService.getInstance(this.userId, this.teamId);
            slashclock.clockOut(this.endTime);
            result.setMessage(SlashclockService.CLOCKED_OUT_SUCCESS);
            result.setSuccess(true);
        }
        catch (SlashclockException caught) {
            result.setMessage(caught.getMessage());
        }

        // Return the result
        return result;
    }

    public static String getCommandRegex() {
        return 'out(\\s+.*)?';
    }

    public static Pattern getPattern() {
        return Pattern.compile(getCommandRegex());
    }

    public Slashclock.Command load(SlashCommand__c command) {

        // Remember the Slack User ID and Team ID,
        // then locate the contact and the time zone
        this.userId = command.SlackUserId__c;
        this.teamId = command.SlackTeamId__c;
        
        SlackService slacker = SlackService.getInstance(this.teamId);
        this.timeZoneSidKey = slacker.getTimeZoneSidKey(this.userId);

        // Update the contact's time zone if it's determined to be
        Contact userContact = slacker.findOrCreateContact(this.userId);

        if (userContact.TimeZoneSidKey__c != this.timeZoneSidKey) {
            userContact.TimeZoneSidKey__c = this.timeZoneSidKey;
            DatabaseUtil.updateLater(userContact);
        }

        // Load the specific time if specified
        Matcher matcher = getPattern().matcher(command.Text__c);

        if (matcher.matches() && !String.isEmpty(matcher.group(1))) {
            this.endTime =
                    DateTimeUtil.newDateTime(
                            DateTimeUtil.getDate(this.endTime, this.timeZoneSidKey),
                            TimeUtil.parseTime(matcher.group(1).trim()),
                            TimeZone.getTimeZone(this.timeZoneSidKey));
        }

        // Return the fully loaded SlashClock command!
        return this;
    }

    public Boolean matches(SlashCommand__c command) {
        return getPattern().matcher(command.Text__c).matches();
    }
}