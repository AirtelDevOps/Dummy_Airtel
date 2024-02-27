import { LightningElement } from "lwc";
import b2bAttributeConfigOffer from "vlocity_cmt/b2bAttributeConfigOffer";
import { getDataHandler } from "vlocity_cmt/utility";

export default class extendedB2bAttributeConfigOffer extends b2bAttributeConfigOffer {
    // your properties and methods here
    enableAttributes= true;

    connectedCallback() {
        super.connectedCallback();
        this.modifiedMenuList= super.menuList.filter(i => i.id != "adjust");
      }
      renderedCallback() {
        console.log("config card offer: this.route.Quote.id", this.route.Quote.id);
        this.fetchQuoteDetails(this.route.Quote.id);
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
                this.quoteType = JSON.parse(data)[0].Quote[0].vlocity_cmt__Type__c ? JSON.parse(data)[0].Quote[0].vlocity_cmt__Type__c : "undefined";
                console.log("this.quoteType offer", this.quoteType);
                this.enableAttributes = (this.quoteType == "Rebilling" || this.quoteType == "Rate Revision") ? false : true;
            }).catch(error => {
                console.log('fetchQuoteDetails', error);
            });
    }

}