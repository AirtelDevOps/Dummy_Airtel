import { LightningElement, api } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';

export default class ARTL_ComboboxLwc extends OmniscriptBaseMixin(LightningElement) {
    @api mydata;
    @api inboundvalue;
    @api fieldlabel;

    get options() {
        return this.mydata;
    }

    connectedCallback() {
        this.value = this.inboundvalue;
        this.mylabel = this.fieldlabel;
    }

    handleChange(event) {
        try {
            this.value = event.detail.value;
            let selectedItem = [];
            selectedItem.push({selectedDataNode: this.value});
            console.log('this.selectedItem ', selectedItem);
            this.omniUpdateDataJson(selectedItem[0]);
        }
        catch (e) {
            console.error(e);
            console.error('e.name => ' + e.name);
            console.error('e.message => ' + e.message);
            console.error('e.stack => ' + e.stack);
        }
    }
}