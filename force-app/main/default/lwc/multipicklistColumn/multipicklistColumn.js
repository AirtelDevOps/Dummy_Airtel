import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
//import LWCDatatableMultiPicklist from '@salesforce/resourceUrl/LWCDatatableMultiPicklist';

export default class MultipicklistColumn extends LightningElement {
    @api label;
    @api placeholder;
    @api options;
    @api value;
    @api context;
    showPicklist = false;
    isRendered = false;
    yaxis;

    renderedCallback() {
        console.log("MultipicklistColumn-options", this.options);
        // if (!this.isRendered) {
        //     Promise.all([
        //         loadStyle(this, LWCDatatableMultiPicklist),
        //     ]).then(() => { });
        // }

        //this.isRendered = true;
    }

    handleSelectOptionList(event) {
        //show the selected value on UI
        let picklistValues = '';

        if (event.detail) {
            picklistValues = event.detail.join(';');
        }

        console.log(picklistValues);
        this.value = picklistValues;

        //fire event to send context and selected value to the data table
        this.dispatchEvent(new CustomEvent('picklistchanged', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                data: { context: this.context, value: this.value }
            }
        }));
    }

    handleClick(event) {
        this.yaxis = event.clientY;
        this.showPicklist = true;
    }

    closePicklist() {
        this.showPicklist = false;
    }
}