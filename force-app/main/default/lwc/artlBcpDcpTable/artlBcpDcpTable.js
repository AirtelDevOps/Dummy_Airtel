import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import getContacts from '@salesforce/apex/Artl_BcpDcpCtrl.getBcpDcpByAccId';

export default class ArtlBcpDcpTable extends OmniscriptBaseMixin(LightningElement) {
    ERORR_MSG_NO_CONTACT_AVAILABLE = 'No BCP/DCP contact available for this account.';

    @api accId;
    @track columns = [
        //{ label: 'Id', fieldName: 'Id'},
        { label: 'First Name', fieldName: 'firstName' },
        { label: 'Last Name', fieldName: 'lastName' },
        { label: 'Email', fieldName: 'email' },
        { label: 'Phone', fieldName: 'mobilePhone' },
        { label: 'Role', fieldName: 'role' },
        { label: 'Designation', fieldName: 'designation' },
        { label: 'Street', fieldName: 'streetAddress' },
        { label: 'City', fieldName: 'city' },
        { label: 'State', fieldName: 'state' },
        { label: 'Country', fieldName: 'country' },
        { label: 'Postal Code', fieldName: 'postalCode' },
        { label: 'GST', fieldName: 'gstNumber' }
    ];    
  
    @track showLoadingSpinner = false;
    
    @track selectedRows = [];
    rowOffset = 0;
    allRecords;
    visibleRecords = [];
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
            //console.log('pageSize' + this.pageSize);
            //console.log('totalPage' + this.totalPage);
            //console.log('pageSize' + this.pageSize);
            //console.log('pageSize' + this.pageSize);
            //console.log('visibleRecords' + this.visibleRecords.length);
            //console.log('allRecords' + this.allRecords.length);
        }
        //console.log('End contactList');
    }

    get disablePreviousPage(){ 
        return this.currentPage<=1;
    }
    get disableNextPage(){ 
        return this.currentPage>=this.totalPage;
    }

    connectedCallback(){
        //console.log('Start connectedCallback');
        //console.log('this.allRecords=' + JSON.stringify(this.allRecords));
        this.showLoadingSpinner = true;
        //console.log('this.omniJsonData.ContextId=' + JSON.stringify(this.omniJsonData.ContextId));
        let contextId = JSON.stringify(this.omniJsonData.ContextId);
        //console.log('this.contextId=' + contextId);

        if(contextId && contextId.startsWith('"') && contextId.endsWith('"')){
            ////console.log('Inside if');
            contextId = contextId.replace(/"/g, '');
            this.accId = contextId;
            ////console.log('headerString =' + headerString) + '=';
        }
        //console.log('this.accId=' + this.accId);

        this.getContactsData();
        
        //console.log('End connectedCallback');
    }

    getContactsData(){
        getContacts({ accId: this.accId})
            .then(result => {
                this.showLoadingSpinner = false;
                //console.log('result=' + JSON.stringify(result) +'=');
                if(result && Array.isArray(result) && result.length > 0){
                    //console.log('Inside if');
                    this.contactList = result;

                    let data = {"totalNumberOfRecords": result.length};
                    //console.log('totalNumberOfRecords=' + JSON.stringify(data));
                    this.omniApplyCallResp(data);
                }
                else {
                    //console.log('Inside else');
                    this.error = this.ERORR_MSG_NO_CONTACT_AVAILABLE;
                    this.contactList = undefined;
                    this.visibleRecords = undefined;
                    this.showToast('Error', this.ERORR_MSG_NO_CONTACT_AVAILABLE, 'error');

                    let data = {"totalNumberOfRecords": 0};
                    //console.log('totalNumberOfRecords=' + JSON.stringify(data));
                    this.omniApplyCallResp(data);
                    
                }
            })
            .catch(error => {
                this.showLoadingSpinner = false;
                //console.log('Error == ' + error.body.message);
                this.error = error.body.message;
                this.contactList = undefined;
                this.visibleRecords = undefined;
                this.showToast('Error', error.body.message, 'error');
            });
    }

    // handleRowSelect(evt){
    //     //console.log('Start handleRowSelect');

    //     const selectedRows = evt.detail.selectedRows;
    //     //console.log('selectedRows=' + JSON.stringify(selectedRows));

    //     let data = {selectedContacts: selectedRows};
    //     //console.log('selectedRows=' + JSON.stringify(data));
    //     this.omniApplyCallResp(data);

    //     //console.log('End handleRowSelect');
    // }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    handleRowSelection(event) {
        let updatedItemsSet = new Set();
        let selectedItemsSet = new Set(this.selectedRows);
        let loadedItemsSet = new Set();
        this.visibleRecords.map((ele) => {
            loadedItemsSet.add(ele.Id);
        });

        if (event.detail.selectedRows) {
            event.detail.selectedRows.map((ele) => {
                updatedItemsSet.add(ele.Id);
            });
            updatedItemsSet.forEach((id) => {
                if (!selectedItemsSet.has(id)) {
                    selectedItemsSet.add(id);
                }
            });
        }
        loadedItemsSet.forEach((id) => {
            if (selectedItemsSet.has(id) && !updatedItemsSet.has(id)) {
                selectedItemsSet.delete(id);
            }
        });
        
        this.selectedRows = [...selectedItemsSet];
        //console.log('selectedRows==> ' + JSON.stringify(this.selectedRows));

        let selectedContacts = [];
        //console.log('this.allRecords.length=' + this.allRecords.length);
        for (let index = 0; index < this.allRecords.length; index++) {
            ////console.log('All Id=' + this.allRecords[index].Id);
            if (selectedItemsSet.has(this.allRecords[index].Id)) {
                //console.log('Has id=' + this.allRecords[index].Id);
                selectedContacts.push(this.allRecords[index]);
            }            
        }
        let data = {"selectedContacts": selectedContacts};
        //console.log('selectedRows=' + JSON.stringify(data));
        this.omniApplyCallResp(data);
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