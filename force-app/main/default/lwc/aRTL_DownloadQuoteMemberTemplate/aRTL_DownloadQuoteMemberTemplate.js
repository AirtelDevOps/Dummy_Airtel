import { LightningElement, track, api} from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import getQuoteMembersByQuoteId from '@salesforce/apex/ARTL_DownloadUploadQMContactController.getQuoteMembersByQuoteId';
// imported to show toast messages
import {ShowToastEvent} from 'lightning/platformShowToastEvent';


export default class aRTL_DownloadQuoteMemberTemplate extends LightningElement {
    @track error;
    @track data;
    quoteId;
    showSpinner = true;

    @api set recordId(val){
        this.quoteId = val;
        this.getQuoteMembers();
    }
    get recordId(){
        return this.quoteId;
    }

    // fetching accounts from server
    getQuoteMembers() {
        getQuoteMembersByQuoteId({quoteId : this.quoteId})
        .then(result => {
            if(result == null || result.length == 0){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'No site available!', 
                        message: 'Please upload locations/sites to download this template.', 
                        variant: 'error'
                    }),
                );
                this.data = undefined;
                
            }else{
                this.data = result;
                this.downloadCSVFile();
                this.error = undefined;
                
            }
            this.showSpinner = false;
            this.closeQuickAction();
            
        })
        .catch(error => {
            this.error = error;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while downloading template', 
                    message: error.message, 
                    variant: 'error'
                }),
            );
            this.data = undefined;
        });
    }

    // this method validates the data and creates the csv file to download
    downloadCSVFile() {   
        let rowEnd = '\n';
        let csvString = '';

        let rowData = new Array();
        rowData.push('Account Name');
        rowData.push('Account Id');
        rowData.push('Site Name');
        rowData.push('Site Id');
        rowData.push('DC First Name');
        rowData.push('DC Last Name');
        rowData.push('DC Email');
        rowData.push('DC Phone');
        rowData.push('GST Installation');
        
        // splitting using ','
        csvString += rowData.join(',');
        csvString += rowEnd;

        // main for loop to get the data based on key value
        for(let i=0; i < this.data.length; i++){
            let colValue = 0;
            if(colValue > 0){
                csvString += ',';
            }
            if(this.data[i].hasOwnProperty('vlocity_cmt__ServiceAccountId__r') && this.data[i]['vlocity_cmt__ServiceAccountId__r'].Name != undefined) {
                csvString += '"'+ this.data[i]['vlocity_cmt__ServiceAccountId__r'].Name +'"';
            }
            csvString += ',';
            
            if(this.data[i].hasOwnProperty('vlocity_cmt__ServiceAccountId__c')) {
                csvString += '"'+ this.data[i]['vlocity_cmt__ServiceAccountId__c'] +'"';
            }
            csvString += ',';

            //console.log('@@@ =',this.data[i]['vlocity_cmt__StreetAddress__c']);
            let siteName = this.data[i].hasOwnProperty('vlocity_cmt__StreetAddress__c') ? this.data[i]['vlocity_cmt__StreetAddress__c'] + ', ' : '';
            siteName += this.data[i].hasOwnProperty('vlocity_cmt__City__c') ? this.data[i]['vlocity_cmt__City__c'] + ', ' : '';
            siteName += this.data[i].hasOwnProperty('vlocity_cmt__State__c') ? this.data[i]['vlocity_cmt__State__c']: '';
            csvString += '"'+ siteName +'"';
            csvString += ',';
            console.log('@@@!!!!22 =',siteName);
            
            
            if(this.data[i].hasOwnProperty('Id')) {
                csvString += '"'+ this.data[i]['Id'] +'"';
            }
            //csvString += ',';
            csvString += rowEnd;
        }

        // Creating anchor element to download
        let downloadElement = document.createElement('a');

        // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
        downloadElement.target = '_self';
        // CSV File Name
        downloadElement.download = 'CustomerContactTemplate.csv';
        // below statement is required if you are using firefox browser
        document.body.appendChild(downloadElement);
        // click() Javascript function to download CSV file
        downloadElement.click();

        //Show success message after successfully download it
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success!', 
                message: 'Direct Customer Contact template has been downloaded.', 
                variant: 'success'
            }),
        );
         
    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

}