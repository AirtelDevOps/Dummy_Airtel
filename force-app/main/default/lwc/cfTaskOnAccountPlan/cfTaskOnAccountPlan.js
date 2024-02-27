import { FlexCardMixin } from "vlocity_cmt/flexCardMixin";
    import { CurrentPageReference } from 'lightning/navigation';
    import {interpolateWithRegex, interpolateKeyValue, loadCssFromStaticResource } from "vlocity_cmt/flexCardUtility";
    
          import { LightningElement, api, track, wire } from "lwc";
          import pubsub from "vlocity_cmt/pubsub";
          import { getRecord } from "lightning/uiRecordApi";
          
          import data from "./definition";
          
          import styleDef from "./styleDefinition";
              
          export default class cfTaskOnAccountPlan extends FlexCardMixin(LightningElement){
              currentPageReference;        
              @wire(CurrentPageReference)
              setCurrentPageReference(currentPageReference) {
                this.currentPageReference = currentPageReference;
              }
              @api debug;
              @api recordId;
              @api objectApiName;
              
              @track record;
              @track _sessionApiVars = {};
        @api set cfRecordId(val) {
          if(typeof val !== "undefined") {
            this._sessionApiVars["RecordId"] = val;
          }
        } get cfRecordId() {
          return this._sessionApiVars["RecordId"] || "";
        }
      
              
              pubsubEvent = [];
              customEvent = [];
              
              connectedCallback() {
                super.connectedCallback();
                this.setThemeClass(data);
                this.setStyleDefinition(styleDef);
                data.Session = {} //reinitialize on reload
                
                      loadCssFromStaticResource(this, "WrappedHeaderTable", "/assets/styles/salesforce-lightning-design-system-vf.min.css").then(() => {
                      this.setDefinition(data);
                      this.isProcessing = false;
                      this.registerEvents();
                      }).catch(() => {
                      this.setDefinition(data);
                      this.registerEvents();
                    });
                
                
                
                this.setAttribute(
                  "class", (this.getAttribute("class") ? this.getAttribute("class") : "") +
                  " card-0ko7200000007HeAAI"
                );
                this.loadCustomStylesheetAttachement("00P72000004o9dmEAA");
                
                
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