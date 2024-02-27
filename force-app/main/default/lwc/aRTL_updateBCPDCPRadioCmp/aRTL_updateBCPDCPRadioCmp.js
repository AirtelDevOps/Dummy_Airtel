import { LightningElement, wire, track, api } from 'lwc';
import { OmniscriptBaseMixin } from "vlocity_cmt/omniscriptBaseMixin";
import { getDataHandler } from "vlocity_cmt/utility";
export default class ARTL_updateBCPDCPRadioCmp extends OmniscriptBaseMixin(LightningElement) {
    data = [];
    _state = '';
    columns = [
        { label: 'BCP/DCP Id', fieldName: 'RoleBasedId' },
        { label: 'Contact Name', fieldName: 'ContactName' },
        //{ label: 'Address', fieldName: 'StreetAddress' },
        { label: 'Address', fieldName: 'Address' },
        { label: 'GST#', fieldName: 'GSTNumber', type: 'text', cellAttributes: { alignment: 'left' } }
    ];
    @track resp = {
        restrictNext: true,
        state: '',
        rows: {}
    }
    @track pageSize = 5;
    @track comboBoxVal = 5;
    @track currentPage = 1;
    //pageSizeOptions = [{ label: 5, value: 5 }, { label: 10, value: 10 }, { label: 20, value: 20 }];
    @track pageSizeOptions = [
        { label: '5', value: 5 },
        { label: '10', value: 10 },
        { label: '20', value: 20 }
    ];
    @track selectedRows = [];
    selectedIds = [];
    @api records;
    @api recid;
    @track pagedData;
    @track isPreviousDisabled = true;
    @track isNextDisabled = true;


    selectedData = {};
    connectedCallback() {
        this.omniApplyCallResp(this.resp);
        console.log('this.records' + JSON.stringify(this.recid));
        console.log('this.pageSize' + JSON.stringify(this.pageSize));
        this.getCPRecords();
        // this.data = JSON.parse(JSON.stringify(this.records));
        // console.log('this.data' + JSON.stringify(this.data));
        // //this.data.sort((a, b) => a.Role.localeCompare(b.Role));
        // this.selectedRows = [this.data[0].Id];
        // this.resp.rows = this.data[0];
        // this.omniApplyCallResp(this.resp);
    }

    

    handleRowSelection(evt) {
        let selectedRows = this.template.querySelector('[data-id="qlitable"]').getSelectedRows();
        if (selectedRows.length !== 0) this.resp.restrictNext = false;
        else if (selectedRows.length === 0) this.resp.restrictNext = true;
        this.resp.rows = selectedRows[0];
        this.omniApplyCallResp(this.resp);
    }
    getCPRecords() {
        let recordObj = { ContextId: this.recid }
        let requestData = {
            "type": "integrationprocedure",
            "value": {
                "ipMethod": "ARTL_GetContactPersonDetails",
                "inputMap": recordObj,
                "optionsMap": ''
            }
        }
        getDataHandler(JSON.stringify(requestData)).then(response => {
            this.ipResult = JSON.parse(response);
            if (this.ipResult && this.ipResult.IPResult) {
                this.data = this.ipResult.IPResult;
                this.data.forEach((record) => {
                    record.RoleBasedId = record.Role === 'DCP' ? record.DCP : record.BCP;
                    record.ContactName = record.FirstName + ' ' + record.LastName;
                    record.Address = record.City + ', ' + record.State + ', ' + record.StreetAddress + ', ' + record.PostalCode;
                    record.GSTNumber = record.GSTNumber || '--';
                    if (record.Role === 'BCP') {
                        delete record.DCP;
                    }
                    else {
                        delete record.BCP;
                    }
                    // if(record.GSTNumber){
                    //     record.GSTNumber = record.GSTNumber;
                    // }
                    // else{
                    //     record.GSTNumber = '--';
                    // }

                });
            }
            console.log('bcpdcpradiodataBefore' + JSON.stringify(this.data));
            this.data.sort((a, b) => {
                var roleA = a.RoleBasedId.toUpperCase();
                var roleB = b.RoleBasedId.toUpperCase();

                if (roleA < roleB) {
                    return -1;
                }
                if (roleA > roleB) {
                    return 1;
                }

                // If RoleBasedId is the same, maintain the original order
                return 0;
            });
            this.pagedData = this.data.slice(0, this.pageSize);
            if(this.data.length > this.pageSize){
                this.isNextDisabled = false;
            }
            this.selectedRows = [this.pagedData[0].Id];
            this.resp.rows = this.pagedData[0];
            console.log('bcpdcpradiodata' + JSON.stringify(this.data));
            this.omniApplyCallResp(this.resp);
        });
    }

    handlePageSizeChange(event) {
        const selectedValue = event.detail.value; // Get the selected option's value
        this.pageSize = selectedValue;
        this.comboBoxVal =  +event.detail.value;
        //this.template.querySelector('lightning-combobox').value = this.pageSize;
        console.log(typeof this.template.querySelector('lightning-combobox').value === 'string');
        // Update the current page if it exceeds the new page count
        const totalPages = Math.ceil(this.data.length / this.pageSize);
        if (this.currentPage > totalPages) {
            this.currentPage = totalPages;
        }
    
        // Disable next button if the last page is reached
        this.isNextDisabled = this.currentPage === totalPages;
    
        // Update pagedData based on the new page size
        const startIdx = (this.currentPage - 1) * this.pageSize;
        const endIdx = Math.min(startIdx + this.pageSize, this.data.length);
        this.pagedData = this.data.slice(startIdx, endIdx);
    
        // Update selected rows and response
        this.selectedRows = [this.pagedData[0].Id];
        this.resp.rows = this.pagedData[0];
        this.omniApplyCallResp(this.resp);
    }
    
    handleNext(event) {
        const totalPages = Math.ceil(this.data.length / this.pageSize);
    
        if (this.currentPage < totalPages) {
            this.currentPage++;
            this.isPreviousDisabled = false;
        }
    
        // Disable next button if the last page is reached
        this.isNextDisabled = this.currentPage === totalPages;
    
        // Update pagedData for the next page
        const startIdx = (this.currentPage - 1) * this.pageSize;
        const endIdx = Math.min(startIdx + this.pageSize, this.data.length);
        this.pagedData = this.data.slice(startIdx, endIdx);
    
        // Update selected rows and response
        this.selectedRows = [this.pagedData[0].Id];
        this.resp.rows = this.pagedData[0];
        this.omniApplyCallResp(this.resp);
    }
    
    handlePrevious(event) {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.isNextDisabled = false;
        }
    
        // Disable previous button if the first page is reached
        this.isPreviousDisabled = this.currentPage === 1;
    
        // Update pagedData for the previous page
        const startIdx = (this.currentPage - 1) * this.pageSize;
        const endIdx = Math.min(startIdx + this.pageSize, this.data.length);
        this.pagedData = this.data.slice(startIdx, endIdx);
    
        // Update selected rows and response
        this.selectedRows = [this.pagedData[0].Id];
        this.resp.rows = this.pagedData[0];
        this.omniApplyCallResp(this.resp);
    }
    
}