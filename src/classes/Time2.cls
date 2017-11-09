public class Time2 {

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

    public String formatH() {
        return this.hours() + 'h';
    }

    public static Matcher getMatcher(String value) {
        String regex = '([0-9.]+\\s+hours?)?\\s*([0-9.]+\\s+minutes?)?\\s*([0-9.]+\\s+seconds?)?';
        return Pattern.compile(regex).matcher(value);
    }

    public Long getTime() {
        return (((this.days * 24 /* hours per day */ + this.remainder.hour())
                * 60 /* minutes per hour */ + this.remainder.minute())
                * 60 /* seconds per minute */ + this.remainder.second())
                * 1000 /* ms per second */ + this.remainder.millisecond();
    }

    public Decimal hours() {
        Decimal total = this.days * 24 + this.remainder.hour();
        total += this.remainder.minute() / 60.0;
        total += this.remainder.second() / 60.0 / 60.0;
        total += this.remainder.millisecond() / 1000.0 / 60.0 / 60.0;
        return total;
    }

    public Decimal minutes() {
        Decimal hours = this.days * 24 + this.remainder.hour();
        Decimal minutes = hours * 60 + this.remainder.minute();
        return minutes
                + this.remainder.second() / 60.0
                + this.remainder.millisecond() / 1000.0 / 60.0;
    }

    public static Time2 newInstance() {
        return newInstance(0, 0, 0, 0, 0);
    }

    public static Time2 newInstance(
            Integer days, Integer hours,
            Integer minutes, Integer seconds, Integer millis) {
        return new Time2(days, hours, minutes, seconds, millis);
    }

    public static Time2 newInstance(Decimal totalMillis) {
        return newInstance(totalMillis.longValue());
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

    /**
     * Parse an increment of time, such as the following.
     *
     * - 10 seconds
     * - 17 minutes
     * - 1 hour
     * - 2.5 hours
     *
     * @param value
     *
     * @return the time increment as a `Time2` object
     *
     * @see https://get.slack.help/hc/en-us/articles/208423427-set-a-reminder
     */
    public static Time2 parse(String value) {

        // Initialize duration values
        Decimal hours = 0;
        Decimal minutes = 0;
        Decimal seconds = 0;

        // Define the regex used to parse the time.
        // Assume times would be given in order of magnitude, starting
        // with the largest unit.
        Matcher matcher = getMatcher(value);

        if (matcher.matches()) {

            // Read the number of hours
            if (!String.isEmpty(matcher.group(1))) {
                hours = Decimal.valueOf(matcher.group(1).split('\\s')[0]);
            }

            // Read the number of minutes
            if (!String.isEmpty(matcher.group(2))) {
                minutes = Decimal.valueOf(matcher.group(2).split('\\s')[0]);
            }

            // Read the number of seconds
            if (!String.isEmpty(matcher.group(3))) {
                seconds = Decimal.valueOf(matcher.group(3).split('\\s')[0]);
            }
        }

        // Return the parsed time
        return Time2.newInstance(
                ((hours * 60 + minutes) * 60 + seconds) * 1000);
    }
}