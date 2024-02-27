import { LightningElement } from "lwc";
    import b2bProductItem from "vlocity_cmt/b2bProductItem";
    import template from "./cb2bProductItem.html"
    import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
    export default class cb2bProductItem extends OmniscriptBaseMixin(b2bProductItem){
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