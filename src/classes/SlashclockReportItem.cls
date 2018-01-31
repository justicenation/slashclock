public with sharing class SlashclockReportItem {

    private Time2 duration;
    private String label;
    private SlashclockSliceList slices;

    private SlashclockReportItem(String label, Time2 duration) {
        this.label = label;
        this.duration = duration;
        this.slices = new SlashclockSliceList();
    }

    public SlashclockReportItem add(SlashclockReportItem other) {

        // Initialize the new item, using the current item as the base
        SlashclockReportItem newItem =
                SlashclockReportItem.newInstance(this.label, this.duration);

        // Add the existing item's slices
        for (SlashclockReportSlice eachSlice : this.getSlices()) {
            newItem.addSlice(eachSlice);
        }

        // Add the other item's duration
        newItem.addDuration(other.getDuration());

        // Add the other item's slices
        for (SlashclockReportSlice eachSlice : other.getSlices()) {
            newItem.addSlice(eachSlice);
        }

        // Return the new item
        return newItem;
    }

    public void addDuration(Long duration) {
        this.duration = this.duration.add(duration);
    }

    public void addDuration(Time2 duration) {
        this.duration = this.duration.add(duration);
    }

    public void addSlice(SlashclockReportSlice slice) {
        this.slices.add(slice);
    }

    /**
     * Format this line item to show the label, followed by any applicable
     * slices and tags. Formatted line item samples below.
     *
     * Mon 8h
     * Tue 8.25h
     * Wed 8.5h
     * Thu 8h (0.5h alpha)
     * Fri 8.25h (1h alpha; 2h beta)
     * SUM 40h (4h gamma; 8h delta)
     *
     * @return the formatted time report line item
     */
    public String format() {

        // Initialize the known parts of the string
        List<String> itemParts = new List<String> {
            this.label, SlackUtil.bold(this.duration.formatH())
        };

        // Add a part for the slices if we have any slices
        if (slices.size() > 0) {
            itemParts.add(this.slices.format());
        }

        // Return the parts joined by spaces
        return String.join(itemParts, ' ');
    }

    public Time2 getDuration() {
        return this.duration;
    }

    public String getLabel() {
        return this.label;
    }

    public SlashclockReportSlice getSlice(String tag) {
        return this.slices.get(tag);
    }

    public List<SlashclockReportSlice> getSlices() {
        return this.slices.values();
    }

    public static SlashclockReportItem newInstance(DateTime startTime, String timeZoneSidKey, Time2 duration) {
        return newInstance(formatLabel(startTime, timeZoneSidKey), duration);
    }

    public static SlashclockReportItem newInstance(String label, Time2 duration) {
        return new SlashclockReportItem(label, duration);
    }

    public static String formatLabel(DateTime startTime, String timeZoneSidKey) {
        return startTime.format('EEE', timeZoneSidKey);
    }
}