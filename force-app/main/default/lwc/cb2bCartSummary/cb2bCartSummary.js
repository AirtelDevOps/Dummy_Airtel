import B2bCartSummary from 'vlocity_cmt/b2bCartSummary';
import { LightningElement, api, track } from 'lwc';
import { getDataHandler } from "vlocity_cmt/utility";
import ArcTotal from '@salesforce/label/c.CMEXARCTotal';
import { formatCurrency } from 'vlocity_cmt/utility';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { invokeDR } from "vlocity_cmt/b2bUtils";
import { NavigationMixin } from "lightning/navigation";
import pubsub from 'vlocity_cmt/pubsub';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';  
//import getBulkCartUpdateFile from '@salesforce/apex/ARTL_BulkUploadCartStageLoad.getBulkCartUpdateFile';


export default class cb2bCartSummary extends B2bCartSummary {
    get annualRecurringTotal() {
        return formatCurrency(this.cartData?.ARTL_EffectiveAnnualRecurringTotal__c); 
    }
    label = {
        ArcTotal,
    };
    get effectiveQuoteTotal() {
        return formatCurrency(this.cartData?.ARTL_Effective_Quote_Total__c); 
    }
    isGstTagging = false;
    isBaSaCreation = false;
    isAddressCorrection = false;
    isInvokeSubmitForPriceApproval = false;
    iscreateBCPDCP=false; // Sagar: commented to deploy this file to QA
    prefill;
    @api recordId;
    feasibilityEventName = '/event/ARTL_Feasibility_Event__e';

    connectedCallback() {
        this.recordId = this.getUrlParams('c__cartId');
        super.connectedCallback();
        this.recordId = this.getUrlParams('c__cartId');
        //nList can be any variable, need to store the route Quote property
        this.nList = this.route.Quote;
        //    modifying existing utility actions (add or remove)
        this.actionList.splice(0, 0, { label: 'GST Taggings', method: 'gstTagging' }, { label: 'Enrich Quote', method: 'downloadAndUploadAction' }, /*{ label: 'Download POC', method: 'downloadPOC' }, */{ label: 'Enrich Quote V2', method: 'openOmniscript' }, { label: 'Address Validation', method: 'verifyAddress', disabled: true }, { label: 'Address Correction', method: 'addressCorrection' }, {label: 'Check Feasibility', method: 'checkFeasibility'}, {label: 'Feasibility Info', method: 'openFeasibilityReport'},{label: 'Create DCP', method: 'openDCPModal'}/*, {label: 'Submit For Price Approval', method: 'submitForPriceApproval'},{label: 'Submit For OV Approval', method: 'submitForOVApproval'}*/);
    }
    executeAction(evt) {
        const func = evt.currentTarget.dataset.method;
        this[func]();
    }
    gstTagging() {
        //custom code here
        this.isGstTagging = true;
    }
    closemodal() {
        this.isGstTagging = false;
        this.isBaSaCreation = false;
        this.isAddressCorrection = false;
        this.iscreateBCPDCP=false;
    }
    getUrlParams(param) {
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        return urlParams.get(param);
    }
    downloadAndUploadAction() {
        this.isBaSaCreation = true;
    }

