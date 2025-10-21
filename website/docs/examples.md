---
outline: deep
---

# Examples

This page provides practical examples of using the DML library in real-world scenarios.

## INSERT

### Single Record

**Traditional DML**

```apex title="Traditional DML"
Account account = new Account(Name = 'Test Account');
insert account;
```

**DML Lib**

```apex title="DML Lib Approach"
Account account = new Account(Name = 'Test Account');

new DML()
    .toInsert(account)
    .commitWork();
```

### Multiple Records

**Traditional DML**

```apex title="Traditional DML"
List<Account> accounts = new List<Account>{
    new Account(Name = 'Test Account 1'),
    new Account(Name = 'Test Account 2')
};
insert accounts;
```

**DML Lib**

```apex title="DML Lib Approach"
List<Account> accounts = new List<Account>{
    new Account(Name = 'Test Account 1'),
    new Account(Name = 'Test Account 2')
};

new DML()
    .toInsert(accounts)
    .commitWork();
```

### With Relationships

**Traditional DML**

```apex title="Traditional DML"
Account account = new Account(Name = 'Test Account');
insert account;

Contact contact = new Contact(
    FirstName = 'Test', 
    LastName = 'Contact',
    AccountId = account.Id
);
insert contact;
```

**DML Lib**

```apex title="DML Lib Approach"
Account account = new Account(Name = 'Test Account');
Contact contact = new Contact(FirstName = 'Test', LastName = 'Contact');

new DML()
    .toInsert(account)
    .toInsert(DML.Record(contact).withRelationship(Contact.AccountId, account))
    .commitWork();
```

### Multiple Related Records

**Traditional DML**

```apex title="Traditional DML"
Account account = new Account(Name = 'Parent Company');
insert account;

List<Contact> contacts = new List<Contact>{
    new Contact(FirstName = 'John', LastName = 'Doe', AccountId = account.Id),
    new Contact(FirstName = 'Jane', LastName = 'Smith', AccountId = account.Id),
    new Contact(FirstName = 'Bob', LastName = 'Johnson', AccountId = account.Id)
};
insert contacts;
```

**DML Lib**

```apex title="DML Lib Approach"
Account account = new Account(Name = 'Parent Company');

List<Contact> contacts = new List<Contact>{
    new Contact(FirstName = 'John', LastName = 'Doe'),
    new Contact(FirstName = 'Jane', LastName = 'Smith'),
    new Contact(FirstName = 'Bob', LastName = 'Johnson')
};

new DML()
    .toInsert(account)
    .toInsert(DML.Records(contacts).withRelationship(Contact.AccountId, account))
    .commitWork();
```

### Complex Multi-Level Relationships

**Traditional DML**

```apex title="Traditional DML"
// Create opportunity
Opportunity opp = new Opportunity(
    Name = 'UoW Test Name',
    StageName = 'Open',
    CloseDate = System.today()
);
insert opp;

// Create product
Product2 product = new Product2(Name = 'Test Product');
insert product;

// Create pricebook entry
PricebookEntry pbe = new PricebookEntry(
    UnitPrice = 10,
    IsActive = true,
    UseStandardPrice = false,
    Pricebook2Id = Test.getStandardPricebookId(),
    Product2Id = product.Id
);
insert pbe;

// Create opportunity line item
OpportunityLineItem oli = new OpportunityLineItem(
    Quantity = 1,
    TotalPrice = 10,
    OpportunityId = opp.Id,
    PricebookEntryId = pbe.Id
);
insert oli;
```

**DML Lib**

```apex title="DML Lib Approach"
DML uow = new DML();

Opportunity opp = new Opportunity(
    Name = 'UoW Test Name',
    StageName = 'Open',
    CloseDate = System.today()
);
uow.toInsert(opp);

Product2 product = new Product2(Name = 'Test Product');
uow.toInsert(product);

PricebookEntry pbe = new PricebookEntry(
    UnitPrice = 10,
    IsActive = true,
    UseStandardPrice = false,
    Pricebook2Id = Test.getStandardPricebookId()
);
uow.toInsert(DML.Record(pbe).withRelationship(PricebookEntry.Product2Id, product));

OpportunityLineItem oli = new OpportunityLineItem(Quantity = 1, TotalPrice = 10);
uow.toInsert(DML.Record(oli)
    .withRelationship(OpportunityLineItem.OpportunityId, opp)
    .withRelationship(OpportunityLineItem.PricebookEntryId, pbe)
);

uow.commitWork();
```

### External ID Relationships

