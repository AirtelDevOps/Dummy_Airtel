import { LightningElement } from "lwc";
    import b2bItemsGrid from "vlocity_cmt/b2bItemsGrid";
    import template from "./cb2bItemsGrid.html"
    import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
    export default class cb2bItemsGrid extends OmniscriptBaseMixin(b2bItemsGrid){
        // your properties and methods here
        
      connectedCallback() {
        // Call omniUpdateDataJson to update the omniscript
        // this.omniUpdateDataJson({'key':'value'});
      }
    
        render()
          {
            return template;
          }
    }