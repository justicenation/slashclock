public class SlashclockUnknownCommand implements Slashclock.Command {

    private String commandText;

    public SlashclockUnknownCommand() {
        this.commandText = null;
    }

    public Slashclock.CommandResult execute() {

        // Initialize the result
        Slashclock.CommandResult result = new Slashclock.CommandResult();

        result.setSuccess(false);  // If we got here, things are not okay

        // Set the error message
        SlashclockContentService slashclockContent =
                SlashclockContentService.getInstance();

        result.setMessage(
                SlashclockContentUtil.place(
                        new List<String> { this.commandText },
                        slashclockContent.getContent(
                                SlashclockContentName.UNKNOWN_COMMAND)));

        // Return the result
        return result;
    }

    public static String getCommandRegex() {
        return '((.+?)(\\s+.*)?)?';
    }

    public static Pattern getPattern() {
        return Pattern.compile(getCommandRegex());
    }

    public Slashclock.Command load(SlashCommand__c command) {

        // Default the command text for the later parameterization
        this.commandText = command.Command__c;

        // Figure out whether a command was issued
        if (!String.isEmpty(command.Text__c)) {
            Matcher matcher = getPattern().matcher(command.Text__c);

            if (matcher.matches()) {
                if (!String.isEmpty(matcher.group(2))) {
                    this.commandText += ' ' + matcher.group(2);
                }
            }
        }

        return this;
    }

    public Boolean matches(SlashCommand__c command) {
        return command.Command__c == '/clock';
    }
}