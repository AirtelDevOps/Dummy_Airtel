import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import makeDocDownloadloadCallout from '@salesforce/apex/ARTL_DocumentDownloadController.makeDocDownloadloadCallout';
import getDocuments from '@salesforce/apex/ARTL_DocumentDownloadController.getDocuments';
import getDocumentsWire from '@salesforce/apex/ARTL_DocumentDownloadController.getDocumentsWire';
import { NavigationMixin } from 'lightning/navigation';
import { registerListener } from 'c/pubsub';
import { CurrentPageReference } from 'lightning/navigation';

export default class Artl_DocumentDownload extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName
    @track docList = [];
    @track hasDoc = false;
    @track docId = '';
    @track error = '';
    @track isLoading = false;
    @track isDisabled = false;

    @wire(CurrentPageReference) pageRef;

    @wire(getDocumentsWire, { recId: "$recordId", objAPIName: "$objectApiName" })
    wiredDocs({ data, error }) {
        if (data) {
            this.docList = data;
            if (this.docList.length > 0)
                this.hasDoc = true;
        } else {
            this.error = error;
            console.log('Error:: ' + this.error);
        }
    }

    connectedCallback(){
        registerListener('DocUploadSuccess', this.handleEvent, this);
    }


    handleEvent(bind) {
        console.log('Event');
        this.startSpinner();
        getDocuments({ recId: this.recordId, objAPIName: this.objectApiName })
            .then((result) => {
                console.log('Result:' +JSON.stringify(result));
                this.docList = [];
                this.docList = result;
                if (this.docList.length > 0)
                    this.hasDoc = true;
                this.stopSpinner();
            })
            .catch((error) => {
                this.error = error;
                console.log('Error:: ' + this.error);
                this.stopSpinner();
            });
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