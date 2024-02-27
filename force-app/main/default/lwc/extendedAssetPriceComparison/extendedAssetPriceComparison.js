import { LightningElement, api, track } from "lwc";
import { getDataHandler } from "vlocity_cmt/utility";
import { B2BBaseComponent } from "vlocity_cmt/b2bBaseComponent";
import { routeDetails, setCacheData } from "vlocity_cmt/b2bNavigationUtil";

export default class ExtendedAssetPriceComparison extends B2BBaseComponent(LightningElement) {
  _assetReferenceId;
  _rootLineItemAttributeSelectedValues;
  _assetData = [];
  _processing = true;
  _isLoading = false;
  route;

  @api
  set assetReferenceId(data) {
    if (data) {
      this._assetReferenceId = data;
    }
  }

  get assetReferenceId() {
    return this._assetReferenceId;
  }

  @api
  set rootLineItemAttributeSelectedValues(data) {
    if (data) {
      this._rootLineItemAttributeSelectedValues = JSON.parse(data);
    }
  }

  get rootLineItemAttributeSelectedValues() {
    return this._rootLineItemAttributeSelectedValues;
  }

  get areAttributesReady() {
    return(this._assetData.length > 0 && this._processing === false);
  }

  async connectedCallback() {
    console.log("conn => ");
    console.log('this._assetReferenceId child---'+this._assetReferenceId);
    this.route = routeDetails()
    this._isLoading = true;
    console.log('_rootLineItemAttributeSelectedValues -----'+JSON.stringify(this._rootLineItemAttributeSelectedValues));
    const requestBody = {
      type: "integrationprocedure",
      value: {
        ipMethod: "es_GetAssetHistoryOfChanges",
        inputMap: {
          RootAssetReferenceId: this._assetReferenceId,
          QuoteId: this.route.Quote.id
        },
        optionsMap: {}
      }
    };

    try {
      let response = JSON.parse(await getDataHandler(requestBody));
      this._isLoading = false;
      this._assetData = response?.IPResult?.ChildAsset;
      let quoteLineItems = response?.IPResult?.QuoteLineItem;
      let attributeDetails = response?.IPResult?.AttributeList;
      this.postProcessAttributes(quoteLineItems,attributeDetails);
      // console.log("asset data -> ", JSON.stringify(this._assetData));
      // console.log(
      // "lineItem data -> ",
      // JSON.stringify(this._rootLineItemAttributeSelectedValues)
      //);
    } catch (e) {
      console.log(e.message);
    }
  }


  postProcessAttributes(quoteLineItems, attributeDetails) {
    if (this._assetData?.length > 0) {
      for (let asset of this._assetData) {
        if (asset.AttributeSelectedValue) {
          asset.currentAttributes = JSON.parse(asset.AttributeSelectedValue) || {};
          if (asset.LineNumber === "0001") {
            asset.listOfAttributes = [];
            for (const [key, value] of Object.entries(
              asset.currentAttributes
            )) {
                console.log('key---'+key);
              asset.listOfAttributes.push({
                label: key,
                assetValue: value,
                currentValue:
                  this._rootLineItemAttributeSelectedValues[key] || ""
              });
            }
          } else {
            // check if we have other match against quoteLineItems parameter
            let foundItem = quoteLineItems.filter(item => item.Name === asset.Name);
            if(foundItem) {
              asset.listOfAttributes = [];
              for (const [key, value] of Object.entries(
                asset.currentAttributes
              )) {
                let attInstance = attributeDetails.filter(item => item.Code === key);
                console.log('attInstance----'+JSON.stringify(attInstance));
                console.log('attInstance--Name--'+attInstance[0]?.Name);
                let lineItemAttribute = JSON.parse(foundItem[0]?.AttributeSelectedValue) || {};
                if(((value != null && value != undefined) || (lineItemAttribute[key] != null && lineItemAttribute[key] != undefined)) && value != lineItemAttribute[key]){
                    asset.listOfAttributes.push({
                        label: attInstance[0]?.Name,
                        assetValue: value,
                        currentValue:
                        lineItemAttribute[key] || ""
                      });
                }
               
              }
            }
          }
        }
      }
    }
    // console.log("updated data -> ", JSON.stringify(this._assetData));
    this._processing = false;
  }
}