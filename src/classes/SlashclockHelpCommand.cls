public with sharing class SlashclockHelpCommand implements Slashclock.Command {

    public Slashclock.CommandResult execute() {
        return null;
    }

    public Slashclock.Command load(SlashCommand__c command) {
        return this;
    }

    public Boolean matches(SlashCommand__c command) {
        return command.Text__c.startsWith('help');
    }
}