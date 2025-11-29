---
outline: deep
---

# Undelete

Mock undelete operations in unit tests to avoid actual database undeletes.

::: warning
The `DML.mock()` and `DML.retrieveResultFor()` methods are `@TestVisible` and should only be used in test classes.
:::

::: tip
- **No database operations**: Mocked undeletes don't touch the database
- **Results are captured**: All operation details are available via `DML.retrieveResultFor()`
- **Selective mocking**: Use `undeletesFor()` to mock specific SObject types while allowing others to execute
:::

**Example**

```apex
public class AccountService {
    public void restoreDeletedAccounts() {
        List<Account> accounts = [SELECT Id FROM Account WHERE IsDeleted = true ALL ROWS];

        new DML()
            .toUndelete(accounts)
            .identifier('AccountService.restoreDeletedAccounts')
            .commitWork();
    }
}
```

```apex
@IsTest
static void shouldRestoreDeletedAccounts() {
    // Setup
    DML.mock('AccountService.restoreDeletedAccounts').allUndeletes();

    // Test
    Test.startTest();
    new AccountService().restoreDeletedAccounts();
    Test.stopTest();

    // Verify
    DML.Result result = DML.retrieveResultFor('AccountService.restoreDeletedAccounts');

    DML.OperationResult accountResult = result.undeletesOf(Account.SObjectType);
    Assert.isFalse(accountResult.hasFailures(), 'No failures expected');
}
```

## allUndeletes

Mock all undelete operations regardless of SObject type.

**Signature**

```apex
DML.mock(String identifier).allUndeletes();
```

**Class**

```apex
public class DataService {
    public void restoreDeletedRecords() {
        List<Account> accounts = [SELECT Id FROM Account WHERE IsDeleted = true ALL ROWS];
        List<Contact> contacts = [SELECT Id FROM Contact WHERE IsDeleted = true ALL ROWS];

        new DML()
            .toUndelete(accounts)
            .toUndelete(contacts)
            .identifier('DataService.restoreDeletedRecords')
            .commitWork();
    }
}
```

**Test**

```apex
@IsTest
static void shouldMockMultipleSObjectTypes() {
    // Setup
    DML.mock('DataService.restoreDeletedRecords').allUndeletes();

    // Test
    Test.startTest();
    new DataService().restoreDeletedRecords();
    Test.stopTest();

    // Verify
    DML.Result result = DML.retrieveResultFor('DataService.restoreDeletedRecords');

    Assert.areEqual(2, result.undeletes().size(), '2 SObject types mocked');
}
```

## undeletesFor

Mock undelete operations only for a specific SObject type. Other SObject types will be undeleted in the database.

**Signature**

```apex
DML.mock(String identifier).undeletesFor(SObjectType objectType);
```

**Class**

```apex
public class DataService {
    public void restoreDeletedRecords() {
        List<Account> accounts = [SELECT Id FROM Account WHERE IsDeleted = true ALL ROWS];
        List<Contact> contacts = [SELECT Id FROM Contact WHERE IsDeleted = true ALL ROWS];

        new DML()
            .toUndelete(accounts)
            .toUndelete(contacts)
            .identifier('DataService.restoreDeletedRecords')
            .commitWork();
    }
}
```

**Test**

```apex
@IsTest
static void shouldMockOnlyAccountUndeletes() {
    // Setup - Mock only Account undeletes
    DML.mock('DataService.restoreDeletedRecords').undeletesFor(Account.SObjectType);

    // Test
    Test.startTest();
    new DataService().restoreDeletedRecords();
    Test.stopTest();

    // Verify
    DML.Result result = DML.retrieveResultFor('DataService.restoreDeletedRecords');

    Assert.areEqual(2, result.undeletes().size(), '2 SObject types in result');
    // Account was mocked, Contact was actually undeleted
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
    public void restoreAccount(Id accountId) {
        new DML()
            .toUndelete(accountId)
            .identifier('AccountService.restoreAccount')
            .commitWork();
    }
}
```

**Test**

```apex
@IsTest
static void shouldAccessRecordResults() {
    // Setup
    DML.mock('AccountService.restoreAccount').allUndeletes();

    // Test
    Test.startTest();
    new AccountService().restoreAccount(DML.randomIdGenerator.get(Account.SObjectType));
    Test.stopTest();

    // Verify
    DML.Result result = DML.retrieveResultFor('AccountService.restoreAccount');
    DML.OperationResult opResult = result.undeletesOf(Account.SObjectType);

    Assert.areEqual(Account.SObjectType, opResult.objectType(), 'Should be Account type');
    Assert.areEqual(DML.OperationType.UNDELETE_DML, opResult.operationType(), 'Should be UNDELETE operation');
    Assert.isFalse(opResult.hasFailures(), 'Should have no failures');
}
```
