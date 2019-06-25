public with sharing class DatabaseJockey {

    /**
     * Deletes a list of existing sObject records, such as individual accounts
     * or contacts, from your organization’s data.
     *
     * @param recordsToDelete
     *
     * @return results from the DML operation
     *
     * @see https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_database.htm
     */
    public List<Database.DeleteResult> del(List<SObject> recordsToDelete) {
        return Database.delete(recordsToDelete, true);
    }
    
    /**
     * Adds one or more sObjects, such as individual accounts or contacts,
     * to your organization’s data.
     *
     * @param recordsToInsert
     *
     * @return results from the DML operation
     *
     * @see https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_database.htm
     */
    public List<Database.SaveResult> ins(List<SObject> recordsToInsert) {
        return Database.insert(recordsToInsert, true);
    }

    /**
     * @return a fresh jockey to perform DML operations
     */
    public static DatabaseJockey newInstance() {
        return new DatabaseJockey();
    }

    /**
     * Modifies one or more existing sObject records, such as individual
     * accounts or contacts, in your organization’s data.
     *
     * @param recordsToUpdate
     *
     * @return results from the DML operation
     *
     * @see https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_database.htm
     */
    public List<Database.SaveResult> upd(List<SObject> recordsToUpdate) {
        return Database.update(recordsToUpdate, true);
    }
}