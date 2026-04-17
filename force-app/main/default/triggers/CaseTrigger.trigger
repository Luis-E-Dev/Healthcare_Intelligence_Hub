trigger CaseTrigger on Case (before insert, before update) {
    CaseTriggerHandler.handleBefore(Trigger.new);
}