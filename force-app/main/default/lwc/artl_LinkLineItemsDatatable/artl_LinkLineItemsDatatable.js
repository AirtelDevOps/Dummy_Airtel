import { LightningElement, api, track, wire } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
//import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import QUOTELINEITEM_OBJECT from '@salesforce/schema/QuoteLineItem';
import QUOTE_OBJECT from '@salesforce/schema/Quote';
import OVSTATUS_FIELD from '@salesforce/schema/QuoteLineItem.ARTL_OVStatus__c';
import REJECTIONREASON_FIELD from '@salesforce/schema/QuoteLineItem.ARTL_LOVRejectionReason__c';
import { refreshApex } from '@salesforce/apex';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord } from 'lightning/uiRecordApi';
import { OmniscriptBaseMixin } from "vlocity_cmt/omniscriptBaseMixin";
//import { getObjectInfo } from "lightning/uiObjectInfoApi";

const columns = [
    { label: 'LSI', fieldName: 'LSI', type: 'number', editable: false },
    { label: 'Quote Member Name', fieldName: 'Site', type: 'text', editable: false },
    { label: 'Product', fieldName: 'Product', type: 'text', editable: false },
    {
        label: 'OV Status', fieldName: 'OVStatus', type: 'picklistColumn', editable: true, typeAttributes: {
            placeholder: 'Choose OV Status', options: { fieldName: 'statusPickListOptions' },
            value: { fieldName: 'ARTL_OVStatus__c' }, // default value for picklist,
            context: { fieldName: 'Id' } // binding account Id with context variable to be returned back
        }
    },
    {
        label: 'Rejection Reason', fieldName: 'RejectionReason', type: 'multiselectpicklistColumn', editable: false, typeAttributes: {
            placeholder: 'Choose Rejection Reason', options: { fieldName: 'pickListOptions' },
            value: { fieldName: 'ARTL_LOVRejectionReason__c' }, // default value for picklist,
            context: { fieldName: 'Id' } // binding quoteLineItem Id with context variable to be returned back
        }
    }
]

export default class artl_LinkLineItemsDatatable extends OmniscriptBaseMixin(LightningElement) {
    columns = columns;
    showSpinner = false;
    isRenderd = false;

    @track lastSavedData = [];
    data = [];
    finalLinkLineList = [];
    @track draftValues = [];
    @track pickListOptions;
    @track statusPickListOptions;
    @track testpickListOptions;
    _linklineitems = [];
    @track record;
    @track objectInfo;
    @api recordId;
    @api objectApiName;
    @track enterpriseQuoteRecordTypeId;



    @api
    get linklineitems() {
        return this._linklineitems;
    }
    set linklineitems(val) {
        this._linklineitems = val;
    }
    /*
        staticlinklineitems = [
            {
                LSI: "1234324",
                Id: '0QL720000002XuMGAU',
                Site: 'Mariner Square Loop',
                Product: 'Primary Link',
                OVStatus: "",
                RejectionReason: ""
            },
            {
                LSI: '1234324',
                Id: '0QL720000002XuSGAU',
                Site: 'Mariner Square Loop',
                Product: 'Primary Link',
                OVStatus: "",
                RejectionReason: ""
            },
            {
                LSI: '1234324',
                Id: '0QL720000002XvyGAE',
                Site: 'Mariner Square Loop',
                Product: 'Primary Link',
                OVStatus: "",
                RejectionReason: ""
            },
            {
                LSI: '1234324',
                Id: '0QL720000002Xw4GAE',
                Site: 'Mariner Square Loop',
                Product: 'Primary Link',
                OVStatus: "",
                RejectionReason: ""
            }
        ];
    */

    // @wire(getObjectInfo, { objectApiName: QUOTELINEITEM_OBJECT })
    // objectInfo;

