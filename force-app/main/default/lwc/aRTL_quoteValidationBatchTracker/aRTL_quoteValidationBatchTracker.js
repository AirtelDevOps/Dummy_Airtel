import { LightningElement,api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';
import successValidationTitle from '@salesforce/label/c.Success_validation_title';
import successValidationMessage from '@salesforce/label/c.Success_validation_message';
import artl_batchSuccessTitle from '@salesforce/label/c.artl_batchSuccessTitle';
import artl_batchSuccessMessage from '@salesforce/label/c.artl_batchSuccessMessage';
import artl_batchErrorTitle from '@salesforce/label/c.artl_batchErrorTitle';
import artl_batchErrorMessage from '@salesforce/label/c.artl_batchErrorMessage';
import getReportId from '@salesforce/apex/ARTL_QuoteValidationController.getReportId';

export default class ARTL_quoteValidationBatchTracker extends LightningElement {
    @track reportId='';
    label = {
        successValidationTitle,
        successValidationMessage,
        artl_batchSuccessTitle,
        artl_batchSuccessMessage,
        artl_batchErrorTitle,
        artl_batchErrorMessage
    };
    
    batchRunSuccess = '/event/ARTL_Common_Toast_Event__e';
    @api recordId;
    connectedCallback() {
        console.log(this.label.artl_batchErrorMessage);
        getReportId()
        .then(result=>{
            this.reportId=result;
            console.log(this.reportId);
        })
        .catch(error=>{
            console.log(error);
        });
        var self=this;
        const messageCallback = function (response) {
            console.log(response);
            console.log(self.reportId);
             if (response.data.payload.Sub_Event__c == 'Quote Validation Event'  && response.data.payload.Success__c == true && response.data.payload.Id__c==self.recordId) {
                self.errorValidationToast(self.label.artl_batchSuccessTitle,self.label.artl_batchSuccessMessage,'success');
            } 
            else if(response.data.payload.Sub_Event__c == 'Quote Validation Event' && response.data.payload.Success__c == false && response.data.payload.Id__c==self.recordId){
                console.log('inside else if');
               // console.log(response.data.payload.Message__c.toString());
                var baseURL=window.location.origin;
                var extraParams='/lightning/r/Report/'+self.reportId+'/view?';
                var parameters='fv0='+self.recordId;
                var URL=baseURL+extraParams+parameters;
                var Message=self.label.artl_batchErrorMessage;
                const event = new ShowToastEvent({
                    title: self.label.artl_batchErrorTitle,
                    message: Message,
                    messageData:[
                        response.data.payload.Message__c.toString(),
                    {
                        url: URL,
                        label: 'here',
                    },
                        ],
                    variant: 'error',
                    mode: 'sticky'
                });
                
                self.dispatchEvent(event);
            };
        }
            subscribe(self.batchRunSuccess, -1, messageCallback);         
    }

    errorValidationToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        }));
    }
}