import { LightningElement,api } from 'lwc';

export default class BaSaCreation extends LightningElement {
    @api recordId;
    closeModal(){
        this.dispatchEvent(new CustomEvent("closemodalpopup"));
    }
}