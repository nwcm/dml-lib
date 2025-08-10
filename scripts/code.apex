// DML Work

DML dml = new DML();

Opportunity newOpportunity = new Opportunity(
    Name = 'UoW Test Name ' + i,
    StageName = 'Open',
    CloseDate = System.today()
);

dml.toInsert(newOpportunity);

for(Integer j = 0 ; j < i + 1 ; j++) {
    Product2 newProduct = new Product2(
        Name = newOpportunity.Name + ' : Product : ' + i
    );

    dml.toInsert(newProduct);

    PricebookEntry newPricebookEntry = new PricebookEntry(
        UnitPrice = 10,
        IsActive = true,
        UseStandardPrice = false
    );  

    dml.toInsert(newPricebookEntry, PricebookEntry.Product2Id, newProduct);

    // or

    dml.toInsert(newPricebookEntry)
        .withRelationship(PricebookEntry.Product2Id, newProduct);

    // or

    dml.toInsert(
        DML.Record(newPricebookEntry).withRelationship(PricebookEntry.Product2Id, newProduct)
    );

    OpportunityLineItem newOpportunityLineItem = new OpportunityLineItem(
        Quantity = 1,
        TotalPrice = 10
    );

    dml.toInsert(newOpportunityLineItem)
        .withRelationship(OpportunityLineItem.OpportunityId, newOpportunity)
        .withRelationship(OpportunityLineItem.PricebookEntryId, newPricebookEntry);

    // or

    dml.toInsert(
        DML.Record(newOpportunityLineItem)
            .withRelationship(OpportunityLineItem.OpportunityId, newOpportunity)
            .withRelationship(OpportunityLineItem.PricebookEntryId, newPricebookEntry)
    );
}

dml.commitWork();


