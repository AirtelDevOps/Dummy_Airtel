import { LightningElement,api,wire,track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { CurrentPageReference } from 'lightning/navigation';
import getReportId from '@salesforce/apex/ARTL_QuoteValidationController.getReportId';
export default class ARTL_redirectToReport extends LightningElement {
    @api recordId;
    @track reportId='';

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
        getReportId()
        .then(result=>{
            this.reportId=result;
             var baseURL=window.location.origin;
            var extraParams='/lightning/r/Report/'+this.reportId+'/view?';
            var parameters='fv0='+this.recordId;
            var URL=baseURL+extraParams+parameters;
            console.log(URL);
            window.location.href=URL;
            console.log(this.reportId);
        })
        .catch(error=>{
            console.log(error);
        });
        console.log('recordId'+this.recordId);
        //this.dispatchEvent(new CloseActionScreenEvent());
       
    }
}