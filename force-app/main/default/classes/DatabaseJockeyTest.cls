@isTest
private class DatabaseJockeyTest {

    /** 
     * Confirm that `newInstance` always returns a different instance
     * of `DatabaseJockey`.
     */
    @isTest
    private static void newInstancesAreDifferent() {

        // Given
        DatabaseJockey givenJockey = DatabaseJockey.newInstance();

        // When
        Test.startTest();

        DatabaseJockey newJockey = DatabaseJockey.newInstance();

        // Then
        Test.stopTest();

        System.assertNotEquals(
            givenJockey,
            newJockey,
            'New jockey should not be the same as given jockey'
        );
    }
}