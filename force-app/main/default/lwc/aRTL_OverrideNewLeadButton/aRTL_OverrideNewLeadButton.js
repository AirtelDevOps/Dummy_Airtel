import { LightningElement,api } from 'lwc';

export default class ARTL_OverrideNewLeadButton extends LightningElement {
    @api recordId;

    get prefill(){
        return JSON.stringify({ "ContextId": this.recordId});
        //return JSON.stringify({ "ContextId": "0010T00000bJSRVQA4"});
    }
}