public with sharing class DynamicLWCDataTableController {
        @AuraEnabled(cacheable=true)
        public static DataTableResponse GetWrapperOfSObjectFieldColumnActionValues(String TableName)
        //public static List<DataTableColumns> GetWrapperOfSObjectFieldColumnActionValues(String TableName)

        {
            List<DataTableColumns> lstDataColumns            = new List<DataTableColumns>();
            List<string> columnList                          = new List<string>();
            List<string> fieldAPINameList                    = new List<string>();
            String CSVHeaders                                = '';
            Map<String,Object> csvHeadersMap				 = new Map<String,Object>();
            String Templateurl                               = '';
            System.debug('Inside Apex');
             DataTableResponse finalWrapper   = new DataTableResponse();
            try{
                Dynamic_Table_DataTable__mdt TableComponentMetadata = [SELECT Id, DeveloperName, Field_Value__c, Header_Value__c,CSVHeader__c,Template_URL__c  FROM Dynamic_Table_DataTable__mdt WHERE DeveloperName =: TableName];
                string baseUrl = System.URL.getOrgDomainUrl().toExternalForm();
                System.debug('base Url'+baseUrl);
                
            if(TableComponentMetadata.Header_Value__c != null)
            {
                CSVHeaders = TableComponentMetadata.CSVHeader__c;
                Templateurl = baseUrl+TableComponentMetadata.Template_URL__c;
                csvHeadersMap = (Map<String,Object>)JSON.deserializeUntyped(CSVHeaders);
                columnList = TableComponentMetadata.Header_Value__c.split(',');
                System.debug('COlumn'+columnList);
                System.debug('Header'+CSVHeaders);
            }
    
            if(TableComponentMetadata.Field_Value__c != null)
            {
                fieldAPINameList = TableComponentMetadata.Field_Value__c.split(',');
                System.debug('Fields'+fieldAPINameList);
            }
    
            for(integer i = 0; i < columnList.size(); i++)
            {
    
                DataTableColumns datacolumns = new DataTableColumns( columnList[i].trim() , 
                                                                    fieldAPINameList[i].substringBefore(':').trim(), 
                                                                    fieldAPINameList[i].substringAfter(':').trim());
    
                lstDataColumns.add(datacolumns);
                System.debug('Inside Apex columns'+lstDataColumns);
            }
    
           
           
            finalWrapper.lstDataTableColumns = lstDataColumns;
            finalWrapper.lstDataTableHeaders = csvHeadersMap;
            finalWrapper.templateUrl = Templateurl;
            System.debug('Inside Apex final template'+finalWrapper.templateUrl);
            System.debug('Inside Apex final wrapper'+finalWrapper.lstDataTableColumns);
            System.debug('Inside Apex final header'+finalWrapper.lstDataTableHeaders);
            System.debug('Inside Apex final wrapper'+finalWrapper);
            
            //return lstDataColumns;
            }catch(Exception ex){
            System.debug('DEBUGG ' + ex.getMessage() + ' ' + ex.getLineNumber());
            //outMap.put('errorMessage',ex.getMessage());
            ARTL_Logger.error(ARTL_Constants.CONTROLLER, 'DynamicLWCDataTableController:GetWrapperOfSObjectFieldColumnActionValues', '', new Map<String, Object>{'Exception' => ex.getMessage(), 'LineNumber' => ex.getLineNumber()}, ex);
        }
            return finalWrapper;
        }
    
       public class DataTableColumns {
            @AuraEnabled
            public String label {get;set;}
            @AuraEnabled       
            public String fieldName {get;set;}
            @AuraEnabled
            public String type {get;set;}
    
            public DataTableColumns(String label, String fieldName, String type)
            {
                this.label     = label;
                this.fieldName = fieldName;
                this.type      = type;          
            }
        }
        
        public class DataTableResponse {
            @AuraEnabled
            public List<DataTableColumns> lstDataTableColumns {get;set;}
            @AuraEnabled
            public Object lstDataTableHeaders {get;set;}
            @AuraEnabled
            public String templateUrl {get;set;}
           
        }
    }