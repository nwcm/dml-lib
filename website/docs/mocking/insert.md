---
outline: deep
---

# Insert

Mock insert operations in unit tests to avoid actual database inserts.

::: warning
The `DML.mock()` and `DML.retrieveResultFor()` methods are `@TestVisible` and should only be used in test classes.
:::

::: tip
- **No database operations**: Mocked inserts don't touch the database
- **IDs are assigned**: Records receive valid mocked IDs that can be used in relationships
- **Results are captured**: All operation details are available via `DML.retrieveResultFor()`
- **Selective mocking**: Use `insertsFor()` to mock specific SObject types while allowing others to execute
:::

**Example**

```apex
public class AccountService {
    public void createAccountWithContacts() {
        Account account = new Account(Name = 'Test Account');
        Contact contact = new Contact(LastName = 'Doe');

        new DML()
            .toInsert(account)
            .toInsert(DML.Record(contact).withRelationship(Contact.AccountId, account))
            .identifier('AccountService.createAccountWithContacts')
            .commitWork();
    }
}
```

```apex
@IsTest
static void shouldCreateAccountWithContacts() {
    // Setup
    DML.mock('AccountService.createAccountWithContacts').allInserts();

    // Test
    Test.startTest();
    new AccountService().createAccountWithContacts();
    Test.stopTest();

    // Verify
    DML.Result result = DML.retrieveResultFor('AccountService.createAccountWithContacts');

    Assert.areEqual(0, [SELECT COUNT() FROM Account], 'No records should be in database');

    DML.OperationResult accountResult = result.insertsOf(Account.SObjectType);
    Assert.areEqual(1, accountResult.successes().size(), '1 account should be inserted');

    DML.OperationResult contactResult = result.insertsOf(Contact.SObjectType);
    Assert.areEqual(1, contactResult.successes().size(), '1 contact should be inserted');
}
```

## allInserts

Mock all insert operations regardless of SObject type.

**Signature**

```apex
DML.mock(String identifier).allInserts();
```

**Class**

```apex
public class DataService {
    public void createRecords() {
        Account account = new Account(Name = 'Test Account');
        Contact contact = new Contact(LastName = 'Doe');

        new DML()
            .toInsert(account)
            .toInsert(contact)
            .identifier('DataService.createRecords')
            .commitWork();
    }
}
```

**Test**

```apex
@IsTest
static void shouldMockMultipleSObjectTypes() {
    // Setup
    DML.mock('DataService.createRecords').allInserts();

    // Test
    Test.startTest();
    new DataService().createRecords();
    Test.stopTest();

    // Verify
    DML.Result result = DML.retrieveResultFor('DataService.createRecords');

    Assert.areEqual(0, [SELECT COUNT() FROM Account], 'No accounts in database');
    Assert.areEqual(0, [SELECT COUNT() FROM Contact], 'No contacts in database');
    Assert.areEqual(2, result.inserts().size(), '2 SObject types mocked');
}
```

## insertsFor

Mock insert operations only for a specific SObject type. Other SObject types will be inserted into the database.

**Signature**

```apex
DML.mock(String identifier).insertsFor(SObjectType objectType);
```

**Class**

```apex
public class DataService {
    public void createRecords() {
        Account account = new Account(Name = 'Test Account');
        Contact contact = new Contact(LastName = 'Doe');

        new DML()
            .toInsert(account)
            .toInsert(contact)
            .identifier('DataService.createRecords')
            .commitWork();
    }
}
```

**Test**

```apex
@IsTest
static void shouldMockOnlyAccountInserts() {
    // Setup - Mock only Account inserts
    DML.mock('DataService.createRecords').insertsFor(Account.SObjectType);

    // Test
    Test.startTest();
    new DataService().createRecords();
    Test.stopTest();

    // Verify
    DML.Result result = DML.retrieveResultFor('DataService.createRecords');

    Assert.areEqual(0, [SELECT COUNT() FROM Account], 'Account mocked - not in database');
    Assert.areEqual(1, [SELECT COUNT() FROM Contact], 'Contact actually inserted');
}
```

## Retrieving Results

Use `DML.retrieveResultFor()` to access the mocked operation results.

**Signature**

```apex
DML.Result result = DML.retrieveResultFor(String identifier);
```

**Class**

```apex
public class AccountService {
    public void createAccount() {
        Account account = new Account(Name = 'Test Account');

        new DML()
            .toInsert(account)
            .identifier('AccountService.createAccount')
            .commitWork();
    }
}
```

**Test**

```apex
@IsTest
static void shouldAccessRecordResults() {
    // Setup
    DML.mock('AccountService.createAccount').allInserts();

    // Test
    Test.startTest();
    new AccountService().createAccount();
    Test.stopTest();

    // Verify
    DML.Result result = DML.retrieveResultFor('AccountService.createAccount');
    DML.OperationResult opResult = result.insertsOf(Account.SObjectType);

    // Check operation metadata
    Assert.areEqual(Account.SObjectType, opResult.objectType(), 'Should be Account type');
    Assert.areEqual(DML.OperationType.INSERT_DML, opResult.operationType(), 'Should be INSERT operation');
    Assert.isFalse(opResult.hasFailures(), 'Should have no failures');

    // Check record results
    List<DML.RecordResult> recordResults = opResult.recordResults();
    Assert.areEqual(1, recordResults.size(), 'Should have 1 record result');
    Assert.isTrue(recordResults[0].isSuccess(), 'Record should be successful');
    Assert.isNotNull(recordResults[0].id(), 'Record should have mocked ID');
}
```
