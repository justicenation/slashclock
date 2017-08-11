public with sharing class SlackUtil {

    public static String format(SlashclockReport report) {

        // Initialize the lines of text to render
        List<String> lines = new List<String>();
        
        // Go through every daily item in the report, and format the item
        for (SlashclockReport.Item eachItem : report.getItems()) {
            lines.add(format(eachItem));
        }

        // Add the summary line break
        lines.add('==========');

        // Add the formatted summary line
        lines.add(format(report.getSummaryItem()));

        // Add the code block escape lines
        lines.add('```');
        lines.add(0, '```');

        // Return the formatted
        return String.join(lines, '\n');
    }

    public static String format(SlashclockReport.Item item) {
        return 'TODO';
    }
}