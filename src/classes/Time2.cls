public with sharing class Time2 {

    private Integer days;
    private Time remainder;

    public Time2(Integer days, Time remainder) {
        this.days = days;
        this.remainder = remainder;
    }

    public Time2(
            Integer days, Integer hours,
            Integer minutes, Integer seconds, Integer millis) {
        this.days = days;
        this.remainder = Time.newInstance(hours, minutes, seconds, millis);
    }

    public Time2 add(Long value) {
        return newInstance(this.getTime() + value);
    }

    public Time2 add(Time2 value) {
        return this.add(value.getTime());
    }

    public Decimal inHours() {
        Decimal total = this.days * 24 + this.remainder.hour();
        total += this.remainder.minute() / 60.0;
        total += this.remainder.second() / 60.0 / 60.0;
        total += this.remainder.millisecond() / 60.0 / 60.0 / 60.0;
        return total;
    }

    public Long getTime() {
        return (((this.days * 24 /* hours per day */ + this.remainder.hour())
                * 60 /* minutes per hour */ + this.remainder.minute())
                * 60 /* seconds per minute */ + this.remainder.second())
                * 1000 /* ms per second */ + this.remainder.millisecond();
    }

    public static Time2 newInstance() {
        return newInstance(0, 0, 0, 0, 0);
    }

    public static Time2 newInstance(
            Integer days, Integer hours,
            Integer minutes, Integer seconds, Integer millis) {
        return new Time2(days, hours, minutes, seconds, millis);
    }

    public static Time2 newInstance(Long totalMillis) {

        // Truncate up to find useful values up each order of magnitude
        Long totalSeconds = totalMillis / 1000;
        Long totalMinutes = totalSeconds / 60;
        Long totalHours = totalMinutes / 60;

        // Calculate the full days included in the duration
        Integer days = (totalHours / 24).intValue();

        // Calculate the remainder in hours, minutes, seconds and ms
        Integer hours = (totalHours - days * 24).intValue();
        Integer minutes = (totalMinutes - totalHours * 60).intValue();
        Integer seconds = (totalSeconds - totalMinutes * 60).intValue();
        Integer millis = (totalMillis - totalSeconds * 1000).intValue();

        // Return the Time2 object
        return new Time2(
                days, Time.newInstance(hours, minutes, seconds, millis));
    }
}