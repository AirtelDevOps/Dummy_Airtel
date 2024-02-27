import { LightningElement, track, wire, api } from 'lwc';
import fetchDCPwire from '@salesforce/apex/ARTL_CreateDCPController.fetchDCPwire';
import fetchDCP from '@salesforce/apex/ARTL_CreateDCPController.fetchDCP';
import createDCP from '@salesforce/apex/ARTL_CreateDCPController.createDCP';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {getObjectInfo} from 'lightning/uiObjectInfoApi';
import Contactpremise_OBJECT from '@salesforce/schema/ContactPremiseRelation__c';
import Contact_OBJECT from '@salesforce/schema/Contact';
import {getPicklistValues} from 'lightning/uiObjectInfoApi';
import GSTAPPL_FIELD from '@salesforce/schema/ContactPremiseRelation__c.ARTL_GST_Applicable__c';
import STDREASON_FIELD from '@salesforce/schema/ContactPremiseRelation__c.ARTL_Standard_Reason__c';
import SALUTATION_FIELD from '@salesforce/schema/Contact.Salutation';

import { exportCSVFile } from 'c/utils';
import { getCSVLine } from 'c/utils';

export default class Artl_CreateDCP extends LightningElement {
    @api recordId;
    @track hasDTW = false;
    @track dtwList = [];
    @track qmIdSet = [];
    @track FirstName = "FirstName";
    @track Salutation = "Salutation";
    @track MiddleName = "MiddleName";
    @track LastName = "LastName";
    @track Designation = "Designation";
    @track Phone = "Phone";
    @track Email = "Email";
    @track GST = "GST";
    @track StdReason="StdReason";
    @track  Gstappl="Gstappl";
    @track inputDataList = [];
    @track isLoading = false;
    @track isDisabled = false;
    @track selectedRecId = '';
    @track stdReasonOptions=[];
    @track gstApplOptions=[];
    @track salOptions=[];
    @wire(getObjectInfo, {objectApiName: Contactpremise_OBJECT })
    contactpremiseInfo;

    @wire(getObjectInfo, {objectApiName: Contact_OBJECT })
    contactInfo;
    headers = ['qmId', 'Address', 'DCP', 'Designation', 'FirstName', 'MiddleName', 'LastName', 'Phone', 'Email', 'Gstappl', 'StdReason', 'GST'];

    downloadHeaders = {
        qmId: "QuoteMemberId",
        streetAddress: "Address",
        DCP: "DCP",
        designation: "Designation",
        firstName: "FirstName",
        middleName: "MiddleName",
        lastName: "LastName",
        phone: "Phone",
        email: "Email",
        gstAppl: "GSTApplicable",
        standardReason:"StandardReason",
        GST: "GST"
    }

    @track allQMIdSet = [];
    @track uploadList = [];
    @track csvData = false;

    @wire(getPicklistValues, {recordTypeId: '$contactpremiseInfo.data.defaultRecordTypeId', fieldApiName: GSTAPPL_FIELD })
    gstApplFieldInfo({ data, error }) {
        if (data) this.gstApplOptions = data.values;
    }

    
    @wire(getPicklistValues, {recordTypeId:'$contactpremiseInfo.data.defaultRecordTypeId', fieldApiName: STDREASON_FIELD })
    stdReasonFieldInfo({ data, error }) {
        if (data) this.stdReasondata = data;
    }

    @wire(getPicklistValues, {recordTypeId:'$contactInfo.data.defaultRecordTypeId', fieldApiName: SALUTATION_FIELD })
    salutationFieldInfo({ data, error }) {
        if (data) {
            console.log('datat '+JSON.stringify(data));
            this.salOptions = data.values;}
    }

    
   /* @wire(fetchDCPwire, { quoteId: '$recordId' })
    wiredDTW( {data, error } wireresult) {
        const { data, error } = wireresult;
        this._wirelist = wireresult;
        if (data) {
            this.dtwList = data;
            if (this.dtwList.length > 0)
                this.hasDTW = true; 
        } else {
            this.error = error;
            console.log('Error:: ' + this.error);
        }
    }*/

