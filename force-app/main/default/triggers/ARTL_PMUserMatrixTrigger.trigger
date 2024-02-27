trigger ARTL_PMUserMatrixTrigger on PM_User_Matrix__c (after insert, after Update) {
    new ARTL_PMUserMatrixTriggerHandler().run();
}