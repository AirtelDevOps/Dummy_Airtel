import { LightningElement, wire, api } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getPincodeDetails from '@salesforce/apex/ARTL_UpdateBcpDcpLwcController.getPincodeDetails';

export default class ARTL_SearchableCombobox extends LightningElement {
    pincodeRecords;
    picklistOrdered;
    searchResults;
    selectedPincodeResult;
    showPicklistOptions = false;
    @api
    addressDetails;
    updatedAddress;

    get selectedValue() {
        return this.updatedAddress['PincodeCity'];
    }

    get streetValue() {
        return this.updatedAddress['StreetAddress'];
    }

    get cityValue() {
        return this.updatedAddress['City'];
    }

    get stateValue() {
        return this.updatedAddress['State'];
    }

    get countryValue() {
        return this.updatedAddress['Country'];
    }

    get pincodeValue() {
        return this.updatedAddress['PostalCode'];
    }

    get selectedPincodeId() {
        return this.updatedAddress['ARTL_Pincode__c'];
    }
    
    connectedCallback() {
        console.log('DEBUGG connectedCallback Searchable combobox ', this.addressDetails);
        this.updatedAddress = JSON.parse(JSON.stringify(this.addressDetails));
    }

    search(event) {
        var searchKey = event?.detail?.value;
        getPincodeDetails({ searchKey: searchKey })
            .then((result) => {
                this.pincodeRecords = result;
                this.picklistOrdered = result?.map(((result) => {
                    var label = result.ARTL_Pincode_City__c;
                    var value = result.Id;
                    return { label, value }
                }));
                this.showPicklistOptions = true;
                this.generatePicklistOptions();
            })
            .catch((error) => {
                console.error('error', error);
                this.showNotification('Error', error.message, 'error');
            })
    }

    selectSearchResult(event) {
        try {
            const selectedValue = event.currentTarget.dataset.value;
            console.log('DEBUGG select city id ', selectedValue);
            this.selectedPincodeResult = this.pincodeRecords.find(
                (picklistOption) => {
                    return picklistOption['Id'] === selectedValue;
                }
            );
            console.log('DEBUGG this.selectedPincodeResult ', this.selectedPincodeResult);
            this.showPicklistOptions = false;
            this.updateAddressDetails();
        }
        catch (error) {
            console.error(error);
            this.showNotification('Error', error.message, 'error');
        }

    }

    updateAddressDetails() {
        try {
            this.updatedAddress = {
                "ARTL_Pincode__c": this.selectedPincodeResult['Id'],
                "City": this.selectedPincodeResult['ARTL_City__c'],
                "State": this.selectedPincodeResult['ARTL_State__c'],
                "PostalCode": this.selectedPincodeResult['Name'],
                "Country": this.selectedPincodeResult['ARTL_Country__c'],
                "PincodeCity": this.selectedPincodeResult['ARTL_Pincode_City__c'], 
                "StreetAddress": null
            }
            this.dispatchEvent(new CustomEvent('updatedaddress', { detail: this.updatedAddress }));
        }
        catch (error) {
            console.error(error);
            this.showNotification('Error', error.message, 'error');
        }
    }

    generatePicklistOptions() {
        this.searchResults = this.picklistOrdered;
    }

    handleChange(event) {
        try {
            switch (event.target.name) {
                case 'street':
                    this.updatedAddress['StreetAddress'] = event.detail.value === '' ? null : event.detail.value;
                    break;
            }
            this.dispatchEvent(new CustomEvent('updatedaddress', { detail: this.updatedAddress }));
        }
        catch (error) {
            console.error('error ', error);
            this.showNotification('Error', error.message, 'error');
        }
    }

    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

}