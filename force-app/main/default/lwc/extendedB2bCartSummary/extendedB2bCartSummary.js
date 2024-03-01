import B2bCartSummary from 'vlocity_cmt/b2bCartSummary';
import { LightningElement, api, track } from 'lwc';
import { getDataHandler } from "vlocity_cmt/utility";
import { CloseActionScreenEvent } from "lightning/actions";
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import ArcTotal from '@salesforce/label/c.CMEXARCTotal';
import { formatCurrency } from 'vlocity_cmt/utility';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { invokeDR } from "vlocity_cmt/b2bUtils";
import { NavigationMixin } from "lightning/navigation";
import pubsub from 'vlocity_cmt/pubsub';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';
import getBulkCartUpdateFile from '@salesforce/apex/ARTL_BulkUploadCartStageLoad.getBulkCartUpdateFile';
import invokeGetQLIAPI from '@salesforce/apex/ARTL_BulkUploadCartStageLoad.invokeGetQLIAPI';
import { updateRecord } from 'lightning/uiRecordApi';
import validateDoc from '@salesforce/apex/ARTL_DocumentUploadController.validateDoc';
import invokeDOAApproval from '@salesforce/apex/ARTL_InvokeDOAApprovalProcessHelper.invokeDOAApproval';
import checkQuoteIsInPendingApproval from '@salesforce/apex/ARTL_InvokeDOAApprovalProcessHelper.checkQuoteIsInPendingApproval';
import ID_FIELD from "@salesforce/schema/Quote.Id";
import STATUS_FIELD from '@salesforce/schema/Quote.Status';
import { RefreshEvent } from "lightning/refresh";
import LightningAlert from 'lightning/alert';
import { formatCurrencyESM, setCurrencyCode, setLocale} from "c/cb2bUtils";

export default class ExtendedB2bCartSummary extends NavigationMixin(B2bCartSummary) {
    label = {
        ArcTotal,
    };
    get annualRecurringTotal() {
        return formatCurrencyESM(this.cartData?.ARTL_EffectiveAnnualRecurringTotal__c); 
    }
    get oneTimeTotalEsm() {
        return formatCurrencyESM(this.cartData?.EffectiveOneTimeTotal__c)
    }
    get monthlyTotalEsm() {
        return formatCurrencyESM(this.cartData?.EffectiveRecurringTotal__c)
    }
    get effectiveQuoteTotal() {
        return formatCurrencyESM(this.cartData?.ARTL_Effective_Quote_Total__c);
    }
   
    isGstTagging = false;
    isBaSaCreation = false;
    isAddressCorrection = false;
    isInvokeSubmitForPriceApproval = false;
    iscreateBCPDCP = false; // Sagar: commented to deploy this file to QA
    prefill;
    @track isDocUpload= true;
    @track modalValue= false;
    @api recordId;
    @api objectApiName;
    feasibilityEventName = '/event/ARTL_Feasibility_Event__e';
    notificationEvent = '/event/NotificationWorker__e';
    feasibilityCheckCompleteEvent = 'FEASIBILITY_CHECK_COMPLETED';
    addressValidationCompleteEvent = 'ADDRESS_VALIDATION_COMPLETED';
    toastMessage = 'Fetch Item Code Completed';
    showVerifyAddress = false;
    showAddressCorrection = false;
    showCheckFeasibility = false;
    showSubmitForPriceApproval = true;
    showSubmitForOVApproval = true;
    showQuoteDetails = true;
    showAddProductBtn = true;
    fetchCodeSuccessCount = 0;
    fetchCodeTotalQli = 0;
    fetchItemCodeText = "Fetch Item Code";
    rfEvent;
    
    connectedCallback() {
        this.recordId = this.getUrlParams('c__cartId');
        super.connectedCallback();
        this.recordId = this.getUrlParams('c__cartId');
        //nList can be any variable, need to store the route Quote property
        this.nList = this.route.Quote;
       // Select Summary tab by default
       const activeTabIndex= localStorage.getItem('summary') ? 0 : 1 ;
       const activeTabId= localStorage.getItem('summary') ? "Product" : "Location" ;
       console.log("activeTabIndex", activeTabIndex);
       console.log("activeTabId", activeTabId);
       this.handleTabChange({
            "detail": {
                "result": {
                    "tabIndex": activeTabIndex,
                    "id": activeTabId,
                }
            }
        });

        this.fetchQuoteDetails(this.route.Quote.id);
        this.checkFeasibilitySubscribe();
    }

