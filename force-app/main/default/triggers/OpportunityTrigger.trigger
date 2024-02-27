trigger OpportunityTrigger on Opportunity (After Update, Before Update,Before Insert) {
    new ARTL_OpportunityTriggerHandler().run();
}