    @wire(getObjectInfo, { objectApiName: QUOTE_OBJECT })
    objectInfo({ error, data }) {

        if (data) {
            const objectInfoRecs = data;
            this.enterpriseQuoteRecordTypeId = Object.keys(objectInfoRecs.recordTypeInfos).find(
                (recordTypeId) => objectInfoRecs.recordTypeInfos[recordTypeId].name === "Enterprise Quote"
            );
            console.log('objectInfo.enterpriseQuoteRecordTypeIdPN' + JSON.stringify(this.enterpriseQuoteRecordTypeId));
        } else if (error) {
            console.error('sm testing test picklist valuess Error in Rejection Reason picklist field', JSON.stringify(error));
        }
        //this.populatePicklist();
    };

    // @wire(getPicklistValues, {
    //     recordTypeId: '$enterpriseQuoteRecordTypeId',
    //     fieldApiName: REJECTIONREASON_FIELD
    // })
    // wiredTestData({ error, data }) {
    //     //console.log('sm testing test picklist valuessTestthis.enterpriseQuoteRecordTypeId' + JSON.stringify(this.enterpriseQuoteRecordTypeId));
    //     console.log('wiredTestData.valuessTestthis.data' + JSON.stringify(data));
    //     if (data && data.values) {
    //         this.testpickListOptions = data.values;
    //         console.log('sm testing test picklist valuess' + JSON.stringify(this.testpickListOptions));
    //     } else if (error) {
    //         console.error('sm testing test picklist valuess Error in Rejection Reason picklist field', JSON.stringify(error));
    //     }
    //     //this.populatePicklist();
    // }



    @wire(getPicklistValues, { recordTypeId: '$enterpriseQuoteRecordTypeId', fieldApiName: REJECTIONREASON_FIELD })
    // @wire(getPicklistValues, { recordTypeId: "$objectInfo.data.defaultRecordTypeId", fieldApiName: REJECTIONREASON_FIELD })
    wiredReasonsData({ error, data }) {
        console.log('artl_LinkLineItemsDatatable: 1: wiredReasonsData' + JSON.stringify(data));
        if (data && data.values) {
            this.pickListOptions = data.values;
            console.log('artl_LinkLineItemsDatatable: 1: this.pickListOptions' + JSON.stringify(this.pickListOptions));
        } else if (error) {
            console.error('Error in Rejection Reason picklist field', JSON.stringify(error));
        }
        this.populatePicklist();
    }

    @wire(getPicklistValues, { recordTypeId: '$enterpriseQuoteRecordTypeId', fieldApiName: OVSTATUS_FIELD })
    wiredStatusData({ error, data }) {
        console.log('artl_LinkLineItemsDatatable: 1: wiredStatusData' + JSON.stringify(data));
        if (data && data.values) {
            this.statusPickListOptions = data.values;
            console.log('artl_LinkLineItemsDatatable: 2: this.statusPickListOptions ' + JSON.stringify(this.statusPickListOptions));
        } else if (error) {
            console.error('Error in OV Status picklist field', JSON.stringify(error));
        }
        this.populatePicklist();
    }

    populatePicklist() {
        console.log('artl_LinkLineItemsDatatable: 3: this.linklineitems ' + JSON.stringify(this.linklineitems));
        if (this.linklineitems) {
            this.data = this.linklineitems;
        }
        else {
            this.data = this.staticlinklineitems;
        }
        console.log('artl_LinkLineItemsDatatable: 4: this.data ' + JSON.stringify(this.data));

        let finalData = JSON.parse(JSON.stringify(this.data));
        if (finalData && this.pickListOptions && this.statusPickListOptions) {
            finalData.forEach(ele => {
                ele.pickListOptions = this.pickListOptions;
                ele.statusPickListOptions = this.statusPickListOptions;
            })
        }
        this.lastSavedData = JSON.parse(JSON.stringify(finalData));
        console.log('artl_LinkLineItemsDatatable: 5: this.lastSavedData ' + JSON.stringify(this.lastSavedData));

    }

