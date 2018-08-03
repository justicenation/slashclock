public with sharing class DatabaseUtil {
    public static Id updateLater(Sobject record) {
        return updateLater(new List<Sobject> { record });
    }
    public static Id updateLater(List<Sobject> records) {
        return System.enqueueJob(new UpdateJob(records));
    }
}