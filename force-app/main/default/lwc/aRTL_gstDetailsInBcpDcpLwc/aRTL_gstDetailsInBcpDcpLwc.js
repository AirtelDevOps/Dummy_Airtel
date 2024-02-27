import { LightningElement, api, wire, track } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CONTACT_PREMISE_RELATION_OBJECT from '@salesforce/schema/ContactPremiseRelation__c';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import GST_APPLICABLE_FIELD from '@salesforce/schema/ContactPremiseRelation__c.ARTL_GST_Applicable__c';
import STANDARD_REASON_FIELD from '@salesforce/schema/ContactPremiseRelation__c.ARTL_Standard_Reason__c';
import getGstDetails from '@salesforce/apex/ARTL_gstDetailsInBcpDcp.getGstDetails';
import { ShowToastEvent } from "lightning/platformShowToastEvent";


export default class ARTL_gstDetailsInBcpDcpLwc extends OmniscriptBaseMixin(LightningElement) {
    gstApplicableValue;
    gstApplicableOptions;

    standardReasonValue;
    standardReasonFieldData;
    standardReasonOptions;

    gstTypeValue;

    gstOptions;
    gstSelectedValue;

    gstNumberRequired = false;
    lwcError;

    gstApplicableReadonly = false;

    @api stateValue;
    @api nbaAccountIdValue;
    @api isUpdate;
    @api gstApplicableValueInput;
    @api standardReasonValueInput;
    @api gstSelectedValueInput;

    details = {
        "gstApplicable": null,
        "standardReason": null,
        "gstSelectedValue": null,
        "gstType": null, 
        "lwcError": null
    };

    get nbaAccountId() {
        if (this.omniJsonData) {
            var contextId = JSON.parse(JSON.stringify(this.omniJsonData))['ContextId'];
            return contextId;
        }
        else {
            return this.nbaAccountIdValue;
        }
    }

    get state() {
        if (this.omniJsonData) {
            var contactDetails = JSON.parse(JSON.stringify(this.omniJsonData))['Step_ContactDetails'];
            var pincodeBlock = contactDetails['TApincode-Block'];
            return pincodeBlock['state'];
        }
        else {
            return this.stateValue;
        }
    }

    gstTypeSez = ['SEZ', 'SEZ with taxes'];
    gstTypeNonSez = ['Non-SEZ', 'Zero Rated Supply- FTWZ', 'Non Taxable as transactions within same Company'];

    @wire(getObjectInfo, { objectApiName: CONTACT_PREMISE_RELATION_OBJECT })
    contactPremiseObject;


