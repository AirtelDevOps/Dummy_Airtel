import { LightningElement, api } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { getDataHandler } from "vlocity_cmt/utility";

export default class ArtlDownloadQLIMultipicklistTableNips extends LightningElement {
    columns;
    showSpinner = false;
    accountData;
    draftValues = [];
    lastSavedData = [];
    // JS Properties 
    pageSizeOptions = [5, 10, 25, 50, 75, 100]; //Page size options
    records = []; //All records available in the data table
    columns = []; //columns information available in the data table
    totalRecords = 0; //Total no.of records
    pageSize; //No.of records to be displayed per page
    totalPages; //Total no.of pages
    pageNumber = 1; //Page number    
    recordsToDisplay = []; //Records to be displayed on the page
    @api currentQuoteLineItemsData;

    pickListOptions;
    isRenderd = false;
    //currentQuoteLineItemsData;

    connectedCallback() {
        //this.currentQuoteLineItemsData= this.data;
        this.columns=[
            { label: 'Item Code', fieldName: 'ItemCode' },
            { label: 'Tax%', fieldName: 'TaxPerc' },
            { label: 'Quantity', fieldName: 'QTY' },
            { label: 'Hardware Type', fieldName: 'HardwareType' },
            { label: 'Service Type', fieldName: 'NIPSServiceType' },
            { label: 'ARC', fieldName: 'ARC' },
            { label: 'OTC', fieldName: 'OTC' },
            { label: 'OV Status', fieldName: 'OVStatus' },
            {
              label: 'OV Reason', fieldName: 'OVRejectionReason', type: 'multiselectpicklistColumn', typeAttributes: {
                  placeholder: 'Update Reason', options: [
                    { label: 'Approved - No action required', value: 'Approved - No action required' },
                    { label: 'Document related customer is minor less than 15 Years', value: 'Document related customer is minor less than 15 Years' },
                    { label: 'MNP - Competition Bill copy customer name not clear', value: 'MNP - Competition Bill copy customer name not clear' },
                    { label: 'POA copy not clear', value: 'POA copy not clear' },
                    { label: 'POA related issue - POA not allowed', value: 'POA related issue - POA not allowed' },
                    { label: 'POI copy not clear POI copy not complete', value: 'POI copy not clear POI copy not complete' },
                    { label: 'POI related issue - POI not allowed Local address entered with dummy details', value: 'POI related issue - POI not allowed Local address entered with dummy details' },
                    { label: 'Customer live photo not clear Live photo not matching with POI/POA Details mismatch data entry vs attached upload document Punching related rejected due to incomplete punching', value: 'Customer live photo not clear Live photo not matching with POI/POA Details mismatch data entry vs attached upload document Punching related rejected due to incomplete punching' },
                    { label: 'MNP - Competition Bill copy customer name vs punching Customer name different ARC/OTC charges mismatch between attached PO V/s punched in system', value: 'MNP - Competition Bill copy customer name vs punching Customer name different ARC/OTC charges mismatch between attached PO V/s punched in system' },
                    { label: 'Attached all documents not readable', value: 'Attached all documents not readable' },
                    { label: 'Attached COI not readable', value: 'Attached COI not readable' },
                    { label: 'Attached deed not readable', value: 'Attached deed not readable' },
                    { label: 'Attached POI not readable', value: 'Attached POI not readable' },
                    { label: 'City name/Pin code/State mismatch between attached PO V/s punched in system', value: 'City name/Pin code/State mismatch between attached PO V/s punched in system' },
                    { label: 'Company stamp missing on PO', value: 'Company stamp missing on PO' },
                    { label: 'Complete GST Document not attached', value: 'Complete GST Document not attached' },
                    { label: 'Contract period mismatch between attached PO V/s system GST Number not available in SEZ File (SEZ team approval mail required) Incorrect Date captured on PO', value: 'Contract period mismatch between attached PO V/s system GST Number not available in SEZ File (SEZ team approval mail required) Incorrect Date captured on PO' },
                    { label: 'Incorrect total amount captured (OTC + ARC + contract period)', value: 'Incorrect total amount captured (OTC + ARC + contract period)' },
                    { label: 'Instead of OTC amount, ARC Amount captured or Vice/ Versa', value: 'Instead of OTC amount, ARC Amount captured or Vice/ Versa' },
                    { label: 'Legal Entity mismatch between attached PO V/s system', value: 'Legal Entity mismatch between attached PO V/s system' },
                    { label: 'Mismatch of Billing terms/frequency between PO Vs. system', value: 'Mismatch of Billing terms/frequency between PO Vs. system' },
                    { label: 'Mismatch of Company name between Company Pan Card VS COI/Society Registration/Trust Deed/Partnership deed', value: 'Mismatch of Company name between Company Pan Card VS COI/Society Registration/Trust Deed/Partnership deed' },
                    { label: 'Mismatch of Company name between System VS GST Document', value: 'Mismatch of Company name between System VS GST Document' },
                    { label: 'Mismatch of contract Period vs contract termination clause under T&C Mismatch of Product manageability between PO Vs. system', value: 'Mismatch of contract Period vs contract termination clause under T&C Mismatch of Product manageability between PO Vs. system' },
                    { label: 'Multiple City name appearing against same Pin Code in Billing/Installation/Company Address', value: 'Multiple City name appearing against same Pin Code in Billing/Installation/Company Address' },
                    { label: 'Multiple city/Correct city not appearing against same PIN code selected', value: 'Multiple city/Correct city not appearing against same PIN code selected' },
                    { label: 'Multiple Pin Code appearing against same City in Billing/Installation/Company Address', value: 'Multiple Pin Code appearing against same City in Billing/Installation/Company Address' },
                    { label: 'Non-taxable order logged instead of taxable', value: 'Non-taxable order logged instead of taxable' },
                    { label: 'Organization proof not attached', value: 'Organization proof not attached' },
                    { label: 'Taxable order logged instead of Non-taxable', value: 'Taxable order logged instead of Non-taxable' },
                    { label: 'Taxation approval not attached/not readable', value: 'Taxation approval not attached/not readable' },
                    { label: 'BCP/DCP/Invoice address mismatch between System Vs PO/ Document', value: 'BCP/DCP/Invoice address mismatch between System Vs PO/ Document' },
                    { label: 'Approve epcn / Finance approval mail missing', value: 'Approve epcn / Finance approval mail missing' },
                    { label: 'GST undertaking missing', value: 'GST undertaking missing' },
                    { label: 'POA copy not complete Document related - Rejeced due to document non compliant', value: 'POA copy not complete Document related - Rejeced due to document non compliant' },
                  ] // list of all picklist options
                  , value: { fieldName: 'OVRejectionReason' } // default value for picklist
                  , context: { fieldName: 'Id' } // binding account Id with context variable to be returned back
              },
              initialWidth: 450
            }
        ];
        this.data =  JSON.parse(JSON.stringify(this.currentQuoteLineItemsData));
        this.records =  this.data
        this.totalRecords =  this.data.length; // update total records count                 
        this.pageSize = this.pageSizeOptions[0]; //set pageSize with default value as first option
        this.paginationHelper(); 
    }

