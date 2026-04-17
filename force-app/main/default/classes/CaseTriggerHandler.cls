public with sharing class CaseTriggerHandler {
    // Recursion guard to prevent re-entry in same transaction
    private static Boolean isRunning = false;

    public static void handleBefore(List<Case> newList) {
        if (isRunning) {
            return;
        }
        isRunning = true;

        
        try {
            CaseSLAService.applySLA(newList);
            PriorityScoringService.applyPriorityScores(newList);
        } finally {
            isRunning = false;
        }
    }
}