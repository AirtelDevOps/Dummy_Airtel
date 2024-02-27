import { LightningElement, track, api } from 'lwc';

export default class Artl_CreateDCPContainer extends LightningElement {
    @api recordId;
    @api isModalOpen;
    //@track recordId = '0Q00T000000FtIpSAK';
    //@track isModalOpen = true;
    closeModal() {
        this.isModalOpen = false;
        this.dispatchEvent(new CustomEvent('resetvar'));
    }
}