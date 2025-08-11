/**
 * Copyright (c) 2025 Beyond The Cloud Sp. z o.o. (BeyondTheCloud.Dev)
 * Licensed under the MIT License (https://github.com/beyond-the-cloud-dev/dml-lib/blob/main/LICENSE)
 *
 * PMD False Positives:
**/
public inherited sharing class DML implements Commitable {
    public static Record Record(SObject record) {
        return new DmlRecord(record);
    }

    public static Records records(Iterable<SObject> records) { // to process multiple records at once
        return new DmlRecords(records);
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
        // Upsert
        Commitable toUpsert(SObject record);
        Commitable toUpsert(DML.Record record);
        Commitable toUpsert(List<SObject> records);
        // Commitable toUpsert(SObject record, Schema.SObjectField externalIdField);
        // Delete
        Commitable toDelete(SObject record);
        Commitable toDelete(List<SObject> recordssObjs);
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
        // Partial Success
        Commitable allowPartialSuccess();
        // Commitable dmlOptions(Database.DmlOptions options);
        // Save
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
        List<EnhancedRecord> get();
    }

    // Implementation

    private DmlExecutor insertUow = new InsertUow();
    private DmlExecutor updateUow = new UpdateUow();
    private DmlExecutor deleteUow = new DeleteUow();
    private DmlExecutor platformEventUow = new PlatformEventUow();

    public Commitable userMode() {
        this.insertUow.userMode();
        this.updateUow.userMode();
        this.deleteUow.userMode();
        this.platformEventUow.userMode();
        return this;
    }

    public Commitable systemMode() {
        this.insertUow.systemMode();
        this.updateUow.systemMode();
        this.deleteUow.systemMode();
        this.platformEventUow.systemMode();
        return this;
    }

    public Commitable withSharing() {
        this.insertUow.withSharing();
        this.updateUow.withSharing();
        this.deleteUow.withSharing();
        this.platformEventUow.withSharing();
        return this;
    }

    public Commitable withoutSharing() {
        this.insertUow.withoutSharing();
        this.updateUow.withoutSharing();
        this.deleteUow.withoutSharing();
        this.platformEventUow.withoutSharing();
        return this;
    }

    public Commitable allowPartialSuccess() {
        this.insertUow.allowPartialSuccess();
        this.updateUow.allowPartialSuccess();
        this.deleteUow.allowPartialSuccess();
        this.platformEventUow.allowPartialSuccess();
        return this;
    }

    public Commitable toInsert(SObject record) {
        return this.toInsert(DML.Record(record));
    }

    public Commitable toInsert(List<SObject> records) {
        for (SObject record : records) {
            this.toInsert(record);
        }
        
        return this;
    }

    public Commitable toInsert(DML.Record record) {
        if (record.get().isRecordAlreadyExists()) {
            throw new DmlException('Only new records can be registered as new.');
        }

        this.insertUow.register(record);
        return this;
    }

    public Commitable toInsert(DML.Records records) {
        // for (DML.Record record : records.get()) {
        //     this.toInsert(record);
        // }
        return this;
    }

    public Commitable toUpdate(SObject record) {
        return this.toUpdate(DML.Record(record));
    }

    public Commitable toUpdate(Iterable<SObject> records) {
        for (SObject record : records) {
            this.toUpdate(record);
        }
        
        return this;
    }

    public Commitable toUpdate(DML.Record record) {
        if (!record.get().isRecordAlreadyExists()) {
            throw new DmlException('Only existing records can be updated.');
        }

        this.updateUow.register(record);
        return this;
    }

    public Commitable toUpsert(SObject record) {
        return this.toUpsert(DML.Record(record));
    }

    public Commitable toUpsert(Iterable<SObject> records) {
        for (SObject record : records) {
            this.toUpsert(record);
        }

        return this;
    }

    public Commitable toUpsert(DML.Record record) {
        if (record.get().isRecordAlreadyExists()) {
            return this.toUpdate(record);
        }
        
        return this.toInsert(record);
    }

    public Commitable toDelete(SObject record) {
        if (String.isBlank(record.Id)) {
            throw new DmlException('Only existing records can be registered as deleted.');
        }

        this.deleteUow.register(DML.Record(record));

        return this;
    }

    public Commitable toDelete(Iterable<SObject> records) {
        for (SObject record : records) {
            this.toDelete(record);
        }
        
        return this;
    }

    public Commitable toPublish(SObject record) {
        this.platformEventUow.register(DML.Record(record));
        return this;
    }

    public Commitable toPublish(List<SObject> records) {
        for (sObject record : records) {
            this.toPublish(record);
        }

        return this;
    }

    public void preview() {
        this.insertUow.preview();
        this.updateUow.preview();
        this.deleteUow.preview();
        this.platformEventUow.preview();
    }

    public void commitWork() {
        Savepoint savePoint = Database.setSavepoint();

        try {
            this.insertUow.commitWork();
            this.updateUow.commitWork();
            this.deleteUow.commitWork();
            this.platformEventUow.commitWork();
        } catch (Exception e) {
            Database.rollback(savePoint);
            throw e;
        }
    }

    public abstract class DmlExecutor {
        private DmlSharing sharingExecutor = new InheritedSharing();

        protected Map<String, RecordsContainer> recordsProcessContainerByType = new Map<String, RecordsContainer>();
        protected AccessLevel accessMode = AccessLevel.USER_MODE;
        protected Boolean allOrNone = true;

        public DmlExecutor userMode() {
            this.accessMode = AccessLevel.USER_MODE;
            return this;
        }

        public DmlExecutor systemMode() {
            this.accessMode = AccessLevel.SYSTEM_MODE;
            return this;
        }

        public DmlExecutor allowPartialSuccess() {
            this.allOrNone = false;
            return this;
        }

        public DmlExecutor withSharing() {
            this.sharingExecutor = new WithSharing();
            return this;
        }

        public DmlExecutor withoutSharing() {
            this.sharingExecutor = new WithoutSharing();
            return this;
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
    }

    public inherited sharing class InsertUow extends DmlExecutor {
        public override void execute() {
            for (String objectTypeName : this.recordsProcessContainerByType.keySet()) { //TODO Move loop to parent class
                Database.insert(this.recordsProcessContainerByType.get(objectTypeName).getRecordsToProcess(), this.allOrNone, this.accessMode);
            }
        }
    }

    public inherited sharing class UpdateUow extends DmlExecutor {
        public override void execute() {
            for (String objectTypeName : this.recordsProcessContainerByType.keySet()) {
                Database.update(this.recordsProcessContainerByType.get(objectTypeName).getRecordsToProcess(), this.allOrNone, this.accessMode);
            }
        }
    }

    public inherited sharing class DeleteUow extends DmlExecutor {
        public override void execute() {
            for (String objectTypeName : this.recordsProcessContainerByType.keySet()) {
                Database.delete(this.recordsProcessContainerByType.get(objectTypeName).getRecordsToProcess(), this.allOrNone, this.accessMode);
            }
        }
    }

    public inherited sharing class PlatformEventUow extends DmlExecutor {
        public override void execute() {
            List<SObject> events = new List<SObject>();

            for (String objectTypeName : this.recordsProcessContainerByType.keySet()) {
                events.addAll(this.recordsProcessContainerByType.get(objectTypeName).getRecordsToProcess());
            }

            EventBus.publish(events);
        }
    }

    private interface DmlSharing {
        void execute(DmlExecutor executor);
    }

    private inherited sharing class InheritedSharing implements DmlSharing {
        public void execute(DmlExecutor executor) {
            executor.execute();
        }
    }

    private without sharing class WithoutSharing implements DmlSharing {
        public void execute(DmlExecutor executor) {
            executor.execute();
        }
    }

    private with sharing class WithSharing implements DmlSharing {
        public void execute(DmlExecutor executor) {
            executor.execute();
        }
    }

    private class DmlRecord implements Record {
        private EnhancedRecord unitOfWork;

        public DmlRecord(SObject record) {
            this.unitOfWork = new EnhancedRecord(record);
        }

        public DmlRecord withRelationship(SObjectField relationshipField, SObject relatedToRecord) {
            this.unitOfWork.withRelationship(relationshipField, relatedToRecord);
            return this;
        }

        public DmlRecord withRelationship(SObjectField relationshipField, SObjectField externalIdField, Object externalId) {
            this.unitOfWork.withExternalRelationship(relationshipField, externalIdField, externalId);
            return this;
        }

        public EnhancedRecord get() {
            return this.unitOfWork;
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

        public List<EnhancedRecord> get() {
            List<EnhancedRecord> enhancedRecords = new List<EnhancedRecord>();

            for (DML.Record dmlRecord : this.enhancedRecords) {
                enhancedRecords.add(dmlRecord.get());
            }

            return enhancedRecords;
        }
    }

    private class EnhancedRecord {
        private SObject currentRecord;
        private List<ParentRelationship> parentRelationships = new List<ParentRelationship>();
        private List<ExternalRelationship> externalRelationships = new List<ExternalRelationship>();

        public EnhancedRecord(SObject currentRecord) {
            this.currentRecord = currentRecord;
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
            return this.currentRecord.getSObjectType().toString();
        }

        public Boolean isRecordAlreadyExists() {
            return String.isNotBlank(this.currentRecord.Id);
        }

        public SObject getRecord() {
            return this.currentRecord;
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

    private class RecordsContainer {
        private List<EnhancedRecord> enhancedRecords = new List<EnhancedRecord>();

        public void addNewRecordToProcess(EnhancedRecord enhancedRecord) {
            this.enhancedRecords.add(enhancedRecord);
        }

        public List<SObject> getRecordsToProcess() { 
            List<SObject> recordsToProcess = new List<SObject>();

            for (EnhancedRecord enhancedRecord : this.enhancedRecords) {
                enhancedRecord.resolveRecordRelationships();
                recordsToProcess.add(enhancedRecord.getRecord());
            }

            return recordsToProcess;
        }
    }
}