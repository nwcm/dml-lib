public inherited sharing class UnitOfWorkService implements UnitOfWork.DmlCommitable {

    // Custom exception
    public class DmlException extends Exception {}

    // Maps to hold records for DML operations
    private Map<SObjectType, List<SObject>> workToInsert = new Map<SObjectType, List<SObject>>();
    private Map<SObjectType, List<SObject>> workToUpdate = new Map<SObjectType, List<SObject>>();
    private Map<SObjectType, List<SObject>> workToDelete = new Map<SObjectType, List<SObject>>();
    private List<RelationshipSObjectUow> relationships = new List<RelationshipSObjectUow>();
    private List<ExternalSObjectUow> externalRelationships = new List<ExternalSObjectUow>();

    // DML Executors
    private DmlExecutor insertUow = new InsertUow(this);
    private DmlExecutor updateUow = new UpdateUow(this);
    private DmlExecutor deleteUow = new DeleteUow(this);
    private DmlExecutor platformEventUow = new PlatformEventUow(this);

    // Sharing settings
    public UnitOfWork systemMode() {
        DmlSharing runner = new WithoutSharing();
        this.insertUow.sharingExecutor = runner;
        this.updateUow.sharingExecutor = runner;
        this.deleteUow.sharingExecutor = runner;
        return this;
    }

    public UnitOfWork withSharing() {
        DmlSharing runner = new WithSharing();
        this.insertUow.sharingExecutor = runner;
        this.updateUow.sharingExecutor = runner;
        this.deleteUow.sharingExecutor = runner;
        return this;
    }

    public UnitOfWork withoutSharing() {
        return this.systemMode();
    }

    // Register methods
    public UnitOfWork registerNew(SObject record) {
        if (record == null) return this;
        if (String.isNotBlank(record.Id)) {
            throw new DmlException('Only new records can be registered as new.');
        }
        SObjectType sObjectType = record.getSObjectType();
        if (!workToInsert.containsKey(sObjectType)) {
            workToInsert.put(sObjectType, new List<SObject>());
        }
        workToInsert.get(sObjectType).add(record);
        return this;
    }

    public UnitOfWork registerNew(Iterable<SObject> records) {
        if(records == null) return this;
        for (SObject record : records) {
            this.registerNew(record);
        }
        return this;
    }

    public UnitOfWork registerDirty(SObject record) {
        if (record == null) return this;
        if (String.isBlank(record.Id)) {
            throw new DmlException('Only existing records can be registered as dirty.');
        }
        SObjectType sObjectType = record.getSObjectType();
        if (!workToUpdate.containsKey(sObjectType)) {
            workToUpdate.put(sObjectType, new List<SObject>());
        }
        
        if (!workToUpdate.get(sObjectType).contains(record)) {
             workToUpdate.get(sObjectType).add(record);
        }
        return this;
    }

    public UnitOfWork registerDirty(Iterable<SObject> records) {
        if(records == null) return this;
        for (SObject record : records) {
            this.registerDirty(record);
        }
        return this;
    }

    public UnitOfWork registerUpsert(SObject record) {
        if (String.isBlank(record.Id)) {
            return this.registerNew(record);
        }
        return this.registerDirty(record);
    }

    public UnitOfWork registerUpsert(Iterable<SObject> records) {
        if(records == null) return this;
        for (SObject record : records) {
            this.registerUpsert(record);
        }
        return this;
    }

    public UnitOfWork registerDelete(SObject record) {
        if (record == null) return this;
        if (String.isBlank(record.Id)) {
            throw new DmlException('Only existing records can be registered as deleted.');
        }
        SObjectType sObjectType = record.getSObjectType();
        if (!workToDelete.containsKey(sObjectType)) {
            workToDelete.put(sObjectType, new List<SObject>());
        }
        workToDelete.get(sObjectType).add(record);
        return this;
    }

    public UnitOfWork registerDelete(Iterable<SObject> records) {
        if(records == null) return this;
        for (SObject record : records) {
            this.registerDelete(record);
        }
        return this;
    }

    // Relationship methods
    public UnitOfWork registerRelationship(SObject targetRecord, SObjectField targetField, SObject relatedRecord) {
        if (targetRecord == null || relatedRecord == null || targetField == null) return this;
    
        registerUpsert(targetRecord);
        registerUpsert(relatedRecord);
    
        this.relationships.add(new RelationshipSObjectUow(targetRecord, targetField, relatedRecord));
        return this;
    }

    public UnitOfWork registerRelationship(SObject targetRecord, SObjectField targetField, SObjectField externalIdField, Object externalId) {
        if (targetRecord == null || externalId == null || targetField == null || externalIdField == null) return this;

        registerUpsert(targetRecord);
    
        this.externalRelationships.add(new ExternalSObjectUow(targetRecord, targetField, externalIdField, externalId));
        return this;
    }


    // Commit
    public void commitWork() {
        Savepoint savePoint = Database.setSavepoint();
        try {
            if(!this.externalRelationships.isEmpty()) {
                for(ExternalSObjectUow extRel : this.externalRelationships) {
                    extRel.resolve(this);
                }
            }
            insertUow.execute();
            updateUow.execute();
            deleteUow.execute();
        } catch (Exception e) {
            Database.rollback(savePoint);
            throw e;
        }
    }

    public abstract class DmlExecutor {
        protected UnitOfWorkService uow;
        public DmlSharing sharingExecutor = new InheritedSharing();

        public DmlExecutor(UnitOfWorkService uow) {
            this.uow = uow;
        }

        public void execute() {
            sharingExecutor.run(this);
        }
        public abstract void performDml();
    }

    private interface DmlSharing {
        void run(DmlExecutor executor);
    }

    private inherited sharing class InheritedSharing implements DmlSharing {
        public void run(DmlExecutor executor) {
            executor.performDml();
        }
    }

    private without sharing class WithoutSharing implements DmlSharing {
        public void run(DmlExecutor executor) {
            executor.performDml();
        }
    }

    private with sharing class WithSharing implements DmlSharing {
        public void run(DmlExecutor executor) {
            executor.performDml();
        }
    }

    public inherited sharing class InsertUow extends DmlExecutor {
        public InsertUow(UnitOfWorkService uow) { super(uow); }
        
        public override void performDml() {
            if (this.uow.workToInsert.isEmpty()) return;
        
            List<SObject> allNewRecords = new List<SObject>();
            for(List<SObject> records: this.uow.workToInsert.values()) {
                allNewRecords.addAll(records);
            }
            
            Set<SObject> processedRecords = new Set<SObject>();
            Integer recordsToProcessCount = allNewRecords.size();
            Integer lastProcessedCount = -1;
            
            while(processedRecords.size() < recordsToProcessCount) {
                if (lastProcessedCount == processedRecords.size()) {
                     throw new DmlException('Could not resolve dependencies. Check for circular relationships or records not registered for insertion.');
                }
                lastProcessedCount = processedRecords.size();
        
                List<SObject> batchToInsert = new List<SObject>();
                
                for(SObject record : allNewRecords) {
                    if(processedRecords.contains(record)) continue;
                    
                    Boolean isReady = true;
                    for(RelationshipSObjectUow rel : this.uow.relationships) {
                        if (rel.getRecord() == record) { 
                            if (rel.relatedRecord.Id == null) {
                                isReady = false;
                                break;
                            }
                        }
                    }
                    
                    if(isReady) {
                        batchToInsert.add(record);
                    }
                }
                
                if (!batchToInsert.isEmpty()) {
                    for(SObject recordToInsert : batchToInsert) {
                        for(RelationshipSObjectUow rel : this.uow.relationships) {
                            if(rel.getRecord() == recordToInsert) {
                                rel.resolve();
                            }
                        }
                    }
                    Database.insert(batchToInsert, true);
                    processedRecords.addAll(batchToInsert);
                }
            }
        }
    }

    public inherited sharing class UpdateUow extends DmlExecutor {
        public UpdateUow(UnitOfWorkService uow) { super(uow); }
        public override void performDml() {
            for(RelationshipSObjectUow rel : this.uow.relationships) {
                rel.resolve();
            }

            if (this.uow.workToUpdate.isEmpty()) return;
            List<SObject> allRecords = new List<SObject>();
            for (List<SObject> records : this.uow.workToUpdate.values()) {
                allRecords.addAll(records);
            }
            if (!allRecords.isEmpty()) {
                Database.update(allRecords, true);
            }
        }
    }

    public inherited sharing class DeleteUow extends DmlExecutor {
        public DeleteUow(UnitOfWorkService uow) { super(uow); }
        public override void performDml() {
            if (this.uow.workToDelete.isEmpty()) return;
            List<SObject> allRecords = new List<SObject>();
            for (List<SObject> records : this.uow.workToDelete.values()) {
                allRecords.addAll(records);
            }
            if (!allRecords.isEmpty()) {
                Database.delete(allRecords, true);
            }
        }
    }

    public inherited sharing class PlatformEventUow extends DmlExecutor {
        public PlatformEventUow(UnitOfWorkService uow) { super(uow); }
        public override void performDml() {
        }
    }

    private abstract class SObjectUow {
        public SObject record;
        public virtual void resolve(UnitOfWorkService uow) {}
        public abstract SObject getRecord();
    }

    private inherited sharing class ExternalSObjectUow extends SObjectUow {
        private SObject currentRecord;
        private SObjectField relationshipField;
        private SObjectField externalIdField;
        private Object externalId;

        public ExternalSObjectUow(SObject record, SObjectField relationshipField, SObjectField externalIdField, Object externalId) {
            this.currentRecord = record;
            this.relationshipField = relationshipField;
            this.externalIdField = externalIdField;
            this.externalId = externalId;
        }

        public override void resolve(UnitOfWorkService uow) {
            SObjectType relatedObjectType = this.relationshipField.getDescribe().getReferenceTo()[0];
            String query = 'SELECT Id FROM ' + relatedObjectType.getDescribe().getName() + ' WHERE ' + this.externalIdField.getDescribe().getName() + ' = :externalId LIMIT 1';
            
            List<SObject> relatedRecords = Database.query(query);

            if(!relatedRecords.isEmpty()){
                this.currentRecord.put(this.relationshipField, relatedRecords[0].Id);
                uow.registerDirty(this.currentRecord);
            } else {
                throw new DmlException('Could not find related record with external ID: ' + externalId);
            }
        }

        public override SObject getRecord() {
            return this.currentRecord;
        }
    }

    private inherited sharing class RelationshipSObjectUow extends SObjectUow {
        private SObject currentRecord;
        public SObject relatedRecord { get; private set; }
        private SObjectField relationshipField;

        public RelationshipSObjectUow(SObject currentRecord, SObjectField relationshipField, SObject relatedRecord) {
            this.currentRecord = currentRecord;
            this.relatedRecord = relatedRecord;
            this.relationshipField = relationshipField;
        }

        public void resolve() {
            if(this.relatedRecord != null && this.relatedRecord.Id != null) {
                this.currentRecord.put(this.relationshipField, this.relatedRecord.Id);
            }
        }

        @TestVisible
        private override void resolve(UnitOfWorkService uow) {
            this.resolve();
        }

        public override SObject getRecord() {
            return this.currentRecord;
        }
    }
}
