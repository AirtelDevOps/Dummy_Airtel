import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import { getDataHandler } from "vlocity_cmt/utility";
import { invokeDR } from "vlocity_cmt/b2bUtils";
import LightningModal from 'lightning/modal';

const columns = [
  { label: 'Street Address', fieldName: 'vlocity_cmt__StreetAddress__c' },
  { label: 'City', fieldName: 'vlocity_cmt__City__c' },
  { label: 'State', fieldName: 'vlocity_cmt__State__c' },
  { label: 'Country', fieldName: 'vlocity_cmt__Country__c' },
  { label: 'Pin code', fieldName: 'vlocity_cmt__PostalCode__c'},
];
export default class ArtlUploadLocations extends NavigationMixin(LightningElement) {
  @api recordId ;
  errorMsg = '';
  showerror = false;
  torender=true;
  showDownloadScreen = true;
  @track data = [];
  columns = columns;
  showform = false;
  rowOffset = 0;
  showPopup = true;
  @track selectedData = [];
  savedquotemembers = [];
  address = '';
  @track pinObj = {};
  @track pincodeoptions = [];
  pincodes = [];
  pincode = '';

  isAddLocaButnClick =false;
  
  connectedCallback() {
    console.log('connected cllbck');
    if(this.recordId == undefined){
      this.recordId = this.getUrlParams('c__cartId');
    }
    this.showPopup = true;
    this.getLocations();
    this.getPincodes();
  }

  getUrlParams(param) {
    const queryString = window.location.search;
    const urlParams = new URLSearchParams(queryString);
    return urlParams.get(param);
  } 

  get options() {
    return this.pincodeoptions;
  }

  get showsave(){
    if(this.pinObj!='' && this.pinObj!=null && this.pinObj.address!=null && this.pinObj.address!='' && this.pinObj.city!=null 
    && this.pinObj.city!='' && this.pinObj.state!=null && this.pinObj.state!='' && this.pinObj.country!=null && this.pinObj.country!='' && this.pincode!='' && this.pincode!=null){
      return false;
    }else return true;
  }

  addAddress() {
    this.showform = true;
  }
  
  renderedCallback() {

    console.log('***Inside Location LWC');
    if (this.torender) {
      this.getLocations();
      this.getPincodes();
      this.torender = false;
    }
  }
  getPincodes(){
    invokeDR('ARTL_GetPincodeDetails', {}).then(res => {
      this.pincodes = JSON.parse(res);
      this.pincodeoptions = this.pincodes.map(data => ({ label: data.pincode, value: data.pincodeId }));
    });
  }

  get showsubmit(){
    if(this.selectedData.length>0){
      console.log('getSelectedData' +this.selectedData.length);
      return false;
    }
    else return true;
  }

  saveNewAddress() {
    if (this.pincode == '' || this.pincode == null) {
      this.showerror = true;
      this.errorMsg = 'Pin code is required field';
    } else {
      let randomId = Math.random() * 16;
      let myNewElement = { Id: randomId, vlocity_cmt__AutoNumber__c: "", vlocity_cmt__StreetAddress__c: this.address, vlocity_cmt__City__c: this.pinObj.city, vlocity_cmt__State__c: this.pinObj.state, vlocity_cmt__Country__c: this.pinObj.country, vlocity_cmt__PostalCode__c: this.pinObj.pincode };
      let requestData = {
        "action": "updatePremises",
        "quoteId": this.recordId,
        "premises": JSON.stringify(new Array(myNewElement))
      }
      let reportRes;
      this.callIP('ARTL_GetAndUpdateLocations', requestData).then(response => {
        let res = JSON.parse(response);
        if(res && res.IPResult && res.IPResult.AddressError){
          this.showerror=true;
          this.errorMsg=res.IPResult.AddressError;
        }else{
          this.showerror=false;
          this.errorMsg='';
          this.getLocations();
          this.pinObj={};
          this.address='';
          this.pincode='';
          this.showform = false;
        }
      });
    }
  }

