import { LightningElement, api, track } from "lwc";
    import b2bOfferSelection from "vlocity_cmt/b2bOfferSelection";
    import cb2bOfferSelectiontemplate from "./cb2bOfferSelection.html"
    export default class cb2bOfferSelection extends b2bOfferSelection{
        // your properties and methods here
        
  
    
        render()
          {
            return cb2bOfferSelectiontemplate;
          }
    }