    handleTabChange(evt){
        console.log("evt", evt.detail);
        super.handleTabChange(evt);
        localStorage.removeItem('summary');
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
        getDataHandler(datasourcedef)
            .then(data => {
                console.log("This.quote Details currecny code: ", JSON.parse(data)[0].Quote[0].vlocity_cmt__PriceListId__r.vlocity_cmt__CurrencyCode__c);
                setCurrencyCode(JSON.parse(data)[0].Quote[0].vlocity_cmt__PriceListId__r.vlocity_cmt__CurrencyCode__c);
                this.quoteStatus = JSON.parse(data)[0].Quote[0].Status;
                this.quoteNeedDoaApproval = JSON.parse(data)[0].Quote[0].ARTL_QNeedDOAApproval__c;
                this.quoteNeedCapexApproval = JSON.parse(data)[0].Quote[0].ARTL_QNeedCapexApproval__c;
                this.quoteType = JSON.parse(data)[0].Quote[0].vlocity_cmt__Type__c ? JSON.parse(data)[0].Quote[0].vlocity_cmt__Type__c : "undefined";
                // console.log("this.quoteType", this.quoteType);
                this.addressAndFeasibilityStatus = JSON.parse(data)[0].Quote[0].ARTL_Address_and_Feasibility_Status__c;
                console.log('addressAndFeasibilityStatus ---- '+this.addressAndFeasibilityStatus);
                //    modifying existing utility actions (add or remove)
                this.actionList.splice(0, 0,
                    // {label:'Sample Action 3',method:'sampleAction3',showItem: this.quoteStatus == "Draft" ? true : false},
                  //  { label: 'GST Taggings', method: 'gstTagging' },
                  //Enrich Quote is commented as part of Usability Enhancements story by Prakash Sahu
                  //  { label: 'Enrich Quote', method: 'downloadAndUploadAction' },
                    /*{ label: 'Download POC', method: 'downloadPOC' }, */
                   // { label: 'Enrich Quote V2', method: 'openOmniscript' },
                    // { label: 'Address Validation', method: 'verifyAddress', disabled: true },
                    // { label: 'Address Correction', method: 'addressCorrection' },
                    // { label: 'Check Feasibility', method: 'checkFeasibility' },
                    { label: 'Feasibility Info', method: 'openFeasibilityReport' },
                   // { label: 'Create DCP', method: 'openDCPModal' },
                    // { label: 'Fetch Item Code', method: 'getAttDetails' },

                    // { label: 'Configure Enterprise Guided Quote', method: 'navigateToGuidedJourney', showItem: true },
                    // { label: 'Discounts and Promotions', method: 'toggleDiscountPanel', showItem: true },
              /*,
              {label: 'Submit For Price Approval', method: 'submitForPriceApproval'},
              {label: 'Submit For OV Approval', method: 'submitForOVApproval'}*/);
                //   this.showAction2 = this.quoteStatus == "Approved" ? true : false;
                //Removing Check servicability and validate address buttons
                this.actionList =  this.actionList.filter(item =>item.label != 'Check Serviceability');
                this.actionList =  this.actionList.filter(item => item.label != 'Validate Addresses');
                if(((this.quoteStatus == "Feasibility Completed" && this.quoteNeedDoaApproval == false &&  this.quoteNeedCapexApproval == false) || (this.quoteStatus == "DOA Approved" && (this.quoteNeedDoaApproval == true ||  this.quoteNeedCapexApproval == true)) || ((this.quoteType == "Upgrade" || this.quoteType == "Downgrade" || this.quoteType == "Rate Revision") &&  this.quoteStatus == "Negotiation") ) && (this.quoteType != "Rebilling" && this.quoteType != "PO Renewal") ){
                }else{
                    this.actionList =  this.actionList.filter(item => item.label != 'Create Proposal');
                }

                if(this.quoteStatus == "Proposal Sent" || this.quoteStatus == "Proposal Accepted"){
                    if((this.quoteType != "Upgrade" && this.quoteType != "Downgrade" && this.quoteType != "Rate Revision" && this.quoteType != "Rebilling" && this.quoteType != "PO Renewal")){
                        this.actionList.splice(0, 0,
                            { label: 'Create DCP', method: 'openDCPModal' });
                    }
                    if(this.quoteType != "Rebilling" && this.quoteType != "PO Renewal"){
                        this.actionList.splice(0, 0,
                            { label: 'Enrich Quote - UI', method: 'openOmniscript' });  
                    }
                  
                    
                }

                if((this.quoteType == "Rebilling" || this.quoteType == "PO Renewal") && this.quoteStatus == "Draft"){
                      this.actionList.splice(0, 0,
                            { label: 'Enrich Quote - UI', method: 'openOmniscript' });       
                }


                this.showVerifyAddress =  (this.addressAndFeasibilityStatus == "None" || this.addressAndFeasibilityStatus == "Feasibility in Progress" || this.quoteType == "Upgrade" || this.quoteType == "Downgrade" || this.quoteType == "Rate Revision" || this.quoteType == "Rebilling" || this.quoteType == "PO Renewal") ? false : true ;
                this.showAddressCorrection =  ((this.addressAndFeasibilityStatus == "Coordinate Validations Completed" || this.addressAndFeasibilityStatus == "Feasibility Completed") && (this.quoteType != "Upgrade" && this.quoteType != "Downgrade" && this.quoteType != "Rate Revision" && this.quoteType != "Rebilling" && this.quoteType != "PO Renewal") ) ? true : false ;
                this.showCheckFeasibility =  ((this.addressAndFeasibilityStatus == "Coordinate Validations Completed" || this.addressAndFeasibilityStatus == "Feasibility Completed" ) && (this.quoteType != "Upgrade" && this.quoteType != "Downgrade" && this.quoteType != "Rate Revision" && this.quoteType != "Rebilling" && this.quoteType != "PO Renewal")) ? true : false ;

                this.showSubmitForPriceApproval =  (this.quoteStatus != "DOA Approval in Progress" && this.quoteNeedDoaApproval == true && this.quoteType != "Demo" && this.quoteType != "Rebilling" && this.quoteType != "PO Renewal") ? true : false ;
                this.showSubmitForOVApproval =  ((this.quoteStatus == "Proposal Accepted" && this.quoteType != "Demo") || this.quoteType == "Rebilling" || this.quoteType == "PO Renewal") ? true : false ;
                this.showAddProductBtn = (this.quoteType == "Rebilling" || this.quoteType == "Rate Revision") ? false : true ;     
            }).catch(error => {
                console.log('fetchQuoteDetails', error);
            });
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
        this.iscreateBCPDCP = false;
    }
    getUrlParams(param) {
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        return urlParams.get(param);
    }
    downloadAndUploadAction() {
        this.isBaSaCreation = true;
    }

