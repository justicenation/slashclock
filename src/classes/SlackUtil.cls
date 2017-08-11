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

        // Initialize the list of parts expected in a line representing
        // an item in the report. Each item really only has two parts right
        // now: day of week, and amount of time.
        List<String> parts = new List<String>();

        // Add the formatted day of week
        parts.add(item.getLabel());

        // Add the formatted amount of time
        parts.add(item.formatDuration());

        // Return the formatted parts
        return String.join(parts, ' ');
    }
}