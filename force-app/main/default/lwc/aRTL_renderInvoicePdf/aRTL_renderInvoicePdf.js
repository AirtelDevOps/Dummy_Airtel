import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class ARTL_renderInvoicePdf extends NavigationMixin(LightningElement) {
    @api reference_number;

    //Navigate to visualforce page
    navigateToVFPage() {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: '/apex/ARTL_FetchPdf?reference=' + this.reference_number
            }
        }).then(vfURL => {
            window.open(vfURL);
        });
    }
}