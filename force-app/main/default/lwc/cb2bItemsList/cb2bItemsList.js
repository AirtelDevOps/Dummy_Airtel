import { LightningElement } from "lwc";
    import b2bItemsList from "vlocity_cmt/b2bItemsList";
    import template from "./cb2bItemsList.html"
    import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
    export default class cb2bItemsList extends OmniscriptBaseMixin(b2bItemsList){
        // your properties and methods here
        
      
    
        render()
          {
            return template;
          }
    }