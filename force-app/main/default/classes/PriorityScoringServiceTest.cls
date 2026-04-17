@isTest
private class PriorityScoringServiceTest {

    @isTest
    static void testHighPriority_EmergencyWithHospitalAndDoctor() {
        Account acc = new Account(Name = 'Test Hospital', Type = 'Hospital');
        insert acc;

        Contact con = new Contact(LastName = 'Smith', Title = 'Doctor', AccountId = acc.Id);
        insert con;

        Case c = new Case(
            Subject = 'Emergency Case',
            Type = 'Emergency',
            AccountId = acc.Id,
            ContactId = con.Id
        );
        insert c;

        // Re-query to get CreatedDate populated
        c = [SELECT Id, AccountId, ContactId, Type, CreatedDate, Priority_Score__c, Priority FROM Case WHERE Id = :c.Id];

        Test.startTest();
        PriorityScoringService.applyPriorityScores(new List<Case>{ c });
        Test.stopTest();

        // Emergency(30) + Hospital(20) + Doctor(15) + age score
        System.assert(c.Priority_Score__c >= 65, 'Score should be at least 65 for Emergency + Hospital + Doctor');
        System.assertEquals('High', c.Priority, 'Priority should be High for score >= 80 (including age contribution)');
    }

    @isTest
    static void testMediumPriority() {
        Account acc = new Account(Name = 'Test Clinic', Type = 'Hospital');
        insert acc;

        Case c = new Case(
            Subject = 'Medium Case',
            Type = 'Problem',
            AccountId = acc.Id
        );
        insert c;

        c = [SELECT Id, AccountId, ContactId, Type, CreatedDate, Priority_Score__c, Priority FROM Case WHERE Id = :c.Id];

        Test.startTest();
        PriorityScoringService.applyPriorityScores(new List<Case>{ c });
        Test.stopTest();

        // Hospital(20) + small age score; no Emergency/Doctor bonus
        System.assert(c.Priority_Score__c >= 20, 'Score should include Hospital bonus');
    }

    @isTest
    static void testLowPriority_NoRelatedRecords() {
        Case c = new Case(Subject = 'Low Priority Case', Type = 'Question');
        insert c;

        c = [SELECT Id, AccountId, ContactId, Type, CreatedDate, Priority_Score__c, Priority FROM Case WHERE Id = :c.Id];

        Test.startTest();
        PriorityScoringService.applyPriorityScores(new List<Case>{ c });
        Test.stopTest();

        System.assertNotEquals(null, c.Priority_Score__c, 'Priority_Score__c should be set');
        // No Account/Contact/Emergency bonuses; only minimal age score for a just-created case
        System.assertEquals('Low', c.Priority, 'Priority should be Low with no bonuses');
    }

    @isTest
    static void testApplyPriorityScores_NullAndEmpty() {
        Test.startTest();
        PriorityScoringService.applyPriorityScores(null);
        PriorityScoringService.applyPriorityScores(new List<Case>());
        Test.stopTest();

        // No exception thrown — test passes
        System.assert(true, 'No exception should be thrown for null or empty input');
    }

    @isTest
    static void testPriorityThresholds() {
        Case c = new Case(Subject = 'Threshold Case', Type = 'Question');
        insert c;

        c = [SELECT Id, AccountId, ContactId, Type, CreatedDate, Priority_Score__c, Priority FROM Case WHERE Id = :c.Id];

        Test.startTest();
        PriorityScoringService.applyPriorityScores(new List<Case>{ c });
        Test.stopTest();

        Decimal score = c.Priority_Score__c;
        String expectedPriority;
        if (score >= 80) {
            expectedPriority = 'High';
        } else if (score >= 50) {
            expectedPriority = 'Medium';
        } else {
            expectedPriority = 'Low';
        }

        System.assertEquals(expectedPriority, c.Priority, 'Priority field should match the score threshold');
    }
}
