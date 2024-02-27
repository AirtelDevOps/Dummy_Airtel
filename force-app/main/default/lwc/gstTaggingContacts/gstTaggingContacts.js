import { LightningElement, api, track , wire} from 'lwc';
import { getDataHandler } from "vlocity_cmt/utility";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo , getPicklistValues } from "lightning/uiObjectInfoApi";
import CONTACT_OBJECT from "@salesforce/schema/Contact";
import SALUTATION_FIELD from "@salesforce/schema/Contact.Salutation";
import fetchNBA from '@salesforce/apex/ARTL_GstTaggingContactsController.getNBAAccountId';
import pubsub from 'vlocity_cmt/pubsub';
const columns = [
  {
    label: 'DCP First Name',
    fieldName: 'DCPfirstName',
    type: 'text',
  }, {
    label: 'DCP Last Name',
    fieldName: 'DCPlastName',
    type: 'number',
    editable: true,
  }, {
    label: 'Phone',
    fieldName: 'phone',
    type: 'phone',
    editable: true,
  }, {
    label: 'Email',
    fieldName: 'email',
    type: 'email',
    editable: true,
  }, {
    label: 'Type',
    fieldName: 'type',
    type: 'text',
    editable: true,
  }
];
export default class GstTaggingContacts extends LightningElement {
  columns = columns;
  showLoading = false;
  @api addInfo = [];
  @api record;
  nBAAccountId;
  @track objectInfo;
  bcpDCPRecordTypeId ;
  salutations;
  error;

  showFeatures = true;
  get options() {
    return [
      { label: 'DCP', value: 'DCP' },
      { label: 'LCP', value: 'LCP' }
    ];
  }
  @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
  objectInfo({ error, data }) {
    if (data) {
      const rtis = data.recordTypeInfos;
      this.bcpDCPRecordTypeId =  Object.keys(rtis).find((rti) => rtis[rti].name === "BCP/DCP Contact");
     this.error = undefined;
    } else if (error) {
     this.error = error;
    }
  };

  @wire(getPicklistValues, { recordTypeId: "$bcpDCPRecordTypeId", fieldApiName: SALUTATION_FIELD })
  picklistResults({ error, data }) {
    if (data) {
      this.salutations = data.values;
      this.error = undefined;
    } else if (error) {
      this.error = error;
      this.salutations = undefined;
    }
  }

  connectedCallback() {
    this.Id = this.setRandomId();
    // this.addInfo = [...this.addInfo, this.addFieldItem()];
    this.getNBAAccountId();
    this.getContacts();
    
  }
  recordTypeId() {
    // Returns a map of record type Ids
    const rtis = this.objectInfo.data.recordTypeInfos;
    this.bcpDCPRecordTypeId =  Object.keys(rtis).find((rti) => rtis[rti].name === "BCP/DCP Contact");
  }

  getNBAAccountId(){
    fetchNBA({quoteMId: this.record.SiteId}).then((data)=>{
      this.nBAAccountId = data;
      }).catch((error)=>{
          this.error = error;
          console.log('Error:: ' + this.error);
      });
  }

  getContacts() {
    this.showLoading = true;
    let recordObj = { recordId: this.record.SiteId }
    let requestData = {
      "type": "integrationprocedure",
      "value": {
        "ipMethod": "ARTL_gstTaggingGetExistingContactsFromQuoteMember",
        "inputMap": recordObj,
        "optionsMap": ''
      }
    }
    getDataHandler(JSON.stringify(requestData)).then(response => {
      this.ipResult = JSON.parse(response);
      if (this.ipResult && this.ipResult.IPResult && this.ipResult.IPResult && this.ipResult.IPResult.length > 0) {
        this.addInfo = [...this.addInfo, ...this.ipResult.IPResult];
      }
      else {
        this.addInfo = [...this.addInfo, this.addFieldItem()];
      }
      console.log("ContactDetails::" + JSON.stringify(this.addInfo));
    })
    this.showLoading = false;
  }

  updateContactwithRandomId(array) {
    for (var element of array) {
      if (!element.Id) {
        element.Id = this.setRandomId();
      }
    }
    return array;

  }
  addFieldItem() {
    
    return {
      Id: this.setRandomId(),
      Designation: "",
      salutation:"",
      DCPfirstName: "",
      DCPlastName: "",
      phone: "",
      email: "",
      type: "",
      QMContactId: "",
      ContactId: "",
      ContactRole:"",
      recordTypeId: this.bcpDCPRecordTypeId,
      siteid: this.record.SiteId,
      nBAAccountId: this.nBAAccountId
    }
  }

  hasNullValue(arr) {
    for (const obj of arr) {
      for (const key in obj) {
        if (obj.DCPlastName === '') {
          return true;
        }
      }
    }
    return false;
  }

  addField() {
    if (this.hasNullValue(this.addInfo)) {
      this.ShowToast('Error', 'Please fill the Empty fields', 'error', 'dismissable');

    }
    else {
      this.addInfo = [this.addFieldItem(), ...this.addInfo];
    }
  }
  setRandomId() {
    var x = Math.random();
    this.randomId = String(x).split(".")[1];
    return this.randomId
  }
  handleInputChange(e) {
    var inputId = e.target.dataset.id;
    var inputValue = e.target.value;
    var inputField = e.target.dataset.field;
    console.log(JSON.stringify(inputField + inputValue));

    this.addInputTojson(inputId, inputValue, inputField)
  }

  addInputTojson(inputId, inputValue, inputField) {
    var array = this.addInfo;
    for (var element of array) {
      if (element.Id == inputId && inputField) {
        element[inputField] = inputValue;
      }
    }
    this.addInfo = this.addInfo.map(obj => array.find(o => o.Id === obj.Id) || obj);
    console.log(JSON.stringify(this.addInfo));

  }
  viewJson() {
    this.showLoading = true;
    let filteredData = this.addInfo.filter((item) => {
      return item.DCPlastName != '';
    });


    console.log('viewJson-------before ---'+JSON.stringify(filteredData));

    for (var element of filteredData) {
      if ( element['type'] === 'DCP') {
        element['ContactRole'] = 'Delivery Contact';
      }else if( element['type'] === 'LCP'){
        element['ContactRole'] = 'Local Contact Person';
      }
    }


    console.log('viewJson-------after----'+JSON.stringify(filteredData));

    if (this.record && this.record.SiteId) {
      let recordData = { siteid: this.record.SiteId, Installationgst: this.record.InstallationGST, sitecontacts: filteredData }
      console.log(JSON.stringify(recordData));
      pubsub.fire("ARTLgstTaggingContact", "getcontacts", { contacts: recordData });

    }
  }

  cancelContact(){
    this.showLoading = true;
    pubsub.fire("ARTLgstTaggingContact", "getcontacts", {});
    
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

  deleteItem(e) {
    this.addInfo = this.addInfo.filter(x => x.Id != e.target.dataset.id);
  }
}