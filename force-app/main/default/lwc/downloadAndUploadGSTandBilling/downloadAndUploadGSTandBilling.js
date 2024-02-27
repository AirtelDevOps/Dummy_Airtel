import { LightningElement, api, track, wire } from 'lwc';
import { getDataHandler } from "vlocity_cmt/utility";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningConfirm from "lightning/confirm";
import REPORT_OBJECT from '@salesforce/schema/Report';
import uploadAction from '@salesforce/apex/ARTL_BillingStaging_DwnldUpld.insertNupsertCSVToBillingStaging';
import validateStagingData from '@salesforce/apex/ARTL_ValidateStagingDataHelper.invokeARTL_ValidateStagingData';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

const cols = [
  { label: 'Product Name', fieldName: 'ProductName' },
  { label: 'Billing Account Name', fieldName: 'BillingAccountName' },
  { label: 'billing Account Id', fieldName: 'billingAccountId' },
];


export default class DownloadAndUploadGSTandBilling extends NavigationMixin(LightningElement) {
  @track data;
  @api recordId;
  @api columns = cols;
  @api uploadData;
  @api editTableData;
  uploadData = false;
  @api showLoading = false;
  @api showCsvsData;
  filesUploaded = [];
  file;
  fileContents;
  fileReader;
  content;
  saveDraftValues = [{}]
  MAX_FILE_SIZE = 1500000;
  reportId;



  connectedCallback() {
    this.showLoading = true;
    this.recordId = this.getUrlParams('c__cartId');
    this.getbillingStagingFields();
    if (this.recordId) {
      this.getBillingDetails();
    }
    let requestData = {
      "type": "integrationprocedure",
      "value": {
        "ipMethod": "ARTL_FetchBillingStagingReport",
        "inputMap": {},
        "optionsMap": ''
      }
    }
    let reportRes;
    getDataHandler(JSON.stringify(requestData)).then(response => {
      reportRes = JSON.parse(response);

      this.reportId = reportRes.IPResult.Report[0].Id;

    })

  }
  getUrlParams(param) {
    const queryString = window.location.search;
    const urlParams = new URLSearchParams(queryString);
    return urlParams.get(param);
  }


  getbillingStagingFields() {
    let recordObj = {}
    let requestData = {
      "type": "integrationprocedure",
      "value": {
        "ipMethod": "ARTL_validateBillingStagingFields",
        "inputMap": recordObj,
        "optionsMap": ''
      }
    }
    getDataHandler(JSON.stringify(requestData)).then(response => {
      this.ipResult = JSON.parse(response);
      if (this.ipResult.IPResult && this.ipResult.IPResult.fields) {
        this.billingStagingFields = this.ipResult.IPResult.fields;

        console.log("billingStagingFields" + JSON.stringify(this.billingStagingFields))
      }
      if (this.ipResult.IPResult) {
        this.validatetionOptions = this.ipResult.IPResult;
        console.log("validatetionOptions" + JSON.stringify(this.validatetionOptions))
      }
    })
  }

  getBillingDetails() {
    this.showLoading = true;
    let recordObj = { recordId: this.recordId }
    let requestData = {
      "type": "integrationprocedure",
      "value": {
        "ipMethod": "ARTL_createBASARecords",
        "inputMap": recordObj,
        "optionsMap": ''
      }
    }
    console.log("requestData::" + JSON.stringify(requestData));
    getDataHandler(JSON.stringify(requestData)).then(response => {
      this.ipResult = JSON.parse(response);
      if (this.ipResult && this.ipResult.IPResult) {
        this.data = this.ipResult.IPResult
      }
      if (this.data && this.data.result && this.data.result.errors) {
        this.ShowToast("Error", "No LineItem Availabel", "error", "Sticky");
      }
      console.log("billingData::" + JSON.stringify(this.data));
    })
    this.showLoading = false;
  }

