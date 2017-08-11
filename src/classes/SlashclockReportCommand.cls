public with sharing class SlashclockReportCommand implements Slashclock.Command {

    private String teamId;
    private String userId;

    public SlashclockReportCommand() {
        this.userId = null;
        this.teamId = null;
    }

    public Slashclock.CommandResult execute() {

        // Initialize the result
        Slashclock.CommandResult result = new Slashclock.CommandResult();

        // Clock in via service
        SlashclockService slashclock =
                SlashclockService.getInstance(this.userId, this.teamId);
        SlashclockReport report = slashclock.report(DateTime.now());
        result.setMessage(SlackUtil.format(report));
        result.setSuccess(true);

        // Return the result
        return result;
    }

    public Slashclock.Command load(SlashCommand__c command) {
        this.userId = command.SlackUserId__c;
        this.teamId = command.SlackTeamId__c;
        return this;
    }

    public Boolean matches(SlashCommand__c command) {
        return command.Text__c.startsWith('report');
    }
}