public with sharing class TimeUtil {

    public static final String AM_PERIOD = 'am';

    public static final String TIME_REGEX = '(\\d{1,2}):(\\d{2}) *(am|pm)';

    public static final String PM_PERIOD = 'pm';

    public static Time parseTime(String value) {

        // Get a time pattern matcher for the given value
        Matcher timeMatcher = Pattern.compile(
                TIME_REGEX).matcher(value.toLowerCase());

        // If no match, throw a type exception
        if (!timeMatcher.matches()) {
            throw new TypeException(value);
        }

        // Return the parsed time
        Integer hour = Integer.valueOf(timeMatcher.group(1));
        Integer minute = Integer.valueOf(timeMatcher.group(2));
        String period = timeMatcher.group(3);

        if (period == PM_PERIOD && hour < 12) {
            hour += 12;
        }
        else if (period == AM_PERIOD && hour == 12) {
            hour = 0;
        }

        return Time.newInstance(hour, minute, 0, 0);
    }
}