---
outline: deep
---

# Result

The DML library provides comprehensive result handling through the `Result`, `OperationResult`, `RecordResult`, and `Error` interfaces. These allow you to inspect the outcome of DML operations, including success/failure status, record IDs, and error details.

## Overview

When you call `commitWork()`, `dryRun()`, or `hardCommitWork()`, a `Result` object is returned containing detailed information about each DML operation performed.

```apex title="Basic Result Usage"
DML.Result result = new DML()
    .toInsert(account)
    .toUpdate(contact)
    .commitWork();

// Check results by operation type
List<DML.OperationResult> insertResults = result.inserted();
List<DML.OperationResult> updateResults = result.updated();

// Check results by SObject type
DML.OperationResult accountInserts = result.inserted(Account.SObjectType);
```

## Result Interface

The `Result` interface provides methods to access operation results.

### Get All Results

**Signature**

```apex title="Method Signature"
List<OperationResult> all();
```

**Example**

```apex title="Get All Results"
DML.Result result = new DML()
    .toInsert(accounts)
    .toUpdate(contacts)
    .commitWork();

for (DML.OperationResult opResult : result.all()) {
    System.debug('Type: ' + opResult.getType());
    System.debug('Object: ' + opResult.getObjectType());
    System.debug('Succeeded: ' + opResult.succeededCount());
}
```

### Get Results by Operation Type

**Signatures**

```apex title="Method Signatures"
List<OperationResult> inserted();
List<OperationResult> updated();
List<OperationResult> upserted();
List<OperationResult> deleted();
List<OperationResult> undeleted();
List<OperationResult> published();
```

**Example**

```apex title="Results by Operation Type"
DML.Result result = new DML()
    .toInsert(accounts)
    .toInsert(contacts)
    .commitWork();

// Get all insert results (one per SObject type)
List<DML.OperationResult> insertResults = result.inserted();

Assert.areEqual(2, insertResults.size()); // Account and Contact
```

### Get Results by SObject Type

**Signatures**

```apex title="Method Signatures"
OperationResult inserted(Schema.SObjectType objectType);
OperationResult updated(Schema.SObjectType objectType);
OperationResult upserted(Schema.SObjectType objectType);
OperationResult deleted(Schema.SObjectType objectType);
OperationResult undeleted(Schema.SObjectType objectType);
OperationResult published(Schema.SObjectType objectType);
```

**Example**

```apex title="Results by SObject Type"
DML.Result result = new DML()
    .toInsert(accounts)
    .toInsert(contacts)
    .commitWork();

// Get insert results for Accounts only
DML.OperationResult accountResults = result.inserted(Account.SObjectType);
DML.OperationResult contactResults = result.inserted(Contact.SObjectType);
```

## OperationResult Interface

The `OperationResult` interface provides detailed information about a specific DML operation.

### Methods

**Signatures**

```apex title="Method Signatures"
Type getType();                      // DML operation type (INSERT_DML, UPDATE_DML, etc.)
Schema.SObjectType getObjectType();  // SObject type for this operation
Boolean hasFailures();               // True if any records failed
Integer requestedCount();            // Total records submitted
Integer succeededCount();            // Records that succeeded
Integer failedCount();               // Records that failed
List<SObject> records();             // The actual SObject records
List<RecordResult> getRecordResults(); // Individual record results
```

**Example**

```apex title="Using OperationResult"
DML.Result result = new DML()
    .toInsert(accounts)
    .commitWork();

DML.OperationResult opResult = result.inserted(Account.SObjectType);

// Operation metadata
Assert.areEqual(DML.Type.INSERT_DML, opResult.getType());
Assert.areEqual(Account.SObjectType, opResult.getObjectType());

// Success/failure counts
System.debug('Requested: ' + opResult.requestedCount());
System.debug('Succeeded: ' + opResult.succeededCount());
System.debug('Failed: ' + opResult.failedCount());

// Check for failures
if (opResult.hasFailures()) {
    System.debug('Some records failed!');
}

// Access records
List<SObject> processedRecords = opResult.records();
```

## RecordResult Interface

The `RecordResult` interface provides information about individual record processing.

### Methods

**Signatures**

