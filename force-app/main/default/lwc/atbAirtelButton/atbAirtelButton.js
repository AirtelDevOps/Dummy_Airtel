import { LightningElement, wire, api } from 'lwc';
import generateJwt from '@salesforce/apex/ARTL_ATBValidationClass.generateJwt';
import { getRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class AtbAirtelButton extends LightningElement {
 @api recordId;
 @api target = '_blank';
    accountId;
    jwtToken;
    urls;
    accountNumber;

    @wire(getRecord, { recordId: '$recordId', fields: ['Account.Id', 'Account.AccountNumber'] })
    accountRecord({ data, error }) {
        if (data) {
            this.accountId = data.fields.Id.value;
            this.accountNumber = data.fields.AccountNumber.value; 
            console.log('Account number --> '+ this.accountNumber);
            if (this.accountNumber) {
                generateJwt({ accountNumber: this.accountNumber  })
                    .then(result => {
                       
                         this.jwtToken = result;
                         this.urls  = 'https://test.airtel.in/atb-preprod/business/thanksforbusiness/login?token='+this.jwtToken;
                         // this.urls  = 'https://test.airtel.in/atb-preprod/business/thanksforbusiness/login?token='+this.jwtToken+'&accountnumber='+this.accountNumber;
                         console.log('this.urls:  ', this.urls);
                        console.log('this.jwtToken:', this.jwtToken);
                        console.log('ID:', result);
                        this.openTab();
                        this.dispatchEvent(new CloseActionScreenEvent());

                    })
                    .catch(error => {
                        console.error('Error creating ID :', error);
                    });
            } else {
                console.error('Id is not available.');
            }
        } else if (error) {
            console.error('Error fetching account record:', error);
        }
    }

    openTab() {
        //alert(this.urls);
    window.open(this.urls, this.target);
    console.log('urls --> ',this.urls);
  }

}