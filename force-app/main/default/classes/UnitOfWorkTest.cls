@IsTest
private class UnitOfWorkTest {
    @IsTest
    static void registerNewSingleRecord() {
        // Setup
        Account account = new Account(Name = 'Test Account');

        // Test
        Test.startTest();
            new UnitOfWork()
                .registerNew(account)
                .commitWork();
        Test.stopTest();

        // Verify
        Assert.areEqual(1, [SELECT COUNT() FROM Account WHERE Name = 'Test Account'], 'Account should be inserted.');
    }
}
