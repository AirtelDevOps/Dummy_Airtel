import { LightningElement, api, track } from 'lwc';
import { getDataHandler } from "vlocity_cmt/utility";
import { OmniscriptBaseMixin } from "vlocity_cmt/omniscriptBaseMixin";
import { invokeDR } from "vlocity_cmt/b2bUtils";

export default class artl_DisplayLSIForPORenewalLWC extends OmniscriptBaseMixin(LightningElement) {

    @api recordid;
    @api selectoptions;
    @api columns;
    @api recordname;
    @api recordnumber;
    searchData;
    searchKey = '';
    selectValue = '';
    showError = false;
    showDatabaseError = false;
    selectedIds = [];
    selectedData = {};
    selectedRows = [];

    handleSelectChange(event) {
        this.selectValue = event.currentTarget.value;
        console.log('this.selectValue ' + JSON.stringify(this.selectValue));
    }
    handleKey(event) {
        this.searchKey = event.currentTarget.value;
        console.log('this.searchKey ' + JSON.stringify(this.searchKey));
    }

    handleSearch() {
        if (!this.searchKey) {
            this.searchData = undefined;
            this.showError = true;
            return;
        }

        let recordObj = { SearchBy: this.selectValue, SearchKey: this.searchKey, ContextId: this.recordid };
        console.log('recordObj ' + JSON.stringify(recordObj));
        let requestData = {
            "type": "integrationprocedure",
            "value": {
                "ipMethod": "ARTL_SearchLSIForPORenewal",
                "inputMap": recordObj,
                "optionsMap": ''
            }
        }
        //console.log('requestData ' + requestData);
        getDataHandler(JSON.stringify(requestData)).then(response => {
            this.ipResult = JSON.parse(response);
            console.log('this.ipResult.IPResult.searchQLIList ' + JSON.stringify(this.ipResult.IPResult.searchQLIList));

            if (this.ipResult.IPResult.searchQLIList) {
                this.searchData = this.ipResult.IPResult.searchQLIList;
                this.showError = false;
            } else {
                this.searchData = undefined;
                this.showError = true;
            }
        });
    }

    handleRowSelection(evt) {
        this.selectedRows = this.template.querySelector('[data-id="qlitable"]').getSelectedRows();
        console.log('this.selectedRows' + JSON.stringify(this.selectedRows));
        this.rows = [];
        this.selectedIds = [];
        this.parentRows =[];

        let recordDRObj = { LinkSelectedRows: this.selectedRows };
        console.log('recordDRObj ' + JSON.stringify(recordDRObj));
        let datasourcedef = JSON.stringify({
            "type": "dataraptor",
            "value": {
                "bundleName": "ARTL_GetParentAssetsForPORenewal",
                "inputMap": recordDRObj
            }
        });

        getDataHandler(datasourcedef).then(data => {
            this.result = JSON.parse(data);
            console.log('this.result ' + JSON.stringify(this.result));
            console.log('this.result.length ' + this.result.length);
            if (this.result.length != 0) this.showDatabaseError = false;
            else if (this.result.length == 0) this.showDatabaseError = true;
            console.log('this.showDatabaseError ' + this.showDatabaseError);
            this.result.forEach(elem => {
                console.log('elem ' + elem);
                this.parentRows.push(elem.Id);
            });
            console.log('this.parentRows:' + JSON.stringify(this.parentRows));
            let myData = {
                "SelectedRows": this.selectedRows,
                "AssetIds": this.parentRows
            }
            this.omniApplyCallResp(myData);

        }).catch(error => {
            console.log('Failed at getting DR data =>', JSON.stringify(error));
        });


        /*
        console.log('selectedRows:' + this.selectedRows.length);
        if (this.selectedRows.length != 0) this.showDatabaseError = false;
        else if (this.selectedRows.length == 0) this.showDatabaseError = true;
        this.selectedRows.forEach(element => {
            this.rows.push(element.Id);
        });
*/
        //console.log('this.rows:' + JSON.stringify(this.rows));


    }
    handleNext() {
        if (this.selectedRows.length != 0) {
            this.showDatabaseError = false;
            this.omniNextStep();
        } else {
            this.showDatabaseError = true;
        }
    }
}