    getDTW(){
        fetchDCP({quoteId: this.recordId}).then((data)=>{
            this.dtwList = data;
            console.log('temthis.dtwListpRec=>'+JSON.stringify(this.dtwList))
            if (this.dtwList.length > 0)
                this.hasDTW = true;
                this.dtwList.forEach((dtw) => {
                    if(!(this.allQMIdSet.includes(dtw.qmId)))
                        this.allQMIdSet.push(dtw.qmId);
                });
            }).catch((error)=>{
                this.error = error;
                console.log('Error:: ' + this.error);
            });
    }

    connectedCallback(){
        this.getDTW();
    }
    startSpinner() {
        this.isLoading = true;
        this.isDisabled = true;
    }
    stopSpinner() {
        this.isLoading = false;
        this.isDisabled = false;
    }

    handleSelect(event){
        console.log('Selected:: '+event.target.dataset.id);
        this.selectedRecId = event.target.dataset.id;
    }

    handleCopy(event) {
        console.log('Copy:: ' + event.target.dataset.id);
        let copyRowId = event.target.dataset.id;
        this.template.querySelector(`[data-id="${copyRowId}"][data-name="${this.Salutation}"]`).value = this.template.querySelector(`[data-id="${this.selectedRecId}"][data-name="${this.Salutation}"]`).value;
        this.template.querySelector(`[data-id="${copyRowId}"][data-name="${this.FirstName}"]`).value = this.template.querySelector(`[data-id="${this.selectedRecId}"][data-name="${this.FirstName}"]`).value;
        this.template.querySelector(`[data-id="${copyRowId}"][data-name="${this.MiddleName}"]`).value = this.template.querySelector(`[data-id="${this.selectedRecId}"][data-name="${this.MiddleName}"]`).value;
        this.template.querySelector(`[data-id="${copyRowId}"][data-name="${this.LastName}"]`).value = this.template.querySelector(`[data-id="${this.selectedRecId}"][data-name="${this.LastName}"]`).value;
        this.template.querySelector(`[data-id="${copyRowId}"][data-name="${this.Designation}"]`).value = this.template.querySelector(`[data-id="${this.selectedRecId}"][data-name="${this.Designation}"]`).value;

        this.template.querySelector(`[data-id="${copyRowId}"][data-name="${this.Phone}"]`).value = this.template.querySelector(`[data-id="${this.selectedRecId}"][data-name="${this.Phone}"]`).value;
        this.template.querySelector(`[data-id="${copyRowId}"][data-name="${this.Email}"]`).value = this.template.querySelector(`[data-id="${this.selectedRecId}"][data-name="${this.Email}"]`).value;
    }

    handlechange(event) {
        if(!(this.qmIdSet.includes(event.target.dataset.id)))
            this.qmIdSet.push(event.target.dataset.id);
    }

    handlegstApplicable(event){
        let key = this.stdReasondata.controllerValues[event.target.value];
        let stdPicklist= this.stdReasondata.values.filter(data =>{ return data.validFor.includes(key)});
        let tempAllRecords = Object.assign([], this.dtwList);
        for (let j = 0; j < this.dtwList.length; j++) {
                let tempRec = Object.assign({}, tempAllRecords[j]);
                if(tempRec.qmId==event.target.dataset.id){
                    tempRec.stdPicklist = stdPicklist;
                    tempAllRecords[j] = tempRec;
                    break;
                }
        }
        this.dtwList = tempAllRecords;
        this.handlechange(event);
    }

    handlereasonchange(event) {
        let tempAllRecords = Object.assign([], this.dtwList);
        for (let j = 0; j < this.dtwList.length; j++) {
            let tempRec = Object.assign({}, tempAllRecords[j]);
            console.log('tempRec=>'+JSON.stringify(tempRec))
            console.log('this.dtwList=>'+JSON.stringify(this.dtwList))
            if (tempRec.qmId == event.target.dataset.id) {
                let gsttype=this.getGSTType(event.detail.value);
                if(gsttype!=''){
                    console.log('element'+  this.template.querySelector(`[data-id="${tempRec.qmId}"][data-name="${this.GST}"]`));
                    this.template.querySelector(`[data-id="${tempRec.qmId}"][data-name="${this.GST}"]`).required=true;
                }else{
                    this.template.querySelector(`[data-id="${tempRec.qmId}"][data-name="${this.GST}"]`).required=false;
                }
                console.log('tempRec.isGSTrequired '+tempRec.isGSTrequired);
                if(tempRec.gstPicklistMap!=null && tempRec.gstPicklistMap!=undefined){
                    console.log('enetered iff iff=>')
                let gstmap=JSON.parse(JSON.stringify(tempRec.gstPicklistMap));
                tempRec.gstPicklist = gstmap[gsttype];
                tempAllRecords[j] = tempRec;
                }
                break;
            }
        }
        this.dtwList = tempAllRecords;
        this.handlechange(event);
    }

