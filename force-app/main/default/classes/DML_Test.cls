/**
 * Copyright (c) 2025 Beyond The Cloud Sp. z o.o. (BeyondTheCloud.Dev)
 * Licensed under the MIT License (https://github.com/beyond-the-cloud-dev/dml-lib/blob/main/LICENSE)
 *
 * v1.5.0
 *
 * PMD False Positives:
 * - CyclomaticComplexity: It is a library and we tried to put everything into ONE class
 * - CognitiveComplexity: It is a library and we tried to put everything into ONE class
**/
@SuppressWarnings('PMD.CyclomaticComplexity,PMD.CognitiveComplexity')
@IsTest
private class DML_Test {

	// INSERT

	@IsTest
	static void toInsertSingleRecord() {
		// Setup
		Account account1 = getAccount(1);

		// Test
		Test.startTest();
			DML.Result result = new DML()
				.toInsert(account1)
				.commitWork();
		Test.stopTest();

		// Verify
		Assert.areEqual(1, [SELECT COUNT() FROM Account], 'Single record should be inserted.');

		Assert.isNotNull(account1.Id, 'Account should be inserted and have an Id.');
	
		Assert.areEqual(1, result.inserted().size(), 'Inserted operation result should contain 1 result.');
		Assert.areEqual(0, result.upserted().size(), 'Upserted operation result should contain 0 results.');
		Assert.areEqual(0, result.updated().size(), 'Updated operation result should contain 0 results.');
		Assert.areEqual(0, result.deleted().size(), 'Deleted operation result should contain 0 results.');
		Assert.areEqual(0, result.undeleted().size(), 'Undeleted operation result should contain 0 results.');
		Assert.areEqual(0, result.published().size(), 'Published operation result should contain 0 results.');

		Assert.areEqual(1, result.inserted(Account.SObjectType).requestedCount(), 'Inserted operation result should contain 1 record.');
		Assert.areEqual(0, result.upserted(Account.SObjectType).requestedCount(), 'Upserted operation result should contain 0 records.');
		Assert.areEqual(0, result.updated(Account.SObjectType).requestedCount(), 'Updated operation result should contain 0 records.');
		Assert.areEqual(0, result.deleted(Account.SObjectType).requestedCount(), 'Deleted operation result should contain 0 records.');
		Assert.areEqual(0, result.undeleted(Account.SObjectType).requestedCount(), 'Undeleted operation result should contain 0 records.');
		Assert.areEqual(0, result.published(Account.SObjectType).requestedCount(), 'Published operation result should contain 0 records.');

		DML.OperationResult operationResult = result.inserted(Account.SObjectType);

		Assert.areEqual(1, operationResult.succeededCount(), 'Inserted operation result should contain 1 succeeded record.');
		Assert.areEqual(0, operationResult.failedCount(), 'Inserted operation result should contain 0 failed record.');
		Assert.areEqual(1, operationResult.requestedCount(), 'Inserted operation result should contain 1 record.');
		Assert.areEqual(1, operationResult.records().size(), 'Inserted operation result should contain the inserted record.');
		Assert.areEqual(1, operationResult.getRecordResults().size(), 'Inserted operation result should contain the inserted record result.');
		Assert.areEqual(Account.SObjectType, operationResult.getObjectType(), 'Inserted operation result should contain Account object type.');
		Assert.areEqual(DML.Type.INSERT_DML, operationResult.getType(), 'Inserted operation result should contain insert type.');
		Assert.isFalse(operationResult.hasFailures(), 'Inserted operation result should not have failures.');
	}

	@IsTest
	static void toInsertWithRelationshipSingleRecord() {
		// Setup
		Account newAccount = getAccount(1);
		Contact newContact = getContact(1);

		// Test
		Test.startTest();
			new DML()
				.toInsert(newAccount)
				.toInsert(DML.Record(newContact).withRelationship(Contact.AccountId, newAccount))
				.commitWork();
		Test.stopTest();

		// Verify
		Assert.areEqual(1, [SELECT COUNT() FROM Account], 'Account should be inserted.');
		Assert.areEqual(1, [SELECT COUNT() FROM Contact], 'Contact should be inserted.');

		Assert.areEqual(newAccount.Id, newContact.AccountId, 'Contact should be related to Account.');
	}       

	@IsTest
	static void toInsertWithInvalidRelationshipSingleRecord() {
		// Setup
		Account newAccount = getAccount(1);
		Contact newContact = getContact(1);

		// Test
		Test.startTest();
			Exception expectedException = null;

			try {
			new DML()
					.toInsert(newAccount)
					.toInsert(DML.Record(newContact).withRelationship(Contact.LastName, newAccount))
					.commitWork();
			} catch (Exception e) {
				expectedException = e;
			}
		Test.stopTest();

		// Verify
		Assert.isNotNull(expectedException, 'Expected exception to be thrown.');
		Assert.areEqual('Invalid argument: relationshipField. Field supplied is not a relationship field.', expectedException.getMessage(), 'Expected exception message should be thrown.');
	}

	@IsTest
	static void toInsertWithInvalidTargetRelationshipFieldSingleRecord() {
		// Setup
		Account newAccount = getAccount(1);
		Contact newContact = getContact(1);

		// Test
		Test.startTest();
		Exception expectedException = null;

		try {
			new DML()
				.toInsert(newAccount)
				.toInsert(DML.Record(newContact).withRelationship(Contact.LastName, Account.Name, 'Test'))
				.commitWork();
		} catch (Exception e) {
			expectedException = e;
		}
		Test.stopTest();

		// Verify
		Assert.isNotNull(expectedException, 'Expected exception to be thrown.');
		Assert.areEqual('Invalid argument: relationshipField. Field supplied is not a relationship field.', expectedException.getMessage(), 'Expected exception message should be thrown.');
	}

	@IsTest
	static void toInsertWithInvalidExternalRelationshipSingleRecord() {
		// Setup
		Account newAccount = getAccount(1);
		Contact newContact = getContact(1);

		// Test
		Test.startTest();
		Exception expectedException = null;

		try {
			new DML()
				.toInsert(newAccount)
				.toInsert(DML.Record(newContact).withRelationship(Contact.AccountId, Account.Name, 'Test'))
				.commitWork();
		} catch (Exception e) {
			expectedException = e;
		}
		Test.stopTest();

		// Verify
		Assert.isNotNull(expectedException, 'Expected exception to be thrown.');
		Assert.areEqual('Invalid argument: externalIdField. Field supplied is not a marked as an External Identifier.', expectedException.getMessage(), 'Expected exception message should be thrown.');
	}

	@IsTest
	static void toInsertMultipleRecords() {
		// Setup
		Account account1 = getAccount(1);
		Account account2 = getAccount(2);

		// Test
		Test.startTest();
			DML.Result result = new DML()
				.toInsert(account1)
				.toInsert(account2)
				.commitWork();
		Test.stopTest();

		// Verify
		Assert.areEqual(2, [SELECT COUNT() FROM Account], 'Accounts should be inserted.');
		
		Assert.isNotNull(account1.Id, 'Account 1 should be inserted and have an Id.');
		Assert.isNotNull(account2.Id, 'Account 2 should be inserted and have an Id.');

		Assert.areEqual(1, result.inserted().size(), 'Inserted operation result should contain 2 results.');
		Assert.areEqual(0, result.upserted().size(), 'Upserted operation result should contain 0 results.');
		Assert.areEqual(0, result.updated().size(), 'Updated operation result should contain 0 results.');
		Assert.areEqual(0, result.deleted().size(), 'Deleted operation result should contain 0 results.');
		Assert.areEqual(0, result.undeleted().size(), 'Undeleted operation result should contain 0 results.');
		Assert.areEqual(0, result.published().size(), 'Published operation result should contain 0 results.');

		Assert.areEqual(2, result.inserted(Account.SObjectType).requestedCount(), 'Inserted operation result should contain 2 Account records.');

		DML.OperationResult operationResult = result.inserted(Account.SObjectType);

		Assert.areEqual(2, operationResult.succeededCount(), 'Inserted operation result should contain 2 succeeded records.');
		Assert.areEqual(0, operationResult.failedCount(), 'Inserted operation result should contain 0 failed record.');
		Assert.areEqual(2, operationResult.requestedCount(), 'Inserted operation result should contain 2 records.');
		Assert.areEqual(2, operationResult.records().size(), 'Inserted operation result should contain the inserted records.');
		Assert.areEqual(2, operationResult.getRecordResults().size(), 'Inserted operation result should contain the inserted record results.');
		Assert.areEqual(Account.SObjectType, operationResult.getObjectType(), 'Inserted operation result should contain Account object type.');
		Assert.areEqual(DML.Type.INSERT_DML, operationResult.getType(), 'Inserted operation result should contain insert type.');
		Assert.isFalse(operationResult.hasFailures(), 'Inserted operation result should not have failures.');
	}

	@IsTest
	static void toInsertWithRelationshipMultipleRecords() {
		// Setup
		Account newAccount = getAccount(1);
		Contact newContact1 = getContact(1);
		Contact newContact2 = getContact(2);

		List<Contact> contacts = new List<Contact>{ newContact1, newContact2 };

		// Test
		Test.startTest();
			new DML()
				.toInsert(newAccount)
				.toInsert(DML.Records(contacts).withRelationship(Contact.AccountId, newAccount))
				.commitWork();
		Test.stopTest();

		// Verify
		Assert.areEqual(1, [SELECT COUNT() FROM Account], 'Account should be inserted.');
		Assert.areEqual(2, [SELECT COUNT() FROM Contact], 'Contacts should be inserted.');

		Assert.areEqual(newAccount.Id, newContact1.AccountId, 'Contact should be related to Account.');
		Assert.areEqual(newAccount.Id, newContact2.AccountId, 'Contact 2 should be related to Account.');
	}

	@IsTest
	static void toInsertWithInvalidTargetRelationshipFieldMultipleRecords() {
		// Setup
		Account newAccount = getAccount(1);
		Contact newContact1 = getContact(1);
		Contact newContact2 = getContact(2);

		List<Contact> contacts = new List<Contact>{ newContact1, newContact2 };

		// Test
		Test.startTest();
			Exception expectedException = null;

			try {
			new DML()
					.toInsert(newAccount)
					.toInsert(DML.Records(contacts).withRelationship(Contact.LastName, newAccount))
				.commitWork();
			} catch (Exception e) {
				expectedException = e;
			}
		Test.stopTest();

		// Verify
		Assert.isNotNull(expectedException, 'Expected exception to be thrown.');
		Assert.areEqual('Invalid argument: relationshipField. Field supplied is not a relationship field.', expectedException.getMessage(), 'Expected exception message should be thrown.');
	}

	@IsTest
	static void toInsertWithInvalidExternalRelationshipMultipleRecords() {
		// Setup
		Account newAccount = getAccount(1);
		Contact newContact1 = getContact(1);
		Contact newContact2 = getContact(2);

		List<Contact> contacts = new List<Contact>{ newContact1, newContact2 };

		// Test
		Test.startTest();
		Exception expectedException = null;

		try {
			new DML()
				.toInsert(newAccount)
				.toInsert(DML.Records(contacts).withRelationship(Contact.LastName, Account.Name, 'Test'))
				.commitWork();
		} catch (Exception e) {
			expectedException = e;
		}
		Test.stopTest();

		// Verify
		Assert.isNotNull(expectedException, 'Expected exception to be thrown.');
		Assert.areEqual('Invalid argument: relationshipField. Field supplied is not a relationship field.', expectedException.getMessage(), 'Expected exception message should be thrown.');
	}

	@IsTest
	static void toInsertWithInvalidExternalIdFieldMultipleRecords() {
		// Setup
		Account newAccount = getAccount(1);
		Contact newContact1 = getContact(1);
		Contact newContact2 = getContact(2);

		List<Contact> contacts = new List<Contact>{ newContact1, newContact2 };

		// Test
		Test.startTest();
		Exception expectedException = null;

		try {
			new DML()
				.toInsert(newAccount)
				.toInsert(DML.Records(contacts).withRelationship(Contact.AccountId, Account.Name, 'Test'))
				.commitWork();
		} catch (Exception e) {
			expectedException = e;
		}
		Test.stopTest();

		// Verify
		Assert.isNotNull(expectedException, 'Expected exception to be thrown.');
		Assert.areEqual('Invalid argument: externalIdField. Field supplied is not a marked as an External Identifier.', expectedException.getMessage(), 'Expected exception message should be thrown.');
	}

