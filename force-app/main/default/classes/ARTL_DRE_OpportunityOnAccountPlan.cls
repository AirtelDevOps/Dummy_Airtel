/**
* @description       : Used in Opportunity Account Plan dataraptor
* @test class        : 
* @author            : Rishab Kalra
* @last modified on  : 11-06-2023
**/
global class ARTL_DRE_OpportunityOnAccountPlan implements vlocity_cmt.VlocityOpenInterface{ 
    global Boolean invokeMethod(String methodName, Map<String, Object> inputs, Map<String, Object> output, Map<String, Object> options){
        System.debug('DEBUGG '+ methodName);
        System.debug('DEBUGG inputs '+ inputs);
        System.debug('DEBUGG output '+ output);
        System.debug('DEBUGG options '+ options);
        
        if (methodName == 'default') {
            calculateHierarchyScore(inputs, output, options);
            return true;
        } else if(methodName == 'fetchBUC'){
            fetchHistoricalBUC(inputs,output,options);
            return true;
        } else if(methodName == 'fetchFiscalYrOpp'){
            fetchFiscalYrOppList(inputs,output,options);
            return true;
        }
        return false;
    }
    
    /**
* @description : Calculate hierarchy level score for contacts 
* @author Rishab Kalra | 11-06-2023 
* @param inputs 
* @param output 
* @param options 
**/
    private static void calculateHierarchyScore(Map<String, Object> inputs, Map<String, Object> output, Map<String, Object> options){
        // Retrieve the argument lists
        try{
            List<Contact> contactList = new List<Contact>();
            Set<Id> eventIds=New Set<Id>();
            Map<Id,List<Eventrelation>> eventrelationMap = New Map<Id,List<Eventrelation>>();
            List<Object> arguments = (List<Object>)inputs.get('arguments');
            String accountId = (String) arguments[0];            
            contactList = [SELECT Id, AccountId, ARTL_Interaction_level__c, RecordTypeId, Name, ARTL_designation__c, ARTL_stakeholder_score__c, owner.name,
                           (SELECT Id, Accountid, WhoId, vlocity_cmt__eventstatus__c, activitydate, ARTL_account_plan__c, RecordTypeId, ARTL_disposition__c, who.name, Description, ARTL_description__c,ARTL_key_competitors__c, ARTL_key_stake_holder__c, ARTL_key_timelines__c, owner.name, ARTL_immediate_steps_engagement_plans__c, ARTL_sizing__c, ARTL_agenda__c FROM Events Order by createdDate desc limit 1)
                           FROM Contact WHERE AccountId = :accountId AND ARTL_Interaction_Level__c != null ORDER BY ARTL_Interaction_Level__c]; 
            
            List<Map<String, Object>> listOfMapContact = new List<Map<String, Object>>();
            Map<String, List<Contact>> interactionLevelContactList = new Map<String, List<Contact>>();
            Map<String, Double> interactionLevelAvg = new Map<String, Double>();
            for(Contact cont: contactList){
                if(!cont.events.isEmpty()){
                    eventIds.add(cont.events[0].Id);
                }
                if(!interactionLevelContactList.containsKey(cont.ARTL_Interaction_level__c)){
                    interactionLevelContactList.put(cont.ARTL_Interaction_level__c, new List<Contact>{cont});
                }
                else {
                    interactionLevelContactList.get(cont.ARTL_Interaction_level__c).add(cont);
                }
            }
            List<EventRelation> lstRelation = [SELECT ID, EventID, Relation.Type, RelationID, Relation.FirstName, 
                                               Relation.Email, Relation.name FROM EventRelation
                                               WHERE EventID IN :eventIds];
            for(EventRelation relationrecord : lstRelation){
                if (!eventrelationMap.containsKey(relationrecord.EventID)) {
                    eventrelationMap.put(relationrecord.EventID, new List<EventRelation>{relationrecord});
                } else {
                    eventrelationMap.get(relationrecord.EventID).add(relationrecord);
                }
            }
            for(String intLevel: interactionLevelContactList.keySet()){
                Integer count = interactionLevelContactList.get(intLevel).size(); //count
                Double sum = 0;
                Double average;
                for(Contact cont: interactionLevelContactList.get(intLevel)){
                    sum = sum + Double.valueOf(cont.ARTL_stakeholder_score__c);
                }
                average = sum/count;
                interactionLevelAvg.put(intLevel, average);
                
            }
            for(Contact cont: contactList){
                Map<String, Object> contMap = new Map<String, Object>();
                contMap.put('name', cont.Name);
                contMap.put('interactionLevel', cont.ARTL_Interaction_level__c);
                contMap.put('designation', cont.ARTL_designation__c);
                contMap.put('stakeholderScore',cont.ARTL_Stakeholder_Score__c);
                contMap.put('hierarchyLevelScore', interactionLevelAvg.get(cont.ARTL_Interaction_level__c));
                List<EventRelation> listofeventrecords = new List<EventRelation>();
                if(!cont.events.isEmpty()){
                    listofeventrecords = eventrelationMap.get(cont.events[0]?.Id);
                    //MOdified as per SFDC-1727(Polam Vishal)...
                    List<String> namesList = new List<String>();
                    String names = '';
                    if(listofeventrecords != null && !listofeventrecords.isEmpty()){
                        for(EventRelation er: listofeventrecords){
                            namesList.add(er.Relation.name);
                            
                        }
                        names = String.join(namesList,',');
                    }
                    contMap.put('assignee', names);
                    contMap.put('eventId', cont.events[0].Id);
                    contMap.put('eventAccountTeam', cont.events[0].Owner.Name);
                    String eventStatus;
                    if(!String.ISBLANK(cont.events[0].vlocity_cmt__eventstatus__c)){
                        eventStatus = '['+cont.events[0].vlocity_cmt__EventStatus__c+'] - '+cont.events[0].ActivityDate; 
                    }
                    contMap.put('eventMeetingStatus', eventStatus);
                    contMap.put('eventObjective', cont.events[0].ARTL_agenda__c); 
                    contMap.put('eventNextSteps', cont.events[0].ARTL_immediate_steps_engagement_plans__c);
                }
                listOfMapContact.add(contMap);
                
            }//size = 0 , list object
            
            if(!listOfMapContact.isEmpty()) {
                output.put('result', listOfMapContact);
            }
            System.debug('DEBUGG output '+ output);
        }
        
        catch(Exception ex){
            System.debug('DEBUGG exception '+ ex.getLineNumber()+ ' ' + ex.getMessage());
            ARTL_Logger.error(ARTL_Constants.CONTROLLER, 'ARTL_DRE_OpportunityOnAccountPlan.calculateHierarchyScore', '', new Map<String, Object>{'Exception' => ex.getMessage(), 'LineNumber' => ex.getLineNumber()}, ex);
        }
    }
    
    private static void fetchHistoricalBUC(Map<String, Object> inputs, Map<String, Object> output, Map<String, Object> options){
        // Retrieve the argument lists
        try{
            List<Object> arguments = (List<Object>)inputs.get('arguments');
            String accountPlanId = (String) arguments[0];
            List<Map<String,Object>> bucList = new List<Map<String,Object>>();
            Map<String,List<Bottom_Up_Construct__c>> bucMap = new Map<String,List<Bottom_Up_Construct__c>>();
            
            Integer currentYear = (Date.today()).year();
            Integer prev1Year   = currentYear-1;
            Integer prev2Year   = currentYear-2;
            
            List<String> lastThreeFiscalYearList = new List<String>{String.valueOf(currentYear), String.valueOf(prev1Year), String.valueOf(prev2Year)};
                
                for(Bottom_Up_Construct__c buc: [SELECT Id,Product_Solution__c ,Product_Category__r.Name ,Spends_with_Airtel__c ,Total_Competitor_Spends__c , Fiscal_Year__c  FROM Bottom_Up_Construct__c WHERE Account_Plan__c=:accountPlanId AND Fiscal_Year__c IN:lastThreeFiscalYearList ORDER BY Product_Solution__c]){
                    System.debug('buc::::::'+buc.Id + '__' + buc.Fiscal_Year__c);
                    //create a map of buc records wrt Product soln and category
                    if(bucMap.containsKey(buc.Product_Solution__c + '_' + buc.Product_Category__r.Name)){
                        bucMap.get(buc.Product_Solution__c + '_' + buc.Product_Category__r.Name).add(buc);
                    }else{
                        bucMap.put(buc.Product_Solution__c + '_' + buc.Product_Category__r.Name, new List<Bottom_Up_Construct__c>{buc});
                    }
                }
            
            System.debug('BUC List Size::'+ bucMap.values().size());
            Double currentYrTotalAirtelSpend = 0;Double currentYrTotalTotalSpend = 0;
            Double prev1YrTotalAirtelSpend = 0;Double prev1YrTotalTotalSpend = 0;
            Double prev2YrTotalAirtelSpend = 0;Double prev2YrTotalTotalSpend = 0;
            for(String prd: bucMap.keySet()){
                Map<String,Object> bucYrMap = new Map<String,Object>();
                bucYrMap.put('productSoln',prd.substring(0,prd.indexOf('_')));
                bucYrMap.put('productCategory',prd.substring(prd.indexOf('_')+1));
                Double currentYrAirtelSpend = 0; Double currentYrCompetitorSpend = 0; Double currentYrTotalSpend = 0;
                Double prev1YrAirtelSpend = 0;   Double prev1YrCompetitorSpend = 0;   Double prev1YrTotalSpend = 0;
                Double prev2YrAirtelSpend = 0;   Double prev2YrCompetitorSpend = 0;   Double prev2YrTotalSpend = 0;
                for(Bottom_Up_Construct__c buc:bucMap.get(prd)){
                    if(buc.Fiscal_Year__c == String.valueOf(currentYear)){
                        currentYrAirtelSpend += buc.Spends_with_Airtel__c ;
                        currentYrCompetitorSpend += buc.Total_Competitor_Spends__c ;
                        currentYrTotalSpend += (buc.Spends_with_Airtel__c + buc.Total_Competitor_Spends__c);
                    }else if(buc.Fiscal_Year__c == String.valueOf(prev1Year)){
                        prev1YrAirtelSpend += buc.Spends_with_Airtel__c ;
                        prev1YrCompetitorSpend += buc.Total_Competitor_Spends__c ;
                        prev1YrTotalSpend += (buc.Spends_with_Airtel__c + buc.Total_Competitor_Spends__c);
                    }else if(buc.Fiscal_Year__c == String.valueOf(prev2Year)){
                        prev2YrAirtelSpend += buc.Spends_with_Airtel__c ;
                        prev2YrCompetitorSpend += buc.Total_Competitor_Spends__c ;
                        prev2YrTotalSpend += (buc.Spends_with_Airtel__c + buc.Total_Competitor_Spends__c);
                    }
                }
                currentYrTotalAirtelSpend += currentYrAirtelSpend; currentYrTotalTotalSpend += currentYrTotalSpend;
                prev1YrTotalAirtelSpend += prev1YrAirtelSpend; prev1YrTotalTotalSpend += prev1YrTotalSpend;
                prev2YrTotalAirtelSpend += prev2YrAirtelSpend; prev2YrTotalTotalSpend += prev2YrTotalSpend;
                
                bucYrMap.put('currentYrAirtelSpend',currentYrAirtelSpend);
                bucYrMap.put('currentYrTotalSpend',currentYrTotalSpend);
                bucYrMap.put('Prev1YrAirtelSpend',Prev1YrAirtelSpend);
                bucYrMap.put('Prev1YrTotalSpend',Prev1YrTotalSpend);
                bucYrMap.put('Prev2YrAirtelSpend',Prev2YrAirtelSpend);
                bucYrMap.put('Prev2YrTotalSpend',Prev2YrTotalSpend);
                bucList.add(bucYrMap);
            }
            
            Map<String,Object> resultMap = new Map<String,Object>();
            resultMap.put('HistBUC',bucList);
            resultMap.put('currentYrTotalAirtelSpend'   ,currentYrTotalAirtelSpend);
            resultMap.put('currentYrTotalTotalSpend'    ,currentYrTotalTotalSpend);
            resultMap.put('prev1YrTotalAirtelSpend'     ,prev1YrTotalAirtelSpend);
            resultMap.put('prev1YrTotalTotalSpend'      ,prev1YrTotalTotalSpend);
            resultMap.put('prev2YrTotalAirtelSpend'     ,prev2YrTotalAirtelSpend);
            resultMap.put('prev2YrTotalTotalSpend'      ,prev2YrTotalTotalSpend);
            resultMap.put('currentYear'                 ,currentYear);
            resultMap.put('prev1Year'                   ,prev1Year);
            resultMap.put('prev2Year'                   ,prev2Year);
            System.debug('result::'+JSON.serialize(bucList));
            System.debug('currentYrTotalAirtelSpend::'+currentYrTotalAirtelSpend + ' currentYrTotalTotalSpend::'+currentYrTotalTotalSpend);
            output.put('result',resultMap);
        }
        
        catch(Exception ex){
            System.debug('DEBUGG exception '+ ex.getLineNumber()+ ' ' + ex.getMessage());
            ARTL_Logger.error(ARTL_Constants.CONTROLLER, 'ARTL_DRE_OpportunityOnAccountPlan.fetchHistoricalBUC', '', new Map<String, Object>{'Exception' => ex.getMessage(), 'LineNumber' => ex.getLineNumber()}, ex);
        }
    }
    
    private static void fetchFiscalYrOppList(Map<String, Object> inputs, Map<String, Object> output, Map<String, Object> options){
        // Retrieve the argument lists
        try{
            List<Object> arguments = (List<Object>)inputs.get('arguments');
            String accountId = (String) arguments[0];
            Integer fiscalYear = Integer.valueOf(arguments[1]);
            List<Map<String,Object>> oppList = new List<Map<String,Object>>();
            
            Date startDate = Date.newInstance(fiscalYear-1,4,1);
            Date endDate   = Date.newInstance(fiscalYear,3,31);
            for(Opportunity opp:[SELECT Id,CloseDate,Amount,ARTL_Comments__c,ARTL_Key_Competitors__c, Customer_Contact__r.Name,Description,Name,NextStep  FROM Opportunity WHERE AccountId =:accountId AND CloseDate >=: startDate AND CloseDate <=: endDate]){
                System.debug(opp.Name + '--'+ opp.CloseDate);
                Map<String,Object> oppMap = new Map<String,Object>();
                oppMap.put('sizing',opp.Amount);
                oppMap.put('comments',opp?.ARTL_Comments__c);
                oppMap.put('keyCompetitors',opp?.ARTL_Key_Competitors__c);
                oppMap.put('immediateSteps',opp?.NextStep);
                oppMap.put('closeDate',opp?.CloseDate);
                oppMap.put('keyStakeholder',opp?.Customer_Contact__r.Name);
                oppMap.put('name',opp.Name);
                oppMap.put('id',opp.Id);
                oppMap.put('description',opp?.Description);
                oppList.add(oppMap);
            }
            if(oppList.size() > 0) {
                output.put('result',oppList);
            }
        }catch(Exception ex){
            System.debug('DEBUGG exception '+ ex.getLineNumber()+ ' ' + ex.getMessage());
            ARTL_Logger.error(ARTL_Constants.CONTROLLER, 'ARTL_DRE_OpportunityOnAccountPlan.fetchFiscalYrOppList', '', new Map<String, Object>{'Exception' => ex.getMessage(), 'LineNumber' => ex.getLineNumber()}, ex);
        }
        
    }
}