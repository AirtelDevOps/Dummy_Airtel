import { LightningElement, api, wire, track } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import { CurrentPageReference } from 'lightning/navigation';

import CONTACT_PREMISE_RELATION_OBJECT from '@salesforce/schema/ContactPremiseRelation__c';
import GST_APPLICABLE_FIELD from '@salesforce/schema/ContactPremiseRelation__c.ARTL_GST_Applicable__c';
import STANDARD_REASON_FIELD from '@salesforce/schema/ContactPremiseRelation__c.ARTL_Standard_Reason__c';

import getContactRecords from '@salesforce/apex/ARTL_UpdateBcpDcpLwcController.getContactRecords';
import getRecordDetails from '@salesforce/apex/ARTL_UpdateBcpDcpLwcController.getRecordDetails';
import updateRecords from '@salesforce/apex/ARTL_UpdateBcpDcpLwcController.updateRecords';

import regexPatternValidationLwc from '@salesforce/apex/ARTL_verifyInputPattern.regexPatternValidationLwc';
import { NavigationMixin } from 'lightning/navigation';




export default class ARTL_updateBcpDcpLwc extends NavigationMixin(LightningElement){ //OmniscriptBaseMixin(LightningElement) {
    @track columns = [
        { label: 'BCP/DCP String', fieldName: 'ARTL_BCP_DCP_Search_String__c', type: 'text', initialWidth: 885 }
    ];

    @api recordId;
    @track data;

    currentStep = '1';
    error = false;

    showDatatable = true;
    showDetails = false;
    showAddress = false;
    showPrevious = false;

    selectedRecordId;

    //Values
    salutationValue;
    firstNameValue;
    middleNameValue;
    lastNameValue;
    emailAddressValue;
    phoneValue;
    roleValue;
    alternateEmailValue;
    faxValue;
    gstApplicableValue = null;
    standardReasonValue = null;
    gstSelectedValue = null;
    designationValue;
    statusValue;

    contactRecordOld;
    contactRecordUpdate;
    gstApplicableOptions;
    standardReasonOptions;

    NextButtonLabel = 'Next';

    addressDetails;
    stateValue;
    nbaAccountIdValue;
    gstNumber;
    gstId;

    lwcError;

    gstTypeSez = ['SEZ', 'SEZ with taxes'];
    gstTypeNonSez = ['Non-SEZ', 'Zero Rated Supply- FTWZ', 'Non Taxable as transactions within same Company'];

    gstTypeValue;

    isLoading = false;

    get salutationOptions() {
        return [
            { label: 'Mr.', value: 'Mr.' },
            { label: 'Ms.', value: 'Ms.' },
            { label: 'Mrs.', value: 'Mrs.' },
        ];
    }
    get roleOptions() {
        return [
            { label: 'BCP', value: 'BCP' },
            { label: 'DCP', value: 'DCP' },
            { label: 'BCP and DCP', value: 'BCPandDCP' },
        ];
    }