**Traditional DML**

```apex title="Traditional DML"
// Not directly supported - requires manual lookup
Account account = [SELECT Id FROM Account WHERE External_Id__c = 'EXT-12345'];

Contact contact = new Contact(
    FirstName = 'External',
    LastName = 'Contact',
    AccountId = account.Id
);
insert contact;
```

**DML Lib**

```apex title="DML Lib Approach"
Contact contact = new Contact(
    FirstName = 'External',
    LastName = 'Contact'
);

new DML()
    .toInsert(DML.Record(contact).withRelationship(
        Contact.AccountId,
        Account.External_Id__c,
        'EXT-12345'
    ))
    .commitWork();
```

## UPDATE

### Single Record

**Traditional DML**

```apex title="Traditional DML"
Account account = [SELECT Id, Name FROM Account LIMIT 1];
account.Name = 'Updated Test Account';
update account;
```

**DML Lib**

```apex title="DML Lib Approach"
Account account = [SELECT Id, Name FROM Account LIMIT 1];
account.Name = 'Updated Test Account';

new DML()
    .toUpdate(account)
    .commitWork();
```

### Multiple Records

**Traditional DML**

```apex title="Traditional DML"
List<Account> accounts = [SELECT Id, Name FROM Account LIMIT 2];
accounts[0].Name = 'Updated Test Account 1';
accounts[1].Name = 'Updated Test Account 2';
update accounts;
```

**DML Lib**

```apex title="DML Lib Approach"
List<Account> accounts = [SELECT Id, Name FROM Account LIMIT 2];
accounts[0].Name = 'Updated Test Account 1';
accounts[1].Name = 'Updated Test Account 2';

new DML()
    .toUpdate(accounts)
    .commitWork();
```

### With Relationships

**Traditional DML**

```apex title="Traditional DML"
Account account = new Account(Name = 'Test Account');
insert account;

Contact contact = [SELECT Id FROM Contact LIMIT 1];
contact.AccountId = account.Id;
update contact;
```

**DML Lib**

```apex title="DML Lib Approach"
Account account = new Account(Name = 'Test Account');
Contact contact = [SELECT Id FROM Contact LIMIT 1];

new DML()
    .toInsert(account)
    .toUpdate(DML.Record(contact).withRelationship(Contact.AccountId, account))
    .commitWork();
```

## UPSERT

### Mixed Records

**Traditional DML**

```apex title="Traditional DML"
List<Account> accounts = new List<Account>{
    new Account(Name = 'New Account'),           // Will be inserted
    new Account(Id = existingId, Name = 'Updated') // Will be updated
};
upsert accounts;
```

**DML Lib**

```apex title="DML Lib Approach"
List<Account> accounts = new List<Account>{
    new Account(Name = 'New Account'),           // Will be inserted
    new Account(Id = existingId, Name = 'Updated') // Will be updated
};

new DML()
    .toUpsert(accounts)
    .commitWork();
```

## DELETE

### Single Record

**Traditional DML**

```apex title="Traditional DML"
Account account = [SELECT Id FROM Account LIMIT 1];
delete account;
```

**DML Lib**

```apex title="DML Lib Approach"
Account account = [SELECT Id FROM Account LIMIT 1];

new DML()
    .toDelete(account)
    .commitWork();
```

### Multiple Records

**Traditional DML**

```apex title="Traditional DML"
List<Account> accounts = [SELECT Id FROM Account WHERE Name LIKE 'Test%'];
delete accounts;
```

**DML Lib**

```apex title="DML Lib Approach"
List<Account> accounts = [SELECT Id FROM Account WHERE Name LIKE 'Test%'];

new DML()
    .toDelete(accounts)
    .commitWork();
```

## UNDELETE

### Single Record

**Traditional DML**

```apex title="Traditional DML"
Account account = [SELECT Id FROM Account WHERE IsDeleted = true ALL ROWS LIMIT 1];
undelete account;
```

**DML Lib**

```apex title="DML Lib Approach"
Account account = [SELECT Id FROM Account WHERE IsDeleted = true ALL ROWS LIMIT 1];

new DML()
    .toUndelete(account)
    .commitWork();
```

## Security and Access Control

### User vs System Mode

**Traditional DML**

```apex title="Traditional DML"
// User mode - respects user permissions (default)
Case newCase = new Case(Status = 'New', Origin = 'Web');
insert newCase; // May throw SecurityException

// System mode - bypasses user permissions
Case newCase = new Case(Status = 'New', Origin = 'Web');
insert as system newCase; // Salesforce doesn't support this syntax
```

