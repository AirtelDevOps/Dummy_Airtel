import { LightningElement,api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class GstTaggingModal extends LightningElement {
    @api recordId;
    closeModal(){
        this.dispatchEvent(new CustomEvent("closemodalpopup"));

    }
}