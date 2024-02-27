public class CreateOutlookEvent {
    @future(callout=true)
    public static void setOutlookCalendarDate(String eventIds, dateTime StartDate, dateTime EndTime, List<String> attendeeEmail, String Subject, List<String> name, String location, String Description, String Agenda){
       try{    
            datetime dt = System.now();
            String locationValue = (location != null) ? location : '';
            String descriptionValue = (Description != null) ? Description : '';
            String agendaValue = (Agenda != null) ? Agenda : '';
            String CompanyName;
         //   String companyName = [Select id,ARTL_Account_Name__r.name from Event where id = : eventIds ].ARTL_Account_Name__r.name;

            event eventrecord = [select id, whoid, whatid, what.name from event where id = : eventIds LIMIT 1];
            if(eventrecord != NULL)
        {
            if(eventrecord.whatid != NULL)
            CompanyName = eventrecord.what.name;
            else if (eventrecord.whoid != NULL)
            {
            if(String.valueOf(eventrecord.whoid).startsWithIgnoreCase('00Q'))
            CompanyName = [select Company from lead where id = : eventrecord.whoid LIMIT 1].company;
            if(String.valueOf(eventrecord.whoid).startsWithIgnoreCase('003'))  
            CompanyName = [select account.name from contact where id = : eventrecord.whoid LIMIT 1].account.name;
            }
        }
            if (String.isEmpty(CompanyName))
            CompanyName = '';
                
            String startdt = StartDate.format('yyyy-MM-dd HH:mm:ss', 'IST');
            List<String> lstAttendeeNames = new List<String>();
            for (String nm : name) {
                lstAttendeeNames.add(nm);
            }
            String AttendeeNames = String.join(lstAttendeeNames, ',');
            String jsonRequestBody = '{"attendees": [';
            
            for (Integer i = 0; i < attendeeEmail.size(); i++) {
                String attendeeJson = '{"emailAddress": {"address": "' + attendeeEmail[i] + '", "name": "'+lstAttendeeNames[i]+'"}, "type": "Required"},';
                jsonRequestBody += attendeeJson;
            }

            http  http = new http();
            httpRequest req = new httpRequest();
			String bodyRequest = descriptionValue;
            //String bodyRequest = '<div id=mapDiv bgcolor=white align=justify><img src=https://assets.airtel.in/static-assets/siebel/airtel-one.jpg><br></br>Dear ' + CompanyName + ',<br></br><b>Greetings from Airtel Business!</b><br></br>Further to our discussion, please consider this meeting invite as a placeholder for below agenda:<br></br><table border=0 width=70%><tr><td colspan=1><center><b>Agenda</b></center></td></tr></table><table border=1 rules=all width=70%><tr><td colspan=1>' + descriptionValue + '</td></tr></table><br></br><table border=0 width=70% height=100><tr><td colspan=4><center><b>Meeting Schedule</b></center></td></tr><tr><td><img src=https://assets.airtel.in/static-assets/siebel/calenderb.jpg></td><td><b>Date & Time:  </b>'+ startdt +'</td><td>  <img src=https://assets.airtel.in/static-assets/siebel/company.jpg></td><td><b>  Company Name:  </b>' + companyName + '</td></tr></table><br></br><br></br>The Attendees are : <b>' + AttendeeNames + '</b><br></br>Please let me know if you would like to add anything or make any changes. Assuring you of our best services.<br></br>You may download and save the attachment for meeting details.<br></br><br></br>Regards,<br>'+ UserInfo.getName() + '</br><br></br>Note: You can accept or decline the meeting using the buttons at top of this invite. <br></br><br></br><table border=0 bgcolor=#384152 width=70%><tr><td colspan=3><font color=white><center><small>Visit <b><a href=https://www.airtel.in/business style=color:#FFFFFF;>https://www.airtel.in/business</b></a> or call us at <b>1800 103 8325</b> or drop us an email at <a href=mailto:airtelforbusiness@airtel.com style=color:#FFFFFF><b>airtelforbusiness@airtel.com</b></a></small></center></font></th></tr><tr><td rowspan=2 style=text-align:right><font color=white>FOLLOW US&nbsp;&nbsp;&nbsp;&nbsp;<a href=https://www.linkedin.com/company/airtel-business/ target=_blank><img src=https://assets.airtel.in/static-assets/siebel/linked-in.jpg></a>&nbsp;&nbsp;<a href=https://www.youtube.com/channel/UC62RQR1TkP_945zTN6Jwecg target=_blank><img src=https://assets.airtel.in/static-assets/siebel/yt.jpg></a>&nbsp;&nbsp;</font></td><td rowspan =2><center>&nbsp;&nbsp;&nbsp;&nbsp;<img src=https://assets.airtel.in/static-assets/siebel/footer-verticle-sep.jpg>&nbsp;&nbsp;&nbsp;&nbsp;</center></td><td><img src=https://assets.airtel.in/static-assets/siebel/email.jpg> <font color=white>&nbsp;airtelforbusiness@airtel.com</font></td></tr><tr><td><img src=https://assets.airtel.in/static-assets/siebel/web.jpg><font color=white>&nbsp;www.airtel.in/business</font></td></tr><tr><td colspan=3><center><font color=white><small>If you no longer wish to receive these mails, you may unsubscribe any time by sending an email at: <b>airtelforbusiness@airtel.com</b></small></font></center></td></tr></table>';
            //String bodyRequest = '<div id=mapDiv bgcolor=white align=justify><img src=https://assets.airtel.in/static-assets/siebel/airtel-one.jpg><br></br>Dear ' + CompanyName + ',<br></br><b>Greetings from Airtel Business!</b><br></br>Further to our discussion, please consider this meeting invite as a placeholder for below agenda:<br></br><table border=0 width=70%><tr><td colspan=1><center><b>Agenda</b></center></td></tr></table><table border=1 rules=all width=70%><tr><td colspan=1>' + agendaValue + '</td></tr></table><br></br><table border=0 width=70% height=100><tr><td colspan=4><center><b>Meeting Schedule</b></center></td></tr><tr><td><img src=https://assets.airtel.in/static-assets/siebel/calenderb.jpg></td><td><b>Date & Time:  </b>'+ startdt +'</td><td>  <img src=https://assets.airtel.in/static-assets/siebel/company.jpg></td><td><b>  Company Name:  </b>' + companyName + '</td></tr></table><br></br><br></br>The Attendees are : <b>' + AttendeeNames + '</b><br></br>Please let me know if you would like to add anything or make any changes. Assuring you of our best services.<br></br>You may download and save the attachment for meeting details.<br></br><br></br>Regards,<br>'+ UserInfo.getName() + '</br><br></br>Note: You can accept or decline the meeting using the buttons at top of this invite. <br></br><br></br><table border=0 bgcolor=#384152 width=70%><tr><td colspan=3><font color=white><center><small>Visit <b><a href=https://www.airtel.in/business style=color:#FFFFFF;>https://www.airtel.in/business</b></a> or call us at <b>1800 103 8325</b> or drop us an email at <a href=mailto:airtelforbusiness@airtel.com style=color:#FFFFFF><b>airtelforbusiness@airtel.com</b></a></small></center></font></th></tr><tr><td rowspan=2 style=text-align:right><font color=white>FOLLOW US&nbsp;&nbsp;&nbsp;&nbsp;<a href=https://www.linkedin.com/company/airtel-business/ target=_blank><img src=https://assets.airtel.in/static-assets/siebel/linked-in.jpg></a>&nbsp;&nbsp;<a href=https://www.youtube.com/channel/UC62RQR1TkP_945zTN6Jwecg target=_blank><img src=https://assets.airtel.in/static-assets/siebel/yt.jpg></a>&nbsp;&nbsp;</font></td><td rowspan =2><center>&nbsp;&nbsp;&nbsp;&nbsp;<img src=https://assets.airtel.in/static-assets/siebel/footer-verticle-sep.jpg>&nbsp;&nbsp;&nbsp;&nbsp;</center></td><td><img src=https://assets.airtel.in/static-assets/siebel/email.jpg> <font color=white>&nbsp;airtelforbusiness@airtel.com</font></td></tr><tr><td><img src=https://assets.airtel.in/static-assets/siebel/web.jpg><font color=white>&nbsp;www.airtel.in/business</font></td></tr><tr><td colspan=3><center><font color=white><small>If you no longer wish to receive these mails, you may unsubscribe any time by sending an email at: <b>airtelforbusiness@airtel.com</b></small></font></center></td></tr></table>';
            //String bodyRequest = '<div id=mapDiv bgcolor=white align=justify><img src=https://assets.airtel.in/static-assets/siebel/airtel-one.jpg><br></br>Dear ' + companyName + ',<br></br><b>Greetings from Airtel Business!</b><br></br>Further to our discussion, please consider this meeting invite as a placeholder for below agenda:<br></br><table border=0 width=70%><tr><td colspan=1><center><b>Agenda</b></center></td></tr></table><table border=1 rules=all width=70%><tr><td colspan=1>' + agendaValue + '</td></tr></table><br></br><table border=0 width=70% height=100><tr><td colspan=4><center><b>Meeting Schedule</b></center></td></tr><tr><td><img src=https://assets.airtel.in/static-assets/siebel/calenderb.jpg></td><td><b>Date & Time:  </b>'+ startdt +'</td><td>  <img src=https://assets.airtel.in/static-assets/siebel/company.jpg></td><td><b>  Company Name:  </b>' + companyName + '</td></tr></table><br></br><br></br>The Attendees are : <b>' + AttendeeNames + '</b><br></br>Please let me know if you would like to add anything or make any changes. Assuring you of our best services.<br></br>You may download and save the attachment for meeting details.<br></br><br></br>Regards,<br>'+ UserInfo.getName() + '</br><br></br><br></br><table border=0 bgcolor=#384152 width=70%><tr><td colspan=3><font color=white><center><small>Visit <b><a href=https://www.airtel.in/business style=color:#FFFFFF;>https://www.airtel.in/business</b></a> or call us at <b>1800 103 8325</b> or drop us an email at <a href=mailto:airtelforbusiness@airtel.com style=color:#FFFFFF><b>airtelforbusiness@airtel.com</b></a></small></center></font></th></tr><tr><td rowspan=2 style=text-align:right><font color=white>FOLLOW US&nbsp;&nbsp;&nbsp;&nbsp;<a href=https://www.linkedin.com/company/airtel-business/ target=_blank><img src=https://assets.airtel.in/static-assets/siebel/linked-in.jpg></a>&nbsp;&nbsp;<a href=https://www.youtube.com/channel/UC62RQR1TkP_945zTN6Jwecg target=_blank><img src=https://assets.airtel.in/static-assets/siebel/yt.jpg></a>&nbsp;&nbsp;</font></td><td rowspan =2><center>&nbsp;&nbsp;&nbsp;&nbsp;<img src=https://assets.airtel.in/static-assets/siebel/footer-verticle-sep.jpg>&nbsp;&nbsp;&nbsp;&nbsp;</center></td><td><img src=https://assets.airtel.in/static-assets/siebel/email.jpg> <font color=white>&nbsp;airtelforbusiness@airtel.com</font></td></tr><tr><td><img src=https://assets.airtel.in/static-assets/siebel/web.jpg><font color=white>&nbsp;www.airtel.in/business</font></td></tr><tr><td colspan=3><center><font color=white><small>If you no longer wish to receive these mails, you may unsubscribe any time by sending an email at: <b>airtelforbusiness@airtel.com</b></small></font></center></td></tr></table>';
            // String bodyRequest = '<div id=mapDiv bgcolor=white align=justify><img src=https://assets.airtel.in/static-assets/siebel/airtel-one.jpg><br></br>Dear ' + companyName + ',<br></br><b>Greetings from Airtel Business!</b><br></br>Further to our discussion, please consider this meeting invite as a placeholder for below agenda:<br></br><table border=0 width=70%><tr><td colspan=1><center><b>Agenda</b></center></td></tr><tr><td colspan=1>' + descriptionValue + '</td></tr></table><br></br><br></br><table border=0 width=70%><tr><td colspan=4><center><b>Meeting Schedule</b></center></td></tr><tr><td><img src=https://assets.airtel.in/static-assets/siebel/calenderb.jpg></td><td><b>Date & Time:  </b>'+ startdt +'</td><td>  <img src=https://assets.airtel.in/static-assets/siebel/company.jpg></td><td><b>  Company Name:  </b>' + companyName + '</td></tr></table><br></br><br></br>The Attendees are : <b>' + AttendeeNames + '</b><br></br>Please let me know if you would like to add anything or make any changes. Assuring you of our best services.<br></br>You may download and save the attachment for meeting details.<br></br><br></br>Regards,<br>'+ UserInfo.getName() + '</br><br></br><br></br><table border=0 bgcolor=#384152 width=70%><tr><td colspan=3><font color=white><center><small>Visit <b><a href=https://www.airtel.in/business style=color:#FFFFFF;>https://www.airtel.in/business</b></a> or call us at <b>1800 103 8325</b> or drop us an email at <a href=mailto:airtelforbusiness@airtel.com style=color:#FFFFFF><b>airtelforbusiness@airtel.com</b></a></small></center></font></th></tr><tr><td rowspan=2 style=text-align:right><font color=white>FOLLOW US&nbsp;&nbsp;&nbsp;&nbsp;<a href=https://www.linkedin.com/company/airtel-business/ target=_blank><img src=https://assets.airtel.in/static-assets/siebel/linked-in.jpg></a>&nbsp;&nbsp;<a href=https://www.youtube.com/channel/UC62RQR1TkP_945zTN6Jwecg target=_blank><img src=https://assets.airtel.in/static-assets/siebel/yt.jpg></a>&nbsp;&nbsp;</font></td><td rowspan =2><center>&nbsp;&nbsp;&nbsp;&nbsp;<img src=https://assets.airtel.in/static-assets/siebel/footer-verticle-sep.jpg>&nbsp;&nbsp;&nbsp;&nbsp;</center></td><td><img src=https://assets.airtel.in/static-assets/siebel/email.jpg> <font color=white>&nbsp;airtelforbusiness@airtel.com</font></td></tr><tr><td><img src=https://assets.airtel.in/static-assets/siebel/web.jpg><font color=white>&nbsp;www.airtel.in/business</font></td></tr><tr><td colspan=3><center><font color=white><small>If you no longer wish to receive these mails, you may unsubscribe any time by sending an email at: <b>airtelforbusiness@airtel.com</b></small></font></center></td></tr></table>';
            jsonRequestBody = jsonRequestBody.removeEnd(',');
            jsonRequestBody += '], "subject": "' + Subject + '", "start": {"dateTime": "' + StartDate + '", "timeZone": "UTC"}, "end": {"dateTime": "' + EndTime + '", "timeZone": "UTC"} , "transactionId":"7E163156-7762-4BEB-A1C6-' + dt + StartDate + '", "body": {"contentType": "HTML", "content": "' + bodyRequest + '"},"organizer": {"emailAddress": {"name": "' + UserInfo.getName() + '","address": "' + UserInfo.getUserEmail() + '"}}, "location":{"displayName":"' + locationValue + '"},"isOnlineMeeting":true}';
            req.setBody(jsonRequestBody);
            req.SetMethod('POST');
            req.setHeader('Accept', 'application/json');
            req.setHeader('Content-Type', 'application/json');
            req.setEndpoint('callout:Teams_Integration');
            httpResponse response = http.send(req);
            
            String strResponse = response.getBody();
            System.debug('HTTP Response Body' + strResponse);

            Event evtdetail = (Event)JSON.deserialize(strResponse, Event.class);
            System.debug('HTTP Deserialized' + evtdetail);
            System.debug('HTTP Deserialized id' + evtdetail.Id);

          /*  List<Event> FinalEv1 = new List<Event>();
            event Ev1 = [select id,Outlook_Id__c from event where id = : eventIds LIMIT 1];

           // Map<string,Object> jsonMap = (Map<string,Object>)JSON.deserializeUntyped(strResponse);


            Ev1.Outlook_Id__c = evtdetail.Id;
            FinalEv1.add(Ev1);
            update FinalEv1; */

            handleHttpResponse(eventIds, response, Subject, StartDate, EndTime );
           
        }catch ( exception ex ) {
            handleException(ex);
        }
    }
    
    private static void handleHttpResponse(String eventIds, httpResponse response, String Subject, dateTime StartDate, dateTime EndTime) {
        if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
            Event sfEvent = new Event(Id = eventIds, vlocity_cmt__EventStatus__c = 'Scheduled');
            update sfEvent;

        } else {
            Event sfEvent = new Event(Id = eventIds, System_Error__c = response.getStatusCode() + ' ' + response.getStatus(), vlocity_cmt__EventStatus__c = 'Error');
            update sfEvent;
            sendErrorEmail(UserInfo.getUserEmail(), Subject, StartDate, EndTime );
        }
    }
    
    private static void sendErrorEmail(String userEmail, String Subject, dateTime StartDate, dateTime EndTime ) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.toAddresses = new String[] {userEmail };
                message.subject = 'Error In Creating Outlook Event';
                message.setHtmlBody('Snap ! There is an error in setting up the meeting in MS Teams with the below deatils  <br/><p> <b>Subject "'+Subject+'",<p> Start Date "'+StartDate+'", <p> End Date "'+EndTime+'"</b> <p><p> Please delete the Salesforce meeting so that your contacts are notified. Then, try to recreate a new meeting.<p> Please contact your system administrator if this error reoccurs.</p> ');
                Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);  
    }
    private static void handleException(Exception ex) {
        System.debug('Error Message is ' + ex.getMessage());
        System.debug('Line Number is ' + ex.getLineNumber());
        System.debug('Stack Trace String is ' + ex.getStackTraceString());
    }    
}