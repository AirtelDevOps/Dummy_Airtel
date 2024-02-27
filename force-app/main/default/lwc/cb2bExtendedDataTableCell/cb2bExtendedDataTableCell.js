/* eslint-disable @lwc/lwc/no-async-operation */
// import { LightningElement } from 'lwc';
import b2bDataTableCell from "vlocity_cmt/b2bDataTableCell";
import { debounce, formatDate } from "vlocity_cmt/utility";

export default class Cb2bExtendedDataTableCell extends b2bDataTableCell {
  _picklistOptions;
  get picklistValues() {
    let picklistValue =
      this.columnData?.config?.picklist ||
      this.columnData?.config?.rowData[this.columnData?.config?.picklistRowField][0].val;
    if (picklistValue) {
      picklistValue = this.deepClone(picklistValue);
      if (typeof picklistValue === "string") {
        let newValues = JSON.parse(picklistValue);
        this._picklistOptions = this.validatePicklistOptions(newValues);
        // console.log('picklist options', JSON.stringify(this._picklistOptions));
        return this.validatePicklistOptions(newValues);
      } else if (Array.isArray(picklistValue)) {
        this._picklistOptions = this.validatePicklistOptions(picklistValue);
        // console.log('picklist options', JSON.stringify(this._picklistOptions));
        return this.validatePicklistOptions(picklistValue);
      }
    }
    return [];
  }

  get getCellValue() {
    console.log('cellData => ', this.columnData?.fieldName, JSON.stringify(this.cellData));
    if (this.columnData.datetime) {
      return formatDate(this.cellData.value, this.inputDatetimeFormat);
    } else if (this.columnData.date) {
      return formatDate(this.cellData.value, this.inputDateFormat);
    } else if(this.columnData.config.isCustomPicklistField === true) {
        return typeof this.cellData.value === 'string' ? this.cellData.value : this.cellData.value[0]?.val;
    } 
    return this.cellData.value;
  }

  get isPicklistCellEditable() {
    // let editIcon = this.template.querySelector('.b2b-hover-icon');
    // console.log('editIcon', editIcon);
    return this.cellData.editable; // && this._picklistOptions?.length > 0;
  }

  
  renderedCallback() {
    super.renderedCallback();

    setTimeout(() => {
      let editFieldEle = this.template.querySelector('.b2b-hover-icon');
      if(editFieldEle) {
        console.log('editFieldEle', editFieldEle);
        editFieldEle.click();
        // editFieldEle.click();
      }
    }, 300);
  }
}