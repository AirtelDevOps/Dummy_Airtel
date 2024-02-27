import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { CurrentPageReference } from 'lightning/navigation';
import accountTemplate from "./accountTemplate.html";
import leadTemplate from "./leadTemplate.html";
import hasKAMGeneralUser from '@salesforce/customPermission/ARTL_KAM_General_User';
import hasKAMTLUser from '@salesforce/customPermission/ARTL_KAMTL_User';
import hasSalesOps from '@salesforce/customPermission/ARTL_SalesOps';

import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import USER_PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';

import ACCOUNT_RECORD_TYPE_FIELD from '@salesforce/schema/Account.RecordType.Name';
import ACCOUNT_STATUS_FIELD from '@salesforce/schema/Account.vlocity_cmt__Status__c';
import ACCOUNT_IDENTIFICATION_TYPE_FIELD from '@salesforce/schema/Account.ARTL_Identification_Type__c';
import ACCOUNT_IS_PAN_VERIFIED_FIELD from '@salesforce/schema/Account.ARTL_IsPANVerified__c';
import ACCOUNT_PAN_FIELD from '@salesforce/schema/Account.ARTL_PAN__c';


import LEAD_STATUS_FIELD from '@salesforce/schema/Lead.Status';
import LEAD_OWNER_CHECK_FIELD from '@salesforce/schema/Lead.ARTL_Account_Owner_Equals_Lead_Owner__c';


const LEAD = 'Lead';
const ACCOUNT = 'Account';

export default class ARTL_MobileButtons extends NavigationMixin(LightningElement) {

    @api recordId;
    @api objectApiName;

    @track error;
    @track userId = Id;
    @track currentUserProfile;

    
    showGst                 = false;
    showCreateNba           = false;
    showAccountComponents   = false;
    showLeadComponents      = false;
    showConvertLead         = false;
    showAssignToKAM         = false;
    launchFlow              = false;

    accountRecordTypeName;
    accountStatus;
    isPANVerified;
    panValue;
    identificationType;
    leadStatus;
    leadOwnerEqualsAccountOwner;
    editRecordform;
    
    get kamOrTLUser() {
        var kamUser = hasKAMGeneralUser !== undefined ? true : false;
        var kamTLUser = hasKAMTLUser !== undefined ? true : false;
        console.log('DEBUGG kamOrTLUser ', kamUser);
        console.log('DEBUGG kamTLUser ', kamTLUser);
        return kamUser || kamTLUser;
    }

    get isSalesOps() {
        console.log('DEBUGG hasSalesOps ', hasSalesOps);
        return hasSalesOps !== undefined ? true : false;
    }

    get isKAMorSalesOpsOrSystemAdmin() {
        console.log('DEBUGG isKAMorSalesOpsOrSystemAdmin ', this.kamOrTLUser || this.isSalesOps || this.isAdmin);
        return this.kamOrTLUser || this.isSalesOps || this.isAdmin;
    }

    get isAdmin() {
        console.log('DEBUGG isAdmin ', this.currentUserProfile === 'System Administrator');
        return this.currentUserProfile === 'System Administrator';
    }

    get isSalesOpsOrAdmin() {
        console.log('DEBUGG isSalesOpsOrAdmin ', this.isSalesOps || this.isAdmin);
        return this.isSalesOps || this.isAdmin;
    }

    get isKAMOrAdmin() {
        console.log('DEBUGG isKAMOrAdmin', this.isAdmin || this.kamOrTLUser);
        return this.isAdmin || this.kamOrTLUser;
    }

    get isActiveBillingAggregatorAccount() {
        console.log('DEBUGG isActiveBillingAggregatorAccount ', this.accountStatus === 'Active' && this.accountRecordTypeName === 'Billing Aggregator');

        return this.accountStatus === 'Active' && this.accountRecordTypeName === 'Billing Aggregator';
    }

    get isActiveBusinessAccount() {
        console.log('DEBUGG isActiveBusinessAccount ', this.accountStatus === 'Active' && this.accountRecordTypeName === 'Business');

        return this.accountStatus === 'Active' && this.accountRecordTypeName === 'Business';
    }

    get isActiveBillingAggregatorOrBusiness() {
        console.log('DEBUGG isActiveBillingAggregatorOrBusiness ', this.isActiveBillingAggregatorAccount || this.isActiveBusinessAccount);

        return this.isActiveBillingAggregatorAccount || this.isActiveBusinessAccount;
    }


