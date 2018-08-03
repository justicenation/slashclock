public with sharing class SlashclockReportSlice {

    private Time2 duration;
    private String tag;

    public SlashclockReportSlice(Time2 duration, String tag) {
        this.duration = duration;
        this.tag = tag;
    }

    public String format() {
        return this.duration.formatH() + ' ' + this.tag;
    }

    public Time2 getDuration() {
        return this.duration;
    }

    public String getTag() {
        return this.tag;
    }

    public void increase(Time2 increment) {
        this.duration = this.duration.add(increment);
    }

    public static SlashclockReportSlice newInstance(TimeSlice__c record) {
        Integer minute = record.NumberOfMinutes__c.intValue();
        Time2 duration = Time2.newInstance(0, 0, minute, 0, 0);
        return new SlashclockReportSlice(duration, record.Tag__c);
    }
}