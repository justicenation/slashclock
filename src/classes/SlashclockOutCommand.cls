public with sharing class SlashclockOutCommand implements Slashclock.Command {

    private DateTime endTime;
    private String teamId;
    private String userId;

    public SlashclockOutCommand() {
        this.userId = null;
        this.teamId = null;
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

    public Slashclock.Command load(SlashCommand__c command) {
        this.userId = command.SlackUserId__c;
        this.teamId = command.SlackTeamId__c;
        return this;
    }

    public Boolean matches(SlashCommand__c command) {
        return command.Text__c.startsWith('out');
    }
}