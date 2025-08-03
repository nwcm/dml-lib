@isTest
private class UnitOfWorkServiceTest {

    @isTest
    static void commitWork_InsertsSingleRecord_ShouldCreateRecord() {
        // Arrange
        UnitOfWorkService uow = new UnitOfWorkService();
        Account testAccount = new Account(Name = 'Test Account');
        uow.registerNew(testAccount);

        // Act
        Test.startTest();
        uow.commitWork();
        Test.stopTest();

        // Assert
        List<Account> insertedAccounts = [SELECT Id, Name FROM Account WHERE Name = 'Test Account'];
        System.assertEquals(1, insertedAccounts.size(), 'A single account should have been inserted.');
        System.assertEquals('Test Account', insertedAccounts[0].Name, 'The account name should match.');
    }

    @isTest
    static void commitWork_BulkInserts_ShouldCreateAllRecords() {
        // Arrange
        UnitOfWorkService uow = new UnitOfWorkService();
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Bulk Account 1'),
            new Account(Name = 'Bulk Account 2')
        };
        uow.registerNew(accounts);

        // Act
        Test.startTest();
        uow.commitWork();
        Test.stopTest();

        // Assert
        List<Account> inserted = [SELECT Id FROM Account WHERE Name LIKE 'Bulk Account%'];
        System.assertEquals(2, inserted.size(), 'Two accounts should have been inserted.');
    }

    @isTest
    static void commitWork_MixedDmlOperations_ShouldCommitAllChanges() {
        // Arrange
        Account accToUpdate = new Account(Name = 'Update Me');
        insert accToUpdate;
        Account accToDelete = new Account(Name = 'Delete Me');
        insert accToDelete;

        UnitOfWorkService uow = new UnitOfWorkService();
        uow.registerNew(new Account(Name = 'New Account'));
        uow.registerDirty(new Account(Id = accToUpdate.Id, Name = 'Updated Name'));
        uow.registerDelete(accToDelete);

        // Act
        Test.startTest();
        uow.commitWork();
        Test.stopTest();

        // Assert
        System.assertEquals(1, [SELECT COUNT() FROM Account WHERE Name = 'New Account'], 'New account should be inserted.');
        System.assertEquals(1, [SELECT COUNT() FROM Account WHERE Name = 'Updated Name'], 'Account should be updated.');
        System.assertEquals(0, [SELECT COUNT() FROM Account WHERE Id = :accToDelete.Id], 'Account should be deleted.');
    }

    @isTest
    static void commitWork_WithRelationships_ShouldResolveDependencies() {
        // Arrange
        UnitOfWorkService uow = new UnitOfWorkService();
        Account parentAccount = new Account(Name = 'Parent Account');
        Contact childContact = new Contact(LastName = 'Child Contact');

        uow.registerNew(parentAccount);
        uow.registerNew(childContact);
        uow.registerRelationship(childContact, Contact.AccountId, parentAccount);

        // Act
        Test.startTest();
        uow.commitWork();
        Test.stopTest();

        // Assert
        Contact insertedContact = [SELECT AccountId FROM Contact WHERE LastName = 'Child Contact'];
        Account insertedAccount = [SELECT Id FROM Account WHERE Name = 'Parent Account'];
        System.assert(insertedContact.AccountId != null, 'AccountId should be populated.');
        System.assertEquals(insertedAccount.Id, insertedContact.AccountId, 'Contact should be related to the new Account.');
    }
    
    @isTest
    static void commitWork_CircularDependency_ShouldThrowException() {
        // Arrange
        UnitOfWorkService uow = new UnitOfWorkService();
        
        SObject record1 = new Account(Name='Record1');
        SObject record2 = new Account(Name='Record2');
        
        uow.registerNew(record1);
        uow.registerNew(record2);
        
        uow.registerRelationship(record1, Schema.Account.ParentId, record2);
        uow.registerRelationship(record2, Schema.Account.ParentId, record1);

        // Act & Assert
        Test.startTest();
        try {
            uow.commitWork();
            System.assert(false, 'A DmlException should have been thrown due to a circular dependency.');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Could not resolve dependencies'), 'The error message should indicate a dependency issue.');
        }
        Test.stopTest();
    }
    
    @isTest
    static void commitWork_WithSharing_ShouldEnforceSharingRules() {
        // Arrange
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User testUser = new User(
            Alias = 'standt', 
            Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='standarduser' + Math.random() + '@testorg.com'
        );
        insert testUser;

        Account privateAccount = new Account(Name='Private Account');
        insert privateAccount;

        // Act
        System.runAs(testUser) {
            UnitOfWorkService uow = new UnitOfWorkService();
            uow.withSharing();
            uow.registerDirty(new Account(Id=privateAccount.Id, Name='Attempted Update'));

            Test.startTest();
            try {
                uow.commitWork();
                System.assert(false, 'DML should fail due to sharing rules.');
            } catch (Exception e) {
                System.assert(e.getMessage().contains('INSUFFICIENT_ACCESS'), 'Expected an insufficient access error.');
            }
            Test.stopTest();
        }
    }

    @isTest
    static void commitWork_WithoutSharing_ShouldBypassSharingRules() {
        // Arrange
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User testUser = new User(
            Alias = 'standt2', 
            Email='standarduser2@testorg.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing2', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='standarduser2' + Math.random() + '@testorg.com'
        );
        insert testUser;

        Account privateAccount = new Account(Name='Private Account 2');
        insert privateAccount;

        // Act
        System.runAs(testUser) {
            UnitOfWorkService uow = new UnitOfWorkService();
            uow.withoutSharing();
            uow.registerDirty(new Account(Id=privateAccount.Id, Name='Successful Update'));
            
            Test.startTest();
            uow.commitWork();
            Test.stopTest();
        }

        // Assert
        Account updatedAccount = [SELECT Name FROM Account WHERE Id = :privateAccount.Id];
        System.assertEquals('Successful Update', updatedAccount.Name, 'The account should have been updated, bypassing sharing rules.');
    }

    @isTest
    static void commitWork_WithExternalIdRelationship_ShouldResolveRelationship() {
        // Arrange
        String externalId = 'EXT_ID_' + Math.random();
        Account parentAccount = new Account(Name='Parent with External Id', My_External_Id__c = externalId);
        insert parentAccount;
    
        UnitOfWorkService uow = new UnitOfWorkService();
        Contact childContact = new Contact(LastName='Child via External Id');
        uow.registerNew(childContact);
        uow.registerRelationship(childContact, Contact.AccountId, Account.My_External_Id__c, externalId);
    
        // Act
        Test.startTest();
        uow.commitWork();
        Test.stopTest();
    
        // Assert
        Contact insertedContact = [SELECT AccountId FROM Contact WHERE LastName = 'Child via External Id'];
        System.assertNotEquals(null, insertedContact.AccountId, 'AccountId should be populated.');
        System.assertEquals(parentAccount.Id, insertedContact.AccountId, 'Contact should be related to the correct parent account.');
    }
}
