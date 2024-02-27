import { LightningElement, api } from 'lwc';
import { getDataHandler } from "vlocity_cmt/utility";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
export default class Artl_invokeAttributeValidation extends LightningElement {
    @api recordId;
    @api invoke() {
        // Log the record ID for debugging purposes
        console.log('recordID=>' + this.recordId);


        // Invoke IP for attribute validation
        this.invokeAttrValidationIP();
    }

    invokeAttrValidationIP(){
        let recordObj = { quoteId: this.recordId };
        let requestData = {
            "type": "integrationprocedure",
            "value": {
                "ipMethod": "ARTL_ValidateAttributes",
                "inputMap": recordObj,
                "optionsMap": ''
            }
        };

        
        getDataHandler(JSON.stringify(requestData)).then(response => {
            this.ipResult = JSON.parse(response)?.IPResult;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.ipResult?.errorMsg ? 'Error' : 'Success',
                    message : this.ipResult?.errorMsg || 'Successfully invoked IP',
                    variant: this.ipResult?.errorMsg ? 'error' : 'success'
                })
            );

            getRecordNotifyChange([{ recordId: this.recordId }]);
        });
        
    }
}