```apex title="Method Signatures"
Id getId();                  // Record ID (assigned after insert)
Boolean isSuccess();         // True if this record succeeded
List<Error> getErrors();     // List of errors for this record
```

**Example**

```apex title="Using RecordResult"
DML.Result result = new DML()
    .toInsert(accounts)
    .allowPartialSuccess()
    .commitWork();

DML.OperationResult opResult = result.inserted(Account.SObjectType);

for (DML.RecordResult recordResult : opResult.getRecordResults()) {
    if (recordResult.isSuccess()) {
        System.debug('Record inserted with Id: ' + recordResult.getId());
    } else {
        System.debug('Record failed:');
        for (DML.Error error : recordResult.getErrors()) {
            System.debug('  - ' + error.getMessage());
        }
    }
}
```

## Error Interface

The `Error` interface provides details about DML errors.

### Methods

**Signatures**

```apex title="Method Signatures"
String getMessage();              // Error message
System.StatusCode getStatusCode(); // Status code (e.g., REQUIRED_FIELD_MISSING)
List<String> getFields();         // Fields that caused the error
```

**Example**

```apex title="Using Error"
DML.Result result = new DML()
    .toInsert(accounts)
    .allowPartialSuccess()
    .commitWork();

for (DML.OperationResult opResult : result.all()) {
    for (DML.RecordResult recordResult : opResult.getRecordResults()) {
        for (DML.Error error : recordResult.getErrors()) {
            System.debug('Error Message: ' + error.getMessage());
            System.debug('Status Code: ' + error.getStatusCode());
            System.debug('Fields: ' + error.getFields());
        }
    }
}
```

## DML Type Enum

The `DML.Type` enum identifies the type of DML operation.

**Values**

```apex title="DML.Type Values"
DML.Type.INSERT_DML
DML.Type.UPDATE_DML
DML.Type.UPSERT_DML
DML.Type.DELETE_DML
DML.Type.UNDELETE_DML
DML.Type.HARD_DELETE_DML
DML.Type.MERGE_DML
DML.Type.PUBLISH_DML
```

## Complete Examples

### Basic Insert with Result

```apex title="Insert with Result"
Account account = new Account(Name = 'Test Account');

DML.Result result = new DML()
    .toInsert(account)
    .commitWork();

// Verify result
Assert.areEqual(1, result.inserted().size());

DML.OperationResult opResult = result.inserted(Account.SObjectType);
Assert.areEqual(1, opResult.requestedCount());
Assert.areEqual(1, opResult.succeededCount());
Assert.areEqual(0, opResult.failedCount());
Assert.isFalse(opResult.hasFailures());
Assert.areEqual(DML.Type.INSERT_DML, opResult.getType());
Assert.areEqual(Account.SObjectType, opResult.getObjectType());

// Check record result
DML.RecordResult recordResult = opResult.getRecordResults()[0];
Assert.isTrue(recordResult.isSuccess());
Assert.isNotNull(recordResult.getId());
Assert.areEqual(account.Id, recordResult.getId());
```

### Partial Success Handling

```apex title="Partial Success"
List<Account> accounts = new List<Account>{
    new Account(Name = 'Valid Account 1'),
    new Account(), // Missing required Name
    new Account(Name = 'Valid Account 2')
};

DML.Result result = new DML()
    .toInsert(accounts)
    .allowPartialSuccess()
    .commitWork();

DML.OperationResult opResult = result.inserted(Account.SObjectType);

// Check counts
Assert.areEqual(3, opResult.requestedCount());
Assert.areEqual(2, opResult.succeededCount());
Assert.areEqual(1, opResult.failedCount());
Assert.isTrue(opResult.hasFailures());

// Process individual results
for (Integer i = 0; i < opResult.getRecordResults().size(); i++) {
    DML.RecordResult rr = opResult.getRecordResults()[i];
    
    if (rr.isSuccess()) {
        System.debug('Record ' + i + ' succeeded with Id: ' + rr.getId());
    } else {
        System.debug('Record ' + i + ' failed:');
        for (DML.Error error : rr.getErrors()) {
            System.debug('  Status: ' + error.getStatusCode());
            System.debug('  Message: ' + error.getMessage());
            System.debug('  Fields: ' + error.getFields());
        }
    }
}
```

### Multiple Operation Types

