import { LightningElement, wire, api } from 'lwc';
import LightningModal from 'lightning/modal';
import { getDataHandler } from "vlocity_cmt/utility";
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from "lightning/refresh";
import { updateRecord, notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from "lightning/actions";
import { NavigationMixin } from 'lightning/navigation';



const columns = [
    {
        label: 'Name',
        fieldName: 'Name',
        type: 'text',
    }, {
        label: 'Quantity',
        fieldName: 'Quantity',
        type: 'number',
        editable: true,
        cellAttributes: { class: 'slds-icon-* ' }
    }, {
        label: 'Sales Price',
        fieldName: 'SalesPrice',
        type: 'currency',
        editable: true,
        cellAttributes: { class: 'slds-icon-* ' }
    }, {
        label: 'Description',
        fieldName: 'Description',
        type: 'text',
        editable: true,
        cellAttributes: { class: 'slds-icon-* ' }
    }
];

export default class ArtlAddProduct extends NavigationMixin(LightningElement) {
    @api showLoading = false;
    columns = columns;
    saveDraftValues = [{}]
    @api productList
    @api recordId;
    @api objectApiName;
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
    }

    connectedCallback() {
        if (this.recordId) {
            this.getProducts();
        }
    }

    getProducts() {
        let recordObj = { recordId: this.recordId }
        let requestData = {
            "type": "integrationprocedure",
            "value": {
                "ipMethod": "ARTL_GetProducts",
                "inputMap": recordObj,
                "optionsMap": ''
            }
        }
        getDataHandler(JSON.stringify(requestData)).then(response => {
            this.ipResult = JSON.parse(response);
            if (this.ipResult.IPResult) {
                this.productList = this.ipResult.IPResult
            }
        })
    }

    @api content;

    handleOkay() {
        this.close('okay');
    }

    getSelectedRec() {
        var selectedRecords = this.template.querySelector("lightning-datatable").getSelectedRows();
        if (selectedRecords.length > 0) {
            let ids = '';
            selectedRecords.forEach(currentItem => {
                ids = ids + ',' + currentItem.Id;
            });
            this.selectedIds = ids.replace(/^,/, '');
            this.lstSelectedRecords = selectedRecords;
            alert(this.selectedIds);
        }
    }

    handleSave(event) {
        this.showLoading = true;
        var draftedValue = event.detail.draftValues;
        var el = this.template.querySelector('lightning-datatable');
        var selected = el.getSelectedRows();
        const map2 = new Map(draftedValue.map(item => [item.Id, item]));
        if (selected && selected.length > 0) {
            const mergedArray = selected.map(item => {
                const newItem = { ...item };
                if (map2.has(item.Id)) {
                    if (map2.get(item.Id).Quantity && map2.get(item.Id).SalesPrice) {
                        newItem.Quantity = map2.get(item.Id).Quantity;
                        newItem.SalesPrice = map2.get(item.Id).SalesPrice;
                        if (map2.get(item.Id).Description) {
                            newItem.Description = map2.get(item.Id).SalesPrice;
                        }
                    }
                }
                return newItem;
            });

            console.log("mergedArray" + JSON.stringify(mergedArray));
            const isEmpty = (value) => value === undefined || value === null || value === '';

            const doEmptyAction = mergedArray.some((item) => isEmpty(item.SalesPrice) || isEmpty(item.Quantity));
            if (!doEmptyAction) {
                this.createOpptyLineItems(mergedArray);
            }
            else {
                this.ShowToast('Error', 'Please check you have entered "Quantity" & "Sales Price" fields!!', 'error', 'dismissable');

                this.showLoading = false;
            }

        }
        else {
            this.ShowToast('Error', 'Please select products', 'error', 'dismissable');
            this.showLoading = false;
        }

    }

    createOpptyLineItems(liDta) {
        let recordObj = { opportunityId: this.recordId, oli: liDta }
        let requestData = {
            "type": "integrationprocedure",
            "value": {
                "ipMethod": "ARTL_CreateOLI",
                "inputMap": recordObj,
                "optionsMap": ''
            }
        }
        getDataHandler(JSON.stringify(requestData)).then(response => {
            this.ipResult = JSON.parse(response);
            console.log('createOpptyLineItems:' + JSON.stringify(this.ipResult));
            if (this.ipResult.IPResult && this.ipResult.IPResult.OpportunityLineItem_1 && this.validateResult(this.ipResult.IPResult.OpportunityLineItem_1)) {
                this.ShowToast('Success', 'Records Created Successfully!', 'success', 'dismissable');
                updateRecord({ fields: { Id: this.recordId } });
                this.showLoading = false;
                // setTimeout(() => {
                //     eval("$A.get('e.force:refreshView').fire();");
                // }, 1000); 
                this.handleRefresh();
                this.navigateToRecordViewMode();
                this.dispatchEvent(new CloseActionScreenEvent());

            }
            else {
                if (this.ipResult.IPResult && this.ipResult.IPResult.result && this.ipResult.IPResult.result.errorsAsJson && this.ipResult.IPResult.result.errorsAsJson.oli[0]) {
                    let errorNode = this.ipResult.IPResult.result.errorsAsJson.oli[0];
                    if (errorNode.SalesPrice) {
                        this.ShowToast('Error', errorNode.SalesPrice, 'error', 'dismissable');
                    }
                    if (errorNode.Quantity) {
                        this.ShowToast('Error', errorNode.Quantity, 'error', 'dismissable');
                    }
                    if (errorNode.Name) {
                        this.ShowToast('Error', errorNode.Name, 'error', 'dismissable');
                    }
                    if (errorNode.Description) {
                        this.ShowToast('Error', errorNode.Description, 'error', 'dismissable');
                    }


                }
                else {
                    this.ShowToast('Error', 'An Error Occured!!', 'error', 'dismissable');

                }
                this.showLoading = false;
            }
        })
    }

    validateResult(arr) {
        return arr.every(element => element.UpsertSuccess === true);
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

    handleRefresh() {
        // location.reload();
        this.dispatchEvent(new RefreshEvent());
    }
    navigateToRecordViewMode() {
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: this.recordId,
                objectApiName: this.objectApiName,
                actionName: 'view'
            }
        })
    }
}