import { LightningElement } from 'lwc';
import csvReferenceFiles from "@salesforce/resourceUrl/csvReferenceFiles";
import { NavigationMixin } from "lightning/navigation";



export default class UsefullLinkContainer extends NavigationMixin(LightningElement) {

    LegalEntity  = csvReferenceFiles + '/LegalEntity.csv';
    billFormat  = csvReferenceFiles + '/BillFormat.csv';
    taxation  = csvReferenceFiles + '/Taxation.csv';
    licenseCompany  = csvReferenceFiles + '/LicenseCompany.csv';
    ftc  = csvReferenceFiles + '/FTC.csv';
    downloadLegalEntity(){
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: this.LegalEntity
            }
        }, false );
    }
    
}