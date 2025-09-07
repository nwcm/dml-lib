/**
 * Copyright (c) 2025 Beyond The Cloud Sp. z o.o. (BeyondTheCloud.Dev)
 * Licensed under the MIT License (https://github.com/beyond-the-cloud-dev/dml-lib/blob/main/LICENSE)
 *
 * PMD False Positives:
**/
public inherited sharing class DML implements Commitable {
    public static Record Record(Id recordId) {
        return new DmlRecord(recordId);
    }

    public static Record Record(SObject record) {
        return new DmlRecord(record);
    }

    public static Records Records(List<SObject> records) { // to process multiple records at once
        return new DmlRecords(records);
    }

    public static Records Records(Iterable<Id> recordIds) {
        return new DmlRecords(recordIds);
    }

    // public interface InsertOptions {
    //     InsertOptions stripNotCreatableFields();
    // }

    // public interface UpdateOptions {

    // }

    // public interface UpsertOptions {

    // }

    // public interface DeleteOptions {

    // }

    public interface Commitable {
        // Insert
        Commitable toInsert(SObject record);
        Commitable toInsert(DML.Record record);
        Commitable toInsert(Iterable<SObject> records);
        Commitable toInsert(DML.Records records);
        // Update
        Commitable toUpdate(SObject record);
        Commitable toUpdate(DML.Record record);
        Commitable toUpdate(Iterable<SObject> records);
        Commitable toUpdate(DML.Records records);
        // Upsert
        Commitable toUpsert(SObject record);
        Commitable toUpsert(DML.Record record);
        Commitable toUpsert(Iterable<SObject> records);
        Commitable toUpsert(DML.Records records);
        // Commitable toUpsert(SObject record, SObjectField externalIdField);
        // Delete
        Commitable toDelete(Id recordId);
        Commitable toDelete(SObject record);
        Commitable toDelete(Iterable<Id> recordIds);
        Commitable toDelete(List<SObject> records);
        // option makeHardDelete(); TODO
        // Undelete
        Commitable toUndelete(Id recordId);
        Commitable toUndelete(SObject record);
        Commitable toUndelete(Iterable<Id> recordIds);
        Commitable toUndelete(List<SObject> records);
        // Merge
        Commitable toMerge(SObject mergeToRecord, Id duplicateId);
        Commitable toMerge(SObject mergeToRecord, SObject duplicateRecord);
        Commitable toMerge(SObject mergeToRecord, List<SObject> duplicateRecords);
        Commitable toMerge(SObject mergeToRecord, Iterable<Id> duplicateIds);
        // Platform Event
        Commitable toPublish(SObject record);
        Commitable toPublish(Iterable<SObject> records);
        // Debug
        void preview();
        // Field Level Security
        Commitable userMode();
        Commitable systemMode();
        Commitable stripNotCreatableFields(); // TODO: This applies only to insert, doesn't make sense to have it global    
        Commitable stripNotUpdatableFields(); // TODO: This applies only to update, doesn't make sense to have it global
        // Sharing Mode
        Commitable withSharing();
        Commitable withoutSharing();
        // Other configs
        Commitable allowPartialSuccess();
        Commitable skipDuplicateRules();
        Commitable options(Database.DmlOptions options);
        // Commitable executionOrder(List<SObjectType> executionOrder);
        Commitable commitHook(DML.Hook callback);
        // Save
        // void dryRun();
        void commitWork();
    }
    
    public interface Record {
        // Record with(SObjectField field, Object value); TODO 
        Record withRelationship(SObjectField targetField, SObject relatedRecord);
        Record withRelationship(SObjectField targetField, SObjectField externalIdField, Object externalId);
        
        // for internal use only
        EnhancedRecord get();
    }

    public interface Records {
        // Records with(SObjectField field, Object value); TODO
        Records withRelationship(SObjectField targetField, SObject relatedRecord);
        Records withRelationship(SObjectField targetField, SObjectField externalIdField, Object externalId);
        
        // for internal use only
        List<Record> get();
    }

    // public class Result {
    //     Boolean isSuccess();

    // }

    public interface Hook {
        void before();
        void after();
    }

    // Mocking

    @TestVisible
    private static void mock(String dmlMockId) {
        // TODO
    }

    // Implementation

    private final DmlOperation insertCommand = new InsertOperation();
    private final DmlOperation updateCommand = new UpdateOperation();
    private final DmlOperation upsertCommand = new UpsertOperation();
    private final DmlOperation mergeCommand = new MergeOperation();
    private final DmlOperation deleteCommand = new DeleteOperation();
    private final DmlOperation undeleteCommand = new UndeleteOperation();
    private final DmlOperation publishCommand = new PlatformEventOperation();

    private DML.Hook hook = null;

    // Insert

    public Commitable toInsert(SObject record) {
        return this.toInsert(DML.Record(record));
    }

    public Commitable toInsert(DML.Record record) {
        if (record.get().isRecordAlreadyExists()) {
            throw new DmlException('Only new records can be registered as new.');
        }

        this.insertCommand.register(record);

        return this;
    }

    public Commitable toInsert(Iterable<SObject> records) {
        return this.toInsert(DML.Records(records));
    }
    
    public Commitable toInsert(DML.Records records) {
        for (DML.Record record : records.get()) {
            this.toInsert(record);
        }

        return this;
    }

    // Update
    
    public Commitable toUpdate(SObject record) {
        return this.toUpdate(DML.Record(record));
    }

    public Commitable toUpdate(DML.Record record) {
        if (!record.get().isRecordAlreadyExists()) {
            throw new DmlException('Only existing records can be updated.');
        }

        this.updateCommand.register(record);

        return this;
    }

    public Commitable toUpdate(Iterable<SObject> records) {
        return this.toUpdate(DML.Records(records));
    }

    public Commitable toUpdate(DML.Records records) {
        for (DML.Record record : records.get()) {
            this.toUpdate(record);
        }
        
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

    public Commitable toUpsert(Iterable<SObject> records) {
        return this.toUpsert(DML.Records(records));
    }

    public Commitable toUpsert(DML.Records records) {
        for (DML.Record record : records.get()) {
            this.toUpsert(record);
        }
        
        return this;
    }

    // Delete

    public Commitable toDelete(Id recordId) {
        if (String.isBlank(recordId)) {
            throw new DmlException('Only existing records can be registered as deleted.');
        }

        this.deleteCommand.register(DML.Record(recordId));

        return this;
    }

    public Commitable toDelete(SObject record) {
        return this.toDelete(record.Id);
    }

    public Commitable toDelete(Iterable<Id> recordIds) {
        for (Id recordId : recordIds) {
            this.toDelete(recordId);
        }
        
        return this;
    }

    public Commitable toDelete(List<SObject> records) {
        return this.toDelete(new Map<Id, SObject>(records).keySet());
    }

    // Undelete

    public Commitable toUndelete(Id recordId) {
        if (String.isBlank(recordId)) {
            throw new DmlException('Only existing records can be registered as undeleted.');
        }

        this.undeleteCommand.register(DML.Record(recordId));

        return this;
    }

    public Commitable toUndelete(SObject record) {
        return this.toUndelete(record.Id);
    }

    public Commitable toUndelete(Iterable<Id> recordIds) {
        for (Id recordId : recordIds) {
            this.toUndelete(recordId);
        }
        
        return this;
    }

    public Commitable toUndelete(List<SObject> records) {
        return this.toUndelete(new Map<Id, SObject>(records).keySet());
    }

    // Merge

    public Commitable toMerge(SObject mergeToRecord, Id duplicateId) {
        return this;
    }

    public Commitable toMerge(SObject mergeToRecord, SObject duplicateRecord) {
        return this;
    }

    public Commitable toMerge(SObject mergeToRecord, List<SObject> duplicateRecords) {
        return this;
    }

    public Commitable toMerge(SObject mergeToRecord, Iterable<Id> duplicateIds) {
        return this;
    }
    
    // Platform Event

    public Commitable toPublish(SObject record) {
        this.publishCommand.register(DML.Record(record));
        return this;
    }

    public Commitable toPublish(Iterable<SObject> records) {
        for (SObject record : records) {
            this.toPublish(record);
        }

        return this;
    }

    // Debug

    public void preview() {
        this.insertCommand.preview();
        this.updateCommand.preview();
        this.upsertCommand.preview();
        this.mergeCommand.preview();
        this.deleteCommand.preview();
        this.undeleteCommand.preview(); 
        this.publishCommand.preview();
    }

    // Field Level Security

    public Commitable userMode() {
        this.insertCommand.userMode();
        this.updateCommand.userMode();
        this.upsertCommand.userMode();
        this.mergeCommand.userMode();
        this.deleteCommand.userMode();
        this.undeleteCommand.userMode();
        this.publishCommand.userMode();
        return this;
    }

    public Commitable systemMode() {
        this.insertCommand.systemMode();
        this.updateCommand.systemMode();
        this.upsertCommand.systemMode();
        this.mergeCommand.systemMode();
        this.deleteCommand.systemMode();
        this.undeleteCommand.systemMode();
        this.publishCommand.systemMode();
        return this;
    }

    public Commitable stripNotCreatableFields() {
        return this.stripInaccessible(AccessType.CREATABLE);
    }

    public Commitable stripNotUpdatableFields() {
        return this.stripInaccessible(AccessType.UPDATABLE);
    }

    public Commitable stripInaccessible(System.AccessType accessType) { // TODO: CREATABLE/UPDATABLE - it doesn't have sense to have it global
        this.insertCommand.stripInaccessible(accessType);
        this.updateCommand.stripInaccessible(accessType);
        this.upsertCommand.stripInaccessible(accessType);
        return this;
    }

    // Sharing Mode

    public Commitable withSharing() {
        this.insertCommand.withSharing();
        this.updateCommand.withSharing();
        this.upsertCommand.withSharing();
        this.mergeCommand.withSharing();
        this.deleteCommand.withSharing();
        this.undeleteCommand.withSharing();
        this.publishCommand.withSharing();
        return this;
    }

    public Commitable withoutSharing() {
        this.insertCommand.withoutSharing();
        this.updateCommand.withoutSharing();
        this.upsertCommand.withoutSharing();
        this.mergeCommand.withoutSharing();
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
        this.mergeCommand.allowPartialSuccess();
        this.deleteCommand.allowPartialSuccess();
        this.undeleteCommand.allowPartialSuccess();
        return this;
    }

    public Commitable skipDuplicateRules() {
        this.insertCommand.skipDuplicateRules();
        this.updateCommand.skipDuplicateRules();
        this.upsertCommand.skipDuplicateRules();
        this.mergeCommand.skipDuplicateRules();
        this.undeleteCommand.skipDuplicateRules();
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

    public void commitWork() {
        Savepoint savePoint = Database.setSavepoint();

        try {
            this.hook?.before();

            // if (isMockingModeEnabled) {
            //     this.insertCommand.mockCommitWork();
            //     this.updateCommand.mockCommitWork();
            //     this.upsertCommand.mockCommitWork();
            //     this.mergeCommand.mockCommitWork();
            //     this.deleteCommand.mockCommitWork();
            //     this.undeleteCommand.mockCommitWork();
            //     this.publishCommand.mockCommitWork();
            // }

            this.insertCommand.commitWork();
            this.upsertCommand.commitWork();
            this.updateCommand.commitWork();
            this.mergeCommand.commitWork();
            this.deleteCommand.commitWork();
            this.undeleteCommand.commitWork();
            this.publishCommand.commitWork();

            this.hook?.after();
        } catch (Exception e) {
            Database.rollback(savePoint);
            throw e;
        } finally {
            Database.releaseSavepoint(savePoint);
        }
    }

    public abstract class DmlOperation {
        protected Map<String, RecordsContainer> recordsProcessContainerByType = new Map<String, RecordsContainer>();
        protected System.AccessLevel accessMode = System.AccessLevel.USER_MODE;
        protected System.AccessType accessType = null;
        protected DmlSharing sharingExecutor = new InheritedSharing();
        protected Boolean allOrNone = true;
        protected Database.DmlOptions options = new Database.DMLOptions();

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

        public void register(Record record) {
            EnhancedRecord enhancedRecord = record.get();

            String typeName = enhancedRecord.getSObjectType();

            if (!this.recordsProcessContainerByType.containsKey(typeName)) {
                this.recordsProcessContainerByType.put(typeName, new RecordsContainer());
            }

            this.recordsProcessContainerByType.get(typeName).addNewRecordToProcess(enhancedRecord);
        }

        public void preview() {
            System.debug(LoggingLevel.ERROR, '\n\n============ DML Preview ============\n' + JSON.serializePretty(this.recordsProcessContainerByType) + '\n=======================================\n');
        }

        public void commitWork() {
            this.sharingExecutor.execute(this);
        }

        public abstract void execute();
        // public abstract void executeMock();
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
        public override void execute() {
            for (String objectTypeName : this.recordsProcessContainerByType.keySet()) { //TODO Move loop to parent class
                Database.insert(this.recordsProcessContainerByType.get(objectTypeName).getRecordsToProcess(this.accessType), this.options, this.accessMode);
            }
        }
    }

    public inherited sharing class UpdateOperation extends DmlOperation {
        public override void execute() {
            for (String objectTypeName : this.recordsProcessContainerByType.keySet()) {
                Database.update(this.recordsProcessContainerByType.get(objectTypeName).getRecordsToProcess(this.accessType), this.options, this.accessMode);
            }
        }
    }

    public inherited sharing class UpsertOperation extends DmlOperation {
        public override void execute() {
            for (String objectTypeName : this.recordsProcessContainerByType.keySet()) {
                Database.upsert(this.recordsProcessContainerByType.get(objectTypeName).getRecordsToProcess(this.accessType), this.allOrNone, this.accessMode);
            }
        }
    }

    public inherited sharing class MergeOperation extends DmlOperation {
        public override void execute() {
            for (String objectTypeName : this.recordsProcessContainerByType.keySet()) {
                // Database.merge(mergeToRecord, duplicateIds, this.allOrNone, this.accessMode);
            }
        }
    }

    public inherited sharing class DeleteOperation extends DmlOperation {
        public override void execute() {
            for (String objectTypeName : this.recordsProcessContainerByType.keySet()) {
                Database.delete(this.recordsProcessContainerByType.get(objectTypeName).getRecordIdsToProcess(), this.allOrNone, this.accessMode);
            }
        }
    }

    public inherited sharing class UndeleteOperation extends DmlOperation {
        public override void execute() {
            for (String objectTypeName : this.recordsProcessContainerByType.keySet()) {
                Database.undelete(this.recordsProcessContainerByType.get(objectTypeName).getRecordIdsToProcess(), this.allOrNone, this.accessMode);
            }
        }
    }

    public inherited sharing class PlatformEventOperation extends DmlOperation {
        public override void execute() {
            List<SObject> events = new List<SObject>();

            for (String objectTypeName : this.recordsProcessContainerByType.keySet()) {
                events.addAll(this.recordsProcessContainerByType.get(objectTypeName).getRecordsToProcess(this.accessType));
            }

            EventBus.publish(events);
        }
    }

    private interface DmlSharing {
        void execute(DmlOperation executor);
    }

    private inherited sharing class InheritedSharing implements DmlSharing {
        public void execute(DmlOperation executor) {
            executor.execute();
        }
    }

    private without sharing class WithoutSharing implements DmlSharing {
        public void execute(DmlOperation executor) {
            executor.execute();
        }
    }

    private with sharing class WithSharing implements DmlSharing {
        public void execute(DmlOperation executor) {
            executor.execute();
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

        public DmlRecord withRelationship(SObjectField relationshipField, SObject relatedToRecord) {
            this.enhancedRecord.withRelationship(relationshipField, relatedToRecord);
            return this;
        }

        public DmlRecord withRelationship(SObjectField relationshipField, SObjectField externalIdField, Object externalId) {
            this.enhancedRecord.withExternalRelationship(relationshipField, externalIdField, externalId);
            return this;
        }

        public EnhancedRecord get() {
            return this.enhancedRecord;
        }
    }

    private class DmlRecords implements Records {
        private List<DML.Record> enhancedRecords = new List<DML.Record>();

        public DmlRecords(Iterable<SObject> records) {
            for (SObject record : records) {
                this.enhancedRecords.add(DML.Record(record));
            }
        }

        public DmlRecords withRelationship(SObjectField relationshipField, SObject relatedToRecord) {
            for (DML.Record dmlRecord : this.enhancedRecords) {
                dmlRecord.withRelationship(relationshipField, relatedToRecord);
            }

            return this;
        }

        public DmlRecords withRelationship(SObjectField relationshipField, SObjectField externalIdField, Object externalId) {
            for (DML.Record dmlRecord : this.enhancedRecords) {
                dmlRecord.withRelationship(relationshipField, externalIdField, externalId);
            }

            return this;
        }

        public List<DML.Record> get() {
            return this.enhancedRecords;
        }
    }

    private class EnhancedRecord {
        private Id currentRecordId;
        private SObject currentRecord;
        private List<ParentRelationship> parentRelationships = new List<ParentRelationship>();
        private List<ExternalRelationship> externalRelationships = new List<ExternalRelationship>();

        public EnhancedRecord(SObject currentRecord) {
            this.currentRecord = currentRecord;
            this.currentRecordId = currentRecord.Id;
        }

        public EnhancedRecord(Id currentRecordId) {
            this.currentRecordId = currentRecordId;
        }

        public void withRelationship(SObjectField relationshipField, SObject relatedToRecord) {
            this.parentRelationships.add(new ParentRelationship(relationshipField, relatedToRecord));
        }

        public void withExternalRelationship(SObjectField relationshipField, SObjectField externalIdField, Object externalId) {
            this.externalRelationships.add(new ExternalRelationship(relationshipField, externalIdField, externalId));
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

        public String getSObjectType() {
            return this.currentRecord?.getSObjectType()?.toString() ?? this.currentRecordId.getSObjectType().toString();
        }

        public Boolean isRecordAlreadyExists() {
            return String.isNotBlank(this.currentRecord.Id);
        }

        public SObject getRecord() {
            return this.currentRecord;
        }

        public Id getRecordId() {
            return this.currentRecordId;
        }
    }

    private class ParentRelationship {
        private SObject relatedToRecord;
        private SObjectField relationshipField;

        public ParentRelationship(SObjectField relationshipField, SObject relatedToRecord) {
            this.relationshipField = relationshipField;
            this.relatedToRecord = relatedToRecord;
        }

        public void resolve(SObject currentRecord) {
            if (this.relationshipField == null || this.relatedToRecord == null) {
                return;
            }
            currentRecord.put(this.relationshipField, this.relatedToRecord.Id);
        }
    }

    private class ExternalRelationship { 
        public SObjectField relatedToField;
        public SObjectField externalIdField;
        public SObjectType relatedTo;
        public String relationshipName;
        public Object externalId;

        public ExternalRelationship(SObjectField relatedToField, SObjectField externalIdField, Object externalId) {
            this.validateRelatedToField(relatedToField);
            this.validateExternalIdField(relatedToField, externalIdField);

            this.relatedToField = relatedToField;
            this.externalIdField = externalIdField;
            this.externalId = externalId;
        }  

        public void resolve(SObject currentRecord) {
            SObject relationshipObject = this.relatedTo.newSObject();
            relationshipObject.put(this.externalIdField.getDescribe().getName(), this.externalId);

            currentRecord.putSObject(this.relationshipName, relationshipObject);
        }

        private void validateRelatedToField(SObjectField relatedToField) {
            if (relatedToField == null) {
                throw new DmlException('Invalid argument: relatedToField.');
            }
    
            String relationshipName = relatedToField.getDescribe().getRelationshipName();
    
            if (String.isBlank(relationshipName)) {
                throw new DmlException('Invalid argument: relatedToField. Field supplied is not a relationship field.');
            }
        }

        private void validateExternalIdField(SObjectField relatedToField, SObjectField externalIdField) {
            Boolean externalIdFieldIsValid = externalIdField.getDescribe().isExternalId();
    
            if (!externalIdFieldIsValid) {
                throw new UnitOfWorkException('Invalid argument: externalIdField. Field supplied is not a marked as an External Identifier.');
            }
    
            List<SObjectType> relatedObjects = relatedToField.getDescribe().getReferenceTo();
            SObjectType relatedObject = relatedObjects[0];
            String externalIdFieldName = externalIdField.getDescribe().getName();
    
            Boolean relatedHasExternalIdField = relatedObject.getDescribe().fields.getMap().keySet().contains(externalIdFieldName.toLowerCase());
    
            if (!relatedHasExternalIdField) {
                throw new DmlException('Invalid argument: externalIdField. Field supplied is not a known field on the target sObject.');
            }
        }
    }
}

/*
new DML()
    .toInsert(record)
    .toUpdate(record2)
    .systemMode()
    .withoutSharing()
    .commitWork();
*/