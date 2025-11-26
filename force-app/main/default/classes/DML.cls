/**
 * Copyright (c) 2025 Beyond The Cloud Sp. z o.o. (BeyondTheCloud.Dev)
 * Licensed under the MIT License (https://github.com/beyond-the-cloud-dev/dml-lib/blob/main/LICENSE)
 *
 * v1.7.0
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
		// Immediate Insert
		OperationResult insertImmediately(SObject record);
		OperationResult insertImmediately(DML.Record record);
		OperationResult insertImmediately(List<SObject> records);
		OperationResult insertImmediately(DML.Records records);
		// Immediate Update
		OperationResult updateImmediately(SObject record);
		OperationResult updateImmediately(DML.Record record);
		OperationResult updateImmediately(List<SObject> records);
		OperationResult updateImmediately(DML.Records records);
		// Immediate Upsert
		OperationResult upsertImmediately(SObject record);
		OperationResult upsertImmediately(DML.Record record);
		OperationResult upsertImmediately(List<SObject> records);
		OperationResult upsertImmediately(DML.Records records);
		// Immediate Delete
		OperationResult deleteImmediately(Id recordId);
		OperationResult deleteImmediately(SObject record);
		OperationResult deleteImmediately(Iterable<Id> recordIds);
		OperationResult deleteImmediately(List<SObject> records);
		// Immediate Undelete
		OperationResult undeleteImmediately(Id recordId);
		OperationResult undeleteImmediately(SObject record);
		OperationResult undeleteImmediately(Iterable<Id> recordIds);
		OperationResult undeleteImmediately(List<SObject> records);
		// Immediate Publish
		OperationResult publishImmediately(SObject record);
		OperationResult publishImmediately(List<SObject> records);
		// Mocking
		Commitable identifier(String dmlIdentifier); // used for mocking and tracking results
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
		// Commitable throwExceptionWhenFailure();
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
		Boolean isSuccess();
		List<Error> getErrors();
	}

	public interface Error {
		String getMessage();
		System.StatusCode getStatusCode();
		List<String> getFields();
	}

	// Mockking

	@TestVisible
	private static Mockable whenDmlIdentifier(String dmlIdentifier) {
		if (!DML.dmlIdentifierToMock.containsKey(dmlIdentifier)) {
			DML.dmlIdentifierToMock.put(dmlIdentifier, new DmlMock());
		}
		return DML.dmlIdentifierToMock.get(dmlIdentifier);
	}

	@TestVisible
	private static Result getMockResulfForDml(String dmlIdentifier) {
		if (!DML.dmlIdentifierToResult.containsKey(dmlIdentifier)) {
			throw new DmlException('No result found for dml identifier: ' + dmlIdentifier);
		}
		return DML.dmlIdentifierToResult.get(dmlIdentifier);
	}

	public interface Mockable {
		Mockable thenMockAllDmls();
		// Per Operation
		Mockable thenMockAllInserts();
		Mockable thenMockAllUpdates();
		Mockable thenMockAllUpserts();
		Mockable thenMockAllDeletes();
		Mockable thenMockAllUndelete();
		Mockable thenMockAllPublishes();
		// Per Object Type
		Mockable thenMockInsertFor(SObjectType objectType);
		Mockable thenMockUpdateFor(SObjectType objectType);
		Mockable thenMockUpsertFor(SObjectType objectType);
		Mockable thenMockDeleteFor(SObjectType objectType);
		Mockable thenMockUndeletFor(SObjectType objectType);
		Mockable thenMockPublishFor(SObjectType objectType);
	}

	// Hooks

	public interface Hook {
		void before();
		void after();
	}

	// Implementation

	private Configuration configuration = new Configuration();

	private DmlOperation insertCommand = new InsertOperation(this.configuration);
	private DmlOperation updateCommand = new UpdateOperation(this.configuration);
	private DmlOperation upsertCommand = new UpsertOperation(this.configuration);
	private DmlOperation deleteCommand = new DeleteOperation(this.configuration);
	private DmlOperation undeleteCommand = new UndeleteOperation(this.configuration);
	private DmlOperation publishCommand = new PlatformEventOperation(this.configuration);

	public enum Type { INSERT_DML, UPDATE_DML, UPSERT_DML, DELETE_DML, UNDELETE_DML, HARD_DELETE_DML, MERGE_DML, PUBLISH_DML }

	private DML.Hook hook = null;

	@TestVisible
	private static final RandomIdGenerator randomIdGenerator = new RandomIdGenerator();
	private static final Map<String, Result> dmlIdentifierToResult = new Map<String, Result>();
	private static final Map<String, DmlMock> dmlIdentifierToMock = new Map<String, DmlMock>();

	public DML() {} // default constructor

	public DML(List<SObjectType> customExecutionOrder) {
		this.configuration.executionOrder(customExecutionOrder);
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

	public OperationResult insertImmediately(SObject record) {
		return this.insertImmediately(DML.Record(record));
	}

	public OperationResult insertImmediately(DML.Record record) {
		return new InsertOperation(this.configuration).register(record).commitWork().get(0);
	}

	public OperationResult insertImmediately(List<SObject> records) {
		return this.insertImmediately(DML.Records(records));
	}

	public OperationResult insertImmediately(DML.Records records) {
		return new InsertOperation(this.configuration).register(records).commitWork().get(0);
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

	public OperationResult updateImmediately(SObject record) {
		return this.updateImmediately(DML.Record(record));
	}

	public OperationResult updateImmediately(DML.Record record) {
		return new UpdateOperation(this.configuration).register(record).commitWork().get(0);
	}

	public OperationResult updateImmediately(List<SObject> records) {
		return this.updateImmediately(DML.Records(records));
	}

	public OperationResult updateImmediately(DML.Records records) {
		return new UpdateOperation(this.configuration).register(records).commitWork().get(0);
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

	public OperationResult upsertImmediately(SObject record) {
		return this.upsertImmediately(DML.Record(record));
	}

	public OperationResult upsertImmediately(DML.Record record) {
		return new UpsertOperation(this.configuration).register(record).commitWork().get(0);
	}

	public OperationResult upsertImmediately(List<SObject> records) {
		return this.upsertImmediately(DML.Records(records));
	}

	public OperationResult upsertImmediately(DML.Records records) {
		return new UpsertOperation(this.configuration).register(records).commitWork().get(0);
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

	public OperationResult deleteImmediately(Id recordId) {
		return new DeleteOperation(this.configuration).register(DML.Record(recordId)).commitWork().get(0);
	}

	public OperationResult deleteImmediately(SObject record) {
		return this.deleteImmediately(record.Id);
	}

	public OperationResult deleteImmediately(Iterable<Id> recordIds) {
		return new DeleteOperation(this.configuration).register(DML.Records(recordIds)).commitWork().get(0);
	}

	public OperationResult deleteImmediately(List<SObject> records) {
		return new DeleteOperation(this.configuration).register(DML.Records(records)).commitWork().get(0);
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

	public OperationResult undeleteImmediately(Id recordId) {
		return new UndeleteOperation(this.configuration).register(DML.Record(recordId)).commitWork().get(0);
	}

	public OperationResult undeleteImmediately(SObject record) {
		return this.undeleteImmediately(record.Id);
	}

	public OperationResult undeleteImmediately(Iterable<Id> recordIds) {
		return new UndeleteOperation(this.configuration).register(DML.Records(recordIds)).commitWork().get(0);
	}

	public OperationResult undeleteImmediately(List<SObject> records) {
		return new UndeleteOperation(this.configuration).register(DML.Records(records)).commitWork().get(0);
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

	public OperationResult publishImmediately(SObject record) {
		return new PlatformEventOperation(this.configuration).register(DML.Record(record)).commitWork().get(0);
	}

	public OperationResult publishImmediately(List<SObject> records) {
		return new PlatformEventOperation(this.configuration).register(DML.Records(records)).commitWork().get(0);
	}

	// Identifier

	public Commitable identifier(String dmlIdentifier) {
		this.configuration.identifier(dmlIdentifier);
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
		this.configuration.userMode();
		return this;
	}

	public Commitable systemMode() {
		this.configuration.systemMode();
		return this;
	}

	// Sharing Mode

	public Commitable withSharing() {
		this.configuration.withSharing();
		return this;
	}

	public Commitable withoutSharing() {
		this.configuration.withoutSharing();
		return this;
	}

	// Other configs

	public Commitable allowPartialSuccess() {
		this.configuration.allowPartialSuccess();
		return this;
	}

	public Commitable options(Database.DmlOptions options) {
		this.configuration.options(options);
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

			DML.dmlIdentifierToResult.put(this.configuration.dmlIdentifier, result);

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
		this.insertCommand = new InsertOperation(this.configuration);
		this.updateCommand = new UpdateOperation(this.configuration);
		this.upsertCommand = new UpsertOperation(this.configuration);
		this.deleteCommand = new DeleteOperation(this.configuration);
		this.undeleteCommand = new UndeleteOperation(this.configuration);
		this.publishCommand = new PlatformEventOperation(this.configuration);
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
			return this.getOperationResult(Type.INSERT_DML, objectType);
		}

		public OperationResult updated(SObjectType objectType) {
			return this.getOperationResult(Type.UPDATE_DML, objectType);
		}

		public OperationResult upserted(SObjectType objectType) {
			return this.getOperationResult(Type.UPSERT_DML, objectType);
		}

		public OperationResult deleted(SObjectType objectType) {
			return this.getOperationResult(Type.DELETE_DML, objectType);
		}

		public OperationResult undeleted(SObjectType objectType) {
			return this.getOperationResult(Type.UNDELETE_DML, objectType);
		}

		public OperationResult published(SObjectType objectType) {
			return this.getOperationResult(Type.PUBLISH_DML, objectType);
		}

		private List<OperationResult> getOperationResults(Type operationType) {
			List<OperationResult> operationResults = new List<OperationResult>();

			for (SObjectType objectType : this.operationResultsByObjectType.get(operationType).keySet()) {
				operationResults.add(this.operationResultsByObjectType.get(operationType).get(objectType));
			}

			return operationResults;
		}

		private OperationResult getOperationResult(Type operationType, SObjectType objectType) {
			return this.operationResultsByObjectType.get(operationType).get(objectType) ?? new OperationSummary(objectType, operationType);
		}

		public List<OperationResult> all() {
			List<OperationResult> allResults = new List<OperationResult>();

			for (Type operationType : this.operationResultsByObjectType.keySet()) {
				allResults.addAll(this.operationResultsByObjectType.get(operationType).values());
			}

			return allResults;
		}
	}

	private class Configuration {
		private List<SObjectType> customExecutionOrder = new List<SObjectType>();
		private System.AccessLevel accessMode = System.AccessLevel.USER_MODE;
		private System.AccessType accessType = null;
		private Database.DmlOptions options = new Database.DMLOptions();
		private DmlSharing sharingExecutor = new InheritedSharing();
		private Boolean allOrNone = true;
		private String dmlIdentifier = null;

		public Configuration() {
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
			this.customExecutionOrder = customExecutionOrder;
		}

		public void identifier(String dmlIdentifier) {
			this.dmlIdentifier = dmlIdentifier;
		}

		public void allowPartialSuccess() {
			this.allOrNone = false;
			this.options.optAllOrNone = false;
		}

		public void options(Database.DmlOptions options) {
			this.options = options;
			this.options.optAllOrNone = this.options.optAllOrNone ?? this.allOrNone ?? true;
		}

		public void skipDuplicateRules() {
			this.options.duplicateRuleHeader.allowSave = true;
		}
	}

	public abstract class DmlOperation {
		protected Map<SObjectType, RecordsContainer> recordsProcessContainerByType = new Map<SObjectType, RecordsContainer>();
		protected Configuration globalConfiguration;

		public DmlOperation(Configuration configuration) {
			this.globalConfiguration = configuration;
		}

		public DmlOperation register(DML.Records records) {
			for (DML.Record record : records.get()) {
				this.register(record);
			}

			return this;
		}

		public DmlOperation register(DML.Record record) {
			this.validate(record);
			
			EnhancedRecord enhancedRecord = record.get();
			SObjectType typeName = enhancedRecord.getSObjectType();

			if (!this.globalConfiguration.customExecutionOrder.isEmpty() && !this.globalConfiguration.customExecutionOrder.contains(typeName)) {
				throw new DmlException('Only the following types can be registered: ' + this.globalConfiguration.customExecutionOrder);
			}

			this.addNewRecordToProcess(typeName, enhancedRecord);
			return this;
		}

		private void addNewRecordToProcess(SObjectType typeName, EnhancedRecord enhancedRecord) {
			if (!this.recordsProcessContainerByType.containsKey(typeName)) {
				this.recordsProcessContainerByType.put(typeName, new RecordsContainer());
			}

			this.recordsProcessContainerByType.get(typeName).addNewRecordToProcess(enhancedRecord);
		}

		public void preview() {
			System.debug(LoggingLevel.ERROR, '\n\n============ DML Preview ============\n' + JSON.serializePretty(this.recordsProcessContainerByType) + '\n=======================================\n');
		}

		public List<OperationResult> commitWork() {
			return this.globalConfiguration.sharingExecutor.execute(this);
		}

		public List<OperationResult> execute() {
			if (!this.globalConfiguration.customExecutionOrder.isEmpty()) {
				return this.processBasedOnCustomOrder();
			} 

			return this.processBasedOnRegistrationOrder();
		}

		private List<OperationResult> processBasedOnCustomOrder() {
			return this.process(this.globalConfiguration.customExecutionOrder);
		}

		private List<OperationResult> processBasedOnRegistrationOrder() {
			return this.process(this.recordsProcessContainerByType.keySet());
		}

		private List<OperationResult> process(Iterable<SObjectType> objectTypesOrder) {
			List<OperationResult> operationResults = new List<OperationResult>();

			for (SObjectType objectTypeName : objectTypesOrder) {
				if (!this.recordsProcessContainerByType.containsKey(objectTypeName)) {
					continue;
				}

				List<SObject> recordsToProcess = this.recordsProcessContainerByType.get(objectTypeName).getRecordsToProcess(this.globalConfiguration.accessType);

				DmlMock dmlMock = DML.dmlIdentifierToMock.get(this.globalConfiguration.dmlIdentifier);

				List<RecordResult> recordResults;

				if (dmlMock == null || !dmlMock.shouldBeMocked(this.getType(), objectTypeName)) {
					recordResults = this.executeDml(recordsToProcess);
				} else {
					recordResults = this.getMockedRecordResults(recordsToProcess);
				}
				
				operationResults.add(new OperationSummary(objectTypeName, this.getType()).setRecords(recordsToProcess).setRecordResults(recordResults));
			}

			return operationResults;
		}

		private List<RecordResult> getMockedRecordResults(List<SObject> recordsToProcess) {
			List<RecordResult> recordResults = new List<RecordResult>();

			for (SObject record : recordsToProcess) {
				recordResults.add(this.prepareMockedDml(record));
			}

			return recordResults;
		}

		public abstract Type getType();
		public abstract List<RecordResult> executeDml(List<SObject> recordsToProcess);
		public abstract RecordResult prepareMockedDml(SObject record);

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

			return System.Security.stripInaccessible(accessType, recordsToProcess).getRecords();
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
		public InsertOperation(Configuration configuration) {
			super(configuration);
		}

		public override Type getType() {
			return Type.INSERT_DML;
		}

		public override void validate(DML.Record record) {
			if (record.get().doesRecordHaveIdSpecified()) {
				throw new DmlException('Only new records can be registered as new.');
			}
		}

		public override List<RecordResult> executeDml(List<SObject> recordsToProcess) {
			List<Database.SaveResult> saveResults = Database.insert(recordsToProcess, this.globalConfiguration.options, this.globalConfiguration.accessMode);
			return new SaveResultAdapter(saveResults).transform();
		}

		public override RecordResult prepareMockedDml(SObject record) {
			record.put('Id', DML.randomIdGenerator.get(record.getSObjectType()));
			return new RecordSummary().isSuccess(true).recordId(record.Id);
		}
	}

	public inherited sharing class UpdateOperation extends DmlOperation {
		public UpdateOperation(Configuration configuration) {
			super(configuration);
		}

		public override Type getType() {
			return Type.UPDATE_DML;
		}

		public override void validate(DML.Record record) {
			if (!record.get().doesRecordHaveIdSpecified()) {
				throw new DmlException('Only existing records can be updated.');
			}
		}

		public override List<RecordResult> executeDml(List<SObject> recordsToProcess) {
			List<Database.SaveResult> saveResults = Database.update(recordsToProcess, this.globalConfiguration.options, this.globalConfiguration.accessMode);
			return new SaveResultAdapter(saveResults).transform();
		}

		public override RecordResult prepareMockedDml(SObject record) {
			return new RecordSummary().isSuccess(true).recordId(record.Id);
		}
	}

	public inherited sharing class UpsertOperation extends DmlOperation {
		public UpsertOperation(Configuration configuration) {
			super(configuration);
		}

		public override Type getType() {
			return Type.UPSERT_DML;
		}

		public override List<RecordResult> executeDml(List<SObject> recordsToProcess) {
			List<Database.UpsertResult> upsertResults = Database.upsert(recordsToProcess, this.globalConfiguration.allOrNone, this.globalConfiguration.accessMode);
			return new UpsertResultAdapter(upsertResults).transform();
		}

		public override RecordResult prepareMockedDml(SObject record) {
			if (record.Id == null) {
				record.put('Id', DML.randomIdGenerator.get(record.getSObjectType()));
			}
			return new RecordSummary().isSuccess(true).recordId(record.Id);
		}
	}

	public inherited sharing class DeleteOperation extends DmlOperation {
		public DeleteOperation(Configuration configuration) {
			super(configuration);
		}

		public override Type getType() {
			return Type.DELETE_DML;
		}

		public override void validate(DML.Record record) {
			if (!record.get().doesRecordHaveIdSpecified()) {
				throw new DmlException('Only existing records can be registered as deleted.');
			}
		}

		public override List<RecordResult> executeDml(List<SObject> recordsToProcess) {
			List<Database.DeleteResult> deleteResults = Database.delete(recordsToProcess, this.globalConfiguration.allOrNone, this.globalConfiguration.accessMode);
			return new DeleteResultAdapter(deleteResults).transform();
		}

		public override RecordResult prepareMockedDml(SObject record) {
			return new RecordSummary().isSuccess(true).recordId(record.Id);
		}
	}

	public inherited sharing class UndeleteOperation extends DmlOperation {
		public UndeleteOperation(Configuration configuration) {
			super(configuration);
		}

		public override Type getType() {
			return Type.UNDELETE_DML;
		}

		public override void validate(DML.Record record) {
			if (!record.get().doesRecordHaveIdSpecified()) {
				throw new DmlException('Only deleted records can be undeleted.');
			}
		}

		public override List<RecordResult> executeDml(List<SObject> recordsToProcess) {
			List<Database.UndeleteResult> undeleteResults = Database.undelete(recordsToProcess, this.globalConfiguration.allOrNone, this.globalConfiguration.accessMode);
			return new UndeleteResultAdapter(undeleteResults).transform();
		}

		public override RecordResult prepareMockedDml(SObject record) {
			return new RecordSummary().isSuccess(true).recordId(record.Id);
		}
	}

	public inherited sharing class PlatformEventOperation extends DmlOperation {
		public PlatformEventOperation(Configuration configuration) {
			super(configuration);
		}

		public override Type getType() {
			return Type.PUBLISH_DML;
		}

		public override List<RecordResult> executeDml(List<SObject> recordsToProcess) {
			List<Database.SaveResult> saveResults = EventBus.publish(recordsToProcess);
			return new SaveResultAdapter(saveResults).transform();
		}

		public override RecordResult prepareMockedDml(SObject record) {
			return new RecordSummary().isSuccess(true).recordId(DML.randomIdGenerator.get(record.getSObjectType()));
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

	private class DmlMock implements Mockable {
		private Set<Type> mockedDmlTypes = new Set<Type>();
		private Map<Type, Set<SObjectType>> mockedObjectTypesByDmlType = new Map<Type, Set<SObjectType>>{
			Type.INSERT_DML => new Set<SObjectType>(),
			Type.UPDATE_DML => new Set<SObjectType>(),
			Type.UPSERT_DML => new Set<SObjectType>(),
			Type.DELETE_DML => new Set<SObjectType>(),
			Type.UNDELETE_DML => new Set<SObjectType>(),
			Type.PUBLISH_DML => new Set<SObjectType>()
		};

		public Mockable thenMockAllDmls() {
			this.thenMockAllInserts();
			this.thenMockAllUpdates();
			this.thenMockAllUpserts();
			this.thenMockAllDeletes();
			this.thenMockAllUndelete();
			this.thenMockAllPublishes();
			return this;
		}
		
		public Mockable thenMockAllInserts() {
			return this.thenMockDml(Type.INSERT_DML);
		}

		public Mockable thenMockAllUpdates() {
			return this.thenMockDml(Type.UPDATE_DML);
		}

		public Mockable thenMockAllUpserts() {
			return this.thenMockDml(Type.UPSERT_DML);
		}

		public Mockable thenMockAllDeletes() {
			return this.thenMockDml(Type.DELETE_DML);
		}

		public Mockable thenMockAllUndelete() {
			return this.thenMockDml(Type.UNDELETE_DML);
		}

		public Mockable thenMockAllPublishes() {
			return this.thenMockDml(Type.PUBLISH_DML);
		}

		private Mockable thenMockDml(Type dmlType) {
			this.mockedDmlTypes.add(dmlType);
			return this;
		}

		public Mockable thenMockInsertFor(SObjectType objectType) {
			return this.thenMockDmlFor(Type.INSERT_DML, objectType);
		}

		public Mockable thenMockUpdateFor(SObjectType objectType) {
			return this.thenMockDmlFor(Type.UPDATE_DML, objectType);
		}

		public Mockable thenMockUpsertFor(SObjectType objectType) {
			return this.thenMockDmlFor(Type.UPSERT_DML, objectType);
		}

		public Mockable thenMockDeleteFor(SObjectType objectType) {
			return this.thenMockDmlFor(Type.DELETE_DML, objectType);
		}

		public Mockable thenMockUndeletFor(SObjectType objectType) {
			return this.thenMockDmlFor(Type.UNDELETE_DML, objectType);
		}

		public Mockable thenMockPublishFor(SObjectType objectType) {
			return this.thenMockDmlFor(Type.PUBLISH_DML, objectType);
		}

		private Mockable thenMockDmlFor(Type dmlType, SObjectType objectType) {
			this.mockedObjectTypesByDmlType.get(dmlType).add(objectType);
			return this;
		}

		public Boolean shouldBeMocked(Type dmlType, SObjectType objectType) {
			return this.mockedDmlTypes.contains(dmlType) || this.mockedObjectTypesByDmlType.get(dmlType).contains(objectType);
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

	public class RandomIdGenerator {
		private final String RANDOM_STRING_CHARACTERS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';

		public Id get(SObjectType objectType) {
			return get(objectType.getDescribe().getKeyPrefix());
		}

		public Id get(String prefix) {
			String randomPart = '';

			while (randomPart.length() < 8) {
				Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), RANDOM_STRING_CHARACTERS.length());
				randomPart += RANDOM_STRING_CHARACTERS.substring(idx, idx + 1);
			}

			return Id.valueOf(prefix + '0000' + randomPart);
		}
	}
}