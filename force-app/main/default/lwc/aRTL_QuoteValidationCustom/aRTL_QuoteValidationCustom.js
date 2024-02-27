import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import checkQuoteValidation from '@salesforce/apex/ARTL_QuoteValidationController.checkQuoteValidation';
import warningValidationTitle from '@salesforce/label/c.Warning_validation_title';
import successValidationTitle from '@salesforce/label/c.Success_validation_title';
import errorValidationTitle from '@salesforce/label/c.Error_validation';
import successValidationMessage from '@salesforce/label/c.Success_validation_message';
import errorValidationMessage from '@salesforce/label/c.Error_validation_message';
import quoteEnrichValidationMsg from '@salesforce/label/c.Quote_Enrich_Validation_Msg';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';

export default class aRTL_QuoteValidationCustom extends NavigationMixin(LightningElement) {
    batchRunSuccess = '/event/ARTL_Common_Toast_Event__e';
    @api recordId;
    @api objectApiName;
    label = {
        warningValidationTitle,
        successValidationTitle,
        errorValidationMessage,
        successValidationMessage,
        errorValidationTitle,
        quoteEnrichValidationMsg

    };
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        console.log('ARTL_QuoteValidationController.getStateParameters.recordIdBefore' + this.recordId);
        if (this.recordId === undefined) {
            if (currentPageReference) {
                console.log('current page reference: ' + currentPageReference);
                this.recordId = currentPageReference.state.recordId;
                console.log('ARTL_QuoteValidationController.getStateParameters.recordId' + this.recordId);
            }
        }
    }

    connectedCallback() {
        console.log('inside connected callback');
        checkQuoteValidation({ recId: this.recordId }).then(res => {
            console.log('@@@res =', res);
            if (typeof res === 'string' && res === this.label.successValidationTitle) {
                this.dispatchEvent(new CloseActionScreenEvent());
                this.errorValidationToast(this.label.successValidationTitle,this.label.successValidationMessage,'success');
                
                /*const self = this;
                    const messageCallback = function (response) {
                        console.log(response);
                        //console.log('ID 2>>> ' + self.recordId);
                        if (response.data.payload.Sub_Event__c == 'Quote Validation Event'  && response.data.payload.Success__c == false) {
                            //console.log('ID 3>>> ' + self.recordId);
                            console.log(response.data.payload.Message__c);
                            self.errorValidationToast(self.label.errorValidationTitle, JSON.stringify(response.data.payload.Message__c), 'error');
                            self.dispatchEvent(new CloseActionScreenEvent());
                        } else if(response.data.payload.Sub_Event__c == 'Quote Validation Event' && response.data.payload.Success__c == true){
                            //console.log('#### Subscribed event doesnt match with quote id');
                            self.errorValidationToast('Validation Success','valdiation successfull','success');
                            self.dispatchEvent(new CloseActionScreenEvent());
                        }
                    };
                    subscribe(this.batchRunSuccess, -1, messageCallback);*/

                //this.showSuccessMsg();
            } else {
                
                console.log('res is else condition', res);
                const errorStrings = res;
                this.dispatchEvent(new CloseActionScreenEvent());
                if(errorStrings.includes('Fx Validation')){
                    this.errorValidationToast(this.label.errorValidationTitle, errorStrings, 'error');
                }else{
                    this.errorValidationToast(this.label.errorValidationTitle, this.label.quoteEnrichValidationMsg+ errorStrings, 'error');
                }
            }
        }).catch(error => {
            console.log('error in validateDoc ', error);
        });
    }

    errorValidationToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        }));
    }

    /*showWarningMsg(message) {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Warning',
            message: message,
            variant: 'warning',
        }));
    }

    showSuccessMsg() {
        this.dispatchEvent(new ShowToastEvent({
            title: 'In-Progress',
            message: 'Validation In- Progress',
            variant: 'success',
        }));
    }

    showErrorMsg() {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Approval',
            message: 'Process failed. Already in Process',
            variant: 'error',
        }));
    }*/
}