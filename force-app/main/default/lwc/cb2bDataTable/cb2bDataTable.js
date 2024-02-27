/* eslint-disable no-prototype-builtins */
/* eslint-disable radix */
import { LightningElement, api} from 'lwc';
import b2bDataTable from 'vlocity_cmt/b2bDataTable';
import { invokeVIP } from "vlocity_cmt/b2bUtils";
import setAttributeValues from '@salesforce/apex/TechnicalAttributeEnrichmentController.setAttributeValues';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getDataHandler } from "vlocity_cmt/utility";
import { formatCurrencyESM, setCurrencyCode, setLocale} from "c/cb2bUtils";

export default class cb2bDataTable extends b2bDataTable {
    _selectedAssetReferenceId;
    _selectedRecordId;
    _renderFlexCard;
    _parentAttributeFlexCard = {};
    _streetAddressHeaderConfig;
    recordsRefreshed = false;
    showAddProductBtn = true;
    showEditCartBtn = true;

    techEnrichAttrs;

    @api tablePageData;
    @api tablePageGroupData;
    @api newRecords;
  
    
    connectedCallback() {
        super.connectedCallback();
        // this.tablePageData[0].columns[7].data.value[0].val= "₹10,000.00";
        /*
        this.tablePageData.forEach(row => {
            row.columns.forEach(col => {
                if(col.Currency) {
                    let unformataCurrencyVal = col.data.value[0].val.replace("$", "").split(".")[0].replace(",", "").replace("₹","");
                    let unformataCurrencyOriginalValue = col.data.value[0].originalValue.replace("$", "").split(".")[0].replace(",", "").replace("₹","");
                    col.data.value[0].val= formatCurrencyESM(unformataCurrencyVal);
                    col.data.value[0].originalValue= formatCurrencyESM(unformataCurrencyOriginalValue);
                }
            })
        });*/
    }
    /*
    get getTableParentWrapper() {
        let wrapperParentClass = "slds-is-relative";
        wrapperParentClass = `${wrapperParentClass}`
        return wrapperParentClass;
    }
    */
    /*
    set records(value) {
        if (value) {
            super.records = value;
            this.recordsRefreshed = true;
        }
    }*/
    toggleList(evt) {
        evt.currentTarget.classList.toggle('b2b-dropdown_open');
        evt.currentTarget.getBoundingClientRect();
        this.template.querySelector('.b2b-common-menu').style.position = 'fixed';
        this.template.querySelector('.b2b-common-menu').style.display = 'block';
        this.template.querySelector('.b2b-common-menu').style.zIndex = '9999';
        this.template.querySelector('.b2b-common-menu').classList.add('b2b-dropdown_open');
        this.template.querySelector('.b2b-common-menu').style.left = evt.clientX + 'px';
        this.template.querySelector('.b2b-common-menu').style.top = evt.clientY + 'px';
        this.populateActionListOnSummaryPage(evt);
        if (evt.currentTarget.dataset.adjustmenu && this.filteredData.length) {
          const rowIndex = parseInt(evt.currentTarget.dataset.index);
          if (this.filteredData.length > 1 && rowIndex > this.filteredData.length / 2 - 1) {
            evt.currentTarget.classList.toggle('b2b-dropdown-showup');
          } else {
            evt.currentTarget.classList.toggle('b2b-dropdown-showdown');
          }
        }
    }

    
    populateActionListOnSummaryPage(evt) {
        super.populateActionListOnSummaryPage(evt);
        if (!this.isLocationOrSubscriberTab) { 
            const index = parseInt(evt.currentTarget.dataset.index);
            const actionValue = this.tableData[index].columns.find(col =>
                col.fieldLabel === 'Action')?.data.value[0].val;
            // actionValue => Existing / Change / Disconnect
            this.commonActionList.push({
                'label': 'Technical Attributes',
                'operation': 'techEnrichment',
                'method': 'techEnrichment'
            });
            if (actionValue === 'Existing' || actionValue === 'Change') {
                this.commonActionList.push(
                    {
                        'label': 'Compare with Asset',
                        'operation': 'compareAsset',
                        'method': 'compareAsset'
                    }
                );
            }

            if (!this.showEditCartBtn) {
                this.commonActionList= this.commonActionList.filter(i => i.operation != "edit");
            }
        }
        /** current logic, needs a merge */
    /*
        this.commonActionList = [];
        let actionType = evt.currentTarget.dataset.actiontype;
        if (this.headerActionList.length > 0 && actionType && actionType == "headerAction") {
            this.commonActionList = this.commonActionList.concat(this.headerActionList);
            return;
        }
        if (this.groupActionList.length > 0 && actionType && actionType == "groupAction") {
            this.commonActionList = this.commonActionList.concat(this.groupActionList);
            return;
        }
        if (!this.isLocationOrSubscriberTab) {
            this.macdActionList = [];
            this.summaryActionList = [];
            this.currentRowData = null;
            const index = parseInt(evt.currentTarget.dataset.index);
            const actionValue = this.tableData[index].columns.find(col => col.fieldLabel === 'Action')?.data.value[0].val;
            if (actionValue === 'Existing' || actionValue === 'Change') {
            this.commonActionList.push({
                'label': this.labels.CMEXDisconnect,
                'operation': 'disconnect',
                'method': 'processDisconnect'
            });
            }
            if (actionValue !== 'Disconnect' && this.showEditCartBtn) {
                this.commonActionList.push({
                    'label': this.labels.CMEXEdit,
                    'operation': 'edit',
                    'method': 'editRecord'
                });
            }
            if(this.showAddProductBtn) {
                this.commonActionList.push({
                    'label': this.labels.CMEXDelete,
                    'operation': 'delete',
                    'method': 'processRow'
                });
            }
            
        }
        if (this.tableData.length > 0) {
            this.currentRowIndex = parseInt(evt.currentTarget.dataset.index, 10);
            this.isConvertedFromAsset = this.tableData[this.currentRowIndex].isConvertedFromAsset;
            this.currentRowData = this.tableData[this.currentRowIndex];
        } else if (this.tableGroupData.length > 0) {
            this.currentRowIndex = parseInt(evt.currentTarget.dataset.index, 10);
            this.currentRowGroupIndex = parseInt(evt.currentTarget.dataset.groupindex, 10);
            this.currentRowData = this.tableGroupData[this.currentRowGroupIndex].groupItems.find(ele => ele.originalItemIndex == this.currentRowIndex);
            this.isConvertedFromAsset = this.currentRowData.isConvertedFromAsset;
        }
        if (!this.isConvertedFromAsset && this.isLocationOrSubscriberTab) {
            this.commonActionList.push({
            'label': this.labels.CMEXDelete,
            'operation': 'delete',
            'method': 'processRow'
            });
        }
        if (this.currentRowData?.actions.length > 0) {
            this.commonActionList = this.commonActionList.concat(this.currentRowData.actions);
        }
       */
        /** ends new logic */
       /* if (!this.isLocationOrSubscriberTab) {
            this.macdActionList = [];
            this.summaryActionList = [];
            const index = parseInt(evt.currentTarget.dataset.index);
            const actionValue = this.tableData[index].columns.find(col =>
                col.fieldLabel === 'Action')?.data.value[0].val;
            if (actionValue === 'Existing' || actionValue === 'Change') {
                this.macdActionList.push({
                    'label': this.labels.CMEXDisconnect,
                    'operation': 'disconnect',
                    'method': 'processDisconnect'
                },
                    {
                        'label': 'Compare with Asset',
                        'operation': 'compareAsset',
                        'method': 'compareAsset'
                    }
                );
            }
            if (actionValue !== 'Disconnect' && this.showEditCartBtn) {
                this.summaryActionList.push({
                    'label': this.labels.CMEXEdit,
                    'operation': 'edit',
                    'method': 'editRecord'
                });
            }
            if(this.showAddProductBtn) {
                this.summaryActionList.push({
                    'label': this.labels.CMEXDelete,
                    'operation': 'delete',
                    'method': 'processRow'
                });
            }
            this.summaryActionList.push({
                'label': 'Technical Attributes',
                'operation': 'techEnrichment',
                'method': 'techEnrichment'
            });
        }
       */
        // if (!this.isLocationOrSubscriberTab) {
        //     this.macdActionList = [];
        //     this.summaryActionList = [];
        //     const index = parseInt(evt.currentTarget.dataset.index);
        //     const actionValue = this.tableData[index].columns.find(col =>
        //         col.fieldLabel === 'Action')?.data.value[0].val;
        //     if (actionValue === 'Existing' || actionValue === 'Change') {
        //         this.commonActionList.push(
        //             {
        //                 'label': 'Compare with Asset',
        //                 'operation': 'compareAsset',
        //                 'method': 'compareAsset'
        //             }
        //         );
        //     }
            // if (actionValue !== 'Disconnect') {
            //     this.summaryActionList.push({
            //         'label': this.labels.CMEXEdit,
            //         'operation': 'edit',
            //         'method': 'editRecord'
            //     });
            // }
            // this.summaryActionList.push({
            //     'label': this.labels.CMEXDelete,
            //     'operation': 'delete',
            //     'method': 'processRow'
            // });
            // this.summaryActionList.push({
            //     'label': 'Technical Attributes',
            //     'operation': 'techEnrichment',
            //     'method': 'techEnrichment'
            // });
       // }
    }


