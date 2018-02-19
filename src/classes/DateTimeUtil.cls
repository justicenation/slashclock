public with sharing class DateTimeUtil {

    public static final String GMT_TIME_ZONE_SID_KEY = 'GMT';

    /**
     * Given a `Datetime` value, adjust the value by applying an offset to
     * correct for a time zone difference between an old, assumed time zone
     * and a new, accurate time zone.
     *
     * For example, for a value of Feb 19, 2018 1:00pm EST, if `adjust` is
     * called to adjust the value from an old time zone of "America/New_York"
     * to "America/Chicago", the return value should be Feb 19, 2018 1:00pm CST
     *
     * @param value The given `Datetime` value
     *
     * @param newTimeZone
     *
     * @param oldTimeZone
     *
     * @return the same local time as previously observed in the old time zone,
     *         but now adjusted to be accurately observed in the new time zone
     */
    public static Datetime adjust(
            Datetime value, TimeZone newTimeZone, TimeZone oldTimeZone) {

        // TODO
        return value;
    }
    
    public static Date getDate(DateTime value, String timeZoneSidKey) {
        return Date.valueOf(value.format('yyyy-MM-dd', timeZoneSidKey));
    }
    
    public static Time getTime(DateTime value, String timeZoneSidKey) {
        List<String> timeParts = value.format('H,m,s,S', timeZoneSidKey).split(',');

        return Time.newInstance(
                Integer.valueOf(timeParts[0]),
                Integer.valueOf(timeParts[1]),
                Integer.valueOf(timeParts[2]),
                Integer.valueOf(timeParts[3]));
    }

    /**
     * @return an integer representing the day of week
     *         
     *         - 0 (Sunday)
     *         - 1 (Monday)
     *         - 2 (Tuesday)
     *         - 3 (Wednesday)
     *         - 4 (Thursday)
     *         - 5 (Friday)
     *         - 6 (Saturday)
     */
    public static Integer getWeekday(Date value) {

        // Google says January 4, 1970 fell on a Sunday
        return Math.mod(Date.newInstance(1970, 1, 4).daysBetween(value), 7);
    }

    public static DateTime newDateTime(
            Date dateValue, Time timeValue, TimeZone zone) {

        // Calculate the offset as the number of seconds to add to the GMT
        // date and time defined by the `Date` and `Time` values.
        Integer offset = -1 * zone.getOffset(dateValue) / 1000 /* ms/sec */;
        
        return DateTime.newInstanceGmt(dateValue, timeValue).addSeconds(offset);
    }

    public static Datetime newDatetime(
            Date dateValue, Time timeValue, String timeZoneSidKey) {
        return newDateTime(
                dateValue, timeValue, TimeZone.getTimeZone(timeZoneSidKey));
    }

    /**
     * This functions similar to the `Decimal.setScale(Integer)` method,
     * where a given `Datetime` value is always rounded up to the nearest
     * increment of the given scale in minutes.
     *
     * For example, if the scale is 3 minutes, and the given value has a time
     * component of 2:46pm, the returned value should bumped up to 2:48pm.
     * if the given scale was instead 15 minutes, for the same given value
     * the returned value should be bumped up to 3:00pm.
     *
     * @param value The `Datetime` value to round
     *
     * @param scale The number of minutes per increment
     *
     * @return the value, rounded up to the next whole increment
     */
    public static Datetime setScale(Datetime value, Integer scale) {
        
        // Figure out the base number of minutes we're starting with
        Long seconds = value.getTime() / 1000;
        Long minutes = seconds / 60;

        // Round up
        Long remainder = Math.mod(minutes, scale);
        
        if (remainder > 0) {
            minutes = minutes + scale - remainder;
        }

        // Return the value rounded up
        return Datetime.newInstance(minutes * 60 * 1000);
    }

    public static Date startOfWeek(Date value, Weekday firstDayOfWeek) {

        // Figure out the weekday index of the given date
        Integer dayOfWeek = getWeekday(value);

        // Calculate the correct offset in number of days.
        // The offset may be 0 if the given date is the first day of the week.
        //
        // One example: If the given day is a Monday and the start of the week
        // is Sunday, the offset should be -1.
        //
        // Another example: If the given day is a Sunday and the start of the
        // week of Monday, the offset should be -6.
        Integer relativeOffset = dayOfWeek - firstDayOfWeek.ordinal();
        Integer absoluteOffset = relativeOffset < 0
                ? (firstDayOfWeek.ordinal() - dayOfWeek - 7)
                : (-1 * relativeOffset);

        // Return the start of the week by applying the offset
        return value.addDays(absoluteOffset);
    }

    public static DateTime startOfWeek(DateTime value, String timeZoneSidKey, Weekday firstDayOfWeek) {
        
        // Get the correct date for the given date/time
        Date refDate = getDate(value, timeZoneSidKey);

        // Given the reference date, figure out the correct date
        // for the start of the week
        Date startDate = startOfWeek(refDate, firstDayOfWeek);

        // Construct the date/time in GMT for the start of the week
        DateTime startOfWeekGmt = DateTime.newInstanceGmt(
                startDate.year(), startDate.month(), startDate.day(), 0, 0, 0);

        // Apply the appropriate time zone offset
        TimeZone zone = TimeZone.getTimeZone(timeZoneSidKey);
        Integer offset = zone.getOffset(startDate);

        return DateTime.newInstance(startOfWeekGmt.getTime() - offset);
    }

    /**
     * Zero out the seconds and milliseconds portion of a given DateTime
     * object for consistency of calculation
     *
     * @param  value
     *
     * @return the DateTime object with zero seconds and milliseconds
     */
    public static DateTime truncate(DateTime value) {

        Long numberOfMinutes = value.getTime()
                / 1000 /* ms/sec */
                / 60 /* sec/min */;

        return DateTime.newInstance(numberOfMinutes * 60 * 1000);
    }
}