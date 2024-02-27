import { LightningElement,  api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import FIELD_ACC_NAME from "@salesforce/schema/Account.Name";

const fields = [FIELD_ACC_NAME];

export default class ArtlBcpDcpCsvDownload extends LightningElement {
    DOWNLOAD_FILE_NAME = 'BCP DCP Contacts';

    @api selectedContactsJson;
    @api accId;

    downloadHeaders = {
        Id: "ID",
        firstName: "Existing First Name",
        newfirstName: "New First Name",
        lastName: "Existing Last Name",
        newlastName: "New Last Name",
        email: "Existing Email",
        newEmail: "New Email",
        mobilePhone: "Existing Mobile Phone",
        newMobilePhone: "New Mobile Phone",
        role: "Existing Role",
        newRole: "New Role",
        designation: "Existing Designation",
        newDesignation: "New Designation",
        standardReason:"Existing Standard Reason",
        newStandardReason: "New Standard Reason",
        streetAddress: "Existing Street",
        newStreetAddress: "New Street",
        city: "Existing City",
        newCity: "New City",
        state: "Existing State",
        newState: "New State",
        country: "Existing Country",
        newCountry: "New Country",
        postalCode: "Existing Postal Code",
        newPostalCode: "New Postal Code",
        gstNumber: "Existing GST",
        newGstNumber: "New GST",

        /*contactId: "Contact Id",
        premiseId: "Premise Id",
        gstID: "GST ID"*/
    }

    @wire(getRecord, { recordId: "$accId", fields })
        accountRecord;

    /*connectedCallback(){
        //console.log('Start connectedCallback');
        
        //console.log('accId=' + this.accId);
        //console.log('selectedContactsJson.length=' + this.selectedContactsJson.length);
        ////console.log('selectedContactsJson=' + JSON.stringify(this.selectedContactsJson));

        //console.log('End connectedCallback');
    }*/

    downLoadCsv(){
        //console.log('Start downLoadCsv');
        //console.log('accId=' + this.accId);
        //console.log('accountRecord=' + JSON.stringify(this.accountRecord));
        let accName = getFieldValue(this.accountRecord.data, FIELD_ACC_NAME);
        accName = accName ? accName : '';
        //console.log('accountRecord name=' + accName);
        let fileName = accName + ' ' + this.DOWNLOAD_FILE_NAME + ' ' + new Date().toJSON().slice(0, 10);
        //console.log('fileName=' + fileName);
        try {
            //console.log('selectedContactsJson.length=' + this.selectedContactsJson.length);
            ////console.log('selectedContactsJson=' + JSON.stringify(this.selectedContactsJson));
            //exportCSVFile(this.downloadHeaders, this.selectedContactsJson, this.DOWNLOAD_FILE_NAME);
            this.exportCSVFile(this.downloadHeaders, this.selectedContactsJson, fileName);
        } catch (err) {
            //console.log('err=' + err.message);
            this.showToast('Error', err.body.message, 'error');
        }
        
        //console.log('End downLoadCsv');
    }

    exportCSVFile(headers, totalData, fileTitle){
        if(!totalData || !totalData.length){
            return null;
        }
        const jsonObject = JSON.stringify(totalData);
        const result = this.convertToCSV(jsonObject, headers);
        ////console.log('result=' + result);
        //if(result === null) return
        //const blob = new Blob([result])
        const exportedFilename = fileTitle ? fileTitle + '.csv' : 'export.csv';
        let downloadElement = document.createElement('a');
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(result);
        downloadElement.target = "_blank";
        downloadElement.download = exportedFilename;
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }
    
    /*convertToCSV1(objArray, headers){
        const columnDelimiter = ',';
        const lineDelimiter = '\r\n';
        const actualHeaderKey = Object.keys(headers);
        const headerToShow = Object.values(headers) ;
        let str = '';
        str+=headerToShow.join(columnDelimiter) ;
        //str += '"' + str + '"';
        str+=lineDelimiter;
        const data = typeof objArray !=='object' ? JSON.parse(objArray):objArray;
        //console.log('data.length=' + data.length);
        data.forEach(obj=>{
            let line = '';
            actualHeaderKey.forEach(key=>{
                ////console.log('key=' + key);
                ////console.log('obj[key]=' + obj[key]);
                ////console.log('line=' + line);
                if(line !=''){
                    line += columnDelimiter;
                }
                ////console.log('line=' + line);
                //let strItem = obj[key]+'';
                let strItem = (obj[key] === undefined || obj[key] === null) ? '': obj[key]+'';
               // //console.log('strItem=' + strItem);
                //line += strItem ;
                ////console.log('line=' + line);
                line += strItem ? strItem.replace(/,/g, ''):strItem;
            })
            //console.log('str1=' + str);
            str+=line+lineDelimiter;
        })
        //console.log('str2=' + str);
        return str;
    }*/

    convertToCSV(objArray, headers){
        const columnDelimiter = '","';
        const lineDelimiter = '\r\n';
        const actualHeaderKey = Object.keys(headers);
        const headerToShow = Object.values(headers) ;
        let str = '';
        str+=headerToShow.join(columnDelimiter) ;
        str = '"' + str + '"';
        str+=lineDelimiter;
        const data = typeof objArray !=='object' ? JSON.parse(objArray):objArray;
        ////console.log('data.length=' + data.length);
        data.forEach(obj=>{
            let line = '';
            actualHeaderKey.forEach(key=>{
                ////console.log('key=' + key);
                ////console.log('obj[key]=' + obj[key]);
                ////console.log('line=' + line);
                if(line !=''){
                    line += columnDelimiter;
                }
                ////console.log('line=' + line);
                //let strItem = obj[key]+'';
                let strItem = (obj[key] === undefined || obj[key] === null) ? '': obj[key]+'';
                ////console.log('strItem=' + strItem);
                line += strItem ;
                ////console.log('line=' + line);
                //line += strItem ? strItem.replace(/,/g, ''):strItem;
            })
            //console.log('str1=' + str);
            str+= '"' + line + '"' + lineDelimiter;
        })
        //console.log('str2=' + str);
        return str;
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}