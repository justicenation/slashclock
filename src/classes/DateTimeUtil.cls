public with sharing class DateTimeUtil {

    public static final String GMT_TIME_ZONE_SID_KEY = 'GMT';

    public static final String TIME_REGEX = '(\\d{1,2}):(\\d{2}) *(am|pm)';

    public static Date getDate(DateTime value, String timeZoneSidKey) {
        return Date.valueOf(value.format('yyyy-MM-dd', timeZoneSidKey));
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