    compareAsset(evt) {
        this._parentAttributeFlexCard = {};
        const op = evt.currentTarget.dataset.operation;
        console.log('op---'+op);
        //const index = parseInt(evt.currentTarget.dataset.index, 10);
        const index = this.deepClone(parseInt(this.currentRowIndex, 10));
        console.log('index---'+index);
        const record = this.deepClone(this.filteredData.find(item => item.originalIndex == index));
        console.log('record---'+JSON.stringify(record));
        this._selectedAssetReferenceId = record[this.nsp + 'AssetReferenceId__c'][0].val;
        console.log(' this._selectedAssetReferenceId---'+ this._selectedAssetReferenceId);
        const AttributeSelectedValues = record.vlocity_cmt__AttributeSelectedValues__c[0].originalValue;
        console.log(' AttributeSelectedValues---'+ AttributeSelectedValues);
        this._parentAttributeFlexCard = {
            rootLineItemAttributes: AttributeSelectedValues
        }
        this._renderFlexCard = true;
        this.template.querySelector(".b2b-assetPriceComparison-modal")?.openModal();
    }

    handleCloseAssetPriceComparisonPopup(evt) {
        this._renderFlexCard = false;
        this.template.querySelector(".b2b-assetPriceComparison-modal")?.closeModal();
    }

