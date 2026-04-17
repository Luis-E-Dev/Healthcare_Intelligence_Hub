public with sharing class PriorityScoringService {
    
    /**
     * Entry point to calculate Priority_Score__c for a list of Cases.
     * - Evaluate each Case and assign a numeric score
     * - Optionally set Case.Priority or custom field based on score
     */
    public static void applyPriorityScores(List<Case> casesToProcess) {
        if(casesToProcess == null || casesToProcess.isEmpty()) {
            return;
        }

        Set<Id> accountIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        for (Case c : casesToProcess) {
            if (c.AccountId != null) {
                accountIds.add(c.AccountId);
            }
            if (c.ContactId != null) {
                contactIds.add(c.ContactId);
            }
        }

        Map<Id, Account> accounts = loadAccounts(accountIds);
        Map<Id, Contact> contacts = loadContacts(contactIds);

        for (Case c : casesToProcess) {
            Account acc = accounts.get(c.AccountId);
            Contact con = contacts.get(c.ContactId);

            Decimal score = calculateScore(c, acc, con);
            c.Priority_Score__c = score;

            if (score >= 80) {
                c.Priority = 'High';
            } else if (score >= 50) {
                c.Priority = 'Medium';
            } else {
                c.Priority = 'Low';
            }
        }

    }

    /**
     * Calculates the priority score for a single Case.
     * - Use age, Account type, Contact role, Case type, etc.
     * - Return a numeric score
     */
    private static Decimal calculateScore(Case c, Account acc, Contact con) {
        Decimal score = 0;

        if (c != null && c.CreatedDate != null) {
            Integer ageHours = (Integer) ((System.now().getTime() - c.CreatedDate.getTime()) / (1000 * 60 * 60));
            score += Math.min(ageHours, 24) * 2;
        }
        if (acc != null && acc.Type == 'Hospital'   ) {
            score += 20;
        }
        if (con != null && con.Title == 'Doctor') {
            score += 15;
        }
        if (c != null && c.Type == 'Emergency') {
            score += 30;
        }

        return score;
    }

    /**
     * Helper: build a Map of related Accounts by Id.
     * - Query Accounts for all Case.AccountId values
     */
    private static Map<Id, Account> loadAccounts(Set<Id> accountIds) {
        Map<Id, Account> result = new Map<Id, Account>();
        if (accountIds == null || accountIds.isEmpty()) {
            return result;
        }

        for (Account acc : [SELECT Id, Name, Type FROM Account WHERE Id IN :accountIds]) {
            result.put(acc.Id, acc);
        }
        return result;
    }

    /**
     * Helper: build a Map of related Contacts by Id.
     * - Query Contacts for all Case.ContactId values
     */
    private static Map<Id, Contact> loadContacts(Set<Id> contactIds) {
        Map<Id, Contact> result = new Map<Id, Contact>();
        if (contactIds == null || contactIds.isEmpty()) {
            return result;
        }

        for(Contact c : [SELECT Id, Name, Title FROM Contact WHERE Id IN :contactIds]) {
            result.put(c.Id, c);
        }
        return result;
    }
}