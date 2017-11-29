public with sharing class SlashclockReportItem {

    private Time2 duration;
    private String label;
    private Map<String, SlashclockReportSlice> slicesByTag;

    private SlashclockReportItem(String label, Time2 duration) {
        this.label = label;
        this.duration = duration;
        this.slicesByTag = new Map<String, SlashclockReportSlice>();
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
        if (this.slicesByTag.containsKey(slice.getTag())) {
            this.slicesByTag.get(slice.getTag()).increase(slice.getDuration());
        }
        else {
            this.slicesByTag.put(slice.getTag(), slice);
        }
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
        if (slicesByTag.size() > 0) {
            itemParts.add(formatSlices(this.slicesByTag));
        }

        // Return the parts joined by spaces
        return String.join(itemParts, ' ');
    }

    public static String formatSlices(Map<String, SlashclockReportSlice> slicesByTag) {

        // Initialize the formatted slice parts to join and return
        List<String> sliceParts = new List<String>();
        
        List<String> sliceTags = new List<String>(slicesByTag.keySet());
        sliceTags.sort();

        for (String tag : sliceTags) {
            SlashclockReportSlice eachSlice = slicesByTag.get(tag);
            sliceParts.add(eachSlice.format());
        }

        // Join and return the formatted slices
        return '(' + String.join(sliceParts, '; ') + ')';
    }

    public Time2 getDuration() {
        return this.duration;
    }

    public String getLabel() {
        return this.label;
    }

    public SlashclockReportSlice getSlice(String tag) {
        return this.slicesByTag.get(tag);
    }

    public List<SlashclockReportSlice> getSlices() {
        return this.slicesByTag.values();
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