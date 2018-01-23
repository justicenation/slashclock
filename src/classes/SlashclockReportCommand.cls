public with sharing class SlashclockReportCommand implements Slashclock.Command {

    private DateTime endTime;
    private Boolean forLastWeek;
    private String teamId;
    private String userId;

    public SlashclockReportCommand() {
        this.userId = null;
        this.teamId = null;
        this.endTime = DateTime.now();
        this.forLastWeek = false;
    }

    public Slashclock.CommandResult execute() {

        // Initialize the result
        Slashclock.CommandResult result = new Slashclock.CommandResult();

        // Get the service
        SlashclockService slashclock =
                SlashclockService.getInstance(this.userId, this.teamId);

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
        this.userId = command.SlackUserId__c;
        this.teamId = command.SlackTeamId__c;

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