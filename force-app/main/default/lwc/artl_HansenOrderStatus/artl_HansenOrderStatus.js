import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getHansenOrderStatus from '@salesforce/apex/artl_HansenOrderStatusController.getHansenOrderStatus';
import SOM_ORDERID from '@salesforce/schema/Order.ARTL_SOMOrderId__c';
import SOM_ORDERSTATUS from '@salesforce/schema/Order.ARTL_SOMOrder_Status__c';

export default class Artl_HansenOrderStatus extends LightningElement {
    @api recordId;
    @track statusValues = [];
    statusMap  = [];
    SOM_ORDERSTATUS = 'Pending';
    @wire(getRecord, { recordId: '$recordId', fields: [SOM_ORDERID,SOM_ORDERSTATUS] })
    record;
    
    get somOrderId() {
        return getFieldValue(this.record.data, SOM_ORDERID);
    }

    get somOrderStatus() {
        return getFieldValue(this.record.data, SOM_ORDERSTATUS);
    }

  connectedCallback(){
        getHansenOrderStatus({ orderId: this.recordId })
		.then(result => {
            console.log('sstts--- ',result);
            console.log('sstts--- ',JSON.stringify(result))
            this.statusValues = result;
            this.statusValues = this.statusValues.map(item => item.replace(/"/g, ''));

             this.statusMap = this.statusValues.map((value, index) => ({ index, value }));
			this.error = undefined;
		})
		.catch(error => {
			this.error = error;
		})
    }

    handleSectionToggle(event) {
        console.log('test');
    }
}