**DML Lib**

```apex title="DML Lib Approach"
// User mode (default)
new DML()
    .toInsert(new Case(Status = 'New', Origin = 'Web'))
    .userMode()
    .commitWork();

// System mode
new DML()
    .toInsert(new Case(Status = 'New', Origin = 'Web'))
    .systemMode()
    .commitWork();
```

### Field Level Security

**Traditional DML**

```apex title="Traditional DML"
// Manual field stripping required
Task task = new Task(Subject = 'Important Task', Type = 'Other');
// Developer must manually check field permissions
insert task;
```

**DML Lib**

```apex title="DML Lib Approach"
Task task = new Task(Subject = 'Important Task', Type = 'Other');

new DML()
    .toInsert(task)
    .systemMode()
    .stripNotCreatableFields()
    .commitWork();
```

## Configuration

### Partial Success Mode

**Traditional DML**

```apex title="Traditional DML"
Database.DmlOptions options = new Database.DmlOptions();
options.optAllOrNone = false;

List<Account> accounts = new List<Account>{
    new Account(Name = 'Valid Account'),
    new Account(), // Missing required Name field
    new Account(Name = 'Another Valid Account')
};

Database.insert(accounts, options);
```

**DML Lib**

```apex title="DML Lib Approach"
List<Account> accounts = new List<Account>{
    new Account(Name = 'Valid Account'),
    new Account(), // Missing required Name field
    new Account(Name = 'Another Valid Account')
};

new DML()
    .toInsert(accounts)
    .allowPartialSuccess()
    .commitWork();
```

### Skip Duplicate Rules

**Traditional DML**

```apex title="Traditional DML"
Database.DmlOptions options = new Database.DmlOptions();
options.duplicateRuleHeader.allowSave = true;

List<Account> accounts = new List<Account>{
    new Account(Name = 'Duplicate Name'),
    new Account(Name = 'Duplicate Name')
};

Database.insert(accounts, options);
```

**DML Lib**

```apex title="DML Lib Approach"
List<Account> accounts = new List<Account>{
    new Account(Name = 'Duplicate Name'),
    new Account(Name = 'Duplicate Name')
};

new DML()
    .toInsert(accounts)
    .skipDuplicateRules()
    .commitWork();
```

## Advanced Features

### Mixed Operations

**Traditional DML**

```apex title="Traditional DML"
// Multiple separate transactions
Account newAccount = new Account(Name = 'New Account');
insert newAccount;

Account existingAccount = [SELECT Id, Name FROM Account LIMIT 1];
existingAccount.Name = 'Updated Name';
update existingAccount;

Account accountToDelete = [SELECT Id FROM Account WHERE Name = 'Delete Me' LIMIT 1];
delete accountToDelete;
```

**DML Lib**

```apex title="DML Lib Approach"
// Single transaction
Account newAccount = new Account(Name = 'New Account');
Account existingAccount = [SELECT Id, Name FROM Account LIMIT 1];
existingAccount.Name = 'Updated Name';
Account accountToDelete = [SELECT Id FROM Account WHERE Name = 'Delete Me' LIMIT 1];

new DML()
    .toInsert(newAccount)
    .toUpdate(existingAccount)
    .toDelete(accountToDelete)
    .commitWork();
```

### Commit Hooks

**Traditional DML**

```apex title="Traditional DML"
// Manual implementation required
System.debug('Starting DML operations at: ' + DateTime.now());

List<Account> accounts = new List<Account>{ /* ... */ };
insert accounts;

System.debug('Completed DML operations at: ' + DateTime.now());
```

**DML Lib**

```apex title="DML Lib Approach"
public class AuditHook implements DML.Hook {
    public void before() {
        System.debug('Starting DML operations at: ' + DateTime.now());
    }
    
    public void after() {
        System.debug('Completed DML operations at: ' + DateTime.now());
    }
}

new DML()
    .toInsert(accounts)
    .commitHook(new AuditHook())
    .commitWork();
```

### Debug Preview

**Traditional DML**

```apex title="Traditional DML"
// No built-in preview functionality
System.debug('About to insert: ' + accounts);
System.debug('About to update: ' + contacts);
System.debug('About to delete: ' + leadIds);

insert accounts;
update contacts;
delete leadIds;
```

**DML Lib**

```apex title="DML Lib Approach"
new DML()
    .toInsert(accounts)
    .toUpdate(contacts)
    .toDelete(leadIds)
    .preview(); // Outputs debug information without executing
```
