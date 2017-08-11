public with sharing class SlashclockInCommand implements Slashclock.Command {

    private DateTime startTime;
    private String teamId;
    private String userId;

	public SlashclockInCommand() {
		this.userId = null;
        this.teamId = null;
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

    public Slashclock.Command load(SlashCommand__c command) {
        this.userId = command.SlackUserId__c;
        this.teamId = command.SlackTeamId__c;
        return this;
    }

    public Boolean matches(SlashCommand__c command) {
        return command.Text__c.startsWith('in');
    }
}