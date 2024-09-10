trigger BillTrigger on Bill__c (before insert, before update, after insert, after update) {

    if (trigger.isBefore) {
        if (trigger.isInsert || trigger.isUpdate) {
            BillTriggerHandler.billValidate(trigger.new);
            BillTriggerHandler.invoicePopulate(trigger.new);
        }
    }

    if (trigger.isAfter) {
        if (trigger.isInsert || trigger.isUpdate) {
            BillTriggerHandler.billOpportunities(trigger.new);
            BillTriggerHandler.updateBillWithOpportunity(trigger.new);
        }
    }
}
