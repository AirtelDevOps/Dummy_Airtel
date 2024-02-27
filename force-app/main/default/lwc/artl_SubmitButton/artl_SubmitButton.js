import { LightningElement, api } from 'lwc';
import { OmniscriptBaseMixin } from "vlocity_cmt/omniscriptBaseMixin";
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class artl_SubmitButton extends NavigationMixin(OmniscriptBaseMixin(LightningElement)) {
    _quoteid;
    _toastmessagelist = [];

    quotestatus;
    olilist = [];
    title;
    message;
    variant;
    mode;
    notifications =[];

    @api
    get quoteid() {
        return this._quoteid;
    }
    set quoteid(val) {
        this._quoteid = val;
    }

    @api
    get toastmessagelist() {
        return this._toastmessagelist;
    }
    set toastmessagelist(val) {
        this._toastmessagelist = val;
    }

    
    //Added by RR to set default Notifications, if the Notifications are not configured.
    defaultNotifications = [
        {
            title: 'No Title Provided',
            message: 'Notifications are not configured',
            variant: 'error',
            mode: 'sticky'
        }
    ];

    handleCancelClick(event) {
        if (this.quoteid) {
            this.navigateToQuoteRecordPage();
        }
    }

    connectedCallback() {
        console.log('artl_SubmitButton this.quoteid ' + this.quoteid);
        console.log('artl_SubmitButton this.toastmessagelist ' + JSON.stringify(this.toastmessagelist));
    }

    identifyMessageParams(level) {
        if (this.toastmessagelist && this.toastmessagelist.length > 0) {
            this.toastmessagelist.forEach(item => {
                if (item.level === level && item.level === 'context') {
                    this.populateMessageParams(item);
                } 
                if (item.level === level && item.level === 'line-primary') {
                    this.populateMessageParams(item);
                } 
                if (item.level === level && item.level === 'line-secondary') {
                    this.populateMessageParams(item);
                }
            });
        }
    }

    populateMessageParams(item) {
        
        this.notifications.push(item);
    }

    handleSubmitClick(event) {
        this.notifications =[];
        if (this.omniJsonData && this.omniJsonData.UpdatedQLI) {
            this.olilist = this.omniJsonData.UpdatedQLI;
        }

        if (this.omniJsonData && this.omniJsonData.OVDetailsStep && this.omniJsonData.OVDetailsStep.OVHeaderLevelBlock && this.omniJsonData.OVDetailsStep.OVHeaderLevelBlock.OVApprovalRadioButton) {
            this.quotestatus = this.omniJsonData.OVDetailsStep.OVHeaderLevelBlock.OVApprovalRadioButton;
        }

        console.log('artl_SubmitButton this.quotestatus ' + this.quotestatus);
        console.log('artl_SubmitButton this.olilist ' + JSON.stringify(this.olilist));

        if (this.olilist && this.quotestatus && this.olilist.length != 0 && JSON.stringify(this.olilist) != []) {
            let lineOVRejectedCount = 0;
            let missingRejectionReasonCount = 0;
            let levelStr;
            this.olilist.forEach(item => {
                console.log('artl_SubmitButton item=>' + JSON.stringify(item));

                if (item.OVStatus === 'OV Rejected') {
                    lineOVRejectedCount = lineOVRejectedCount + 1;
                }
                if (item.OVStatus === 'OV Rejected' && !item['RejectionReason']) {
                    missingRejectionReasonCount = missingRejectionReasonCount + 1;
                }
            });

            console.log('artl_SubmitButton missingRejectionReasonCount ' + missingRejectionReasonCount);
            console.log('artl_SubmitButton lineOVRejectedCount ' + lineOVRejectedCount);
            if ((this.quotestatus === 'OV Approved' && lineOVRejectedCount === 0 && missingRejectionReasonCount === 0) || this.quotestatus === 'OV Rejected' && lineOVRejectedCount > 0 && missingRejectionReasonCount === 0) {
                this.omniNextStep();
            }     
            if (this.quotestatus === 'OV Approved' && lineOVRejectedCount > 0) {
                levelStr = 'context';
                this.identifyMessageParams(levelStr);
            } 
            if ((this.quotestatus === 'OV Rejected' && lineOVRejectedCount > 0 && missingRejectionReasonCount > 0) || (this.quotestatus === 'OV Approved' && lineOVRejectedCount > 0 && missingRejectionReasonCount > 0)) {
                levelStr = 'line-secondary';
                this.identifyMessageParams(levelStr);
      
            }
            console.log('artl_SubmitButton this.notifications=>' + JSON.stringify(this.notifications));
            for (let i = 0; i < this.notifications.length; i++) {
                this.showToastMessage(this.notifications[i].title, this.notifications[i].message, this.notifications[i].variant, this.notifications[i].mode);
        
              }


        }
    }

    navigateToQuoteRecordPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.quoteid,
                objectApiName: 'Quote',
                actionName: 'view'
            },
        });
    }

    showToastMessage(title, message, variant, mode) {
        const event = new ShowToastEvent({
          title: title,
          message: message,
          variant: variant,
          mode: mode
        });
        this.dispatchEvent(event);
    
      }


}