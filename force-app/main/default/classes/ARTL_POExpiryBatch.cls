global class ARTL_POExpiryBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        try {
            Date currentDate = Date.today();
            Date thirtyDaysFromNow = currentDate.addDays(30);
            Date fifteenDaysFromNow = currentDate.addDays(15);
            Date fiveDaysFromNow = currentDate.addDays(5);
            System.debug('thirtyDaysFromNow '+thirtyDaysFromNow);
            System.debug('fifteenDaysFromNow '+fifteenDaysFromNow);
            System.debug('fiveDaysFromNow '+fiveDaysFromNow);
            return Database.getQueryLocator([
                SELECT Id, Name, ARTL_PO_Number__c, Start_Date__c, End_Date__c, Owner.Email, ARTL_Account__c
                FROM ARTL_Purchase_Order__c
                WHERE End_Date__c != null AND (End_Date__c = :thirtyDaysFromNow OR End_Date__c = :fifteenDaysFromNow OR End_Date__c = :fiveDaysFromNow OR End_Date__c = :currentDate)
            ]);
        } catch (Exception e) {
            // Handle the exception or log it
            System.debug('An exception occurred in start method: ' + e.getMessage());
            return null;
        }
    }
    
    global void execute(Database.BatchableContext BC, List<ARTL_Purchase_Order__c> scope) {
        try {
            System.debug('scope' + scope);
            System.debug('scope.size()' + scope.size());
            for (ARTL_Purchase_Order__c po : scope) {
                // Send email notification
                sendRenewalEmailNotification(po);
            }
        } catch (Exception e) {
            // Handle the exception or log it
            System.debug('An exception occurred in execute method: ' + e.getMessage());
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        try {
            
        } catch (Exception e) {
            // Handle the exception or log it
            System.debug('An exception occurred in finish method: ' + e.getMessage());
        }
    }
    
    private void sendRenewalEmailNotification(ARTL_Purchase_Order__c po) {
        String kamScdryUsEmailid, coltnMngerUsrEmailId; 
        Integer openOrder, openQuote;
        try {
            
            if(String.isNotEmpty(po.ARTL_Account__c)){
                System.debug('po.ARTL_Account__c ' + po.ARTL_Account__c);
                openOrder = [SELECT COUNT() FROM Order WHERE AccountId=:po.ARTL_Account__c AND Type='PO Renewal'];
                openQuote = [SELECT COUNT() FROM Quote WHERE AccountId=:po.ARTL_Account__c AND vlocity_cmt__Type__c='PO Renewal']; 
                System.debug('openOrder' + openOrder);
                System.debug('openQuote' + openQuote);
                
                List<AccountTeamMember> atmList = [Select Id, UserId, User.Email, TeamMemberRole, AccountId FROM AccountTeamMember WHERE AccountId=:po.ARTL_Account__c];
                System.debug('atmList' + atmList);
                if(atmList.size()>0){
                    for(AccountTeamMember atm: atmList){
                        if(atm.TeamMemberRole =='Collection Manager'){
                            coltnMngerUsrEmailId = atm.User.Email;
                            System.debug('coltnMngerUsrEmailId' + coltnMngerUsrEmailId);
                        }
                        if(atm.TeamMemberRole =='Secondary KAM'){
                            kamScdryUsEmailid = atm.User.Email;
                            System.debug('kamScdryUsEmailid' + kamScdryUsEmailid);
                        }
                    }       
                }
                
            }
            
            // Logic to send email notification
            // Use Messaging.SingleEmailMessage or other appropriate methods
            if(openOrder == 0 && openQuote == 0){
                Messaging.SingleEmailMessage[] emailList = new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                // Include the email template with the Purchase Order information
                DateTime dateTimeValue = (DateTime)po.End_Date__c;
                String endDate = dateTimeValue.format();
                System.debug('endDate.substringBefore '+endDate.substringBefore(','));
                email.setSubject('Purchase Order Expiry Reminder');
                email.setHtmlBody('Purchase Order ' + po.ARTL_PO_Number__c + ' getting expired on ' + endDate.substringBefore(',') + ','+'\r\n'+ ' kindly initiate the Purchase Order Renewal');
                List<String> emailTo = new List<String>();
                emailTo.add(po.Owner.Email);
                if(String.isNotEmpty(kamScdryUsEmailid)){
                    emailTo.add(kamScdryUsEmailid);    
                }
                if(String.isNotEmpty(coltnMngerUsrEmailId)){
                    emailTo.add(coltnMngerUsrEmailId);    
                }
                
                email.setToAddresses(emailTo);
                emailList.add(email);
                
                if (!emailList.isEmpty()) {
                    Messaging.sendEmail(emailList, false);
                }   
            }
            
        } catch (Exception e) {
            // Handle the exception or log it
            System.debug('An exception occurred in sendRenewalEmailNotification method: ' + e.getMessage());
        }
    }
}