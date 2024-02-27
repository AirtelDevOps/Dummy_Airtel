import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { getDataHandler } from "vlocity_cmt/utility";
import { CloseActionScreenEvent } from "lightning/actions";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { RefreshEvent } from 'lightning/refresh';
import { NavigationMixin } from 'lightning/navigation';
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import validateDoc from '@salesforce/apex/ARTL_DocumentUploadController.validateDoc';

export default class Artl_SubmitForApproval extends NavigationMixin(LightningElement) {
    //export default class Artl_SubmitForApproval extends LightningElement {
    @api recordId;
    @api objectApiName;


    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        console.log('Artl_SubmitForApproval.getStateParameters.recordIdBefore' + this.recordId);
        if (this.recordId == undefined) {
            if (currentPageReference) {
                console.log('current page refernece: ' + currentPageReference);
                this.recordId = currentPageReference.state.recordId;
                console.log('Artl_SubmitForApproval.getStateParameters.recordId' + this.recordId);
            }
        }
    }

    connectedCallback() {
        validateDoc({recId :this.recordId ,objName : 'Quote'}).then(res=>{
            console.log('@@@res =', res);
            if(typeof res === 'string' && res === ''){
                
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
                    console.log('this.ipResult.RevisiteFlag ' +this.ipResult.IPResult.RevisiteFlag);
                    console.log('this.ipResult.SubmitApprovalStatus ' +this.ipResult.IPResult.SubmitApprovalStatus);
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
                    notifyRecordUpdateAvailable([{recordId: this.recordId}]);
                    //this.navigateToRecordViewMode();
        
                });
            }else{
                console.log('res is else cond' , res)
                const errorStrings = res;
                    this.dispatchEvent(new CloseActionScreenEvent());
                 this.errorValidationToast('Error', `Submit to OV approval failed due to missing Documents: ${errorStrings}`, 'error');
                
            }
        }).catch(error=>{
            console.log('error in validateDoc ' , error)
        })
    }
    

//    async validateBeforeApproval(){
//             try{
//                 const ress = await validateDoc({recId :this.recordId ,objName : this.objectApiName}).then(res=>{
//                     return res
//                 }).catch(error=>{})
//                 console.log('const resssss' , ress)
//                if(ress){
//                 console.log('res if true' , ress)
//                }else{
//                 console.log('res if false' , ress)
//                } 
//             }catch(error){

//             }
//     }

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

    // navigateToRecordViewMode() {
    //     this[NavigationMixin.Navigate]({
    //         type: "standard__recordPage",
    //         attributes: {
    //             recordId: this.recordId,
    //             objectApiName: this.objectApiName,
    //             actionName: 'view'
    //         }
    //     })
    // }

}