```apex title="Multiple Operations"
Account account = new Account(Name = 'New Account');
Contact existingContact = [SELECT Id, FirstName FROM Contact LIMIT 1];
existingContact.FirstName = 'Updated';
Lead leadToDelete = [SELECT Id FROM Lead LIMIT 1];

DML.Result result = new DML()
    .toInsert(account)
    .toUpdate(existingContact)
    .toDelete(leadToDelete)
    .commitWork();

// Check each operation type
Assert.areEqual(1, result.inserted().size());
Assert.areEqual(1, result.updated().size());
Assert.areEqual(1, result.deleted().size());

// Verify specific results
Assert.isFalse(result.inserted(Account.SObjectType).hasFailures());
Assert.isFalse(result.updated(Contact.SObjectType).hasFailures());
Assert.isFalse(result.deleted(Lead.SObjectType).hasFailures());
```

### Multiple SObject Types Same Operation

```apex title="Multiple Types Same Operation"
Account account = new Account(Name = 'Test Account');
Contact contact = new Contact(FirstName = 'Test', LastName = 'Contact');
Lead lead = new Lead(FirstName = 'Test', LastName = 'Lead', Company = 'Test Co');

DML.Result result = new DML()
    .toInsert(account)
    .toInsert(contact)
    .toInsert(lead)
    .commitWork();

// Get all insert results (3 - one per SObject type)
List<DML.OperationResult> insertResults = result.inserted();
Assert.areEqual(3, insertResults.size());

// Get specific SObject type results
Assert.areEqual(1, result.inserted(Account.SObjectType).requestedCount());
Assert.areEqual(1, result.inserted(Contact.SObjectType).requestedCount());
Assert.areEqual(1, result.inserted(Lead.SObjectType).requestedCount());
```

### Dry Run Results

```apex title="Dry Run"
Account account = new Account(Name = 'Test Account');

DML.Result result = new DML()
    .toInsert(account)
    .dryRun();

// Result is returned but database is rolled back
Assert.areEqual(1, result.inserted().size());
Assert.isFalse(result.inserted(Account.SObjectType).hasFailures());

// No records in database
Assert.areEqual(0, [SELECT COUNT() FROM Account WHERE Name = 'Test Account']);
```

### Accessing Records from Results

```apex title="Accessing Records"
List<Account> accounts = new List<Account>{
    new Account(Name = 'Account 1'),
    new Account(Name = 'Account 2'),
    new Account(Name = 'Account 3')
};

DML.Result result = new DML()
    .toInsert(accounts)
    .commitWork();

// Get the records that were processed
List<SObject> processedRecords = result.inserted(Account.SObjectType).records();

// They're the same references, so IDs are populated
Assert.areEqual(3, processedRecords.size());
for (SObject record : processedRecords) {
    Assert.isNotNull(record.Id);
}
```

## Best Practices

### Always Check for Failures

```apex title="Check Failures"
DML.Result result = new DML()
    .toInsert(records)
    .allowPartialSuccess()
    .commitWork();

for (DML.OperationResult opResult : result.all()) {
    if (opResult.hasFailures()) {
        // Handle failures appropriately
        logFailures(opResult);
    }
}
```

### Use Results for Verification in Tests

```apex title="Test Verification"
@IsTest
static void testAccountCreation() {
    Account account = new Account(Name = 'Test');
    
    DML.Result result = new DML()
        .toInsert(account)
        .commitWork();
    
    // Use result for comprehensive assertions
    DML.OperationResult opResult = result.inserted(Account.SObjectType);
    
    Assert.areEqual(1, opResult.requestedCount());
    Assert.areEqual(1, opResult.succeededCount());
    Assert.areEqual(0, opResult.failedCount());
    Assert.isFalse(opResult.hasFailures());
    Assert.areEqual(DML.Type.INSERT_DML, opResult.getType());
    Assert.isNotNull(opResult.getRecordResults()[0].getId());
}
```

### Handle Empty Results Gracefully

```apex title="Empty Results"
DML.Result result = new DML()
    .toInsert(accounts)
    .commitWork();

// Returns an empty OperationResult if no operations for that type
DML.OperationResult updateResult = result.updated(Account.SObjectType);
Assert.areEqual(0, updateResult.requestedCount()); // Returns 0, not null
```


