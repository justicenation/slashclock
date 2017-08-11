public with sharing class DateTimeUtil {

    public static DateTime getDuration(DateTime startTime, DateTime endTime) {
        return DateTime.newInstance(endTime.getTime() - startTime.getTime());
    }
}