  handleChange(event) {
    console.log("event ");
    if(event.target.dataset.id==='address'){
      console.log("event address");
      this.address = event.detail.value;
      this.pinObj.address=event.detail.value;
    }else if(event.target.dataset.id==='city'){
      this.pinObj.city=event.detail.value;
    }else if(event.target.dataset.id==='state'){
      this.pinObj.state=event.detail.value;
    }else if(event.target.dataset.id==='country'){
      this.pinObj.country=event.detail.value;
    }else if(event.target.dataset.id==='pincode'){
      this.pinObj.pincode=event.detail.value;
      this.pincode=event.detail.value;
    }
    
  }
  handlePincodeChange(event) {
    this.pincode = event.detail.value;
    let pinobj = this.pincodes.filter(pinc => {
      return pinc.pincodeId == this.pincode
    });
    this.pinObj = pinobj[0];
  }

  saveQuoteMembers(event) {
    if(!this.isAddLocaButnClick){

      this.isAddLocaButnClick = true;    
      const members = this.template.querySelector('lightning-datatable').getSelectedRows();
      let newselection = [];
      if (this.savedquotemembers.length > 0) {
        newselection = members.filter(member => {
          return !this.savedquotemembers.find(qm => {
            return qm.Id === member.Id;
          });

        });
      }

      if (this.savedquotemembers.length <= 0 || newselection.length > 0) {
        let requestData = {
          "action": "saveMembers",
          "quoteId": this.recordId,
          "members": newselection.length > 0 ? JSON.stringify(newselection) : JSON.stringify(members)
        }
        let reportRes;
        this.callIP('ARTL_GetAndUpdateLocations', requestData).then(response => {
          reportRes = JSON.parse(response);
          if (reportRes && reportRes.IPResult) {
            this.savedquotemembers.push(...reportRes.IPResult.vlocity_cmt__QuoteMember__c_1);
          }
          this.closeModal('quotemember');
          this.isAddLocaButnClick=false;
        });
      }

    }
   
  }

  getLocations() {
    let requestData = {
      "action": "getLocations",
      "quoteId": this.recordId,
      "AddressInput": "p"
    }
    this.callIP('ARTL_GetAndUpdateLocations', requestData).then(response => {
      let reportRes = JSON.parse(response);
      if (reportRes && reportRes.IPResult) {
        this.data = reportRes.IPResult.Premises;
      }
    });
  }

  handleRowSelection(event) {
    switch (event.detail.config.action) {
      case 'selectAllRows':
        for (let i = 0; i < event.detail.selectedRows.length; i++) {
          this.selectedData.push(event.detail.selectedRows[i]);
        }
        break;
      case 'deselectAllRows':
        this.selectedData = [];
        break;
      case 'rowSelect':
        this.selectedData.push(event.detail.config.value);
        break;
      case 'rowDeselect':
        let index = this.selectedData.indexOf(event.detail.config.value);
        if (index !== -1) {
          this.selectedData.splice(index, 1);
        }
        break;
      default:
        break;
    }
  }

  callIP(ipname, inputmap) {
    let requestData = {
      "type": "integrationprocedure",
      "value": {
        "ipMethod": ipname,
        "inputMap": inputmap,
        "optionsMap": ''
      }
    }
    return getDataHandler(JSON.stringify(requestData));
  }

  closeModal(actiontype) {
    this.showPopup = false;
    if(actiontype=='quotemember'){
      this.dispatchEvent(new CustomEvent("refreshmemberscustom"));
    }else{
      this.dispatchEvent(new CustomEvent("closemodalpopup"));
    }
  }

  showModal() {
    if (this.showPopup) {
      this.showPopup = false;
    } else {
      this.showPopup = true;
    }
  }

  //Arka
  closeParentModal(){
    this.showPopup = false;
    console.log('closing Parent ***');
    this.dispatchEvent(new CustomEvent("refreshmemberscustom"));
    this.dispatchEvent(new CustomEvent("closemodalpopup"));
  }
  //Arka

  disconnectedCallback(){
    console.log('disconnected cllbck');
    this.torender=false;
  }

}