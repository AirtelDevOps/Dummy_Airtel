import { LightningElement, track, wire, api } from 'lwc';
import { getCSVLine } from 'c/utils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveStageRecs from '@salesforce/apex/ARTL_BCPDCPBulkDataUpdateController.saveStageRecs';

export default class Artl_BCPDCPBulkDataUpdate extends LightningElement {
    @track columns = [
        { label: 'ID', fieldName: 'ID' },
        { label: 'Existing First Name', fieldName: 'ExistingFirstName' },
        { label: 'New First Name', fieldName: 'NewFirstName' },
        { label: 'Existing Last Name', fieldName: 'ExistingLastName' },
        { label: 'NewLast Name', fieldName: 'NewLastName' },
        { label: 'Existing Email', fieldName: 'ExistingEmail' },
        { label: 'New Email', fieldName: 'NewEmail' },
        { label: 'Existing Mobile Phone', fieldName: 'ExistingMobilePhone' },
        { label: 'NewMobile Phone', fieldName: 'NewMobilePhone' },
        { label: 'Existing Role', fieldName: 'ExistingRole' },
        { label: 'New Role', fieldName: 'NewRole' },
        { label: 'Existing Designation', fieldName: 'ExistingDesignation' },
        { label: 'New Designation', fieldName: 'NewDesignation' },
        { label: 'Existing Standard Reason', fieldName: 'ExistingStandardReason' },
        { label: 'New Standard Reason', fieldName: 'NewStandardReason' },
        { label: 'Existing Street', fieldName: 'ExistingStreet' },
        { label: 'New Street', fieldName: 'NewStreet' },
        { label: 'Existing City', fieldName: 'ExistingCity' },
        { label: 'New City', fieldName: 'NewCity' },
        { label: 'Existing State', fieldName: 'ExistingState' },
        { label: 'New State', fieldName: 'NewState' },
        { label: 'Existing Country', fieldName: 'ExistingCountry' },
        { label: 'New Country', fieldName: 'NewCountry' },
        { label: 'Existing Postal Code', fieldName: 'ExistingPostalCode' },
        { label: 'New Postal Code', fieldName: 'NewPostalCode' },
        { label: 'Existing GST', fieldName: 'ExistingGST' },
        { label: 'New GST', fieldName: 'NewGST' }
    ];    

    @track selectedRows = [];
    rowOffset = 0;
    @track allRecords;
    @track visibleRecords;
    currentPage =1;
    pageSize = 20;
    totalPage = 1;
    
    get contactList(){
        return this.visibleRecords;
    }
    set contactList(data){
        if(data){ 
            //console.log('inside contactList');
            this.allRecords = data;
            this.pageSize = Number(this.pageSize);
            this.totalPage = Math.ceil(data.length/this.pageSize);
            //console.log('totalPage' + this.totalPage);
            if(this.totalPage == 0){
                this.totalPage = 1;  
            }
            this.currentPage = 1;
            this.visibleRecords = this.allRecords.slice(0, this.pageSize);
        }
        //console.log('End contactList');
    }

    get disablePreviousPage(){ 
        return this.currentPage<=1;
    }
    get disableNextPage(){ 
        return this.currentPage>=this.totalPage;
    }



    headers = ["ID","ExistingFirstName","NewFirstName","ExistingLastName","NewLastName","ExistingEmail","NewEmail","ExistingMobilePhone","NewMobilePhone","ExistingRole","NewRole","ExistingDesignation","NewDesignation","ExistingStandardReason","NewStandardReason","ExistingStreet","NewStreet","ExistingCity","NewCity","ExistingState","NewState","ExistingCountry","NewCountry","ExistingPostalCode","NewPostalCode", "ExistingGST", "NewGST"];
    @track isLoading = false;
    @track isDisabled = false;
    @track hasData = false;
    @track data = [];

    startSpinner() {
        this.isLoading = true;
        this.isDisabled = true;
    }

    stopSpinner() {
        this.isLoading = false;
        this.isDisabled = false;
    }

