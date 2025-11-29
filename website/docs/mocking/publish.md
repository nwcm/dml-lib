---
outline: deep
---

# Publish

Mock platform event publish operations in unit tests to avoid actual event publishing.

::: warning
The `DML.mock()` and `DML.retrieveResultFor()` methods are `@TestVisible` and should only be used in test classes.
:::

::: tip
- **No events published**: Mocked publishes don't trigger event subscribers
- **IDs are assigned**: Events receive valid mocked IDs
- **Results are captured**: All operation details are available via `DML.retrieveResultFor()`
- **Selective mocking**: Use `publishesFor()` to mock specific event types while allowing others to execute
:::

**Example**

```apex
public class NotificationService {
    public void notifyAccountCreated(Account account) {
        AccountCreatedEvent__e event = new AccountCreatedEvent__e(
            AccountId__c = account.Id,
            AccountName__c = account.Name
        );

        new DML()
            .toPublish(event)
            .identifier('NotificationService.notifyAccountCreated')
            .commitWork();
    }
}
```

```apex
@IsTest
static void shouldPublishAccountCreatedEvent() {
    // Setup
    DML.mock('NotificationService.notifyAccountCreated').allPublishes();

    Account account = new Account(
        Id = DML.randomIdGenerator.get(Account.SObjectType),
        Name = 'Test Account'
    );

    // Test
    Test.startTest();
    new NotificationService().notifyAccountCreated(account);
    Test.stopTest();

    // Verify
    DML.Result result = DML.retrieveResultFor('NotificationService.notifyAccountCreated');

    DML.OperationResult eventResult = result.eventsOf(AccountCreatedEvent__e.SObjectType);
    Assert.areEqual(1, eventResult.records().size(), '1 event should be published');
}
```

## allPublishes

Mock all publish operations regardless of event type.

**Signature**

```apex
DML.mock(String identifier).allPublishes();
```

**Class**

```apex
public class EventService {
    public void publishEvents() {
        new DML()
            .toPublish(new OrderEvent__e(OrderId__c = '12345'))
            .toPublish(new ShipmentEvent__e(TrackingNumber__c = 'ABC123'))
            .identifier('EventService.publishEvents')
            .commitWork();
    }
}
```

**Test**

```apex
@IsTest
static void shouldMockMultipleEventTypes() {
    // Setup
    DML.mock('EventService.publishEvents').allPublishes();

    // Test
    Test.startTest();
    new EventService().publishEvents();
    Test.stopTest();

    // Verify
    DML.Result result = DML.retrieveResultFor('EventService.publishEvents');

    Assert.areEqual(2, result.events().size(), '2 event types mocked');
}
```

## publishesFor

Mock publish operations only for a specific event type. Other event types will be published.

**Signature**

```apex
DML.mock(String identifier).publishesFor(SObjectType objectType);
```

**Class**

```apex
public class EventService {
    public void publishEvents() {
        new DML()
            .toPublish(new OrderEvent__e(OrderId__c = '12345'))
            .toPublish(new ShipmentEvent__e(TrackingNumber__c = 'ABC123'))
            .identifier('EventService.publishEvents')
            .commitWork();
    }
}
```

**Test**

```apex
@IsTest
static void shouldMockOnlyOrderEvents() {
    // Setup - Mock only OrderEvent__e publishes
    DML.mock('EventService.publishEvents').publishesFor(OrderEvent__e.SObjectType);

    // Test
    Test.startTest();
    new EventService().publishEvents();
    Test.stopTest();

    // Verify
    DML.Result result = DML.retrieveResultFor('EventService.publishEvents');

    Assert.areEqual(2, result.events().size(), '2 event types in result');
    // OrderEvent__e was mocked, ShipmentEvent__e was actually published
}
```

## Retrieving Results

Use `DML.retrieveResultFor()` to access the mocked operation results.

**Signature**

```apex
DML.Result result = DML.retrieveResultFor(String identifier);
```

**Class**

```apex
public class NotificationService {
    public void sendAlert() {
        new DML()
            .toPublish(new AlertEvent__e(Message__c = 'System Alert'))
            .identifier('NotificationService.sendAlert')
            .commitWork();
    }
}
```

**Test**

```apex
@IsTest
static void shouldAccessRecordResults() {
    // Setup
    DML.mock('NotificationService.sendAlert').allPublishes();

    // Test
    Test.startTest();
    new NotificationService().sendAlert();
    Test.stopTest();

    // Verify
    DML.Result result = DML.retrieveResultFor('NotificationService.sendAlert');
    DML.OperationResult opResult = result.eventsOf(AlertEvent__e.SObjectType);

    Assert.areEqual(AlertEvent__e.SObjectType, opResult.objectType(), 'Should be AlertEvent__e type');
    Assert.areEqual(DML.OperationType.PUBLISH_DML, opResult.operationType(), 'Should be PUBLISH operation');
}
```
