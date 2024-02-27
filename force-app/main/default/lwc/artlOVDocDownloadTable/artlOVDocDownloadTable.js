import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import makeDocDownloadloadCallout from '@salesforce/apex/ARTL_DocumentDownloadController.makeDocDownloadloadCallout';
import getDocuments from '@salesforce/apex/ARTL_DocumentDownloadController.getDocuments';
import { NavigationMixin } from 'lightning/navigation';


export default class ArtlOVDocDownloadTable extends NavigationMixin(LightningElement) {
    @track docList = [];
    @track hasDoc = false;
    @track docId = '';
    @track error = '';
    @track isLoading = false;
    @track isDisabled = false;
    @api documentList;

    connectedCallback() {

       console.log("this.documentList", this.documentList);
        this.docList = this.documentList;
        if (this.docList.length > 0)
            this.hasDoc = true;
    }

    startSpinner() {
        this.isLoading = true;
        this.isDisabled = true;
    }
    stopSpinner() {
        this.isLoading = false;
        this.isDisabled = false;
    }

    handleDownload(event) {
        this.startSpinner();
        this.docId = event.target.dataset.id;
        console.log('Doc Id:: ' + this.docId);
        makeDocDownloadloadCallout({ docId: this.docId })
            .then((result) => {
                console.log('Result:: ' + JSON.stringify(result));
                if (result.callout) {
                    let docURL = result.finalDocURL;
                    console.log('URL:: ' + docURL);
                    this[NavigationMixin.Navigate]({
                        "type": "standard__webPage",
                        "attributes": {
                            "url": docURL
                        }
                    });
                } else {
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: result.finalDocURL,
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }
                this.stopSpinner();
            })
            .catch((error) => {
                console.log('Error:: ' + JSON.stringify(error));
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                this.stopSpinner();
            });
    }

}