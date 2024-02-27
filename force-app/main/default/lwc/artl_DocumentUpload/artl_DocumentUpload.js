import { LightningElement, track, api , wire } from 'lwc';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {  fireEvent } from 'c/pubsub';
import { CurrentPageReference } from 'lightning/navigation';
// import QUOTEFIELD from '@salesforce/schema/ARTL_Document__c.Quote__c';
// import OPPFIELD from '@salesforce/schema/ARTL_Document__c.Opportunity__c';

import makeDocUploadCallout from '@salesforce/apex/ARTL_DocumentUploadController.makeDocUploadCallout';

export default class Artl_DocumentUpload extends LightningElement {
    @track docRecordId = '';
    @track isModalOpen = false;
    @track fileUploadLabel = '';
    @track hasFile = false;
    @track isLoading = false;
    @track isDisabled = false;
    @api recordId;
    @api objectApiName;

    @wire(CurrentPageReference) pageRef;

    handleSuccess(event) {
        this.docRecordId = event.detail.id;
        // console.log('docRecordId :::' , this.docRecordId)
        // console.log('recordId  :::' , this.recordId)
        this.isModalOpen = true;
        this.startSpinner();
    }

    handleSubmit(event){
        event.preventDefault();
        const fields = event.detail.fields;
        console.log('Rec Id'+this.recordId);
        console.log('Object '+this.objectApiName);
        console.log('Fields '+ JSON.stringify(fields));
        if(this.objectApiName === 'Account'){
            fields['Account__c'] = this.recordId;
        } else if(this.objectApiName === 'Contact'){
            fields['Contact__c'] = this.recordId;
        } else if(this.objectApiName === 'Opportunity'){
            fields['Opportunity__c'] = this.recordId;
        } else if(this.objectApiName === 'Quote'){
            fields['Quote__c'] = this.recordId;
        } else if(this.objectApiName === 'Order'){
            fields['Order__c'] = this.recordId;
        }
        console.log('Fields- '+ JSON.stringify(fields));
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    startSpinner() {
        this.isLoading = true;
        this.isDisabled = true;
    }
    stopSpinner() {
        this.isLoading = false;
        this.isDisabled = false;
        this.docRecordId = '';
        this.fileUploadLabel = '';
        this.hasFile = false;
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
    }
    closeModal() {
        this.isModalOpen = false;
        if (!(this.hasFile)) {
            this.startSpinner();
            deleteRecord(this.docRecordId)
                .then(() => {
                    const evt = new ShowToastEvent({
                        title: 'File Upload Cancelled',
                        variant: 'info',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                    this.stopSpinner();
                })
                .catch((error) => {
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                    this.stopSpinner();
                });
        }
    }
    get acceptedFormats() {
        return ['.pdf', '.png', '.doc', '.docx', '.jpg', '.jpeg'];
    }
    handleDocName(event) {
        this.fileUploadLabel = 'Upload ' + event.target.value;
    }
    handleUploadFinished(event) {
        console.log('File::: ' + JSON.stringify(event.detail));
        this.hasFile = true;
        makeDocUploadCallout({ docId: this.docRecordId, cvId: event.detail.files[0].contentVersionId })
            .then((result) => {
                console.log('Result:: ' + result);
                if (result.callout) {
                    const evt = new ShowToastEvent({
                        title: 'Success',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                    //pubsub.fire('DocUploadSuccess',{});
                    fireEvent(this.pageRef, 'DocUploadSuccess', result);
                    this.stopSpinner();
                } else {
                    deleteRecord(this.docRecordId)
                        .then(() => {
                            const evt = new ShowToastEvent({
                                title: 'Error',
                                message: result.errorMsg,
                                variant: 'error',
                                mode: 'dismissable'
                            });
                            this.dispatchEvent(evt);
                            this.stopSpinner();
                        })
                        .catch((error) => {
                            const evt = new ShowToastEvent({
                                title: 'Error',
                                message: error,
                                variant: 'error',
                                mode: 'dismissable'
                            });
                            this.dispatchEvent(evt);
                            this.stopSpinner();
                        });
                }
            })
            .catch((error) => {
                console.log('Error:: ' + JSON.stringify(error));
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                this.stopSpinner();
            });
        this.closeModal();
    }
}