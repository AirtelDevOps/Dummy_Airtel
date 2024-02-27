trigger ARTL_QuoteMemberTrigger on vlocity_cmt__QuoteMember__c (before insert, before update, after insert, after update) {
    new ARTL_QuoteMemberTriggerHandler().run();
}