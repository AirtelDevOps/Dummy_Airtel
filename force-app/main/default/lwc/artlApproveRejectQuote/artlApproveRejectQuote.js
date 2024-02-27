import { LightningElement, api } from 'lwc';
import { getDataHandler } from "vlocity_cmt/utility";
import { NavigationMixin } from "lightning/navigation";

export default class ArtlApproveRejectQuote extends NavigationMixin(LightningElement) {
    rejecteReasonValue = [];
    isApproved = false;
    isRejected = false;
    selectedStatus;
    selectedReason = [];
    isSelectedReason = false;
    OVRemarks;
    @api quoteId; 
    @api QuoteRejectStatus;
    @api QuoteApproveStatus;

    get rejectedReasonOptions() {
        return [
            { label: 'Document related', value: 'Document related' },
            { label: 'Document related - Customer is Minor', value: 'Document related - Customer is Minor' },
            { label: 'POA Related - POA copy not clear', value: 'POA Related - POA copy not clear' },
            { label: 'POA Related - POA not allowed', value: 'POA Related - POA not allowed' },
            { label: 'POI Related - POI Copy not Clear', value: 'POI Related - POI Copy not Clear' },
            { label: 'POI Related - POI Copy not Complete', value: 'POI Related - POI Copy not Complete' },
            { label: 'POI Related - POI not allowed', value: 'POI Related - POI not allowed' },
            { label: 'MNP - Competition Bill copy customer name vs punching Customer name different ARC/OTC charges mismatch between attached PO V/s punched in system', value: 'MNP - Competition Bill copy customer name vs punching Customer name different ARC/OTC charges mismatch between attached PO V/s punched in system' },
        ];
    }

    connectedCallback() { 
        setTimeout(() => {
            // testing values.
            // this.QuoteRejectStatus = 1;
            // this.QuoteApproveStatus = 0;
            console.log("quoteId", this.quoteId);
            this.isApproved = this.QuoteApproveStatus === 1 ? true : false;
            this.isRejected = this.QuoteRejectStatus === 1 ? true : false;
            this.selectedStatus = this.QuoteApproveStatus === 1 ? "OV Approved" : "OV Rejected";
            console.log("QuoteRejectStatus", this.QuoteRejectStatus);
            console.log("QuoteApproveStatus", this.QuoteApproveStatus);  
        }, 1000);
       
    }
    
    handleInputChange(event) {
        console.log(" event.detail.value;",  event.detail.value);
        this.OVRemarks = event.detail.value;
    }
    
    handleReasonSelection(event) {
        this.selectedReason = event.detail.value;
        this.isSelectedReason = this.selectedReason.length ? true : false;

    }
    handleSubmit() {
        console.log("this.selectedReason: ", this.selectedStatus);
        console.log('this.selectedReason', this.selectedReason);

        let inputData = {
            "QuoteStatus": this.selectedStatus,
            "QuoteId": this.quoteId,
            "launchFlag": false,
            "OVRemarks": this.OVRemarks
        };
        if(this.selectedStatus == "OV Rejected") {
            inputData = {
                "QuoteStatus": this.selectedStatus,
                "QuoteId": this.quoteId,
                "launchFlag": false,
                "QuoteRejectionReason": this.selectedReason.join(';'),
                "OVRemarks": this.OVRemarks
            };
        }
    
        let requestData = {
          "type": "integrationprocedure",
          "value": {
              "ipMethod": "ARTL_UpdateOVDetails",
              "inputMap": inputData,
              "optionsMap": ''
          }
      }
      getDataHandler(JSON.stringify(requestData)).then(response => {
          this.ipResult = JSON.parse(response);
          if (this.ipResult && this.ipResult.IPResult) {
              let result = this.ipResult.IPResult;
              if (result) {
                console.log("result", result);
                    this[NavigationMixin.GenerateUrl]({
                        type: 'standard__webPage',
                        attributes: {
                            url: '/lightning/r/Quote/' + this.quoteId + '/view'
                        }
                    }).then(generatedUrl => {
                        window.open(generatedUrl, "_self");
                    }), false;
                  };
                } 
              this.loading = false;
          });
    }
}