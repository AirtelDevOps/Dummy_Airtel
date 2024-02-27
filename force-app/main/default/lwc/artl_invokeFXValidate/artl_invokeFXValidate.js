import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { getDataHandler } from "vlocity_cmt/utility";
import { CloseActionScreenEvent } from "lightning/actions";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from 'lightning/navigation';
import checkFxValidationRequired from '@salesforce/apex/ARTL_ValidateChangeEffectiveDate.checkFXvalidatedDate';
import invokeFXValidate from '@salesforce/apex/ARTL_ValidateChangeEffectiveDate.invokeFXValidationAPI';
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';

export default class artl_invokeFXValidate extends NavigationMixin(LightningElement) {
    @api recordId;
    @api invoke() {
        console.log('recordID=>' + this.recordId);
        this.checkFXDateValidationIsNeeded();
        //this.invokeFXDateValidation();
    }

    checkFXDateValidationIsNeeded() {
        checkFxValidationRequired({ quoteId: this.recordId })
            .then(result => {
                console.log('from apex then');
                this.res = result;
                console.log('need fx validation???==> ' + this.res)
                console.log('need fx validation???==> ' + JSON.stringify(this.res))
                if (this.res == true) {
                    this.showSuccessMsg();
                    let input={"quoteId": this.recordId,"processName":"FXValidateAPI"}
                    let output={}
                    let option={}

                    invokeFXValidate({quoteId: this.recordId})
                        .then(result => {
                            console.log('from apex then');
                            this.res = result;
                            console.log('need fx validation???==> ' + this.res)
                            console.log('need fx validation???==> ' + JSON.stringify(this.res))
                            
                        })
                        .catch(error => {
                            console.error('Error from Apex:', error);
                            this.error = error;
                        });

                } else {
                    this.showErrorgMsg();
                }
            })
            .catch(error => {
                console.error('Error from Apex:', error);
                this.error = error;
            });
    }
    invokeFXDateValidation() {
        console.log('artl_invokeFXValidate.connectedCallback.recordId' + this.recordId);
        let recordObj = { QuoteId: this.recordId };
        console.log('artl_invokeFXValidate.connectedCallback.recordObj' + JSON.stringify(recordObj));

        let requestData = {
            "type": "integrationprocedure",
            "value": {
                "ipMethod": "ARTL_FXValidateDate",
                "inputMap": recordObj,
                "optionsMap": ''
            }
        }
        getDataHandler(JSON.stringify(requestData)).then(response => {
            this.ipResult = JSON.parse(response);
            console.log('ipresult=>' + JSON.stringify(this.ipResult))
            try {
                this.updateResponse = this.ipResult.IPResult;
                //this.ShowToast("Success", "Record updated successfully", "success", "dismissable");
                console.log("updateResponse::" + JSON.stringify(this.updateResponse));
                this.showSuccessMsg();
            }
            catch (err) {
                //this.ShowToast("Error", err, "error", "dismissable");
                console.log("updateResponse::" + JSON.stringify(err));
                this.showErrorgMsg();
            }

        })


    }

    showSuccessMsg() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'FX Validate',
                message: 'Quote Sent for FX Validation ',
                variant: 'success'
            }),
        );
    }

    showErrorgMsg() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'FX Validate',
                message: 'Quote Does not need FX Validation ',
                variant: 'error'
            }),
        );
    }
}