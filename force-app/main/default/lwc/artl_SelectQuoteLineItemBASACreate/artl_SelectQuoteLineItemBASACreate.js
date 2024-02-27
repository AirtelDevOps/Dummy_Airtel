import { LightningElement, api, track } from 'lwc';
import { OmniscriptBaseMixin } from "vlocity_cmt/omniscriptBaseMixin";

export default class Artl_SelectQuoteLineItemBASACreate extends OmniscriptBaseMixin(LightningElement) {
    data = [];
    hasAddressError = false;
    _state = '';
    columns = [
        { label: 'Line Number', fieldName: 'LineNumber' },
        { label: 'Address', fieldName: 'Address' },
        { label: 'Product', fieldName: 'Product' },
        { label: 'LSI', fieldName: 'LSI' }
    ];
    @track resp = {
        restrictNext: true,
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
                    // this.resp.showAddressError = true;
                    // //this.selectedIds.push(element.Id);
                    // this.resp.rows.push({Id:element.Id});
                    // this.omniApplyCallResp(this.resp);
                    // //break;
                    // return;
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
                Product: element.Product
            };
            this.resp.rows.push(obj);


            this.omniApplyCallResp(this.resp);
            i++;

        });
        console.log('this.resp.pn' + JSON.stringify(this.resp));
        this.omniApplyCallResp(this.resp);
        // if(evt.detail.config.action == 'rowSelect' || evt.detail.config.action == 'selectAllRows'){
        //     let selectedRows = this.template.querySelector('[data-id="qlitable"]').getSelectedRows();
        //     console.log('selectedRows'+JSON.stringify(selectedRows));
        //     let i=0;
        //     let address = '';
        //     selectedRows.forEach(element => {
        //         //let row = {};
        //         if(i==0){
        //             address = element['Address'];
        //             this.selectedIds.push(element.Id);
        //             this.resp.rows.push({Id:element.Id});
        //         }
        //         else{
        //             if(address == element['Address']){
        //                 this.selectedIds.push(element.Id);
        //                 this.resp.rows.push({Id:element.Id});

        //             }
        //             else{
        //                 this.resp.showAddressError = true;
        //                 this.omniApplyCallResp(this.resp);
        //                 return;
        //             }
        //         }
        //         i++;
        //     });

        // }
        // else if(evt.detail.config.action == 'deselectAllRows' || evt.detail.config.action == 'rowDeselect'){
        //     if(evt.detail.config.action == 'rowDeselect'){
        //         console.log(evt.detail.config.value);
        //         const index = this.selectedIds.indexOf(evt.detail.config.value);
        //         this.selectedIds.splice(index,1);
        //         this.resp.rows.splice(index,1);

        //     }else{
        //         this.selectedData = [];
        //         this.selectedIds=[];
        //         let rows = {
        //             data : this.selectedData
        //         }

        //     }

        // }
        // this.omniApplyCallResp(this.resp);

    }
    handleSave() {
        let rows = {
            data: this.selectedData

        }
        this.omniApplyCallResp(rows);

    }
}