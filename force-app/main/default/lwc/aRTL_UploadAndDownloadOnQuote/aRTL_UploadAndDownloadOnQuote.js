import { LightningElement, api, track } from 'lwc';
import getBulkCartUpdateFile from '@salesforce/apex/ARTL_BulkUploadCartStageLoad.getBulkCartUpdateFile';
import invokeGetQLIAPI from '@salesforce/apex/ARTL_BulkUploadCartStageLoad.invokeGetQLIAPI';
export default class ARTL_UploadAndDownloadOnQuote extends LightningElement {

    @track isDocUpload= true;
    @track modalValue= false;
    @api recordId;

    connectedCallback(){
        console.log('connectedCallback recordId ',this.recordId);
    }


    handleBulkQLIUpload(){
        console.log('entered the button');
        this.isDocUpload = false;
        this.modalValue = true;
        console.log('bulk Uplaod click 345');
    }

    closedUploadModal(event){
        this.isDocUpload = true;
    }

    handleBulkQLIDownload() {
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