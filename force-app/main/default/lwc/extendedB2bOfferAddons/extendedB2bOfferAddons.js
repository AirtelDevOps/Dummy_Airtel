import { LightningElement } from "lwc";
import b2bOfferAddons from "vlocity_cmt/b2bOfferAddons";
import pubsub from "vlocity_cmt/pubsub";
import { debounce } from "vlocity_cmt/utility";
import { getDataHandler } from "vlocity_cmt/utility";

export default class ExtendedB2bOfferAddons extends b2bOfferAddons {
  enableAttributes= true;
  connectedCallback() {
    console.log("Addons: this.route.Quote.id", this.route.Quote.id);
    this.fetchQuoteDetails(this.route.Quote.id);
  }
  handletypeaheadInput(evt) {
    console.log("handletypeaheadInput => ");
    if (!this.typeaheadFn) {
      this.typeaheadFn = debounce((event) => {
        pubsub.fire("b2b_update_cart", "data", {
          lineItem: this.offer,
          lineItemId: this.offer.id,
          rootBundleId: this.offer.rootItemId,
          parentId: this.offer.parentId,
          queryInput: event.value,
          action: "getCartsProduct"
        });
        this.typeaheadFn = null;
      }, 500);
    }
    if (this.typeaheadFn) {
      this.typeaheadFn(evt);
    }
  }

  handletypeaheadSelect(evt) {
    console.log('handletypeaheadSelect');
    super.handletypeaheadSelect(evt);
  }

  handletypeaheadSelectCustom(evt) {
    console.log('handletypeaheadSelectCustom');
    pubsub.fire("b2b_update_cart", "data", {
        lineItem: this.offer,
        lineItemId: this.offer.id,
        rootBundleId: this.offer.rootItemId,
        parentId: this.offer.parentId,
        queryInput: " ",
        action: "getCartsProduct"
    });
  }

  fetchProductsOnDemand(event) {
    console.log('fetchProductsOnDemand');
    pubsub.fire("b2b_update_cart", "data", {
      lineItem: this.offer,
      lineItemId: this.offer.id,
      rootBundleId: this.offer.rootItemId,
      parentId: this.offer.parentId,
      queryInput: " ",
      action: "getCartsProduct"
    });
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