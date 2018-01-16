public class SlashclockUnknownCommand implements Slashclock.Command {

    public Slashclock.CommandResult execute() {

        // Initialize the result
        Slashclock.CommandResult result = new Slashclock.CommandResult();

        result.setSuccess(false);  // If we got here, things are not okay

        // TODO: Do the command


        // Return the result
        return result;
    }

    public Slashclock.Command load(SlashCommand__c command) {
        return this;
    }

    public Boolean matches(SlashCommand__c command) {
        return command.Command__c == '/clock';
    }
}