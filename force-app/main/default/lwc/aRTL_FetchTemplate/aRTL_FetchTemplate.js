import { LightningElement,track,api, wire} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import getDynamicTableDataList from '@salesforce/apex/DynamicLWCDataTableController.GetWrapperOfSObjectFieldColumnActionValues';
import {OmniscriptBaseMixin} from 'vlocity_cmt/omniscriptBaseMixin';

export default class ARTL_FetchTemplate extends OmniscriptBaseMixin(LightningElement) {
    @api objecttype;
    @api fetchtemplate;

    downloadTemplate() {
        console.log('objectType::', this.objecttype);
        let url = '';
        this.objectName =  this.objecttype;    
        console.log('objectName::', this.objectName);
        console.log('fetchtemplate::',this.fetchTemplate);
        getDynamicTableDataList({TableName: this.objectName})
            .then(result => {
                url = result.templateUrl;
                console.log('url is inside method::', url);
                window.open(url, "_blank");
            })
    }



}