    openFeasibilityReport() {
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
                // url: '/lightning/cmp/vlocity_cmt__vlocityLWCOmniWrapper?c__target=c:aRTLEnrishQuoteBASACreateEnglish&c__layout=lightning&c__tabIcon=custom:custom18&c__tabLabel=ARTL/EnrishQuoteBASACreate&c__ContextId=' + this.recordId
                url: '/lightning/cmp/vlocity_cmt__vlocityLWCOmniWrapper?c__target=c:aRTLParentQuoteEnrichFlowEnglish&c__layout=lightning&c__tabIcon=custom:custom18&c__tabLabel=ARTL/EnrishQuoteBASACreate&c__ContextId=' + this.recordId
            }
        }).then(generatedUrl => {
            window.open(generatedUrl, '_blank');
        });

    }
    
    getAttDetails(){
        this.loading = true;
        let recordObj = {
            "cartId": this.recordId,
            "userId": "00572000005mBkfAAE"
        }
        let requestData = {
            "type": "integrationprocedure",
            "value": {
                "ipMethod": "ARTL_FetchItemCodeBatch",
                "inputMap": recordObj,
                "optionsMap": ''
            }
        }
        getDataHandler(JSON.stringify(requestData)).then(response => {
            console.log("Result of ARTL_FetchItemCodeBatch",response);
            this.ipResult = JSON.parse(response);
            this.loading = true;
            if (this.ipResult && this.ipResult.IPResult) {
                let result = this.ipResult.IPResult;
               
                if (result.success) {
                    this.ShowToast('Success', 'FetchItemCode is in progress', 'success', 'dismissable');
                    const self = this;
                    const messageCallbackFetchItemCode = function (response) {
                        console.log('response 2 >>> ' + self.response);
                        if (response.data.payload.artlQuoteId__c == self.recordId  && response.data.payload.SubEventName__c == self.toastMessage) {
                            console.log('ID 3>>> ' + self.recordId);
                            self.ShowToast('Success', 'FetchItemCode callouts for NIPS products are completed. Success: '+response.data.payload.successCount__c +' Failure: '+response.data.payload.failureCount__c, 'success', 'dismissable');
                            self.handleRefreshFetchItemCode();
                        } else {
                            console.log('#### Subscribed event doesnt match with quote id');
                        }
                    };
                    
                    subscribe(this.notificationEvent, -1, messageCallbackFetchItemCode);
                } else {
                    this.ShowToast('Error', result.errorMsg, 'error', 'dismissable');
                }
                this.loading = false;
            }
        });
    }
   
     handleBulkQLIUpload(){
        console.log('entered the button');
        this.isDocUpload = false;
        this.modalValue = true;
        //this.template.querySelector('c-artl_-bulk-data-upload-comp').isModalOpen = true;
           console.log('bulk Uplaod click 345');
     }

    closedUploadModal(event){
        this.isDocUpload = true;
    }
    // Commenting out to deploy this code to QA
    handleBulkQLIDownload() {
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
                    LightningAlert.open({
                        message: error.body.message,
                        theme: 'error', // a red theme intended for error states
                        label: 'Error!', // this is the header text
                    });
                     console.log( 'error  ---> ',error);
                     console.log( 'error status ---> ',error.status);
                     console.log( 'error mesage ---> ',error.body.message);
               });
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
        const fileName = `EILL_OrderEntry_${datetime}.xlsm`;
        console.log('dynamic name fileName 207--- > ',datetime);

        let a = document.createElement('a');
        a.href = 'data:application/vnd.ms-excel;base64,' + base64Data;
         a.download = fileName;       //'EILL_OrderEntry.xlsm';
         console.log('bulk downoad click before click');
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
                if (result.success) {
                    console.log("Result of FeasibilityAddressVerification" + JSON.stringify(result));
                    this.ShowToast('Success', 'Address verification is in progress', 'success', 'dismissable');
                    const self = this;
                    const messageCallback = function (response) {
                        console.log('ID 2>>> ' + self.recordId);
                        if (response.data.payload.ARTL_QuoteId__c == self.recordId  && response.data.payload.subEventName__c == self.addressValidationCompleteEvent) {
                            console.log('ID 3>>> ' + self.recordId);

                            self.ShowToast('Success', 'Address verification is completed', 'success', 'dismissable');
                            //self.dispatchEvent(new RefreshEvent());
                            self.refreshESMCart();
                           // self.refreshQuoteRecord();
                        } else {
                            console.log('#### Subscribed event doesnt match with quote id');
                        }
                    };
                  
                    subscribe(this.feasibilityEventName, -1, messageCallback);
                   // this.refreshESMCart();

                } else {
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
                if (result.success) {
                    this.ShowToast('Success', 'Feasibility Check is in progress', 'success', 'dismissable');
                    this.checkFeasibilitySubscribe();
                    this.refreshESMCart();
                  

                } else {
                    this.ShowToast('Error', result.errorMsg, 'error', 'dismissable');

                }
                this.loading = false;
            }
        })
    }
    checkFeasibilitySubscribe(){
        const self = this;
        const messageCallback = function (response) {
            console.log('ID 2>>> ' + self.recordId);
            if (response.data.payload.ARTL_QuoteId__c == self.recordId && response.data.payload.subEventName__c == self.feasibilityCheckCompleteEvent) {
                console.log('ID 3>>> ' + self.recordId);
                self.ShowToast('Feasibility Completed', 'Feasibility Check is completed', 'success', 'dismissable');
              //  self.dispatchEvent(new RefreshEvent());
                self.refreshESMCart();
            } else {
                console.log('#### Subscribed event doesnt match with quote id');
            }
        };
        subscribe(this.feasibilityEventName, -1, messageCallback);
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
    addressCorrection() {
        this.isAddressCorrection = true;
    }

    //Sagar: Commented to deploy this to QA
    openDCPModal() {
        this.iscreateBCPDCP = true;
    }

    submitForPriceApproval() {
        checkQuoteIsInPendingApproval({ quoteId: this.recordId })
        .then(result => {
            console.log('from apex then');
            this.res = result;
            console.log('have approval history ' + this.res)
            if (this.res == true) {
                console.log('Error toast');

                this.ShowToast('Error', 'Quote is in an active approval process; Quote is not submitted for DOA Approval', 'error', 'dismissible');
                console.log('Error toast showed');
            }
            else {
                this.updateStatusToInProgress();
                this.ShowToast('Success', 'Quote is Submitted for Approval', 'success', 'dismissible');

                invokeDOAApproval({ quoteId: this.recordId })
                    .then(result => {

                        console.log('from apex then');
                        this.res = result;
                        console.log('this.res', this.res);
                        this.refreshQuoteRecord();
                        if (this.res && this.res != null) {
                            console.log('if ' + JSON.stringify(this.res));
                        }

                       // this.refreshQuoteRecord();
                    })
                    .catch(error => {
                        console.error('Error from Apex:', error);
                        this.error = error;
                    });
                    setTimeout( function() {
                        window.location.reload();
                    }, 2000);
            }
        })
        .catch(error => {
            console.error('Error from Apex:', error);
            this.error = error;
        });
    }

    submitForOVApproval() {
        validateDoc({ recId: this.recordId, objName: "Quote",  }).then(res => {
            console.log('@@@res =', res);
            if (res) {
                console.log('res is', res)

                console.log('Artl_SubmitForApproval.connectedCallback.recordId' + this.recordId);
                let recordObj = { QuoteId: this.recordId };
                console.log('Artl_SubmitForApproval.connectedCallback.recordObj' + JSON.stringify(recordObj));
                let requestData = {
                    "type": "integrationprocedure",
                    "value": {
                        "ipMethod": "ARTL_GetRevisitSiteStatusNCallApprovalProcess",
                        "inputMap": recordObj,
                        "optionsMap": ''
                    }
                }
                //invoke IP
                getDataHandler(JSON.stringify(requestData)).then(response => {
                    this.ipResult = JSON.parse(response);
                    console.log('this.ipResultIPResult ' + JSON.stringify(this.ipResult.IPResult));
                    console.log('this.ipResult.RevisiteFlag ' + this.ipResult.IPResult.RevisiteFlag);
                    console.log('this.ipResult.SubmitApprovalStatus ' + this.ipResult.IPResult.SubmitApprovalStatus);
                    let message;
                    if (this.ipResult.IPResult.RevisiteFlag && this.ipResult.IPResult.RevisiteFlag == 'warning') {
                        message = 'There are sites that need attention before you submit for OV Approvals';
                        this.showWarningMsg(message);
                    }

                    if (this.ipResult.IPResult.SubmitApprovalStatus && this.ipResult.IPResult.SubmitApprovalStatus == true) {
                        console.log('InsideSuccessIf')
                        this.showSuccessMsg();
                    }
                    else if (this.ipResult.IPResult.SubmitApprovalStatus === "") {
                        // console.log('InsideElseIf')
                        this.showErrorgMsg();
                    }

                    this.dispatchEvent(new CloseActionScreenEvent());
                    notifyRecordUpdateAvailable([{ recordId: this.recordId }]);
                    setTimeout( function() {
                        window.location.reload();
                    }, 2000);
                    //this.navigateToRecordViewMode();

                });
            } else {
                console.log('res is else cond', res)
                this.dispatchEvent(new CloseActionScreenEvent());
                this.errorValidationToast('Error', 'Please upload required documents to submit', 'error')
            }
        }).catch(error => {
            console.log('error in validateDoc ', error)
        })
    }

    quoteDetails() {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: '/lightning/r/Quote/' + this.recordId + "/view"
            }
        }).then(generatedUrl => {
            window.open(generatedUrl, '_blank');
        });
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

    /** Utility Functions */
    errorValidationToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        }))
    }
    showWarningMsg(message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Warning',
                message: message,
                variant: 'Warning'
            }),
        );
    }

    showSuccessMsg() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Approval',
                message: 'Request for Approval successfull ',
                variant: 'success'
            }),
        );

    }

    showErrorgMsg() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Approval',
                message: 'Process failed. Already in Process ',
                variant: 'error'
            }),
        );

    }

    updateStatusToInProgress() {
        // Create an object to hold the updated field values
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[STATUS_FIELD.fieldApiName] = 'DOA Approval in Progress';

        // Prepare the record input for the updateRecord function
        const recordInput = { fields };

        // Use the updateRecord function to update the Quote record
        updateRecord(recordInput)
            .then(result => {
                // Log a success message and refresh the quote record
                console.log('Record updated successfully:', result);
                this.refreshQuoteRecord();

            })
            .catch(error => console.error('Error updating status:', error));
    }
    // Method to refresh the Quote record using LDS after the update
    refreshQuoteRecord() {
        this.dispatchEvent(new CustomEvent('force:refreshView'));
    }

    refreshESMCart() {
        this.rfEvent = setTimeout(() => {
            window.location.reload();
          },2000); 
    }


    handleRefreshFetchItemCode() {
        setTimeout(() => {
            localStorage.setItem('summary', 1);
            window.location.reload();
        }, 2000)
    }

}