  downloadReport() {

    this[NavigationMixin.GenerateUrl]({
      type: 'standard__webPage',
      attributes: {
        //url: '/00O720000042XjxEAE?pv0='+this.recordId//+'&export=1&enc=UTF-8&xf=csv'
        url: '/lightning/r/Report/' + this.reportId + '/view?fv0=' + this.recordId + '&csv=1&exp=1&enc=UTF-8&isdtp=p1'
      }
    }, false).then(generatedUrl => {
      console.log("generatedUrl" + generatedUrl)
      window.open(generatedUrl, '_blank');
    });
  }
  downloadCSVFile() {
    let rowEnd = '\n';
    let csvString = '';
    // this set elminates the duplicates if have any duplicate keys
    let rowData = new Set();

    // getting keys from data
    this.data.forEach(function (record) {
      Object.keys(record).forEach(function (key) {
        rowData.add(key);
      });
    });

    // Array.from() method returns an Array object from any object with a length property or an iterable object.
    rowData = Array.from(rowData);

    // splitting using ','
    csvString += rowData.join(',');
    csvString += rowEnd;

    // main for loop to get the data based on key value
    for (let i = 0; i < this.data.length; i++) {
      let colValue = 0;

      // validating keys in data
      for (let key in rowData) {
        if (rowData.hasOwnProperty(key)) {
          // Key value 
          // Ex: Id, Name
          let rowKey = rowData[key];
          // add , after every value except the first.
          if (colValue > 0) {
            csvString += ',';
          }
          // If the column is undefined, it as blank in the CSV file.
          let value = this.data[i][rowKey] === undefined ? '' : this.data[i][rowKey];
          csvString += '"' + value + '"';
          colValue++;
        }
      }
      csvString += rowEnd;
    }

    // Creating anchor element to download
    let downloadElement = document.createElement('a');

    // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
    downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
    downloadElement.target = '_self';
    // CSV File Name
    downloadElement.download = 'Billing Account Data.csv';
    // below statement is required if you are using firefox browser
    document.body.appendChild(downloadElement);
    // click() Javascript function to download CSV file
    downloadElement.click();
  }

  handleFilesChange(event) {
    if (event.target.files.length > 0) {
      this.filesUploaded = event.target.files;
      this.fileName = event.target.files[0].name;
      this.uploadHelper();
    }
  }

  uploadHelper() {
    this.file = this.filesUploaded[0];
    // if (this.file.size > this.MAX_FILE_SIZE) {
    //     console.log('File Size is to long');
    //     return;
    // }
    this.showLoading = true;
    this.fileReader = new FileReader();
    this.fileReader.onloadend = (() => {
      this.fileContents = this.fileReader.result;
      console.log('this.fileReader.result :: ' + this.fileReader.result);
      this.uploadData = this.csvJSON(this.fileContents).map(el =>
        Object.fromEntries(Object.entries(el).map(([key, value]) => ([
          key.replace(/\s+/g, "").replace(/:/g, ""),
          value.replace(/\r/g, "")
        ])))
      );
      //***** Uncomment after testing bulk data*****/
      // this.uploadData = this.uploadData.filter((item) => {
      //     return item.BillingStagingBillingStagingName != '';
      // });
      //***** Uncomment after testing bulk data*****/
      // this.validateRecords(this.uploadData, this.billingStagingFields);
    });
    this.fileReader.readAsText(this.file);
    this.showLoading = false;
  }

  validateRecords(uploadData, billingStagingFields) {
    let errrorArray = [];
    for (let items of uploadData) {
      let errorFields = []
      for (let field of billingStagingFields) {
        if (items[field.fieldName] == "" && field.required) {
          errorFields = [...errorFields, field.fieldName];
          if (items.BillingStagingBillingStagingName) {
            console.log(field.fieldName + " is Required in Stagging Record ID " + items.BillingStagingBillingStagingName);
            errrorArray.push(field.fieldName + " is required in Stagging Record ID " + items.BillingStagingBillingStagingName)
          }
        }

      }
      let errorMsg;
      if (errorFields.length > 0) {
        errorMsg = "Failed to validate following fields ( " + errorFields.toString() + " )";
      }
      items['status'] = errorMsg;
    }
    if (uploadData) {
      let column = []
      for (let item of Object.keys(uploadData[0])) {
        column.push({ label: item, fieldName: item, editable: true })
      }
      this.columns = column;
      this.editTableData = uploadData;
      if (this.editTableData.length > 0) {
        this.showCsvsData = true
      }
      console.log("this.columns" + this.columns)
    }
    console.log("New uploadData" + JSON.stringify(this.editTableData));
    if (errrorArray.length > 0) {
      var errrorArrayString = [];
      for (const [index, value] of errrorArray.entries()) {
        errrorArrayString.push(index + 1 + " . " + value);
      }
      console.log('uploadData :: ' + JSON.stringify(this.uploadData));

      this.uploadData = false;
      console.log(errrorArrayString.toString().replace(/,/g, '.\n'));
      let errorMessage = errrorArrayString.toString().replace(/,/g, ',\n');
      this.ShowToast("Error", errorMessage, "error", "Sticky");
    }
    this.showLoading = false;
  }