    handleCreate() {
        const isInputsCorrect = [...this.template.querySelectorAll(".validity")]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
        if (isInputsCorrect) {
            this.startSpinner();
            this.inputDataList = [];
            console.log('Id Set:: ' + this.qmIdSet);
            this.qmIdSet.forEach(function (qmId) {
                let inpRec = {
                    "qmId": qmId,
                    "Salutation": this.template.querySelector(`[data-id="${qmId}"][data-name="${this.Salutation}"]`).value,
                    "FirstName": this.template.querySelector(`[data-id="${qmId}"][data-name="${this.FirstName}"]`).value,
                    "MiddleName": this.template.querySelector(`[data-id="${qmId}"][data-name="${this.MiddleName}"]`).value,
                    "LastName": this.template.querySelector(`[data-id="${qmId}"][data-name="${this.LastName}"]`).value,
                    "Designation": this.template.querySelector(`[data-id="${qmId}"][data-name="${this.Designation}"]`).value,
                    
                    "Phone": this.template.querySelector(`[data-id="${qmId}"][data-name="${this.Phone}"]`).value,
                    "Email": this.template.querySelector(`[data-id="${qmId}"][data-name="${this.Email}"]`).value,
                    "GST": this.template.querySelector(`[data-id="${qmId}"][data-name="${this.GST}"]`).value,
                    "StdReason": this.template.querySelector(`[data-id="${qmId}"][data-name="${this.StdReason}"]`).value,
                    "Gstappl": this.template.querySelector(`[data-id="${qmId}"][data-name="${this.Gstappl}"]`).value
                }
                this.inputDataList.push(inpRec);
            }, this);
            console.log('Data:: ' + JSON.stringify(this.inputDataList));

            createDCP({ objList: this.inputDataList, quoteId: this.recordId })
                .then((result) => {
                    this.dtwList = result;
                    const evt = new ShowToastEvent({
                        title: 'Success',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                    this.stopSpinner();
                    this.dispatchEvent(new CustomEvent('resetvar'));
                    
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
        }else{
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Please enter required and correct data',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
    }

    getGSTType(stdreason){
        let gsttype='';
        if(stdreason=='SEZ' || stdreason=='SEZ with taxes'){
            gsttype='SEZ';
        }else if(stdreason=='Non-SEZ' || stdreason=='Zero Rated Supply- FTWZ' || stdreason=='Non Taxable as transactions within same Company'){
            gsttype='Non-SEZ';
        }else if(stdreason=='UIN'){
            gsttype='UIN';
        }
        return gsttype ;
    }

    handleDownload(){
        console.log('Download');
        exportCSVFile(this.downloadHeaders, this.dtwList, "DCP-"+this.recordId);
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
        const lines = csv.split(/\r\n|\n/)
        const emailRegex = /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/;
        const phoneRegex = /^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$/;
        //let uploadList = [];
        lines.forEach((line, i) => {
            if (i === 0) return;
            //const currentline = line.split(',');
            const currentline = getCSVLine(line);
            console.log('line '+currentline);
            if (currentline != null) {
                const obj = {};
                for (let j = 0; j < this.headers.length; j++) {
                    obj[this.headers[j]] = currentline[j].replaceAll('"', '').replaceAll(':blank:', '');
                }
                let validation = true;
                let validationMsg = '';
                if (obj.qmId == null || obj.qmId == undefined || obj.qmId == '') {
                    validation = false;
                    validationMsg = 'Quote Member Id is required. ';
                } else if (!(this.allQMIdSet.includes(obj.qmId))) {
                    validation = false;
                    validationMsg += 'Quote Member Id is incorrect. ';
                }
                if (validation) {
                    let localDTW = this.dtwList.filter(rec => rec.qmId == obj.qmId);
                    //console.log('Local  '+ JSON.stringify(localDTW[0]));
                    if (localDTW[0].hasDCP) {
                        validation = false;
                        validationMsg += 'DCP already exists. ';
                    }
                    if (obj.Designation == null || obj.Designation == undefined || obj.Designation == '' || obj.Designation == 'undefined' ||
                        obj.FirstName == null || obj.FirstName == undefined || obj.FirstName == '' || obj.FirstName == 'undefined' ||
                        obj.LastName == null || obj.LastName == undefined || obj.LastName == '' || obj.LastName == 'undefined' ||
                        obj.Phone == null || obj.Phone == undefined || obj.Phone == '' || obj.Phone == 'undefined' ||
                        obj.Email == null || obj.Email == undefined || obj.Email == '' || obj.Email == 'undefined' ||
                        obj.Gstappl == null || obj.Gstappl == undefined || obj.Gstappl == '' || obj.Gstappl == 'undefined' ||
                        obj.StdReason == null || obj.StdReason == undefined || obj.StdReason == '' || obj.StdReason == 'undefined') {
                        validation = false;
                        validationMsg += 'Designation, FirstName, LastName, Phone, Email, GSTApplicable, StandardReason is Mandatory. ';
                    }
                    if (obj.Phone != null && obj.Phone != undefined && obj.Phone != '' && obj.Phone != 'undefined' && obj.Phone.match(phoneRegex) == null) {
                        validation = false;
                        validationMsg += 'Incorrect Value for Phone field. ';
                    }
                    if (obj.Email != null && obj.Email != undefined && obj.Email != '' && obj.Email != 'undefined' && obj.Email.match(emailRegex) == null) {
                        validation = false;
                        validationMsg += 'Incorrect Value for Email field. ';
                    }
                    if (obj.Gstappl != null && obj.Gstappl != undefined && obj.Gstappl != '' && obj.Gstappl != 'undefined') {
                        //let flag = false;
                        /*for(let appl of this.gstApplOptions){
                            if(appl.value == obj.Gstappl){
                                flag = true;
                                break;
                            }
                        }*/
                        let validData = this.gstApplOptions.filter(rec => rec.value == obj.Gstappl);
                        if (validData.length == 0) {
                            validation = false;
                            validationMsg += 'Incorrect Value for GST Applicable field. ';
                        }
                    }
                    if (obj.StdReason != null && obj.StdReason != undefined && obj.StdReason != '' && obj.StdReason != 'undefined') {
                        let key = this.stdReasondata.controllerValues[obj.Gstappl];
                        let sstdPicklist = this.stdReasondata.values.filter(data => { return data.validFor.includes(key) });
                        //let flag = false;
                        /*for(let appl of sstdPicklist){
                            if(appl.value == obj.StdReason){
                                flag = true;
                                break;
                            }
                        }*/
                        let validData = sstdPicklist.filter(rec => rec.value == obj.StdReason);
                        if (validData.length == 0) {
                            validation = false;
                            validationMsg += 'Incorrect Value for Standard Reason field. ';
                        }
                    }
                    if (obj.GST != null && obj.GST != undefined && obj.GST != '' && obj.GST != 'undefined') {
                        //let flag = false;
                        /*for(let appl of localDTW[0].gstPicklist){
                            if(appl.value == obj.Gstappl){
                                flag = true;
                                break;
                            }
                        }*/
                        let validData = this.localDTW[0].gstPicklist.filter(rec => rec.value == obj.GST);
                        if (validData.length == 0) {
                            validation = false;
                            validationMsg += 'Incorrect Value for GST field. ';
                        }
                    }
                }
                //No Error
                if (validation) {
                    validationMsg = 'Validated';
                }
                //Final Validation 
                obj['Validation'] = validation;
                obj['ValidationMessage'] = validationMsg;
                this.uploadList.push(obj);
            }
        });       
        if (this.uploadList.length > 0) {
            this.csvData = true;
        }
        this.stopSpinner();
    }

    closeModal(){
        this.csvData = false;
        this.uploadList = [];
    }

    handleSave() {
        this.startSpinner();
        let validData = this.uploadList.filter(rec => rec.Validation == true);
        createDCP({ objList: validData, quoteId: this.recordId })
            .then((result) => {
                this.dtwList = result;
                const evt = new ShowToastEvent({
                    title: 'Success',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                this.stopSpinner();
                this.dispatchEvent(new CustomEvent('resetvar'));
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
                this.stopSpinner();
                this.closeModal();
            });
    }


}