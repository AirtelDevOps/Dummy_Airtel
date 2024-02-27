import { LightningElement,api, track } from 'lwc';
import { OmniscriptBaseMixin } from "vlocity_cmt/omniscriptBaseMixin";
export default class Artl_SelectQLIForMACDEnrich extends OmniscriptBaseMixin(LightningElement) {
    data = [];
    hasAddressError = false;
    _state='';
    //{ label: 'Line Number', fieldName: 'LineNumber' },
    columns =[
        { label: 'LSI', fieldName: 'LSI' },
        { label: 'Product', fieldName: 'Product' },
        { label: 'Site', fieldName: 'Address'},
        { label: 'BCP Id', fieldName: 'BCPId'},
        { label: 'DCP Id', fieldName: 'DCPId'},
        { label: 'BA Id', fieldName: 'BAId'},
        { label: 'Legal Entity', fieldName: 'LegalEntity'},
        { label: 'Bill Type', fieldName: 'BillType'},
        { label: 'Credit Period', fieldName: 'CreditPeriod'},
        { label: 'Store', fieldName: 'Store'},
        { label: 'Billing Level', fieldName: 'BillingLevel'},
        { label: 'Applicable GST', fieldName: 'ApplicableGST'}
    ];
    @track resp = {
        restrictNext :  true,
        state:'',
        showAddressError : false,
        rows:[
        ]
    }
    selectedIds =[];
    @api records;
    selectedData ={};
    connectedCallback() {
        this.omniApplyCallResp(this.resp);
        this.data = JSON.parse(JSON.stringify(this.records));
        
    }
    handleRowSelection(evt){
        console.log('values=>'+JSON.stringify(evt));
        this.hasAddressError = false;
        let selectedRows = this.template.querySelector('[data-id="qlitable"]').getSelectedRows();
        console.log('selectedRows'+JSON.stringify(selectedRows));
        this.resp.rows=[];
        this.selectedIds =[];
        //let i=0;
        //let state = '';
        console.log('selectedRows:'+selectedRows.length);
        if(selectedRows.length != 0) this.resp.restrictNext = false;
        else if(selectedRows.length == 0)this.resp.restrictNext = true;
        console.log('this.resp.restrictNext:'+this.resp.restrictNext);
        selectedRows.forEach(element => {
            console.log('element:'+JSON.stringify(element));
            console.log('element:',element['State']);
            this.resp.rows.push(element);
        })
        console.log('output element:'+JSON.stringify(this.resp));


        // selectedRows.forEach(element => {
            
        //     console.log('element:',element['State']);
        //     if(i==0){
        //         state = element['State'];
        //         this.resp.state = state;
        //         this.resp.showAddressError = false;
        //     }
        //     else {
        //         if(state != element['State']){
        //             this.hasAddressError = true;
        //             // this.resp.showAddressError = true;
        //             // //this.selectedIds.push(element.Id);
        //             // this.resp.rows.push({Id:element.Id});
        //             // this.omniApplyCallResp(this.resp);
        //             // //break;
        //             // return;
        //         }
        //     }
        //     //this.selectedIds.push(element.Id);
        //     if(this.hasAddressError)
        //         this.resp.showAddressError = true;
        //     else
        //         this.resp.showAddressError = false;

        //     this.resp.state = state;
        //     this.resp.rows.push({Id:element.Id});
            
        //     this.omniApplyCallResp(this.resp);
        //     i++;

        // });
        // console.log('this.resp.pn'+JSON.stringify(this.resp));
        // this.omniApplyCallResp(this.resp);
        this.omniApplyCallResp(this.resp);
          
    }
    handleSave(){
        let rows = {
            data : this.selectedData
           
        }
        this.omniApplyCallResp(rows);
        
    }
}