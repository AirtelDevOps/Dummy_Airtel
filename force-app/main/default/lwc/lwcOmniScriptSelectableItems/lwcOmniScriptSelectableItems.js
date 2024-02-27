import { LightningElement,api,track } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';

const columns = [
    { label: 'Circle', fieldName: 'Circle' },
    { label: 'PM Name', fieldName: 'PMName' },
    { label: 'TL', fieldName: 'TL' },
    { label: 'CPH', fieldName: 'CPHUser' },
    { label: 'CCE', fieldName: 'CCE' },
];

export default class lwcdatatable extends OmniscriptBaseMixin(LightningElement) {
    @track columns = columns;
    _jsonDef;
    _headerJson;
    _omniJsonData;
    _accountDetails; // Needs to match the OS parameter
    
    @api
    set omniJsonDef(json) {
        if(json) {
            this._jsonDef = json;
        }
    }

    get omniJsonDef() {
        return this._jsonDef;
    }

    @api 
    set omniScriptHeaderDef(headerJson) {
        if(headerJson) {
            this._headerJson = headerJson;
        }
    }

    get omniScriptHeaderDef() {
        return this._headerJson;
    }

    @api
    set omniJsonData(omniData) {
        if(omniData) {
            this._omniJsonData = omniData;
        }
    }

    get omniJsonData() {
        return this._omniJsonData;
    }

    // Needs to match the OS parameter
    @api
    set accountDetails(myaccounts) {
        console.log('### this._accountDetails:  ' + myaccounts + ';');
        if(myaccounts) {
            this._accountDetails = myaccounts;
        }
    }
    
    // Needs to match the OS parameter
    get accountDetails() {
        console.log('$$$ this._accountDetails:  ' + this._accountDetails + ';');
        return this._accountDetails;
    }

    getSelectedName(event) {
        const selectedRows = event.detail.selectedRows;
        // this will update the OS's data json with the last selected row. If you want this selectable items to allow user to select more than one row and write all the selected rows in the data json, then update this
        for (let i = 0; i < selectedRows.length; i++){
            this.omniUpdateDataJson(selectedRows[i].Id);
        }
    }
}