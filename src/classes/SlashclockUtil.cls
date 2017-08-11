public with sharing class SlashclockUtil {
    public static List<Slashclock.Command> getKnownCommands() {
        return new List<Slashclock.Command> {
            new SlashclockInCommand(),
            new SlashclockOutCommand(),
            new SlashclockReportCommand()
        };
    }

    public static Slashclock.Command newCommand(SlashCommand__c command) {

        // Placeholder for the command to return
        Slashclock.Command matchedCommand = null;

        // Go through all known commands to look for a match
        List<Slashclock.Command> knownCommands = getKnownCommands();

        while (matchedCommand == null && knownCommands.size() > 0) {
            Slashclock.Command knownCommand = knownCommands.remove(0);
            if (knownCommand.matches(command)) {
                matchedCommand = knownCommand.load(command);
            }
        }

        // Return the matched command
        return matchedCommand;
    }

    public static SlashclockService.Key newServiceKey(SlashCommand__c command) {
        return new SlashclockService.Key(command.SlackUserId__c, command.SlackTeamId__c);
    }
}