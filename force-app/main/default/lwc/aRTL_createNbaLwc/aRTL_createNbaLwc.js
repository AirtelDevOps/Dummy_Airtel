import { LightningElement, api } from 'lwc';

export default class ARTL_createNbaLwc extends LightningElement {
    @api recordId;
    get prefill() {
        return JSON.stringify({ "ContextId": this.recordId});
    }
}