    collapseItems(evt) {
        if (evt.detail.result && evt.detail.result.itemId) {
          super.collapseItems(evt);
        } else {
          const t = evt.currentTarget;
          const target = t.closest('.b2b-table_row');
          const elems = target.querySelectorAll('vlocity_cmt-b2b-data-table-cell-list');
          // const elems = target.querySelectorAll('c-extended-b2b-data-table-cell-list');
          elems.forEach(e => {
            e.collapseChilds();
          });
        }
    }
    
    techEnrichment(evt) {
        this._parentAttributeFlexCard = {};
        const operation = evt.currentTarget.dataset.operation;
        console.log('operation => ', operation);
        const index = this.deepClone(parseInt(this.currentRowIndex, 10));
        // const index = parseInt(evt.currentTarget.dataset.index, 10);
        const record = this.deepClone(this.filteredData.find(item => item.originalIndex == index));
        this._selectedRecordId = record['Id'][0].val;
        //const AttributeSelectedValues = record.vlocity_cmt__AttributeSelectedValues__c[0].originalValue;
        this.template.querySelector(".b2b-techenrichment-modal")?.openModal();
    }

    handleCloseTechEnrichmentPopup(evt) {
        this._renderFlexCard = false;
        this.template.querySelector(".b2b-techenrichment-modal")?.closeModal();
    }

    changeFieldGroup(evt, skip) {
        super.changeFieldGroup(evt);

        if (this.memberType == "Location") {
            let _fGroup = evt.target.value;
            //KB: Below script is to make member fieldsv(row wise) read only if its validated already
            if (this.tableData.length > 0) {
                if (this.recordsRefreshed) {
                    this.tableData.forEach((data, index) => {
                        //console.log('@@@@@ 11data= ' + index + ' == ' +  JSON.stringify(data));
                        data.columns.forEach(col => {
                            if (col.config.rowData.ARTL_Feasibility_Error_Margin__c != undefined) {
                                col.data.editable = false;

                            }

                        });

                    });
                    //console.log('@@@@@ 11= ', JSON.stringify(this.tableData));
                } else {
                    this.recordsRefreshed = false;
                }
            }
            //KB: below script is used to remove Add Location action for address validation option
            if (this._streetAddressHeaderConfig == null) {
                this._streetAddressHeaderConfig = this.dataColumns.find(col => col.fieldName == "vlocity_cmt__StreetAddress__c").headerLookupConfig;

            }
            if (_fGroup == 'Address Validation') {
                this.dataColumns.find(col => col.fieldName == "vlocity_cmt__StreetAddress__c").headerLookupConfig = null;
            } else {
                this.dataColumns.find(col => col.fieldName == "vlocity_cmt__StreetAddress__c").headerLookupConfig = this._streetAddressHeaderConfig;
            }
        }
    }

