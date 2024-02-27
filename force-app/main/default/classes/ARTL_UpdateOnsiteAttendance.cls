public class ARTL_UpdateOnsiteAttendance {

    @AuraEnabled
    public static void updateAttendance(String recordId,Decimal latitude,Decimal longitude){
        System.debug('RecordId'+recordId+'     latitude '+latitude+'    longitude '+longitude);
        
        List<Event> eventsToUpdate=New List<Event>();
        List<Event> events=[Select Id,Meeting_Location__Latitude__s,Meeting_Location__Longitude__s from Event where Id =:recordId];
        for(Event eventrecord : events){
            Event event1=New Event();
            event1.Id=eventrecord.Id;
            event1.Meeting_Location__Latitude__s=latitude;
            event1.Meeting_Location__Longitude__s=longitude;
            event1.vlocity_cmt__EventStatus__c = 'In Progress';
            eventsToUpdate.add(event1);
        }
        if(!eventsToUpdate.isEmpty()){
            update eventsToUpdate;
        }
    }
}