    handleFileUpload(event) {
        this.startSpinner();
        try {
            const evt = new ShowToastEvent({
                title: 'Reading CSV File',
                variant: 'info',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            const files = event.detail.files;
            if (files.length > 0) {
                const file = files[0];
                this.read(file);
            }
        } catch (e) {
            console.log('Error: ' + e);
            this.stopSpinner();
            const evt = new ShowToastEvent({
                title: 'Error',
                message: e,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
    }

    async read(file) {
        try {
            const result = await this.load(file);
            this.parse(result);
        } catch (e) {
            console.log('Read Error: ' + e);
            this.stopSpinner();
            const evt = new ShowToastEvent({
                title: 'Error',
                message: e,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
    }

    async load(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = () => {
                resolve(reader.result);
            };
            reader.onerror = () => {
                reject(reader.error);
            };
            reader.readAsText(file);
        });
    }

    parse(csv) {
        const lines = csv.split(/\r\n|\n/);
        this.data = [];
        lines.forEach((line, i) => {
            if (i === 0) return;
            //const currentline = line.split(',');
            const currentline = getCSVLine(line);
            console.log('CL ' + currentline);
            if (currentline != null) {
                const obj = {};
                for (let j = 0; j < this.headers.length; j++) {
                    if (currentline[j] == ' ') {
                        obj[this.headers[j]] = '';
                    } else {
                        obj[this.headers[j]] = currentline[j].replaceAll('"', '').replaceAll(':blank:', '');
                    }
                }
                let validation = true;
                let validationMsg = '';
                if((obj.NewFirstName == null || obj.NewFirstName == undefined || obj.NewFirstName == '' || obj.NewFirstName == 'undefined' || obj.NewFirstName == ' ') && 
                (obj.NewLastName == null || obj.NewLastName == undefined || obj.NewLastName == '' || obj.NewLastName == 'undefined' || obj.NewLastName == ' ') &&
                (obj.NewEmail == null || obj.NewEmail == undefined || obj.NewEmail == '' || obj.NewEmail == 'undefined' || obj.NewEmail == ' ') &&
                (obj.NewMobilePhone == null || obj.NewMobilePhone == undefined || obj.NewMobilePhone == '' || obj.NewMobilePhone == 'undefined' || obj.NewMobilePhone == ' ') &&
                (obj.NewRole == null || obj.NewRole == undefined || obj.NewRole == '' || obj.NewRole == 'undefined' || obj.NewRole == ' ') &&
                (obj.NewDesignation == null || obj.NewDesignation == undefined || obj.NewDesignation == '' || obj.NewDesignation == 'undefined' || obj.NewDesignation == ' ') &&
                (obj.NewStreet == null || obj.NewStreet == undefined || obj.NewStreet == '' || obj.NewStreet == 'undefined' || obj.NewStreet == ' ') &&
                (obj.NewCity == null || obj.NewCity == undefined || obj.NewCity == '' || obj.NewCity == 'undefined' || obj.NewCity == ' ') &&
                (obj.NewState == null || obj.NewState == undefined || obj.NewState == '' || obj.NewState == 'undefined' || obj.NewState == ' ') &&
                (obj.NewCountry == null || obj.NewCountry == undefined || obj.NewCountry == '' || obj.NewCountry == 'undefined' || obj.NewCountry == ' ') &&
                (obj.NewStandardReason == null || obj.NewStandardReason == undefined || obj.NewStandardReason == '' || obj.NewStandardReason == 'undefined' || obj.NewStandardReason == ' ') &&
                (obj.NewGST == null || obj.NewGST == undefined || obj.NewGST == '' || obj.NewGST == 'undefined' || obj.NewGST == ' ') &&
                (obj.NewPostalCode == null || obj.NewPostalCode == undefined || obj.NewPostalCode == '' || obj.NewPostalCode == 'undefined' || obj.NewPostalCode == ' ') ){
                    validation = false;
                    validationMsg += 'No new values';
                }
                //No Error
                if (validation) {
                    validationMsg = 'Validated';
                }
                //Final Validation
                obj['Validation'] = validation;
                obj['ValidationMessage'] = validationMsg;
                this.data.push(obj);
            }
        });

        if (this.data.length > 0) {
            this.hasData = true;
            this.contactList = this.data;
        }

        this.stopSpinner();
    }

    handleSave() {
        this.startSpinner();
        console.log('Save');
        let validData = this.data.filter(rec => rec.Validation == true);
        saveStageRecs({ objList: validData })
        .then((result)=>{
            const evt = new ShowToastEvent({
                title: 'Success',
                message: result + ' records sent for processing',
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            this.closeModal();
        })
        .catch((error) => {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            this.closeModal();
        });
    }

    closeModal() {
        this.hasData = false;
        this.data = [];
        this.stopSpinner();
    }



    previousPageHandler(){ 
        if(this.currentPage>1){
            this.currentPage = this.currentPage-1;
            this.handleVisibleRows();
        }
    }
    nextPageHandler(){
        if(this.currentPage < this.totalPage){
            this.currentPage = this.currentPage+1;
            this.handleVisibleRows();
        }
    }
    handleVisibleRows(){ 
        this.rowOffset = this.currentPage <= 1 ? 0 : (this.currentPage -1) * this.pageSize;
        const start = (this.currentPage-1)*this.pageSize;
        const end = this.pageSize*this.currentPage;
        this.visibleRecords = this.allRecords.slice(start, end);
        this.template.querySelector('[data-id="datatable"]').selectedRows = this.selectedRows;
    }

}