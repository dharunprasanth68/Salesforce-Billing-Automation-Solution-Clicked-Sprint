trigger BillTrigger on Bill__c (before insert, before update, after insert, after update) {
    
    if(trigger.isbefore){
        if(trigger.isInsert || trigger.isUpdate){
            BillTriggerHandler.billvalidate(trigger.new);
            BillTriggerHandler.invoicePopulate(trigger.new);
        }
    }
    if(trigger.isafter){

        if(trigger.isInsert || trigger.isUpdate){
            BillTriggerHandler.billOpportunities(trigger.new);
        }
    }
}

