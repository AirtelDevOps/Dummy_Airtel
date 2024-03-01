import { LightningElement,api,wire } from 'lwc';
import { CloseActionScreenEvent } from "lightning/actions";
import { CurrentPageReference } from 'lightning/navigation';
import getBulkCartUpdateFile from '@salesforce/apex/ARTL_BulkUploadCartStageLoad.getBulkCartUpdateFile';
import invokeGetQLIAPI from '@salesforce/apex/ARTL_BulkUploadCartStageLoad.invokeGetQLIAPI';
import { NavigationMixin } from 'lightning/navigation';
export default class ARTL_QuoteDownloadButton extends NavigationMixin(LightningElement) {

    @api recordId;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
             console.log(this.recordId + ' from currentPageReference');
        }
        
    }


    async connectedCallback(){
        console.log('recordId----',this.recordId);
        console.log('handleBulkQLIDownload recordId ',this.recordId);
        console.log('bulk downoad click');
        console.log('bulk downoad click   this.recordId',this.recordId);
        invokeGetQLIAPI({ quoteId: this.recordId }).then((data) => {
            console.log('data:::', data);
            getBulkCartUpdateFile({ body: data }).then((result) => {
                    const base64Data = result;
                console.log('inside download', base64Data, ' typeof ', typeof base64Data);
                console.log('bulk downoad click before downloadFile');
                this.downloadFile(base64Data);

            })
                .catch((error) => {
                    console.log(error);
                });
        })
        .catch((error) => {
            console.log(error);
        });
        this.dispatchEvent(new CloseActionScreenEvent());
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
               recordId: this.recordId,
               objectApiName: "Quote",
               actionName: "view"
            }
         });
    }

    close() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    downloadFile(base64Data) {
    console.log('inside download');
    var currentdate = new Date();
    var datetime = currentdate.getDate() + "/"
                    + (currentdate.getMonth()+1)  + "/"
                    + currentdate.getFullYear() + " @ "
                    + currentdate.getHours() + ":"
                    + currentdate.getMinutes() + ":"
                    + currentdate.getSeconds();
    // Create a unique file name using the timestamp
    const fileName = `EILL_OrderLineEntry_${datetime}.xlsm`;
    console.log('dynamic name fileName 207--- > ',datetime);

    let a = document.createElement('a');
    a.href = 'data:application/vnd.ms-excel;base64,' + base64Data;
    a.download = fileName;       //'EILL_OrderEntry.xlsm';
    console.log('bulk downoad click before click');
    a.click();
    }

}