    @wire(getPicklistValues, { recordTypeId: '$contactPremiseObject.data.defaultRecordTypeId', fieldApiName: GST_APPLICABLE_FIELD })
    gstApplicableInfo({ data, error }) {
        if (data) {
            this.gstApplicableOptions = data.values;
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$contactPremiseObject.data.defaultRecordTypeId', fieldApiName: STANDARD_REASON_FIELD })
    standardReasonInfo({ data, error }) {
        if (data) {
            this.standardReasonFieldData = data;
            if (this.gstApplicableValueInput && this.gstApplicableValueInput !== undefined && this.isUpdate) {
                var event = {
                    detail: {
                        value: this.gstApplicableValueInput
                    }
                }
                this.handleGstApplicableChange(event);
            }
        }
    }

    connectedCallback() {
        console.log('ConnectedCallback ');
        if (this.isUpdate) {
            this.gstApplicableReadonly = this.isUpdate;
        }
    }

    handleGstApplicableChange(event) {
        try {
            this.gstSelectedValue = null;
            this.gstOptions = null;
            this.standardReasonValue = null;
            let key = this.standardReasonFieldData.controllerValues[event.detail.value];
            this.gstApplicableValue = event.detail.value;
            this.standardReasonOptions = this.standardReasonFieldData.values.filter(opt => opt.validFor.includes(key));
            if (this.standardReasonValueInput && this.standardReasonValueInput !== undefined && this.isUpdate) {
                this.standardReasonValue = this.standardReasonValueInput;
                this.gstType();
                this.handleGetGstDetail();
            }
            var data = {
                Step_ContactDetails: {
                    gstApplicable: this.gstApplicableValue,
                }
            };
            this.details["gstApplicable"] = this.gstApplicableValue;
            this.omniApplyCallResp(data);
        }

        catch (error) {
            console.error(error);
            this.showNotification('Error', error.message, 'error');
        }
    }

    standardReasonHandleChange(event) {
        try {
            console.log('DEBUGG standardReasonHandleChange ', event.detail.value);
            this.gstSelectedValue = null;
            this.gstOptions = null;
            this.standardReasonValue = event.detail.value;
            var data = {
                Step_ContactDetails: {
                    standardReason: this.standardReasonValue
                }
            };
            console.log('DEBUGG this.gstSelectedValue ', this.gstSelectedValue);
            this.omniApplyCallResp(data);
            this.gstType();
        }
        catch (error) {
            console.error(error);
            this.showNotification('Error', error.message, 'error');
        }

    }

    handleGetGstDetail() {
        console.log('DEBUGG handleGetGstDetail ', this.state);
        console.log('DEBUGG handleGetGstDetail ', this.nbaAccountId);
        console.log('DEBUGG handleGetGstDetail this.gstTypeValue ', this.gstTypeValue);

        this.isUpdate = false;

        try {
            getGstDetails({
                state: this.state,
                nbaAccountId: this.nbaAccountId,
                gstType: this.gstTypeValue
            })
                .then((result) => {
                    if (result.length == 0) {
                        this.showNotification('Error', 'No GST records found.', 'error');
                    }
                    else if (result.length > 0) {
                        this.showNotification('Success', 'GST records fetched.', 'success');
                        this.gstOptions = result;
                        if (this.gstSelectedValueInput) {
                            this.gstSelectedValue = this.gstSelectedValueInput;
                            this.details['gstType'] = this.gstTypeValue;
                            this.details['standardReason'] = this.standardReasonValue;
                            this.details['gstSelectedValue'] = this.gstSelectedValue;
                            this.details['lwcError'] = null;
                            this.dispatchEvent(new CustomEvent('gstselectedvalue', { detail: this.details }));
                        }
                    }

                })
                .catch((error) => {
                    console.log('error ', error);
                    this.showNotification('Error', error.message, 'error');
                })
        }
        catch (error) {
            console.error(error);
            this.showNotification('Error', error.message, 'error');
        }
    }

    gstType() {
        try {
            console.log('DEBUGG gstDetailsBCPDCP gstType ', this.standardReasonValue);
            if (this.gstTypeSez.includes(this.standardReasonValue)) {
                this.gstTypeValue = 'SEZ';
                this.gstNumberRequired = true;
            }
            else if (this.gstTypeNonSez.includes(this.standardReasonValue)) {
                this.gstTypeValue = 'Non-SEZ';
                this.gstNumberRequired = true;
            }
            else if (this.standardReasonValue === 'UIN') {
                this.gstTypeValue = 'UIN';
                this.gstNumberRequired = true;
            }
            else {
                this.gstTypeValue = '';
                this.gstNumberRequired = false;
            }

            if (this.gstNumberRequired) {
                this.lwcError = 'Please select a GST number.'
            }
            else {
                this.lwcError = null;
            }
            var data = {
                Step_ContactDetails: {
                    gstType: this.gstTypeValue,
                    lwcError: this.lwcError
                }
            };
            this.omniApplyCallResp(data);
            this.details['gstType'] = this.gstTypeValue;
            this.details['standardReason'] = this.standardReasonValue;
            this.details['gstSelectedValue'] = null;
            this.details['lwcError'] = this.lwcError;
            this.dispatchEvent(new CustomEvent('standardvalue', { detail: this.details }));

        }
        catch (error) {
            console.error(error);
            this.showNotification('Error', error.message, 'error');
        }
    }

    handleSelectedGst(event) {
        try {
            this.gstSelectedValue = event.detail.value;
            if (this.gstSelectedValue && this.gstSelectedValue !== '') {
                var data = {
                    Step_ContactDetails: {
                        gstSelectedValue: this.gstSelectedValue,
                        lwcError: null
                    }
                };
                this.omniApplyCallResp(data);
            }
            this.details['gstSelectedValue'] = this.gstSelectedValue;
            this.dispatchEvent(new CustomEvent('gstselectedvalue', { detail: this.details }));
        }
        catch (error) {
            console.error(error);
            this.showNotification('Error', error.message, 'error');
        }
    }

    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}