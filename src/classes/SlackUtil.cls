public with sharing class SlackUtil {

    public static String bold(String value) {
        return '*' + value + '*';
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