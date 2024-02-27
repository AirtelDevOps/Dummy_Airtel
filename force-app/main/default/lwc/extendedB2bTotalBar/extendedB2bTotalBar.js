import { LightningElement, api } from "lwc";
import b2bTotalBar from "vlocity_cmt/b2bTotalBar";
import { getDataHandler } from "vlocity_cmt/utility";
import { formatCurrencyESM, setCurrencyCode, setLocale} from "c/cb2bUtils";

export default class extendedB2bTotalBar extends b2bTotalBar {
  @api dueTotal;
  @api recurringTotal;
  dueTotalEsm;
  recurringTotalEsm;
 
  connectedCallback() {
    super.connectedCallback();
    this.fetchQuoteDetails(this.route.Quote.id);
    console.log("Super.oneTimeTotal", this.dueTotal);
    console.log("Super.recurringTotal", this.recurringTotal);
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
          this.setCurrencyToFields();
            }).catch(error => {
            console.log('fetchQuoteDetails', error);
        });
  }
  setCurrencyToFields() {
      this.dueTotalEsm= formatCurrencyESM(this.dueTotal);
      this.recurringTotalEsm= formatCurrencyESM(this.recurringTotal);
  }
}