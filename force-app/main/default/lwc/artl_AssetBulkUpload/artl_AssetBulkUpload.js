import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import checkLsi from '@salesforce/apex/ARTL_AssetBulkUploadCtrl.checkLsi';

const FILE_FORMATS = ['.csv'];
const MAX_FILE_SIZE = 2000000; //Max file size 2.0 MB

export default class Artl_AssetBulkUpload extends OmniscriptBaseMixin(LightningElement) {
    @track showLoadingSpinner = false;
    @track error;
    
    filesUploaded = [];
    filename;

    @track csvHeaders = [];
    @track csvData;
    iterationId = '';
    lsiNumbers = [];

    //error msg
    errorBlankLsi = 'LSI is blank for more than 1 row. Please re-upload the file with correct data.';
    errorInvalidLsi = 'Below LSIs does not exist. Please re-upload the file with correct data.';

    // Accepted File Formats - .CSV files
    get acceptedFormats() {
        return FILE_FORMATS;
    }

    get disableImportButton(){
        return (this.error);
    }

    connectedCallback() {
        //console.log('connectedCallback 1= ' );
        //console.log('iterationId = ' + this.iterationId);
        //console.log('omniJsonData.ContextId = ' + JSON.stringify(this.omniJsonData.ContextId));
        //console.log('DRId_ARTL_Bulk_Upload_Iteration__c = ' + JSON.stringify(this.omniJsonData.DRId_ARTL_Bulk_Upload_Iteration__c));
        //console.log('iterationId = ' + this.iterationId);
        this.iterationId = JSON.stringify(this.omniJsonData.DRId_ARTL_Bulk_Upload_Iteration__c);
        //console.log('iterationId = ' + this.iterationId);
        this.csvHeaders.push({ label: 'Invalid Lsi', fieldName: 'Lsi', type: 'decimal' });
        //console.log('this.csvHeaders = ' + JSON.stringify(this.csvHeaders));
    }
 
    // Upload Files Button - It loads the file
    importcsv(event){
        this.resetVariables();

        if (event.target.files.length > 0) {
            this.filesUploaded = event.target.files;
            this.filename = event.target.files[0].name;
            if(event.target.files.length > 1){
                this.showToast('Error', 'Please upload only 1 csv file', 'error');
            }
            else if (this.filesUploaded.size > MAX_FILE_SIZE) {
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
                    
                    this.parseCSV(result);

                    if( (!this.error) && this.lsiNumbers.length > 0){
                        this.checkExistingLsi();
                    }
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

     
    //process CSV input to JSON
    parseCSV(csv){

        let lines = csv.split(/\r\n|\n/);
        //let result = [];
        let headerString = lines[0];
        //console.log('headerString ==' + headerString + '=');
        if(headerString.startsWith('"') && headerString.endsWith('"')){
            //console.log('Inside if');
            headerString = headerString.replace(/"/g, '');
            //console.log('headerString =' + headerString) + '=';
        }
        //else //console.log('Inside else');
        
        //console.log('lines[0] =' + lines[0] + '=');
        let headers = headerString.split(",");
        //headers = headerString.split(",");
        //console.log('headers =' + headers + '=');
        //console.log('headers.length =' + headers.length + '=');
        //console.log('lines.length =' + lines.length + '=');
        lines.shift();
        //console.log('lines.length =' + lines.length + '=');

        // Iterate over all rows
        for(var i=0; i<lines.length-1; i++) {
            //var obj = {};
            let currentlineString = lines[i];

            if(currentlineString.startsWith('"') && currentlineString.endsWith('"')){
                //console.log('Inside if');
                currentlineString = currentlineString.replace(/"/g, '');
                //console.log('currentlineString  =' + currentlineString) + '=';
            }
            //else //console.log('Inside else');

            var currentline = currentlineString.split(",");
            //console.log('currentline =' + currentline + '=');
            //console.log('currentline.length =' + currentline.length + '=');

            for(var j=0; j<headers.length-1; j++) {
                if(headers[j] == 'LSI'){
                    //console.log('LSI');
                    let cellData = currentline[j];
                    //console.log('cellData =' + cellData + '=');
                    if(cellData !== undefined || cellData !== null){
                        //console.log('Not undefined');
                        cellData = cellData.trim();
                        //console.log('cellData =' + cellData + '=');
                        if(cellData !== ''){
                            this.lsiNumbers.push(cellData);
                        }
                        else {
                            this.showLoadingSpinner = false;
                            this.error = this.errorBlankLsi;
                            this.showToast('Error', this.error, 'error');
                            return;
                        }
                    }
                    else{
                        //console.log('LSI undefined');
                        this.showLoadingSpinner = false;
                        this.error = this.errorBlankLsi;
                        this.showToast('Error', this.error, 'error');
                        return;
                    }
                }
            }
        }
        //console.log('lsiNumbers.length =' + this.lsiNumbers.length + '=');
        //console.log('lsiNumbers =' + this.lsiNumbers + '=');
    }

    checkExistingLsi(){
        checkLsi({ lsiList: this.lsiNumbers, iterationId: this.iterationId})
                .then(result => {
                    //console.log('Apex call checkLsi Success == ' + result + typeof result);
                    this.showLoadingSpinner = false;
                    let invalidLsiNumbers = result;
                    //console.log('invalidLsiNumbers == ' + invalidLsiNumbers + '=' + typeof invalidLsiNumbers + '=' + invalidLsiNumbers.length);
                    if(invalidLsiNumbers.length > 0){
                        this.csvData = [];
                        this.error = this.errorInvalidLsi;
                        this.showToast('Error', this.error, 'error');
                        for(let i=0; i < invalidLsiNumbers.length; i++){
                            this.csvData.push({Lsi : invalidLsiNumbers[i]});
                        }
                        //console.log('this.csvData =' + JSON.stringify(this.csvData) + '=');
                    }else{
                        this.showToast('Success!!', 'CSV file parsed !!!', 'success');
                    }
                })
                .catch(error => {
                    this.showLoadingSpinner = false;
                    console.log('Error == ' + error.body.message);
                    this.error = error.body.message;
                    this.showToast('Error', error.body.message, 'error');
                });
    }

    resetVariables(){
        this.error = undefined;
        this.lsiNumbers = [];
        this.csvData = undefined;
        this.showLoadingSpinner = false;
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}