  csvJSON(csv) {

    var items = []

    var rows = csv.split(/\n/g);
    var keys = rows.shift().split(",");

    rows.forEach(raw_row => {
      var row = {};
      var columns = raw_row.split(/,(?=(?:(?:[^"]*"){2})*[^"]*$)/);

      columns.forEach((column, index) => {
        var key = keys[index];
        if (!key) return;
        if (key === "Coordinates") {
          column = column.replace(/""/g, '"');
          column = column.substring(1, column.length - 1);
          column = column.replace(/([a-zA-Z_]+):/g, `"$1":`);
          try { column = JSON.parse(`{${column}}`); } catch (e) { }
        }
        row[key] = column;

      });
      items.push(row);
    });
    let jsonString = JSON.stringify(items).replaceAll(/\\"/g, '');
    return JSON.parse(jsonString); //JSON
  }

  updateBillingDetails() {
    this.showLoading = true;
    let recordObj = { records: this.uploadData }
    let requestData = {
      "type": "integrationprocedure",
      "value": {
        // "ipMethod": "ARTL_updateBillingStagingRecords",
        "ipMethod": "Test_TestBulkPNVSP",
        "inputMap": recordObj,
        "optionsMap": ''
      }
    }
    console.log("requestData::" + JSON.stringify(requestData));
    getDataHandler(JSON.stringify(requestData)).then(response => {
      this.ipResult = JSON.parse(response);
      try {
        this.updateResponse = this.ipResult.IPResult;
        this.ShowToast("Success", "Record updated successfully", "success", "dismissable");
        console.log("updateResponse::" + JSON.stringify(this.updateResponse));
      }
      catch (err) {
        this.ShowToast("Error", err, "error", "dismissable");
      }
      if (this.ipResult && this.ipResult.IPResult) {
      }
      this.uploadData = false;
    })
    this.showLoading = false;
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
  closeModal() {
    this.showCsvsData = false;
  }
  handleSave(event) {
    var draftedValue = event.detail.draftValues;
    console.log("editTableData" + JSON.stringify(draftedValue))
  }
  LegalEntity() {
    this[NavigationMixin.Navigate]({
      type: 'standard__webPage',
      attributes: {
        url: this.LegalEntity
      }
    }, false);
  }

  uploadRecords() {
    this.showLoading = true;
    this.totalLength = this.uploadData.length;
    this.firstIndex = 0;
    this.lastIndex = 0;
    this.recordsLeft = this.totalLength;
    let promises = [];
    this.isShowModal = true;
    this.progress = 1;
    if (this.totalLength >= 1000000) this.batchsize = 5000;
    else if (this.totalLength > 1000) {
      //this.batchsize = Math.floor(this.totalLength / 50);
      this.batchsize = Math.floor(this.totalLength / 20);
    }
    else {
      this.batchsize = 50;
    }
    console.log('batchsize::', this.batchsize);
    try {
      while (promises.length <= 5 && this.recordsLeft > 0) {
        if (this.recordsLeft <= this.batchsize) {
          //   let rowLines = this.uploadData.slice(this.firstIndex, this.totalLength);
          let rowLines = this.uploadData;
          let toastMsg = 'Upload has been complete, validation in progress, we will notify once the validation has been completed';
          let errorMsg = 'Upload failed!!, Please verify the data, and try again';
          console.log('tableData length' + this.uploadData.length);
          console.log('this.uploadDataPNNN', JSON.stringify(this.uploadData));
          this.firstIndex = this.totalLength;
          this.recordsLeft = 0;
          console.log('totalLength::' + this.totalLength);
          console.log('recordsLeft::' + this.recordsLeft);
          console.log('firstIndex::' + this.firstIndex);
          let request = [];
          //request.push(this.header);
          request = [...rowLines];
          console.log('requestPNNN', JSON.stringify(request));
          let promise = new Promise((resolve, reject) => {
            uploadAction({ inputCSV: JSON.stringify(request) })
              .then(result => {
                console.log('uploadAction.result' + result);
                resolve(result);
                this.progress = Math.round((this.totalLength - this.recordsLeft) / this.totalLength * 100);
                if (this.progress == 100) {
                  this._uploadComplete = true;
                  //alert('Hi');
                  if (result === 'Success') {
                    this.showSuccessToastMsg(toastMsg);
                    validateStagingData({ recordId: this.recordId, isTest: false }).then(result => {
                      if (result) {
                        console.log('result');
                        // this.navigateToRecordPage();
                      }
                    }).catch(error => {
                      console.log('error' + JSON.stringify(error));
                    })
                  }
                  else{
                    this.ShowToast("Error", errorMsg, "error", "dismissable");
                  }
                  //this.handleUploadComplete('Upload has been complete, validation in progress, we will notify once the validation has been completed', 'warning', 'Submit', 'submit');
                }
              })
              .catch(error => {
                reject();
              });
          });
          promises.push(promise);
        }
        else {
          this.lastIndex += this.batchsize;
          let rowLines = this.uploadData.slice(this.firstIndex, this.lastIndex);
          console.log('tableData length' + this.uploadData.length);
          console.log('this.uploadDataPNNN', JSON.stringify(this.uploadData));
          this.firstIndex += this.batchsize;
          this.recordsLeft -= this.batchsize;
          console.log('totalLength::' + this.totalLength);
          console.log('recordsLeft::' + this.recordsLeft);
          let request = [];
          request = [...rowLines];
          console.log('requestPNNN', JSON.stringify(request));
          let promise = new Promise((resolve, reject) => {
            uploadAction({ inputCSV: JSON.stringify(request) })
              .then(result => {
                console.log('uploadAction.result' + result);
                resolve(result); this.progress = Math.round((this.totalLength - this.recordsLeft) / this.totalLength * 100);
              })
              .catch(error => {
                reject();
                console.log('error:', JSON.stringify(error));
              });
          })
          promises.push(promise);
          console.log('this.tableHeaderData::' + this.tableHeaderData);
          console.log('firstIndex::' + this.firstIndex);
        }
      }
      this.allpromises = promises;
      this.saveAll(promises);
    }
    catch (e) {
      this.showLoading = false;
    }
  }
  saveAll(promises) {
    Promise.all(promises).then((values) => {
      let promisesNextSet = [];
      if (this.recordsLeft > 0) {
        while (promisesNextSet.length <= 5 && this.recordsLeft > 0) {
          if (this.recordsLeft <= this.batchsize) {
            let rowLines = this.uploadData.slice(this.firstIndex, this.totalLength);
            console.log('tableData length' + this.uploadData.length);
            console.log('saveAll.this.uploadData' + JSON.stringify(this.uploadData));
            this.firstIndex = this.totalLength;
            this.recordsLeft = 0;
            console.log('totalLength::' + this.totalLength);
            console.log('recordsLeft::' + this.recordsLeft);
            console.log('firstIndex::' + this.firstIndex);
            let request = [];
            request = [...rowLines];
            console.log('saveAll.this.request' + JSON.stringify(request));
            let promise = new Promise((resolve, reject) => {
              uploadAction({ inputCSV: JSON.stringify(request) })
                .then(result => {
                  console.log('uploadAction.result' + result);
                  resolve(result); this.progress = Math.round((this.totalLength - this.recordsLeft) / this.totalLength * 100);
                })
                .catch(error => {
                  reject();
                  console.log('error:', JSON.stringify(error));
                });
            })
            promisesNextSet.push(promise);
          }
          else {
            this.lastIndex += this.batchsize;
            let rowLines = this.uploadData.slice(this.firstIndex, this.lastIndex);
            console.log('tableData length' + this.uploadData.length);
            this.firstIndex += this.batchsize;
            this.recordsLeft -= this.batchsize;
            console.log('totalLength::' + this.totalLength);
            console.log('recordsLeft::' + this.recordsLeft);
            let request = [];
            console.log('saveAll.this.uploadData' + JSON.stringify(this.uploadData));
            request = [...rowLines];
            console.log('saveAll.this.request' + JSON.stringify(request));
            let promise = new Promise((resolve, reject) => {
              uploadAction({ inputCSV: JSON.stringify(request) })
                .then(result => {
                  console.log('uploadAction.result' + result);
                  resolve(result); this.progress = Math.round((this.totalLength - this.recordsLeft) / this.totalLength * 100);
                })
                .catch(error => {
                  reject();
                  console.log('error:', JSON.stringify(error));
                });
            })
            promisesNextSet.push(promise);
            console.log('this.tableHeaderData::' + this.tableHeaderData);
            console.log('firstIndex::' + this.firstIndex);
          }
        }
      }
      else {
        this.showLoading = false;
        this.progress = 100;
        this._uploadComplete = true;

      }
      if (promisesNextSet.length > 0) {
        this.saveAll(promisesNextSet);
      }
    }).catch((e) => {
      console.log(e);
    });
    this.showLoadingSpinner = false;

  }


  showSuccessToastMsg(message) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: 'Success',
        message: message,
        variant: 'Success',
        //mode: 'sticky'
      }),
    );
  }

}