    handleFieldEditCustom(evt) {
        const result = evt.detail.result;
        const target = result.currentTarget;
        const itemIndex = target.dataset.rowOriginalIndex;
        const fieldName = target.dataset.fieldName;
        const posValue = target.dataset.cellPosition;
        const columnType = evt.currentTarget.columnData.type;
        let record = {};
        //new-pos is used for new records shown through manual add
        if (posValue && posValue.startsWith('new-pos')) {
            record = this.newRecords.find(item => item.originalItemIndex == itemIndex);
        }
        else {
            record = this.filteredData.find(item => item.originalIndex == itemIndex);
        }

        if (record.editRowMode) {
            if (record.isNewRecord) {
                let changeValue;
                if (columnType === 'lookup') {
                    const selectedItem = evt.currentTarget.rowData?.item;
                    changeValue = (selectedItem != null && typeof selectedItem === 'object')
                        ? { ...selectedItem, Id: null, Name: null }
                        : selectedItem;
                }
                else if (columnType === "checkbox") {
                    changeValue = target.checked;
                }
                else {
                    changeValue = target.value;
                }

                if (posValue && posValue.startsWith('new-pos')) {
                    const colRecord = record.columns.find(recCol => recCol.fieldName === fieldName);
                    colRecord.data.changedValue = changeValue;
                }
                else {
                    record[fieldName] = changeValue;
                    this.route[this.routePath].data[this.memberType].tableData = this.records;
                }
            }
            return;
        }
        if (result.type === "click" || (result.type === "keypress" && result.keyCode == 13)) {
            record.editColName = fieldName;
        } else {
            const oldValue = record[fieldName];
            const mediaId = record['ARTL_Media_Rec_Id__c.value'][0]?.val;
            // custom logic
            try {
                let bandwithOptions = JSON.parse(record['ARTL_Media_SourceOptions__c'][0].val);

                if (bandwithOptions?.length > 0) {
                    let selectedBandwith = bandwithOptions.filter(obj => obj.hasOwnProperty(target.value));
                    record['ARTL_Bandwith_Options__c.value'][0].val = selectedBandwith[0][target.value];
                    record['ARTL_Bandwith_Options__c.value'][0].originalValue = selectedBandwith[0][target.value];

                }
            } catch (e) {
                console.log('error => ', e.message);
            }
            // 
            record[fieldName] = columnType === "checkbox" ? target.checked : target.value;
            record.editColName = null;

            let nameSpaceEntityId = this.objType == 'Quote' ? this.nsp.concat("QuoteId__c") : this.nsp.concat("OrderId__c");
            let onlyEntityId = this.objType == 'Quote' ? "QuoteId__c" : "OrderId__c";
            let entityGroupId = this.objType == 'Quote' ? "QuoteGroupId__c" : "OrderGroupId__c";
            let nameSpaceMemberTypeId = this.nsp.concat("MemberType__c");
            delete record[entityGroupId];
            //To remove Quote/Order Id as per ESM_UploadMembers request format
            if (record[nameSpaceEntityId]) {
                delete record[nameSpaceEntityId];
            } else {
                delete record[onlyEntityId];
            }
            //To handle memberType 
            if (record[nameSpaceMemberTypeId]) {
                record['MemberType__c'] = record[nameSpaceMemberTypeId];
                delete record[nameSpaceMemberTypeId];
            }
            let updatedrecordKey = {
                Id: record.Id,
                "MemberType__c": this.memberType,
                [fieldName]: record[fieldName]
            };
            if (this.memberType === 'Subscriber') {
                updatedrecordKey[this.nsp.concat("FirstName__c")] = record[this.nsp.concat("FirstName__c")];
                updatedrecordKey[this.nsp.concat("LastName__c")] = record[this.nsp.concat("LastName__c")];
            }
            record = updatedrecordKey;

            console.log('updated record', record);

            let reqObj;
            let updateMediaIP;
            if (this.objType === 'Quote') {
                updateMediaIP = 'ARTL_UpdateMedia';
                reqObj = {
                    "Id": mediaId,
                    "ARTL_Media_Options_SelectedValue__c.value": record["ARTL_Media_Options_SelectedValue__c.value"]
                }
            }

            this.loading = true;
            invokeVIP(updateMediaIP, reqObj, this).then((res) => {
                console.log('VIP Response => ', res);
                //this.showToast(`${this.labels.CMEXFieldUpdated}`,`${this.labels.CMEXFieldUpdateSuccessMessage}`, "success", this);
                //this.resetPaginatedCache();

                const upsertSuccess = res.IPResult?.UpsertSuccess || res.IPResult[0]?.UpsertSuccess;
                if (upsertSuccess) {
                    this.showToast(`${this.labels.CMEXFieldUpdated}`, `${this.labels.CMEXFieldUpdateSuccessMessage}`, "success", this);
                    this.resetPaginatedCache();
                } else {
                    this.showToast(`${this.labels.CMEXError}`, `${this.labels.CMEXFieldUpdateFailed}`, "error", this);
                    record[fieldName] = oldValue;
                }
                this.loading = false;
            }).catch(e => {
                console.error(`Field Updation failed ${e}`);
                this.showToast(`${this.labels.CMEXError}`, `${this.labels.CMEXGenericError}`, "error", this);
                record[fieldName] = oldValue;
                this.loading = false;
            });

            this.handleRecords();

        }
    }

