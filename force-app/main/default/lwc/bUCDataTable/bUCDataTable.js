import { LightningElement,track,api, wire} from 'lwc';
import {OmniscriptBaseMixin} from 'vlocity_cmt/omniscriptBaseMixin';
import {loadStyle} from "lightning/platformResourceLoader";
import WrappedHeaderTable from "@salesforce/resourceUrl/WrappedHeaderTable";
import {exportCSVFile} from 'c/utils';
import {NavigationMixin} from 'lightning/navigation';
import getDynamicTableDataList from '@salesforce/apex/DynamicLWCDataTableController.GetWrapperOfSObjectFieldColumnActionValues';

export default class BUCDataTable extends OmniscriptBaseMixin(LightningElement) {
    @api records;
    @api objecttype;
    @api fetchtemplate;
    @api fetchErrorRecords;
    @track DataTableResponseWrappper;
    @track DataTableHeader;
    @track objectName;

    stylesLoaded = false;
    connectedCallback() {
        if (this.records != null && Array.isArray(this.records) == false) {
            let docArray = [];
            docArray.push(this.records);
            this.bucData = docArray;
        } else if (this.records != null && Array.isArray(this.records) == true) {
            this.bucData = this.records;
        }
        getDynamicTableDataList({TableName: this.objecttype})
            .then(result => {
                this.DataTableResponseWrappper = result.lstDataTableColumns;
                this.DataTableHeader = result.lstDataTableHeaders;
            })
    }

    downloadAccountData() {
        exportCSVFile(this.DataTableHeader, this.bucData, "error detail")
    }

    renderedCallback() {
        if (!this.stylesLoaded) {
            Promise.all([loadStyle(this, WrappedHeaderTable)])
                .then(() => {
                    console.log("Custom styles loaded");
                    this.stylesLoaded = true;
                })
                .catch((error) => {
                    console.error("Error loading custom styles");
                });
        }
    }
}