/**
 * Copyright (c) 2025 Beyond The Cloud Sp. z o.o. (BeyondTheCloud.Dev)
 * Licensed under the MIT License (https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/LICENSE)
 *
 * PMD False Positives:
**/
public inherited sharing class DML implements Commitable {
    public static Record Record(SObject record) {
        return new DmlRecord(record);
    }

    public interface Commitable {
        // Settings
        Commitable systemMode();
        Commitable withSharing();
        Commitable withoutSharing();
        Commitable allowPartialSuccess();
        // Insert
        Commitable toInsert(SObject record);
        Commitable toInsert(List<SObject> records);
        Commitable toInsert(DML.Record record);
        Commitable toInsert(List<DML.Record> records);
        // Update
        Commitable toUpdate(SObject record);
        Commitable toUpdate(Iterable<SObject> records);
        // Upsert
        Commitable toUpsert(SObject record);
        Commitable toUpsert(Iterable<SObject> records);
        // Delete
        Commitable toDelete(SObject record);
        Commitable toDelete(Iterable<SObject> recordssObjs);
        // Platform Event
        Commitable toPublish(SObject record);
        Commitable toPublish(List<SObject> records);
        // Debug
        void preview();
        // Save
        void commitWork();
    }
    
    public interface Record {
        Record withRelationship(SObjectField targetField, SObject relatedRecord);
    }

    // Implementation

    private DmlExecutor insertUow = new InsertUow();
    private DmlExecutor updateUow = new UpdateUow();
    private DmlExecutor deleteUow = new DeleteUow();
    private DmlExecutor platformEventUow = new PlatformEventUow();

    public Commitable systemMode() {
        this.insertUow.withoutSharing();
        this.updateUow.withoutSharing();
        this.deleteUow.withoutSharing();
        this.platformEventUow.withoutSharing();
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
        if (String.isNotBlank(record.Id)) {
            throw new DmlException('Only new records can be registered as new.');
        }

        this.insertUow.register(new PlainSObjectUow(record));

        return this;
    }

    public Commitable toInsert(List<SObject> records) {
        for (SObject record : records) {
            this.toInsert(record);
        }
        
        return this;
    }

    public Commitable toInsert(DML.Record record) {
        // this.insertUow.register(new PlainSObjectUow(record.getRecord()));
        return this;
    }

    public Commitable toInsert(List<DML.Record> records) {
        for (DML.Record record : records) {
            this.toInsert(record);
        }
        
        return this;
    }

    public Commitable toUpdate(SObject record) {
        if (String.isBlank(record.Id)) {
            throw new DmlException('Only existing records can be registered as dirty.');
        }

        this.updateUow.register(new PlainSObjectUow(record));

        return this;
    }

    public Commitable toUpdate(Iterable<SObject> records) {
        for (SObject record : records) {
            this.toUpdate(record);
        }
        
        return this;
    }

    public Commitable toInsert(SObject targetRecord, SObjectField targetField, SObject relatedRecord) {
        this.insertUow.register(new RelationshipSObjectUow(targetRecord, targetField, relatedRecord));
        return this;
    }

    public Commitable registerRelationship(SObject targetRecord, SObjectField targetField, SObjectField externalIdField, Object externalId) {
        // TODO
        return this;
    }

    public Commitable toUpsert(SObject record) {
        if (String.isBlank(record.Id)) {
            return this.toInsert(record);
        }

        return this.toUpdate(record);
    }

    public Commitable toUpsert(Iterable<SObject> records) {
        for (SObject record : records) {
            this.toUpsert(record);
        }

        return this;
    }

    public Commitable toDelete(SObject record) {
        if (String.isBlank(record.Id)) {
            throw new DmlException('Only existing records can be registered as deleted.');
        }

        this.deleteUow.register(new PlainSObjectUow(record));

        return this;
    }

    public Commitable toDelete(Iterable<SObject> records) {
        for (SObject record : records) {
            this.toDelete(record);
        }
        
        return this;
    }

    public Commitable toPublish(SObject record) {
        this.platformEventUow.register(new PlainSObjectUow(record));
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
            this.insertUow.execute();
            this.updateUow.execute();
            this.deleteUow.execute();
            this.platformEventUow.execute();
        } catch (Exception e) {
            Database.rollback(savePoint);
            throw e;
        }
    }

    public abstract class DmlExecutor {
        protected Map<String, ObjectTypeContainer> recordsByType = new Map<String, ObjectTypeContainer>();
        protected AccessLevel accessMode = AccessLevel.USER_MODE;
        protected Boolean allOrNone = true;

        private DmlSharing sharingExecutor = new InheritedSharing();

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

        public void register(SObjectUow uow) {
            String sObjectType = uow.getRecord().getSObjectType().getDescribe().getName();

            ObjectTypeContainer recordsToProcess = this.recordsByType.containsKey(sObjectType) ? this.recordsByType.get(sObjectType) : new ObjectTypeContainer();

            recordsToProcess.add(uow);

            this.recordsByType.put(sObjectType, recordsToProcess);
        }

        public void preview() {
            System.debug(JSON.serializePretty(this.recordsByType));
        }

        public abstract void execute();
    }

    public inherited sharing class InsertUow extends DmlExecutor {
        public override void execute() {
            for (String sObjectTypeName : this.recordsByType.keySet()) {
                this.recordsByType.get(sObjectTypeName).resolve();
                Database.insert(this.recordsByType.get(sObjectTypeName).getRecords(), this.allOrNone, this.accessMode);
            }
        }
    }

    public inherited sharing class UpdateUow extends DmlExecutor {
        public override void execute() {
            for (String sObjectTypeName : this.recordsByType.keySet()) {
                this.recordsByType.get(sObjectTypeName).resolve();
                Database.update(this.recordsByType.get(sObjectTypeName).getRecords(), this.allOrNone, this.accessMode);
            }
        }
    }

    public inherited sharing class DeleteUow extends DmlExecutor {
        public override void execute() {
            for (String sObjectTypeName : this.recordsByType.keySet()) {
                Database.delete(this.recordsByType.get(sObjectTypeName).getRecords(), this.allOrNone, this.accessMode);
            }
        }
    }

    public inherited sharing class PlatformEventUow extends DmlExecutor {
        public override void execute() {
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

    private abstract class SObjectUow {
        public SObject currentRecord;

        public virtual void resolve() {}
        public abstract SObject getRecord();
    }

    private inherited sharing class PlainSObjectUow extends SObjectUow {
        public PlainSObjectUow(SObject currentRecord) {
            this.currentRecord = currentRecord;
        }

        public override SObject getRecord() {
            return this.currentRecord;
        }
    }

    private inherited sharing class ExternalSObjectUow extends SObjectUow {
        public SObjectField relatedToField;
        public SObjectField externalIdField;
        public SObjectType relatedTo;
        public String relationshipName;
        public Object externalId;

        public ExternalSObjectUow(SObject record, SObjectField relatedToField, SObjectField externalIdField, Object externalId) {
            this.validateRelatedToField(relatedToField);
            this.validateExternalIdField(relatedToField, externalIdField);

            this.currentRecord = record;
            this.relatedToField = relatedToField;
            this.externalIdField = externalIdField;
            this.externalId = externalId;
        }

        public override void resolve() {
            SObject relationshipObject = this.relatedTo.newSObject();
            relationshipObject.put(externalIdField.getDescribe().getName(), this.externalId);

            this.currentRecord.putSObject(this.relationshipName, relationshipObject);
        }

        public override SObject getRecord() {
            return this.currentRecord;
        }

        private void validateRelatedToField(SObjectField relatedToField) {
            if (relatedToField == null) {
                // throw new UnitOfWorkException('Invalid argument: relatedToField.');
            }
    
            String relationshipName = relatedToField.getDescribe().getRelationshipName();
    
            if (String.isBlank(relationshipName)) {
                // throw new UnitOfWorkException('Invalid argument: relatedToField. Field supplied is not a relationship field.');
            }
        }

        private void validateExternalIdField(SObjectField relatedToField, SObjectField externalIdField) {
            Boolean externalIdFieldIsValid = externalIdField.getDescribe().isExternalId();
    
            if (!externalIdFieldIsValid) {
                // throw new UnitOfWorkException('Invalid argument: externalIdField. Field supplied is not a marked as an External Identifier.');
            }
    
            List<SObjectType> relatedObjects = relatedToField.getDescribe().getReferenceTo();
            SObjectType relatedObject = relatedObjects[0];
            String externalIdFieldName = externalIdField.getDescribe().getName();
    
            Boolean relatedHasExternalIdField = relatedObject.getDescribe().fields.getMap().keySet().contains(externalIdFieldName.toLowerCase());
    
            if (!relatedHasExternalIdField) {
                // throw new UnitOfWorkException('Invalid argument: externalIdField. Field supplied is not a known field on the target sObject.');
            }
        }
    }

    private inherited sharing class RelationshipSObjectUow extends SObjectUow {
        private SObject relatedToRecord;
        private SObjectField relationshipField;

        public RelationshipSObjectUow(SObject currentRecord, SObjectField relationshipField, SObject relatedToRecord) {
            this.currentRecord = currentRecord;
            this.relatedToRecord = relatedToRecord;
            this.relationshipField = relationshipField;
        }

        public override void resolve() {
            if (this.relationshipField == null || this.relatedToRecord == null) {
                return;
            }
            this.currentRecord.put(this.relationshipField, this.relatedToRecord.Id);
        }

        public override SObject getRecord() {
            return this.currentRecord;
        }
    }

    private class DmlRecord implements Record {
        private SObject record;

        public DmlRecord(SObject record) {
            this.record = record;
        }

        public DmlRecord withRelationship(SObjectField targetField, SObject relatedRecord) {    
            // this.record.put(targetField, relatedRecord.Id);
            return this;
        }

        public SObject getRecord() {
            return this.record;
        }
    }

    private class ObjectTypeContainer {
        private List<SObjectUow> sObjectsWithRelationships;

        public ObjectTypeContainer() {
            this.sObjectsWithRelationships = new List<SObjectUow>();
        }

        public void add(SObjectUow sObjectWithRelationship) {
            this.sObjectsWithRelationships.add(sObjectWithRelationship);
        }

        public void resolve() {
            for (SObjectUow sObjectWithRelationship : this.sObjectsWithRelationships) {
                sObjectWithRelationship.resolve();
            }
        }

        public List<SObject> getRecords() {
            List<SObject> recordsToProcess = new List<SObject>();

            for (SObjectUow sObjectWithRelationship : this.sObjectsWithRelationships) {
                recordsToProcess.add(sObjectWithRelationship.getRecord());
            }

            return recordsToProcess;
        }
    }
}