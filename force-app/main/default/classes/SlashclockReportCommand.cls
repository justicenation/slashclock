public with sharing class SlashclockReportCommand implements Slashclock.Command {

    private DateTime endTime;
    private Boolean forLastWeek;
    private Contact userContact;

    public SlashclockReportCommand() {
        this.endTime = DateTime.now();
        this.forLastWeek = false;
        this.userContact = null;
    }

    public Slashclock.CommandResult execute() {

        // Initialize the result
        Slashclock.CommandResult result = new Slashclock.CommandResult();

        // Get the service
        SlashclockService slashclock =
                SlashclockService.getInstance(this.userContact);

        // Adjust for last week if needed
        if (this.forLastWeek) {
            this.endTime = slashclock.getStartOfWeek(
                    this.endTime).addSeconds(-1);
        }
        else {

            // TODO: Make the scale configurable per user
            this.endTime = DatetimeUtil.setScale(this.endTime, 6);
        }

        // Generate the report
        SlashclockReport report = slashclock.report(this.endTime);
        result.setMessage(SlackUtil.format(report));
        result.setSuccess(true);

        // Return the result
        return result;
    }

    public Slashclock.Command load(SlashCommand__c command) {
        
        // Find the contact for the Slack user
        SlackService slacker = SlackService.getInstance(command.SlackTeamId__c);
        this.userContact = slacker.findOrCreateContact(command.SlackUserId__c);

        // Set the end time to the start of this week, so that the report
        // will contain all entries from the previous week.
        if (command.Text__c.endsWith('last week')) {
            this.forLastWeek = true;
        }

        return this;
    }

    public Boolean matches(SlashCommand__c command) {
        return command.Text__c.startsWith('report');
    }
}