	@IsTest
	static void toInsertMultipleRecordsTypes() {
		// Setup
		Account account1 = getAccount(1);
		Opportunity opportunityToInsert = getOpportunity(1);
		Lead leadToInsert = getLead(1);

		// Test
		Test.startTest();
			DML.Result result = new DML()
				.toInsert(account1)
				.toInsert(opportunityToInsert)
				.toInsert(leadToInsert)
				.commitWork();
		Test.stopTest();

		// Verify
		Assert.areEqual(1, [SELECT COUNT() FROM Account], 'Account should be inserted.');
		Assert.areEqual(1, [SELECT COUNT() FROM Opportunity], 'Opportunity should be inserted.');
		Assert.areEqual(1, [SELECT COUNT() FROM Lead], 'Lead should be inserted.');

		Assert.isNotNull(account1.Id, 'Account should be inserted and have an Id.');
		Assert.isNotNull(opportunityToInsert.Id, 'Opportunity should be inserted and have an Id.');
		Assert.isNotNull(leadToInsert.Id, 'Lead should be inserted and have an Id.');

		Assert.areEqual(3, result.inserted().size(), 'Inserted operation result should contain 3 results.');
		Assert.areEqual(0, result.upserted().size(), 'Upserted operation result should contain 0 results.');
		Assert.areEqual(0, result.updated().size(), 'Updated operation result should contain 0 results.');
		Assert.areEqual(0, result.deleted().size(), 'Deleted operation result should contain 0 results.');
		Assert.areEqual(0, result.undeleted().size(), 'Undeleted operation result should contain 0 results.');
		Assert.areEqual(0, result.published().size(), 'Published operation result should contain 0 results.');

		Assert.areEqual(1, result.inserted(Account.SObjectType).requestedCount(), 'Inserted operation result should contain 1 Account record.');
		Assert.areEqual(1, result.inserted(Opportunity.SObjectType).requestedCount(), 'Inserted operation result should contain 1 Opportunity record.');
		Assert.areEqual(1, result.inserted(Lead.SObjectType).requestedCount(), 'Inserted operation result should contain 1 Lead record.');

		DML.OperationResult accountOperationResult = result.inserted(Account.SObjectType);

		Assert.areEqual(1, accountOperationResult.succeededCount(), 'Inserted operation result should contain 1 succeeded record.');
		Assert.areEqual(0, accountOperationResult.failedCount(), 'Inserted operation result should contain 0 failed record.');
		Assert.areEqual(1, accountOperationResult.requestedCount(), 'Inserted operation result should contain 1 record.');
		Assert.areEqual(1, accountOperationResult.records().size(), 'Inserted operation result should contain the inserted record.');
		Assert.areEqual(1, accountOperationResult.getRecordResults().size(), 'Inserted operation result should contain the inserted record results.');
		Assert.areEqual(Account.SObjectType, accountOperationResult.getObjectType(), 'Inserted operation result should contain Account object type.');
		Assert.areEqual(DML.Type.INSERT_DML, accountOperationResult.getType(), 'Inserted operation result should contain insert type.');
		Assert.isFalse(accountOperationResult.hasFailures(), 'Inserted operation result should not have failures.');

		DML.OperationResult opportunityOperationResult = result.inserted(Opportunity.SObjectType);

		Assert.areEqual(1, opportunityOperationResult.succeededCount(), 'Inserted operation result should contain 1 succeeded record.');
		Assert.areEqual(0, opportunityOperationResult.failedCount(), 'Inserted operation result should contain 0 failed record.');
		Assert.areEqual(1, opportunityOperationResult.requestedCount(), 'Inserted operation result should contain 1 record.');
		Assert.areEqual(1, opportunityOperationResult.records().size(), 'Inserted operation result should contain the inserted record.');
		Assert.areEqual(1, opportunityOperationResult.getRecordResults().size(), 'Inserted operation result should contain the inserted record results.');
		Assert.areEqual(Opportunity.SObjectType, opportunityOperationResult.getObjectType(), 'Inserted operation result should contain Opportunity object type.');
		Assert.areEqual(DML.Type.INSERT_DML, opportunityOperationResult.getType(), 'Inserted operation result should contain insert type.');
		Assert.isFalse(opportunityOperationResult.hasFailures(), 'Inserted operation result should not have failures.');

		DML.OperationResult leadOperationResult = result.inserted(Lead.SObjectType);

		Assert.areEqual(1, leadOperationResult.succeededCount(), 'Inserted operation result should contain 1 succeeded record.');
		Assert.areEqual(0, leadOperationResult.failedCount(), 'Inserted operation result should contain 0 failed record.');
		Assert.areEqual(1, leadOperationResult.requestedCount(), 'Inserted operation result should contain 1 record.');
		Assert.areEqual(1, leadOperationResult.records().size(), 'Inserted operation result should contain the inserted record.');
		Assert.areEqual(1, leadOperationResult.getRecordResults().size(), 'Inserted operation result should contain the inserted record results.');
		Assert.areEqual(Lead.SObjectType, leadOperationResult.getObjectType(), 'Inserted operation result should contain Lead object type.');
		Assert.areEqual(DML.Type.INSERT_DML, leadOperationResult.getType(), 'Inserted operation result should contain insert type.');
		Assert.isFalse(leadOperationResult.hasFailures(), 'Inserted operation result should not have failures.');
	}

	@IsTest
	static void toInsertListOfRecords() {
		// Setup
		List<Account> accounts = new List<Account>{
			getAccount(1),
			getAccount(2),
			getAccount(3)
		};
		
		// Test
		Test.startTest();
			new DML()
				.toInsert(accounts)
				.commitWork();
		Test.stopTest();

		// Verify
		Assert.areEqual(3, [SELECT COUNT() FROM Account], 'Accounts should be inserted.');

		Assert.isNotNull(accounts[0].Id, 'Account 1 should be inserted and have an Id.');
		Assert.isNotNull(accounts[1].Id, 'Account 2 should be inserted and have an Id.');
		Assert.isNotNull(accounts[2].Id, 'Account 3 should be inserted and have an Id.');
	}

	@IsTest
	static void toInsertWithExistingIds() {
		// Setup
		Account account = getAccount(1);
		insert account;
		
		DmlException expectedException = null;
		
		// Test
		Test.startTest();
			try {
				new DML()
					.toInsert(account)
					.commitWork();
			} catch (DmlException e) {
				expectedException = e;
			}
		Test.stopTest();

		// Verify
		Assert.isNotNull(expectedException, 'Expected exception to be thrown.');
		Assert.areEqual('Only new records can be registered as new.', expectedException.getMessage(), 'Expected exception message should be thrown.');
	}

	@IsTest
	static void toInsertWithPartialSuccess() {
		// Setup
		List<Account> accounts = new List<Account>{
			getAccount(1),
			new Account() // Name is required
		};

		// Test
		Test.startTest();
			new DML()
				.toInsert(accounts)
				.allowPartialSuccess()
				.commitWork();
		Test.stopTest();

		// Verify
		Assert.areEqual(1, [SELECT COUNT() FROM Account], 'Only one account should be inserted, because one has missing required field.');
	}

	@IsTest
	static void toInsertUserMode() {
		// Setup
		Case newCase = getCase(1);

		Exception expectedException = null;

		// Test
		Test.startTest();
		System.runAs(minimumAccessUser()) {
			try {
				new DML()
					.toInsert(newCase)
					.commitWork(); // user mode by default
			} catch (Exception e) {
				expectedException = e;
			}
		}
		Test.stopTest();

		// Verify
		Assert.isNotNull(expectedException, 'Expected exception to be thrown.');
		Assert.areEqual('Access to entity \'Case\' denied', expectedException.getMessage(), 'Expected exception message should be thrown.');
	}

	@IsTest
	static void toInsertWithUserModeExplicitlySet() {
		// Setup
		Case newCase = getCase(1);

		Exception expectedException = null;

		// Test
		Test.startTest();
			System.runAs(minimumAccessUser()) {
			try {
				new DML()
					.toInsert(newCase)
					.userMode()
					.commitWork();
			} catch (Exception e) {
				expectedException = e;
			}
			}
		Test.stopTest();

		// Verify
		Assert.isNotNull(expectedException, 'Expected exception to be thrown.');
		Assert.areEqual('Access to entity \'Case\' denied', expectedException.getMessage(), 'Expected exception message should be thrown.');
	}

	@IsTest
	static void toInsertSystemMode() {
		// Setup
		Case newCase = getCase(1);

		// Test
		Test.startTest();
		System.runAs(minimumAccessUser()) {
				new DML()
					.toInsert(newCase)
					.systemMode()
					.commitWork();
		}
		Test.stopTest();

		// Verify
		Assert.areEqual(1, [SELECT COUNT() FROM Case], 'Case should be inserted.');
		Assert.isNotNull(newCase.Id, 'Case should be inserted and have an Id.');
	}

	// UPDATE

	@IsTest
	static void toUpdateSingleRecord() {
		// Setup
		Account account1 = getAccount(1);
		insert account1;

		// Test
		Test.startTest();
			account1.Name = 'Updated Test Account';

			DML.Result result = new DML()
				.toUpdate(account1)
				.commitWork();
		Test.stopTest();

		// Verify
		Assert.areEqual(1, [SELECT COUNT() FROM Account], 'Account should be updated.');

		Assert.areEqual('Updated Test Account', account1.Name, 'Account should be updated.');
			
		Assert.areEqual(0, result.inserted().size(), 'Inserted operation result should contain 0 results.');
		Assert.areEqual(0, result.upserted().size(), 'Upserted operation result should contain 0 results.');
		Assert.areEqual(1, result.updated().size(), 'Updated operation result should contain 1 result.');
		Assert.areEqual(0, result.deleted().size(), 'Deleted operation result should contain 0 results.');
		Assert.areEqual(0, result.undeleted().size(), 'Undeleted operation result should contain 0 results.');
		Assert.areEqual(0, result.published().size(), 'Published operation result should contain 0 results.');

		Assert.areEqual(0, result.inserted(Account.SObjectType).requestedCount(), 'Inserted operation result should contain 1 record.');
		Assert.areEqual(0, result.upserted(Account.SObjectType).requestedCount(), 'Upserted operation result should contain 0 records.');
		Assert.areEqual(1, result.updated(Account.SObjectType).requestedCount(), 'Updated operation result should contain 0 records.');
		Assert.areEqual(0, result.deleted(Account.SObjectType).requestedCount(), 'Deleted operation result should contain 0 records.');
		Assert.areEqual(0, result.undeleted(Account.SObjectType).requestedCount(), 'Undeleted operation result should contain 0 records.');
		Assert.areEqual(0, result.published(Account.SObjectType).requestedCount(), 'Published operation result should contain 0 records.');

		DML.OperationResult operationResult = result.updated(Account.SObjectType);

		Assert.areEqual(1, operationResult.succeededCount(), 'Updated operation result should contain 1 succeeded record.');
		Assert.areEqual(0, operationResult.failedCount(), 'Updated operation result should contain 0 failed record.');
		Assert.areEqual(1, operationResult.requestedCount(), 'Updated operation result should contain 1 record.');
		Assert.areEqual(1, operationResult.records().size(), 'Updated operation result should contain the updated record.');
		Assert.areEqual(1, operationResult.getRecordResults().size(), 'Updated operation result should contain the updated record result.');
		Assert.areEqual(Account.SObjectType, operationResult.getObjectType(), 'Updated operation result should contain Account object type.');
		Assert.areEqual(DML.Type.UPDATE_DML, operationResult.getType(), 'Updated operation result should contain update type.');
		Assert.isFalse(operationResult.hasFailures(), 'Updated operation result should not have failures.');
	}

	@IsTest
	static void toUpdateWithRelationshipSingleRecord() {
		// Setup
		Account newAccount = getAccount(1);
		Contact newContact = getContact(1);
		insert newContact;

		// Test
		Test.startTest();
			new DML()
				.toInsert(newAccount)
				.toUpdate(DML.Record(newContact).withRelationship(Contact.AccountId, newAccount))
				.commitWork();
		Test.stopTest();

		// Verify
		Assert.areEqual(1, [SELECT COUNT() FROM Account], 'Account should be inserted.');
		Assert.areEqual(1, [SELECT COUNT() FROM Contact], 'Contact should be updated.');

		List<Contact> contacts = [SELECT Id, AccountId FROM Contact WHERE Id = :newContact.Id];

		Assert.areEqual(newAccount.Id, contacts[0].AccountId, 'Contact should be related to Account.');
	}

