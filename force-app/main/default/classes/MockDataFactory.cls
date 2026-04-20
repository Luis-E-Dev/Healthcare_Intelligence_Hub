public with sharing class MockDataFactory {
    public static void run() {
        createMockData(20);
    }
    
    public static void createMockData(Integer recordCount) {
        Integer count = (recordCount == null || recordCount <= 0) ? 20 : recordCount;
        
        List<Account> accounts = new List<Account>();
        List<String> accountTypes = new List<String>{'Hospital', 'Clinic', 'Lab', 'Pharmacy'};
        for(Integer i = 0; i < count; i++) {
            Account a = new Account();
            a.Name = 'Health Org ' + (i + 1);
            a.Type = accountTypes[randIndex(accountTypes.size())];
            accounts.add(a);
        }
        insert accounts;

        List<Contact> contacts = new List<Contact>();
        List<String> contactTitles = new List<String>{'Doctor', 'Nurse', 'Staff', 'Administrator'};
        for(Integer i = 0; i < count; i++) {
            Contact c = new Contact();
            c.FirstName = 'First' + (i + 1);
            c.LastName = 'Last' + (i + 1);
            c.Title = contactTitles[randIndex(contactTitles.size())];
            c.AccountId = accounts[i].Id;
            contacts.add(c);
        }

        for (Integer i = contacts.size(); i < count; i++) {
            Contact c = new Contact();
            c.FirstName = 'First' + (i + 1);
            c.LastName = 'Last' + (i + 1);
            c.Title = contactTitles[randIndex(contactTitles.size())];
            c.AccountId = accounts[randIndex(accounts.size())].Id;
            contacts.add(c);
        }
        insert contacts;

        List<Case> cases = new List<Case>();
        List<String> caseTypes = new List<String>{'Emergency', 'Routine', 'Billing', 'Records'};

        for (Integer i = 0; i < accounts.size(); i++) {
            Case cs = buildCase(i, accounts[i], contacts[randIndex(contacts.size())], caseTypes);
            cases.add(cs);
        }

        for (Integer i = cases.size(); i < count; i++) {
            Account a = accounts[randIndex(accounts.size())];
            Contact c = contacts[randIndex(contacts.size())];
            Case cs = buildCase(i, a, c, caseTypes);
            cases.add(cs);
        }
        insert cases;
    }

    private static Case buildCase(Integer index, Account account, Contact contact, List<String> caseTypes) {
        Case cs = new Case();
        cs.Subject = 'Healthcare Case ' + (index + 1);
        cs.Status = 'New';
        cs.Origin = 'Origin';
        cs.Type = caseTypes[randIndex(caseTypes.size())];

        cs.AccountId = account.Id;
        cs.ContactId = contact.Id;

        // Mock SLA Fields
        cs.SLA_Start__c = System.now().addHours(-1 * Math.mod(Crypto.getRandomInteger(), 12));
        cs.SLA_Hours__c = Math.mod(Crypto.getRandomInteger(), 12) + 12;

        cs.Case_Summary__c = 'Mock summary for healthcare case #' + (index + 1);
        return cs;
    }

    public static void cleanupMockData() {
        List<Case> cases = [SELECT Id FROM Case WHERE Subject LIKE 'Healthcare Case %'];
        if (!cases.isEmpty()) delete cases;
        List<Contact> contacts = [SELECT Id FROM Contact WHERE LastName LIKE 'Last%'];
        if (!contacts.isEmpty()) delete contacts;
        List<Account> accounts = [SELECT Id FROM Account WHERE Name LIKE 'Health Org %'];
        if (!accounts.isEmpty()) delete accounts;
    }

    private static Integer randIndex(Integer size) {
        if (size == null || size <= 0) return 0;
        Integer r = Crypto.getRandomInteger();
        if (r < 0) r = -r;
        return Math.mod(r, size);
    }
}