public with sharing class SlashclockHelpCommand implements Slashclock.Command {

    /**
     * The subcommand that comes after `/clock help` as issued by the user
     */
    private String subcommandText;

    public SlashclockHelpCommand() {
        this.subcommandText = null;
    }

    public Slashclock.CommandResult execute() {

        // Get the content type and appropriate content based on the subcommand
        SlashclockContentName contentName =
                SlashclockContentUtil.getHelpContentName(this.subcommandText);

        SlashclockContentService slashclockContent =
                SlashclockContentService.getInstance();

        // Construct a success result
        Slashclock.CommandResult result = new Slashclock.CommandResult();

        result.setSuccess(true);
        result.setMessage(slashclockContent.getContent(contentName));

        // Return the result
        return result;
    }

    public Slashclock.Command load(SlashCommand__c command) {
        return this;
    }

    public Boolean matches(SlashCommand__c command) {
        return command.Text__c.startsWith('help');
    }
}