	@IsTest
	static void toUpdateMultipleRecords() {
		// Setup
		Account account1 = getAccount(1);
		Account account2 = getAccount(2);

		insert new List<Account>{ account1, account2 };

		// Test
		Test.startTest();
		account1.Name = 'Updated Test Account 1';
		account2.Name = 'Updated Test Account 2';

			DML.Result result = new DML()
				.toUpdate(account1)
				.toUpdate(account2)
				.commitWork();
		Test.stopTest();

		// Verify
		Assert.areEqual(2, [SELECT COUNT() FROM Account], 'Accounts should be updated.');

		Assert.areEqual('Updated Test Account 1', account1.Name, 'Account 1 should be updated.');
		Assert.areEqual('Updated Test Account 2', account2.Name, 'Account 2 should be updated.');

		Assert.areEqual(0, result.inserted().size(), 'Inserted operation result should contain 0 results.');
		Assert.areEqual(0, result.upserted().size(), 'Upserted operation result should contain 0 results.');
		Assert.areEqual(1, result.updated().size(), 'Updated operation result should contain 1 result.');
		Assert.areEqual(0, result.deleted().size(), 'Deleted operation result should contain 0 results.');
		Assert.areEqual(0, result.undeleted().size(), 'Undeleted operation result should contain 0 results.');
		Assert.areEqual(0, result.published().size(), 'Published operation result should contain 0 results.');

		Assert.areEqual(2, result.updated(Account.SObjectType).requestedCount(), 'Updated operation result should contain 2 Account records.');

		DML.OperationResult operationResult = result.updated(Account.SObjectType);

		Assert.areEqual(2, operationResult.succeededCount(), 'Updated operation result should contain 2 succeeded records.');
		Assert.areEqual(0, operationResult.failedCount(), 'Updated operation result should contain 0 failed record.');
		Assert.areEqual(2, operationResult.requestedCount(), 'Updated operation result should contain 2 records.');
		Assert.areEqual(2, operationResult.records().size(), 'Updated operation result should contain the updated records.');
		Assert.areEqual(2, operationResult.getRecordResults().size(), 'Updated operation result should contain the updated record results.');
		Assert.areEqual(Account.SObjectType, operationResult.getObjectType(), 'Updated operation result should contain Account object type.');
		Assert.areEqual(DML.Type.UPDATE_DML, operationResult.getType(), 'Updated operation result should contain update type.');
		Assert.isFalse(operationResult.hasFailures(), 'Updated operation result should not have failures.');
	}

	@IsTest
	static void toUpdateWithRelationshipMultipleRecords() {
		// Setup
		Account newAccount = getAccount(1);
		Contact newContact = getContact(1);
		Contact newContact2 = getContact(2);

		List<Contact> contactsToCreate = new List<Contact>{ newContact, newContact2 };
		insert contactsToCreate;

		// Test
		Test.startTest();
			new DML()
				.toInsert(newAccount)
				.toUpdate(DML.Records(contactsToCreate).withRelationship(Contact.AccountId, newAccount))
				.commitWork();
		Test.stopTest();

		// Verify
		Assert.areEqual(2, [SELECT COUNT() FROM Contact], 'Contacts should be updated.');
		Assert.areEqual(1, [SELECT COUNT() FROM Account], 'Account should be inserted.');

		List<Contact> contacts = [SELECT Id, AccountId FROM Contact WHERE Id IN :contactsToCreate];

		Assert.areEqual(newAccount.Id, contacts[0].AccountId, 'Contact should be related to Account.');
		Assert.areEqual(newAccount.Id, contacts[1].AccountId, 'Contact 2 should be related to Account.');
	}

	@IsTest
	static void toUpdateMultipleRecordsTypes() {
		// Setup
		Account account1 = getAccount(1);
		Opportunity opportunity1 = getOpportunity(1);
		Lead lead1 = getLead(1);

		insert new List<SObject>{ account1, opportunity1, lead1 };

		// Test
		Test.startTest();
			account1.Name = 'Updated Test Account';
			opportunity1.Name = 'Updated Test Opportunity';
			lead1.FirstName = 'Updated Test';

			DML.Result result = new DML()
				.toUpdate(account1)
				.toUpdate(opportunity1)
				.toUpdate(lead1)
				.commitWork();
		Test.stopTest();   

		// Verify
		Assert.areEqual(1, [SELECT COUNT() FROM Account], 'Account should be updated.');
		Assert.areEqual(1, [SELECT COUNT() FROM Opportunity], 'Opportunity should be updated.');
		Assert.areEqual(1, [SELECT COUNT() FROM Lead], 'Lead should be updated.');

		Assert.areEqual('Updated Test Account', account1.Name, 'Account should be updated.');
		Assert.areEqual('Updated Test Opportunity', opportunity1.Name, 'Opportunity should be updated.');
		Assert.areEqual('Updated Test', lead1.FirstName, 'Lead should be updated.');

		Assert.areEqual(0, result.inserted().size(), 'Inserted operation result should contain 0 results.');
		Assert.areEqual(0, result.upserted().size(), 'Upserted operation result should contain 0 results.');
		Assert.areEqual(3, result.updated().size(), 'Updated operation result should contain 3 results.');
		Assert.areEqual(0, result.deleted().size(), 'Deleted operation result should contain 0 results.');
		Assert.areEqual(0, result.undeleted().size(), 'Undeleted operation result should contain 0 results.');
		Assert.areEqual(0, result.published().size(), 'Published operation result should contain 0 results.');

		Assert.areEqual(1, result.updated(Account.SObjectType).requestedCount(), 'Updated operation result should contain 1 Account record.');
		Assert.areEqual(1, result.updated(Opportunity.SObjectType).requestedCount(), 'Updated operation result should contain 1 Opportunity record.');
		Assert.areEqual(1, result.updated(Lead.SObjectType).requestedCount(), 'Updated operation result should contain 1 Lead record.');

		DML.OperationResult accountOperationResult = result.updated(Account.SObjectType);

		Assert.areEqual(1, accountOperationResult.succeededCount(), 'Updated operation result should contain 1 succeeded record.');
		Assert.areEqual(0, accountOperationResult.failedCount(), 'Updated operation result should contain 0 failed record.');
		Assert.areEqual(1, accountOperationResult.requestedCount(), 'Updated operation result should contain 1 record.');
		Assert.areEqual(1, accountOperationResult.records().size(), 'Updated operation result should contain the updated record.');
		Assert.areEqual(1, accountOperationResult.getRecordResults().size(), 'Updated operation result should contain the updated record results.');
		Assert.areEqual(Account.SObjectType, accountOperationResult.getObjectType(), 'Updated operation result should contain Account object type.');
		Assert.areEqual(DML.Type.UPDATE_DML, accountOperationResult.getType(), 'Updated operation result should contain update type.');
		Assert.isFalse(accountOperationResult.hasFailures(), 'Updated operation result should not have failures.');

		DML.OperationResult opportunityOperationResult = result.updated(Opportunity.SObjectType);

		Assert.areEqual(1, opportunityOperationResult.succeededCount(), 'Updated operation result should contain 1 succeeded record.');
		Assert.areEqual(0, opportunityOperationResult.failedCount(), 'Updated operation result should contain 0 failed record.');
		Assert.areEqual(1, opportunityOperationResult.requestedCount(), 'Updated operation result should contain 1 record.');
		Assert.areEqual(1, opportunityOperationResult.records().size(), 'Updated operation result should contain the updated record.');
		Assert.areEqual(1, opportunityOperationResult.getRecordResults().size(), 'Updated operation result should contain the updated record results.');
		Assert.areEqual(Opportunity.SObjectType, opportunityOperationResult.getObjectType(), 'Updated operation result should contain Opportunity object type.');
		Assert.areEqual(DML.Type.UPDATE_DML, opportunityOperationResult.getType(), 'Updated operation result should contain update type.');
		Assert.isFalse(opportunityOperationResult.hasFailures(), 'Updated operation result should not have failures.');

		DML.OperationResult leadOperationResult = result.updated(Lead.SObjectType);

		Assert.areEqual(1, leadOperationResult.succeededCount(), 'Updated operation result should contain 1 succeeded record.');
		Assert.areEqual(0, leadOperationResult.failedCount(), 'Updated operation result should contain 0 failed record.');
		Assert.areEqual(1, leadOperationResult.requestedCount(), 'Updated operation result should contain 1 record.');
		Assert.areEqual(1, leadOperationResult.records().size(), 'Updated operation result should contain the updated record.');
		Assert.areEqual(1, leadOperationResult.getRecordResults().size(), 'Updated operation result should contain the inserted record results.');
		Assert.areEqual(Lead.SObjectType, leadOperationResult.getObjectType(), 'Updated operation result should contain Lead object type.');
		Assert.areEqual(DML.Type.UPDATE_DML, leadOperationResult.getType(), 'Updated operation result should contain update type.');
		Assert.isFalse(leadOperationResult.hasFailures(), 'Updated operation result should not have failures.');
	}

	@IsTest
	static void toUpdateListOfRecords() {
		// Setup
		List<Account> accounts = new List<Account>{
			getAccount(1),
			getAccount(2),
			getAccount(3)
		};
		insert accounts;

		// Test
		Test.startTest();
		accounts[0].Name = 'Updated Test Account 1';
		accounts[1].Name = 'Updated Test Account 2';
		accounts[2].Name = 'Updated Test Account 3';

			new DML()
				.toUpdate(accounts)
				.commitWork();
		Test.stopTest();

		// Verify
		Assert.areEqual(3, [SELECT COUNT() FROM Account], 'Accounts should be updated.');

		Assert.areEqual('Updated Test Account 1', accounts[0].Name, 'Account 1 should be updated.');
		Assert.areEqual('Updated Test Account 2', accounts[1].Name, 'Account 2 should be updated.');
		Assert.areEqual('Updated Test Account 3', accounts[2].Name, 'Account 3 should be updated.');
	}

	@IsTest
	static void toUpdateWithoutExistingIds() {
		// Setup
		Account account = getAccount(1);
		
		DmlException expectedException = null;
		
		// Test
		Test.startTest();
			try {
				new DML()
					.toUpdate(account)
					.commitWork();
			} catch (DmlException e) {
				expectedException = e;
			}
		Test.stopTest();
		
		// Verify
		Assert.isNotNull(expectedException, 'Expected exception to be thrown.');
		Assert.areEqual('Only existing records can be updated.', expectedException.getMessage(), 'Expected exception message should be thrown.');
	}

	@IsTest
	static void toUpdateWithPartialSuccess() {
		// Setup
		List<Account> accounts = new List<Account>{
			getAccount(1),
			getAccount(2)
		};
		insert accounts;

		// Test
		Test.startTest();
			accounts[0].Name = null;
			accounts[1].Name = 'Test Account 1 New Name';

			new DML()
				.toUpdate(accounts)
				.allowPartialSuccess()
				.commitWork();
		Test.stopTest();

		// Verify
		Assert.areEqual(2, [SELECT COUNT() FROM Account WHERE Name IN ('Test Account 1', 'Test Account 1 New Name')], 'Accounts should be present with expected names after partial success update.');
	}

	@IsTest
	static void toUpdateWithUserMode() {
		// Setup
		Case newCase = getCase(1);
		insert newCase;

		Exception expectedException = null;

		// Test
		Test.startTest();
		System.runAs(minimumAccessUser()) {
			try {
				newCase.Subject = 'Updated Test Case';
				new DML()
					.toUpdate(newCase)
					.commitWork(); // user mode by default
			} catch (Exception e) {
				expectedException = e;
			}
		}
		Test.stopTest();

		// Verify
		Assert.isNotNull(expectedException, 'Expected exception to be thrown.');
		Assert.areEqual('Access to entity \'Case\' denied', expectedException.getMessage(), 'Expected exception message should be thrown.');
	}

	@IsTest
	static void toUpdateWithUserModeExplicitlySet() {
		// Setup
		Case newCase = getCase(1);
		insert newCase;

		Exception expectedException = null;

		// Test
		Test.startTest();
		System.runAs(minimumAccessUser()) {
			try {
				newCase.Subject = 'Updated Test Case';
			new DML()
					.toUpdate(newCase)
					.userMode()
					.commitWork();
			} catch (Exception e) {
				expectedException = e;
			}
		}
		Test.stopTest();

		// Verify
		Assert.isNotNull(expectedException, 'Expected exception to be thrown.');
		Assert.areEqual('Access to entity \'Case\' denied', expectedException.getMessage(), 'Expected exception message should be thrown.');
	}

