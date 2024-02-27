import { LightningElement, api } from 'lwc';
import { getDataHandler } from "vlocity_cmt/utility";

export default class ArtlDownloadQLIDetailsTable extends LightningElement {
    @api recordId; 
    @api currentQuoteLineItemsData;
   
    draftValues = [];
    lastSavedData = [];
     // JS Properties 
     pageSizeOptions = [2, 5, 10, 25, 50, 75, 100]; //Page size options
     records = []; //All records available in the data table
     columns = []; //columns information available in the data table
     totalRecords = 0; //Total no.of records
     pageSize; //No.of records to be displayed per page
     totalPages; //Total no.of pages
     pageNumber = 1; //Page number    
     recordsToDisplay = []; //Records to be displayed on the page

    connectedCallback() {
        this.columns=[
            { label: 'Sr#', fieldName: 'LineNumber' },
            { label: 'LSI', fieldName: 'LSI' },
            { label: 'Site', fieldName: 'Site' },
            { label: 'Link Type', fieldName: 'ProductName' },
            { label: 'Bandwidth', fieldName: 'Bandwidth' },
            { label: 'Service Type', fieldName: 'ServiceType' },
            { label: 'Media', fieldName: 'Media' },
            { label: 'PO#', fieldName: 'PONumber' },
            { label: 'PO Start Date', fieldName: 'POStartDate' },
            { label: 'PO Tenure', fieldName: 'POTenure' },
            { label: 'PO Amount', fieldName: 'POAmount' },
            { label: 'ARC', fieldName: 'ARC' },
            { label: 'OTC', fieldName: 'OTC' },
            { label: 'OV Status', fieldName: 'OVStatus' },
            {
              label: 'OV Reason', fieldName: 'OVRejectionReason', type: 'picklist', typeAttributes: {
                  placeholder: 'Update Reason', options: [
                      { label: 'Approved - No action required', value: 'Approved - No action required' },
                      { label: 'Approve epcn / Finance approval mail missing', value: 'Approve epcn / Finance approval mail missing' },
                      { label: 'Attached all documents not readable', value: 'Attached all documents not readable' },
                      { label: 'Complete GST Document not attached', value: 'Complete GST Document not attached' },
                      { label: 'POA copy not clear', value: 'POA copy not clear' },
                      { label: 'POA related issue - POA not allowed', value: 'POA related issue - POA not allowed' },
                      { label: 'Attached COI not readable', value: 'Attached COI not readable' },
                      { label: 'Attached deed not readable', value: 'Attached deed not readable' },
                      { label: 'Attached POI not readable', value: 'Attached POI not readable' },
                      { label: 'Company stamp missing on PO', value: 'Company stamp missing on PO' },
                      { label: 'Organization proof not attached', value: 'Organization proof not attached' },
                      { label: 'GST undertaking missing', value: 'GST undertaking missing' },
                      { label: 'Attached all documents not readable', value: 'Attached all documents not readable' },
                      { label: 'Taxable order logged instead of Non-taxable', value: 'Taxable order logged instead of Non-taxable' }
                  ] // list of all picklist options
                  , value: { fieldName: 'OVRejectionReason' } // default value for picklist
                  , context: { fieldName: 'Id' } // binding account Id with context variable to be returned back
                  , fieldname: 'OVRejectionReason'
                  , cellAttributes: {
                        class: {
                            fieldName: 'highlight'
                        }
                    }
              },
              initialWidth: 450
            }
        ];

      //sample data
      console.log("this.currentQuoteLineItemsData;", JSON.parse(JSON.stringify(this.currentQuoteLineItemsData)));
      this.data =  JSON.parse(JSON.stringify(this.currentQuoteLineItemsData));
      this.records =  this.data
      this.totalRecords =  this.data.length; // update total records count                 
      this.pageSize = this.pageSizeOptions[0]; //set pageSize with default value as first option
      this.paginationHelper(); 
        //  this.data = [{ 'Id': '12345', 'Name': 'Acme', 'AccountNumber': 'CD355119-A', 'Rating': 'Hot', phone: 12537 }, { 'Id': '34567', 'Name': 'Mace', 'AccountNumber': 'CD355120-A', 'Rating': 'Cold', phone: 1978234 }]
        //  this.data = [{ 'LineNumber': '12345', 'LSI': 'Acme', 'Site': 'CD355119-A', 'OVStatus': 'Hot' },
        //  { 'LineNumber': '34567', 'LSI': 'Mace', 'Site': 'CD355120-A', 'OVStatus': 'Cold' }]
       
        //save last saved copy
        this.lastSavedData = JSON.parse(JSON.stringify(this.data));
    }

    updateDataValues(updateItem) {
        let copyData = [... this.data];
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
        console.log("updateItem:", updateItem);
        console.log("copyDraftValues:", copyDraftValues);
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
    picklistChanged(event) {
        event.stopPropagation();
        console.log("event.detail.data", event.detail.data);
        let dataRecieved = event.detail.data;
        let updatedItem = { Id: dataRecieved.context, Value: dataRecieved.value};
        this.updateDraftValues(updatedItem);
        this.updateDataValues(updatedItem);
    }

    //handler to handle cell changes & update values in draft values
    handleCellChange(event) {
        this.updateDraftValues(event.detail.draftValues[0]);
    }

    handleSave(event) {
        console.log('Updated items', this.draftValues);
        this.draftValues = {"data": this.draftValues};
        //save last saved copy
        this.lastSavedData = JSON.parse(JSON.stringify(this.data));
        let requestData = {
          "type": "integrationprocedure",
          "value": {
              "ipMethod": "ARTL_UpdateOVTableStatus",
              "inputMap": this.draftValues,
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
    // JS function to handel pagination logic 
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