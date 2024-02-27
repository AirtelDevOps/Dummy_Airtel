import { LightningElement, track, wire, api } from 'lwc';
import getPinCodes from '@salesforce/apex/ARTL_UploadPremisesCSVController.getPinCodes';
import getPremiseRec from '@salesforce/apex/ARTL_UploadPremisesCSVController.getPremiseRec';
import savePremiseRecs from '@salesforce/apex/ARTL_UploadPremisesCSVController.savePremiseRecs';
import { exportCSVFile } from 'c/utils';
import { getCSVLine } from 'c/utils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Artl_UploadPremisesCSV extends LightningElement {
    @api quoteId;
    @track data = [];
    @track downloadData = [];
    @track hasData = false;
    @track pinList = [];
    @track headers = ['AddressId','Street','City','State','Country','Pincode','Latitude','Longitude'];
    downloadHeaders = {
        External_Id__c: "AddressId",
        vlocity_cmt__StreetAddress__c: "Street",
        vlocity_cmt__City__c: "City",
        vlocity_cmt__State__c: "State",
        vlocity_cmt__Country__c: "Country",
        vlocity_cmt__PostalCode__c: "Pincode",
        vlocity_cmt__Geolocation__Latitude__s: "Latitude",
        vlocity_cmt__Geolocation__Longitude__s: "Longitude"
    }
    @track isLoading = false;
    @track isDisabled = false;

    @wire(getPinCodes)
    wiredPins({ data, error }) {
        if (data) {
            this.pinList = data;
        } else {
            console.log('Error:: ' + error);
        }
    }

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
        const pinRegex = /^[1-9]{1}[0-9]{5}$/;
        //let head = this.headers;
        //console.log('Proxy Array ',JSON.parse(JSON.stringify(this.headers)));
        //console.log('Actual',lines[0].split(','));
        //console.log('Bollean ' +(JSON.stringify(lines[0].split(',')) != JSON.stringify(this.headers)) ? 'Not' : 'Yes');
        /*if (lines[0].split(',') != this.headers) {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Invalid CSV Format',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        } else {*/
        lines.forEach((line, i) => {
            if (i === 0) return;
            //const currentline = line.split(',');
            const currentline = getCSVLine(line);
            console.log('CL ' + currentline);
            if (currentline != null) {
                const obj = {};
                for (let j = 0; j < this.headers.length; j++) {
                    obj[this.headers[j]] = currentline[j].replaceAll('"', '').replaceAll(':blank:', '');
                }
                //this.downloadData.push(obj);
                let validation = true;
                let validationMsg = '';
                //Pincode Validation 
                if (obj.Pincode.match(pinRegex) == null) {
                    validation = false;
                    validationMsg = 'Pincode must contain 6 digits without space and should not start with 0. ';
                } else if (!(this.pinList.includes(obj.Pincode))) {
                    validation = false;
                    validationMsg = 'Pincode not present in Database. ';
                }
                //Mandatory Fields
                if(obj.Street == null || obj.Street == undefined || obj.Street == '' || obj.Street == 'undefined' ||
                obj.City == null || obj.City == undefined || obj.City == '' || obj.City == 'undefined' ||
                obj.State == null || obj.State == undefined || obj.State == '' || obj.State == 'undefined' ||
                obj.Country == null || obj.Country == undefined || obj.Country == '' || obj.Country == 'undefined'){
                    validation = false;
                    validationMsg = 'Street, City, State, Country are Mandatory fields';
                }
                //Street Validation
                if (obj.Street.length > 255) {
                    validation = false;
                    validationMsg = validationMsg + 'Street exceeds max character limit of 255. ';
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
            //console.log('CSV Data:', JSON.stringify(this.data));
            if (this.data.length > 0) {
                this.hasData = true;
            }
        //}
        this.stopSpinner();
    }

    handleSave() {
        this.startSpinner();
        let validData = this.data.filter(rec => rec.Validation == true);
        savePremiseRecs({ objList: validData, qId: this.quoteId })
            .then((result) => {
                console.log('Success');
                this.stopSpinner();
                if (result > 0) {
                    const evt = new ShowToastEvent({
                        title: result + ' Location Added/Updated',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                } else {
                    const evt = new ShowToastEvent({
                        title: 'No Location Added',
                        variant: 'info',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }
                this.closeModal();
            })
            .catch((error) => {
                console.log('Error:: ' + JSON.stringify(error));
                this.stopSpinner();
                const evt = new ShowToastEvent({
                    title: 'error',
                    message: JSON.stringify(error),
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                this.closeModal();
            });
    }

    closeModal() {
        this.dispatchEvent(new CustomEvent("closeparentmodal"));
        this.hasData = false;
        this.data = [];
        this.downloadData = [];
    }

    handleDownload() {
        this.startSpinner();
        getPremiseRec({ qId: this.quoteId })
            .then((result) => {
                this.downloadData = result;
                exportCSVFile(this.downloadHeaders, this.downloadData, "PremiseRecords");
                this.stopSpinner();
            })
            .catch((error) => {
                console.log('Error:: ' + error);
                const evt = new ShowToastEvent({
                    title: 'error',
                    message: JSON.stringify(error),
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                this.stopSpinner();
            });
    }
}