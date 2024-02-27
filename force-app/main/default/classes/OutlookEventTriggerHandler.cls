public class OutlookEventTriggerHandler {
    
    public static void handleAfterInsert(List<Event> newEvents) {

        try{
        Map<Id, Event> eventMap = new Map<Id, Event>(newEvents);

        for(Event ev : eventMap.values()){
            if(ev.MS_Teams_Meeting__c == true)
        {

        List<EventRelation> lstRelation = [SELECT ID, EventID,Relation.Type, RelationID,Relation.FirstName, Relation.Email,Relation.name FROM EventRelation where EventId = : eventMap.keySet()];
        set<id> eventRelationId = new set<id>();
        for(EventRelation evr : lstRelation){
            eventRelationId.add(evr.RelationID);
        }
       
        List<String> lstEmail = new list<String>();
        List<String> lstName = new list<String>();
        String transformdesc;
        String finaltransformdesc;
        String names;
        
        List<Contact> lstCon = [Select id, FirstName, LastName,Email from Contact where id = : eventRelationId];
        for(Contact con : lstCon){
            if(con.FirstName == NULL)
            names = con.LastName;
            else
            names = con.FirstName + ' '+con.LastName;
            lstEmail.add(con.Email);
            lstName.add(names);
        }
        
        List<Lead> lstLead = [Select id, LastName, FirstName, Email from Lead where id = : eventRelationId];
        for(lead le : lstLead){
            if(le.FirstName == NULL)
            names = le.LastName;
            else
            names = le.FirstName +' '+ le.LastName;
            lstEmail.add(le.Email);
            lstName.add(names);
        }
        
        List<User> lstUser = [Select id, LastName, FirstName, Email from User where id = : eventRelationId];
        for(User us : lstUser){
            if(us.FirstName == NULL)
            names = us.LastName;
            else
            names = us.FirstName +' '+ us.LastName;
            lstEmail.add(us.Email);
            lstName.add(names);
        } 

        List<Event> ExtraContact = [Select External_Contacts__c from Event where id = : eventMap.keySet()];
        if(ExtraContact.get(0).External_Contacts__c != NULL)
        {
        System.debug('Extra Contact' + ExtraContact);
        String ExtCon = ExtraContact.get(0).External_Contacts__c;
        System.debug('ExtCon' + ExtCon);
        List<String> searchData = new List<String>();
        searchData = ExtCon.split(',');
        System.debug('SearchData' + searchData);
         for(string ec : searchData)
         {
            lstEmail.add(ec);
            lstName.add(ec);
         }
        }

        List<Event> descript = [Select ARTL_Agenda__c from Event where id = : eventMap.keySet()];
        if(descript != NULL)
        {
        for(Event e : descript){
        transformdesc = e.ARTL_Agenda__c;
        }

        finaltransformdesc = transformdesc.replace('\n','<br>');
        }
        else
        finaltransformdesc ='';
            
        
            //    CreateOutlookEvent.setOutlookCalendarDate(ev.id,ev.StartDateTime, ev.EndDateTime,lstEmail, ev.Subject,lstName, ev.location, ev.Description, ev.ARTL_Agenda__c );
            CreateOutlookEvent.setOutlookCalendarDate(ev.id,ev.StartDateTime, ev.EndDateTime,lstEmail, ev.Subject,lstName, ev.location, finaltransformdesc, ev.ARTL_Agenda__c );
                
            }
        }
    }catch (exception ex) {
        handleException(ex);
}
    }
    private static void handleException(Exception ex) {
        System.debug('Error Message is ' + ex.getMessage());
        System.debug('Line Number is ' + ex.getLineNumber());
        System.debug('Stack Trace String is ' + ex.getStackTraceString());
    }
}