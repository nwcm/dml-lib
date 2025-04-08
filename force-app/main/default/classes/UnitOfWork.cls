public inherited sharing class UnitOfWork implements DmlCommitable {

    // UnitOfWork uow = new UnitOfWork()
    // ;
    // uow.registerNew(new Account(Name='Test Account'));
    // uow.registerNew(new Account(Name='Test Account 2'));

    // uow.commitWork();

    public interface DmlCommitable {
        // Settings
        UnitOfWork systemMode();
        UnitOfWork withSharing();
        UnitOfWork withoutSharing();
        // Insert
        UnitOfWork registerNew(SObject record);
        UnitOfWork registerNew(Iterable<SObject> records);
        // Update
        UnitOfWork registerDirty(SObject record);
        UnitOfWork registerDirty(Iterable<SObject> records);
        // Relationship
        UnitOfWork registerRelationship(SObject targetRecord, SObjectField targetField, SObject relatedRecord);
        // Upsert
        UnitOfWork registerUpsert(SObject record);
        UnitOfWork registerUpsert(Iterable<SObject> records);
        // Delete
        UnitOfWork registerDeleted(SObject record);
        UnitOfWork registerDeleted(Iterable<SObject> recordssObjs);
        // Save
        void commitWork();
    }

    public UnitOfWork registerNew(SObject record) {
        if (String.isNotBlank(record.Id)) {
            throw new DmlException('Only new records can be registered as new');
        }
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
        return this;
    }

    public UnitOfWork registerDirty(Iterable<SObject> records) {
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
        for (SObject record : records) {
            this.registerUpsert(record);
        }
        return this;
    }

    public UnitOfWork registerDeleted(SObject record) {
        if (String.isBlank(record.Id)) {
            throw new DmlException('Only existing records can be registered as deleted');
        }
        return this;
    }

    public UnitOfWork registerDeleted(Iterable<SObject> records) {
        for (SObject record : records) {
            this.registerDeleted(record);
        }
        return this;
    }

    public void commitWork() {
        Savepoint savePoint = Database.setSavepoint();

        try {

        } catch (Exception e) {
            Database.rollback(savePoint);
            throw e;
        }
    }

    public abstract class DmlExecutor {

    }

    public inherited sharing class InsertUow extends DmlExecutor {

    }

    public inherited sharing class UpdateUow extends DmlExecutor {

    }

    public inherited sharing class DeleteUow extends DmlExecutor {

    }

    public inherited sharing class PlatformEventUow extends DmlExecutor {

    }
}
