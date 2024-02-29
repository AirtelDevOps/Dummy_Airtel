/* eslint-disable @lwc/lwc/no-async-operation */

import { LightningElement } from "lwc";
import b2bConfigCard from "vlocity_cmt/b2bConfigCard";
import template from "./extendedB2bConfigCard.html";
import { getDataHandler } from "vlocity_cmt/utility";
import { formatCurrencyESM, setCurrencyCode, setLocale} from "c/cb2bUtils";

export default class ExtendedB2bConfigCard extends b2bConfigCard {
  modifiedMenuList;
  showDD;
  enableFields= true;
  enablePriceFields= true;


  connectedCallback() {
    super.connectedCallback();
    super.offer.columns.forEach(col => {
      if(col.dataType === "Currency"){
        let unformataCurrency = col.value.value.replace("$", "").split(".")[0].replaceAll(",", "").replace("₹","");
        let unformataCurrencyOriginal =  (col.value.originalValue !== null  && col.value.originalValue !== undefined) ? col.value.originalValue.replace("$", "").split(".")[0].replaceAll(",", "").replace("₹","") : null ;
        console.log("unformataCurrecny " , unformataCurrency);
        console.log("unformataCurrencyOriginal " , unformataCurrencyOriginal);
        col.value.value = formatCurrencyESM(unformataCurrency);
        col.value.originalValue = (col.value.originalValue !== null  && col.value.originalValue !== undefined) ? formatCurrencyESM(unformataCurrencyOriginal) : null;
      }
      
    });
    console.log(" super.offer.columns",  super.offer.columns);
    this.modifiedMenuList= super.menuList.filter(i => i.id != "adjust");
  }

  renderedCallback() {
    console.log("config card: this.route.Quote.id", this.route.Quote.id);
    this.fetchQuoteDetails(this.route.Quote.id);
    console.log('enablePriceFields '+this.enablePriceFields);
}
fetchQuoteDetails(quoteId) {
    const datasourcedef = JSON.stringify({
        type: "dataraptor",
        value: {
            bundleName: "DRGetQuoteDetailsForLWC",
            inputMap: {
                "cartId": quoteId
            }
        },
        optionsMap: null
    });
    getDataHandler(datasourcedef)
        .then(data => {
            setCurrencyCode(JSON.parse(data)[0].Quote[0].vlocity_cmt__PriceListId__r.vlocity_cmt__CurrencyCode__c);
            this.quoteType = JSON.parse(data)[0].Quote[0].vlocity_cmt__Type__c ? JSON.parse(data)[0].Quote[0].vlocity_cmt__Type__c : "undefined";
            console.log("this.quoteType", this.quoteType);
            this.enableFields = (this.quoteType == "Rebilling" || this.quoteType == "Rate Revision") ? false : true;
            if(this.quoteType == "Rebilling") {
              this.enablePriceFields = false;
            } else if(this.quoteType == "Rate Revision") {
              this.enablePriceFields = true;
            }
            
        }).catch(error => {
            console.log('fetchQuoteDetails', error);
        });
}
}