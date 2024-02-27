// quoteMemberList.js
import { LightningElement, wire, api } from 'lwc';
import SheetJS from "@salesforce/resourceUrl/sheetJs2";
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';


export default class ArtlDownloadQLIDetails extends LightningElement {
    @api recordId; // Quote Id
    @api currentQuoteLineItemsData;
 
    async connectedCallback() {
      try {
        console.log("currentQuoteLineItemsData: ", this.currentQuoteLineItemsData);
           await loadScript(this, SheetJS); // load the library
           this.version = XLSX.version;
           console.log('version: '+this.version); 
           // console.log("recordId", this.recordId);
           this.quoteMembers = this.currentQuoteLineItemsData;
           console.log("quoteMembers", this.quoteMembers);
         } catch (e) {
           console.log("Failed on connectedCallback() -> ", e.message);
         }
    }

  async exportToExcel() {
    // Create a new SheetJS workbook
    const filename = 'ExportToExcel.xlsx';
    const workbook = XLSX.utils.book_new();
    const worksheetData = [];

    var jsonRecordsData = this.quoteMembers; 
    for (let i = 0; i < jsonRecordsData.length; i++) {  
       worksheetData.push(jsonRecordsData[i]);
    } 
    console.log("worksheetData",worksheetData);
    const worksheet = XLSX.utils.json_to_sheet(worksheetData);
    XLSX.utils.book_append_sheet(workbook, worksheet, 'QuoteMembers');

    const excelBuffer = XLSX.write(workbook, { bookType: 'xlsx', type: 'array' });
    const blob = new Blob([excelBuffer], { type: 'application/octet-stream' });

    // Create a download link and click it programmatically to initiate the download
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = filename;
    a.click();
    // Release the object URL to free up memory
    URL.revokeObjectURL(a.href);
  }
  // exportToCsv() {
  //     let columnHeader = ["Id", "Quantity"];  // This array holds the Column headers to be displayd
  //     let jsonKeys = ["Id", "Quantity"]; // This array holds the keys in the json data  
  //     var jsonRecordsData = this.quoteMembers;  
  //     let excelIterativeData;  
  //     let csvSeperator  
  //     let newLineCharacter;  
  //     csvSeperator = ",";  
  //     newLineCharacter = "\n";  
  //     excelIterativeData = "";  
  //     excelIterativeData += columnHeader.join(csvSeperator);  
  //     excelIterativeData += newLineCharacter;  
  //     for (let i = 0; i < jsonRecordsData.length; i++) {  
  //       let counter = 0;  
  //       for (let iteratorObj in jsonKeys) {  
  //         let dataKey = jsonKeys[iteratorObj];  
  //         if (counter > 0) {  excelIterativeData += csvSeperator;  }  
  //         if (  jsonRecordsData[i][dataKey] !== null &&  
  //           jsonRecordsData[i][dataKey] !== undefined  
  //         ) {  excelIterativeData += '"' + jsonRecordsData[i][dataKey] + '"';  
  //         } else {  excelIterativeData += '""';  
  //         }  
  //         counter++;  
  //       }  
  //       excelIterativeData += newLineCharacter;  
  //     }  
  //     console.log("excelIterativeData", excelIterativeData);  
  //     this.hrefdata = "data:application/vnd.ms-excel," + encodeURI(excelIterativeData);  
  //   }
    
}