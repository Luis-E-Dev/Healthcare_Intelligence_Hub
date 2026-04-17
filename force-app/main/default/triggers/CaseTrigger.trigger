trigger CaseTrigger on Case (before insert, before update) {
    CaseSLAService.applySLA(Trigger.new);

    PriorityScoringService.applyPriorityScores(Trigger.new);
}