    get editRecord() {
        console.log('DEBUGG editRecord ', (((this.isSalesOpsOrAdmin) || ((this.kamOrTLUser) && this.accountStatus !== 'Active' && this.accountStatus !== 'Approved')) && this.accountRecordTypeName === 'Business') || this.accountRecordTypeName === 'Billing Aggregator');
        return (((this.isSalesOpsOrAdmin) || ((this.kamOrTLUser) && this.accountStatus !== 'Active' && this.accountStatus !== 'Approved')) && this.accountRecordTypeName === 'Business') || this.accountRecordTypeName === 'Billing Aggregator';
    }

    get isAccountStatusActiveorApproved() {
        console.log('DEBUGG isAccountStatusActiveorApproved ', this.accountStatus === 'Approved' || this.accountStatus === 'Active');

        return this.accountStatus === 'Approved' || this.accountStatus === 'Active';
    }

    get submitForApproval(){
        console.log('DEBUGG isSubmitForApproval ', this.accountStatus === 'Unapproved' || this.accountStatus === 'Rejected');

        return (this.accountStatus === 'Unapproved' || this.accountStatus === 'Rejected') && this.accountRecordTypeName === 'Business';
    }
    get gstVisibleForBusinessAccountAndUser() {
        console.log('DEBUGG gstvisibleForBusinessAccountAndUser ', this.accountRecordTypeName === 'Business'   && this.isAccountStatusActiveorApproved  && (this.isSalesOps || this.kamOrTLUser));

        return this.accountRecordTypeName === 'Business' && this.isAccountStatusActiveorApproved && (this.isSalesOps || this.kamOrTLUser);
    }

    get nbaVisibleForBusinessAccountAndUser() {
        console.log('DEBUGG nbaVisibleForBusinessAccountAndUser ', this.isActiveBusinessAccount  && this.isAccountStatus === 'Approved' && this.isSalesOpsOrAdmin);

        return this.accountRecordTypeName === 'Business' && this.isAccountStatusActiveorApproved && this.isSalesOpsOrAdmin;
    }

    get validatePan(){
        var panLength = (this.panValue !== undefined && this.panValue !== null)  ? this.panValue.length : 0;
        return  this.accountRecordTypeName === 'Business'  && this.isPANVerified === false && this.identificationType === 'PAN' && panLength > 0;
    }

    get isLeadStatusQualified() {
        console.log('DEBUGG isLeadStatusQualified ', this.leadStatus === 'Qualified');
        return this.leadStatus === 'Qualified';
    }

    get leadQualifiedAndKAMUser() {
        console.log('DEBUGG leadQualifiedAndKAMUser ', this.isLeadStatusQualified && this.isKAMOrAdmin);
        return this.isLeadStatusQualified && this.isKAMOrAdmin;
    }

    get showAccountMenu(){
        return this.gstVisibleForBusinessAccountAndUser || this.nbaVisibleForBusinessAccountAndUser || this.validatePan || this.submitForApproval || this.isAccountStatusActiveorApproved;
        }

    get showLeadMenu(){
        return this.isLeadQualifiedAndOwnerNotEqual || this.leadQualifiedAndKAMUser ;
    }

    get isLeadQualifiedAndOwnerNotEqual() {
        return !this.leadOwnerEqualsAccountOwner && this.isLeadStatusQualified;
    }
    get prefill() {
        console.log('DEBUGG prefill ', this.recordId);
        return JSON.stringify({ "ContextId": this.recordId });
    }

    get inputVariables() {
        return [
            {
                name: 'recordId',
                type: 'String',
                value: this.recordId
            }
        ];
    }

    @wire(getRecord, { recordId: Id, fields: [USER_PROFILE_NAME_FIELD] })
    currentUserInfo({ error, data }) {
        if (data) {
            console.log('DEBUGG currentUserInfo ', data.fields);
            this.currentUserProfile = data.fields.Profile.displayValue;
        } else if (error) {
            this.error = error;
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: [ACCOUNT_RECORD_TYPE_FIELD, ACCOUNT_STATUS_FIELD,ACCOUNT_IDENTIFICATION_TYPE_FIELD,ACCOUNT_IS_PAN_VERIFIED_FIELD,ACCOUNT_PAN_FIELD ] })
    getAccountRecord({ data, error }) {
        if (data) {
            console.log('DEBUGG 1 getAccountRecord ', data);
            this.accountRecordTypeName = data.fields.RecordType.displayValue;
            this.accountStatus = data.fields.vlocity_cmt__Status__c?.value;
            this.isPANVerified = data.fields.ARTL_IsPANVerified__c?.value;
            this.identificationType = data.fields.ARTL_Identification_Type__c?.value;
            this.panValue = data.fields.ARTL_PAN__c?.value;
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: [LEAD_STATUS_FIELD, LEAD_OWNER_CHECK_FIELD] })
    getLeadRecord({ data, error }) {
        if (data) {
            console.log('DEBUGG 1 getLeadRecord ', data);
            this.leadStatus = data.fields.Status?.value;
            this.leadOwnerEqualsAccountOwner = data.fields.ARTL_Account_Owner_Equals_Lead_Owner__c?.value;
        }
    }

