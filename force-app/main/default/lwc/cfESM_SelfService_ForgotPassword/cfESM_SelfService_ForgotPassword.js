import { FlexCardMixin } from "vlocity_cmt/flexCardMixin";
    import { CurrentPageReference } from 'lightning/navigation';
    import {interpolateWithRegex, interpolateKeyValue, loadCssFromStaticResource } from "vlocity_cmt/flexCardUtility";
    
          import { LightningElement, api, track, wire } from "lwc";
          import pubsub from "vlocity_cmt/pubsub";
          import { getRecord } from "lightning/uiRecordApi";
          
          import data from "./definition";
          
          import styleDef from "./styleDefinition";
              
          export default class cfESM_SelfService_ForgotPassword extends FlexCardMixin(LightningElement){
              currentPageReference;        
              @wire(CurrentPageReference)
              setCurrentPageReference(currentPageReference) {
                this.currentPageReference = currentPageReference;
              }
              @api debug;
              @api recordId;
              @api objectApiName;
              
              @track record;
              
              @track Label={CMEXSelfServiceUsername:"Username",
        CMEXSelfServiceContinueToLogin:"Continue to Login",
        CMEXSelfServiceEmailSentInfo:"Instructions to reset your password have been successfully sent to your registered email.",
        CMEXSelfServiceEmailSent:"Email Sent",
        CMEXSelfServiceRecoverPassword:"Recover Password",
        CMEXSelfServiceCancel:"Cancel",
        CMEXSelfServicePasswordRecoveryFailed:"Password Recovery Failed",
        CMEXSelfServiceMissingUsernameError:"Please enter username",
        CMEXSelfServiceMissingRequiredField:"Required Field is missing",
        CMEXSelfServiceForgotPasswordInfo:"Please enter the email registered with us and we'll send you a link to reset your password."
        };
              pubsubEvent = [];
              customEvent = [];
              
              connectedCallback() {
                super.connectedCallback();
                this.setStyleDefinition(styleDef);
                data.Session = {} //reinitialize on reload
                
                
                this.customLabels = this.Label;
                      
                this.setDefinition(data);
 this.registerEvents();
                this.setAttribute(
                  "class",
                  "card-a5aHn00000I0sb9AAM"
                );
                this.loadCustomStylesheetAttachement("00PHn00001vRZSAEAH");
                
                
              }
              
              disconnectedCallback(){
                super.disconnectedCallback();
                    
                    

                  this.unregisterEvents();
              }

              registerEvents() {
                
              }

              unregisterEvents(){
                
              }
            
              renderedCallback() {
                super.renderedCallback();
                
              }
          }