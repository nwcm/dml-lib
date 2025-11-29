---
outline: deep
---

# Mocking

The DML library provides built-in support for mocking DML operations in unit tests. This allows you to test your code without actually performing database operations, making tests faster and more isolated.

## Overview

Mocking DML operations involves three steps:

1. **Setup**: Configure which DML operations should be mocked using `DML.whenDmlIdentifier()`
2. **Execute**: Run your code with the `.identifier()` method to associate DML operations with the mock
3. **Verify**: Use `DML.getMockResulfForDml()` to retrieve and assert on the results

```apex title="Basic Mocking Pattern"
// 1. Setup - Configure mocking
DML.whenDmlIdentifier('myDmlId').thenMockAllInserts();

// 2. Execute - Run code with identifier
new DML()
    .toInsert(account)
    .identifier('myDmlId')
    .commitWork();

// 3. Verify - Get results and assert
DML.Result result = DML.getMockResulfForDml('myDmlId');
Assert.areEqual(1, result.inserted().size());
```

## Setting Up Mocks

### whenDmlIdentifier

Configure mocking for a specific DML identifier.

**Signature**

```apex title="Method Signature"
@TestVisible
private static Mockable whenDmlIdentifier(String dmlIdentifier);
```

**Example**

```apex title="Setup Mocking"
DML.whenDmlIdentifier('accountInsert').thenMockAllInserts();
```

## Mock Configuration Methods

The `Mockable` interface provides methods to configure which operations should be mocked.

### Mock All Operations

Mock all DML operations regardless of type.

```apex title="Mock All DML Types"
DML.whenDmlIdentifier('myDml').thenMockAllDmls();
```

### Mock by Operation Type

Mock specific DML operation types.

**Signature**

```apex title="Method Signatures"
Mockable thenMockAllInserts();
Mockable thenMockAllUpdates();
Mockable thenMockAllUpserts();
Mockable thenMockAllDeletes();
Mockable thenMockAllUndelete();
Mockable thenMockAllPublishes();
```

**Example**

```apex title="Mock Specific Operations"
// Mock only inserts
DML.whenDmlIdentifier('insertsOnly').thenMockAllInserts();

// Mock multiple operation types
DML.whenDmlIdentifier('insertsAndUpdates')
    .thenMockAllInserts()
    .thenMockAllUpdates();
```

### Mock by SObject Type

Mock operations for specific SObject types while allowing other types to execute normally.

**Signature**

```apex title="Method Signatures"
Mockable thenMockInsertFor(SObjectType objectType);
Mockable thenMockUpdateFor(SObjectType objectType);
Mockable thenMockUpsertFor(SObjectType objectType);
Mockable thenMockDeleteFor(SObjectType objectType);
Mockable thenMockUndeletFor(SObjectType objectType);
Mockable thenMockPublishFor(SObjectType objectType);
```

**Example**

```apex title="Mock Specific SObject Types"
// Only mock Account inserts, Contact inserts will execute normally
DML.whenDmlIdentifier('accountsOnly').thenMockInsertFor(Account.SObjectType);
```

## Using Identifier

### identifier

Associate a DML operation with a mock identifier.

**Signature**

```apex title="Method Signature"
Commitable identifier(String dmlIdentifier);
```

**Example**

```apex title="Using Identifier"
new DML()
    .toInsert(account)
    .toUpdate(contact)
    .identifier('myTransaction')
    .commitWork();
```

## Retrieving Mock Results

### getMockResulfForDml

Retrieve the result of a mocked DML operation.

**Signature**

```apex title="Method Signature"
@TestVisible
private static Result getMockResulfForDml(String dmlIdentifier);
```

**Example**

```apex title="Get Mock Results"
DML.Result result = DML.getMockResulfForDml('myTransaction');

// Access operation results
List<DML.OperationResult> insertResults = result.inserted();
List<DML.OperationResult> updateResults = result.updated();
```

## Complete Examples

### Mocking Insert Operations

```apex title="Mock Insert Test"
@IsTest
static void testInsertMocking() {
    // Setup
    Account account = new Account(Name = 'Test Account');
    
    DML.whenDmlIdentifier('insertTest').thenMockAllInserts();
    
    // Test
    Test.startTest();
    new DML()
        .toInsert(account)
        .identifier('insertTest')
        .commitWork();
    Test.stopTest();
    
    // Verify
    DML.Result result = DML.getMockResulfForDml('insertTest');
    
    // No actual database insert occurred
    Assert.areEqual(0, [SELECT COUNT() FROM Account], 'No records should be in database');
    
    // But the record has a mocked Id
    Assert.isNotNull(account.Id, 'Account should have mocked Id');
    
    // And we can verify the operation result
    Assert.areEqual(1, result.inserted().size(), 'Should have 1 insert result');
    Assert.areEqual(Account.SObjectType, result.inserted(Account.SObjectType).getObjectType());
    Assert.isTrue(result.inserted(Account.SObjectType).getRecordResults()[0].isSuccess());
}
```

### Mocking Multiple Record Types

```apex title="Mock Multiple Types Test"
@IsTest
static void testMockMultipleTypes() {
    // Setup
    Account account = new Account(Name = 'Test Account');
    Contact contact = new Contact(FirstName = 'Test', LastName = 'Contact');
    
    DML.whenDmlIdentifier('multiType').thenMockAllInserts();
    
    // Test
    Test.startTest();
    new DML()
        .toInsert(account)
        .toInsert(contact)
        .identifier('multiType')
        .commitWork();
    Test.stopTest();
    
    // Verify
    DML.Result result = DML.getMockResulfForDml('multiType');
    
    Assert.areEqual(0, [SELECT COUNT() FROM Account]);
    Assert.areEqual(0, [SELECT COUNT() FROM Contact]);
    Assert.areEqual(2, result.inserted().size());
    Assert.isNotNull(account.Id);
    Assert.isNotNull(contact.Id);
}
```

