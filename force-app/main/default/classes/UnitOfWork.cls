public inherited sharing class UnitOfWork implements DmlCommitable {
    public interface DmlCommitable {
        // Settings
        UnitOfWork systemMode();
        UnitOfWork withSharing();
        UnitOfWork withoutSharing();
        UnitOfWork allowPartialSuccess();
        // Insert
        UnitOfWork registerNew(SObject record);
        UnitOfWork registerNew(Iterable<SObject> records);
        // Update
        UnitOfWork registerDirty(SObject record);
        UnitOfWork registerDirty(Iterable<SObject> records);
        // Relationship
        UnitOfWork registerRelationship(SObject targetRecord, SObjectField targetField, SObject relatedRecord);
        UnitOfWork registerRelationship(SObject targetRecord, SObjectField targetField, SObjectField externalIdField, Object externalId);
        // Upsert
        UnitOfWork registerUpsert(SObject record);
        UnitOfWork registerUpsert(Iterable<SObject> records);
        // Delete
        UnitOfWork registerDelete(SObject record);
        UnitOfWork registerDelete(Iterable<SObject> recordssObjs);
        // Platform Event
        UnitOfWork registerPlatformEvent(SObject record);
        UnitOfWork registerPlatformEvent(List<SObject> records);
        // Save
        void commitWork();
    }

    // Implementation

    private DmlExecutor insertUow = new InsertUow();
    private DmlExecutor updateUow = new UpdateUow();
    private DmlExecutor deleteUow = new DeleteUow();
    private DmlExecutor platformEventUow = new PlatformEventUow();

    public UnitOfWork systemMode() {
        this.insertUow.withoutSharing();
        this.updateUow.withoutSharing();
        this.deleteUow.withoutSharing();
        this.platformEventUow.withoutSharing();
        return this;
    }

    public UnitOfWork withSharing() {
        this.insertUow.withSharing();
        this.updateUow.withSharing();
        this.deleteUow.withSharing();
        this.platformEventUow.withSharing();
        return this;
    }

    public UnitOfWork withoutSharing() {
        this.insertUow.withoutSharing();
        this.updateUow.withoutSharing();
        this.deleteUow.withoutSharing();
        this.platformEventUow.withoutSharing();
        return this;
    }

    public UnitOfWork allowPartialSuccess() {
        this.insertUow.allowPartialSuccess();
        this.updateUow.allowPartialSuccess();
        this.deleteUow.allowPartialSuccess();
        this.platformEventUow.allowPartialSuccess();
        return this;
    }

    public UnitOfWork registerNew(SObject record) {
        if (String.isNotBlank(record.Id)) {
            throw new DmlException('Only new records can be registered as new.');
        }

        this.insertUow.register(new PlainSObjectUow(record));

        return this;
    }

    public UnitOfWork registerNew(Iterable<SObject> records) {
        for (SObject record : records) {
            this.registerNew(record);
        }
        
        return this;
    }

    public UnitOfWork registerDirty(SObject record) {
        if (String.isBlank(record.Id)) {
            throw new DmlException('Only existing records can be registered as dirty');
        }

        this.updateUow.register(new PlainSObjectUow(record));

        return this;
    }

    public UnitOfWork registerDirty(Iterable<SObject> records) {
        for (SObject record : records) {
            this.registerDirty(record);
        }
        
        return this;
    }

    public UnitOfWork registerRelationship(SObject targetRecord, SObjectField targetField, SObject relatedRecord) {
        return this;
    }

    public UnitOfWork registerRelationship(SObject targetRecord, SObjectField targetField, SObjectField externalIdField, Object externalId) {
        return this;
    }

    public UnitOfWork registerUpsert(SObject record) {
        if (String.isBlank(record.Id)) {
            return this.registerNew(record);
        }

        return this.registerDirty(record);
    }

    public UnitOfWork registerUpsert(Iterable<SObject> records) {
        for (SObject record : records) {
            this.registerUpsert(record);
        }

        return this;
    }

    public UnitOfWork registerDelete(SObject record) {
        if (String.isBlank(record.Id)) {
            throw new DmlException('Only existing records can be registered as deleted.');
        }

        this.deleteUow.register(new PlainSObjectUow(record));

        return this;
    }

    public UnitOfWork registerDelete(Iterable<SObject> records) {
        for (SObject record : records) {
            this.registerDelete(record);
        }
        
        return this;
    }

    public UnitOfWork registerPlatformEvent(SObject record) {
        this.platformEventUow.register(new PlainSObjectUow(record));
        return this;
    }

    public UnitOfWork registerPlatformEvent(List<SObject> records) {
        for (sObject record : records) {
            this.registerPlatformEvent(record);
        }

        return this;
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
            
        }

        public abstract void execute();
    }

    public inherited sharing class InsertUow extends DmlExecutor {
        public override void execute() {
            for (String sObjectTypeName : recordsByType.keySet()) {
                recordsByType.get(sObjectTypeName).resolve();
                Database.insert(recordsByType.get(sObjectTypeName).getRecords(), this.allOrNone, this.accessMode);
            }
        }
    }

    public inherited sharing class UpdateUow extends DmlExecutor {
        public override void execute() {

        }
    }

    public inherited sharing class DeleteUow extends DmlExecutor {
        public override void execute() {
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
        public SObject record;

        public virtual void resolve() {}
        public abstract SObject getRecord();
    }

    private inherited sharing class PlainSObjectUow extends SObjectUow {
        private SObject currentRecord;

        public PlainSObjectUow(SObject currentRecord) {
            this.currentRecord = currentRecord;
        }

        public override SObject getRecord() {
            return this.currentRecord;
        }
    }

    private inherited sharing class ExternalSObjectUow extends SObjectUow {
        private SObject currentRecord;
        private SObjectField relationshipField;
        private SObjectField externalIdField;
        private Object externalId;

        public ExternalSObjectUow(SObject record, SObjectField relatedToField, Schema.SObjectField externalIdField, Object externalId) {
            this.record = record;
        }

        public override SObject getRecord() {
            return this.record;
        }
    }

    private inherited sharing class RelationshipSObjectUow extends SObjectUow {
        private SObject currentRecord;
        private SObject relatedRecord;
        private SObjectField relationshipField;

        public RelationshipSObjectUow(SObject currentRecord, SObjectField relationshipField, SObject relatedRecord) {
            this.currentRecord = currentRecord;
            this.relatedRecord = relatedRecord;
            this.relationshipField = relationshipField;
        }

        public override void resolve() {
            // this.currentRecord.put(this.relationshipField, this.relatedTo.Id);
        }

        public override SObject getRecord() {
            return this.currentRecord;
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

    /*
     UnitOfWork uow = new UnitOfWork();
     uow.registerNew(new Account(Name='Test Account'));
     uow.registerNew(new Account(Name='Test Account 2'));
     uow.commitWork();

     uow.registerRelationship(new Account(Name='Test Account'))
        .withRelationshipField(...)
        .withExternalIdField(...)
        .withRelatedRecord(new Account(Name='Test Account 2'));

    uow.registerRelationship(new Account(Name='Test Account'), Account.RelationshipField__c, new Account(Name='Test Account 2'));

    uow.registerRelationship(
        UOW.Relationship.of(new Account(Name='Test Account'))
            .withRelationshipField(...)
            .withExternalIdField(...)
            .withRelatedRecord(new Account(Name='Test Account 2'))
    )

    */