    openFeasibilityReport(){
        invokeDR('ARTL_DR_GetReportId', { reportName: 'Feasibility_Info_mZF' }).then(result => {
            if (result) {
                
                let parseResult = JSON.parse(result);
                
                this[NavigationMixin.GenerateUrl]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: parseResult[0].report[0].Id,
                        objectApiName: 'Report',
                        actionName: 'view'
                    },
                    state: { 
                        fv0: this.recordId,
                    } 
                }).then(url => { window.open(url, '_blank') });
                
            }
        }, err => {
            console.error(err);
        });
        
    }
    
    downloadPOC() {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: '/00O72000003wk3yEAA?csv=1&exp=1&enc=UTF-8&isdtp=p1'
            }
        }).then(generatedUrl => {
            window.open(generatedUrl, '_blank');
        });
    }
    openConfigureEnterpriseGuidedQuote() {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: '/apex/vlocity_cmt__B2BCmexConfigureEnterpriseQuote?Id=' + this.recordId + '&c__ContextId=' + this.recordId + '&c__ContainerName=eSMGuidedConfigureQuoteMultiLanguage'
            }
        }).then(generatedUrl => {
            window.open(generatedUrl, "_self");
        }), false;
    }
    openOmniscript() {
        console.log('recordId', this.recordId);
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: '/lightning/cmp/vlocity_cmt__vlocityLWCOmniWrapper?c__target=c:aRTLEnrishQuoteBASACreateEnglish&c__layout=lightning&c__tabIcon=custom:custom18&c__tabLabel=ARTL/EnrishQuoteBASACreate&c__ContextId=' + this.recordId
            }
        }).then(generatedUrl => {
            window.open(generatedUrl, '_blank');
        });

    }
   /* openDownloadOS(){
        getBulkCartUpdateFile().then((result) => {
            // this._columns = result['columns'];
            // this._templateURL = result['pageURL'];
            const base64Data = result;
            console.log('inside download',base64Data,' typeof ', typeof base64Data);
            this.downloadFile(base64Data);
            
          })
          .catch((error) => {
            console.log(error);
          });
        // this[NavigationMixin.GenerateUrl]({
        //     type: 'standard__webPage',
        //     attributes: {
        //         url: '/lightning/cmp/vlocity_cmt__vlocityLWCOmniWrapper?c__target=c:aRTLEnrishQuoteBASACreateEnglish&c__layout=lightning&c__tabIcon=custom:custom18&c__tabLabel=ARTL/EnrishQuoteBASACreate&c__ContextId=' + this.recordId
        //     }
        // }).then(generatedUrl => {
        //     window.open(generatedUrl, '_blank');
        // });
    }*/
    downloadFile(base64Data) {
        let a = document.createElement('a');
        a.href = 'data:application/vnd.ms-excel;base64,'+base64Data;
        a.download = 'filename.xlsm';
        a.click();
    }

    verifyAddress() {
        this.loading = true;
        let recordObj = { quoteId: this.recordId };//let recordObj = { this.recordId};//quoteId
        let requestData = {
            "type": "integrationprocedure",
            "value": {
                "ipMethod": "ARTL_FeasibilityAddressVerification",
                "inputMap": recordObj,
                "optionsMap": ''
            }
        }
        getDataHandler(JSON.stringify(requestData)).then(response => {
            this.ipResult = JSON.parse(response);
            if (this.ipResult && this.ipResult.IPResult) {
                let result = this.ipResult.IPResult;
                if(result.success){
                    console.log("Result of FeasibilityAddressVerification"+JSON.stringify(result));
                    this.ShowToast('Success', 'Address verification is in progress', 'success', 'dismissable');
                
                }else{
                    this.ShowToast('Error', result.errorMsg, 'error', 'dismissable');    
                }
                this.loading = false;
            }
        })
    }

    checkFeasibility() {
        this.loading = true;
        let recordObj = { quoteId: this.recordId };//let recordObj = { this.recordId};//quoteId
        let requestData = {
            "type": "integrationprocedure",
            "value": {
                "ipMethod": "ARTL_FeasibilityRequest",
                "inputMap": recordObj,
                "optionsMap": ''
            }
        }
        getDataHandler(JSON.stringify(requestData)).then(response => {
            this.ipResult = JSON.parse(response);
            if (this.ipResult && this.ipResult.IPResult) {
                let result = this.ipResult.IPResult;
                //console.log("Result of FeasibilityRequest" + JSON.stringify(result));
                if(result.success){
                    this.ShowToast('Success', 'Feasibility Check is in progress', 'success', 'dismissable');
                    const self = this;
                    const messageCallback = function (response) {
                        console.log('ID 2>>> ' + self.recordId);
                        if(response.data.payload.ARTL_QuoteId__c == self.recordId){
                            console.log('ID 3>>> ' + self.recordId);
                            self.ShowToast('Feasibility Completed', 'Feasibility Check is completed', 'success', 'dismissable');
                        }else{
                            console.log('#### Subscribed event doesnt match with quote id');
                        }
                    };
                    subscribe( this.feasibilityEventName, -1, messageCallback );
                
                } else{
                    this.ShowToast('Error', result.errorMsg, 'error', 'dismissable');
                    
                }
                this.loading = false;
            }
        })
    }


    ShowToast(title, message, variant, mode) {
        const evt = new ShowToastEvent({
          title: title,
          message: message,
          variant: variant,
          mode: mode
        });
        this.dispatchEvent(evt);
    }
    addressCorrection(){
        this.isAddressCorrection = true;
    }

    //Sagar: Commented to deploy this to QA
    openDCPModal(){
        console.log('inside opem modal');
       this.iscreateBCPDCP=true;
       console.log('inside opem modal');
    }

    // submitForPriceApproval(){
    //     //this.isInvokeSubmitForPriceApproval = true;
    //     console.log('clickedsubmitForPriceApproval');
    //     const queryPn = this.template.querySelector("c-a-r-t-l_-invoke-submit-for-price-approval");
    //     console.log('queried'+JSON.stringify(queryPn));
    //     this.template.querySelector("c-a-r-t-l_-invoke-submit-for-price-approval").invoke();

        
    // }
    // submitForOVApproval(){
    //     this.isInvokeSubmitForPriceApproval = true;
        
    // }
}