import { LightningElement, track,api } from "lwc";
import b2bDataTableWrapper from "vlocity_cmt/b2bDataTableWrapper";
import cb2bDataTableWrapperTem from "./cb2bDataTableWrapper.html";
import { getDataHandler } from "vlocity_cmt/utility";

export default class cb2bDataTableWrapper extends b2bDataTableWrapper{
    @api recordId;
    originalTableColumns = [];
    showLocation=false;
    showLOcationButton = false;
    isShiftingQuote=false;
    quoteType='';
    connectedCallback(){
      this.recordId = this.getUrlParams('c__cartId');
      super.connectedCallback();
      this.fetchQuoteDetails(this.recordId);
    }
    render(){
        if(this.tableColumns){
          //this.tableColumns[0].editable = false;
          //console.log('@@@@ tableColumns5= ', JSON.stringify(this.tableColumns));
        
        //console.log('@@@@ tableData5= ', JSON.stringify(this.tableData));
        //console.log('@@@@ memberType= ', JSON.stringify(this.memberType));
        //console.log('@@@@ route', JSON.stringify(this.route));
    
        
        }
        
        
        return cb2bDataTableWrapperTem;
    }

    fetchQuoteDetails(quoteId) {
      const datasourcedef = JSON.stringify({
          type: "dataraptor",
          value: {
              bundleName: "DRGetQuoteDetailsForLWC",
              inputMap: {
                  "cartId": quoteId
              }
          },
          optionsMap: null
      });
      console.log('datasourcedef'+datasourcedef);
      getDataHandler(datasourcedef)
          .then(data => {
              let quoteType = JSON.parse(data)[0].Quote[0].vlocity_cmt__Type__c ? JSON.parse(data)[0].Quote[0].vlocity_cmt__Type__c : "undefined";
              this.quoteType=quoteType;
              if(quoteType=='Shifting'){
                this.isShiftingQuote=true;
              }else{
                this.isShiftingQuote=false;
              }
              if(quoteType != "Upgrade" && quoteType != "Downgrade" && quoteType != "Rate Revision" && quoteType != "Rebilling" && quoteType != "PO Renewal"){
                this.showLOcationButton = true;
              }else{
                this.showLOcationButton = false;
              }
          }).catch(error => {
              console.log('fetchQuoteDetails', error);
          });
  }
  getUrlParams(param) {
    const queryString = window.location.search;
    const urlParams = new URLSearchParams(queryString);
    return urlParams.get(param);
  }

    handleLinkAddressClick(){
      this.showLocation=true;
    }

    closeModal(){
      this.showLocation=false;
   }
   refreshMem(){
    this.showLocation=false;
    super.handleFileUpload();
    this.refreshESMCart();

 }

 refreshESMCart() {
  this.rfEvent = setTimeout(() => {
      window.location.reload();
    },500); 
}

 
  /*processMemberRecords(members) {
    super.processMemberRecords(members);
    this.originalTableColumns = this.tableColumns;
    console.log('@@@@ tableColumns5= ', JSON.stringify(this.tableColumns));
    
  }*/

}