public with sharing class SlashclockReport {

    public static String DEFAULT_SUMMARY_SEPARATOR = '--';

    private List<SlashclockReportItem> items;

    public SlashclockReport() {
        this.items = new List<SlashclockReportItem>();
    }

    public void addItem(SlashclockReportItem item) {
        this.items.add(item);
    }

    public List<SlashclockReportItem> getItems() {
        return this.items;
    }

    public String format() {

        // Initialize the lines to expect in the report
        List<String> lines = new List<String>();

        // Add the individual items
        for (SlashclockReportItem eachItem : this.items) {
            lines.add(eachItem.format());
        }

        // Add the summary separator and summary item
        lines.add(DEFAULT_SUMMARY_SEPARATOR);
        lines.add(this.getSummaryItem().format());

        // Return the lines joined by the line break
        return String.join(lines, '\n');
    }

    public SlashclockReportItem getSummaryItem() {

        // Initialize the summary item with zero duration
        SlashclockReportItem summary =
                SlashclockReportItem.newInstance('*SUM*', Time2.newInstance());

        // Add all of the individual items
        for (SlashclockReportItem eachItem : this.items) {
            summary = summary.add(eachItem);
        }

        // Return the summary item
        return summary;
    }
}