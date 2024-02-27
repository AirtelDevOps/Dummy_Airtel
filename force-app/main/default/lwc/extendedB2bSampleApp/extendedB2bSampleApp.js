import { LightningElement } from "lwc";
import B2BSampleApp from "vlocity_cmt/b2bSampleApp";
import extendedB2bSampleAppTemplate from "./extendedB2bSampleApp.html"
import { routeDetails, updateAPIConfigDetails } from "vlocity_cmt/b2bNavigationUtil";
import { getParameterByName} from 'vlocity_cmt/b2bUtils';
import lwcStyleResource from "@salesforce/resourceUrl/EsmCartStyles";
import { loadStyle } from "lightning/platformResourceLoader";

export default class ExtendedB2bSampleApp extends B2BSampleApp {
    get _masterQuote1() {
        return this.route.Quote.id;
    }

       
    connectedCallback() {
        super.connectedCallback();
        Promise.all([
            loadStyle(this, lwcStyleResource)
        ]).then(() => {
            console.log('Files loaded.');
        })
       
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
        return extendedB2bSampleAppTemplate;
    }
}