import { LightningElement, api, track } from 'lwc';
import { OmniscriptBaseMixin } from "vlocity_cmt/omniscriptBaseMixin";

export default class Artl_SelectQuoteLineItemBASACreate extends OmniscriptBaseMixin(LightningElement) {
    data = [];
    hasAddressError = false;
    _state = '';
     prodFamily = new Set();
    columns = [
        { label: 'Line Number', fieldName: 'LineNumber' },
        { label: 'Address', fieldName: 'Address' },
        { label: 'Product', fieldName: 'Product' },
        { label: 'LSI', fieldName: 'LSI' }
    ];
    @track resp = {
        restrictNext: true,
        showFamilyError:false,
        isSDWAN:false,
        state: '',
        showAddressError: false,
        rows: [
        ]
    }
    selectedIds = [];
    @api records;
    selectedData = {};
    connectedCallback() {
        this.omniApplyCallResp(this.resp);
        this.data = JSON.parse(JSON.stringify(this.records));

    }
    handleRowSelection(evt) {
        this.hasAddressError = false;
        let selectedRows = this.template.querySelector('[data-id="qlitable"]').getSelectedRows();
        console.log('selectedRows' + JSON.stringify(selectedRows));
        this.resp.rows = [];
        this.selectedIds = [];
        let i = 0;
        let state = '';
        console.log('selectedRows:' + selectedRows.length);
        if (selectedRows.length != 0) this.resp.restrictNext = false;
        else if (selectedRows.length == 0) this.resp.restrictNext = true;
        console.log('this.resp.restrictNext:' + this.resp.restrictNext);
        selectedRows.forEach(element => {

            console.log('element:', element['State']);
            if (i == 0) {
                state = element['State'];
                this.resp.state = state;
                this.resp.showAddressError = false;
            }
            else {
                if (state != element['State']) {
                    this.hasAddressError = true;
                }
            }
            //this.selectedIds.push(element.Id);
            if (this.hasAddressError)
                this.resp.showAddressError = true;
            else
                this.resp.showAddressError = false;

            this.resp.state = state;
            let obj = {
                Id: element.Id,
                Product: element.Product,
                LSI:element.LSI,
                qmemberId:element.qmemberId,
                family:element.Family,
                contractTerm:element.ContractTerm
            };
           this.prodFamily.add(element.Family);
           if(element.Product=='SD-WAN Controller'){
            this.resp.isSDWAN=true;
           }
            this.resp.rows.push(obj);
            this.omniApplyCallResp(this.resp);
            i++;

        });
        if(this.prodFamily.size>1){
            this.resp.showFamilyError=true;
        }else{
            this.resp.showFamilyError=false;
        }
        console.log('this.resp.pn' + JSON.stringify(this.resp));
        this.omniApplyCallResp(this.resp);
    }
    handleSave() {
        let rows = {
            data: this.selectedData

        }
        this.omniApplyCallResp(rows);

    }
}