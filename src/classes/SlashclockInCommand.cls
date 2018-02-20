public with sharing class SlashclockInCommand implements Slashclock.Command {

    private DateTime startTime;
    private Contact userContact;

	public SlashclockInCommand() {
        this.startTime = DateTime.now();
        this.userContact = null;
	}

    public Slashclock.CommandResult execute() {

        // Initialize the result
        Slashclock.CommandResult result = new Slashclock.CommandResult();

        try {       

            // Clock in
            SlashclockService.getInstance(
                    this.userContact).clockIn(this.startTime);

            // Verify the time zone for this operation
            TimeEntryVerifyTimeZoneJob job =
                    new TimeEntryVerifyTimeZoneJob(
                            new List<Id> { this.userContact.Id });

            ApexJobService.getInstance().submitAndProcess(
                    TimeEntryVerifyTimeZoneJob.class, job);

            // Set the success message
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
        return 'in(\\s+(yesterday\\s+)?(.+))?';
    }

    public static Pattern getPattern() {
        return Pattern.compile(getCommandRegex());
    }

    public DateTime getStartTime() {
        return this.startTime;
    }

    public Slashclock.Command load(SlashCommand__c command) {

        // Find the contact to get the time zone
        SlackService slacker = SlackService.getInstance(command.SlackTeamId__c);
        this.userContact = slacker.findOrCreateContact(command.SlackUserId__c);

        // Store a matcher for the command
        Matcher matcher = getPattern().matcher(command.Text__c);

        // Load the specific time if it exists
        if (matcher.matches() && !String.isEmpty(matcher.group(3))) {

            // Determine what the correct offset is to pass to `addDays`
            // to calculate the correct date
            Integer offset = String.isEmpty(matcher.group(2)) ? 0 : -1;

            // Derive the correct end time
            this.startTime =
                    DateTimeUtil.newDateTime(
                            DateTimeUtil.getDate(this.startTime, this.userContact.TimeZoneSidKey__c).addDays(offset),
                            TimeUtil.parseTime(matcher.group(3).trim()),
                            TimeZone.getTimeZone(this.userContact.TimeZoneSidKey__c));
        }
        
        // Return the fully loaded SlashClock command!
        return this;
    }

    public Boolean matches(SlashCommand__c command) {
        
        // Return whether we found a match
        return command.Text__c.startsWith('in');
    }
}