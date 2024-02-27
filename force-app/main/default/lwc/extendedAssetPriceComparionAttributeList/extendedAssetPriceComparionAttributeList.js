import { LightningElement, api, track } from 'lwc';

export default class ExtendedAssetPriceComparionAttributeList extends LightningElement {
    _attributeList = [];

    @api
    set attributeList(data) {
      if (data) {
        this._attributeList = data;
      }
    }
  
    get attributeList() {
      return this._attributeList;
    }
}