	@IsTest
	static void toUpdateWithSystemMode() {
		// Setup
		Case newCase = getCase(1);
		insert newCase;

		// Test
		Test.startTest();
			System.runAs(minimumAccessUser()) {
				newCase.Subject = 'Updated Test Case';

				new DML()
					.toUpdate(newCase)
					.systemMode()
					.withoutSharing()
					.commitWork();
			}
		Test.stopTest();

		// Verify
		Assert.areEqual(1, [SELECT COUNT() FROM Case], 'Case should be updated.');
		Assert.isNotNull(newCase.Id, 'Case should be updated and have an Id.');
	}


	@IsTest
	static void toUpdateWithSystemModeAndWithSharing() {
		// Setup
		Contact newContact = getContact(1);
		insert newContact;

		Exception expectedException = null;

		// Test
		Test.startTest();
		System.runAs(minimumAccessUser()) {
			try {
				newContact.FirstName = 'Updated Test Contact';
				new DML()
					.toUpdate(newContact)
					.systemMode()
					.withSharing()
					.commitWork();
			} catch (Exception e) {
				expectedException = e;
			}
		}
		Test.stopTest();

		// Verify
		Assert.isNotNull(expectedException, 'Expected exception to be thrown.');
		Assert.isTrue(expectedException.getMessage().contains('insufficient access rights on cross-reference id'), 'Expected exception message should be thrown.');
	}

	// UPSERT

	@IsTest
	static void toUpsertSingleExistingRecord() {
		// Setup
		Account account1 = getAccount(1);
		insert account1;

		// Test
		Test.startTest();
			account1.Name = 'Updated Test Account';

			DML.Result result = new DML()
				.toUpsert(account1)
				.commitWork();
		Test.stopTest();

		// Verify
		Assert.areEqual(1, [SELECT COUNT() FROM Account], 'Account should be updated.');

		Assert.areEqual('Updated Test Account', account1.Name, 'Account should be updated.');

		Assert.areEqual(0, result.inserted().size(), 'Inserted operation result should contain 0 results.');
		Assert.areEqual(1, result.upserted().size(), 'Upserted operation result should contain 1 result.');
		Assert.areEqual(0, result.updated().size(), 'Updated operation result should contain 0 results.');
		Assert.areEqual(0, result.deleted().size(), 'Deleted operation result should contain 0 results.');
		Assert.areEqual(0, result.undeleted().size(), 'Undeleted operation result should contain 0 results.');
		Assert.areEqual(0, result.published().size(), 'Published operation result should contain 0 results.');

		Assert.areEqual(0, result.inserted(Account.SObjectType).requestedCount(), 'Inserted operation result should contain 0 records.');
		Assert.areEqual(1, result.upserted(Account.SObjectType).requestedCount(), 'Upserted operation result should contain 1 record.');
		Assert.areEqual(0, result.updated(Account.SObjectType).requestedCount(), 'Updated operation result should contain 0 records.');
		Assert.areEqual(0, result.deleted(Account.SObjectType).requestedCount(), 'Deleted operation result should contain 0 records.');
		Assert.areEqual(0, result.undeleted(Account.SObjectType).requestedCount(), 'Undeleted operation result should contain 0 records.');
		Assert.areEqual(0, result.published(Account.SObjectType).requestedCount(), 'Published operation result should contain 0 records.');

		DML.OperationResult operationResult = result.upserted(Account.SObjectType);

		Assert.areEqual(1, operationResult.succeededCount(), 'Upserted operation result should contain 1 succeeded record.');
		Assert.areEqual(0, operationResult.failedCount(), 'Upserted operation result should contain 0 failed record.');
		Assert.areEqual(1, operationResult.requestedCount(), 'Upserted operation result should contain 1 record.');
		Assert.areEqual(1, operationResult.records().size(), 'Upserted operation result should contain the upserted record.');
		Assert.areEqual(1, operationResult.getRecordResults().size(), 'Upserted operation result should contain the upserted record result.');
		Assert.areEqual(Account.SObjectType, operationResult.getObjectType(), 'Upserted operation result should contain Account object type.');
		Assert.areEqual(DML.Type.UPSERT_DML, operationResult.getType(), 'Upserted operation result should contain upsert type.');
		Assert.isFalse(operationResult.hasFailures(), 'Upserted operation result should not have failures.');
	}

	@IsTest
	static void toUpsertSingleNewRecord() {
		// Setup
		Account account1 = getAccount(1);

		// Test
		Test.startTest();
			DML.Result result = new DML()
				.toUpsert(account1)
				.commitWork();
		Test.stopTest();

		// Verify
		Assert.areEqual(1, [SELECT COUNT() FROM Account], 'Account should be inserted.');

		Assert.isNotNull(account1.Id, 'Account should be inserted and have an Id.');

		Assert.areEqual(0, result.inserted().size(), 'Inserted operation result should contain 0 results.');
		Assert.areEqual(1, result.upserted().size(), 'Upserted operation result should contain 1 result.');
		Assert.areEqual(0, result.updated().size(), 'Updated operation result should contain 0 results.');
		Assert.areEqual(0, result.deleted().size(), 'Deleted operation result should contain 0 results.');
		Assert.areEqual(0, result.undeleted().size(), 'Undeleted operation result should contain 0 results.');
		Assert.areEqual(0, result.published().size(), 'Published operation result should contain 0 results.');

		Assert.areEqual(0, result.inserted(Account.SObjectType).requestedCount(), 'Inserted operation result should contain 0 records.');
		Assert.areEqual(1, result.upserted(Account.SObjectType).requestedCount(), 'Upserted operation result should contain 1 record.');
		Assert.areEqual(0, result.updated(Account.SObjectType).requestedCount(), 'Updated operation result should contain 0 records.');
		Assert.areEqual(0, result.deleted(Account.SObjectType).requestedCount(), 'Deleted operation result should contain 0 records.');
		Assert.areEqual(0, result.undeleted(Account.SObjectType).requestedCount(), 'Undeleted operation result should contain 0 records.');
		Assert.areEqual(0, result.published(Account.SObjectType).requestedCount(), 'Published operation result should contain 0 records.');

		DML.OperationResult operationResult = result.upserted(Account.SObjectType);

		Assert.areEqual(1, operationResult.succeededCount(), 'Upserted operation result should contain 1 succeeded record.');
		Assert.areEqual(0, operationResult.failedCount(), 'Upserted operation result should contain 0 failed record.');
		Assert.areEqual(1, operationResult.requestedCount(), 'Upserted operation result should contain 1 record.');
		Assert.areEqual(1, operationResult.records().size(), 'Upserted operation result should contain the upserted record.');
		Assert.areEqual(1, operationResult.getRecordResults().size(), 'Upserted operation result should contain the upserted record result.');
		Assert.areEqual(Account.SObjectType, operationResult.getObjectType(), 'Upserted operation result should contain Account object type.');
		Assert.areEqual(DML.Type.UPSERT_DML, operationResult.getType(), 'Upserted operation result should contain upsert type.');
		Assert.isFalse(operationResult.hasFailures(), 'Upserted operation result should not have failures.');
	}

	@IsTest
	static void toUpsertMultipleExistingRecords() {
		// Setup
		Account account1 = getAccount(1);
		Account account2 = getAccount(2);

		insert new List<Account>{ account1, account2 };

		// Test
		Test.startTest();
		account1.Name = 'Updated Test Account 1';
		account2.Name = 'Updated Test Account 2';

			new DML()
				.toUpsert(account1)
				.toUpsert(account2)
				.commitWork();
		Test.stopTest();

		// Verify
		Assert.areEqual(2, [SELECT COUNT() FROM Account], 'Accounts should be updated.');

		Assert.areEqual('Updated Test Account 1', account1.Name, 'Account 1 should be updated.');
		Assert.areEqual('Updated Test Account 2', account2.Name, 'Account 2 should be updated.');
	}

	@IsTest
	static void toUpsertMultipleNewRecords() {
		// Setup
		Account account1 = getAccount(1);
		Account account2 = getAccount(2);

		// Test
		Test.startTest();
			new DML()
				.toUpsert(account1)
				.toUpsert(account2)
				.commitWork();
		Test.stopTest();

		// Verify
		Assert.areEqual(2, [SELECT COUNT() FROM Account], 'Accounts should be inserted.');

		Assert.isNotNull(account1.Id, 'Account 1 should be inserted and have an Id.');
		Assert.isNotNull(account2.Id, 'Account 2 should be inserted and have an Id.');
	}

	@IsTest
	static void toUpsertExistingAndNewRecords() {
		// Setup
		Account account1 = getAccount(1);
		Account account2 = getAccount(2);

		insert account1;
		
		// Test
		Test.startTest();
			account1.Name = 'Updated Test Account 1';

			new DML()
				.toUpsert(account1)
				.toUpsert(account2)
				.commitWork();
		Test.stopTest();
		
		// Verify
		Assert.areEqual(2, [SELECT COUNT() FROM Account], 'Both accounts should be upserted.');

		Assert.areEqual('Updated Test Account 1', account1.Name, 'Account 1 should be updated.');
		Assert.isNotNull(account2.Id, 'Account 2 should be inserted and have an Id.');
	}