    render() {
        return this.showAccountComponents ? accountTemplate : leadTemplate;
    }

    handleFlowStatusChange(event) {
        console.log('DEBUGG handleFlowStatusChange ', event);
        if (event.detail.status === 'FINISHED' && event.detail.outputVariables) {
            this.message = event.detail;
        }
        else if(event.detail.status === "ERROR") {
            this.showToast("error","Please check if you have entered all details","error");
        }
    }

    connectedCallback() {
        console.log('DEBUGG ARTL_MobileButtons ', this.recordId);
        console.log('DEBUGG ARTL_MobileButtons ', this.objectApiName);
        console.log('DEBUGG ARTL_MobileButtons hasKAMGeneralUser ', hasKAMGeneralUser);
        console.log('DEBUGG ARTL_MobileButtons isKAMUser ', this.isKAMUser);
        
        if (this.objectApiName === ACCOUNT) {
            this.checkObject(true, false);
        }
        if (this.objectApiName === LEAD) {
            this.checkObject(false, true);
        }
    }

    checkObject(accountboolean, leadBoolean) {
        this.showAccountComponents = accountboolean;
        this.showLeadComponents = leadBoolean;
    }
    
    handleNavigate(componentName) {
        console.log('DEBUGG handleNavigate ', componentName);
        var compDefinition = {
            componentDef: componentName,
            attributes: {
                recordId: this.recordId
            }
        };
        var encodedCompDef = btoa(JSON.stringify(compDefinition));
        console.log('DEBUGG handleNavigate compDefinition ', compDefinition);
        console.log('DEBUGG handleNavigate encodedCompDef', encodedCompDef);
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/one/one.app#' + encodedCompDef
            }
        });
    }


    handleClose() {
        
        this.showGst = false;
        this.showCreateNba = false;
        this.showConvertLead = false;
        this.showAssignToKAM = false;
        this.launchFlow = false;
        this.editRecordform = false;
    }

    handleNavigateToOmniscript(componentName) {
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: 'vlocity_cmt__vlocityLWCOmniWrapper',
            },
            state: {
                c__target: componentName,
                c__layout: 'lightning',
                c__tabIcon: 'custom:custom18',
                c__tabLabel: 'InvoiceDetails',
                c__ContextId: this.recordId
            }
        })
    }

    navigateToClickToCall() {
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: 'vlocity_cmt__vlocityLWCOmniWrapper',
            },
            state: {
                c__target: 'c:aRTLClickToCallEnglish',
                c__layout: 'lightning',
                c__tabIcon: 'custom:custom18',
                c__tabLabel: 'InvoiceDetails',
                c__ContextId: this.recordId,
                c__processName: 'ClickToCall'
            }
        })
    }

    handleClick(event) {
        console.log('handleClick', event.target.name, event.target.value);
        try {
            switch (event.target.name) {
                case 'addGst':
                    this.handleNavigateToOmniscript('c:aRTLAddGSTEnglish');
                    break;

                case 'createNba':
                    this.handleNavigateToOmniscript('c:aRTLCreateNBAEnglish');
                    break;

                case 'createBcpDcp':
                    this.handleNavigateToOmniscript('c:aRTLTestCreateBCP2English');
                    break;

                case 'createAndViewSR':
                    this.handleNavigate('c:atbAirtelButton'); 
                    break;

                case 'getInvoiceDetails':
                    this.handleNavigateToOmniscript('c:aRTLInvoiceDetailsEnglish');
                    break;
                
                case 'submitApproval':
                    this.launchFlow = true;
                    break;
                
                case 'editRec':
                    this.editRecordform=true;
                    break;

                case 'validatePAN':
                    this.handleNavigateToOmniscript('c:aRTLCalloutEventEnglish');
                    break;
            }
        }
        catch (error) {
            console.error(error);
            this.showNotification('Error', error.message, 'error');
        }
    }


    handleLeadClick(event) {
        console.log('handleLeadClick ', event.target.name, event.target.value);
        try {
            switch (event.target.name) {
                case 'clickToCall':
                    this.navigateToClickToCall();
                    break;

                case 'convertLead':
                    this.handleNavigateToOmniscript('c:aRTLLeadConversionEnglish');
                    break;

                case 'assignToKAM':
                    this.showAssignToKAM = true;
                    break;
            }
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