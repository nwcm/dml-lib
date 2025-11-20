/**
 * Copyright (c) 2025 Beyond The Cloud Sp. z o.o. (BeyondTheCloud.Dev)
 * Licensed under the MIT License (https://github.com/beyond-the-cloud-dev/dml-lib/blob/main/LICENSE)
 *
 * v1.6.0
 *
 * PMD False Positives:
 * - MethodNamingConventions - Some methods are uppercase to indicate that they are "constructors" of othere internal classes
 * - CyclomaticComplexity: It is a library and we tried to put everything into ONE class
 * - CognitiveComplexity: It is a library and we tried to put everything into ONE class
 * - ExcessivePublicCount: It is a library and we tried to put everything into ONE class
 * - FieldDeclarationsShouldBeAtStart: The most important methods and interfaces are at the top of the class
 * - AvoidDebugStatements: Debug statements are used for debugging purposes
 * - OperationWithLimitsInLoop: DMLs are executed by SObject Type and the loop is through different types
 * - ApexCRUDViolation: DMLs are executed by User Mode or System Mode
**/
@SuppressWarnings('PMD.MethodNamingConventions,PMD.CyclomaticComplexity,PMD.CognitiveComplexity,PMD.ExcessivePublicCount,PMD.FieldDeclarationsShouldBeAtStart,PMD.AvoidDebugStatements,PMD.OperationWithLimitsInLoop,PMD.ApexCRUDViolation')
public inherited sharing class DML implements Commitable {
	public static Commitable Shared {
		get {
			if (DML.Shared == null) {
				DML.Shared = new DML();
			}
			return DML.Shared;
		}
		private set;
	}

	public static Record Record(SObject record) {
		return new DmlRecord(record);
	}

	public static Record Record(Id recordId) {
		return new DmlRecord(recordId);
	}

	public static Records Records(List<SObject> records) {
		return new DmlRecords(records);
	}

	public static Records Records(Iterable<Id> recordIds) {
		return new DmlRecords(recordIds);
	}

	public interface Commitable {
		// Insert
		Commitable toInsert(SObject record);
		Commitable toInsert(DML.Record record);
		Commitable toInsert(List<SObject> records);
		Commitable toInsert(DML.Records records);
		// Update
		Commitable toUpdate(SObject record);
		Commitable toUpdate(DML.Record record);
		Commitable toUpdate(List<SObject> records);
		Commitable toUpdate(DML.Records records);
		// Upsert
		Commitable toUpsert(SObject record);
		Commitable toUpsert(DML.Record record);
		Commitable toUpsert(List<SObject> records);
		Commitable toUpsert(DML.Records records);
		// Delete
		Commitable toDelete(Id recordId);
		Commitable toDelete(SObject record);
		Commitable toDelete(Iterable<Id> recordIds);
		Commitable toDelete(List<SObject> records);
		// Undelete
		Commitable toUndelete(Id recordId);
		Commitable toUndelete(SObject record);
		Commitable toUndelete(Iterable<Id> recordIds);
		Commitable toUndelete(List<SObject> records);
		// Platform Event
		Commitable toPublish(SObject record);
		Commitable toPublish(List<SObject> records);
		// Debug
		void preview();
		// Field Level Security
		Commitable userMode();
		Commitable systemMode();
		// Sharing Mode
		Commitable withSharing();
		Commitable withoutSharing();
		// Other configs
		Commitable allowPartialSuccess();
		Commitable options(Database.DmlOptions options);
		Commitable commitHook(DML.Hook callback);
		// Save
		Result dryRun();
		Result commitWork();
		Result hardCommitWork();
	}

	public interface Record {
		Record with(SObjectField field, Object value); 
		Record withRelationship(SObjectField targetField, SObject relatedRecord);
		Record withRelationship(SObjectField targetField, SObjectField relatedObjectExternalIdField, Object relatedRecordExternalId);
		
		// for internal use only
		EnhancedRecord get();
	}

	public interface Records {
		Records with(SObjectField field, Object value); 
		Records withRelationship(SObjectField targetField, SObject relatedRecord);
		Records withRelationship(SObjectField targetField, SObjectField relatedObjectExternalIdField, Object relatedRecordExternalId);
		
		// for internal use only
		List<Record> get();
	}

	public interface Result {
		List<OperationResult> all();
		// Per Operation
		List<OperationResult> inserted();
		List<OperationResult> updated();
		List<OperationResult> upserted();
		List<OperationResult> deleted();
		List<OperationResult> undeleted();
		List<OperationResult> published();
		// Per Object Type
		OperationResult inserted(Schema.SObjectType objectType);
		OperationResult updated(Schema.SObjectType objectType);
		OperationResult upserted(Schema.SObjectType objectType);
		OperationResult deleted(Schema.SObjectType objectType);
		OperationResult undeleted(Schema.SObjectType objectType);
		OperationResult published(Schema.SObjectType objectType);
	}

	public interface OperationResult {
		Type getType();
		Schema.SObjectType getObjectType();
		Boolean hasFailures();
		Integer requestedCount();
		Integer succeededCount();
		Integer failedCount();
		List<SObject> records();
		List<RecordResult> getRecordResults();
	}

	public interface RecordResult {
		Id getId();
		// SObject getRecord(); TODO
		Boolean isSuccess();
		List<Error> getErrors();
	}

	public interface Error {
		String getMessage();
		System.StatusCode getStatusCode();
		List<String> getFields();
	}

	// Mockking

	public static Mockable mock(String mockId) {
		return DML.mockIdToMock.get(mockId);
	}

	public static Result mockResult(String mockId) {
		return null;
	}

	public interface Mockable {
		Mockable thenMockAll();
		// Per Operation
		Mockable thenMockInsert();
		Mockable thenMockUpdate();
		Mockable thenMockUpsert();
		Mockable thenMockDelete();
		Mockable thenMockUndelete();
		Mockable thenMockPublish();
	}

	// Hooks

	public interface Hook {
		void before();
		void after();
	}

	// Implementation

	private DmlOperation insertCommand = new InsertOperation();
	private DmlOperation updateCommand = new UpdateOperation();
	private DmlOperation upsertCommand = new UpsertOperation();
	private DmlOperation deleteCommand = new DeleteOperation();
	private DmlOperation undeleteCommand = new UndeleteOperation();
	private DmlOperation publishCommand = new PlatformEventOperation();

	public enum Type { INSERT_DML, UPDATE_DML, UPSERT_DML, DELETE_DML, UNDELETE_DML, HARD_DELETE_DML, MERGE_DML, PUBLISH_DML }

	private DML.Hook hook = null;
	private static Map<String, Mockable> mockIdToMock = new Map<String, Mockable>();

	public DML() {} // default constructor

	public DML(List<SObjectType> customExecutionOrder) {
		this.insertCommand.executionOrder(customExecutionOrder);
		this.updateCommand.executionOrder(customExecutionOrder);
		this.upsertCommand.executionOrder(customExecutionOrder);
		this.deleteCommand.executionOrder(customExecutionOrder);
		this.undeleteCommand.executionOrder(customExecutionOrder);
	}

	// Insert

	public Commitable toInsert(SObject record) {
		return this.toInsert(DML.Record(record));
	}

	public Commitable toInsert(DML.Record record) {
		this.insertCommand.register(record);
		return this;
	}

	public Commitable toInsert(List<SObject> records) {
		return this.toInsert(DML.Records(records));
	}
	
	public Commitable toInsert(DML.Records records) {
		this.insertCommand.register(records);
		return this;
	}

	// Update
	
	public Commitable toUpdate(SObject record) {
		return this.toUpdate(DML.Record(record));
	}

	public Commitable toUpdate(DML.Record record) {
		this.updateCommand.register(record);
		return this;
	}

	public Commitable toUpdate(List<SObject> records) {
		return this.toUpdate(DML.Records(records));
	}

	public Commitable toUpdate(DML.Records records) {
		this.updateCommand.register(records);
		return this;
	}

	// Upsert

	public Commitable toUpsert(SObject record) {
		return this.toUpsert(DML.Record(record));
	}

	public Commitable toUpsert(DML.Record record) {
		this.upsertCommand.register(record);
		return this;
	}

	public Commitable toUpsert(List<SObject> records) {
		return this.toUpsert(DML.Records(records));
	}

	public Commitable toUpsert(DML.Records records) {
		this.upsertCommand.register(records);
		return this;
	}

	// Delete

	public Commitable toDelete(Id recordId) {
		this.deleteCommand.register(DML.Record(recordId));
		return this;
	}

	public Commitable toDelete(SObject record) {
		return this.toDelete(record.Id);
	}

	public Commitable toDelete(Iterable<Id> recordIds) {
		this.deleteCommand.register(DML.Records(recordIds));
		return this;
	}

	public Commitable toDelete(List<SObject> records) {
		this.deleteCommand.register(DML.Records(records));
		return this;
	}

	// Undelete

	public Commitable toUndelete(Id recordId) {
		this.undeleteCommand.register(DML.Record(recordId));
		return this;
	}

	public Commitable toUndelete(SObject record) {
		return this.toUndelete(record.Id);
	}

	public Commitable toUndelete(Iterable<Id> recordIds) {
		this.undeleteCommand.register(DML.Records(recordIds));
		return this;
	}

	public Commitable toUndelete(List<SObject> records) {
		this.undeleteCommand.register(DML.Records(records));
		return this;
	}

	// Platform Event

	public Commitable toPublish(SObject record) {
		this.publishCommand.register(DML.Record(record));
		return this;
	}

	public Commitable toPublish(List<SObject> records) {
		this.publishCommand.register(DML.Records(records));
		return this;
	}

	// Debug

	public void preview() {
		this.insertCommand.preview();
		this.updateCommand.preview();
		this.upsertCommand.preview();
		this.deleteCommand.preview();
		this.undeleteCommand.preview(); 
		this.publishCommand.preview();
	}

	// Field Level Security

	public Commitable userMode() {
		this.insertCommand.userMode();
		this.updateCommand.userMode();
		this.upsertCommand.userMode();
		this.deleteCommand.userMode();
		this.undeleteCommand.userMode();
		this.publishCommand.userMode();
		return this;
	}

	public Commitable systemMode() {
		this.insertCommand.systemMode();
		this.updateCommand.systemMode();
		this.upsertCommand.systemMode();
		this.deleteCommand.systemMode();
		this.undeleteCommand.systemMode();
		this.publishCommand.systemMode();
		return this;
	}

	// Sharing Mode

	public Commitable withSharing() {
		this.updateCommand.withSharing();
		this.upsertCommand.withSharing();
		this.deleteCommand.withSharing();
		this.undeleteCommand.withSharing();
		this.publishCommand.withSharing();
		return this;
	}

	public Commitable withoutSharing() {
		this.insertCommand.withoutSharing();
		this.updateCommand.withoutSharing();
		this.upsertCommand.withoutSharing();
		this.deleteCommand.withoutSharing();
		this.undeleteCommand.withoutSharing();
		this.publishCommand.withoutSharing();
		return this;
	}

	// Other configs

	public Commitable allowPartialSuccess() {
		this.insertCommand.allowPartialSuccess();
		this.updateCommand.allowPartialSuccess();
		this.upsertCommand.allowPartialSuccess();
		this.deleteCommand.allowPartialSuccess();
		this.undeleteCommand.allowPartialSuccess();
		return this;
	}

	public Commitable options(Database.DmlOptions options) {
		this.insertCommand.options(options);
		this.updateCommand.options(options);
		return this;
	}

	// Hooks

	public Commitable commitHook(DML.Hook callback) {
		this.hook = callback;
		return this;
	}

	public Result dryRun() {
		Savepoint savePoint = Database.setSavepoint();

		this.hook?.before();

		DMLResult result = new DmlResult();

		result.add(Type.INSERT_DML, this.insertCommand.commitWork());
		result.add(Type.UPSERT_DML, this.upsertCommand.commitWork());
		result.add(Type.UPDATE_DML, this.updateCommand.commitWork());
		result.add(Type.DELETE_DML, this.deleteCommand.commitWork());
		result.add(Type.UNDELETE_DML, this.undeleteCommand.commitWork());
		result.add(Type.PUBLISH_DML, this.publishCommand.commitWork());

		this.hook?.after();

		Database.rollback(savePoint);

		return result;
	}

	public Result commitWork() {
		DMLResult result = new DmlResult();

		try {
			this.hook?.before();

			result.add(Type.INSERT_DML, this.insertCommand.commitWork());
			result.add(Type.UPSERT_DML, this.upsertCommand.commitWork());
			result.add(Type.UPDATE_DML, this.updateCommand.commitWork());
			result.add(Type.DELETE_DML, this.deleteCommand.commitWork());
			result.add(Type.UNDELETE_DML, this.undeleteCommand.commitWork());
			result.add(Type.PUBLISH_DML, this.publishCommand.commitWork());

			this.hook?.after();
		} catch (Exception e) {
			throw e;
		} finally {
			this.reset();
		}

		return result;
	}

	public Result hardCommitWork() {
		Savepoint savePoint = Database.setSavepoint();

		try {
			return this.commitWork();
		} catch (Exception e) {
			Database.rollback(savePoint);
			throw e;
		} finally {
			Database.releaseSavepoint(savePoint);
		}
	}

	private void reset() {
		this.insertCommand = new InsertOperation();
		this.updateCommand = new UpdateOperation();
		this.upsertCommand = new UpsertOperation();
		this.deleteCommand = new DeleteOperation();
		this.undeleteCommand = new UndeleteOperation();
		this.publishCommand = new PlatformEventOperation();
	}

	public class DmlResult implements DML.Result {
		private Map<Type, Map<SObjectType, OperationResult>> operationResultsByObjectType = new Map<Type, Map<SObjectType, OperationResult>>{
			Type.INSERT_DML => new Map<SObjectType, OperationResult>(),
			Type.UPDATE_DML => new Map<SObjectType, OperationResult>(),
			Type.UPSERT_DML => new Map<SObjectType, OperationResult>(),
			Type.DELETE_DML => new Map<SObjectType, OperationResult>(),
			Type.UNDELETE_DML => new Map<SObjectType, OperationResult>(),
			Type.PUBLISH_DML => new Map<SObjectType, OperationResult>()
		};

		public DmlResult add(Type operationType, List<OperationResult> results) {
			for (OperationResult result : results) {
				this.operationResultsByObjectType.get(operationType).put(result.getObjectType(), result);
			}

			return this;
		}

		public List<OperationResult> inserted() {
			return this.getOperationResults(Type.INSERT_DML);
		}

		public List<OperationResult> updated() {
			return this.getOperationResults(Type.UPDATE_DML);
		}

		public List<OperationResult> upserted() {
			return this.getOperationResults(Type.UPSERT_DML);
		}

		public List<OperationResult> deleted() {
			return this.getOperationResults(Type.DELETE_DML);
		}

		public List<OperationResult> undeleted() {
			return this.getOperationResults(Type.UNDELETE_DML);
		}

		public List<OperationResult> published() {
			return this.getOperationResults(Type.PUBLISH_DML);
		}

		public OperationResult inserted(SObjectType objectType) {
			return this.getOperationResult(Type.INSERT_DML, objectType) ?? new OperationSummary(objectType, Type.INSERT_DML);
		}

		public OperationResult updated(SObjectType objectType) {
			return this.getOperationResult(Type.UPDATE_DML, objectType) ?? new OperationSummary(objectType, Type.UPDATE_DML);
		}

		public OperationResult upserted(SObjectType objectType) {
			return this.getOperationResult(Type.UPSERT_DML, objectType) ?? new OperationSummary(objectType, Type.UPSERT_DML);
		}

		public OperationResult deleted(SObjectType objectType) {
			return this.getOperationResult(Type.DELETE_DML, objectType) ?? new OperationSummary(objectType, Type.DELETE_DML);
		}

		public OperationResult undeleted(SObjectType objectType) {
			return this.getOperationResult(Type.UNDELETE_DML, objectType) ?? new OperationSummary(objectType, Type.UNDELETE_DML);
		}

		public OperationResult published(SObjectType objectType) {
			return this.getOperationResult(Type.PUBLISH_DML, objectType) ?? new OperationSummary(objectType, Type.PUBLISH_DML);
		}

		private List<OperationResult> getOperationResults(Type operationType) {
			List<OperationResult> operationResults = new List<OperationResult>();

			for (SObjectType objectType : this.operationResultsByObjectType.get(operationType).keySet()) {
				operationResults.add(this.operationResultsByObjectType.get(operationType).get(objectType));
			}

			return operationResults;
		}

		private OperationResult getOperationResult(Type operationType, SObjectType objectType) {
			return this.operationResultsByObjectType.get(operationType).get(objectType);
		}

		public List<OperationResult> all() {
			List<OperationResult> allResults = new List<OperationResult>();

			for (Type operationType : this.operationResultsByObjectType.keySet()) {
				allResults.addAll(this.operationResultsByObjectType.get(operationType).values());
			}

			return allResults;
		}
	}

	public abstract class DmlOperation {
		protected Map<SObjectType, RecordsContainer> recordsProcessContainerByType = new Map<SObjectType, RecordsContainer>();
		protected List<SObjectType> customExecutionOrder = new List<SObjectType>();
		protected System.AccessLevel accessMode = System.AccessLevel.USER_MODE;
		protected System.AccessType accessType = null;
		protected Database.DmlOptions options = new Database.DMLOptions();
		protected DmlSharing sharingExecutor = new InheritedSharing();
		protected Boolean allOrNone = true;

		public DmlOperation() {
			this.options.optAllOrNone = this.allOrNone;
		}

		public void userMode() {
			this.accessMode = System.AccessLevel.USER_MODE;
		}

		public void systemMode() {
			this.accessMode = System.AccessLevel.SYSTEM_MODE;
		}

		public void stripInaccessible(System.AccessType type) {
			this.accessType = type;
		}

		public void withSharing() {
			this.sharingExecutor = new WithSharing();
		}

		public void withoutSharing() {
			this.sharingExecutor = new WithoutSharing();
		}

		public void executionOrder(List<SObjectType> customExecutionOrder) {
			this.customExecutionOrder.addAll(customExecutionOrder);
		}

		public DmlOperation allowPartialSuccess() {
			this.allOrNone = false;
			this.options.optAllOrNone = false;
			return this;
		}

		public DmlOperation skipDuplicateRules() {
			this.options.duplicateRuleHeader.allowSave = true;
			return this;
		}

		public void options(Database.DmlOptions options) {
			this.options = options;
			this.options.optAllOrNone = this.options.optAllOrNone ?? this.allOrNone ?? true;
		}

		public void register(DML.Records records) {
			for (DML.Record record : records.get()) {
				this.register(record);
			}
		}

		public void register(DML.Record record) {
			this.validate(record);
			
			EnhancedRecord enhancedRecord = record.get();
			SObjectType typeName = enhancedRecord.getSObjectType();

			if (!this.customExecutionOrder.isEmpty() && !this.customExecutionOrder.contains(typeName)) {
				throw new DmlException('Only the following types can be registered: ' + this.customExecutionOrder);
			}

			if (!this.recordsProcessContainerByType.containsKey(typeName)) {
				this.recordsProcessContainerByType.put(typeName, new RecordsContainer());
			}

			this.recordsProcessContainerByType.get(typeName).addNewRecordToProcess(enhancedRecord);
		}

		public void preview() {
			System.debug(LoggingLevel.ERROR, '\n\n============ DML Preview ============\n' + JSON.serializePretty(this.recordsProcessContainerByType) + '\n=======================================\n');
		}

		public List<OperationResult> commitWork() {
			return this.sharingExecutor.execute(this);
		}

		public List<OperationResult> execute() {
			if (!this.customExecutionOrder.isEmpty()) {
				return this.processBasedOnCustomOrder();
			} 

			return this.processBasedOnRegistrationOrder();
		}

		private List<OperationResult> processBasedOnCustomOrder() {
			List<OperationResult> operationResults = new List<OperationResult>();

			for (SObjectType objectTypeName : this.customExecutionOrder) {
				if (!this.recordsProcessContainerByType.containsKey(objectTypeName)) {
					continue;
				}

				operationResults.add(executeDml(objectTypeName));
			}

			return operationResults;
		}

		private List<OperationResult> processBasedOnRegistrationOrder() {
			List<OperationResult> operationResults = new List<OperationResult>();

			for (SObjectType objectTypeName : this.recordsProcessContainerByType.keySet()) {
				operationResults.add(executeDml(objectTypeName));
			} 

			return operationResults;
		}

		public abstract OperationResult executeDml(SObjectType objectType);

		public virtual void validate(DML.Record record) {
			return;
		}
	}

	private class RecordsContainer {
		private List<EnhancedRecord> enhancedRecords = new List<EnhancedRecord>();

		public void addNewRecordToProcess(EnhancedRecord enhancedRecord) {
			this.enhancedRecords.add(enhancedRecord);
		}

		public List<SObject> getRecordsToProcess(System.AccessType accessType) { 
			List<SObject> recordsToProcess = new List<SObject>();

			for (EnhancedRecord enhancedRecord : this.enhancedRecords) {
				enhancedRecord.resolveRecordRelationships();
				recordsToProcess.add(enhancedRecord.getRecord());
			}

			if (accessType == null) {
				return recordsToProcess;
			}

			return Security.stripInaccessible(accessType, recordsToProcess).getRecords();
		}
		
		public List<Id> getRecordIdsToProcess() {
			List<Id> recordIdsToProcess = new List<Id>();

			for (EnhancedRecord enhancedRecord : this.enhancedRecords) {
				recordIdsToProcess.add(enhancedRecord.getRecordId());
			}

			return recordIdsToProcess;
		}
	}

	public inherited sharing class InsertOperation extends DmlOperation {
		public override void validate(DML.Record record) {
			if (record.get().doesRecordHaveIdSpecified()) {
				throw new DmlException('Only new records can be registered as new.');
			}
		}

		public override OperationResult executeDml(SObjectType objectType) {
			List<SObject> recordsToProcess = this.recordsProcessContainerByType.get(objectType).getRecordsToProcess(this.accessType);
			List<Database.SaveResult> saveResults = Database.insert(recordsToProcess, this.options, this.accessMode);

			return new OperationSummary(objectType, Type.INSERT_DML).setRecords(recordsToProcess).setRecordResults(new SaveResultAdapter(saveResults).transform());
		}
	}

	public inherited sharing class UpdateOperation extends DmlOperation {
		public override void validate(DML.Record record) {
			if (!record.get().doesRecordHaveIdSpecified()) {
				throw new DmlException('Only existing records can be updated.');
			}
		}

		public override OperationResult executeDml(SObjectType objectType) {
			List<SObject> recordsToProcess = this.recordsProcessContainerByType.get(objectType).getRecordsToProcess(this.accessType);
			List<Database.SaveResult> saveResults = Database.update(recordsToProcess, this.options, this.accessMode);

			return new OperationSummary(objectType, Type.UPDATE_DML)
				.setRecords(recordsToProcess)
				.setRecordResults(new SaveResultAdapter(saveResults).transform());
		}
	}

	public inherited sharing class UpsertOperation extends DmlOperation {
		public override OperationResult executeDml(SObjectType objectType) {
			List<SObject> recordsToProcess = this.recordsProcessContainerByType.get(objectType).getRecordsToProcess(this.accessType);
			List<Database.UpsertResult> upsertResults = Database.upsert(recordsToProcess, this.allOrNone, this.accessMode);

			return new OperationSummary(objectType, Type.UPSERT_DML)
				.setRecords(recordsToProcess)
				.setRecordResults(new UpsertResultAdapter(upsertResults).transform());
		}
	}

	public inherited sharing class DeleteOperation extends DmlOperation {
		public override void validate(DML.Record record) {
			if (!record.get().doesRecordHaveIdSpecified()) {
				throw new DmlException('Only existing records can be registered as deleted.');
			}
		}

		public override OperationResult executeDml(SObjectType objectType) {
			List<SObject> recordsToProcess = this.recordsProcessContainerByType.get(objectType).getRecordsToProcess(this.accessType);
			List<Database.DeleteResult> deleteResults = Database.delete(recordsToProcess, this.allOrNone, this.accessMode);

			return new OperationSummary(objectType, Type.DELETE_DML)
				.setRecords(recordsToProcess)
				.setRecordResults(new DeleteResultAdapter(deleteResults).transform());
		}
	}

	public inherited sharing class UndeleteOperation extends DmlOperation {
		public override void validate(DML.Record record) {
			if (!record.get().doesRecordHaveIdSpecified()) {
				throw new DmlException('Only deleted records can be undeleted.');
			}
		}

		public override OperationResult executeDml(SObjectType objectType) {
			List<SObject> recordsToProcess = this.recordsProcessContainerByType.get(objectType).getRecordsToProcess(this.accessType);
			List<Database.UndeleteResult> undeleteResults = Database.undelete(recordsToProcess, this.allOrNone, this.accessMode);

			return new OperationSummary(objectType, Type.UNDELETE_DML)
				.setRecords(recordsToProcess)
				.setRecordResults(new UndeleteResultAdapter(undeleteResults).transform());
		}
	}

	public inherited sharing class PlatformEventOperation extends DmlOperation {
		public override OperationResult executeDml(SObjectType objectType) {
			List<SObject> recordsToProcess = this.recordsProcessContainerByType.get(objectType).getRecordsToProcess(this.accessType);
			List<Database.SaveResult> saveResults = EventBus.publish(recordsToProcess);

			return new OperationSummary(objectType, Type.PUBLISH_DML)
				.setRecords(recordsToProcess)
				.setRecordResults(new SaveResultAdapter(saveResults).transform());
		}
	}
	
	private interface DmlSharing {
		List<OperationResult> execute(DmlOperation executor);
	}

	private inherited sharing class InheritedSharing implements DmlSharing {
		public List<OperationResult> execute(DmlOperation executor) {
			return executor.execute();
		}
	}

	private without sharing class WithoutSharing implements DmlSharing {
		public List<OperationResult> execute(DmlOperation executor) {
			return executor.execute();
		}
	}

	private with sharing class WithSharing implements DmlSharing {
		public List<OperationResult> execute(DmlOperation executor) {
			return executor.execute();
		}
	}

	private class OperationSummary implements OperationResult {
		public SObjectType objectType;
		private Type type;
		public List<RecordResult> recordResults = new List<RecordResult>();
		public List<SObject> records = new List<SObject>();

		public OperationSummary(SObjectType objectType, Type type) {
			this.objectType = objectType;
			this.type = type;
		}

		public OperationSummary setRecords(List<SObject> records) {
			this.records = records;
			return this;
		}

		public OperationSummary setRecordResults(List<RecordResult> recordResults) {
			this.recordResults = recordResults;
			return this;
		}

		public Type getType() {
			return this.type;
		}

		public Boolean hasFailures() {
			return this.failedCount() > 0;
		}

		public Integer requestedCount() {
			return this.records.size();
		}

		public Integer succeededCount() {
			Integer successCount = 0;
			
			for (RecordResult recordResult : this.recordResults) {
				if (recordResult.isSuccess()) {
					successCount++;
				}
			}
			return successCount;
		}

		public Integer failedCount() {
			return this.requestedCount() - this.succeededCount();
		}

		public SObjectType getObjectType() {
			return this.objectType;
		}

		public List<SObject> records() {
			return this.records;
		}

		public List<RecordResult> getRecordResults() {
			return this.recordResults;
		}
	}

	private class RecordSummary implements RecordResult {
		public Id recordId;
		public Boolean isSuccess = false;
		public List<DML.Error> errors = new List<DML.Error>();

		public Id getId() {
			return this.recordId;
		}

		public Boolean isSuccess() {
			return this.isSuccess;
		}

		public List<DML.Error> getErrors() {
			return this.errors;
		}

		public RecordSummary isSuccess(Boolean isSuccess) {
			this.isSuccess = isSuccess;
			return this;
		}

		public RecordSummary recordId(Id recordId) {
			this.recordId = recordId;
			return this;
		}

		public RecordSummary errors(List<Database.Error> errors) {
			for (Database.Error error : errors ?? new List<Database.Error>()) {
				this.errors.add(new RecordProcessingError(error));
			}
			return this;
		}
	}

	private class RecordProcessingError implements DML.Error {
		public String message;
		public System.StatusCode statusCode;
		public List<String> fields;

		public RecordProcessingError(Database.Error error) {
			this.message = error.getMessage();
			this.statusCode = error.getStatusCode();
			this.fields = error.getFields();
		}

		public String getMessage() {
			return this.message;
		}
		public System.StatusCode getStatusCode() {
			return this.statusCode;
		}

		public List<String> getFields() {
			return this.fields;
		}
	}

	private interface DmlAdapter {
		List<RecordResult> transform();
	}

	private class SaveResultAdapter implements DmlAdapter {
		private List<Database.SaveResult> saveResults;

		public SaveResultAdapter(List<Database.SaveResult> saveResults) {
			this.saveResults = saveResults;
		}

		public List<RecordResult> transform() {
			List<RecordResult> recordResults = new List<RecordResult>();

			for (Database.SaveResult saveResult : this.saveResults) {
				recordResults.add(
					new RecordSummary()
						.isSuccess(saveResult.isSuccess())
						.recordId(saveResult.getId())
						.errors(saveResult.getErrors())
				);
			}

			return recordResults;
		}
	}

	private class UpsertResultAdapter implements DmlAdapter {
		private List<Database.UpsertResult> upsertResults;

		public UpsertResultAdapter(List<Database.UpsertResult> upsertResults) {
			this.upsertResults = upsertResults;
		}

		public List<RecordResult> transform() {
			List<RecordResult> recordResults = new List<RecordResult>();

			for (Database.UpsertResult upsertResult : this.upsertResults) {
				recordResults.add(
					new RecordSummary()
						.isSuccess(upsertResult.isSuccess())
						.recordId(upsertResult.getId())
						.errors(upsertResult.getErrors())
				);
			}

			return recordResults;
		}
	}

	private class DeleteResultAdapter implements DmlAdapter {
		private List<Database.DeleteResult> deleteResults;

		public DeleteResultAdapter(List<Database.DeleteResult> deleteResults) {
			this.deleteResults = deleteResults;
		}

		public List<RecordResult> transform() {
			List<RecordResult> recordResults = new List<RecordResult>();

			for (Database.DeleteResult deleteResult : this.deleteResults) {
				recordResults.add(
					new RecordSummary()
						.isSuccess(deleteResult.isSuccess())
						.recordId(deleteResult.getId())
						.errors(deleteResult.getErrors())
				);
			}

			return recordResults;
		}
	}

	private class UndeleteResultAdapter implements DmlAdapter {
		private List<Database.UndeleteResult> undeleteResults;

		public UndeleteResultAdapter(List<Database.UndeleteResult> undeleteResults) {
			this.undeleteResults = undeleteResults;
		}

		public List<RecordResult> transform() {
			List<RecordResult> recordResults = new List<RecordResult>();

			for (Database.UndeleteResult undeleteResult : this.undeleteResults) {
				recordResults.add(
					new RecordSummary()
						.isSuccess(undeleteResult.isSuccess())
						.recordId(undeleteResult.getId())
						.errors(undeleteResult.getErrors())
				);
			}

			return recordResults;
		}
	}

	private class DmlRecords implements Records {
		private List<SObject> recordsToProcess = new List<SObject>();

		private Map<SObjectField, Object> valueByFieldApiName = new Map<SObjectField, Object>();
		private List<ParentRelationship> parentRelationships = new List<ParentRelationship>();
		private List<ExternalRelationship> externalRelationships = new List<ExternalRelationship>();

		public DmlRecords(List<SObject> records) {
			this.recordsToProcess = records;
		}

		public DmlRecords(Iterable<Id> recordIds) {
			SObjectType objectType = recordIds.iterator().next()?.getSObjectType();

			for (Id recordId : recordIds) {
				this.recordsToProcess.add(objectType.newSObject(recordId));
			}       
		}

		public DmlRecords with(SObjectField field, Object value) {
			this.valueByFieldApiName.put(field, value);
			return this;
		}

		public DmlRecords withRelationship(SObjectField relationshipField, SObject relatedToRecord) {
			this.parentRelationships.add(new ParentRelationship(relationshipField, relatedToRecord));
			return this;
		}

		public DmlRecords withRelationship(SObjectField relationshipField, SObjectField externalIdField, Object externalId) {
			this.externalRelationships.add(new ExternalRelationship(relationshipField, externalIdField, externalId));
			return this;
		}

		public List<DML.Record> get() {
			List<DML.Record> dmlRecords = new List<DML.Record>();

			for (SObject record : this.recordsToProcess) {
				DML.Record dmlRecord = new DmlRecord(record);
				EnhancedRecord enhancedRecord = dmlRecord.get();

				this.populateFieldsValues(enhancedRecord);
				this.populateParentRelationships(enhancedRecord);
				this.populateExternalRelationships(enhancedRecord);

				dmlRecords.add(dmlRecord);
			}

			return dmlRecords;
		}

		private void populateFieldsValues(EnhancedRecord enhancedRecord) {
			for (SObjectField field : this.valueByFieldApiName.keySet()) {
				enhancedRecord.with(field, this.valueByFieldApiName.get(field));
			}
		}

		private void populateParentRelationships(EnhancedRecord enhancedRecord) {
			for (ParentRelationship parentRelationship : this.parentRelationships) {
				enhancedRecord.withRelationship(parentRelationship);
			}
		}

		private void populateExternalRelationships(EnhancedRecord enhancedRecord) {
			for (ExternalRelationship externalRelationship : this.externalRelationships) {
				enhancedRecord.withRelationship(externalRelationship);
			}
		}
	}

	private class DmlRecord implements Record {
		private EnhancedRecord enhancedRecord;

		public DmlRecord(SObject record) {
			this.enhancedRecord = new EnhancedRecord(record);
		}

		public DmlRecord(Id recordId) {
			this.enhancedRecord = new EnhancedRecord(recordId);
		}

		public DmlRecord with(SObjectField field, Object value) {
			this.enhancedRecord.with(field, value);
			return this;
		}

		public DmlRecord withRelationship(SObjectField relationshipField, SObject relatedToRecord) {
			this.enhancedRecord.withRelationship(new ParentRelationship(relationshipField, relatedToRecord));
			return this;
		}

		public DmlRecord withRelationship(SObjectField relationshipField, SObjectField externalIdField, Object externalId) {
			this.enhancedRecord.withRelationship(new ExternalRelationship(relationshipField, externalIdField, externalId));
			return this;
		}

		public EnhancedRecord get() {
			return this.enhancedRecord;
		}
	}

	private class EnhancedRecord {
		private SObject currentRecord;

		private List<ParentRelationship> parentRelationships = new List<ParentRelationship>();
		private List<ExternalRelationship> externalRelationships = new List<ExternalRelationship>();

		public EnhancedRecord(SObject currentRecord) {
			this.currentRecord = currentRecord;
		}

		public EnhancedRecord(Id currentRecordId) {
			if (currentRecordId == null) {
				return;
			}

			this.currentRecord = currentRecordId.getSObjectType().newSObject(currentRecordId);
		}

		public void with(SObjectField field, Object value) {
			this.currentRecord.put(field, value);
		}

		public void withRelationship(ParentRelationship parentRelationship) {
			this.parentRelationships.add(parentRelationship);
		}

		public void withRelationship(ExternalRelationship externalRelationship) {
			this.externalRelationships.add(externalRelationship);
		}

		public void resolveRecordRelationships() {
			this.resolveRelationships();
			this.resolveExternalRelationships();
		}

		private void resolveRelationships() {
			for (ParentRelationship parentRelationship : this.parentRelationships) {
				parentRelationship.resolve(this.currentRecord);
			}
		}

		private void resolveExternalRelationships() {
			for (ExternalRelationship externalRelationship : this.externalRelationships) {
				externalRelationship.resolve(this.currentRecord);
			}
		}

		public SObjectType getSObjectType() {
			return this.currentRecord?.getSObjectType();
		}

		public Boolean doesRecordHaveIdSpecified() {
			return String.isNotBlank(this.getRecordId());
		}

		public SObject getRecord() {
			return this.currentRecord;
		}

		public Id getRecordId() {
			return this.currentRecord?.Id;
		}
	}

	private class ParentRelationship {
		private SObject relatedToRecord;
		private SObjectField relationshipField;

		public ParentRelationship(SObjectField relationshipField, SObject relatedToRecord) {
			this.validateRelationshipField(relationshipField);

			this.relationshipField = relationshipField;
			this.relatedToRecord = relatedToRecord;
		}

		public void resolve(SObject currentRecord) {
			currentRecord.put(this.relationshipField, this.relatedToRecord.Id);
		}

		private void validateRelationshipField(SObjectField relationshipField) {            
			if (String.isBlank(relationshipField.getDescribe().getRelationshipName())) {
				throw new DmlException('Invalid argument: relationshipField. Field supplied is not a relationship field.');
			}
		}
	}

	private class ExternalRelationship { 
		public SObjectField relationshipField;
		public SObjectField externalIdField;
		public SObjectType relatedToType;
		public Object relatedRecordExternalId;

		public ExternalRelationship(SObjectField relationshipField, SObjectField relatedObjectExternalIdField, Object relatedRecordExternalId) {
			this.validateRelatedToField(relationshipField);
			this.validateExternalIdField(relationshipField, relatedObjectExternalIdField);

			this.relationshipField = relationshipField;
			this.relatedToType = relationshipField.getDescribe().getReferenceTo()[0];
			this.externalIdField = relatedObjectExternalIdField;
			this.relatedRecordExternalId = relatedRecordExternalId;
		}  

		public void resolve(SObject currentRecord) {
			SObject relationshipObject = this.relatedToType.newSObject();
			relationshipObject.put(this.externalIdField.getDescribe().getName(), this.relatedRecordExternalId);

			currentRecord.putSObject(this.relationshipField.getDescribe().getRelationshipName(), relationshipObject);
		}

		private void validateRelatedToField(SObjectField relationshipField) {
			if (String.isBlank(relationshipField.getDescribe().getRelationshipName())) {
				throw new DmlException('Invalid argument: relationshipField. Field supplied is not a relationship field.');
			}
		}

		private void validateExternalIdField(SObjectField relationshipField, SObjectField externalIdField) {
			Boolean externalIdFieldIsValid = externalIdField.getDescribe().isExternalId();
	
			if (!externalIdFieldIsValid) {
				throw new DmlException('Invalid argument: externalIdField. Field supplied is not a marked as an External Identifier.');
			}
	
			SObjectType relatedObjectType = relationshipField.getDescribe().getReferenceTo()[0];
			String externalIdFieldName = externalIdField.getDescribe().getName();
	
			Boolean relatedHasExternalIdField = relatedObjectType.getDescribe().fields.getMap().keySet().contains(externalIdFieldName.toLowerCase());
	
			if (!relatedHasExternalIdField) {
				throw new DmlException('Invalid argument: externalIdField. Field supplied is not a known field on the target sObject.');
			}
		}
	}
}