/************************************************************************************************************************************************************************************************************
* @Author       : Akshay Kaushik <akshay.kaushik@salesforce.com>
* @Company      : Salesforce (SFI)
* @Date         : 09/12/2023
* @Test Class   : ARTL_GenerateLSIForNIPSHardwareTest
* @Description  : Generate LSI for NIPS order
*
* ----------------------- Changes Implemented / Modification Log --------------------------------------
*     Developer               Date           	  Comment
* ------------------      ---------------       -----------    
*  Akshay Kaushik          25/10/2023     		Initial Dev
******************************************************************************************************************************************************************************************************************/
global  with sharing class ARTL_GenerateLSIForNIPSHardware
{
    @InvocableMethod(label='Generate LSI For OrderItem')
    public static void GenerateLSI(List<FlowInput> flowInputs) {
        String OrderItemId = flowInputs.get(0).recordId;
        List<OrderItem> orderitemrecords = [select id,ARTL_LSI__c from orderitem where id =:OrderItemId];
        
        OrderItem orderitemrecord = orderitemrecords[0];
        System.debug(orderitemrecord+'orderitemrecord');
        //Generating LSI 
        				Datetime todaydate = Datetime.now();
            			//year =(string.valueOf(todayDate.year())).right(2);
                        //Date todaydate = Date.today();
                        String y = (string.valueOf(todayDate.year())).right(2);
                        String m = String.valueof(todaydate.month());
                        String d = String.valueof(todaydate.day());
                        if (m.length() == 1) {
                            m = '0' + m;
                        }
                        if (d.length() == 1) {
                            d = '0' + d;
                        }
                        String LSIDateFormat = d + m + y;
                        String LSIAutoNumber = string.valueOf((Integer) Math.floor(Math.random() * 90000) + 10000);
        orderitemrecord.ARTL_LSI__c = Decimal.valueOf('8000' + LSIDateFormat + LSIAutoNumber);
        update orderitemrecord;
        }
        //Flow Inputs
    public class FlowInput{
        @InvocableVariable(required=true) public Id recordId;
    }
    }