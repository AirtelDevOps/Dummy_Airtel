import { LightningElement ,api,track,wire} from 'lwc';
import mainmethod from '@salesforce/apex/ARTL_BulkUploadCartStageLoad.ARTL_ExceltoJsonCallout';
import loadCartRecords from '@salesforce/apex/ARTL_BulkUploadCartStageLoad.loadCartRecords';
import LightningAlert from 'lightning/alert';
import { CloseActionScreenEvent } from "lightning/actions";

export default class ARTL_QuoteUploadComp extends LightningElement {
    @api content;
    @track file;
    @track uploadedJson;
    @api isModalOpen= false;
    @track UploadedDocs='';
    fileData 
    @track disableButton = true;
    /*get disableButton(){
        return !(this.fileData);
    }*/
    connectedCallback(){
        this.UploadedDocs='';
        this.fileData ='';
        this.isModalOpen = true;
    }
    openfileUpload(event) {
        try{
        this.file = event.target.files[0];
        console.log('this.file ',this.file);
        this.convertFileToBlob();    
        }catch (e) {
            console.error(' openfileUploade.message => ' + e.message );
        }   
    }
    convertFileToBlob() {
        try{
        if (this.file) {
            const reader = new FileReader();
            reader.onload = () => {
                this.fileData = reader.result.split(',')[1]; // Get the base64-encoded string
                const byteCharacters = window.atob(this.fileData);
                const byteNumbers = new Array(byteCharacters.length);
                for (let i = 0; i < byteCharacters.length; i++) {
                    byteNumbers[i] = byteCharacters.charCodeAt(i);
                }
               const byteArray = new Uint8Array(byteNumbers);
                 const blob = new Blob([byteArray], {type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'});
                const bbbb = blob.text();
                this.handlecallout(this.fileData);               
            };
            reader.readAsDataURL(this.file);
        }

        }catch (e) {
            console.error('convertFileToBlob e.message => ' + e.message );
        }  
    }
    handlecallout(fileData){
        try{
         mainmethod({hbody:fileData}).then((result) => {
                     const rrrr = result;
                     this.uploadedJson = result;
                     loadCartRecords({jsonRequest:result}).then((result) => {
                        
                        console.log('upload clisk  '+result);
                        console.log('bulk downoad click before downloadFile');       
                    })
                    .catch((error) => {
                        console.log(error);
                    });
                        console.log('rrrr ',rrrr);
                        if(rrrr){
                            this.disableButton = false;
                        }
                    }).catch(error => {
                        LightningAlert.open({
                            message: error.body.message,
                            theme: 'error', // a red theme intended for error states
                            label: 'Error!', // this is the header text
                        });
                        console.log( 'error  ---> ',error);
                        console.log( 'error status ---> ',error.status);
                        console.log( 'error mesage ---> ',error.body.message);
                    });
        }catch (e) {
            console.error(e); //This will not be executed
            console.error(JSON.stringify(e));
        }        
    }

 
    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
        this.UploadedDocs ='';
         this.fileData ='';
    }
    
     closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
        this.UploadedDocs ='';
         this.fileData ='';
         const selectEvent = new CustomEvent('closemodal', {
            value: true
        });
        // Fire the custom event
        this.dispatchEvent(selectEvent);
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    submitDetails() {
        console.log('this.uploadedJson  &&&  ',this.uploadedJson);
        /*loadCartRecords({jsonRequest:this.uploadedJson}).then((result) => {
            console.log('upload clisk  '+result);
            console.log('bulk downoad click before downloadFile');       
        })
        .catch((error) => {
            console.log(error);
        });*/
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
        const selectEvent = new CustomEvent('closemodal', {
            message: true
        });
        console.log('bulk downoad click before data'); 
        // Fire the custom event
        this.dispatchEvent(selectEvent);
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}