	@IsTest
	static void toUpsertListOfRecords() {
		// Setup
		List<Account> existingAccounts = new List<Account>{
			getAccount(1),
			getAccount(2),
			getAccount(3)
		};
		insert existingAccounts;

		// Test
		Test.startTest();
		existingAccounts[0].Name = 'Updated Test Account 1';
		existingAccounts[1].Name = 'Updated Test Account 2';
		existingAccounts[2].Name = 'Updated Test Account 3';

		List<Account> newAccounts = new List<Account>{
				getAccount(1),
				getAccount(2),
				getAccount(3)
			};

			new DML()
				.toUpsert(existingAccounts)
				.toUpsert(newAccounts)
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

	@IsTest
	static void toUpsertWithPartialSuccess() {
		// Setup
		List<Account> accounts = new List<Account>{
			getAccount(1),
			getAccount(2)
		};
		insert accounts;

		// Test
		Test.startTest();
			accounts[0].Name = null; // Name will not change, because it's set to null
		accounts[1].Name = 'Test Account 1 New Name';

			accounts.add(getAccount(3)); // New account
		
			new DML()
				.toUpsert(accounts)
				.allowPartialSuccess()
				.commitWork();
		Test.stopTest();

		// Verify
		Assert.areEqual(3, [SELECT COUNT() FROM Account WHERE Name IN ('Test Account 1', 'Test Account 1 New Name', 'Test Account 3')], 'Accounts should be upserted with expected names.');
	}

	@IsTest
	static void toUpsertWithUserMode() {
		// Setup
		Case newCase1 = getCase(1);
		Case newCase2 = getCase(2);

		insert newCase1;

		Exception expectedException = null;

		// Test
		Test.startTest();
		System.runAs(minimumAccessUser()) {
			try {
				newCase1.Subject = 'Updated Test Case';

				new DML()
					.toUpsert(newCase1)
					.toUpsert(newCase2)
					.commitWork(); // user mode by default
			} catch (Exception e) {
				expectedException = e;
			}
		}
		Test.stopTest();

		// Verify
		Assert.isNotNull(expectedException, 'Expected exception to be thrown.');
		Assert.isTrue(expectedException.getMessage().contains('Operation failed due to fields being inaccessible on Sobject Case, check errors on Exception or Result'), 'Expected exception message should be thrown.');
	}

	@IsTest
	static void toUpsertWithUserModeExplicitlySet() {
		// Setup
		Case newCase1 = getCase(1);
		Case newCase2 = getCase(2);

		insert newCase1;

		Exception expectedException = null;

		// Test
		Test.startTest();
		System.runAs(minimumAccessUser()) {
			try {
				newCase1.Subject = 'Updated Test Case';

				new DML()
					.toUpsert(newCase1)
					.toUpsert(newCase2)
					.userMode()
					.commitWork();
			} catch (Exception e) {
				expectedException = e;
			}
		}
		Test.stopTest();

		// Verify
		Assert.isNotNull(expectedException, 'Expected exception to be thrown.');
		Assert.isTrue(expectedException.getMessage().contains('Operation failed due to fields being inaccessible on Sobject Case, check errors on Exception or Result'), 'Expected exception message should be thrown.');
	}

	@IsTest
	static void toUpsertWithSystemMode() {
		// Setup
		Case newCase1 = getCase(1);
		Case newCase2 = getCase(2);

		insert newCase1;

		// Test
		Test.startTest();
			System.runAs(minimumAccessUser()) {
				newCase1.Subject = 'Updated Test Case';

				new DML()
					.toUpsert(newCase1)
					.toUpsert(newCase2)
					.systemMode()
					.withoutSharing()
					.commitWork();
			}
		Test.stopTest();

		// Verify
		Assert.areEqual(2, [SELECT COUNT() FROM Case], 'Cases should be upserted.');

		Assert.isNotNull(newCase1.Id, 'Case 1 should be upserted and have an Id.');
		Assert.isNotNull(newCase2.Id, 'Case 2 should be upserted and have an Id.');
	}

	@IsTest
	static void toUpsertWithSystemModeAndWithSharing() {
		// Setup
		Contact newContact1 = getContact(1);
		Contact newContact2 = getContact(2);

		insert newContact1;

		Exception expectedException = null;

		// Test
		Test.startTest();
		System.runAs(minimumAccessUser()) {
			try {
				newContact1.FirstName = 'Updated Test Contact';
				new DML()
					.toUpsert(newContact1)
					.toUpsert(newContact2)
					.withSharing()
					.systemMode()
					.commitWork();
			} catch (Exception e) {
				expectedException = e;
			}
		}
		Test.stopTest();

		// Verify
		Assert.isNotNull(expectedException, 'Expected exception to be thrown.');
		Assert.isTrue(expectedException.getMessage().contains('insufficient access rights on cross-reference id'), 'Expected exception message should be thrown.');
	}

	// DELETE

	@IsTest
	static void toDeleteSingleRecordById() {
		// Setup
		Account account = insertAccount();
		
		// Test
		Test.startTest();
			new DML()
				.toDelete(account.Id)
				.commitWork();
		Test.stopTest();

		// Verify
		Assert.areEqual(0, [SELECT COUNT() FROM Account], 'Account should be deleted.');
	}

	@IsTest
	static void toDeleteSingleRecord() {
		// Setup
		Account account1 = insertAccount();
		
		// Test
		Test.startTest();
			DML.Result result = new DML()
				.toDelete(account1)
				.commitWork();
		Test.stopTest();
		
		// Verify
		Assert.areEqual(0, [SELECT COUNT() FROM Account], 'Account should be deleted.');

		Assert.areEqual(0, result.inserted().size(), 'Inserted operation result should contain 0 results.');
		Assert.areEqual(0, result.upserted().size(), 'Upserted operation result should contain 0 results.');
		Assert.areEqual(0, result.updated().size(), 'Updated operation result should contain 0 results.');
		Assert.areEqual(1, result.deleted().size(), 'Deleted operation result should contain 1 result.');
		Assert.areEqual(0, result.undeleted().size(), 'Undeleted operation result should contain 0 results.');
		Assert.areEqual(0, result.published().size(), 'Published operation result should contain 0 results.');

		Assert.areEqual(0, result.inserted(Account.SObjectType).requestedCount(), 'Inserted operation result should contain 0 records.');
		Assert.areEqual(0, result.upserted(Account.SObjectType).requestedCount(), 'Upserted operation result should contain 0 records.');
		Assert.areEqual(0, result.updated(Account.SObjectType).requestedCount(), 'Updated operation result should contain 0 records.');
		Assert.areEqual(1, result.deleted(Account.SObjectType).requestedCount(), 'Deleted operation result should contain 1 record.');
		Assert.areEqual(0, result.undeleted(Account.SObjectType).requestedCount(), 'Undeleted operation result should contain 0 records.');
		Assert.areEqual(0, result.published(Account.SObjectType).requestedCount(), 'Published operation result should contain 0 records.');

		DML.OperationResult operationResult = result.deleted(Account.SObjectType);

		Assert.areEqual(1, operationResult.succeededCount(), 'Deleted operation result should contain 1 succeeded record.');
		Assert.areEqual(0, operationResult.failedCount(), 'Deleted operation result should contain 0 failed record.');
		Assert.areEqual(1, operationResult.requestedCount(), 'Deleted operation result should contain 1 record.');
		Assert.areEqual(1, operationResult.records().size(), 'Deleted operation result should contain the deleted record.');
		Assert.areEqual(1, operationResult.getRecordResults().size(), 'Deleted operation result should contain the deleted record result.');
		Assert.areEqual(Account.SObjectType, operationResult.getObjectType(), 'Deleted operation result should contain Account object type.');
		Assert.areEqual(DML.Type.DELETE_DML, operationResult.getType(), 'Deleted operation result should contain delete type.');
		Assert.isFalse(operationResult.hasFailures(), 'Deleted operation result should not have failures.');
	}

	@IsTest
	static void toDeleteMultipleRecords() {
		// Setup
		Account account1 = getAccount(1);
		Account account2 = getAccount(2);

		insert new List<Account>{ account1, account2 };
		
		// Test
		Test.startTest();
			DML.Result result = new DML()
				.toDelete(account1)
				.toDelete(account2)
				.commitWork();
		Test.stopTest();

		// Verify
		Assert.areEqual(0, [SELECT COUNT() FROM Account], 'Accounts should be deleted.');

		Assert.areEqual(0, result.inserted().size(), 'Inserted operation result should contain 0 results.');
		Assert.areEqual(0, result.upserted().size(), 'Upserted operation result should contain 0 results.');
		Assert.areEqual(0, result.updated().size(), 'Updated operation result should contain 0 results.');
		Assert.areEqual(1, result.deleted().size(), 'Deleted operation result should contain 1 result.');
		Assert.areEqual(0, result.undeleted().size(), 'Undeleted operation result should contain 0 results.');
		Assert.areEqual(0, result.published().size(), 'Published operation result should contain 0 results.');

		Assert.areEqual(2, result.deleted(Account.SObjectType).requestedCount(), 'Deleted operation result should contain 2 Account records.');

		DML.OperationResult operationResult = result.deleted(Account.SObjectType);

		Assert.areEqual(2, operationResult.succeededCount(), 'Deleted operation result should contain 2 succeeded records.');
		Assert.areEqual(0, operationResult.failedCount(), 'Deleted operation result should contain 0 failed record.');
		Assert.areEqual(2, operationResult.requestedCount(), 'Deleted operation result should contain 2 records.');
		Assert.areEqual(2, operationResult.records().size(), 'Deleted operation result should contain the deleted records.');
		Assert.areEqual(2, operationResult.getRecordResults().size(), 'Deleted operation result should contain the deleted record results.');
		Assert.areEqual(Account.SObjectType, operationResult.getObjectType(), 'Deleted operation result should contain Account object type.');
		Assert.areEqual(DML.Type.DELETE_DML, operationResult.getType(), 'Deleted operation result should contain delete type.');
		Assert.isFalse(operationResult.hasFailures(), 'Deleted operation result should not have failures.');
	}

	@IsTest
	static void toDeleteListOfRecords() {
		// Setup
		List<Account> accounts = insertAccounts();

		// Test
		Test.startTest();
			new DML()
				.toDelete(accounts)
				.commitWork();
		Test.stopTest();

		// Verify
		Assert.areEqual(0, [SELECT COUNT() FROM Account], 'Accounts should be deleted.');
	}

	@IsTest
	static void toDeleteMultipleRecordsById() {
		// Setup
		List<Account> accounts = insertAccounts();

		// Test
		Test.startTest();
			Set<Id> accountIds = new Map<Id, Account>(accounts).keySet();

			new DML()
				.toDelete(accountIds)
				.commitWork();
		Test.stopTest();

		// Verify
		Assert.areEqual(0, [SELECT COUNT() FROM Account], 'Accounts should be deleted.');
	}

	@IsTest
	static void toDeleteMultipleRecordsTypes() {
		// Setup
		Account account1 = getAccount(1);
		Opportunity opportunity1 = getOpportunity(1);
		Lead lead1 = getLead(1);

		insert new List<SObject>{ account1, opportunity1, lead1 };

		// Test
		Test.startTest();
			DML.Result result = new DML()
				.toDelete(account1)
				.toDelete(opportunity1)
				.toDelete(lead1)
				.commitWork();
		Test.stopTest();   

		// Verify
		Assert.areEqual(0, [SELECT COUNT() FROM Account], 'Account should be deleted.');
		Assert.areEqual(0, [SELECT COUNT() FROM Opportunity], 'Opportunity should be deleted.');
		Assert.areEqual(0, [SELECT COUNT() FROM Lead], 'Lead should be deleted.');

		Assert.areEqual(0, result.inserted().size(), 'Inserted operation result should contain 0 results.');
		Assert.areEqual(0, result.upserted().size(), 'Upserted operation result should contain 0 results.');
		Assert.areEqual(0, result.updated().size(), 'Updated operation result should contain 0 results.');
		Assert.areEqual(3, result.deleted().size(), 'Deleted operation result should contain 3 results.');
		Assert.areEqual(0, result.undeleted().size(), 'Undeleted operation result should contain 0 results.');
		Assert.areEqual(0, result.published().size(), 'Published operation result should contain 0 results.');

		Assert.areEqual(1, result.deleted(Account.SObjectType).requestedCount(), 'Deleted operation result should contain 1 Account record.');
		Assert.areEqual(1, result.deleted(Opportunity.SObjectType).requestedCount(), 'Deleted operation result should contain 1 Opportunity record.');
		Assert.areEqual(1, result.deleted(Lead.SObjectType).requestedCount(), 'Deleted operation result should contain 1 Lead record.');

		DML.OperationResult accountOperationResult = result.deleted(Account.SObjectType);

		Assert.areEqual(1, accountOperationResult.succeededCount(), 'Deleted operation result should contain 1 succeeded record.');
		Assert.areEqual(0, accountOperationResult.failedCount(), 'Deleted operation result should contain 0 failed record.');
		Assert.areEqual(1, accountOperationResult.requestedCount(), 'Deleted operation result should contain 1 record.');
		Assert.areEqual(1, accountOperationResult.records().size(), 'Deleted operation result should contain the deleted record.');
		Assert.areEqual(1, accountOperationResult.getRecordResults().size(), 'Deleted operation result should contain the deleted record results.');
		Assert.areEqual(Account.SObjectType, accountOperationResult.getObjectType(), 'Deleted operation result should contain Account object type.');
		Assert.areEqual(DML.Type.DELETE_DML, accountOperationResult.getType(), 'Deleted operation result should contain delete type.');
		Assert.isFalse(accountOperationResult.hasFailures(), 'Deleted operation result should not have failures.');

		DML.OperationResult opportunityOperationResult = result.deleted(Opportunity.SObjectType);

		Assert.areEqual(1, opportunityOperationResult.succeededCount(), 'Deleted operation result should contain 1 succeeded record.');
		Assert.areEqual(0, opportunityOperationResult.failedCount(), 'Deleted operation result should contain 0 failed record.');
		Assert.areEqual(1, opportunityOperationResult.requestedCount(), 'Deleted operation result should contain 1 record.');
		Assert.areEqual(1, opportunityOperationResult.records().size(), 'Deleted operation result should contain the deleted record.');
		Assert.areEqual(1, opportunityOperationResult.getRecordResults().size(), 'Deleted operation result should contain the deleted record results.');
		Assert.areEqual(Opportunity.SObjectType, opportunityOperationResult.getObjectType(), 'Deleted operation result should contain Opportunity object type.');
		Assert.areEqual(DML.Type.DELETE_DML, opportunityOperationResult.getType(), 'Deleted operation result should contain delete type.');
		Assert.isFalse(opportunityOperationResult.hasFailures(), 'Deleted operation result should not have failures.');

		DML.OperationResult leadOperationResult = result.deleted(Lead.SObjectType);

		Assert.areEqual(1, leadOperationResult.succeededCount(), 'Deleted operation result should contain 1 succeeded record.');
		Assert.areEqual(0, leadOperationResult.failedCount(), 'Deleted operation result should contain 0 failed record.');
		Assert.areEqual(1, leadOperationResult.requestedCount(), 'Deleted operation result should contain 1 record.');
		Assert.areEqual(1, leadOperationResult.records().size(), 'Deleted operation result should contain the deleted record.');
		Assert.areEqual(1, leadOperationResult.getRecordResults().size(), 'Deleted operation result should contain the deleted record results.');
		Assert.areEqual(Lead.SObjectType, leadOperationResult.getObjectType(), 'Deleted operation result should contain Lead object type.');
		Assert.areEqual(DML.Type.DELETE_DML, leadOperationResult.getType(), 'Deleted operation result should contain delete type.');
		Assert.isFalse(leadOperationResult.hasFailures(), 'Deleted operation result should not have failures.');
	}

	@IsTest
	static void toDeleteWithoutExistingIds() {
		// Setup
		Account account = getAccount(1);
		
		DmlException expectedException = null;
		
		// Test
		Test.startTest();
			try {
				new DML()
					.toDelete(account)
					.commitWork();
			} catch (DmlException e) {
				expectedException = e;
			}
		Test.stopTest();
		
		// Verify
		Assert.isNotNull(expectedException, 'Expected exception to be thrown.');
		Assert.areEqual('Only existing records can be registered as deleted.', expectedException.getMessage(), 'Expected exception message should be thrown.');
	}

	@IsTest
	static void toDeleteWithPartialSuccess() {
		// Setup
		List<Account> accounts = new List<Account>{
			getAccount(1),
			getAccount(2)
		};

		insert accounts;

		// Test
		Test.startTest();
			new DML()
				.toDelete(accounts)
				.allowPartialSuccess()
				.commitWork();
		Test.stopTest();

		// Verify
		Assert.areEqual(0, [SELECT COUNT() FROM Account], 'Accounts should be deleted.');
	}

	@IsTest
	static void toDeleteWithUserMode() {
		// Setup
		Case newCase = getCase(1);
		insert newCase;

		Exception expectedException = null;

		// Test
		Test.startTest();
		System.runAs(minimumAccessUser()) {
			try {
				new DML()
					.toDelete(newCase)
					.commitWork(); // user mode by default
			} catch (Exception e) {
				expectedException = e;
			}
		}
		Test.stopTest();

		// Verify
		Assert.isNotNull(expectedException, 'Expected exception to be thrown.');
		Assert.areEqual('Access to entity \'Case\' denied', expectedException.getMessage(), 'Expected exception message should be thrown.');
	}

	@IsTest
	static void toDeleteWithUserModeExplicitlySet() {
		// Setup
		Case newCase = getCase(1);
		insert newCase;

		Exception expectedException = null;

		// Test
		Test.startTest();
		System.runAs(minimumAccessUser()) {
			try {
				new DML()
					.toDelete(newCase)
					.userMode()
					.commitWork();
			} catch (Exception e) {
				expectedException = e;
			}
		}
		Test.stopTest();

		// Verify
		Assert.isNotNull(expectedException, 'Expected exception to be thrown.');
		Assert.areEqual('Access to entity \'Case\' denied', expectedException.getMessage(), 'Expected exception message should be thrown.');
	}

	@IsTest
	static void toDeleteWithSystemMode() {
		// Setup
		Case newCase = getCase(1);
		insert newCase;

		// Test
		Test.startTest();
			System.runAs(minimumAccessUser()) {
				new DML()
					.toDelete(newCase)
					.systemMode()
					.withoutSharing()
					.commitWork();
			}
		Test.stopTest();

		// Verify
		Assert.areEqual(0, [SELECT COUNT() FROM Case], 'Cases should be deleted.');
	}

	@IsTest
	static void toDeleteWithSystemModeAndWithSharing() {
		// Setup
		Case newCase = getCase(1);
		insert newCase;

		Exception expectedException = null;

		// Test
		Test.startTest();
			System.runAs(minimumAccessUser()) {
				try {					
					new DML()
						.toDelete(newCase)
						.systemMode()
						.withoutSharing()
						.commitWork();
				} catch (Exception e) {
					expectedException = e;
				}
			}
		Test.stopTest();

		// Verify
		Assert.areEqual(0, [SELECT COUNT() FROM Case], 'Case should be deleted with system mode and without sharing.');
		Assert.isNull(expectedException, 'No exception should be thrown.');
	}

	// UNDELETE

	@IsTest
	static void toUndeleteSingleRecordById() {
		// Setup
		Account account = insertAccount();
		delete account;

		Assert.areEqual(0, [SELECT COUNT() FROM Account], 'Account should be deleted.');

		// Test
		Test.startTest();
			new DML()
				.toUndelete(account.Id)
				.commitWork();
		Test.stopTest();
		
		// Verify
		Assert.areEqual(1, [SELECT COUNT() FROM Account], 'Account should be undeleted.');
	}

	@IsTest
	static void toUndeleteSingleRecord() {
		// Setup
		Account account1 = insertAccount();
		delete account1;

		Assert.areEqual(0, [SELECT COUNT() FROM Account], 'Account should be deleted.');

		// Test
		Test.startTest();
			DML.Result result = new DML()
				.toUndelete(account1)
				.commitWork();
		Test.stopTest();
		
		// Verify
		Assert.areEqual(1, [SELECT COUNT() FROM Account], 'Account should be undeleted.');

		Assert.areEqual(0, result.inserted().size(), 'Inserted operation result should contain 0 results.');
		Assert.areEqual(0, result.upserted().size(), 'Upserted operation result should contain 0 results.');
		Assert.areEqual(0, result.updated().size(), 'Updated operation result should contain 0 results.');
		Assert.areEqual(0, result.deleted().size(), 'Deleted operation result should contain 0 results.');
		Assert.areEqual(1, result.undeleted().size(), 'Undeleted operation result should contain 1 result.');
		Assert.areEqual(0, result.published().size(), 'Published operation result should contain 0 results.');

		Assert.areEqual(0, result.inserted(Account.SObjectType).requestedCount(), 'Inserted operation result should contain 0 records.');
		Assert.areEqual(0, result.upserted(Account.SObjectType).requestedCount(), 'Upserted operation result should contain 0 records.');
		Assert.areEqual(0, result.updated(Account.SObjectType).requestedCount(), 'Updated operation result should contain 0 records.');
		Assert.areEqual(0, result.deleted(Account.SObjectType).requestedCount(), 'Deleted operation result should contain 0 records.');
		Assert.areEqual(1, result.undeleted(Account.SObjectType).requestedCount(), 'Undeleted operation result should contain 1 record.');
		Assert.areEqual(0, result.published(Account.SObjectType).requestedCount(), 'Published operation result should contain 0 records.');

		DML.OperationResult operationResult = result.undeleted(Account.SObjectType);

		Assert.areEqual(1, operationResult.succeededCount(), 'Undeleted operation result should contain 1 succeeded record.');
		Assert.areEqual(0, operationResult.failedCount(), 'Undeleted operation result should contain 0 failed record.');
		Assert.areEqual(1, operationResult.requestedCount(), 'Undeleted operation result should contain 1 record.');
		Assert.areEqual(1, operationResult.records().size(), 'Undeleted operation result should contain the undeleted record.');
		Assert.areEqual(1, operationResult.getRecordResults().size(), 'Undeleted operation result should contain the undeleted record result.');
		Assert.areEqual(Account.SObjectType, operationResult.getObjectType(), 'Undeleted operation result should contain Account object type.');
		Assert.areEqual(DML.Type.UNDELETE_DML, operationResult.getType(), 'Undeleted operation result should contain undelete type.');
		Assert.isFalse(operationResult.hasFailures(), 'Undeleted operation result should not have failures.');
	}

	@IsTest
	static void toUndeleteMultipleRecordsById() {
		// Setup
		List<Account> accounts = insertAccounts();
		delete accounts;

		Assert.areEqual(0, [SELECT COUNT() FROM Account], 'Accounts should be deleted.');

		// Test
		Test.startTest();
			Set<Id> accountIds = new Map<Id, Account>(accounts).keySet();

			new DML()
				.toUndelete(accountIds)
				.commitWork();
		Test.stopTest();
		
		// Verify
		Assert.areEqual(accounts.size(), [SELECT COUNT() FROM Account], 'Accounts should be undeleted.');
	}

	@IsTest
	static void toUndeleteMultipleRecords() {
		// Setup
		List<Account> accounts = insertAccounts();
		delete accounts;

		Assert.areEqual(0, [SELECT COUNT() FROM Account], 'Accounts should be deleted.');

		// Test
		Test.startTest();
			DML.Result result = new DML()
				.toUndelete(accounts)
				.commitWork();
		Test.stopTest();
		
		// Verify
		Assert.areEqual(accounts.size(), [SELECT COUNT() FROM Account], 'Accounts should be undeleted.');

		Assert.areEqual(0, result.inserted().size(), 'Inserted operation result should contain 0 results.');
		Assert.areEqual(0, result.upserted().size(), 'Upserted operation result should contain 0 results.');
		Assert.areEqual(0, result.updated().size(), 'Updated operation result should contain 0 results.');
		Assert.areEqual(0, result.deleted().size(), 'Deleted operation result should contain 0 results.');
		Assert.areEqual(1, result.undeleted().size(), 'Undeleted operation result should contain 1 result.');
		Assert.areEqual(0, result.published().size(), 'Published operation result should contain 0 results.');

		Assert.areEqual(3, result.undeleted(Account.SObjectType).requestedCount(), 'Undeleted operation result should contain 3 Account records.');

		DML.OperationResult operationResult = result.undeleted(Account.SObjectType);

		Assert.areEqual(3, operationResult.succeededCount(), 'Undeleted operation result should contain 3 succeeded records.');
		Assert.areEqual(0, operationResult.failedCount(), 'Undeleted operation result should contain 0 failed record.');
		Assert.areEqual(3, operationResult.requestedCount(), 'Undeleted operation result should contain 3 records.');
		Assert.areEqual(3, operationResult.records().size(), 'Undeleted operation result should contain the undeleted records.');
		Assert.areEqual(3, operationResult.getRecordResults().size(), 'Undeleted operation result should contain the undeleted record results.');
		Assert.areEqual(Account.SObjectType, operationResult.getObjectType(), 'Undeleted operation result should contain Account object type.');
		Assert.areEqual(DML.Type.UNDELETE_DML, operationResult.getType(), 'Undeleted operation result should contain undelete type.');
		Assert.isFalse(operationResult.hasFailures(), 'Undeleted operation result should not have failures.');
	}

	@IsTest
	static void toUndeleteMultipleRecordsTypes() {
		// Setup
		Account account1 = getAccount(1);
		Opportunity opportunity1 = getOpportunity(1);
		Lead lead1 = getLead(1);

		insert new List<SObject>{ account1, opportunity1, lead1 };
		delete new List<SObject>{ account1, opportunity1, lead1 };

		// Test
		Test.startTest();
			DML.Result result = new DML()
				.toUndelete(account1)
				.toUndelete(opportunity1)
				.toUndelete(lead1)
				.commitWork();
		Test.stopTest();   

		// Verify
		Assert.areEqual(1, [SELECT COUNT() FROM Account], 'Account should be undeleted.');
		Assert.areEqual(1, [SELECT COUNT() FROM Opportunity], 'Opportunity should be undeleted.');
		Assert.areEqual(1, [SELECT COUNT() FROM Lead], 'Lead should be undeleted.');

		Assert.areEqual(0, result.inserted().size(), 'Inserted operation result should contain 0 results.');
		Assert.areEqual(0, result.upserted().size(), 'Upserted operation result should contain 0 results.');
		Assert.areEqual(0, result.updated().size(), 'Updated operation result should contain 0 results.');
		Assert.areEqual(0, result.deleted().size(), 'Deleted operation result should contain 0 results.');
		Assert.areEqual(3, result.undeleted().size(), 'Undeleted operation result should contain 3 results.');
		Assert.areEqual(0, result.published().size(), 'Published operation result should contain 0 results.');

		Assert.areEqual(1, result.undeleted(Account.SObjectType).requestedCount(), 'Undeleted operation result should contain 1 Account record.');
		Assert.areEqual(1, result.undeleted(Opportunity.SObjectType).requestedCount(), 'Undeleted operation result should contain 1 Opportunity record.');
		Assert.areEqual(1, result.undeleted(Lead.SObjectType).requestedCount(), 'Undeleted operation result should contain 1 Lead record.');

		DML.OperationResult accountOperationResult = result.undeleted(Account.SObjectType);

		Assert.areEqual(1, accountOperationResult.succeededCount(), 'Undeleted operation result should contain 1 succeeded record.');
		Assert.areEqual(0, accountOperationResult.failedCount(), 'Undeleted operation result should contain 0 failed record.');
		Assert.areEqual(1, accountOperationResult.requestedCount(), 'Undeleted operation result should contain 1 record.');
		Assert.areEqual(1, accountOperationResult.records().size(), 'Undeleted operation result should contain the undeleted record.');
		Assert.areEqual(1, accountOperationResult.getRecordResults().size(), 'Undeleted operation result should contain the undeleted record results.');
		Assert.areEqual(Account.SObjectType, accountOperationResult.getObjectType(), 'Undeleted operation result should contain Account object type.');
		Assert.areEqual(DML.Type.UNDELETE_DML, accountOperationResult.getType(), 'Undeleted operation result should contain undelete type.');
		Assert.isFalse(accountOperationResult.hasFailures(), 'Undeleted operation result should not have failures.');

		DML.OperationResult opportunityOperationResult = result.undeleted(Opportunity.SObjectType);

		Assert.areEqual(1, opportunityOperationResult.succeededCount(), 'Undeleted operation result should contain 1 succeeded record.');
		Assert.areEqual(0, opportunityOperationResult.failedCount(), 'Undeleted operation result should contain 0 failed record.');
		Assert.areEqual(1, opportunityOperationResult.requestedCount(), 'Undeleted operation result should contain 1 record.');
		Assert.areEqual(1, opportunityOperationResult.records().size(), 'Undeleted operation result should contain the undeleted record.');
		Assert.areEqual(1, opportunityOperationResult.getRecordResults().size(), 'Undeleted operation result should contain the undeleted record results.');
		Assert.areEqual(Opportunity.SObjectType, opportunityOperationResult.getObjectType(), 'Undeleted operation result should contain Opportunity object type.');
		Assert.areEqual(DML.Type.UNDELETE_DML, opportunityOperationResult.getType(), 'Undeleted operation result should contain undelete type.');
		Assert.isFalse(opportunityOperationResult.hasFailures(), 'Undeleted operation result should not have failures.');

		DML.OperationResult leadOperationResult = result.undeleted(Lead.SObjectType);

		Assert.areEqual(1, leadOperationResult.succeededCount(), 'Undeleted operation result should contain 1 succeeded record.');
		Assert.areEqual(0, leadOperationResult.failedCount(), 'Undeleted operation result should contain 0 failed record.');
		Assert.areEqual(1, leadOperationResult.requestedCount(), 'Undeleted operation result should contain 1 record.');
		Assert.areEqual(1, leadOperationResult.records().size(), 'Undeleted operation result should contain the undeleted record.');
		Assert.areEqual(1, leadOperationResult.getRecordResults().size(), 'Undeleted operation result should contain the undeleted record results.');
		Assert.areEqual(Lead.SObjectType, leadOperationResult.getObjectType(), 'Undeleted operation result should contain Lead object type.');
		Assert.areEqual(DML.Type.UNDELETE_DML, leadOperationResult.getType(), 'Undeleted operation result should contain undelete type.');
		Assert.isFalse(leadOperationResult.hasFailures(), 'Undeleted operation result should not have failures.');
	}

	@IsTest
	static void toUndeleteWithoutExistingIds() {
		// Setup
		Account account = getAccount(1);

		DmlException expectedException = null;
		
		// Test
		Test.startTest();
			try {
				new DML()
					.toUndelete(account)
					.commitWork();
			} catch (DmlException e) {
				expectedException = e;
			}
		Test.stopTest();
		
		// Verify
		Assert.isNotNull(expectedException, 'Expected exception to be thrown.');
		Assert.areEqual('Only deleted records can be undeleted.', expectedException.getMessage(), 'Expected exception message should be thrown.');
	}

	@IsTest
	static void toUndeleteWithUserMode() {
		// Setup
		Case newCase = getCase(1);
		insert newCase;

		delete newCase;

		Assert.areEqual(0, [SELECT COUNT() FROM Case], 'Cases should be deleted.');

		Exception expectedException = null;

		// Test
		Test.startTest();
		System.runAs(minimumAccessUser()) {
			try {
				new DML()
					.toUndelete(newCase)
					.commitWork(); // user mode by default
			} catch (Exception e) {
				expectedException = e;
			}
		}
		Test.stopTest();

		// Verify
		Assert.isNotNull(expectedException, 'Expected exception to be thrown.');
		Assert.isTrue(expectedException.getMessage().contains('invalid record id'), 'Expected exception message should be thrown.');
	}

	@IsTest
	static void toUndeleteWithUserModeExplicitlySet() {
		// Setup
		Case newCase = getCase(1);
		insert newCase;

		delete newCase;

		Assert.areEqual(0, [SELECT COUNT() FROM Case], 'Cases should be deleted.');

		Exception expectedException = null;

		// Test
		Test.startTest();
		System.runAs(minimumAccessUser()) {
			try {
				new DML()
					.toUndelete(newCase)
					.userMode()
					.commitWork();
			} catch (Exception e) {
				expectedException = e;
			}
		}
		Test.stopTest();

		// Verify
		Assert.isNotNull(expectedException, 'Expected exception to be thrown.');
		Assert.isTrue(expectedException.getMessage().contains('invalid record id'), 'Expected exception message should be thrown.');
	}

	@IsTest
	static void toUndeleteWithSystemMode() {
		// Setup
		Case newCase = getCase(1);
		insert newCase;

		delete newCase;

		Assert.areEqual(0, [SELECT COUNT() FROM Case], 'Cases should be deleted.');

		// Test
		Test.startTest();
			System.runAs(minimumAccessUser()) {
				new DML()
					.toUndelete(newCase)
					.systemMode()
					.withoutSharing()
					.commitWork();
			}
		Test.stopTest();

		// Verify
		Assert.areEqual(1, [SELECT COUNT() FROM Case], 'Cases should be undeleted.');
	}


	@IsTest
	static void toUndeleteWithSystemModeAndWithSharing() {
		// Setup
		Case newCase = getCase(1);
		insert newCase;

		delete newCase;

		Assert.areEqual(0, [SELECT COUNT() FROM Case], 'Cases should be deleted.');

		Exception expectedException = null;

		// Test
		Test.startTest();
		System.runAs(minimumAccessUser()) {
			try {
				new DML()
					.toUndelete(newCase)
					.systemMode()
					.withSharing()
					.commitWork();
			} catch (Exception e) {
				expectedException = e;
			}
		}
		Test.stopTest();

		// Verify
		Assert.areEqual(0, [SELECT COUNT() FROM Case], 'Case should not be undeleted, because user has no access with sharing mode.');
		Assert.isNotNull(expectedException, 'Expected exception to be thrown.');
		Assert.isTrue(expectedException.getMessage().contains('insufficient access rights on object id'), 'Expected exception message should be thrown.');
	}

	// PLATFORM EVENT

	@IsTest
	static void toPublishSingleRecord() {
		// Setup
		FlowOrchestrationEvent event = new FlowOrchestrationEvent();

		Exception expectedException = null;

		// Test
		Test.startTest();
			DML.Result result = null;
			try {
				result = new DML()
					.toPublish(event)
					.commitWork();
			} catch (Exception e) {
				expectedException = e;
			}
		Test.stopTest();

		// Verify
		Assert.isNull(expectedException, 'Expected exception should not be thrown.');

		Assert.areEqual(0, result.inserted().size(), 'Inserted operation result should contain 0 results.');
		Assert.areEqual(0, result.upserted().size(), 'Upserted operation result should contain 0 results.');
		Assert.areEqual(0, result.updated().size(), 'Updated operation result should contain 0 results.');
		Assert.areEqual(0, result.deleted().size(), 'Deleted operation result should contain 0 results.');
		Assert.areEqual(0, result.undeleted().size(), 'Undeleted operation result should contain 0 results.');
		Assert.areEqual(1, result.published().size(), 'Published operation result should contain 1 result.');

		Assert.areEqual(0, result.inserted(FlowOrchestrationEvent.SObjectType).requestedCount(), 'Inserted operation result should contain 0 records.');
		Assert.areEqual(0, result.upserted(FlowOrchestrationEvent.SObjectType).requestedCount(), 'Upserted operation result should contain 0 records.');
		Assert.areEqual(0, result.updated(FlowOrchestrationEvent.SObjectType).requestedCount(), 'Updated operation result should contain 0 records.');
		Assert.areEqual(0, result.deleted(FlowOrchestrationEvent.SObjectType).requestedCount(), 'Deleted operation result should contain 0 records.');
		Assert.areEqual(0, result.undeleted(FlowOrchestrationEvent.SObjectType).requestedCount(), 'Undeleted operation result should contain 0 records.');
		Assert.areEqual(1, result.published(FlowOrchestrationEvent.SObjectType).requestedCount(), 'Published operation result should contain 1 record.');

		DML.OperationResult operationResult = result.published(FlowOrchestrationEvent.SObjectType);

		Assert.areEqual(0, operationResult.succeededCount(), 'Published operation result should contain 0 succeeded record.');
		Assert.areEqual(1, operationResult.failedCount(), 'Published operation result should contain 0 failed record.');
		Assert.areEqual(1, operationResult.requestedCount(), 'Published operation result should contain 1 record.');
		Assert.areEqual(1, operationResult.records().size(), 'Published operation result should contain the published record.');
		Assert.areEqual(1, operationResult.getRecordResults().size(), 'Published operation result should contain the published record result.');
		Assert.areEqual(FlowOrchestrationEvent.SObjectType, operationResult.getObjectType(), 'Published operation result should contain FlowOrchestrationEvent object type.');
		Assert.areEqual(DML.Type.PUBLISH_DML, operationResult.getType(), 'Published operation result should contain publish type.');
		Assert.isTrue(operationResult.hasFailures(), 'Published operation result should have failures.');
	}

	@IsTest
	static void toPublishMultipleRecords() {
		// Setup
		List<FlowOrchestrationEvent> events = new List<FlowOrchestrationEvent>{
			new FlowOrchestrationEvent(),
			new FlowOrchestrationEvent()
		};
		
		Exception expectedException = null;
		
		// Test
		Test.startTest();
			DML.Result result = null;
			try {
				result = new DML()
					.toPublish(events)
					.commitWork();
			} catch (Exception e) {
				expectedException = e;
			}
		Test.stopTest();

		// Verify
		Assert.isNull(expectedException, 'Expected exception should not be thrown.');

		Assert.areEqual(0, result.inserted().size(), 'Inserted operation result should contain 0 results.');
		Assert.areEqual(0, result.upserted().size(), 'Upserted operation result should contain 0 results.');
		Assert.areEqual(0, result.updated().size(), 'Updated operation result should contain 0 results.');
		Assert.areEqual(0, result.deleted().size(), 'Deleted operation result should contain 0 results.');
		Assert.areEqual(0, result.undeleted().size(), 'Undeleted operation result should contain 0 results.');
		Assert.areEqual(1, result.published().size(), 'Published operation result should contain 1 result.');

		Assert.areEqual(2, result.published(FlowOrchestrationEvent.SObjectType).requestedCount(), 'Published operation result should contain 2 FlowOrchestrationEvent records.');

		DML.OperationResult operationResult = result.published(FlowOrchestrationEvent.SObjectType);

		Assert.areEqual(0, operationResult.succeededCount(), 'Published operation result should contain 2 succeeded records.');
		Assert.areEqual(2, operationResult.failedCount(), 'Published operation result should contain 0 failed record.');
		Assert.areEqual(2, operationResult.requestedCount(), 'Published operation result should contain 2 records.');
		Assert.areEqual(2, operationResult.records().size(), 'Published operation result should contain the published records.');
		Assert.areEqual(2, operationResult.getRecordResults().size(), 'Published operation result should contain the published record results.');
		Assert.areEqual(FlowOrchestrationEvent.SObjectType, operationResult.getObjectType(), 'Published operation result should contain FlowOrchestrationEvent object type.');
		Assert.areEqual(DML.Type.PUBLISH_DML, operationResult.getType(), 'Published operation result should contain publish type.');
		Assert.isTrue(operationResult.hasFailures(), 'Published operation result should have failures.');
	}

	// DEBUG

	@IsTest
	static void dryRun() {
		// Setup
		Account account = getAccount(1);
		
		// Test
		Test.startTest();
			new DML()
				.toInsert(account)
				.dryRun();
		Test.stopTest();

		// Verify
		Assert.areEqual(0, [SELECT COUNT() FROM Account], 'Account should not be inserted.');
	}

	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
	@IsTest
	static void preview() {
		// Setup
		Account account = getAccount(1);
		
		// Test
		new DML()
			.toInsert(account)
			.preview();
	}

	// CONFIGURATION
	
	@IsTest
	static void executionOrder() {
		// Setup
		Account newAccount = getAccount(1);
		Contact newContact = getContact(1);
		Opportunity newOpportunity = getOpportunity(1);

		// Test
		Test.startTest();
			new DML(new List<SObjectType>{ Account.SObjectType, Contact.SObjectType, Opportunity.SObjectType })
				.toInsert(newOpportunity)
				.toInsert(newAccount)
				.toInsert(newContact)
				.commitWork();
		Test.stopTest();

		// Verify
		Assert.areEqual(1, [SELECT COUNT() FROM Account], 'Account should be inserted.');
		Assert.areEqual(1, [SELECT COUNT() FROM Contact], 'Contact should be inserted.');
		Assert.areEqual(1, [SELECT COUNT() FROM Opportunity], 'Opportunity should be inserted.');
	}

	@IsTest
	static void executionOrderWhenOneOfObjectsIsNotRegistered() {
		// Setup
		Account newAccount = getAccount(1);
		Contact newContact = getContact(1);

		// Test
		Test.startTest();
			new DML(new List<SObjectType>{ Account.SObjectType, Contact.SObjectType, Opportunity.SObjectType })
				.toInsert(newAccount)
				.toInsert(newContact)
				.commitWork();
		Test.stopTest();

		// Verify
		Assert.areEqual(1, [SELECT COUNT() FROM Account], 'Account should be inserted.');
		Assert.areEqual(1, [SELECT COUNT() FROM Contact], 'Contact should be inserted.');
		Assert.areEqual(0, [SELECT COUNT() FROM Opportunity], 'Opportunity should not be inserted.');
	}

	@IsTest
	static void executionOrderWhenOneOfObjectsIsRegisteredButNotInTheOrder() {
		// Setup
		Account newAccount = getAccount(1);
		Contact newContact = getContact(1);
		Opportunity newOpportunity = getOpportunity(1);

		Exception expectedException = null;
		
		// Test
		Test.startTest();
			try {
				new DML(new List<SObjectType>{ Account.SObjectType, Contact.SObjectType })
					.toInsert(newAccount)
					.toInsert(newContact)
					.toInsert(newOpportunity)
					.commitWork();
			} catch (Exception e) {
				expectedException = e;
			}
		Test.stopTest();

		// Verify
		Assert.isNotNull(expectedException, 'Expected exception to be thrown.');
		Assert.areEqual('Only the following types can be registered: (Account, Contact)', expectedException.getMessage(), 'Expected exception message should be thrown.');
	}

	// RECORD

	@IsTest
	static void singleSObjectRecordWithValue() {
		// Setup
		Account newAccount = getAccount(1);

		// Test
		Test.startTest();
			new DML()
				.toInsert(DML.Record(newAccount)
					.with(Account.Name, 'New Test Account')
					.with(Account.Industry, 'New Test Industry')
					.with(Account.Description, 'New Test Description')
				)
				.commitWork();
		Test.stopTest();

		// Verify
		Assert.areEqual(1, [SELECT COUNT() FROM Account], 'Account should be inserted.');

		List<Account> accounts = [SELECT Id, Name, Industry, Description FROM Account LIMIT 1];

		Assert.areEqual('New Test Account', accounts[0].Name, 'Account name should be "New Test Account".');
		Assert.areEqual('New Test Industry', accounts[0].Industry, 'Account industry should be "New Test Industry".');
		Assert.areEqual('New Test Description', accounts[0].Description, 'Account description should be "New Test Description".');
	}

	@IsTest
	static void singleIdRecordWithValue() {
		// Setup
		Account newAccount = getAccount(1);
		insert newAccount;

		// Test
		Test.startTest();
			new DML()
				.toUpdate(DML.Record(newAccount.Id)
					.with(Account.Name, 'New Test Account')
					.with(Account.Industry, 'New Test Industry')
					.with(Account.Description, 'New Test Description')
				)
				.commitWork();
		Test.stopTest();

		// Verify
		Assert.areEqual(1, [SELECT COUNT() FROM Account], 'Account should be updated.');

		List<Account> accounts = [SELECT Id, Name, Industry, Description FROM Account LIMIT 1];

		Assert.areEqual('New Test Account', accounts[0].Name, 'Account name should be "New Test Account".');
		Assert.areEqual('New Test Industry', accounts[0].Industry, 'Account industry should be "New Test Industry".');
		Assert.areEqual('New Test Description', accounts[0].Description, 'Account description should be "New Test Description".');
	}

	// RECORDS

	@IsTest
	static void multipleSObjectRecordsWithValue() {
		// Setup
		Account newAccount1 = getAccount(1);
		Account newAccount2 = getAccount(2);

		List<Account> newAccounts = new List<Account>{ newAccount1, newAccount2 };

		// Test
		Test.startTest();
			new DML()
				.toInsert(DML.Records(newAccounts)
					.with(Account.Industry, 'New Test Industry')
					.with(Account.Description, 'New Test Description')
				)
				.commitWork();
		Test.stopTest();

		// Verify
		Assert.areEqual(2, [SELECT COUNT() FROM Account], 'Accounts should be inserted.');

		List<Account> accounts = [SELECT Id, Industry, Description FROM Account LIMIT 2];

		Assert.areEqual('New Test Industry', accounts[0].Industry, 'Account industry should be "New Test Industry".');
		Assert.areEqual('New Test Description', accounts[0].Description, 'Account description should be "New Test Description".');
		
		Assert.areEqual('New Test Industry', accounts[1].Industry, 'Account industry should be "New Test Industry".');
		Assert.areEqual('New Test Description', accounts[1].Description, 'Account description should be "New Test Description".');
	}

	// OPTIONS

	@IsTest
	static void allowFieldTruncationOption() {
		// Setup
		String longAccountName = 'Test Account ' + 'Test'.repeat(' ', 100);
		Account account = getAccount(1);
		account.Name = longAccountName;

		// Test
		Test.startTest();
			Database.DmlOptions options = new Database.DmlOptions();
			options.allowFieldTruncation = true;
			
			new DML()
				.toInsert(account)
				.options(options)
				.commitWork();
		Test.stopTest();

		// Verify
		List<Account> accounts = getAccounts();

		Assert.areEqual(1, accounts.size(), 'Account should be inserted.');
		Assert.areEqual(255, accounts[0].Name.length(), 'Account name should be 255 characters long, because allowFieldTruncation is true.');
	}

	@IsTest
	static void optionsAllOrNoneDisabled() {
		// Setup
		List<Account> accounts = new List<Account>{
			getAccount(1),
			new Account() // Name is required
		};

		// Test
		Test.startTest();
			Database.DmlOptions options = new Database.DmlOptions();
			options.optAllOrNone = false;
			
			new DML()
				.toInsert(accounts)
				.options(options)
				.commitWork();
		Test.stopTest();

		// Verify
		Assert.areEqual(1, [SELECT COUNT() FROM Account], 'Only one account should be inserted, because one has missing required field.');
	}

	@IsTest
	static void optionsAllOrNoneEnabled() {
		// Setup
		List<Account> accounts = new List<Account>{
			getAccount(1),
			new Account() // Name is required
		};

		Exception expectedException = null;

		// Test
		Test.startTest();
			Database.DmlOptions options = new Database.DmlOptions();
			options.optAllOrNone = true;
			
			try {
				new DML()
					.toInsert(accounts)
					.options(options)
					.commitWork();
			} catch (Exception e) {
				expectedException = e;
			}
		Test.stopTest();

		// Verify
		Assert.isNotNull(expectedException, 'Expected exception to be thrown.');
		Assert.isTrue(expectedException.getMessage().contains('Required fields are missing: [Name]'), 'Expected exception message should be thrown.');
	}

	// SHARED

	@IsTest
	static void sharedDmlInstance() {
		Account account = getAccount(1);

		Test.startTest();
		Integer dmlStatementsBefore = Limits.getDMLStatements();

		DML.Shared.toInsert(account).commitWork();
		DML.Shared.commitWork();

		Integer dmlStatementsAfter = Limits.getDMLStatements();
		Test.stopTest();

		Assert.areEqual(1, [SELECT COUNT() FROM Account], 'Account should be inserted.');
		Assert.areEqual(1, dmlStatementsAfter - dmlStatementsBefore, 'DML statements should be 1, because second commitWork() should not do anything.');
	}

	// COMPLEX

	@IsTest
	static void registerComplex() {
		// Setup
		DML uow = new DML();

		// Test
		Test.startTest();
		for(Integer i = 0 ; i < 10 ; i++) {
			Opportunity newOpportunity = new Opportunity(
				Name = 'UoW Test Name ' + i,
				StageName = 'Open',
				CloseDate = System.today()
			);

			uow.toInsert(newOpportunity);

			for(Integer j = 0 ; j < i + 1 ; j++) {
				Product2 product = new Product2(Name = newOpportunity.Name + ' : Product : ' + i);
				
				uow.toInsert(product);

				PricebookEntry pbe = new PricebookEntry(
					UnitPrice = 10,
					IsActive = true,
					UseStandardPrice = false,
					Pricebook2Id = Test.getStandardPricebookId()
				);

				uow.toInsert(
					DML.Record(pbe)
						.withRelationship(PricebookEntry.Product2Id, product)
				);

				OpportunityLineItem oppLineItem = new OpportunityLineItem(
					Quantity = 1,
					TotalPrice = 10
				);

				uow.toInsert(
					DML.Record(new OpportunityLineItem(Quantity = 1, TotalPrice = 10))
						.withRelationship(OpportunityLineItem.PricebookEntryId, pbe)
						.withRelationship(OpportunityLineItem.OpportunityId, newOpportunity)
				);
			}
		}
		uow.commitWork();
		Test.stopTest();

		// Verify
		Assert.areEqual(10, [SELECT COUNT() FROM Opportunity], 'Opportunities should be inserted.');
		Assert.areEqual(55, [SELECT COUNT() FROM Product2], 'Products should be inserted.');
		Assert.areEqual(55, [SELECT COUNT() FROM PricebookEntry], 'Pricebook entries should be inserted.');
	}

	// HOOK

	@IsTest
	static void commitHook() {
		// Setup
		Account account = getAccount(1);

		MyHook hook = new MyHook();
		
		// Test
		Test.startTest();
			new DML()
				.toInsert(account)
				.commitHook(hook)
				.commitWork();
		Test.stopTest();

		// Verify
		Assert.isTrue(hook.beforeCalled, 'Before hook should be called.');
		Assert.isTrue(hook.afterCalled, 'After hook should be called.');
	}

	public class MyHook implements DML.Hook {
		private Boolean beforeCalled = false;
		private Boolean afterCalled = false;

		public void before() {
			beforeCalled = true;
		}

		public void after() {
			afterCalled = true;
		}
	}

	// HELPERS

	static Account getAccount(Integer index) {
		return new Account(Name = 'Test Account ' + index);
	}

	static Contact getContact(Integer index) {
		return new Contact(FirstName = 'Test ' + index, LastName = 'Contact ' + index);
	}

	static Opportunity getOpportunity(Integer index) {
		return new Opportunity(Name = 'Test Opportunity ' + index, CloseDate = Date.today(), StageName = 'Prospecting');
	}

	static Lead getLead(Integer index) {
		return new Lead(FirstName = 'Test ' + index, LastName = 'Lead ' + index, Company = 'Test Company ' + index);
	}

	static Case getCase(Integer index) {
		return new Case(Status = 'New', Origin = 'Web');
	}

	static Task getTask(Integer index) {
		return new Task(Subject = 'Test ' + index, Type = 'Other');
	}

	static Account insertAccount() {
		Account account = new Account(Name = 'Test Account');
		insert account;

		return account;
	}

	static List<Account> getAccounts() {
		return [SELECT Id, Name FROM Account];
	}

	static List<Account> insertAccounts() {
		List<Account> accounts = new List<Account>{
			new Account(Name = 'Test Account 1'),
			new Account(Name = 'Test Account 2'),
			new Account(Name = 'Test Account 3')
		};
		insert accounts;

		return accounts;
	}

	static User minimumAccessUser() {
		return new User(
			Alias = 'newUser',
			Email = 'newuser@testorg.com',
			EmailEncodingKey = 'UTF-8',
			LastName = 'Testing',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US',
			Profile = new Profile(Name = 'Minimum Access - Salesforce'),
			TimeZoneSidKey = 'America/Los_Angeles',
			UserName = 'btcdmllibuser@testorg.com'
		);
	}
}