@IsTest
private class UnitOfWorkTest {

    // INSERT

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

        Assert.isNotNull(account.Id, 'Account should be inserted and have an Id.');
    }

    @IsTest
    static void registerNewMultipleRecords() {
        // Setup
        Account account1 = new Account(Name = 'Test Account 1');
        Account account2 = new Account(Name = 'Test Account 2');

        // Test
        Test.startTest();
            new UnitOfWork()
                .registerNew(account1)
                .registerNew(account2)
                .commitWork();
        Test.stopTest();

        // Verify
        Assert.areEqual(2, [SELECT COUNT() FROM Account WHERE Name IN ('Test Account 1', 'Test Account 2')], 'Accounts should be inserted.');
        
        Assert.isNotNull(account1.Id, 'Account 1 should be inserted and have an Id.');
        Assert.isNotNull(account2.Id, 'Account 2 should be inserted and have an Id.');
    }

    @IsTest
    static void registerNewMultipleRecordsTypes() {
        // Setup
        Account account = new Account(Name = 'Test Account');
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity', CloseDate = Date.today(), StageName = 'Prospecting');
        Lead lead = new Lead(FirstName = 'Test', LastName = 'Lead', Company = 'Test Company');

        // Test
        Test.startTest();
            new UnitOfWork()
                .registerNew(account)
                .registerNew(opportunity)
                .registerNew(lead)
                .commitWork();
        Test.stopTest();

        // Verify
        Assert.areEqual(1, [SELECT COUNT() FROM Account WHERE Name = 'Test Account'], 'Account should be inserted.');
        Assert.areEqual(1, [SELECT COUNT() FROM Opportunity WHERE Name = 'Test Opportunity'], 'Opportunity should be inserted.');
        Assert.areEqual(1, [SELECT COUNT() FROM Lead WHERE FirstName = 'Test' AND LastName = 'Lead' AND Company = 'Test Company'], 'Lead should be inserted.');

        Assert.isNotNull(account.Id, 'Account should be inserted and have an Id.');
        Assert.isNotNull(opportunity.Id, 'Opportunity should be inserted and have an Id.');
        Assert.isNotNull(lead.Id, 'Lead should be inserted and have an Id.');
    }

    @IsTest
    static void registerNewListOfRecords() {
        // Setup
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Test Account 1'),
            new Account(Name = 'Test Account 2'),
            new Account(Name = 'Test Account 3')
        };
        
        // Test
        Test.startTest();
            new UnitOfWork()
                .registerNew(accounts)
                .commitWork();
        Test.stopTest();

        // Verify
        Assert.areEqual(3, [SELECT COUNT() FROM Account WHERE Name IN ('Test Account 1', 'Test Account 2', 'Test Account 3')], 'Accounts should be inserted.');

        Assert.isNotNull(accounts[0].Id, 'Account 1 should be inserted and have an Id.');
        Assert.isNotNull(accounts[1].Id, 'Account 2 should be inserted and have an Id.');
        Assert.isNotNull(accounts[2].Id, 'Account 3 should be inserted and have an Id.');
    }

    @IsTest
    static void registerNewWithExistingIds() {
        // Setup
        Account account = new Account(Name = 'Test Account'); // Mock Id
        insert account;
        
        DmlException expectedException = null;
        
        // Test
        Test.startTest();
            try {
                new UnitOfWork()
                    .registerNew(account)
                    .commitWork();
            } catch (DmlException e) {
                expectedException = e;
            }
        Test.stopTest();

        // Verify
        Assert.isNotNull(expectedException, 'Expected exception to be thrown.');
        Assert.areEqual('Only new records can be registered as new.', expectedException.getMessage(), 'Expected exception message should be thrown.');
    }

    // UPDATE

    @IsTest
    static void registerDirtySingleRecord() {
        // Setup
        Account account = new Account(Name = 'Test Account');
        insert account;

        account.Name = 'Updated Test Account';

        // Test
        Test.startTest();
            new UnitOfWork()
                .registerDirty(account)
                .commitWork();
        Test.stopTest();

        // Verify
        Assert.areEqual(1, [SELECT COUNT() FROM Account], 'Account should be updated.');

        Assert.areEqual('Updated Test Account', account.Name, 'Account should be updated.');
    }

    @IsTest
    static void registerDirtyMultipleRecords() {
        // Setup
        Account account1 = new Account(Name = 'Test Account 1');
        Account account2 = new Account(Name = 'Test Account 2');

        insert new List<Account>{ account1, account2 };

        account1.Name = 'Updated Test Account 1';
        account2.Name = 'Updated Test Account 2';

        // Test
        Test.startTest();
            new UnitOfWork()
                .registerDirty(account1)
                .registerDirty(account2)
                .commitWork();
        Test.stopTest();

        // Verify
        Assert.areEqual(2, [SELECT COUNT() FROM Account], 'Accounts should be updated.');

        Assert.areEqual('Updated Test Account 1', account1.Name, 'Account 1 should be updated.');
        Assert.areEqual('Updated Test Account 2', account2.Name, 'Account 2 should be updated.');
    }

    @IsTest
    static void registerDirtyMultipleRecordsTypes() {
        // Setup
        Account account = new Account(Name = 'Test Account');
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity', CloseDate = Date.today(), StageName = 'Prospecting');
        Lead lead = new Lead(FirstName = 'Test', LastName = 'Lead', Company = 'Test Company');

        insert new List<SObject>{ account, opportunity, lead };

        account.Name = 'Updated Test Account';
        opportunity.Name = 'Updated Test Opportunity';
        lead.FirstName = 'Updated Test';

        // Test
        Test.startTest();
            new UnitOfWork()
                .registerDirty(account)
                .registerDirty(opportunity)
                .registerDirty(lead)
                .commitWork();
        Test.stopTest();   

        // Verify
        Assert.areEqual(1, [SELECT COUNT() FROM Account], 'Account should be updated.');
        Assert.areEqual(1, [SELECT COUNT() FROM Opportunity], 'Opportunity should be updated.');
        Assert.areEqual(1, [SELECT COUNT() FROM Lead], 'Lead should be updated.');

        Assert.areEqual('Updated Test Account', account.Name, 'Account should be updated.');
        Assert.areEqual('Updated Test Opportunity', opportunity.Name, 'Opportunity should be updated.');
        Assert.areEqual('Updated Test', lead.FirstName, 'Lead should be updated.');
    }

    @IsTest
    static void registerDirtyListOfRecords() {
        // Setup
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Test Account 1'),
            new Account(Name = 'Test Account 2'),
            new Account(Name = 'Test Account 3')
        };

        insert accounts;

        accounts[0].Name = 'Updated Test Account 1';
        accounts[1].Name = 'Updated Test Account 2';
        accounts[2].Name = 'Updated Test Account 3';

        // Test
        Test.startTest();
            new UnitOfWork()
                .registerDirty(accounts)
                .commitWork();
        Test.stopTest();

        // Verify
        Assert.areEqual(3, [SELECT COUNT() FROM Account], 'Accounts should be updated.');

        Assert.areEqual('Updated Test Account 1', accounts[0].Name, 'Account 1 should be updated.');
        Assert.areEqual('Updated Test Account 2', accounts[1].Name, 'Account 2 should be updated.');
        Assert.areEqual('Updated Test Account 3', accounts[2].Name, 'Account 3 should be updated.');
    }

    @IsTest
    static void registerDirtyWithoutExistingIds() {
        // Setup
        Account account = new Account(Name = 'Test Account');
        
        DmlException expectedException = null;
        
        // Test
        Test.startTest();
            try {
                new UnitOfWork()
                    .registerDirty(account)
                    .commitWork();
            } catch (DmlException e) {
                expectedException = e;
            }
        Test.stopTest();
        
        // Verify
        Assert.isNotNull(expectedException, 'Expected exception to be thrown.');
        Assert.areEqual('Only existing records can be registered as dirty.', expectedException.getMessage(), 'Expected exception message should be thrown.');
    }

    // UPSERT

    @IsTest
    static void registerUpsertSingleExistingRecord() {
        // Setup
        Account account = new Account(Name = 'Test Account');
        insert account;

        account.Name = 'Updated Test Account';

        // Test
        Test.startTest();
            new UnitOfWork()
                .registerUpsert(account)
                .commitWork();
        Test.stopTest();

        // Verify
        Assert.areEqual(1, [SELECT COUNT() FROM Account], 'Account should be updated.');

        Assert.areEqual('Updated Test Account', account.Name, 'Account should be updated.');
    }

    @IsTest
    static void registerUpsertSingleNewRecord() {
        // Setup
        Account account = new Account(Name = 'Test Account');

        // Test
        Test.startTest();
            new UnitOfWork()
                .registerUpsert(account)
                .commitWork();
        Test.stopTest();

        // Verify
        Assert.areEqual(1, [SELECT COUNT() FROM Account], 'Account should be inserted.');

        Assert.isNotNull(account.Id, 'Account should be inserted and have an Id.');
    }

    @IsTest
    static void registerUpsertMultipleExistingRecords() {
        // Setup
        Account account1 = new Account(Name = 'Test Account 1');
        Account account2 = new Account(Name = 'Test Account 2');

        insert new List<Account>{ account1, account2 };

        account1.Name = 'Updated Test Account 1';
        account2.Name = 'Updated Test Account 2';

        // Test
        Test.startTest();
            new UnitOfWork()
                .registerUpsert(account1)
                .registerUpsert(account2)
                .commitWork();
        Test.stopTest();

        // Verify
        Assert.areEqual(2, [SELECT COUNT() FROM Account], 'Accounts should be updated.');

        Assert.areEqual('Updated Test Account 1', account1.Name, 'Account 1 should be updated.');
        Assert.areEqual('Updated Test Account 2', account2.Name, 'Account 2 should be updated.');
    }

    @IsTest
    static void registerUpsertMultipleNewRecords() {
        // Setup
        Account account1 = new Account(Name = 'Test Account 1');
        Account account2 = new Account(Name = 'Test Account 2');

        // Test
        Test.startTest();
            new UnitOfWork()
                .registerUpsert(account1)
                .registerUpsert(account2)
                .commitWork();
        Test.stopTest();

        // Verify
        Assert.areEqual(2, [SELECT COUNT() FROM Account], 'Accounts should be inserted.');

        Assert.isNotNull(account1.Id, 'Account 1 should be inserted and have an Id.');
        Assert.isNotNull(account2.Id, 'Account 2 should be inserted and have an Id.');
    }

    @IsTest
    static void registerUpsertExistingAndNewRecords() {
        // Setup
        Account account1 = new Account(Name = 'Test Account 1');
        Account account2 = new Account(Name = 'Test Account 2');

        insert account1;

        account1.Name = 'Updated Test Account 1';
        
        // Test
        Test.startTest();
            new UnitOfWork()
                .registerUpsert(account1)
                .registerUpsert(account2)
                .commitWork();
        Test.stopTest();
        
        // Verify
        Assert.areEqual(2, [SELECT COUNT() FROM Account], 'Account 2 should be created.');

        Assert.areEqual('Updated Test Account 1', account1.Name, 'Account 1 should be updated.');
        Assert.isNotNull(account2.Id, 'Account 2 should be inserted and have an Id.');
    }

    @IsTest
    static void registerUpsertListOfRecords() {
        // Setup
        List<Account> existingAccounts = new List<Account>{
            new Account(Name = 'Test Account 1'),
            new Account(Name = 'Test Account 2'),
            new Account(Name = 'Test Account 3')
        };

        insert existingAccounts;

        existingAccounts[0].Name = 'Updated Test Account 1';
        existingAccounts[1].Name = 'Updated Test Account 2';
        existingAccounts[2].Name = 'Updated Test Account 3';

        List<Account> newAccounts = new List<Account>{
            new Account(Name = 'New Test Account 1'),
            new Account(Name = 'New Test Account 2'),
            new Account(Name = 'New Test Account 3')
        };

        // Test
        Test.startTest();
            new UnitOfWork()
                .registerUpsert(existingAccounts)
                .registerUpsert(newAccounts)
                .commitWork();
        Test.stopTest();
        
        // Verify
        Assert.areEqual(6, [SELECT COUNT() FROM Account], 'Accounts should be updated and inserted.');

        Assert.areEqual('Updated Test Account 1', existingAccounts[0].Name, 'Account 1 should be updated.');
        Assert.areEqual('Updated Test Account 2', existingAccounts[1].Name, 'Account 2 should be updated.');
        Assert.areEqual('Updated Test Account 3', existingAccounts[2].Name, 'Account 3 should be updated.');

        Assert.isNotNull(newAccounts[0].Id, 'New Account 1 should be inserted and have an Id.');
        Assert.isNotNull(newAccounts[1].Id, 'New Account 2 should be inserted and have an Id.');
        Assert.isNotNull(newAccounts[2].Id, 'New Account 3 should be inserted and have an Id.');
    }

    // DELETE

    @IsTest
    static void registerDeleteSingleRecord() {
        // Setup
        Account account = new Account(Name = 'Test Account');
        insert account;
        
        // Test
        Test.startTest();
            new UnitOfWork()
                .registerDelete(account)
                .commitWork();
        Test.stopTest();
        
        // Verify
        Assert.areEqual(0, [SELECT COUNT() FROM Account], 'Account should be deleted.');
    }

    @IsTest
    static void registerDeleteMultipleRecords() {
        // Setup
        Account account1 = new Account(Name = 'Test Account 1');
        Account account2 = new Account(Name = 'Test Account 2');

        insert new List<Account>{ account1, account2 };
        
        // Test
        Test.startTest();
            new UnitOfWork()
                .registerDelete(account1)
                .registerDelete(account2)
                .commitWork();
        Test.stopTest();

        // Verify
        Assert.areEqual(0, [SELECT COUNT() FROM Account], 'Accounts should be deleted.');
    }

    @IsTest
    static void registerDeleteListOfRecords() {
        // Setup
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Test Account 1'),
            new Account(Name = 'Test Account 2'),
            new Account(Name = 'Test Account 3')
        };

        insert accounts;

        // Test
        Test.startTest();
            new UnitOfWork()
                .registerDelete(accounts)
                .commitWork();
        Test.stopTest();

        // Verify
        Assert.areEqual(0, [SELECT COUNT() FROM Account], 'Accounts should be deleted.');
    }

    @IsTest
    static void registerDeleteWithoutExistingIds() {
        // Setup
        Account account = new Account(Name = 'Test Account');
        
        DmlException expectedException = null;
        
        // Test
        Test.startTest();
            try {
                new UnitOfWork()
                    .registerDelete(account)
                    .commitWork();
            } catch (DmlException e) {
                expectedException = e;
            }
        Test.stopTest();
        
        // Verify
        Assert.isNotNull(expectedException, 'Expected exception to be thrown.');
        Assert.areEqual('Only existing records can be registered as deleted.', expectedException.getMessage(), 'Expected exception message should be thrown.');
    }

    // PLATFORM EVENT

    // RELATIONSHIP

    @IsTest
    static void registerRelationshipSingleRecord() {
        // Setup
        Account newAccount = new Account(Name = 'Test Account');
        Contact newContact = new Contact(FirstName = 'Test', LastName = 'Contact');

        // Test
        Test.startTest();
            new UnitOfWork()
                .registerNew(newAccount)
                .registerNew(newContact, Contact.AccountId, newAccount)
                .commitWork();
        Test.stopTest();

        // Verify
        Assert.areEqual(1, [SELECT COUNT() FROM Contact], 'Contact should be related to Account.');
        Assert.areEqual(1, [SELECT COUNT() FROM Account], 'Account should be related to Contact.');

        Assert.areEqual(newAccount.Id, newContact.AccountId, 'Contact should be related to Account.');
    }       

    // @IsTest
    // static void registerComplex() {
    //     // Setup
    //     UnitOfWork uow = new UnitOfWork();

    //     Opportunity newOpportunity = new Opportunity(
    //         Name = 'UoW Test Name',
    //         StageName = 'Open',
    //         CloseDate = System.today()
    //     );

    //     // Test
    //     Test.startTest();
    //     for(Integer i = 0 ; i < 10 ; i++) {
    //         uow.registerNew( 
    //             new Opportunity(
    //                 Name = 'UoW Test Name ' + i,
    //                 StageName = 'Open',
    //                 CloseDate = System.today()
    //             )
    //         );

    //         for(Integer j = 0 ; j < i + 1 ; j++) {
    //             uow.registerNew(
    //                 new Product2(
    //                     Name = newOpportunity.Name + ' : Product : ' + i
    //                 )
    //             );

    //             uow.registerNew(
    //                 new PricebookEntry(
    //                     UnitPrice = 10,
    //                     IsActive = true,
    //                     UseStandardPrice = false,
    //                     Pricebook2Id = Test.getStandardPricebookId()
    //                 ),
    //                 PricebookEntry.Product2Id,
    //                 product
    //             );

    //             OpportunityLineItem oppLineItem = new OpportunityLineItem(
    //                 Quantity = 1,
    //                 TotalPrice = 10
    //             );

    //             uow.registerRelationship(
    //                 oppLineItem,
    //                 OpportunityLineItem.PricebookEntryId,
    //                 pbe
    //             );

    //             uow.registerNew(
    //                 oppLineItem,
    //                 OpportunityLineItem.OpportunityId,
    //                 newOpportunity
    //             );
    //         }
    //     }
    //     uow.commitWork();
    //     Test.stopTest();

    //     // Verify
    //     Assert.areEqual(10, [SELECT COUNT() FROM Opportunity], 'Opportunities should be inserted.');
    //     Assert.areEqual(55, [SELECT COUNT() FROM Product2], 'Products should be inserted.');
    //     Assert.areEqual(55, [SELECT COUNT() FROM PricebookEntry], 'Pricebook entries should be inserted.');
    // }
    
}