    handleAttributeChange(event) {
        this.techEnrichAttrs = event.detail.attributes;
        console.log('dataTableAttr--->' + JSON.stringify(this.techEnrichAttrs));
    }

    handleSaveTechEnrichmentPopup(event) {
        if (this.techEnrichAttrs !== undefined) {
            let objName = 'QuoteLineItem';
            // if (this.recordId.substring(0, 3) === "0QL") {
            //     objName = 'QuoteLineItem';
            // }
            // else if (this.recordId.substring(0, 3) === "802") {
            //     objName = 'OrderItem';
            // }

            let hasError = false;

            const outputJson = this.techEnrichAttrs.reduce((result, item) => {
                if (item.value) {
                    const id = item.therecordId;
                    const attributeName = item.code;
                    const attributeValue = item.value;
    
                    if (!result[id]) {
                        result[id] = {
                            Id: id,
                            fieldVal: {},
                            vlocity_cmt__AttributeSelectedValues__c: {},
                        };
                    }
    
                    if (item.hasCustomError) {
                        hasError = true;
                    } else {
                        result[id][item.isFieldVal ? "fieldVal" : "vlocity_cmt__AttributeSelectedValues__c"][attributeName] = attributeValue;
                    }
                }
                if (item.hasCustomError) {
                    hasError = true;
                }
    
                return result;
            }, {});
            if (hasError) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Invalid Field Values!!',
                        message: 'Please verify the field values and try again',
                        variant: 'error'
                    })
                );
            }
            else {
                const attrListToUpdate = Object.values(outputJson);
                console.log('attrListToUpdate.Vals' + JSON.stringify(attrListToUpdate));
                setAttributeValues({ selectedAttributeJSON: JSON.stringify(attrListToUpdate), objName: objName }).
                    then(() => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Attributes updated successfully',
                                variant: 'success'
                            })
                        );
                        this.handleCloseTechEnrichmentPopup(event);
                        // if (objName === 'QuoteLineItem') {
                        //     //console.log('SaveQLI')
                        //     this.dispatchEvent(new CustomEvent('save', {
                        //         detail: true
                        //     }));
                        // }
                    })
                    .catch(error => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error updating attribute',
                                message: error.message,
                                variant: 'error'
                            })
                        );
                    });
            }
        }
        else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'No Attributes Changed!!',
                    message: 'Edit atleast one attribute to proceed with save',
                    variant: 'warning'
                })
            );
        }   

    }

    renderedCallback() {
        super.renderedCallback();
        this.fetchQuoteDetails(this.route.Quote.id);
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
                setCurrencyCode(JSON.parse(data)[0].Quote[0].vlocity_cmt__PriceListId__r.vlocity_cmt__CurrencyCode__c);
                this.quoteType = JSON.parse(data)[0].Quote[0].vlocity_cmt__Type__c ? JSON.parse(data)[0].Quote[0].vlocity_cmt__Type__c : "undefined";
                console.log("this.quoteType", this.quoteType);
                this.showAddProductBtn = (this.quoteType == "Rebilling" || this.quoteType == "Rate Revision") ? false : true;
                this.showEditCartBtn = (this.quoteType == "Rebilling") ? false : true;
            }).catch(error => {
                console.log('fetchQuoteDetails', error);
            });
    }
}