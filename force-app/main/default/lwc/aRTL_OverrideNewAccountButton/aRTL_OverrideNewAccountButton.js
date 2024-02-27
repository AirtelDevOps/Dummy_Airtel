import { LightningElement,api } from 'lwc';

export default class ARTL_OverrideNewAccountButton extends LightningElement {
    @api recordId;

    get prefill(){
        return JSON.stringify({ "ContextId": this.recordId});
    }
}