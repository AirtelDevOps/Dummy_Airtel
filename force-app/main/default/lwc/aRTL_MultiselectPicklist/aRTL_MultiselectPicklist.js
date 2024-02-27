import { LightningElement, wire, api } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';

export default class ARTL_MultiselectPicklist extends OmniscriptBaseMixin(LightningElement) {
    _selected = [];
    optionsData;   

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: 'Lead.Product_Interest__c' })
    wiredPicklistValues({ error, data }) {
        if (data) {
            this.optionsData = JSON.parse(JSON.stringify(data.values));
        }
        else {
            console.log('error ===>', error);
        }
    }
    get options() {
        return this.optionsData;
    }


    connectedCallback() {
       
    }

    handleChange(e) {
        this._selected = e.detail.value;        

        if (this._selected.length > 0) {
            var selectedValues = this._selected.join(';');            
            this.omniApplyCallResp({ 'ProductInterestLWC': selectedValues });
        }
        else{
            this.omniApplyCallResp({ 'ProductInterestLWC': ""});
        }
    }
}