    updateDataValues(updateItem) {
        let copyData = JSON.parse(JSON.stringify(this.data));

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
        console.log('updateDraftValues=>' + JSON.stringify(updateItem))
        //store changed value to do operations
        //on save. This will enable inline editing &
        //show standard cancel & save button
        copyDraftValues.forEach(item => {
            console.log('itemid=>' + item.Id)
            console.log('updateItem.Id=>' + updateItem.Id)
            if (item.Id === updateItem.Id) {
                console.log('in if')
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

        console.log('artl_LinkLineItemsDatatable: 19 :this.draftValues ' + JSON.stringify(this.draftValues));

        console.log('artl_LinkLineItemsDatatable: 20 :this.linklineitems.length ' + this.linklineitems.length);
        console.log('artl_LinkLineItemsDatatable: 21 :this.draftValues.length ' + this.draftValues.length);
        if (this.linklineitems.length === this.draftValues.length) {
            let myData = {
                "UpdatedQLI": this.draftValues
            }
            console.log('artl_LinkLineItemsDatatable: 22 : omniApplyCallResp ');
            this.omniApplyCallResp(myData);
        }



    }

    //listener handler to get the context and data
    //updates datatable
    multpicklistChanged(event) {
        event.stopPropagation();
        let dataRecieved = event.detail.data;
        console.log('artl_LinkLineItemsDatatable: 14: event.detail.data ' + event.detail.data);

        let updatedItem = { Id: dataRecieved.context, RejectionReason: dataRecieved.value };
        console.log('artl_LinkLineItemsDatatable: 15: updatedItem ' + JSON.stringify(updatedItem));
        this.updateDraftValues(updatedItem);
        this.updateDataValues(updatedItem);
    }

    //handler to handle cell changes & update values in draft values
    handleCellChange(event) {
        console.log('artl_LinkLineItemsDatatable: 16 :event.detail.draftValues[0] ' + JSON.stringify(event.detail.draftValues[0]));

        /*
        this.finalLinkLineList.push(event.detail.draftValues[0]);
        console.log('artl_LinkLineItemsDatatable: 17 :this.finalLinkLineList ' + JSON.stringify(this.finalLinkLineList));
        console.log('artl_LinkLineItemsDatatable: 17.1 :this.linklineitems.length ' + JSON.stringify(this.linklineitems.length));
        console.log('artl_LinkLineItemsDatatable: 17.2 :this.finalLinkLineList.length ' + JSON.stringify(this.finalLinkLineList.length));
                
        if (this.linklineitems) {
            this.linklineitems.forEach(li => {
                if(this.linklineitems.OVStatus )
            })
            let myData = {
                "QLIUpdated": this.finalLinkLineList
            }
            this.omniApplyCallResp(myData);
        }
        */

        let draftValues = event.detail.draftValues;
        console.log('artl_LinkLineItemsDatatable: 18 :draftValues ' + JSON.stringify(draftValues));
        draftValues.forEach(ele => {
            this.updateDraftValues(ele);
        })
    }

    handleSave(event) {
        this.showSpinner = true;
        this.saveDraftValues = this.draftValues;

        const recordInputs = this.saveDraftValues.slice().map(draft => {
            const fields = Object.assign({}, draft);
            return { fields };
        });

        // Updateing the records using the UiRecordAPi
        const promises = recordInputs.map(recordInput => updateRecord(recordInput));
        Promise.all(promises).then(res => {
            this.showToast('Success', 'Records Updated Successfully!', 'success', 'dismissable');
            this.draftValues = [];
            return this.refresh();
        }).catch(error => {
            console.log(error);
            this.showToast('Error', 'An Error Occured!!', 'error', 'dismissable');
        }).finally(() => {
            this.draftValues = [];
            this.showSpinner = false;
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


    handleChange(event) {
        console.log('18 ' + event.detail);
    }
}