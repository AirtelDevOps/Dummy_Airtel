import { LightningElement, api, wire, track } from 'lwc';
import LOCALE from '@salesforce/i18n/locale';
import CURRENCY from '@salesforce/i18n/currency';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import getARTLJSONAttribute from '@salesforce/apex/CrcconfigureAttributeController.getJSONAttribute';
import saveAttributeDetails from '@salesforce/apex/CrcconfigureAttributeController.saveAttribute';
import {RefreshEvent} from 'lightning/refresh';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CrcconfigureAttribute extends LightningElement {
    @api recordId;
    @track attributedata;
    @track initialdata;
    @track selectedvalue = [];
    showSpinner = false;
    disableButton = true;

    connectedCallback() {
        this.fetchAttributeDetails();
    }

    fetchAttributeDetails() {
        this.showSpinner = true;
        getARTLJSONAttribute({ recordId: this.recordId })
            .then((result) => {
                if (result) {
                    console.log('inside if result--');
                    console.log('this.data---' + JSON.stringify(result));
                    this.attributedata = result;
                    this.showSpinner = false;
                } else {
                    console.log('inside else');
                    //  this.showSpinner = false;
                }
            })
            .catch((error) => {
                console.log('inside catch');
                this.showSpinner = false;
                const newEvent = new ShowToastEvent({
                    title: 'Error Notification',
                    message: error.message,
                    variant: 'Error'
                });
                this.dispatchEvent(newEvent);
                // this.showSpinner = false;
            });
    }

    handleAttribueValueChange(event) {
        this.disableButton = false;
        console.log('inside handle change');
        // console.log('this.attributedata---'+JSON.stringify(this.attributedata));
        console.log('value**** ' + event.target.value);
        console.log('name**** ' + event.target.name);

        if (this.selectedvalue != null && this.selectedvalue != undefined) {
            let notExist = true;
            for (var i in this.selectedvalue) {
                if (this.selectedvalue[i].attCode == event.target.name) {
                    this.selectedvalue[i].valueSelected = event.target.value;
                    notExist = false;
                    break; //Stop this loop, we found it!
                }
            }
            if (notExist) {
                this.selectedvalue.push({ attCode: event.target.name, valueSelected: event.target.value });
            }
        } else {
            this.selectedvalue.push({ attCode: event.target.name, valueSelected: event.target.value });
        }
        console.log('this.selectedvalue-----' + JSON.stringify(this.selectedvalue));
    }

    handleSave() {
        console.log('handle save---' + JSON.stringify(this.selectedvalue));
        this.showSpinner = true;
        saveAttributeDetails({ recordId: this.recordId, selectedAttJSON: this.selectedvalue })
            .then((result) => {
                if (result == 'success') {
                    console.log('inside if result-- handleSave');
                    console.log('this.data--- handleSave --' + JSON.stringify(result));
                    this.showSpinner = false;
                    const newEvent = new ShowToastEvent({
                        title: 'Notification',
                        message: 'Attributes Saved Successfully!',
                        variant: 'success'
                    });
                    this.dispatchEvent(newEvent);
                    this.dispatchEvent(new RefreshEvent());
                }else if(result != null && result != 'success'){
                    console.log('inside else if handleSave');
                    this.showSpinner = false;
                    const newEvent = new ShowToastEvent({
                        title: 'Error Notification',
                        message: result,
                        variant: 'Error'
                    });
                    this.dispatchEvent(newEvent);
                } else {
                    console.log('inside else handleSave');
                    //  this.showSpinner = false;
                }
            })
            .catch((error) => {
                console.log('inside catch handleSave' + JSON.stringify(error));
                this.showSpinner = false;
                const newEvent = new ShowToastEvent({
                    title: 'Error Notification',
                    message: 'Attributes Saved Successfully!',
                    variant: 'Error'
                });
                this.dispatchEvent(newEvent);
                // this.showSpinner = false;
            });
    }

    handleCancel(){
        console.log('handle cancel');
        window.location.reload();
    }
}