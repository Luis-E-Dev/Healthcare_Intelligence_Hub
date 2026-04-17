public with sharing class CaseSLAService {

    /**
     * Entry point to calculate SLA fields for a list of Cases.
     * - Validate required fields (SLA_Start__c, SLA_Hours__c)
     * - Compute SLA_Deadline__c
     * - Determine SLA_Status__c based on deadline vs now
     */
    public static void applySLA(List<Case> casesToProcess) {
        if (casesToProcess == null || casesToProcess.isEmpty()) {
            return;
        }

        for (Case c : casesToProcess) {
            if(c.SLA_Start__c == null || c.SLA_Hours__c == null) {
                continue;
            }

            Datetime deadline = c.SLA_Start__c.addHours(Integer.valueOf(c.SLA_Hours__c));
            c.SLA_Deadline__c = deadline;

            Datetime now = System.now();
            if (deadline <= now) {
                c.SLA_Status__c = 'Breached';
            } else {
                Long totalMillis = (Long) (c.SLA_Hours__c * 60 * 60 * 1000);
                Long remainingMillis = deadline.getTime() - now.getTime();
                if (remainingMillis <= (totalMillis * 0.2)) {
                    c.SLA_Status__c = 'Warning';
                } else {
                    c.SLA_Status__c = 'On Track';
                }
            }
        }
    }

    /**
     * Calculates the SLA deadline based on start time and hours.
     * - Add SLA_Hours__c to SLA_Start__c
     * - Return DateTime result
     */
    private static DateTime calculateDeadline(DateTime slaStart, Decimal slaHours) {
        if (slaStart == null || slaHours == null) {
            return null;
        }       

        return slaStart.addHours(Integer.valueOf(slaHours));
    }

    /**
     * Determines the SLA status (On Track, Warning, Breached).
     * - Compare deadline to current time
     * - Use a warning threshold (ex: within 20% of remaining time)
     */
    private static String determineSLAStatus(DateTime deadline) {
        if (deadline == null) {
            return null;
        }

        Datetime now = System.now();
        if (deadline <= now) {
            return 'Breached';
        }

        Long totalMillis = 4L * 60 * 60 * 1000;
        Long remainingMillis = deadline.getTime() - now.getTime();

        if (remainingMillis <= (totalMillis * 0.2)) {
            return 'Warning';
        } else {
            return 'On Track';
        }
    }

    /**
     * Optional helper to set default SLA values if missing.
     * - Set SLA_Start__c to System.now() if null
     * - Set SLA_Hours__c based on Case type if null
     */
    private static void applyDefaults(Case c) {
        if (c == null) {
            return;
        }

        if (c.SLA_Start__c == null) {
            c.SLA_Start__c = System.now();
        }

        if (c.SLA_Hours__c == null) {
            if (c.Type == 'Emergency') {
                c.SLA_Hours__c = 2;
            } else {
                c.SLA_Hours__c = 8;
            }
        }
    }
}