// OpportunityUow.regiserNew()

        // Setup
        UnitOfWork uow = new UnitOfWork();

        for(Integer i = 0 ; i < 10 ; i++) {
            Opportunity newOpportunity = new Opportunity(
                Name = 'UoW Test Name ' + i,
                StageName = 'Open',
                CloseDate = System.today()
            );

            uow.registerNew(newOpportunity);

            for(Integer j = 0 ; j < i + 1 ; j++) {
                Product2 newProduct = new Product2(
                    Name = newOpportunity.Name + ' : Product : ' + i
                );

                uow.registerNew(newProduct);

                PricebookEntry newPricebookEntry = new PricebookEntry(
                    UnitPrice = 10,
                    IsActive = true,
                    UseStandardPrice = false
                );  

                uow.registerNew(newPricebookEntry)
                    .withRelationship(PricebookEntry.Product2Id, newProduct);

                OpportunityLineItem newOpportunityLineItem = new OpportunityLineItem(
                    Quantity = 1,
                    TotalPrice = 10
                );

                uow.registerNew(newOpportunityLineItem)
                    .withRelationship(OpportunityLineItem.OpportunityId, newOpportunity)
                    .withRelationship(OpportunityLineItem.PricebookEntryId, newPricebookEntry);
            }
        }

        uow.preview();


DML dml = new DML();

Opportunity newOpportunity = new Opportunity(
                Name = 'UoW Test Name ' + i,
                StageName = 'Open',
                CloseDate = System.today()
            );
dml.