    updateDataValues(updateItem) {
        let copyData = JSON.parse(JSON.stringify(this.data));

        console.log("this.data", this.data);
        console.log("updateItem", updateItem);
        copyData.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
            }
        });

        //write changes back to original data
        this.data = [...copyData];
    }

    updateDraftValues(updateItem) {
        let draftValueChanged = false;
        let copyDraftValues = [...this.draftValues];
        //store changed value to do operations
        //on save. This will enable inline editing &
        //show standard cancel & save button
        copyDraftValues.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
                draftValueChanged = true;
            }
        });

        if (draftValueChanged) {
            this.draftValues = [...copyDraftValues];
        } else {
            this.draftValues = [...copyDraftValues, updateItem];
        }
    }

    //listener handler to get the context and data
    //updates datatable
    multpicklistChanged(event) {
        event.stopPropagation();
        let dataRecieved = event.detail.data;
        console.log(event.detail.data);

        let updatedItem = { Id: dataRecieved.context, Value: dataRecieved.value};
        console.log(updatedItem);
        this.updateDraftValues(updatedItem);
        this.updateDataValues(updatedItem);
    }

    //handler to handle cell changes & update values in draft values
    handleCellChange(event) {
        console.log(event.detail.draftValues[0]);
        let draftValues = event.detail.draftValues;
        draftValues.forEach(ele=>{
            this.updateDraftValues(ele);
        })
    }

    handleSave(event) {
        this.showSpinner = true;
        this.saveDraftValues = this.draftValues;
        console.log("this.draftValues", this.draftValues);
        const recordInputs = this.saveDraftValues;
        console.log("this.recordInputs", recordInputs);
        //save last saved copy
        this.lastSavedData = JSON.parse(JSON.stringify(this.data));
        let requestData = {
          "type": "integrationprocedure",
          "value": {
              "ipMethod": "ARTL_UpdateOVTableStatus",
              "inputMap": {"data" : recordInputs},
              "optionsMap": ''
          }
      }
      getDataHandler(JSON.stringify(requestData)).then(response => {
          this.ipResult = JSON.parse(response);
          if (this.ipResult && this.ipResult.IPResult) {
              let result = this.ipResult.IPResult;
              if (result) {
                    setTimeout( function() {
                        window.location.reload();
                    }, 1000);
                  };
                } 
              this.loading = false;
          });
    }

    handleCancel(event) {
        //remove draftValues & revert data changes
        this.data = JSON.parse(JSON.stringify(this.lastSavedData));
        this.draftValues = [];
    }

    showToast(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }

    // This function is used to refresh the table once data updated
    async refresh() {
        await refreshApex(this.accountData);
    }

    handleChange(event){
        console.log(event.detail);
    }

    // JS function to handel pagination logic 
    handleRecordsPerPage(event) {
        this.pageSize = event.target.value;
        this.paginationHelper();
    }
    previousPage() {
        this.pageNumber = this.pageNumber - 1;
        this.paginationHelper();
    }
    nextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.paginationHelper();
    }
    firstPage() {
        this.pageNumber = 1;
        this.paginationHelper();
    }
    lastPage() {
        this.pageNumber = this.totalPages;
        this.paginationHelper();
    }
   
    paginationHelper() {
        this.recordsToDisplay = [];
        // calculate total pages
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
        // set page number 
        if (this.pageNumber <= 1) {
            this.pageNumber = 1;
        } else if (this.pageNumber >= this.totalPages) {
            this.pageNumber = this.totalPages;
        }
        // set records to display on current page 
        for (let i = (this.pageNumber - 1) * this.pageSize; i < this.pageNumber * this.pageSize; i++) {
            if (i === this.totalRecords) {
                break;
            }
            this.recordsToDisplay.push(this.records[i]);
        }
    }
}