### Selective Mocking by SObject Type

```apex title="Selective Mocking Test"
@IsTest
static void testSelectiveMocking() {
    // Setup
    Account account = new Account(Name = 'Test Account');
    Contact contact = new Contact(FirstName = 'Test', LastName = 'Contact');
    
    // Only mock Account inserts
    DML.whenDmlIdentifier('selective').thenMockInsertFor(Account.SObjectType);
    
    // Test
    Test.startTest();
    new DML()
        .toInsert(account)
        .toInsert(contact)
        .identifier('selective')
        .commitWork();
    Test.stopTest();
    
    // Verify
    DML.Result result = DML.getMockResulfForDml('selective');
    
    // Account was mocked (not in database)
    Assert.areEqual(0, [SELECT COUNT() FROM Account]);
    Assert.isNotNull(account.Id); // Has mocked Id
    
    // Contact was actually inserted
    Assert.areEqual(1, [SELECT COUNT() FROM Contact]);
    Assert.isNotNull(contact.Id); // Has real Id
}
```

### Mocking Update Operations

```apex title="Mock Update Test"
@IsTest
static void testUpdateMocking() {
    // Setup - Generate a mocked Id for testing
    Account account = new Account(Name = 'Test Account');
    account.Id = DML.randomIdGenerator.get(Account.SObjectType);
    
    DML.whenDmlIdentifier('updateTest').thenMockAllUpdates();
    
    // Test
    Test.startTest();
    account.Name = 'Updated Name';
    
    new DML()
        .toUpdate(account)
        .identifier('updateTest')
        .commitWork();
    Test.stopTest();
    
    // Verify
    DML.Result result = DML.getMockResulfForDml('updateTest');
    
    Assert.areEqual(1, result.updated().size());
    Assert.isTrue(result.updated(Account.SObjectType).getRecordResults()[0].isSuccess());
    Assert.areEqual('Updated Name', account.Name);
}
```

### Mocking Delete Operations

```apex title="Mock Delete Test"
@IsTest
static void testDeleteMocking() {
    // Setup
    Account account = new Account(Name = 'Test Account');
    account.Id = DML.randomIdGenerator.get(Account.SObjectType);
    
    DML.whenDmlIdentifier('deleteTest').thenMockAllDeletes();
    
    // Test
    Test.startTest();
    new DML()
        .toDelete(account)
        .identifier('deleteTest')
        .commitWork();
    Test.stopTest();
    
    // Verify
    DML.Result result = DML.getMockResulfForDml('deleteTest');
    
    Assert.areEqual(1, result.deleted().size());
    Assert.isTrue(result.deleted(Account.SObjectType).getRecordResults()[0].isSuccess());
}
```

### Mocking Platform Events

```apex title="Mock Platform Event Test"
@IsTest
static void testPublishMocking() {
    // Setup
    MyEvent__e event = new MyEvent__e(Message__c = 'Test Message');
    
    DML.whenDmlIdentifier('publishTest').thenMockAllPublishes();
    
    // Test
    Test.startTest();
    new DML()
        .toPublish(event)
        .identifier('publishTest')
        .commitWork();
    Test.stopTest();
    
    // Verify
    DML.Result result = DML.getMockResulfForDml('publishTest');
    
    Assert.areEqual(1, result.published().size());
    Assert.isTrue(result.published(MyEvent__e.SObjectType).getRecordResults()[0].isSuccess());
}
```

## Random ID Generator

The library provides a utility for generating mock IDs.

### DML.randomIdGenerator

Generate mock IDs for testing without database operations.

**Signature**

```apex title="Method Signatures"
Id get(SObjectType objectType);
Id get(String prefix);
```

**Example**

```apex title="Generate Mock IDs"
// Generate a mock Account Id
Id mockAccountId = DML.randomIdGenerator.get(Account.SObjectType);

// Use with a record for update testing
Account account = new Account(Name = 'Test');
account.Id = DML.randomIdGenerator.get(Account.SObjectType);
```

## Best Practices

### Use Descriptive Identifiers

```apex title="Good Practice"
// Good - descriptive and unique
DML.whenDmlIdentifier('AccountService_createAccounts').thenMockAllInserts();

// Avoid - generic names may conflict
DML.whenDmlIdentifier('insert').thenMockAllInserts();
```

### Mock Only What's Necessary

```apex title="Selective Mocking"
// Mock only what you need to isolate
DML.whenDmlIdentifier('myTest')
    .thenMockInsertFor(Account.SObjectType);  // Mock Account inserts
    // Let Contact inserts execute normally for integration testing
```

### Verify Mock Results

```apex title="Verify Results"
DML.Result result = DML.getMockResulfForDml('myTest');

// Verify record counts
Assert.areEqual(expectedCount, result.inserted(Account.SObjectType).requestedCount());

// Verify success status
Assert.isFalse(result.inserted(Account.SObjectType).hasFailures());

// Verify individual record results
for (DML.RecordResult rr : result.inserted(Account.SObjectType).getRecordResults()) {
    Assert.isTrue(rr.isSuccess());
    Assert.isNotNull(rr.getId());
}
```



