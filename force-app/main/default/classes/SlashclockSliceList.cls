public class SlashclockSliceList {

    private Map<String, SlashclockReportSlice> slicesByTag;

    public SlashclockSliceList() {
        this.slicesByTag = new Map<String, SlashclockReportSlice>();
    }

    public SlashclockSliceList(List<TimeSlice__c> timeSlices) {

        // Start with the defaults
        this();

        // Add every time slice
        for (TimeSlice__c eachSlice : timeSlices) {
            this.add(eachSlice);
        }
    }

    public void add(TimeSlice__c timeSlice) {
        this.add(SlashclockReportSlice.newInstance(timeSlice));
    }

    public void add(SlashclockReportSlice slice) {
        if (this.slicesByTag.containsKey(slice.getTag())) {
            this.slicesByTag.get(slice.getTag()).increase(slice.getDuration());
        }
        else {
            this.slicesByTag.put(slice.getTag(), slice);
        }
    }

    public String format() {
        return formatSlices(this.slicesByTag);
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

    public SlashclockReportSlice get(String tag) {
        return this.slicesByTag.get(tag);
    }

    public Integer size() {
        return this.slicesByTag.size();
    }

    public List<SlashclockReportSlice> values() {
        return this.slicesByTag.values();
    }
}