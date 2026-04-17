@isTest
private class CaseSLAServiceTest {

    @isTest
    static void testApplySLA_OnTrack() {
        Case c = new Case(
            Subject = 'Test On Track',
            SLA_Start__c = System.now(),
            SLA_Hours__c = 8
        );

        Test.startTest();
        CaseSLAService.applySLA(new List<Case>{ c });
        Test.stopTest();

        System.assertNotEquals(null, c.SLA_Deadline__c, 'SLA_Deadline__c should be set');
        System.assertEquals('On Track', c.SLA_Status__c, 'Status should be On Track for a fresh SLA');
    }

    @isTest
    static void testApplySLA_Breached() {
        Case c = new Case(
            Subject = 'Test Breached',
            SLA_Start__c = System.now().addHours(-10),
            SLA_Hours__c = 4
        );

        Test.startTest();
        CaseSLAService.applySLA(new List<Case>{ c });
        Test.stopTest();

        System.assertEquals('Breached', c.SLA_Status__c, 'Status should be Breached when deadline is in the past');
    }

    @isTest
    static void testApplySLA_Warning() {
        // SLA started 7.9 hours ago with 8 hours total — only ~0.1 hours (6 min) remain
        // Remaining is < 20% of total, so status should be Warning
        Case c = new Case(
            Subject = 'Test Warning',
            SLA_Start__c = System.now().addHours(-8).addMinutes(6),
            SLA_Hours__c = 8
        );

        Test.startTest();
        CaseSLAService.applySLA(new List<Case>{ c });
        Test.stopTest();

        System.assertEquals('Warning', c.SLA_Status__c, 'Status should be Warning when within 20% of SLA time remaining');
    }

    @isTest
    static void testApplySLA_NullInputs() {
        // Should not throw — null list and list with null-field cases handled gracefully
        Case cNoSLAStart = new Case(Subject = 'No SLA Start', SLA_Hours__c = 4);
        Case cNoSLAHours = new Case(Subject = 'No SLA Hours', SLA_Start__c = System.now());

        Test.startTest();
        CaseSLAService.applySLA(null);
        CaseSLAService.applySLA(new List<Case>());
        CaseSLAService.applySLA(new List<Case>{ cNoSLAStart, cNoSLAHours });
        Test.stopTest();

        System.assertEquals(null, cNoSLAStart.SLA_Deadline__c, 'Deadline should remain null if SLA_Start__c is missing');
        System.assertEquals(null, cNoSLAHours.SLA_Deadline__c, 'Deadline should remain null if SLA_Hours__c is missing');
    }

    @isTest
    static void testApplySLA_DeadlineCalculation() {
        Datetime start = Datetime.newInstance(2026, 1, 1, 8, 0, 0);
        Case c = new Case(
            Subject = 'Test Deadline',
            SLA_Start__c = start,
            SLA_Hours__c = 4
        );

        Test.startTest();
        CaseSLAService.applySLA(new List<Case>{ c });
        Test.stopTest();

        Datetime expectedDeadline = start.addHours(4);
        System.assertEquals(expectedDeadline, c.SLA_Deadline__c, 'Deadline should be SLA_Start__c + SLA_Hours__c');
    }
}
