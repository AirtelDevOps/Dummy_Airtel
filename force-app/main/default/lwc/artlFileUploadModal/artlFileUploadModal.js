import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadData from '@salesforce/apex/ARTL_TasksBulkUploadCtrl.createTaskRecordsOnBulkCartUpdate';


const FILE_FORMATS = ['.csv'];
const MAX_FILE_SIZE = 3000000; //Max file size 3.0 MB

export default class ArtlFileUploadModal extends LightningElement {
    @track showLoadingSpinner = false;
    @track error;    
    
    filesUploaded = [];
    filename;
    @track taskStatusMap = [];
    taskIds =[];
    @track headers = ['TaskId', 'Subject', 'Product Name', 'Related To', 'Status', 'Account: Account Name', 'Assigned To: Full Name', 'Completed Date','Task Type'];
    //error msg
    errorBlankValue = 'Task ID or Task Status is blank for one or more than 1 row. Please re-upload the file with correct data.';

    // Accepted File Formats - .CSV files
    get acceptedFormats() {
        return FILE_FORMATS;
    }

    // Upload Files Button - It loads the file
    importcsv(event){
        
        if (event.target.files.length > 0) {
            this.filesUploaded = event.target.files;
            this.filename = event.target.files[0].name;
            if (this.filesUploaded.size > MAX_FILE_SIZE) {
                this.filename = 'File size exceeded';
                this.showToast('Error', 'File size is too large', 'error');
                
            } 
        }
    }

    // Import Button
    readFiles() {
        this.showLoadingSpinner = true;
        [...this.template
            .querySelector('lightning-input')
            .files].forEach(async file => {
                try {
                    // Read the CSV
                    const result = await this.load(file);
                    
                    this.csvJSON(result);
                   
                } catch(e) {
                    this.showLoadingSpinner = false;
                    // handle file load exception
                    console.log('exception....' +JSON.stringify(e));
                    this.showToast('Error', JSON.stringify(e), 'error');
                    
                }
            });
    }

    // Reads file asynchronously
    async load(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();

            // Read file into memory as UTF-8
            reader.onload = function() {
                resolve(reader.result);
            };
            reader.onerror = function() {
                reject(reader.error);
            };

            reader.readAsText(file);
        });
    }

    csvJSON(csv){
        const lines = csv.split(/\r\n|\n/);
        console.log('lines'+lines);
        lines.forEach((line, i) => {
            if (i === 0) return;
            const currentline = line.split(',');
            const obj = {};
            const objSend = {};
            for (let j = 0; j < this.headers.length; j++) {
                obj[this.headers[j]] = currentline[j];
            }
            let taskId = JSON.parse(obj.TaskId);
            let status = JSON.parse(obj.Status);
            if(taskId != '' && status != '') {
                this.taskIds.push(taskId);
                objSend['TaskId'] = taskId;
                objSend['Status'] = status;
                this.taskStatusMap.push(objSend);
            }
            else {
                this.showLoadingSpinner = false;
                this.error = this.errorBlankValue;
                this.showToast('Error', this.error, 'error');
                this.closeModal();
                return;
            }
            
        });
        this.saveRecords();
    }


    saveRecords(){
        uploadData({ taskIds: this.taskIds,objList:this.taskStatusMap})
                .then(result => {
                    this.showLoadingSpinner = false;
                    this.showToast('Bulk Task update is in Progress');
                    this.closeModal();
                })
                .catch(error => {
                    this.showLoadingSpinner = false;
                    this.error = error.body.message;
                    this.showToast('Error', error.body.message, 'error');
                    this.closeModal();
                });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
    closeModal() {
        const closeEvent = new CustomEvent('closemodal');
        this.dispatchEvent(closeEvent);
    }
}