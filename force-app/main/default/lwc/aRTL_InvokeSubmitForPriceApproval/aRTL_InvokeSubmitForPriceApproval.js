// Import necessary modules from the Lightning Web Components framework and Salesforce UI API
import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Toast from 'lightning/toast';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import invokeDOAApproval from '@salesforce/apex/ARTL_InvokeDOAApprovalProcessHelper.invokeDOAApproval';
import checkQuoteIsInPendingApproval from '@salesforce/apex/ARTL_InvokeDOAApprovalProcessHelper.checkQuoteIsInPendingApproval';
// Import the field API names for the Quote object
import ID_FIELD from "@salesforce/schema/Quote.Id";
import STATUS_FIELD from '@salesforce/schema/Quote.Status';
import VALIDATION_FIELD from '@salesforce/schema/Quote.ARTL_ValidateAttributeFieldStatus__c';

//const validationField = [VALIDATION_FIELD];

export default class ARTL_InvokeSubmitForPriceApproval extends LightningElement {
    // Expose the recordId property to allow passing the record ID from the Lightning Record Page
    @api recordId;

    // Use the wire service to retrieve the current value of the Status field on the Quote record
    @wire(getRecord, { recordId: '$recordId', fields: [STATUS_FIELD, VALIDATION_FIELD] })
    quote;

    // Public method to be invoked from the parent component or record page
    @api invoke() {
        // Log the record ID for debugging purposes
        console.log('recordID=>' + this.recordId);

        if(this.quote?.data?.fields?.ARTL_ValidateAttributeFieldStatus__c?.value === 'In Progress' || this.quote?.data?.fields?.ARTL_ValidateAttributeFieldStatus__c?.value === 'Failed'){
            this.ShowToast('Error', 'Attribute Validation is '+this.quote.data.fields.ARTL_ValidateAttributeFieldStatus__c.value + '!! Please click on Validate Attribute button!!', 'error', 'dismissable');
        }
         // Invoke the method for DOA approval
        else{
            this.invokeDOAApprovalMethod();
        }
        
    }

    // Method to update the Quote record's status to 'DOA Approved'
    invokeDOAApprovalMethod() {

        this.invokeHelperMethod();
        //this.refreshQuoteRecord();

    }

    // Method to refresh the Quote record using LDS after the update
    refreshQuoteRecord() {
        this.dispatchEvent(new CustomEvent('force:refreshView'));
    }

    // Getter to retrieve the current value of the Quote record's status
    get status() {
        return getFieldValue(this.quote.data, STATUS_FIELD);
    }
    invokeHelperMethod() {


        checkQuoteIsInPendingApproval({ quoteId: this.recordId })
            .then(result => {
                console.log('from apex then');
                this.res = result;
                console.log('have approval history' + this.res)
                if (this.res == true) {
                    console.log('Error toast');

                    this.ShowToast('Error', 'Quote is in an active approval process; Quote is not submitted for DOA Approval', 'error', 'dismissible');
                    console.log('Error toast showed');
                }
                else {
                    this.updateStatusToInProgress();
                    this.ShowToast('Success', 'Quote is Submitted for Approval', 'success', 'dismissible');

                    invokeDOAApproval({ quoteId: this.recordId })
                        .then(result => {

                            console.log('from apex then');
                            this.res = result;
                            console.log('this.res', this.res);
                            this.refreshQuoteRecord();
                            if (this.res && this.res != null) {
                                console.log('if ' + JSON.stringify(this.res));
                            }
                           // this.refreshQuoteRecord();
                        })
                        .catch(error => {
                            console.error('Error from Apex:', error);
                            this.error = error;
                        });



                }


            })
            .catch(error => {
                console.error('Error from Apex:', error);
                this.error = error;
            });
    }


    ShowToast(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }
    updateStatusToInProgress() {
        // Create an object to hold the updated field values
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[STATUS_FIELD.fieldApiName] = 'DOA Approval in Progress';

        // Prepare the record input for the updateRecord function
        const recordInput = { fields };

        // Use the updateRecord function to update the Quote record
        updateRecord(recordInput)
            .then(result => {
                // Log a success message and refresh the quote record
                console.log('Record updated successfully:', result);
                this.refreshQuoteRecord();

            })
            .catch(error => console.error('Error updating status:', error));
    }
}