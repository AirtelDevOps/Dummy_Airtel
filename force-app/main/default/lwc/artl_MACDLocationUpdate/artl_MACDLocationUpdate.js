import { LightningElement, track, wire, api } from 'lwc';
import fetchDCP from '@salesforce/apex/ARTL_CreateDCPController.fetchDCP';
import getPinCodes from '@salesforce/apex/ARTL_UploadPremisesCSVController.getPinCodes';
import savePremiseRecs from '@salesforce/apex/ARTL_MACDLocationUpdateController.savePremiseRecs';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class Artl_MACDLocationUpdate extends LightningElement {
    @api recordId;
    @api isModalOpen;
    @track dtwList = [];
    @track inputDataList = [];
    @track hasDTW = false;
    connectedCallback(){
        this.getDTW();
    }
    @track error;
    @track isLoading = false;
    @track isDisabled = false;
    //@track isModalOpen = false;
    @track isChildModalOpen = false;
    @track qmIdSet = [];
    @track pinList = [];

    @track Street = "Street";
    @track City = "City";
    @track State = "State";
    @track Pincode = "Pincode";
    @track Country = "Country";

    headers = ['qmId', 'Street', 'City', 'State', 'Country', 'Pincode'];

    @wire(getPinCodes)
    wiredPins({ data, error }) {
        if (data) {
            this.pinList = data;
        } else {
            console.log('Error:: ' + error);
        }
    }

    openModal(){
        this.isModalOpen =  true;
    }

    closeModal(){
        this.dispatchEvent(new CustomEvent("closemodalpopup"));
        //this.isModalOpen =  false;
        //this.dispatchEvent(new CustomEvent("refreshmemberscustom"));
        this.stopSpinner();
        this.resetFields();
        this.qmIdSet = [];
    }

    startSpinner() {
        this.isLoading = true;
        this.isDisabled = true;
    }
    stopSpinner() {
        this.isLoading = false;
        this.isDisabled = false;
    }

    resetFields(){
        const inputFields = this.template.querySelectorAll('lightning-input');
        if (inputFields) {
            inputFields.forEach(field => {
                field.value = null;
            });
        }
    }

    getDTW(){
        fetchDCP({quoteId: this.recordId}).then((data)=>{
            this.dtwList = data;
            if (this.dtwList.length > 0)
                this.hasDTW = true;
            }).catch((error)=>{
                this.error = error;
                console.log('Error:: ' + this.error);
            });
    }

    handlechange(event) {
        if(!(this.qmIdSet.includes(event.target.dataset.id)))
            this.qmIdSet.push(event.target.dataset.id);
    }

    handleValidate() {
        const pinRegex = /^[1-9]{1}[0-9]{5}$/;
        this.startSpinner();
        let tempDataList = [];
        this.inputDataList = [];
        this.qmIdSet.forEach(function (qmId) {
            let inpRec = {
                "qmId": qmId,
                "Street": this.template.querySelector(`[data-id="${qmId}"][data-name="${this.Street}"]`).value,
                "City": this.template.querySelector(`[data-id="${qmId}"][data-name="${this.City}"]`).value,
                "State": this.template.querySelector(`[data-id="${qmId}"][data-name="${this.State}"]`).value,
                "Country": this.template.querySelector(`[data-id="${qmId}"][data-name="${this.Country}"]`).value,
                "Pincode": this.template.querySelector(`[data-id="${qmId}"][data-name="${this.Pincode}"]`).value
            }
            tempDataList.push(inpRec);
        }, this);

        console.log('AddressData:: '+JSON.stringify(tempDataList));

        tempDataList.forEach(element => {
            const obj = {};
            for (let j = 0; j < this.headers.length; j++) {
                obj[this.headers[j]] = element[this.headers[j]];
            }
            let validation = true;
            let validationMsg = '';
            if (obj.Street == null || obj.Street == undefined || obj.Street == '' || obj.Street == ' ' ||
                obj.City == null || obj.City == undefined || obj.City == '' || obj.City == ' ' ||
                obj.State == null || obj.State == undefined || obj.State == '' || obj.State == ' ' ||
                obj.Country == null || obj.Country == undefined || obj.Country == '' || obj.Country == ' ' ||
                obj.Pincode == null || obj.Pincode == undefined || obj.Pincode == '' || obj.Pincode == ' ') {
                validation = false;
                validationMsg += 'All Fields are Mandatory. ';
            }
            if (validation) {
                //Pincode Validation 
                if (obj.Pincode.match(pinRegex) == null) {
                    validation = false;
                    validationMsg = 'Pincode must contain 6 digits without space and should not start with 0. ';
                } else if (!(this.pinList.includes(obj.Pincode))) {
                    validation = false;
                    validationMsg = 'Pincode not present in Database. ';
                }
            }
            //No Error
            if (validation) {
                validationMsg = 'Validated';
            }
            //Final Validation 
            obj['Validation'] = validation;
            obj['ValidationMessage'] = validationMsg;
            this.inputDataList.push(obj);
        });

        console.log('AddressData:: '+JSON.stringify(this.inputDataList));
        this.isChildModalOpen = true;
        this.isModalOpen = false;
        this.stopSpinner();
    }

    handleUpdate(){
        this.startSpinner();
        let validData = this.inputDataList.filter(rec => rec.Validation == true);
        if (validData.length > 0) {
            savePremiseRecs({ objList: validData, qId: this.recordId })
            .then((result) => {
                console.log('Success');
                this.stopSpinner();
                if (result > 0) {
                    const evt = new ShowToastEvent({
                        title: result + ' Location Updated',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                } else {
                    const evt = new ShowToastEvent({
                        title: 'No Location Updated',
                        variant: 'info',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }
                this.closeChildModal();
            })
            .catch((error) => {
                console.log('Error:: ' + JSON.stringify(error));
                this.stopSpinner();
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: JSON.stringify(error),
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                this.closeChildModal();
            });
        } else {
            const evt = new ShowToastEvent({
                title: 'No Valid Data',
                variant: 'info',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            this.stopSpinner();
        }
    }

    closeChildModal(){
        this.dispatchEvent(new CustomEvent("closemodalpopup"));
        this.dispatchEvent(new CustomEvent("refreshmemberscustom"));
        this.isChildModalOpen = false;
        this.inputDataList = [];
        this.resetFields();
        this.stopSpinner();
        this.qmIdSet = [];
    }

}