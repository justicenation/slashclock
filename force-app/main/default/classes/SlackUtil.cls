public with sharing class SlackUtil {

    public static String bold(String value) {
        return '*' + value + '*';
    }

    /**
     * Format a slash command as the full command plus text, used when
     * needing to provide feedback to the user that the command generated
     * an unexpected error
     *
     * @param command
     *
     * @return the full text as sent by the user
     */
    public static String format(SlashCommand__c command) {
        return String.isEmpty(command.Text__c)
                ? command.Command__c
                : command.Command__c + ' ' + command.Text__c;
    }

    public static String format(SlashclockReport report) {

        // Initialize the lines of text to render
        List<String> lines = new List<String>();

        lines.add(Label.SlashclockReportOpening);
        
        // Go through every daily item in the report, and format the item
        for (SlashclockReportItem eachItem : report.getItems()) {
            lines.add(format(eachItem));
        }

        // Add the summary line break
        lines.add(SlashclockReport.DEFAULT_SUMMARY_SEPARATOR);

        // Add the formatted summary line
        lines.add(format(report.getSummaryItem()));

        // Return the formatted
        return String.join(lines, '\n');
    }

    public static String format(SlashclockReportItem item) {
        return item.format();
    }

    public static String getWorkspaceUrl(String domain) {
        return 'https://' + domain + '.slack.com';
    }
}