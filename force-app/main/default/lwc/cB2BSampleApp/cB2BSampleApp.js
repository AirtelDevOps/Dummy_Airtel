import { LightningElement } from "lwc";
import B2BSampleApp from "vlocity_cmt/b2bSampleApp";
import cB2BSampleAppTemplate from "./cB2BSampleApp.html"
import { routeDetails, updateAPIConfigDetails } from "vlocity_cmt/b2bNavigationUtil";
import { getParameterByName} from 'vlocity_cmt/b2bUtils';

export default class cB2BSampleApp extends B2BSampleApp {
    get _masterQuote1() {
        return this.route.Quote.id;
    }
    connectedCallback() {
        super.connectedCallback();
        // 
        if(this.session) {
            for (const [key, value] of Object.entries(this.session)) {
                updateAPIConfigDetails(key, value);
            }
        }
        this.objType = getParameterByName("c__objType");
        this.objType = this.objType ? decodeURIComponent(this.objType) : 'Quote'
        this.route = routeDetails();
        this.nList = this.route[this.objType];
    }
    render() {
        return cB2BSampleAppTemplate;
    }
}