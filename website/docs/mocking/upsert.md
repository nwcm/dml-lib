---
outline: deep
---

# Upsert

Mock upsert operations in unit tests to avoid actual database upserts.

::: warning
The `DML.mock()` and `DML.retrieveResultFor()` methods are `@TestVisible` and should only be used in test classes.
:::

::: tip
- **No database operations**: Mocked upserts don't touch the database
- **IDs are assigned**: New records receive valid mocked IDs
- **Results are captured**: All operation details are available via `DML.retrieveResultFor()`
- **Selective mocking**: Use `upsertsFor()` to mock specific SObject types while allowing others to execute
:::

**Example**

```apex
public class AccountService {
    public void syncAccounts(List<Account> externalAccounts) {
        new DML()
            .toUpsert(externalAccounts)
            .identifier('AccountService.syncAccounts')
            .commitWork();
    }
}
```

```apex
@IsTest
static void shouldSyncAccounts() {
    // Setup
    DML.mock('AccountService.syncAccounts').allUpserts();

    // Test
    Test.startTest();
    new AccountService().syncAccounts(new List<Account>{
        new Account(Name = 'New Account'),
        new Account(Name = 'Another Account')
    });
    Test.stopTest();

    // Verify
    DML.Result result = DML.retrieveResultFor('AccountService.syncAccounts');

    Assert.areEqual(0, [SELECT COUNT() FROM Account], 'No records in database');

    DML.OperationResult accountResult = result.upsertsOf(Account.SObjectType);
    Assert.areEqual(2, accountResult.successes().size(), '2 accounts should be upserted');
}
```

## allUpserts

Mock all upsert operations regardless of SObject type.

**Signature**

```apex
DML.mock(String identifier).allUpserts();
```

**Class**

```apex
public class DataService {
    public void syncData() {
        Account account = new Account(Name = 'Test Account');
        Contact contact = new Contact(LastName = 'Doe');

        new DML()
            .toUpsert(account)
            .toUpsert(contact)
            .identifier('DataService.syncData')
            .commitWork();
    }
}
```

**Test**

```apex
@IsTest
static void shouldMockMultipleSObjectTypes() {
    // Setup
    DML.mock('DataService.syncData').allUpserts();

    // Test
    Test.startTest();
    new DataService().syncData();
    Test.stopTest();

    // Verify
    DML.Result result = DML.retrieveResultFor('DataService.syncData');

    Assert.areEqual(0, [SELECT COUNT() FROM Account], 'No accounts in database');
    Assert.areEqual(0, [SELECT COUNT() FROM Contact], 'No contacts in database');
    Assert.areEqual(2, result.upserts().size(), '2 SObject types mocked');
}
```

## upsertsFor

Mock upsert operations only for a specific SObject type. Other SObject types will be upserted in the database.

**Signature**

```apex
DML.mock(String identifier).upsertsFor(SObjectType objectType);
```

**Class**

```apex
public class DataService {
    public void syncData() {
        Account account = new Account(Name = 'Test Account');
        Contact contact = new Contact(LastName = 'Doe');

        new DML()
            .toUpsert(account)
            .toUpsert(contact)
            .identifier('DataService.syncData')
            .commitWork();
    }
}
```

**Test**

```apex
@IsTest
static void shouldMockOnlyContactUpserts() {
    // Setup - Mock only Contact upserts
    DML.mock('DataService.syncData').upsertsFor(Contact.SObjectType);

    // Test
    Test.startTest();
    new DataService().syncData();
    Test.stopTest();

    // Verify
    DML.Result result = DML.retrieveResultFor('DataService.syncData');

    Assert.areEqual(1, [SELECT COUNT() FROM Account], 'Account actually upserted');
    Assert.areEqual(0, [SELECT COUNT() FROM Contact], 'Contact mocked - not in database');
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
    public void upsertAccount() {
        Account account = new Account(Name = 'Test Account');

        new DML()
            .toUpsert(account)
            .identifier('AccountService.upsertAccount')
            .commitWork();
    }
}
```

**Test**

```apex
@IsTest
static void shouldAccessRecordResults() {
    // Setup
    DML.mock('AccountService.upsertAccount').allUpserts();

    // Test
    Test.startTest();
    new AccountService().upsertAccount();
    Test.stopTest();

    // Verify
    DML.Result result = DML.retrieveResultFor('AccountService.upsertAccount');
    DML.OperationResult opResult = result.upsertsOf(Account.SObjectType);

    Assert.areEqual(Account.SObjectType, opResult.objectType(), 'Should be Account type');
    Assert.areEqual(DML.OperationType.UPSERT_DML, opResult.operationType(), 'Should be UPSERT operation');
    Assert.isFalse(opResult.hasFailures(), 'Should have no failures');
}
```
