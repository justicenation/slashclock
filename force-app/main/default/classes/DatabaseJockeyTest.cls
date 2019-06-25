@isTest
private class DatabaseJockeyTest {

    /**
     * Confirm that a jockey can create an account.
     */
    @isTest
    private static void insertAccount() {

        // Given
        Account acme = new Account(
            Name = 'Acme, Inc. (TEST)'
        );

        // When
        Test.startTest();

        DatabaseJockey jockey = DatabaseJockey.newInstance();
        List<Database.SaveResult> results = jockey.ins(
            new List<Account> { acme }
        );

        // Then
        Test.stopTest();

        System.assert(
            results.get(0).isSuccess(),
            'Insert failed: ' + results.get(0).getErrors()
        );
    }

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

    /**
     * Confirm that a jockey can edit an account.
     */
    @isTest
    private static void updateAccount() {

        // Given
        Account givenAcme = new Account(
            Name = 'Acme, Inc. (TEST)'
        );

        insert givenAcme;

        // When
        Test.startTest();

        Account newAcme = new Account(
            Id = givenAcme.Id,
            Name = 'Acme Corporation (TEST)'
        );

        DatabaseJockey jockey = DatabaseJockey.newInstance();

        List<Database.SaveResult> results = jockey.upd(
            new List<Account> { newAcme }
        );

        // Then
        Test.stopTest();

        System.assert(
            results.get(0).isSuccess(),
            'Update failed: ' + results.get(0).getErrors()
        );
    }
}