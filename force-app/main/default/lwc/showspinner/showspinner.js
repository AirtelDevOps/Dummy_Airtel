import { LightningElement, track } from 'lwc';
import { getDataHandler } from "vlocity_cmt/utility";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class Showspinner extends LightningElement {
    @track showLoading = true;
    connectedCallback(){
        setTimeout(() => {
            console.log('Hello world');
            this.showLoading = false;
          }, 8000)
          
    }
}