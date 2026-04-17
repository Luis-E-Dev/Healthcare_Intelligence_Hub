@isTest
private class CaseTriggerTest {

    @isTest
    static void testTrigger_OnInsert_SetsSlAndPriority() {
        Case c = new Case(
            Subject = 'Trigger Insert Test',
            Type = 'Emergency',
            SLA_Start__c = System.now(),
            SLA_Hours__c = 8
        );

        Test.startTest();
        insert c;
        Test.stopTest();

        Case inserted = [SELECT Id, SLA_Deadline__c, SLA_Status__c, Priority_Score__c, Priority FROM Case WHERE Id = :c.Id];

        System.assertNotEquals(null, inserted.SLA_Deadline__c, 'SLA_Deadline__c should be populated after insert');
        System.assertNotEquals(null, inserted.SLA_Status__c, 'SLA_Status__c should be populated after insert');
        System.assertNotEquals(null, inserted.Priority_Score__c, 'Priority_Score__c should be populated after insert');
        System.assertNotEquals(null, inserted.Priority, 'Priority should be populated after insert');
    }

    @isTest
    static void testTrigger_OnUpdate_RecalculatesSLA() {
        Case c = new Case(
            Subject = 'Trigger Update Test',
            SLA_Start__c = System.now().addHours(-10),
            SLA_Hours__c = 4
        );
        insert c;

        Case beforeUpdate = [SELECT Id, SLA_Status__c FROM Case WHERE Id = :c.Id];
        System.assertEquals('Breached', beforeUpdate.SLA_Status__c, 'Should be Breached before update');

        // Reset SLA to a future deadline
        c.SLA_Start__c = System.now();
        c.SLA_Hours__c = 8;

        Test.startTest();
        update c;
        Test.stopTest();

        Case afterUpdate = [SELECT Id, SLA_Status__c, SLA_Deadline__c FROM Case WHERE Id = :c.Id];
        System.assertEquals('On Track', afterUpdate.SLA_Status__c, 'SLA_Status__c should be recalculated to On Track after update');
    }

    @isTest
    static void testTrigger_BulkInsert() {
        List<Case> cases = new List<Case>();
        for (Integer i = 0; i < 200; i++) {
            cases.add(new Case(
                Subject = 'Bulk Case ' + i,
                SLA_Start__c = System.now(),
                SLA_Hours__c = 8,
                Type = 'Question'
            ));
        }

        Test.startTest();
        insert cases;
        Test.stopTest();

        List<Case> inserted = [SELECT Id, SLA_Deadline__c, SLA_Status__c, Priority_Score__c, Priority FROM Case WHERE Id IN :cases];
        System.assertEquals(200, inserted.size(), 'All 200 cases should be inserted');
        for (Case ic : inserted) {
            System.assertNotEquals(null, ic.SLA_Deadline__c, 'SLA_Deadline__c should be set on bulk insert');
            System.assertNotEquals(null, ic.SLA_Status__c, 'SLA_Status__c should be set on bulk insert');
        }
    }
}