    get statusOptions() {
        return [
            { label: 'Active', value: 'Active' },
            { label: 'Inactive', value: 'Inactive' },
        ];
    }

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
        }
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference && this.recordId === undefined) {
            this.recordId = currentPageReference.state.recordId;
        }
    }

    handleNext() {
        try {
            switch (this.currentStep) {
                // case "1":
                //     if (this.selectedRecordId && this.selectedRecordId != undefined) {
                //         this.getRecordDetails();
                //         this.manageViews(false, true, false);
                //         this.currentStep = "2";
                //         this.showPrevious = true;
                //     }
                //     else {
                //         this.showNotification('', 'Please select a record.', 'error');
                //     }
                //     break;

                case "1":

                    const allValid = [
                        ...this.template.querySelectorAll('lightning-input'),
                    ].reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
                    }, true);
                    if (allValid) {
                        this.NextButtonLabel = 'Update Record';
                        this.currentStep = "2";
                        this.showPrevious = true;
                        this.manageViews(false, false, true);
                    } else {
                        this.showNotification('', 'Please update the invalid form entries and try again.', 'error');
                    }
                    break;
                case "2":
                    this.showPrevious = true;
                    this.updateRecords();
                    break;

            }
        }
        catch (error) {
            console.error(error);
            this.showNotification('Error', error.message, 'error');
        }
    }

    handlePrevious() {
        switch (this.currentStep) {
            case "2":
                this.currentStep = "1";
                this.NextButtonLabel = 'Next';
                this.showPrevious = false;
                this.manageViews(false, true, false);
                break;
            case "1":
                // this.currentStep = "1";
                this.NextButtonLabel = 'Next';
                this.manageViews(true, false, false);
                break;
        }
    }

    manageViews(showDatatableBoolean, showDetailsBoolean, showAddressBoolean) {
        this.showDatatable = showDatatableBoolean;
        this.showDetails = showDetailsBoolean;
        this.showAddress = showAddressBoolean;
    }


    connectedCallback() {
        console.log('DEBUGG connectedCallback recordId ', this.recordId);
        // if (this.recordId) {
        //     this.fetchContactRecordUpdates();
        // }
        if (this.recordId) {
            this.selectedRecordId = this.recordId;
            this.manageViews(false, true, false);
            this.getRecordDetails();
        }
    }

    getRecordDetails() {
        getRecordDetails({ selectedRecordId: this.selectedRecordId })
            .then((result) => {
                this.contactRecordUpdate = result.map((element) => ({
                    'Id': element.Contact__c,
                    'Role__c': element.Role__c,
                    'ContactPremiseId': element.Id,
                    'ARTL_GST_Applicable__c': element.ARTL_GST_Applicable__c,
                    'Salutation': element.Contact__r.Salutation,
                    'FirstName': element.Contact__r.FirstName,
                    'MiddleName': element.Contact__r.MiddleName,
                    'LastName': element.Contact__r.LastName,
                    'Email': element.Contact__r.Email,
                    'Phone': element.Contact__r.Phone,
                    'vlocity_cmt__Status__c': element.Contact__r.vlocity_cmt__Status__c,
                    'ARTL_Alternate_Email__c': element.Contact__r.ARTL_Alternate_Email__c,
                    'Fax': element.Contact__r.Fax,
                    'ARTL_Standard_Reason__c': element.ARTL_Standard_Reason__c,
                    'ARTL_Designation__c': element.Contact__r.ARTL_Designation__c,
                    'Premises__c': element.Premises__c,
                    'ARTL_NBA_Account__c': element.ARTL_NBA_Account__c,
                    'BusinessAccountId': element.ARTL_NBA_Account__r.ParentId,
                    'StreetAddress': element.Premises__r.vlocity_cmt__StreetAddress__c,
                    'City': element.Premises__r.vlocity_cmt__City__c,
                    'State': element.Premises__r.vlocity_cmt__State__c,
                    'PostalCode': element.Premises__r.vlocity_cmt__PostalCode__c,
                    'Country': element.Premises__r.vlocity_cmt__Country__c,
                    'GST__c': element.GST__c,
                    'GST_Number': element.GST__r?.Name,
                    'ARTL_Pincode__c': element.Premises__r.ARTL_Pincode__c
                }));

                this.salutationValue = this.contactRecordUpdate[0]['Salutation'];
                this.firstNameValue = this.contactRecordUpdate[0]['FirstName'];
                this.middleNameValue = this.contactRecordUpdate[0]['MiddleName'];
                this.lastNameValue = this.contactRecordUpdate[0]['LastName'];
                this.emailAddressValue = this.contactRecordUpdate[0]['Email'];
                this.phoneValue = this.contactRecordUpdate[0]['Phone'];
                this.roleValue = this.contactRecordUpdate[0]['Role__c'];
                this.alternateEmailValue = this.contactRecordUpdate[0]['ARTL_Alternate_Email__c'];
                this.faxValue = this.contactRecordUpdate[0]['Fax'];
                this.gstApplicableValue = this.contactRecordUpdate[0]['ARTL_GST_Applicable__c'];
                this.standardReasonValue = this.contactRecordUpdate[0]['ARTL_Standard_Reason__c'];
                this.designationValue = this.contactRecordUpdate[0]['ARTL_Designation__c'];
                this.stateValue = this.contactRecordUpdate[0]['State'];
                this.nbaAccountIdValue = this.contactRecordUpdate[0]['ARTL_NBA_Account__c'];
                this.gstNumber = this.contactRecordUpdate[0]['GST_Number'];
                this.statusValue = this.contactRecordUpdate[0]['vlocity_cmt__Status__c'];
                this.gstId = this.contactRecordUpdate[0]['GST__c'];
                
                this.addressDetails = {
                    "StreetAddress": this.contactRecordUpdate[0]['StreetAddress'],
                    "City": this.contactRecordUpdate[0]['City'],
                    "State": this.contactRecordUpdate[0]['State'],
                    "PostalCode": this.contactRecordUpdate[0]['PostalCode'],
                    "Country": this.contactRecordUpdate[0]['Country'],
                    "PincodeCity": this.contactRecordUpdate[0]['PostalCode'] + ' - ' + this.contactRecordUpdate[0]['City'], 
                    "ARTL_Pincode__c": this.contactRecordUpdate[0]['ARTL_Pincode__c']
                }
                
                if (this.gstTypeSez.includes(this.standardReasonValue)) {
                    this.contactRecordUpdate[0]['GST_Type'] = 'SEZ';
                }
                else if (this.gstTypeNonSez.includes(this.standardReasonValue)) {
                    this.contactRecordUpdate[0]['GST_Type'] = 'Non-SEZ';
                }
                else if (this.standardReasonValue === 'UIN') {
                    this.contactRecordUpdate[0]['GST_Type'] = 'UIN';
                }
                else {
                    this.contactRecordUpdate[0]['GST_Type'] = '';
                }

                this.gstTypeValue = this.contactRecordUpdate[0]['GST_Type'];
                this.contactRecordOld = JSON.parse(JSON.stringify(this.contactRecordUpdate));
            })
            .catch((error) => {
                console.error('error', error);
                this.showNotification('Error', error.message, 'error');
            })
    }

    handleChange(event) {
        try {
            switch (event.target.name) {
                case 'salutation':
                    this.salutationValue = event.detail.value;
                    this.contactRecordUpdate[0]['Salutation'] = this.salutationValue;
                    break;

                case 'firstName':
                    this.firstNameValue = event.detail.value;
                    this.contactRecordUpdate[0]['FirstName'] = this.firstNameValue;
                    break;

                case 'middleName':
                    this.middleNameValue = event.detail.value;
                    this.contactRecordUpdate[0]['MiddleName'] = this.middleNameValue;
                    break;

                case 'lastName':
                    this.lastNameValue = event.detail.value;
                    this.contactRecordUpdate[0]['LastName'] = this.lastNameValue;
                    break;

                case 'email':
                    this.emailAddressValue = event.detail.value;
                    this.contactRecordUpdate[0]['Email'] = this.emailAddressValue;
                    break;

                case 'phone':
                    this.phoneValue = event.detail.value;
                    this.contactRecordUpdate[0]['Phone'] = this.phoneValue;
                    break;

                case 'role':
                    this.roleValue = event.detail.value;
                    this.contactRecordUpdate[0]['Role__c'] = this.roleValue;
                    break;

                case 'alternateEmail':
                    this.alternateEmailValue = event.detail.value;
                    this.contactRecordUpdate[0]['ARTL_Alternate_Email__c'] = this.alternateEmailValue;
                    break;

                case 'fax':
                    this.faxValue = event.detail.value;
                    this.contactRecordUpdate[0]['Fax'] = this.faxValue;
                    break;

                case 'designation':
                    this.designationValue = event.detail.value;
                    var pattern = '[a-zA-Z0-9 \\-.&/\']*';
                    var inputComponent = this.template.querySelector('[data-element="designation"]');
                    regexPatternValidationLwc({
                        inputString: this.designationValue,
                        regexPattern: pattern
                    })
                        .then((result) => {
                            if (!result) {
                                inputComponent.setCustomValidity("Designation should not contain any Special Characters except ./'");
                            }
                            else {
                                inputComponent.setCustomValidity("");
                                this.contactRecordUpdate[0]['ARTL_Designation__c'] = this.designationValue;
                            }
                        })
                        .catch((error) => {
                            console.error(error);
                            this.showNotification('Error', 'Error occurred.', 'error');
                        })

                    break;

                case 'status':
                    this.statusValue = event.detail.value;
                    this.contactRecordUpdate[0]['vlocity_cmt__Status__c'] = this.statusValue;
                    break;

            }
        }
        catch (error) {
            console.error(error);
            console.error(error.message);
            this.showNotification('Error', 'Error occurred.', 'error');
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

    updateRecords() {
        var blockUpdate = false;

        if (this.contactRecordUpdate[0]['ARTL_GST_Applicable__c'] === null) {
            this.contactRecordUpdate[0]['ARTL_GST_Applicable__c'] = this.contactRecordOld[0]['ARTL_GST_Applicable__c'];
        }
        if (this.contactRecordUpdate[0]['ARTL_GST_Applicable__c'] === null || this.contactRecordUpdate[0]['ARTL_Standard_Reason__c'] === null ||
            this.contactRecordUpdate[0]['StreetAddress'] === null) {
            this.showNotification('Error', 'Please fill in the required fields.', 'error');
            blockUpdate = true;
        }
        if (this.lwcError && this.gstSelectedValue === null) {
            this.showNotification('Error', this.lwcError, 'error');
            blockUpdate = true;
        }

        if (
            (this.contactRecordOld[0]['ARTL_Standard_Reason__c'] === 'Non-SEZ' && ['SEZ', 'UIN'].includes(this.contactRecordUpdate[0]['ARTL_Standard_Reason__c'])) ||
            (this.contactRecordOld[0]['ARTL_Standard_Reason__c'] === 'SEZ' && ['Non-SEZ', 'UIN'].includes(this.contactRecordUpdate[0]['ARTL_Standard_Reason__c'])) ||
            (this.contactRecordOld[0]['ARTL_Standard_Reason__c'] === 'UIN' && ['SEZ', 'Non-SEZ'].includes(this.contactRecordUpdate[0]['ARTL_Standard_Reason__c']))
        ) {
            this.showNotification('Error', 'Standard Reason can not be changed from Non-SEZ to SEZ, SEZ to Non-SEZ, Non-SEZ to UIN, UIN to Non-SEZ, SEZ to UIN, UIN to SEZ.', 'error');
            blockUpdate = true;
        }

        if (this.gstSelectedValue === null) {
            this.contactRecordUpdate[0]['GST__c'] = null;
        }

        if (this.contactRecordOld[0]['City'] !== this.contactRecordUpdate[0]['City']) {
            this.showNotification('Error', 'Updated pincode should be of the same city.', 'error');
            blockUpdate = true;
        }

        if (this.contactRecordUpdate[0]['GST_Type'] !== this.contactRecordOld[0]['GST_Type']) {
            this.showNotification('Error', 'GST number cannot be updated to a new GST number where GST\'s state and GST Type are different than the previously associated with BCP/DCP.', 'error');
            blockUpdate = true;
        }
        if (!blockUpdate) {
            this.isLoading = true;
            console.log('DEBUGG update ', this.contactRecordUpdate[0]);
            updateRecords({
                recordDetailsOld: this.contactRecordOld[0],
                recordDetails: this.contactRecordUpdate[0]
            })
                .then((result) => {
                    this.showNotification('Success', 'Success updated records.', 'Success');
                    this.closeQuickAction(this.selectedRecordId);
                })
                .catch((error) => {
                    this.isLoading = false;
                    console.error('Update Records error', error);
                    this.showNotification('Error', error.message, 'error');
                });
        }

    }

    closeQuickAction(selectedRecordId) {
        this.dispatchEvent(new CloseActionScreenEvent());
        // window.location.reload();
        // Navigate to View Account Page
        
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: selectedRecordId,
                    objectApiName: 'ContactPremiseRelation__c',
                    actionName: 'view'
                },
            });
        
    }

    addressUpdated(event) {
        try {
            if (event?.detail) {
                let address = event.detail;
                this.addressDetails = JSON.parse(JSON.stringify(event.detail));
                this.contactRecordUpdate[0]['StreetAddress'] = address['StreetAddress'];
                this.contactRecordUpdate[0]['City'] = address['City'];
                this.contactRecordUpdate[0]['State'] = address['State'];
                this.contactRecordUpdate[0]['PostalCode'] = address['PostalCode'];
                this.contactRecordUpdate[0]['Country'] = address['Country'];
                this.contactRecordUpdate[0]['ARTL_Pincode__c'] = address['ARTL_Pincode__c'];
            }
        }
        catch (error) {
            console.error(error);
            this.showNotification('Error', error.message, 'error');
        }
    }

    gstValueUpdated(event) {
        try {
            if (event?.detail) {
                if (event.detail['standardReason'] !== null) {
                    this.standardReasonValue = this.contactRecordUpdate[0]['ARTL_Standard_Reason__c'] = event.detail['standardReason'];
                }
                if (event.detail['gstApplicable'] !== null) {
                    this.gstApplicableValue = this.contactRecordUpdate[0]['ARTL_GST_Applicable__c'] = event.detail['gstApplicable'];
                }
                if (event.detail['gstType'] !== null) {
                    this.gstTypeValue = this.contactRecordUpdate[0]['GST_Type'] = event.detail['gstType'];
                }
                this.gstSelectedValue = this.contactRecordUpdate[0]['GST__c'] = event.detail['gstSelectedValue'];
            }
            console.log('DEBUGG this.gstSelectedValue ', this.gstSelectedValue);
        }
        catch (error) {
            console.error(error);
            this.showNotification('Error', error.message, 'error');
        }
    }

    handleStandardValue(event) {
        try {
            if (event?.detail) {
                if (event.detail['standardReason'] !== null) {
                    this.standardReasonValue = this.contactRecordUpdate[0]['ARTL_Standard_Reason__c'] = event.detail['standardReason'];
                }
              
                if (event.detail['gstApplicable'] !== null) {
                    this.gstApplicableValue = this.contactRecordUpdate[0]['ARTL_GST_Applicable__c'] = event.detail['gstApplicable'];
                }

                if (event.detail['gstType'] !== null) {
                    this.gstTypeValue = this.contactRecordUpdate[0]['GST_Type'] = event.detail['gstType'];
                }
                this.gstSelectedValue = this.contactRecordUpdate[0]['GST__c'] = null;
                this.lwcError = event.detail['lwcError'];
                // this.gstType();
            }
        }
        catch (error) {
            console.error(error);
            this.showNotification('Error', error.message, 'error');
        }
    }

    gstType() {
        try {
            if (this.gstTypeSez.includes(this.standardReasonValue)) {
                this.contactRecordUpdate[0]['GST_Type'] = 'SEZ';
            }
            else if (this.gstTypeNonSez.includes(this.standardReasonValue)) {
                this.contactRecordUpdate[0]['GST_Type'] = 'Non-SEZ';
            }
            else if (this.standardReasonValue === 'UIN') {
                this.contactRecordUpdate[0]['GST_Type'] = 'UIN';
            }
            else {
                this.contactRecordUpdate[0]['GST_Type'] = '';
            }

        }
        catch (error) {
            console.error(error);
            this.showNotification('Error', error.message, 'error');
        }
    }

}